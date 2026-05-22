--[[ MainUI.lua — Bottom-left stats + hotbar (slots 1-3 spell, 4 weapon + lock-target ring)
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local Remotes = RS:WaitForChild("RemoteEvents")
local GetData  = Remotes.Functions:WaitForChild("GetPlayerData")
local SyncData = Remotes:WaitForChild("SyncData")
local SlotCooldown = Remotes:WaitForChild("SlotCooldown")
local StaffFireProjectile = Remotes:WaitForChild("StaffFireProjectile")
local SpellsConfig = require(RS:WaitForChild("Config"):WaitForChild("SpellsConfig"))

-- ══════ CLEANUP OLD GUI ═══════════════════════════════════════════════════
local old = guiParent:FindFirstChild("TheWizardUI")
if old and old:IsA("ScreenGui") then old:Destroy() end

local data
local gui = Instance.new("ScreenGui")
gui.Name = "TheWizardUI"
gui.ResetOnSpawn = false
gui.Parent = guiParent

-- ══════ HELPERS ═══════════════════════════════════════════════════════════
local function label(parent, text, pos, sz, font)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextStrokeTransparency = 0.3
	l.Font = font or Enum.Font.GothamBold
	l.TextSize = sz or 16
	l.Text = text
	l.Position = pos.Position
	l.Size = pos.Size
	l.Parent = parent
	return l
end

local V = Vector3.new

-- ══════ COMBAT STATS BARS ═══════════════════════════════════════════════════
-- bar(name, y-offset, fillColor, defaultMax)
-- Returns fill-frame, text-label
local function bar(name, y, fillColor, defaultMax)
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = UDim2.new(0, 24, 1, y)
	f.Size = UDim2.new(0, 380, 0, 28)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	f.Parent = gui
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke", f)
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = fillColor
	fill.BorderSizePixel = 0
	fill.Parent = f
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)
	-- Default text shown until data arrives
	local t = label(f, name .. ": --", { Position = UDim2.new(), Size = UDim2.new(1, 0, 1, 0) }, 14, Enum.Font.GothamBold)
	print("[MainUI] bar '"..name.."' created, text='"..t.Text.."'")
	return fill, t
end

-- Lowered positioning to fit the full 4-slot hotbar
local hpFill,   hpText   = bar("Health", -136, Color3.fromRGB(46, 184, 92))
local manaFill, manaText = bar("Mana",   -104, Color3.fromRGB(45, 100, 220))
local xpFill,   xpText   = bar("XP",     -72,  Color3.fromRGB(212, 160, 23))

-- ══════ CURRENCY BADGES ═════════════════════════════════════════════════════
local currencyFrame = Instance.new("Frame")
currencyFrame.Name = "CurrencyFrame"
currencyFrame.Position = UDim2.new(0, 24, 1, -174)
currencyFrame.Size = UDim2.new(0, 380, 0, 32)
currencyFrame.BackgroundTransparency = 1
currencyFrame.Parent = gui

local currencyLayout = Instance.new("UIListLayout")
currencyLayout.FillDirection = Enum.FillDirection.Horizontal
currencyLayout.Padding = UDim.new(0, 8)
currencyLayout.Parent = currencyFrame

local function mkBadge(name, icon, bgCol, textCol)
	local b = Instance.new("Frame")
	b.Name = name
	b.Size = UDim2.new(0, 118, 1, 0)
	b.BackgroundColor3 = bgCol
	b.Parent = currencyFrame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke", b)
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(36, 40, 50)),
		ColorSequenceKeypoint.new(1, bgCol)
	})
	grad.Rotation = 45
	grad.Parent = b
	local ic = Instance.new("TextLabel")
	ic.Size = UDim2.new(0, 44, 1, 0)
	ic.Position = UDim2.new(0, 6, 0, 0)
	ic.BackgroundTransparency = 1
	ic.Text = icon
	ic.TextSize = 11
	ic.Font = Enum.Font.GothamBold
	ic.TextColor3 = textCol
	ic.Parent = b
	local tx = Instance.new("TextLabel")
	tx.Name = "Text"
	tx.Size = UDim2.new(1, -56, 1, 0)
	tx.Position = UDim2.new(0, 50, 0, 0)
	tx.BackgroundTransparency = 1
	tx.Text = tostring(data and data.Gold or 0)
	tx.TextColor3 = Color3.new(1, 1, 1)
	tx.Font = Enum.Font.GothamBold
	tx.TextSize = 13
	tx.TextXAlignment = Enum.TextXAlignment.Left
	tx.Parent = b
	return tx
end

local goldText   = mkBadge("Gold",   "G",   Color3.fromRGB(32, 28, 16), Color3.fromRGB(255, 215, 0))
local spinsText  = mkBadge("Spins",  "S",   Color3.fromRGB(32, 22, 14), Color3.fromRGB(255, 165, 0))
local pointsText = mkBadge("Points", "P",   Color3.fromRGB(16, 28, 34), Color3.fromRGB(0, 220, 255))

-- ══════ MENU BUTTONS ═══════════════════════════════════════════════════════
local function makeMenuBtn(text, icon, px, bgColor, iconColor, tab)
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(0, px, 0, 16)
	frame.Size = UDim2.new(0, 130, 0, 44)
	frame.BackgroundColor3 = bgColor
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Transparency = 0.7
	stroke.Thickness = 1.5
	local iconF = Instance.new("Frame")
	iconF.Position = UDim2.new(0, 6, 0, 7)
	iconF.Size = UDim2.new(0, 30, 0, 30)
	iconF.BackgroundColor3 = iconColor
	iconF.Parent = frame
	Instance.new("UICorner", iconF).CornerRadius = UDim.new(0, 6)
	local iconT = Instance.new("TextLabel")
	iconT.Size = UDim2.new(1, 0, 1, 0)
	iconT.BackgroundTransparency = 1
	iconT.Text = icon
	iconT.TextColor3 = Color3.new(1, 1, 1)
	iconT.Font = Enum.Font.GothamBold
	iconT.TextSize = 16
	iconT.Parent = iconF
	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.new(0, 40, 0, 0)
	lbl.Size = UDim2.new(1, -44, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = frame
	btn.MouseButton1Click:Connect(function()
		local inv = guiParent:FindFirstChild("InventoryGui")
		if inv then
			if inv.Enabled and inv:GetAttribute("ActiveTab") == tab then
				inv.Enabled = false
			else
				inv:SetAttribute("ActiveTab", tab)
				inv.Enabled = true
			end
		end
	end)
	return frame
end

makeMenuBtn("Inventory", "⚔", 24,  Color3.fromRGB(35, 45, 70), Color3.fromRGB(60, 90, 140), "Spells")
makeMenuBtn("Gacha",    "★", 162, Color3.fromRGB(100, 65, 10), Color3.fromRGB(180, 130, 30), "Gacha")
makeMenuBtn("Stats",    "▲", 300, Color3.fromRGB(30, 65, 40), Color3.fromRGB(50, 120, 70), "Stats")

-- ══════ HOTBAR — 4 SLOTS (1-3 = Spell, 4 = Weapon/Staff) ══════════════════
local hotbar = Instance.new("Frame")
hotbar.AnchorPoint = Vector2.new(0.5, 1)
hotbar.Position = UDim2.new(0.5, 0, 1, -18)
hotbar.Size = UDim2.new(0, 300, 0, 96)
hotbar.BackgroundTransparency = 1
hotbar.Parent = gui
Instance.new("UIListLayout", hotbar).FillDirection = Enum.FillDirection.Horizontal
hotbar:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbar:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, 10)

-- Slot factory: creates a single slot frame for spell or weapon use
-- idx          – 1-based slot index
-- slotType     – "spell" | "weapon"
local slots = {}   -- [i] = {Frame, Name, Overlay, Cd, End, Duration, Type}
local function makeSlot(idx, slotType)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(0, 88, 0, 96)
	s.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	s.Parent = hotbar
	Instance.new("UICorner", s).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", s)
	stroke.Color = Color3.fromRGB(70, 70, 90)
	stroke.Thickness = 1.5

	-- Slot number badge
	label(s, tostring(idx), { Position = UDim2.new(0, 5, 0, 3), Size = UDim2.new(0, 20, 0, 18) }, 12, Enum.Font.GothamBold)

	-- Name label
	local nm = label(s, slotType == "weapon" and "Staff" or "Empty",
		{ Position = UDim2.new(0, 4, 0, 20), Size = UDim2.new(1, -8, 1, -24) }, 14, Enum.Font.GothamBold)
	nm.TextScaled = true
	nm.TextWrapped = true

	-- Cooldown overlay
	local ov = Instance.new("Frame")
	ov.AnchorPoint = Vector2.new(0, 1)
	ov.Position = UDim2.new(0, 0, 1, 0)
	ov.Size = UDim2.new(1, 0, 0, 0)
	ov.BackgroundColor3 = Color3.new(0, 0, 0)
	ov.BackgroundTransparency = 0.25
	ov.Visible = false
	ov.Parent = s
	Instance.new("UICorner", ov).CornerRadius = UDim.new(0, 8)

	-- Cooldown number
	local cd = label(s, "", { Position = UDim2.new(), Size = UDim2.new(1, 0, 1, 0) }, 24, Enum.Font.GothamBold)
	cd.Visible = false

	slots[idx] = {
		Frame = s, Name = nm, Overlay = ov, Cd = cd,
		End = 0, Duration = 1,
		Type = slotType
	}
	return s
end

for i = 1, 3 do makeSlot(i, "spell") end
makeSlot(4, "weapon")

-- ══════ REFRESH — updates bars + slot display ══════════════════════════════
local lockTargetModel  = nil   -- currently locked monster Model
local lockRingPart     = nil
local lockLabelGui     = nil
local LockTargetRemote = Remotes:WaitForChild("LockTarget", 3)

-- Regenerate lock-target ring (clean + rebuild in workspace)
local function ensureLockRing(pos, labelText)
	if lockRingPart then lockRingPart:Destroy() lockRingPart = nil end
	if lockLabelGui then lockLabelGui:Destroy() lockLabelGui = nil end

	local ring = Instance.new("Part")
	ring.Name = "LockRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = V(0.15, 4.5, 4.5)
	ring.CFrame = CFrame.new(pos) * CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, math.pi / 2)
	ring.Color = Color3.fromRGB(255, 70, 70)
	ring.Material = Enum.Material.Neon
	ring.Transparency = 0.1
	ring.Anchored = true
	ring.CanCollide = false
	ring.CastShadow = false
	ring.Parent = Workspace
	lockRingPart = ring

	-- Rising ping-pong animation so the ring stays attention-grabbing
	task.spawn(function()
		local t0 = os.clock()
		while ring and ring.Parent and lockTargetModel do
			local t = os.clock() - t0
			ring.CFrame = CFrame.new(pos + V(0, math.sin(t * 3) * 0.4 + 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
			ring.Size = V(0.15, 4.5 + math.sin(t * 3) * 1, 4.5 + math.sin(t * 3) * 1)
			task.wait()
		end
	end)

	-- Billboards label above the ring
	if labelText and labelText ~= "" then
		local bbg = Instance.new("BillboardGui")
		bbg.Size = UDim2.new(0, 180, 0, 36)
		bbg.StudsOffset = V(0, 4, 0)
		bbg.AlwaysOnTop = true
		bbg.Parent = Workspace
		lockLabelGui = bbg
		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, 0, 1, 0)
		t.BackgroundTransparency = 1
		t.Text = "🎯 " .. labelText
		t.TextColor3 = Color3.fromRGB(255, 220, 80)
		t.Font = Enum.Font.GothamBold
		t.TextSize = 14
		t.TextStrokeTransparency = 0.3
		t.Parent = bbg
	end
end

local function clearLockRing()
	if lockRingPart then lockRingPart:Destroy() lockRingPart = nil end
	if lockLabelGui then lockLabelGui:Destroy() lockLabelGui = nil end
	lockTargetModel = nil
end

-- Listen for server lock-target notifications
if LockTargetRemote then
	LockTargetRemote.OnClientEvent:Connect(function(targetModel)
		if not targetModel or not targetModel.Parent then
			clearLockRing()
			return
		end
		lockTargetModel = targetModel
		local name = targetModel.Name
		local root = targetModel:FindFirstChild("HumanoidRootPart")
		if root then ensureLockRing(root.Position, name) end
	end)
end

-- Handle character switch
player.CharacterAdded:Connect(function()
	clearLockRing()
end)

local function refresh()
	-- ── Character-dependent stats ──────────────────────────────────────────
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hpFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
		hpText.Text = "Health: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
		local pct = hum.Health / hum.MaxHealth
		if pct > 0.5 then
			hpFill.BackgroundColor3 = Color3.fromRGB(46, 184, 92)
		elseif pct > 0.25 then
			hpFill.BackgroundColor3 = Color3.fromRGB(220, 160, 30)
		else
			hpFill.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		end
	end

	-- ── Mana ───────────────────────────────────────────────────────────────
	local maxM = (data and data.MaxMana) or 100
	local m    = (data and data.Mana) or maxM
	print("[MainUI] refresh data="..tostring(data).." maxM="..tostring(maxM).." m="..tostring(m))
	manaFill.Size = UDim2.new(math.clamp(m / maxM, 0, 1), 0, 1, 0)
	manaText.Text = "Mana: " .. math.floor(m) .. "/" .. math.floor(maxM)
	-- ── XP ─────────────────────────────────────────────────────────────────
	local xp   = data and data.XP    or 0
	local need = data and data.XPToNext or 100
	print("[MainUI] xp="..tostring(xp).." need="..tostring(need).." level="..tostring(data and data.Level))
	xpFill.Size = UDim2.new(math.clamp(xp / need, 0, 1), 0, 1, 0)
	xpText.Text = "Level " .. tostring(data and data.Level or 1) .. " | XP: " .. xp .. "/" .. need

	-- ── Currency ───────────────────────────────────────────────────────────
	goldText.Text   = tostring(data and data.Gold or 0)
	spinsText.Text  = tostring(data and data.FreeSpins or 0)
	pointsText.Text = tostring(data and data.StatPoints or 0)

	-- ── Hotbar slots 1-3 (spells) + slot 4 (weapon) ───────────────────────
	for i = 1, 3 do
		local sn = data and data.EquippedSpells and data.EquippedSpells[i]
		if sn then
			local sp = SpellsConfig.GetSpell(sn)
			slots[i].Name.Text = sn
			slots[i].Frame.BackgroundColor3 = sp and sp.Effect and sp.Effect.Color or Color3.fromRGB(50, 50, 55)
		else
			slots[i].Name.Text = "Empty"
			slots[i].Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		end
	end

	-- Slot 4: show equipped weapon from equipped data
	local wpn = data and data.EquippedSpells and data.EquippedSpells[4]
	if wpn then
		slots[4].Name.Text = wpn
		slots[4].Frame.BackgroundColor3 = Color3.fromRGB(60, 160, 220)
	else
		slots[4].Name.Text = "Empty"
		slots[4].Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	end
end

-- ══════ SPELL CASTING — Slot clicks 1-3 + CastSpell bridge ══════════════
-- Use BindableEvent for client-to-client communication
local CastSpellBindable = Remotes:FindFirstChild("CastSpellBindable")

-- Click handler for spell slots
for i = 1, 3 do
	local slotFrame = slots[i].Frame
	slotFrame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local sn = data and data.EquippedSpells and data.EquippedSpells[i]
		if not sn then return end
		local sp = SpellsConfig.GetSpell(sn)
		if not sp then return end
		local cost = sp.ManaCost or 0
		local currentMana = data and data.Mana or 0
		if currentMana < cost then return end
		-- Fire BindableEvent for SpellCaster to handle
		if CastSpellBindable and CastSpellBindable:IsA("BindableEvent") then
			CastSpellBindable:Fire(i)
		end
	end)
end

-- Click handler for weapon slot 4 — fires StaffFireProjectile directly
local wpnCoolingDown = false
slots[4].Frame.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if wpnCoolingDown then return end

	-- Get the equipped weapon name from data
	local wpn = data and data.EquippedSpells and data.EquippedSpells[4]
	if not wpn then return end

	-- Use mouse position as target (fallback to forward ray if mouse not available)
	local mouse = player:GetMouse()
	local target = mouse.Hit and mouse.Hit.Position or root.Position + root.CFrame.LookVector * 60

	StaffFireProjectile:FireServer(wpn, target)
end)

-- Handle character switch — refresh HP bar on respawn
player.CharacterAdded:Connect(function(char)
	task.wait(0.1) -- small delay for Humanoid to initialize
	refresh()
end)

-- ══════ NETWORKING ═══════════════════════════════════════════════════════
data = GetData:InvokeServer()  -- capture initial data immediately
refresh()

SyncData.OnClientEvent:Connect(function(d)
	data = d
	refresh()
end)

SlotCooldown.OnClientEvent:Connect(function(slot, duration)
	if slots[slot] then
		slots[slot].End = os.clock() + duration
		slots[slot].Duration = math.max(duration, 0.05)
		slots[slot].Overlay.Visible = true
		slots[slot].Cd.Visible = true
	end
end)

RunService.RenderStepped:Connect(function()
	refresh()

	-- Cooldown overlay sweep
	for _, s in ipairs(slots) do
		local remain = s.End - os.clock()
		if remain > 0 then
			s.Overlay.Size = UDim2.new(1, 0, math.clamp(remain / s.Duration, 0, 1), 0)
			s.Cd.Text = tostring(math.ceil(remain))
		else
			s.Overlay.Visible = false
			s.Cd.Visible = false
		end
	end

	-- Keep lock ring tracking its monster head
	if lockTargetModel and lockRingPart then
		local root = lockTargetModel:FindFirstChild("HumanoidRootPart")
		if root then
			lockRingPart.CFrame = CFrame.new(root.Position + V(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
			if lockLabelGui then
				lockLabelGui.StudsOffset = V(0, 4, 0)
			end
		else
			clearLockRing()
		end
	end
end)

GetData:InvokeServer()
