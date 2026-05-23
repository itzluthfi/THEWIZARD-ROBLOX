local CaptureService = game:GetService("CaptureService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local stabilizationMs = 2000
local frameIntervalMs = 300
local frameCount = 20
local PER_FRAME_TIMEOUT_MS = 1000
local READINESS_TIMEOUT_S = 10
local CAPTURE_START_WAIT_MS = 2000
local CAPTURE_CAMERA_ZOOM_DISTANCE = 10

local channel = ReplicatedStorage:WaitForChild("__PlaytestCaptureChannel__", 10)
if not channel then
	return
end

-- Capture sync signal. Connect early so a "start"/"stop" fired by the agent's
-- user LocalScript before our readiness gate completes is buffered into flags
-- rather than lost (BindableEvent doesn't queue without a connection).
local captureSignal = ReplicatedStorage:WaitForChild("__PlaytestCaptureSignal__", 10)
local startReceived = false
local stopReceived = false
local signalConnection
if captureSignal then
	signalConnection = captureSignal.Event:Connect(function(kind)
		if kind == "start" then
			startReceived = true
		elseif kind == "stop" then
			stopReceived = true
		end
	end)
end

-- Capture-readiness gate. Without this the loop opens its window during the
-- post-spawn camera/viewport churn and CaptureScreenshot returns black
-- contentIds — the "frames 4–15 black" pattern from
-- investigation/playtest-gif-cadence-drift-frame-sequencing-2026-05-09.
-- Wait for: character + humanoid + HRP loaded, CurrentCamera focused on
-- the humanoid, then two render frames so Studio has actually painted.
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", READINESS_TIMEOUT_S)
character:WaitForChild("HumanoidRootPart", READINESS_TIMEOUT_S)

local readyDeadline = os.clock() + READINESS_TIMEOUT_S
while os.clock() < readyDeadline do
	local camera = workspace.CurrentCamera
	if camera and humanoid and camera.CameraSubject == humanoid then
		break
	end
	RunService.RenderStepped:Wait()
end
RunService.RenderStepped:Wait()
RunService.RenderStepped:Wait()

-- After readiness, wait for the agent to fire "start" on the capture signal
-- (synchronizes capture window with the mechanic). If no signal arrives within
-- CAPTURE_START_WAIT_MS, fall back to the legacy stabilization-based timing
-- so non-signal-aware playtest scripts still produce GIFs.
local startWaitDeadline = os.clock() + (CAPTURE_START_WAIT_MS / 1000)
while not startReceived and not stopReceived and os.clock() < startWaitDeadline do
	task.wait()
end

-- Fallback stabilization wait: poll for late captureStart so signals
-- that land after CAPTURE_START_WAIT_MS (e.g. when the agent's
-- localScript prologue ran long — `task.wait(2)` + WaitForChild churn
-- routinely fires captureStart at T~2.5s) still drive the capture
-- window. Without the poll, this used to be a blocking task.wait that
-- ignored late signals; a short captureStart→captureStop window then
-- landed entirely inside the wait, leaving stopReceived=true when the
-- frame loop opened → break on iteration 1 → 0 frames → no GIF.
-- See: docs/investigations/playtest-gif-banner-plan-mode-and-errors-2026-05-18.md
-- in lemonade-ui (Issue 2 follow-up — Case B timing race).
if not startReceived then
	local stabDeadline = os.clock() + (stabilizationMs / 1000)
	while not startReceived and not stopReceived and os.clock() < stabDeadline do
		task.wait()
	end
end
-- Snapshot AFTER the polling wait so telemetry reflects late signals —
-- the agent-side log will correctly read `sync=signal` when a late
-- captureStart saved the run, instead of falsely `sync=fallback`.
local startedBySignal = startReceived

-- Capture-time camera zoom: clamp Player.CameraMin/MaxZoomDistance to the
-- same value so Roblox's Custom camera snaps to a fixed close distance for
-- the duration of capture. Saved bounds are restored after the loop. Skipped
-- if the game uses a Scriptable camera (player zoom bounds don't apply).
local savedMinZoom, savedMaxZoom
local zoomApplied = false
local function setZoomBounds(targetMin, targetMax)
	-- Roblox enforces min <= max at write time; pick set order to never
	-- transiently violate that.
	if targetMin > player.CameraMaxZoomDistance then
		player.CameraMaxZoomDistance = targetMax
		player.CameraMinZoomDistance = targetMin
	else
		player.CameraMinZoomDistance = targetMin
		player.CameraMaxZoomDistance = targetMax
	end
end
if not stopReceived then
	local ok = pcall(function()
		savedMinZoom = player.CameraMinZoomDistance
		savedMaxZoom = player.CameraMaxZoomDistance
		setZoomBounds(CAPTURE_CAMERA_ZOOM_DISTANCE, CAPTURE_CAMERA_ZOOM_DISTANCE)
	end)
	if ok then
		zoomApplied = true
		-- Two render ticks so the camera controller honors the new clamp
		-- before the first screenshot lands.
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
	else
		savedMinZoom = nil
		savedMaxZoom = nil
	end
end

-- Sequential capture: CaptureService can't accept concurrent screenshot
-- requests — firing faster than Studio can service them silently drops
-- callbacks. Wait for each callback before the next request, but skip the
-- post-callback inter-frame wait when we're already behind schedule. Cadence
-- becomes max(callback_latency, frameIntervalMs) — never faster than Studio
-- can sustain (no overrun), never slower than callback alone (no
-- callback+intervalMs pile-up).
local startedAt = os.clock()

for i = 1, frameCount do
	-- Early-exit on "stop" — when the agent fires capture stop, we end the
	-- loop rather than waste frames on the post-action stationary tail.
	if stopReceived then
		break
	end

	local id = nil
	local done = false

	local ok = pcall(function()
		CaptureService:CaptureScreenshot(function(contentId)
			id = contentId
			done = true
		end)
	end)

	if ok then
		-- Frame-grain poll (~16 ms) instead of task.wait(0.05) (~50 ms):
		-- shaves the per-frame floor on instant callbacks.
		local waitStart = os.clock()
		while not done and (os.clock() - waitStart) < (PER_FRAME_TIMEOUT_MS / 1000) do
			task.wait()
		end

		if done and id then
			pcall(function()
				channel:FireServer({ kind = "frame", index = i, id = id })
			end)
		end
	end

	if i < frameCount and not stopReceived then
		local nextAt = startedAt + (i * frameIntervalMs / 1000)
		local delta = nextAt - os.clock()
		if delta > 0 then
			task.wait(delta)
		end
	end
end

-- Restore the saved zoom bounds. Runs on every exit path (loop completion,
-- early "stop", per-frame failures) so the player view isn't left clamped.
if zoomApplied then
	pcall(function()
		setZoomBounds(savedMinZoom, savedMaxZoom)
	end)
end

if signalConnection then
	signalConnection:Disconnect()
end

local elapsedMs = (os.clock() - startedAt) * 1000
pcall(function()
	channel:FireServer({
		kind = "done",
		captureWallMs = elapsedMs,
		startedBySignal = startedBySignal,
	})
end)
