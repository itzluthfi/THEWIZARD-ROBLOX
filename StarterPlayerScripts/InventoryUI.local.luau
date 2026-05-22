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
panel.Size = UDim2.new(0,740,0,500)
panel.Position = UDim2.new(0.5,-370,0.5,-250)
panel.BackgroundColor3 = Color3.fromRGB(22,24,30)
panel.ZIndex = 2
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)
local panelStroke = Instance.new("UIStroke",panel)
panelStroke.Color = Color3.fromRGB(60,65,85)
panelStroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,0,40)
title.Position = UDim2.new(0,16,0,8)
title.BackgroundTransparency = 1
title.Text = "Inventory"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = panel

local close = Instance.new("TextButton")
close.Text = "X"
close.Size = UDim2.new(0,34,0,34)
close.Position = UDim2.new(1,-44,0,8)
close.BackgroundColor3 = Color3.fromRGB(120,35,35)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Parent = panel
Instance.new("UICorner",close).CornerRadius = UDim.new(0,6)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

local pages, buttons = {}, {}
local function switchTab(name)
	for n, page in pairs(pages) do
		page.Visible = n == name
		buttons[n].BackgroundColor3 = n == name and Color3.fromRGB(60,70,100) or Color3.fromRGB(38,42,52)
	end
	title.Text = name
end

local tabIcons = {Spells="⚔",Gacha="★",Stats="▲"}
for i, name in ipairs({"Spells","Gacha","Stats"}) do
	local b = Instance.new("TextButton")
	b.Text = (tabIcons[name] or "").." "..name
	b.Size = UDim2.new(0,130,0,38)
	b.Position = UDim2.new(0,14+(i-1)*138,0,52)
	b.BackgroundColor3 = i==1 and Color3.fromRGB(60,70,100) or Color3.fromRGB(38,42,52)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.Parent = panel
	buttons[name] = b
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1,-28,1,-105)
	p.Position = UDim2.new(0,14,0,96)
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
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1,0,1,0)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.ScrollBarImageColor3 = Color3.fromRGB(80,80,100)
list.Parent = pages.Spells
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0,168,0,125)
grid.CellPadding = UDim2.new(0,12,0,12)
grid.Parent = list

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
spin.Text = "★ SPIN GACHA ★"
spin.BackgroundColor3 = Color3.fromRGB(200,140,20)
spin.TextColor3 = Color3.new(1,1,1)
spin.Font = Enum.Font.GothamBold
spin.TextSize = 20
spin.Parent = leftArea
Instance.new("UICorner",spin).CornerRadius = UDim.new(0,10)
local spinStroke = Instance.new("UIStroke",spin)
spinStroke.Color = Color3.fromRGB(255,200,50)
spinStroke.Thickness = 1.5

local result = Instance.new("TextLabel")
result.Size = UDim2.new(1,0,0,40)
result.Position = UDim2.new(0,0,0,290)
result.BackgroundTransparency = 1
result.TextColor3 = Color3.fromRGB(255,230,120)
result.Font = Enum.Font.GothamBold
result.TextSize = 15
result.Parent = leftArea

-- Rates Sidebar (Right Side)
local gachaRates = Instance.new("ScrollingFrame")
gachaRates.Size = UDim2.new(1,-345,1,0)
gachaRates.Position = UDim2.new(0,345,0,0)
gachaRates.BackgroundTransparency = 0.95
gachaRates.BackgroundColor3 = Color3.fromRGB(0,0,0)
gachaRates.BorderSizePixel = 0
gachaRates.ScrollBarThickness = 4
gachaRates.Parent = pages.Gacha

local ratesLayout = Instance.new("UIListLayout")
ratesLayout.Padding = UDim.new(0,8)
ratesLayout.Parent = gachaRates

local function addRarityGroup(titleText, rateText, color, spells)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-12,0,94)
	frame.BackgroundColor3 = Color3.fromRGB(28,30,36)
	frame.Parent = gachaRates
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,6)
	local stroke = Instance.new("UIStroke",frame)
	stroke.Color = color
	stroke.Thickness = 1

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1,-16,0,24)
	header.Position = UDim2.new(0,8,0,4)
	header.BackgroundTransparency = 1
	header.Text = titleText .. " (" .. rateText .. ")"
	header.TextColor3 = color
	header.Font = Enum.Font.GothamBold
	header.TextSize = 13
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = frame

	local listLbl = Instance.new("TextLabel")
	listLbl.Size = UDim2.new(1,-16,1,-34)
	listLbl.Position = UDim2.new(0,8,0,28)
	listLbl.BackgroundTransparency = 1
	listLbl.Text = table.concat(spells, ", ")
	listLbl.TextColor3 = Color3.fromRGB(200,200,200)
	listLbl.Font = Enum.Font.Gotham
	listLbl.TextSize = 11
	listLbl.TextWrapped = true
	listLbl.TextYAlignment = Enum.TextYAlignment.Top
	listLbl.TextXAlignment = Enum.TextXAlignment.Left
	listLbl.Parent = frame
end

addRarityGroup("⚪ Common", "50%", Color3.fromRGB(160,160,160), {"Crimson Bolt", "Frost Fang", "Venom Strike", "Arcane Missile", "Spark Lance"})
addRarityGroup("🔵 Rare", "30%", Color3.fromRGB(50,150,255), {"Inferno Cascade", "Glacial Nova", "Plague Cloud", "Rift Pulse", "Thunder Dome"})
addRarityGroup("🟣 Epic", "15%", Color3.fromRGB(180,50,255), {"Phoenix Wrath", "Winter's Embrace", "Death Blossom", "Celestial Barrage", "Storm Judgement"})
addRarityGroup("🟡 Legendary", "5%", Color3.fromRGB(255,160,0), {"Apocalypse Flare", "Eternal Frost", "Void Annihilation"})
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

local function makeStatRow(name, desc)
	local row = Instance.new("Frame")
	row.Name = name
	row.Size = UDim2.new(1,0,0,50)
	row.BackgroundColor3 = Color3.fromRGB(28,30,36)
	row.Parent = statsList
	Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)
	local stroke = Instance.new("UIStroke",row)
	stroke.Color = Color3.fromRGB(50,55,70)
	stroke.Thickness = 1

	local lblName = Instance.new("TextLabel")
	lblName.Size = UDim2.new(1,-250,1,0)
	lblName.Position = UDim2.new(0,12,0,0)
	lblName.BackgroundTransparency = 1
	lblName.Text = name .. " (" .. desc .. ")"
	lblName.TextColor3 = Color3.new(1,1,1)
	lblName.Font = Enum.Font.GothamBold
	lblName.TextSize = 13
	lblName.TextXAlignment = Enum.TextXAlignment.Left
	lblName.Parent = row

	local val = Instance.new("TextLabel")
	val.Name = "Value"
	val.Size = UDim2.new(0,80,1,0)
	val.Position = UDim2.new(1,-212,0,0)
	val.BackgroundTransparency = 1
	val.Text = "0"
	val.TextColor3 = Color3.fromRGB(0,220,255)
	val.Font = Enum.Font.GothamBold
	val.TextSize = 15
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row

	local btn = Instance.new("TextButton")
	btn.Text = "▲ Upgrade"
	btn.Size = UDim2.new(0,110,0,32)
	btn.Position = UDim2.new(1,-122,0.5,-16)
	btn.BackgroundColor3 = Color3.fromRGB(35,110,55)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = row
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
	btn.MouseButton1Click:Connect(function() AllocateStat:FireServer(name) end)
end

makeStatRow("Health", "Max HP +20")
makeStatRow("Magic", "Spell Damage +4, Max Mana +10")
makeStatRow("Mana", "Max Mana +15, Mana Regen +0.3")
makeStatRow("Speed", "WalkSpeed +1.5")
makeStatRow("Cooldown", "Spell Cooldown Reduction")

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
local elementIcons = {Fire = "🔥", Ice = "❄️", Poison = "☠️", Arcane = "🔮", Lightning = "⚡"}

local function playSpinAnimation(rolledSpellName, isNew, fullMsg)
	spin.Active = false
	spin.AutoButtonColor = false
	spin.Text = "SPINNING..."
	spin.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	result.Text = ""
	
	local rollCard = leftArea:FindFirstChild("RollCard")
	if not rollCard then
		rollCard = Instance.new("Frame")
		rollCard.Name = "RollCard"
		rollCard.Size = UDim2.new(0, 240, 0, 100)
		rollCard.Position = UDim2.new(0.5, -120, 0, 160)
		rollCard.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
		rollCard.Parent = leftArea
		Instance.new("UICorner", rollCard).CornerRadius = UDim.new(0, 8)
		local rollStroke = Instance.new("UIStroke", rollCard)
		rollStroke.Name = "Stroke"
		rollStroke.Thickness = 2
		
		local lbl = Instance.new("TextLabel")
		lbl.Name = "Text"
		lbl.Size = UDim2.new(1, -16, 1, -16)
		lbl.Position = UDim2.new(0, 8, 0, 8)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 16
		lbl.TextWrapped = true
		lbl.Parent = rollCard
		
		local newTag = Instance.new("TextLabel")
		newTag.Name = "NewTag"
		newTag.Size = UDim2.new(0, 80, 0, 20)
		newTag.Position = UDim2.new(0.5, -40, 0, -10)
		newTag.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		newTag.TextColor3 = Color3.fromRGB(0,0,0)
		newTag.Text = "✨ NEW! ✨"
		newTag.Font = Enum.Font.GothamBold
		newTag.TextSize = 10
		newTag.Visible = false
		newTag.Parent = rollCard
		Instance.new("UICorner", newTag).CornerRadius = UDim.new(0, 6)
	end
	
	rollCard.Visible = true
	rollCard.NewTag.Visible = false
	rollCard.Stroke.Color = Color3.fromRGB(80, 80, 100)
	
	local textLabel = rollCard.Text
	local stroke = rollCard.Stroke
	
	local steps = 22
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
		
		rollCard.Size = UDim2.new(0, 246, 0, 104)
		rollCard.Position = UDim2.new(0.5, -123, 0, 158)
		TS:Create(rollCard, TweenInfo.new(delayTime, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 240, 0, 100),
			Position = UDim2.new(0.5, -120, 0, 160)
		}):Play()
		
		if i > 16 then
			delayTime += 0.05
		elseif i > 10 then
			delayTime += 0.02
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
	
	rollCard.Size = UDim2.new(0, 256, 0, 110)
	rollCard.Position = UDim2.new(0.5, -128, 0, 155)
	TS:Create(rollCard, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 240, 0, 100),
		Position = UDim2.new(0.5, -120, 0, 160)
	}):Play()
	
	if isNew then
		rollCard.NewTag.Visible = true
		rollCard.NewTag.BackgroundColor3 = tColor
		rollCard.NewTag.TextColor3 = (tier == "Epic" or tier == "Rare") and Color3.new(1,1,1) or Color3.new(0,0,0)
	end
	
	result.Text = fullMsg
	
	spin.Active = true
	spin.AutoButtonColor = true
	spin.Text = "★ SPIN GACHA ★"
	spin.BackgroundColor3 = Color3.fromRGB(200,140,20)
end

-- ══════ REFRESH ══════
local function equipped(spell)
	-- Check slots 1-3
	for i=1,3 do if data and data.EquippedSpells and data.EquippedSpells[i]==spell then return i end end
	-- Check weapon slot (slot 4)
	if data and data.EquippedSpells and data.EquippedSpells[4]==spell then return 4 end
	-- "Basic Shot" is always equipped as default spell
	if spell == "Basic Shot" then return 1 end
end

local function refresh()
	for _,c in ipairs(list:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

	-- Handle "Basic Shot" as always available (auto-equipped default)
	local displaySpells = {}
	if data and data.UnlockedSpells then
		for _, spellName in ipairs(data.UnlockedSpells) do
			table.insert(displaySpells, spellName)
		end
	end

	-- Also add weapon to display if unlocked
	local weaponCard = nil
	if data and data.UnlockedWeapons and #data.UnlockedWeapons > 0 then
		local weaponName = data.UnlockedWeapons[1]
		local spell = SpellsConfig.GetSpell(weaponName)
		local slot = equipped(weaponName)

		weaponCard = Instance.new("Frame")
		weaponCard.BackgroundColor3 = Color3.fromRGB(28,30,36)
		weaponCard.Parent = list
		Instance.new("UICorner",weaponCard).CornerRadius = UDim.new(0,8)
		local cardStroke = Instance.new("UIStroke",weaponCard)
		cardStroke.Color = Color3.fromRGB(60,160,220)
		cardStroke.Thickness = 2

		local typeTag = Instance.new("TextLabel")
		typeTag.Size = UDim2.new(0,76,0,18)
		typeTag.Position = UDim2.new(1,-82,0,6)
		typeTag.BackgroundColor3 = Color3.fromRGB(20,60,100)
		typeTag.TextColor3 = Color3.fromRGB(100,200,255)
		typeTag.Text = "WEAPON"
		typeTag.Font = Enum.Font.GothamBold
		typeTag.TextSize = 10
		typeTag.Parent = weaponCard
		Instance.new("UICorner",typeTag).CornerRadius = UDim.new(0,4)

		local t = Instance.new("TextLabel")
		t.Size=UDim2.new(1,-8,0,60)
		t.Position=UDim2.new(0,6,0,6)
		t.BackgroundTransparency=1
		t.Text="🔱 "..weaponName.."\nDMG "..tostring(spell and spell.Damage or 35).." | Staff"
		t.TextColor3=Color3.new(1,1,1)
		t.Font=Enum.Font.GothamBold
		t.TextSize=13
		t.TextWrapped=true
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent=weaponCard

		local btn = Instance.new("TextButton")
		btn.Size=UDim2.new(1,-12,0,32)
		btn.Position=UDim2.new(0,6,1,-38)
		btn.Text=slot and "UNEQUIP" or "EQUIP"
		btn.BackgroundColor3=slot and Color3.fromRGB(130,35,35) or Color3.fromRGB(35,110,55)
		btn.TextColor3=Color3.new(1,1,1)
		btn.Font=Enum.Font.GothamBold
		btn.TextSize=13
		btn.Parent=weaponCard
		Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
		btn.MouseButton1Click:Connect(function() Equip:FireServer(weaponName) end)
	end

	-- Add "Basic Shot" card if not in unlocked spells
	if not table.find(displaySpells, "Basic Shot") then
		local spell = SpellsConfig.GetSpell("Basic Shot")
		local card = Instance.new("Frame")
		card.BackgroundColor3 = Color3.fromRGB(28,30,36)
		card.Parent = list
		Instance.new("UICorner",card).CornerRadius = UDim.new(0,8)
		local cardStroke = Instance.new("UIStroke",card)
		cardStroke.Color = Color3.fromRGB(150,150,150)
		cardStroke.Thickness = 1.5

		local typeTag = Instance.new("TextLabel")
		typeTag.Size = UDim2.new(0,76,0,18)
		typeTag.Position = UDim2.new(1,-82,0,6)
		typeTag.BackgroundColor3 = Color3.fromRGB(18,18,22)
		typeTag.TextColor3 = Color3.fromRGB(150,150,150)
		typeTag.Text = "DEFAULT"
		typeTag.Font = Enum.Font.GothamBold
		typeTag.TextSize = 10
		typeTag.Parent = card
		Instance.new("UICorner",typeTag).CornerRadius = UDim.new(0,4)

		local t = Instance.new("TextLabel")
		t.Size=UDim2.new(1,-8,0,60)
		t.Position=UDim2.new(0,6,0,6)
		t.BackgroundTransparency=1
		t.Text="✨ ".."Basic Shot".."\nDMG "..tostring(spell and spell.Damage or 8).." | Free Auto-Equip"
		t.TextColor3=Color3.new(1,1,1)
		t.Font=Enum.Font.GothamBold
		t.TextSize=13
		t.TextWrapped=true
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent=card

		local slot = equipped("Basic Shot")
		local btn = Instance.new("TextButton")
		btn.Size=UDim2.new(1,-12,0,32)
		btn.Position=UDim2.new(0,6,1,-38)
		btn.Text=slot and ("EQUIPPED ✓") or "EQUIP"
		btn.BackgroundColor3=slot and Color3.fromRGB(35,110,55) or Color3.fromRGB(60,60,60)
		btn.TextColor3=Color3.new(1,1,1)
		btn.Font=Enum.Font.GothamBold
		btn.TextSize=13
		btn.Parent=card
		Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
	end

	-- Show unlocked spells
	if #displaySpells == 0 and not weaponCard then
		local card = Instance.new("Frame")
		card.BackgroundColor3 = Color3.fromRGB(38,40,48)
		card.Parent = list
		Instance.new("UICorner",card).CornerRadius = UDim.new(0,8)
		local t = Instance.new("TextLabel")
		t.Size=UDim2.new(1,-10,1,-10)
		t.Position=UDim2.new(0,5,0,5)
		t.BackgroundTransparency=1
		t.TextWrapped=true
		t.Text="Belum ada spell.\nSilakan spin Gacha!"
		t.TextColor3=Color3.new(1,1,1)
		t.Font=Enum.Font.GothamBold
		t.TextSize=15
		t.Parent=card
	end
	for _,spellName in ipairs(displaySpells) do
		local spell = SpellsConfig.GetSpell(spellName)
		local tier = spell and spell.Tier or "Basic"
		local tName = tierNames[tier] or "Common"
		local tColor = tierColors[tier] or Color3.fromRGB(150,150,150)
		local icon = spell and elementIcons[spell.Element] or "✨"

		local card = Instance.new("Frame")
		card.BackgroundColor3 = Color3.fromRGB(28,30,36)
		card.Parent = list
		Instance.new("UICorner",card).CornerRadius = UDim.new(0,8)
		local cardStroke = Instance.new("UIStroke",card)
		cardStroke.Color = tColor
		cardStroke.Thickness = 1.5

		local rl = Instance.new("TextLabel")
		rl.Size = UDim2.new(0,76,0,18)
		rl.Position = UDim2.new(1,-82,0,6)
		rl.BackgroundColor3 = Color3.fromRGB(18,18,22)
		rl.TextColor3 = tColor
		rl.Text = tName
		rl.Font = Enum.Font.GothamBold
		rl.TextSize = 10
		rl.Parent = card
		Instance.new("UICorner",rl).CornerRadius = UDim.new(0,4)

		local t = Instance.new("TextLabel")
		t.Size=UDim2.new(1,-8,0,60)
		t.Position=UDim2.new(0,6,0,6)
		t.BackgroundTransparency=1
		t.Text=icon.." "..spellName.."\nDMG "..tostring(spell and spell.Damage or 0).." | CD "..tostring(spell and spell.Cooldown or 0)
		t.TextColor3=Color3.new(1,1,1)
		t.Font=Enum.Font.GothamBold
		t.TextSize=13
		t.TextWrapped=true
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent=card

		local slot = equipped(spellName)
		local btn = Instance.new("TextButton")
		btn.Size=UDim2.new(1,-12,0,32)
		btn.Position=UDim2.new(0,6,1,-38)
		btn.Text=slot and ("UNEQUIP "..slot) or "EQUIP"
		btn.BackgroundColor3=slot and Color3.fromRGB(130,35,35) or Color3.fromRGB(35,110,55)
		btn.TextColor3=Color3.new(1,1,1)
		btn.Font=Enum.Font.GothamBold
		btn.TextSize=13
		btn.Parent=card
		Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
		btn.MouseButton1Click:Connect(function() Equip:FireServer(spellName) end)
	end
	local itemCount = #displaySpells + ((weaponCard and 1) or 0) + 1  -- +1 for Basic Shot
	list.CanvasSize=UDim2.new(0,0,0,math.ceil(math.max(itemCount,1)/4)*135)

	gachaInfo.Text=string.format("Spins Tersisa: %d\nGold: %d\nBiaya spin: 500 Gold", data and data.FreeSpins or 0, data and data.Gold or 0)

	local s = data and data.Stats or {}
	statsInfo.Text=string.format("Level %d  |  XP %d/%d\nUnspent Stat Points: %d",
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
	else
		result.Text = msg or ""
	end
end)
spin.MouseButton1Click:Connect(function()
	if spin.Text == "★ SPIN GACHA ★" then
		Gacha:FireServer()
	end
end)
UIS.InputBegan:Connect(function(input,processed)
	if not processed and input.KeyCode==Enum.KeyCode.I then gui.Enabled=not gui.Enabled end
end)
GetData:InvokeServer()
