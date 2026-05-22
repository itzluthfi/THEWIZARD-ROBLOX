local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local BroomController = {}
local isFlying = false
local flySpeed = 50
local verticalSpeed = 30

local bodyVelocity
local bodyGyro

function BroomController.ToggleFlight()
	isFlying = not isFlying
	
	if isFlying then
		humanoid.PlatformStand = true
		
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = hrp
		
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.P = 3000
		bodyGyro.Parent = hrp
		
		print("[BroomController] Flight Started")
	else
		humanoid.PlatformStand = false
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		print("[BroomController] Flight Stopped")
	end
end

RunService.RenderStepped:Connect(function()
	if not isFlying or not bodyVelocity or not bodyGyro then return end
	
	local camera = workspace.CurrentCamera
	local moveDirection = Vector3.new(0, 0, 0)
	
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveDirection += camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveDirection -= camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDirection -= camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveDirection += camera.CFrame.RightVector
	end
	
	-- Keep horizontal movement flat unless looking up/down
	bodyVelocity.Velocity = moveDirection * flySpeed
	bodyGyro.CFrame = camera.CFrame
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		BroomController.ToggleFlight()
	end
end)

return BroomController
