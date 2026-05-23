local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local player = Players.LocalPlayer
local parent = player:WaitForChild("PlayerGui")
local Remotes = RS:WaitForChild("RemoteEvents")
local SyncData = Remotes:WaitForChild("SyncData")
local GetData = Remotes.Functions:WaitForChild("GetPlayerData")
local Gacha = Remotes:WaitForChild("GachaSpell")
local Equip = Remotes:WaitForChild("EquipSpell")
local AllocateStat = Remotes:WaitForChild("AllocateStat")
local SpellsConfig = require(RS:WaitForChild("Config"):WaitForChild("SpellsConfig"))
local data

-- Icon texture IDs from Simulator Icon Pack
local ICONS = {
	-- Stats icons
	Star = "rbxassetid://17368097932",
	CoinIcon = "rbxassetid://17368060122",
	RNG = "rbxassetid://17368109454",
	Health = "rbxassetid://17368075795",
	Power = "rbxassetid://17368210998",
	Energy = "rbxassetid://17368078790",
	Speed = "rbxassetid://17368052918",
	Playtime = "rbxassetid://15937828418",
	TripleStars = "rbxassetid://15403047368",
	Kills = "rbxassetid://17368093079",
	Strength = "rbxassetid://15403007921",
	GemIcon = "rbxassetid://17368064384",
	-- Menu/Action icons
	Inventory = "rbxassetid://15402958715",
	Accept = "rbxassetid://17368190066",
	Deny = "rbxassetid://17368208554",
	Question = "rbxassetid://15403140844",
}

-- Element icons (using element colors as visual indicators)
local elementIcons = {
	Fire = "🔥",
	Ice = "❄️",
	Poison = "☠️",
	Arcane = "✨",
	Lightning = "⚡",
	Physical = "⚔️",
	Void = "🌀",
	Dark = "🌑",
}

-- Helper function to create ImageLabel icon
local function createIcon(parent, textureId, size, position, color)
	local img = Instance.new("ImageLabel")
	img.Size = size or UDim2.new(0, 24, 0, 24)
	img.Position = position or UDim2.new(0, 0, 0, 0)
	img.BackgroundTransparency = 1
	img.Image = textureId
	if color then
		img.ImageColor3 = color
	end
	img.Parent = parent
	return img
end

local old = parent:FindFirstChild("InventoryGui")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryGui"
gui.Enabled = false
gui.ResetOnSpawn = false
gui.Parent = parent
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Dismiss Overlay (Click outside modal to close)
local dismissOverlay = Instance.new("TextButton")
dismissOverlay.Name = "DismissOverlay"
dismissOverlay.Size = UDim2.new(1, 0, 1, 0)
dismissOverlay.BackgroundTransparency = 1
dismissOverlay.Text = ""
dismissOverlay.ZIndex = 1
dismissOverlay.Parent = gui
dismissOverlay.MouseButton1Click:Connect(function() gui.Enabled = false end)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,740,0,520)
panel.Position = UDim2.new(0.5,-370,0.5,-260)
panel.BackgroundColor3 = Color3.fromRGB(18,20,28)
panel.ZIndex = 2
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)
local panelStroke = Instance.new("UIStroke",panel)
panelStroke.Color = Color3.fromRGB(80,85,110)
panelStroke.Thickness = 2

-- Title with icon
local titleIcon = createIcon(panel, ICONS.Inventory, UDim2.new(0, 28, 0, 28), UDim2.new(0, 14, 0, 14))
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-90,0,40)
title.Position = UDim2.new(0,46,0,8)
title.BackgroundTransparency = 1
title.Text = "Inventory"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.Text = ""
close.Size = UDim2.new(0,34,0,34)
close.Position = UDim2.new(1,-44,0,8)
close.BackgroundColor3 = Color3.fromRGB(100,30,30)
close.Parent = panel
Instance.new("UICorner",close).CornerRadius = UDim.new(0,6)
local closeIcon = createIcon(close, ICONS.Deny, UDim2.new(0, 20, 0, 20), UDim2.new(0.5, -10, 0.5, -10))
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- Player info header
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1,-28,0,50)
headerFrame.Position = UDim2.new(0,14,0,52)
headerFrame.BackgroundColor3 = Color3.fromRGB(25,28,38)
headerFrame.BackgroundTransparency = 0.5
headerFrame.Parent = panel
Instance.new("UICorner",headerFrame).CornerRadius = UDim.new(0,8)

local headerLayout = Instance.new("UIListLayout")
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
headerLayout.Padding = UDim.new(0,20)
headerLayout.Parent = headerFrame



local function makeHeaderBadge(iconTexture, text, color)
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0,120,0,30)
	badge.BackgroundColor3 = Color3.fromRGB(30,32,45)
	badge.Parent = headerFrame
	Instance.new("UICorner",badge).CornerRadius = UDim.new(0,6)
	local stroke = Instance.new("UIStroke",badge)
	stroke.Color = color
	stroke.Thickness = 1

	local ic = Instance.new("ImageLabel")
	ic.Size = UDim2.new(0,24,0,24)
	ic.Position = UDim2.new(0,4,0.5,-12)
	ic.BackgroundTransparency = 1
	ic.Image = iconTexture
	ic.Parent = badge

	local tx = Instance.new("TextLabel")
	tx.Size = UDim2.new(1,-32,1,0)
	tx.Position = UDim2.new(0,30,0,0)
	tx.BackgroundTransparency = 1
	tx.Text = text
	tx.TextColor3 = Color3.new(1,1,1)
	tx.Font = Enum.Font.GothamBold
	tx.TextSize = 12
	tx.TextXAlignment = Enum.TextXAlignment.Left
	tx.Name = "Value"
	tx.Parent = badge

	return badge
end

local levelBadge = makeHeaderBadge(ICONS.Star, "Lv.1", Color3.fromRGB(255,200,50))
local goldBadge = makeHeaderBadge(ICONS.CoinIcon, "0", Color3.fromRGB(255,215,0))
local spinsBadge = makeHeaderBadge(ICONS.RNG, "5", Color3.fromRGB(180,130,30))

local pages, buttons = {}, {}
local function switchTab(name)
	for n, page in pairs(pages) do
		page.Visible = n == name
		buttons[n].BackgroundColor3 = n == name and Color3.fromRGB(60,75,120) or Color3.fromRGB(35,40,55)
	end
	local tabNames = {Spells="Spells",Weapons="Weapons",Gacha="Gacha",Stats="Stats"}
	title.Text = tabNames[name] or name
end

local tabIconTextures = {
	Spells = ICONS.GemIcon,
	Weapons = ICONS.Kills,
	Gacha = ICONS.RNG,
	Stats = ICONS.TripleStars
}
for i, name in ipairs({"Spells","Weapons","Gacha","Stats"}) do
	local b = Instance.new("TextButton")
	b.Text = ""
	b.Size = UDim2.new(0,110,0,36)
	b.Position = UDim2.new(0,14+(i-1)*118,0,108)
	b.BackgroundColor3 = i==1 and Color3.fromRGB(60,75,120) or Color3.fromRGB(35,40,55)
	b.Parent = panel
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
	-- Tab icon
	local tabIcon = createIcon(b, tabIconTextures[name], UDim2.new(0, 20, 0, 20), UDim2.new(0, 8, 0.5, -10))
	-- Tab label
	local tabLabel = Instance.new("TextLabel")
	tabLabel.Size = UDim2.new(1, -32, 1, 0)
	tabLabel.Position = UDim2.new(0, 30, 0, 0)
	tabLabel.BackgroundTransparency = 1
	tabLabel.Text = name
	tabLabel.TextColor3 = Color3.new(1,1,1)
	tabLabel.Font = Enum.Font.GothamBold
	tabLabel.TextSize = 13
	tabLabel.Parent = b
	buttons[name] = b
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1,-28,1,-155)
	p.Position = UDim2.new(0,14,0,150)
	p.BackgroundTransparency = 1
	p.Visible = i == 1
	p.Parent = panel
	pages[name] = p
	b.MouseButton1Click:Connect(function() switchTab(name) end)
end

gui:GetAttributeChangedSignal("ActiveTab"):Connect(function()
	local tab = gui:GetAttribute("ActiveTab")
	if tab and pages[tab] then switchTab(tab) end
end)

-- ══════ TAB: SPELLS ══════
local spellList = Instance.new("ScrollingFrame")
spellList.Size = UDim2.new(1,0,1,0)
spellList.BackgroundTransparency = 1
spellList.BorderSizePixel = 0
spellList.ScrollBarThickness = 6
spellList.ScrollBarImageColor3 = Color3.fromRGB(80,80,100)
spellList.Parent = pages.Spells
local spellGrid = Instance.new("UIGridLayout")
spellGrid.CellSize = UDim2.new(0,170,0,130)
spellGrid.CellPadding = UDim2.new(0,10,0,10)
spellGrid.Parent = spellList

-- ══════ TAB: WEAPONS ══════
local weaponList = Instance.new("ScrollingFrame")
weaponList.Size = UDim2.new(1,0,1,0)
weaponList.BackgroundTransparency = 1
weaponList.BorderSizePixel = 0
weaponList.ScrollBarThickness = 6
weaponList.ScrollBarImageColor3 = Color3.fromRGB(80,80,100)
weaponList.Parent = pages.Weapons
local weaponGrid = Instance.new("UIGridLayout")
weaponGrid.CellSize = UDim2.new(0,220,0,160)
weaponGrid.CellPadding = UDim2.new(0,12,0,12)
weaponGrid.Parent = weaponList

-- ══════ TAB: GACHA (Rolling RNG Anim + Rates Sidebar) ══════
local leftArea = Instance.new("Frame")
leftArea.Size = UDim2.new(0,330,1,0)
leftArea.BackgroundTransparency = 1
leftArea.Parent = pages.Gacha

local gachaInfo = Instance.new("TextLabel")
gachaInfo.Size = UDim2.new(1,0,0,70)
gachaInfo.Position = UDim2.new(0,0,0,10)
gachaInfo.BackgroundTransparency = 1
gachaInfo.TextColor3 = Color3.new(1,1,1)
gachaInfo.Font = Enum.Font.GothamBold
gachaInfo.TextSize = 18
gachaInfo.TextXAlignment = Enum.TextXAlignment.Center
gachaInfo.Parent = leftArea

local spin = Instance.new("TextButton")
spin.Size = UDim2.new(0,220,0,54)
spin.Position = UDim2.new(0.5,-110,0,90)
spin.Text = ""
spin.BackgroundColor3 = Color3.fromRGB(180,120,20)
spin.Parent = leftArea
Instance.new("UICorner",spin).CornerRadius = UDim.new(0,10)
local spinStroke = Instance.new("UIStroke",spin)
spinStroke.Color = Color3.fromRGB(255,200,50)
spinStroke.Thickness = 2
-- Spin button icon and label
local spinIcon = createIcon(spin, ICONS.RNG, UDim2.new(0, 28, 0, 28), UDim2.new(0.5, -80, 0.5, -14))
local spinLabel = Instance.new("TextLabel")
spinLabel.Size = UDim2.new(1, -40, 1, 0)
spinLabel.Position = UDim2.new(0, 40, 0, 0)
spinLabel.BackgroundTransparency = 1
spinLabel.Text = "SPIN GACHA"
spinLabel.TextColor3 = Color3.new(1,1,1)
spinLabel.Font = Enum.Font.GothamBold
spinLabel.TextSize = 18
spinLabel.Parent = spin

local result = Instance.new("TextLabel")
result.Size = UDim2.new(1,0,0,40)
result.Position = UDim2.new(0,0,0,290)
result.BackgroundTransparency = 1
result.TextColor3 = Color3.fromRGB(255,230,120)
result.Font = Enum.Font.GothamBold
result.TextSize = 14
result.Parent = leftArea

-- Rates Sidebar (Right Side)
local gachaRates = Instance.new("ScrollingFrame")
gachaRates.Size = UDim2.new(1,-345,1,-20)
gachaRates.Position = UDim2.new(0,345,0,10)
gachaRates.BackgroundTransparency = 1
gachaRates.BorderSizePixel = 0
gachaRates.ScrollBarThickness = 4
gachaRates.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
gachaRates.Parent = pages.Gacha

local ratesLayout = Instance.new("UIListLayout")
ratesLayout.Padding = UDim.new(0,10)
ratesLayout.Parent = gachaRates

local function addRarityGroup(titleText, rateText, color, spells)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-12,0,0) -- Dynamic height
	frame.BackgroundColor3 = Color3.fromRGB(28,30,36)
	frame.Parent = gachaRates
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,8)
	local stroke = Instance.new("UIStroke",frame)
	stroke.Color = color
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1,0,0,30)
	header.BackgroundColor3 = color
	header.BackgroundTransparency = 0.8
	header.Parent = frame
	Instance.new("UICorner",header).CornerRadius = UDim.new(0,8)
	
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1,-16,1,0)
	titleLbl.Position = UDim2.new(0,8,0,0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = titleText:upper()
	titleLbl.TextColor3 = Color3.new(1,1,1)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = header

	local rateLbl = Instance.new("TextLabel")
	rateLbl.Size = UDim2.new(1,-16,1,0)
	rateLbl.Position = UDim2.new(0,8,0,0)
	rateLbl.BackgroundTransparency = 1
	rateLbl.Text = rateText
	rateLbl.TextColor3 = Color3.new(1,1,1)
	rateLbl.Font = Enum.Font.GothamBold
	rateLbl.TextSize = 14
	rateLbl.TextXAlignment = Enum.TextXAlignment.Right
	rateLbl.Parent = header

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1,0,0,0)
	content.Position = UDim2.new(0,0,0,35)
	content.BackgroundTransparency = 1
	content.Parent = frame
	
	local contentPadding = Instance.new("UIPadding", content)
	contentPadding.PaddingLeft = UDim.new(0, 10)
	contentPadding.PaddingRight = UDim.new(0, 10)
	contentPadding.PaddingTop = UDim.new(0, 5)
	contentPadding.PaddingBottom = UDim.new(0, 10)

	local listLbl = Instance.new("TextLabel")
	listLbl.Size = UDim2.new(1,0,0,0)
	listLbl.AutomaticSize = Enum.AutomaticSize.Y
	listLbl.BackgroundTransparency = 1
	listLbl.Text = table.concat(spells, " • ")
	listLbl.TextColor3 = Color3.fromRGB(220,220,220)
	listLbl.Font = Enum.Font.GothamMedium
	listLbl.TextSize = 12
	listLbl.TextWrapped = true
	listLbl.TextYAlignment = Enum.TextYAlignment.Top
	listLbl.TextXAlignment = Enum.TextXAlignment.Left
	listLbl.Parent = content

	frame.AutomaticSize = Enum.AutomaticSize.Y
end

addRarityGroup("Common", "50%", Color3.fromRGB(160,160,160), {"Crimson Bolt", "Frost Fang", "Venom Strike", "Arcane Missile", "Spark Lance"})
addRarityGroup("Rare", "30%", Color3.fromRGB(50,150,255), {"Inferno Cascade", "Glacial Nova", "Plague Cloud", "Rift Pulse", "Thunder Dome"})
addRarityGroup("Epic", "15%", Color3.fromRGB(180,50,255), {"Phoenix Wrath", "Winter's Embrace", "Death Blossom", "Celestial Barrage", "Storm Judgement"})
addRarityGroup("Legendary", "5%", Color3.fromRGB(255,160,0), {"Apocalypse Flare", "Eternal Frost", "Void Annihilation"})
gachaRates.CanvasSize = UDim2.new(0,0,0,420)

-- ══════ TAB: STATS ══════
local statsInfo = Instance.new("TextLabel")
statsInfo.Size = UDim2.new(1,0,0,50)
statsInfo.Position = UDim2.new(0,0,0,4)
statsInfo.BackgroundTransparency = 1
statsInfo.TextXAlignment = Enum.TextXAlignment.Left
statsInfo.TextYAlignment = Enum.TextYAlignment.Top
statsInfo.TextColor3 = Color3.new(1,1,1)
statsInfo.Font = Enum.Font.GothamBold
statsInfo.TextSize = 16
statsInfo.Parent = pages.Stats

local statsList = Instance.new("Frame")
statsList.Size = UDim2.new(1,0,1,-60)
statsList.Position = UDim2.new(0,0,0,60)
statsList.BackgroundTransparency = 1
statsList.Parent = pages.Stats

local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0,8)
statsLayout.Parent = statsList

local function makeStatRow(name, desc, iconTexture)
	local row = Instance.new("Frame")
	row.Name = name
	row.Size = UDim2.new(1,0,0,55)
	row.BackgroundColor3 = Color3.fromRGB(28,30,40)
	row.Parent = statsList
	Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
	local stroke = Instance.new("UIStroke",row)
	stroke.Color = Color3.fromRGB(50,55,75)
	stroke.Thickness = 1

	local iconLbl = createIcon(row, iconTexture or ICONS.Question, UDim2.new(0, 32, 0, 32), UDim2.new(0, 10, 0.5, -16), Color3.fromRGB(100,200,255))

	local lblName = Instance.new("TextLabel")
	lblName.Size = UDim2.new(1,-200,1,0)
	lblName.Position = UDim2.new(0,50,0,0)
	lblName.BackgroundTransparency = 1
	lblName.Text = name .. "\n" .. desc
	lblName.TextColor3 = Color3.new(1,1,1)
	lblName.Font = Enum.Font.Gotham
	lblName.TextSize = 11
	lblName.TextXAlignment = Enum.TextXAlignment.Left
	lblName.TextYAlignment = Enum.TextYAlignment.Center
	lblName.Parent = row

	local val = Instance.new("TextLabel")
	val.Name = "Value"
	val.Size = UDim2.new(0,60,1,0)
	val.Position = UDim2.new(1,-175,0,0)
	val.BackgroundTransparency = 1
	val.Text = "0"
	val.TextColor3 = Color3.fromRGB(0,220,255)
	val.Font = Enum.Font.GothamBold
	val.TextSize = 18
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row

	local btn = Instance.new("TextButton")
	btn.Text = "+"
	btn.Size = UDim2.new(0,50,0,36)
	btn.Position = UDim2.new(1,-60,0.5,-18)
	btn.BackgroundColor3 = Color3.fromRGB(35,110,55)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.Parent = row
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
	btn.MouseButton1Click:Connect(function() AllocateStat:FireServer(name) end)
end

makeStatRow("Health", "+20 Max HP", ICONS.Health)
makeStatRow("Magic", "+4 Spell DMG, +10 Max Mana", ICONS.Power)
makeStatRow("Mana", "+15 Max Mana, +0.3 Regen", ICONS.Energy)
makeStatRow("Speed", "+1.5 Walk Speed", ICONS.Speed)
makeStatRow("Cooldown", "-3% Spell Cooldown", ICONS.Playtime)

-- ══════ ROLLING ANIMATION LOGIC ══════
local allSpells = {}
for name, sp in pairs(SpellsConfig.SPELLS) do
	if name ~= "Basic Shot" then
		table.insert(allSpells, name)
	end
end

local tierNames = {Basic = "Common", Advanced = "Rare", Rare = "Epic", Epic = "Legendary"}
local tierColors = {
	Basic = Color3.fromRGB(160,160,160),
	Advanced = Color3.fromRGB(50,150,255),
	Rare = Color3.fromRGB(180,50,255),
	Epic = Color3.fromRGB(255,160,0)
}
-- Element colors for visual reference (no emojis)
local elementColors = {
	Fire = Color3.fromRGB(255,100,20),
	Ice = Color3.fromRGB(100,200,255),
	Poison = Color3.fromRGB(80,200,40),
	Arcane = Color3.fromRGB(160,50,255),
	Lightning = Color3.fromRGB(255,255,80)
}

local function playSpinAnimation(rolledSpellName, isNew, fullMsg)
	spin.Active = false
	spin.AutoButtonColor = false
	spin.Text = "🎲 SPINNING..."
	spin.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	result.Text = ""

	local rollCard = leftArea:FindFirstChild("RollCard")
	if not rollCard then
		rollCard = Instance.new("Frame")
		rollCard.Name = "RollCard"
		rollCard.Size = UDim2.new(0, 250, 0, 110)
		rollCard.Position = UDim2.new(0.5, -125, 0, 160)
		rollCard.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
		rollCard.Parent = leftArea
		Instance.new("UICorner", rollCard).CornerRadius = UDim.new(0, 10)
		local rollStroke = Instance.new("UIStroke", rollCard)
		rollStroke.Name = "Stroke"
		rollStroke.Thickness = 3

		local lbl = Instance.new("TextLabel")
		lbl.Name = "Text"
		lbl.Size = UDim2.new(1, -20, 1, -20)
		lbl.Position = UDim2.new(0, 10, 0, 10)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 18
		lbl.TextWrapped = true
		lbl.Parent = rollCard

		local newTag = Instance.new("TextLabel")
		newTag.Name = "NewTag"
		newTag.Size = UDim2.new(0, 90, 0, 22)
		newTag.Position = UDim2.new(0.5, -45, 0, -11)
		newTag.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		newTag.TextColor3 = Color3.fromRGB(0,0,0)
		newTag.Text = "✨ NEW! ✨"
		newTag.Font = Enum.Font.GothamBold
		newTag.TextSize = 11
		newTag.Visible = false
		newTag.Parent = rollCard
		Instance.new("UICorner", newTag).CornerRadius = UDim.new(0, 6)
	end

	rollCard.Visible = true
	rollCard.NewTag.Visible = false
	rollCard.Stroke.Color = Color3.fromRGB(80, 80, 100)

	local textLabel = rollCard.Text
	local stroke = rollCard.Stroke

	local steps = 25
	local delayTime = 0.04

	for i = 1, steps do
		local dummySpell = allSpells[math.random(1, #allSpells)]
		local sp = SpellsConfig.GetSpell(dummySpell)
		local tier = sp and sp.Tier or "Basic"
		local tColor = tierColors[tier] or Color3.fromRGB(150,150,150)
		local tName = tierNames[tier] or "Common"
		local icon = sp and elementIcons[sp.Element] or "✨"

		textLabel.Text = icon .. " " .. dummySpell .. "\n" .. tName
		textLabel.TextColor3 = tColor
		stroke.Color = tColor

		rollCard.Size = UDim2.new(0, 256, 0, 114)
		rollCard.Position = UDim2.new(0.5, -128, 0, 158)
		TS:Create(rollCard, TweenInfo.new(delayTime, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 250, 0, 110),
			Position = UDim2.new(0.5, -125, 0, 160)
		}):Play()

		if i > 18 then
			delayTime += 0.06
		elseif i > 12 then
			delayTime += 0.03
		end

		task.wait(delayTime)
	end

	local sp = SpellsConfig.GetSpell(rolledSpellName)
	local tier = sp and sp.Tier or "Basic"
	local tColor = tierColors[tier] or Color3.fromRGB(150,150,150)
	local tName = tierNames[tier] or "Common"
	local icon = sp and elementIcons[sp.Element] or "✨"

	textLabel.Text = icon .. " " .. rolledSpellName .. "\n" .. tName
	textLabel.TextColor3 = tColor
	stroke.Color = tColor

	rollCard.Size = UDim2.new(0, 266, 0, 120)
	rollCard.Position = UDim2.new(0.5, -133, 0, 155)
	TS:Create(rollCard, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 250, 0, 110),
		Position = UDim2.new(0.5, -125, 0, 160)
	}):Play()

	if isNew then
		rollCard.NewTag.Visible = true
		rollCard.NewTag.BackgroundColor3 = tColor
		rollCard.NewTag.TextColor3 = (tier == "Epic" or tier == "Rare") and Color3.new(1,1,1) or Color3.new(0,0,0)
	end

	result.Text = fullMsg

	spin.Active = true
	spin.AutoButtonColor = true
	spin.Text = "🎰 SPIN GACHA 🎰"
	spin.BackgroundColor3 = Color3.fromRGB(180,120,20)
end

-- ══════ HELPER FUNCTIONS ══════
local function equipped(spell)
	-- Check SpellBar for spells (new system)
	if data and data.SpellBar then
		for i=1,4 do if data.SpellBar[i] == spell then return i end end
	end
	-- Check EquippedSpells for weapons (slot 4)
	if data and data.EquippedSpells and data.EquippedSpells[4] == spell then return 4 end
	-- Basic Shot is always "equipped" in slot 1 as fallback
	if spell == "Basic Shot" then return 1 end
end

local function createSpellCard(spellName, parent)
	local spell = SpellsConfig.GetSpell(spellName)
	local tier = spell and spell.Tier or "Basic"
	local tName = tierNames[tier] or "Common"
	local tColor = tierColors[tier] or Color3.fromRGB(150,150,150)
	local icon = spell and elementIcons[spell.Element] or "✨"
	local slot = equipped(spellName)

	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(25,27,38)
	card.Parent = parent
	Instance.new("UICorner",card).CornerRadius = UDim.new(0,8)
	local cardStroke = Instance.new("UIStroke",card)
	cardStroke.Color = tColor
	cardStroke.Thickness = 2

	-- Rarity badge
	local rarityBg = Instance.new("TextLabel")
	rarityBg.Size = UDim2.new(0,70,0,18)
	rarityBg.Position = UDim2.new(1,-76,0,6)
	rarityBg.BackgroundColor3 = Color3.fromRGB(20,22,30)
	rarityBg.TextColor3 = tColor
	rarityBg.Text = tName
	rarityBg.Font = Enum.Font.GothamBold
	rarityBg.TextSize = 9
	rarityBg.Parent = card
	Instance.new("UICorner",rarityBg).CornerRadius = UDim.new(0,4)

	-- Spell info
	local spellInfo = Instance.new("TextLabel")
	spellInfo.Size = UDim2.new(1,-12,0,55)
	spellInfo.Position = UDim2.new(0,8,0,8)
	spellInfo.BackgroundTransparency = 1
	spellInfo.Text = icon .. " " .. spellName .. "\n⚔️ DMG: " .. tostring(spell and spell.Damage or 0) .. " | ⏱️ CD: " .. tostring(spell and spell.Cooldown or 0)
	spellInfo.TextColor3 = Color3.new(1,1,1)
	spellInfo.Font = Enum.Font.GothamBold
	spellInfo.TextSize = 11
	spellInfo.TextWrapped = true
	spellInfo.TextXAlignment = Enum.TextXAlignment.Left
	spellInfo.TextYAlignment = Enum.TextYAlignment.Top
	spellInfo.Parent = card

	-- Element indicator
	if spell and spell.Element then
		local elemBadge = Instance.new("TextLabel")
		elemBadge.Size = UDim2.new(0,50,0,16)
		elemBadge.Position = UDim2.new(0,8,0,66)
		elemBadge.BackgroundColor3 = Color3.fromRGB(30,32,45)
		elemBadge.TextColor3 = tColor
		elemBadge.Text = elementIcons[spell.Element] .. " " .. spell.Element
		elemBadge.Font = Enum.Font.Gotham
		elemBadge.TextSize = 9
		elemBadge.Parent = card
		Instance.new("UICorner",elemBadge).CornerRadius = UDim.new(0,4)
	end

	-- Equip button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-16,0,32)
	btn.Position = UDim2.new(0,8,1,-40)
	btn.Text = slot and ("✅ Slot " .. slot) or "📖 EQUIP"
	btn.BackgroundColor3 = slot and Color3.fromRGB(35,100,60) or Color3.fromRGB(45,50,70)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = card
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
	btn.MouseButton1Click:Connect(function() Equip:FireServer(spellName) end)

	return card
end

local function createWeaponCard(weaponName, parent, displayName)
	local spell = SpellsConfig.GetSpell(weaponName)
	local slot = equipped(weaponName)
	local tier = SpellsConfig.GetWeaponTier and SpellsConfig.GetWeaponTier(weaponName) or "Common"

	-- Tier colors
	local tierColors = {
		Common = Color3.fromRGB(160,160,160),
		Rare = Color3.fromRGB(50,150,255),
		Epic = Color3.fromRGB(180,50,255),
		Legendary = Color3.fromRGB(255,160,0),
	}
	local tierColor = tierColors[tier] or Color3.fromRGB(160,160,160)

	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(25,27,50)
	card.Parent = parent
	Instance.new("UICorner",card).CornerRadius = UDim.new(0,10)
	local cardStroke = Instance.new("UIStroke",card)
	cardStroke.Color = tierColor
	cardStroke.Thickness = 3

	-- Weapon type badge
	local typeBg = Instance.new("TextLabel")
	typeBg.Size = UDim2.new(0,80,0,20)
	typeBg.Position = UDim2.new(1,-86,0,8)
	typeBg.BackgroundColor3 = Color3.fromRGB(20,60,120)
	typeBg.TextColor3 = tierColor
	typeBg.Text = tier .. " WEAPON"
	typeBg.Font = Enum.Font.GothamBold
	typeBg.TextSize = 10
	typeBg.Parent = card
	Instance.new("UICorner",typeBg).CornerRadius = UDim.new(0,5)

	-- Weapon icon/visual - change based on tier
	local weaponIcons = {
		Common = "🪵",
		Rare = "⚡",
		Epic = "🔮",
		Legendary = "👑"
	}
	local wpnIcon = Instance.new("TextLabel")
	wpnIcon.Size = UDim2.new(0,60,0,60)
	wpnIcon.Position = UDim2.new(0,15,0.5,-30)
	wpnIcon.BackgroundTransparency = 1
	wpnIcon.Text = weaponIcons[tier] or "🔱"
	wpnIcon.TextSize = 40
	wpnIcon.Font = Enum.Font.GothamBold
	wpnIcon.TextColor3 = tierColor
	wpnIcon.Parent = card

	-- Weapon info
	local elemText = spell and spell.Element or "Physical"
	local shownName = displayName or weaponName
	local wpnInfo = Instance.new("TextLabel")
	wpnInfo.Size = UDim2.new(1,-90,0,50)
	wpnInfo.Position = UDim2.new(0,85,0,15)
	wpnInfo.BackgroundTransparency = 1
	wpnInfo.Text = shownName .. "\n\n⚔️ DMG: " .. tostring(spell and spell.Damage or 20) .. "\n" .. elemText .. " Element"
	wpnInfo.TextColor3 = Color3.new(1,1,1)
	wpnInfo.Font = Enum.Font.GothamBold
	wpnInfo.TextSize = 12
	wpnInfo.TextWrapped = true
	wpnInfo.TextXAlignment = Enum.TextXAlignment.Left
	wpnInfo.TextYAlignment = Enum.TextYAlignment.Top
	wpnInfo.Parent = card

	-- Stats row
	local statsRow = Instance.new("Frame")
	statsRow.Size = UDim2.new(1,-20,0,30)
	statsRow.Position = UDim2.new(0,10,0,70)
	statsRow.BackgroundColor3 = Color3.fromRGB(20,25,45)
	statsRow.BackgroundTransparency = 0.5
	statsRow.Parent = card
	Instance.new("UICorner",statsRow).CornerRadius = UDim.new(0,6)

	local statsLayout = Instance.new("UIListLayout")
	statsLayout.FillDirection = Enum.FillDirection.Horizontal
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	statsLayout.Padding = UDim.new(0,8)
	statsLayout.Parent = statsRow

	local function makeMiniStat(icon, value, color)
		local mini = Instance.new("Frame")
		mini.Size = UDim2.new(0,65,0,20)
		mini.BackgroundTransparency = 1
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1,0,1,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = icon .. " " .. value
		lbl.TextColor3 = color
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 10
		lbl.Parent = mini
		return mini
	end

	makeMiniStat("⚔️", spell and spell.Damage or 20, Color3.fromRGB(255,100,100)).Parent = statsRow
	makeMiniStat(elemText, tier, tierColor).Parent = statsRow
	makeMiniStat("⏱️", spell and spell.Cooldown or 0.8 .. "s", Color3.fromRGB(200,200,200)).Parent = statsRow

	-- Equip button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-20,0,36)
	btn.Position = UDim2.new(0,10,1,-46)
	btn.Text = slot and "🔓 UNEQUIP" or "⚔️ EQUIP"
	btn.BackgroundColor3 = slot and Color3.fromRGB(120,35,35) or Color3.fromRGB(35,100,60)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = card
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
	btn.MouseButton1Click:Connect(function() Equip:FireServer(weaponName) end)

	-- Equipped indicator
	if slot == 4 then
		local equippedBadge = Instance.new("TextLabel")
		equippedBadge.Size = UDim2.new(0,90,0,20)
		equippedBadge.Position = UDim2.new(0.5,-45,0,-10)
		equippedBadge.BackgroundColor3 = Color3.fromRGB(35,150,60)
		equippedBadge.Text = "✅ EQUIPPED"
		equippedBadge.TextColor3 = Color3.new(1,1,1)
		equippedBadge.Font = Enum.Font.GothamBold
		equippedBadge.TextSize = 10
		equippedBadge.Parent = card
		Instance.new("UICorner",equippedBadge).CornerRadius = UDim.new(0,6)
	end

	return card
end

local function refresh()
	-- Clear spell list
	for _,c in ipairs(spellList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	-- Clear weapon list
	for _,c in ipairs(weaponList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

	-- Header updates
	local levelVal = levelBadge:FindFirstChild("Value")
	if levelVal then levelVal.Text = "Lv." .. tostring(data and data.Level or 1) end
	local goldVal = goldBadge:FindFirstChild("Value")
	if goldVal then goldVal.Text = tostring(data and data.Gold or 0) end
	local spinsVal = spinsBadge:FindFirstChild("Value")
	if spinsVal then spinsVal.Text = tostring(data and data.FreeSpins or 0) end

	-- Add weapon card if unlocked
	local weaponCount = 0
	if data and data.UnlockedWeapons and #data.UnlockedWeapons > 0 then
		for _, weaponName in ipairs(data.UnlockedWeapons) do
			-- Strip [rarity] suffix from display if present, but keep for equip logic
			local displayName = weaponName
			local cleanName = weaponName:gsub("%[.*%]", "")  -- e.g. "AstralWand[rare]" → "AstralWand"
			-- Re-check if clean name exists in UnlockedWeapons; if not, maybe the raw name IS the weapon id
			-- We pass the original weaponName so equip fires correctly; createWeaponCard shows the clean name
			createWeaponCard(weaponName, weaponList, displayName)
			weaponCount = weaponCount + 1
		end
	else
		-- Show empty state for weapons
		local emptyCard = Instance.new("Frame")
		emptyCard.Size = UDim2.new(0,220,0,160)
		emptyCard.BackgroundColor3 = Color3.fromRGB(30,32,45)
		emptyCard.Parent = weaponList
		Instance.new("UICorner",emptyCard).CornerRadius = UDim.new(0,10)
		local emptyLbl = Instance.new("TextLabel")
		emptyLbl.Size = UDim2.new(1,-20,1,-20)
		emptyLbl.Position = UDim2.new(0,10,0,10)
		emptyLbl.BackgroundTransparency = 1
		emptyLbl.Text = "⚔️ No Weapons\n\nComplete quests or reach\nhigher levels to unlock\nnew weapons!"
		emptyLbl.TextColor3 = Color3.fromRGB(150,150,150)
		emptyLbl.Font = Enum.Font.GothamBold
		emptyLbl.TextSize = 14
		emptyLbl.TextWrapped = true
		emptyLbl.TextYAlignment = Enum.TextYAlignment.Center
		emptyLbl.Parent = emptyCard
	end

	-- NOTE: Basic Shot is HIDDEN - it's the default weapon attack, not a spell
	-- DO NOT show Basic Shot in spell inventory

	-- Add unlocked spells (exclude Basic Shot)
	local spellCount = 0
	if data and data.UnlockedSpells then
		for _, spellName in ipairs(data.UnlockedSpells) do
			-- Skip Basic Shot - it's not a spell, it's the default weapon attack
			if spellName ~= "Basic Shot" then
				createSpellCard(spellName, spellList)
				spellCount = spellCount + 1
			end
		end
	end

	-- Show empty state if no spells
	if spellCount == 0 then
		local emptySpell = Instance.new("Frame")
		emptySpell.Size = UDim2.new(0,170,0,130)
		emptySpell.BackgroundColor3 = Color3.fromRGB(30,32,45)
		emptySpell.Parent = spellList
		Instance.new("UICorner",emptySpell).CornerRadius = UDim.new(0,10)
		local emptyLbl2 = Instance.new("TextLabel")
		emptyLbl2.Size = UDim2.new(1,-20,1,-20)
		emptyLbl2.Position = UDim2.new(0,10,0,10)
		emptyLbl2.BackgroundTransparency = 1
		emptyLbl2.Text = "✨ No Spells\n\nSpin Gacha to\nunlock new spells!"
		emptyLbl2.TextColor3 = Color3.fromRGB(150,150,150)
		emptyLbl2.Font = Enum.Font.GothamBold
		emptyLbl2.TextSize = 12
		emptyLbl2.TextWrapped = true
		emptyLbl2.TextYAlignment = Enum.TextYAlignment.Center
		emptyLbl2.Parent = emptySpell
		spellCount = 1
	end

	-- Canvas size
	local weaponCount = #(data and data.UnlockedWeapons or {})
	if #(data and data.UnlockedWeapons or {}) == 0 then weaponCount = 1 end

	spellList.CanvasSize = UDim2.new(0,0,0,math.ceil(math.max(spellCount,1)/4)*140)
	weaponList.CanvasSize = UDim2.new(0,0,0,math.ceil(math.max(weaponCount,1)/3)*172)

	-- Stats update
	gachaInfo.Text = string.format("🎰 Spins: %d\n💰 Gold: %d\n💎 Cost: 500 Gold",
		data and data.FreeSpins or 0, data and data.Gold or 0)

	local s = data and data.Stats or {}
	statsInfo.Text = string.format("⭐ Level %d  |  📊 XP: %d/%d\n💎 Stat Points: %d",
		data and data.Level or 1, data and data.XP or 0, data and data.XPToNext or 100, data and data.StatPoints or 0)

	for _, row in ipairs(statsList:GetChildren()) do
		if row:IsA("Frame") then
			local statName = row.Name
			local valLabel = row:FindFirstChild("Value")
			if valLabel then
				valLabel.Text = tostring(s[statName] or 0)
			end
		end
	end
end

-- Immediately request data and refresh on sync
data = GetData:InvokeServer()
refresh()

SyncData.OnClientEvent:Connect(function(d)
	data = d
	refresh()
end)

Gacha.OnClientEvent:Connect(function(success, isNew, spellName, msg)
	if success then
		playSpinAnimation(spellName, isNew, msg)
		refresh()
	else
		result.Text = msg or ""
	end
end)

spin.MouseButton1Click:Connect(function()
	if spin.Text == "🎰 SPIN GACHA 🎰" or spin.Text == "SPIN GACHA" or spin.Text == "" then
		Gacha:FireServer()
	end
end)

UIS.InputBegan:Connect(function(input,processed)
	if not processed and input.KeyCode==Enum.KeyCode.I then gui.Enabled=not gui.Enabled end
end)

-- Auto-refresh when character added
player.CharacterAdded:Connect(function()
	task.wait(1)
	if data then refresh() end
end)