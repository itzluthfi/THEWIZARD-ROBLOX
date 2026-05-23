--[[ MainUI.lua — Bottom-left stats + Item hotbar (slots 1-4) + Spell bar (right side)
     Slots 1-4 = Items/Weapons (keys 1-4 or click)
     Spell bar = 4 spells (keys Z, X, C, V)
     LMB = Basic Attack (auto-lock nearest monster)
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

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
local function bar(name, y, fillColor)
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
	local t = label(f, name .. ": --", { Position = UDim2.new(), Size = UDim2.new(1, 0, 1, 0) }, 14, Enum.Font.GothamBold)
	return fill, t
end

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
makeMenuBtn("Weapons", "⚔", 162, Color3.fromRGB(35, 45, 70), Color3.fromRGB(100, 140, 200), "Weapons")
makeMenuBtn("Gacha",    "★", 300, Color3.fromRGB(100, 65, 10), Color3.fromRGB(180, 130, 30), "Gacha")
makeMenuBtn("Stats",    "▲", 438, Color3.fromRGB(30, 65, 40), Color3.fromRGB(50, 120, 70), "Stats")

-- ══════ ITEM HOTBAR — 4 SLOTS (slots 1-4 for items/weapons) ══════════════════
local itemHotbar = Instance.new("Frame")
itemHotbar.AnchorPoint = Vector2.new(0.5, 1)
itemHotbar.Position = UDim2.new(0.5, 0, 1, -18)
itemHotbar.Size = UDim2.new(0, 300, 0, 96)
itemHotbar.BackgroundTransparency = 1
itemHotbar.Parent = gui
Instance.new("UIListLayout", itemHotbar).FillDirection = Enum.FillDirection.Horizontal
itemHotbar:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Center
itemHotbar:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, 10)

-- Slot factory for items
local itemSlots = {}  -- [i] = {Frame, Name, Overlay, Cd, End, Duration, Icon, EquipBtn}
local function makeItemSlot(idx)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(0, 88, 0, 96)
	s.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	s.Parent = itemHotbar
	Instance.new("UICorner", s).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", s)
	stroke.Name = "Border"
	stroke.Color = Color3.fromRGB(70, 70, 90)
	stroke.Thickness = 2

	-- Slot number badge
	label(s, tostring(idx), { Position = UDim2.new(0, 5, 0, 3), Size = UDim2.new(0, 20, 0, 18) }, 12, Enum.Font.GothamBold)

	-- Item icon (large)
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(1, 0, 0, 40)
	icon.Position = UDim2.new(0, 0, 0, 22)
	icon.BackgroundTransparency = 1
	icon.Text = "📦"
	icon.TextSize = 28
	icon.Font = Enum.Font.GothamBold
	icon.TextColor3 = Color3.new(1, 1, 1)
	icon.Parent = s

	-- Item name
	local nm = Instance.new("TextLabel")
	nm.Name = "Name"
	nm.Size = UDim2.new(1, -4, 0, 24)
	nm.Position = UDim2.new(0, 2, 1, -28)
	nm.BackgroundTransparency = 1
	nm.Text = "Empty"
	nm.TextColor3 = Color3.fromRGB(150, 150, 150)
	nm.Font = Enum.Font.GothamBold
	nm.TextSize = 10
	nm.TextWrapped = true
	nm.TextScaled = true
	nm.Parent = s

	-- Equipped indicator
	local equipBadge = Instance.new("TextLabel")
	equipBadge.Name = "EquippedBadge"
	equipBadge.Size = UDim2.new(0, 60, 0, 16)
	equipBadge.Position = UDim2.new(0.5, -30, 0, -8)
	equipBadge.BackgroundColor3 = Color3.fromRGB(35, 150, 60)
	equipBadge.Text = "✓ EQUIPPED"
	equipBadge.TextColor3 = Color3.new(1, 1, 1)
	equipBadge.Font = Enum.Font.GothamBold
	equipBadge.TextSize = 8
	equipBadge.Visible = false
	equipBadge.Parent = s
	Instance.new("UICorner", equipBadge).CornerRadius = UDim.new(0, 4)

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

	itemSlots[idx] = {
		Frame = s, Name = nm, Icon = icon, Border = stroke,
		Overlay = ov, EquipBadge = equipBadge,
		End = 0, Duration = 1, ItemName = nil
	}
	return s
end

for i = 1, 4 do makeItemSlot(i) end

-- ══════ SPELL BAR — 4 SLOTS on right side (keys Z, X, C, V) ══════════════════
local spellBar = Instance.new("Frame")
spellBar.AnchorPoint = Vector2.new(1, 0.5)
spellBar.Position = UDim2.new(1, -24, 0.5, 0)
spellBar.Size = UDim2.new(0, 80, 0, 340)
spellBar.BackgroundTransparency = 1
spellBar.Parent = gui

local spellLayout = Instance.new("UIListLayout")
spellLayout.FillDirection = Enum.FillDirection.Vertical
spellLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
spellLayout.Padding = UDim.new(0, 8)
spellLayout.Parent = spellBar

-- Spell bar title
local spellTitle = Instance.new("TextLabel")
spellTitle.Size = UDim2.new(1, 0, 0, 24)
spellTitle.BackgroundTransparency = 1
spellTitle.Text = "🔮 SPELLS"
spellTitle.TextColor3 = Color3.new(1, 1, 1)
spellTitle.Font = Enum.Font.GothamBold
spellTitle.TextSize = 12
spellTitle.Parent = spellBar

local spellSlots = {}  -- [i] = {Frame, Name, KeyLabel, Overlay, Cd, End, Duration}
local spellKeys = {"Z", "X", "C", "V"}
local spellIcons = {"✨", "🔥", "❄️", "⚡"}

local function makeSpellSlot(idx)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(0, 70, 0, 70)
	s.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	s.Parent = spellBar
	Instance.new("UICorner", s).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", s)
	stroke.Color = Color3.fromRGB(70, 70, 90)
	stroke.Thickness = 2

	-- Key badge
	local keyBadge = Instance.new("TextLabel")
	keyBadge.Size = UDim2.new(0, 24, 0, 20)
	keyBadge.Position = UDim2.new(0, 3, 0, 3)
	keyBadge.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	keyBadge.Text = spellKeys[idx]
	keyBadge.TextColor3 = Color3.new(1, 1, 1)
	keyBadge.Font = Enum.Font.GothamBold
	keyBadge.TextSize = 12
	keyBadge.Parent = s
	Instance.new("UICorner", keyBadge).CornerRadius = UDim.new(0, 4)

	-- Spell icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 0, 30)
	icon.Position = UDim2.new(0, 0, 0, 25)
	icon.BackgroundTransparency = 1
	icon.Text = spellIcons[idx] or "✨"
	icon.TextSize = 24
	icon.Font = Enum.Font.GothamBold
	icon.TextColor3 = Color3.new(1, 1, 1)
	icon.Parent = s

	-- Spell name
	local nm = Instance.new("TextLabel")
	nm.Name = "Name"
	nm.Size = UDim2.new(1, -4, 0, 16)
	nm.Position = UDim2.new(0, 2, 1, -20)
	nm.BackgroundTransparency = 1
	nm.Text = "Empty"
	nm.TextColor3 = Color3.fromRGB(150, 150, 150)
	nm.Font = Enum.Font.GothamBold
	nm.TextSize = 9
	nm.TextWrapped = true
	nm.TextScaled = true
	nm.Parent = s

	-- Cooldown overlay
	local ov = Instance.new("Frame")
	ov.AnchorPoint = Vector2.new(0, 1)
	ov.Position = UDim2.new(0, 0, 1, 0)
	ov.Size = UDim2.new(1, 0, 0, 0)
	ov.BackgroundColor3 = Color3.new(0, 0, 0)
	ov.BackgroundTransparency = 0.3
	ov.Visible = false
	ov.Parent = s
	Instance.new("UICorner", ov).CornerRadius = UDim.new(0, 8)

	spellSlots[idx] = {
		Frame = s, Name = nm, KeyLabel = keyBadge, Icon = icon, Border = stroke,
		Overlay = ov, End = 0, Duration = 1, SpellName = nil
	}
	return s
end

for i = 1, 4 do makeSpellSlot(i) end

-- ══════ TARGET LOCK INDICATOR ════════════════════════════════════════════════
local lockedTarget = nil
local lockIndicator = nil

local function showLockIndicator(targetModel)
	if lockIndicator then lockIndicator:Destroy() end
	if not targetModel or not targetModel.Parent then return end

	local hrp = targetModel:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Create a ring indicator around the target
	local ring = Instance.new("Part")
	ring.Name = "LockIndicator"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.2, 6, 6)
	ring.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90))
	ring.Color = Color3.fromRGB(255, 50, 50)
	ring.Material = Enum.Material.Neon
	ring.Transparency = 0.2
	ring.Anchored = true
	ring.CanCollide = false
	ring.CastShadow = false
	ring.Parent = Workspace

	-- Billboard above target
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 150, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local lockText = Instance.new("TextLabel")
	lockText.Size = UDim2.new(1, 0, 1, 0)
	lockText.BackgroundTransparency = 1
	lockText.Text = "🎯 LOCKED"
	lockText.TextColor3 = Color3.fromRGB(255, 80, 80)
	lockText.Font = Enum.Font.GothamBold
	lockText.TextSize = 14
	lockText.TextStrokeTransparency = 0.3
	lockText.Parent = billboard

	-- Animate ring rotation
	task.spawn(function()
		local startTime = os.clock()
		while ring and ring.Parent and targetModel and targetModel.Parent do
			local elapsed = os.clock() - startTime
			ring.CFrame = hrp.CFrame * CFrame.Angles(0, elapsed * 2, math.rad(90))
			task.wait()
		end
	end)

	lockIndicator = ring
	lockedTarget = targetModel
end

local function clearLockIndicator()
	if lockIndicator then
		lockIndicator:Destroy()
		lockIndicator = nil
	end
	lockedTarget = nil
end

-- ══════ REFRESH ════════════════════════════════════════════════════════════════
local function refresh()
	-- Character stats
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

	local maxM = (data and data.MaxMana) or 100
	local m    = (data and data.Mana) or maxM
	manaFill.Size = UDim2.new(math.clamp(m / maxM, 0, 1), 0, 1, 0)
	manaText.Text = "Mana: " .. math.floor(m) .. "/" .. math.floor(maxM)

	local xp   = data and data.XP    or 0
	local need = data and data.XPToNext or 100
	xpFill.Size = UDim2.new(math.clamp(xp / need, 0, 1), 0, 1, 0)
	xpText.Text = "Level " .. tostring(data and data.Level or 1) .. " | XP: " .. xp .. "/" .. need

	-- Currency
	goldText.Text   = tostring(data and data.Gold or 0)
	spinsText.Text  = tostring(data and data.FreeSpins or 0)
	pointsText.Text = tostring(data and data.StatPoints or 0)

	-- Item slots (1-4 from EquippedSpells - ONLY for items/weapons, NOT spells)
	for i = 1, 4 do
		local slot = itemSlots[i]
		local itemName = data and data.EquippedSpells and data.EquippedSpells[i]

		-- Only show if it's a weapon (in UnlockedWeapons) or empty
		local isWeapon = false
		if itemName and data then
			for _, w in ipairs(data.UnlockedWeapons or {}) do
				if w == itemName then isWeapon = true break end
			end
		end

		if itemName and isWeapon then
			slot.Name.Text = itemName
			slot.Icon.Text = "⚔️"
			slot.Frame.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
			slot.Border.Color = Color3.fromRGB(80, 140, 220)
			-- Show equipped badge only for slot 4 (weapon slot)
			slot.EquipBadge.Visible = (i == 4)
		else
			slot.Name.Text = "Empty"
			slot.Icon.Text = "📦"
			slot.Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			slot.Border.Color = Color3.fromRGB(70, 70, 90)
			slot.EquipBadge.Visible = false
		end
	end

	-- Spell slots (from data.SpellBar - spells equipped via inventory)
	for i = 1, 4 do
		local spellName = data and data.SpellBar and data.SpellBar[i]
		local slot = spellSlots[i]
		if spellName and spellName ~= "" and spellName then
			local spell = SpellsConfig.GetSpell(spellName)
			slot.Name.Text = spellName
			slot.Icon.Text = spellIcons[i] or "✨"
			slot.Border.Color = spell and (spell.Effect and spell.Effect.Color or Color3.fromRGB(100, 100, 255)) or Color3.fromRGB(100, 100, 255)
			slot.Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
		else
			slot.Name.Text = "Empty"
			slot.Icon.Text = spellIcons[i]
			slot.Border.Color = Color3.fromRGB(70, 70, 90)
			slot.Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		end
	end
end

-- ══════ SPELL CASTING BRIDGE ═════════════════════════════════════════════════
local CastSpellBindable = Remotes:FindFirstChild("CastSpellBindable")

-- Click handler for spell slots (right side)
for i = 1, 4 do
	local slotFrame = spellSlots[i].Frame
	slotFrame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local spellName = data and data.SpellBar and data.SpellBar[i]
		-- Only fire if spell is equipped and not empty
		if not spellName or spellName == "" then return end
		if CastSpellBindable and CastSpellBindable:IsA("BindableEvent") then
			CastSpellBindable:Fire(i)
		end
	end)
end

-- ══════ NETWORKING ═══════════════════════════════════════════════════════
data = GetData:InvokeServer()
refresh()

SyncData.OnClientEvent:Connect(function(d)
	data = d
	refresh()
end)

SlotCooldown.OnClientEvent:Connect(function(slot, duration, isSpell)
	-- isSpell=true means spell slot (Z,X,C,V on right side)
	-- isSpell=false/nil means item slot (1,2,3,4 on bottom)
	if isSpell then
		-- Spell bar cooldown (right side)
		if spellSlots[slot] then
			spellSlots[slot].End = os.clock() + duration
			spellSlots[slot].Duration = math.max(duration, 0.05)
			spellSlots[slot].Overlay.Visible = true
		end
	else
		-- Item slot cooldown (bottom)
		if itemSlots[slot] then
			itemSlots[slot].End = os.clock() + duration
			itemSlots[slot].Duration = math.max(duration, 0.05)
			itemSlots[slot].Overlay.Visible = true
		end
	end
end)

-- ══════ LOCK TARGET INDICATOR ═════════════════════════════════════════════════
local LockTargetRemote = Remotes:FindFirstChild("LockTarget")
if LockTargetRemote then
	LockTargetRemote.OnClientEvent:Connect(function(targetModel)
		if targetModel and targetModel.Parent then
			showLockIndicator(targetModel)
		else
			clearLockIndicator()
		end
	end)
end

-- ══════ PROXIMITY AUTO-LOCK ══════════════════════════════════════════════════
-- Show lock indicator automatically when a monster is near camera center
local LOCK_RANGE = 120
local AUTO_LOCK_INTERVAL = 0.2 -- seconds
local lastLockedModel = nil
local Camera = workspace.CurrentCamera

local function getMonsterNearCenter()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local bestTarget = nil
	local minCenterDist = 0.5 -- Max distance from center (normalized 0 to 1)

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:GetAttribute("IsMonster") then
			local hrp = model:FindFirstChild("HumanoidRootPart")
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local dist = (hrp.Position - root.Position).Magnitude
				if dist < LOCK_RANGE then
					local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
					if onScreen then
						-- Distance from center of screen (0.5, 0.5)
						local viewportSize = Camera.ViewportSize
						local center = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
						local monsterScreenPos = Vector2.new(screenPos.X, screenPos.Y)
						local distFromCenter = (monsterScreenPos - center).Magnitude / viewportSize.Y -- normalized by height
						
						if distFromCenter < minCenterDist then
							minCenterDist = distFromCenter
							bestTarget = model
						end
					end
				end
			end
		end
	end
	return bestTarget
end

task.spawn(function()
	while true do
		local nearestModel = getMonsterNearCenter()

		if nearestModel then
			if nearestModel ~= lastLockedModel then
				lastLockedModel = nearestModel
				showLockIndicator(nearestModel)
				gui:SetAttribute("LockedTarget", nearestModel.Name) -- Store name or reference
				-- Since we can't store references in attributes easily for models in workspace that might be deleted,
				-- we'll use an ObjectValue or just rely on the lockedTarget variable if we can bridge it.
				-- For now, let's use an ObjectValue inside the GUI.
				local val = gui:FindFirstChild("LockedTargetValue") or Instance.new("ObjectValue")
				val.Name = "LockedTargetValue"
				val.Value = nearestModel
				val.Parent = gui
			end
		elseif lastLockedModel then
			lastLockedModel = nil
			clearLockIndicator()
			local val = gui:FindFirstChild("LockedTargetValue")
			if val then val.Value = nil end
		end

		task.wait(AUTO_LOCK_INTERVAL)
	end
end)

-- ══════ CHARACTER SWITCH ═══════════════════════════════════════════════════════
player.CharacterAdded:Connect(function(char)
	clearLockIndicator()
	lastLockedModel = nil
	task.wait(0.1)
	refresh()
end)

-- ══════ RENDER STEP ═══════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
	-- Cooldown sweep for item slots
	for _, s in ipairs(itemSlots) do
		local remain = s.End - os.clock()
		if remain > 0 then
			s.Overlay.Size = UDim2.new(1, 0, math.clamp(remain / s.Duration, 0, 1), 0)
			s.Overlay.Visible = true
		else
			s.Overlay.Visible = false
		end
	end

	-- Cooldown sweep for spell slots
	for _, s in ipairs(spellSlots) do
		local remain = s.End - os.clock()
		if remain > 0 then
			s.Overlay.Size = UDim2.new(1, 0, math.clamp(remain / s.Duration, 0, 1), 0)
			s.Overlay.Visible = true
		else
			s.Overlay.Visible = false
		end
	end

	-- Track locked target
	if lockedTarget and lockIndicator then
		local hrp = lockedTarget:FindFirstChild("HumanoidRootPart")
		if hrp then
			lockIndicator.CFrame = hrp.CFrame * CFrame.Angles(0, os.clock() * 2, math.rad(90))
			-- Update Billboard position manually to ensure it follows perfectly
			local billboard = hrp:FindFirstChildOfClass("BillboardGui")
			if billboard then
				billboard.Enabled = true
			end
		else
			clearLockIndicator()
		end
	end
end)

local function showAlert(text, color)
	local old = gui:FindFirstChild("AlertText")
	if old then old:Destroy() end

	local alert = Instance.new("TextLabel")
	alert.Name = "AlertText"
	alert.Size = UDim2.new(0,400,0,50)
	alert.Position = UDim2.new(0.5,-200,0.3,0)
	alert.BackgroundTransparency = 1
	alert.Text = text
	alert.TextColor3 = color
	alert.Font = Enum.Font.GothamBold
	alert.TextSize = 24
	alert.TextStrokeTransparency = 0.5
	alert.Parent = gui

	local ts = game:GetService("TweenService")
	ts:Create(alert, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0.5,-200,0.25,0)}):Play()

	task.delay(1.5, function()
		if alert and alert.Parent then
			ts:Create(alert, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			task.delay(0.5, function() alert:Destroy() end)
		end
	end)
end

local CastSpellRemote = Remotes:FindFirstChild("CastSpell") or Remotes:FindFirstChild("SpellCast")
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.V then
		local keyToSlot = { [Enum.KeyCode.Z] = 1, [Enum.KeyCode.X] = 2, [Enum.KeyCode.C] = 3, [Enum.KeyCode.V] = 4 }
		local slot = keyToSlot[input.KeyCode]
		local spellName = data and data.SpellBar and data.SpellBar[slot]
		if not spellName or spellName == "" then
			showAlert("Slot " .. input.KeyCode.Name .. " Belum Ada Spell Ter-Equip! 🔮", Color3.fromRGB(255, 100, 100))
		end
	end
end)

GetData:InvokeServer()