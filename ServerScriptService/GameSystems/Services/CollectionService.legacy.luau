local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))
local SpellsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SpellsConfig"))
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Create a BindableEvent in Remotes for client-to-client communication
local function ensureBindable(name)
	local existing = Remotes:FindFirstChild(name)
	if existing and existing:IsA("BindableEvent") then return existing end
	if existing then existing:Destroy() end
	local be = Instance.new("BindableEvent")
	be.Name = name
	be.Parent = Remotes
	return be
end

local function remote(name)
	local r = Remotes:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = Remotes
	end
	return r
end

local Gacha = remote("GachaSpell")
local Equip = remote("EquipSpell")
local AllocateStat = remote("AllocateStat")
remote("SlotCooldown")
remote("CastSpell") -- Legacy: now using BindableEvent instead

-- BindableEvent for client-to-client communication (spell slot clicks)
local CastSpellBindable = ensureBindable("CastSpellBindable")

local pools = { Basic = {}, Advanced = {}, Rare = {}, Epic = {} }
for name, spell in pairs(SpellsConfig.SPELLS) do
	if name ~= "Basic Shot" then
		local tier = spell.Tier or "Basic"
		if pools[tier] then table.insert(pools[tier], name) end
	end
end

local function ownsAny(data, itemName)
	for _, s in ipairs(data.UnlockedSpells or {}) do if s == itemName then return true end end
	for _, w in ipairs(data.UnlockedWeapons or {}) do if w == itemName then return true end end
	return false
end

Gacha.OnServerEvent:Connect(function(player)
	local data = DataManager.Get(player)
	if not data then return end
	if (data.FreeSpins or 0) > 0 then
		data.FreeSpins -= 1
	elseif data.Gold >= 500 then
		data.Gold -= 500
	else
		Gacha:FireClient(player, false, false, "", "Gold kurang. Butuh 500 Gold.")
		DataManager.Sync(player)
		return
	end

	-- Weighted Roll
	local roll = math.random(1, 100)
	local chosenTier = "Basic"
	if roll <= 50 then chosenTier = "Basic"
	elseif roll <= 80 then chosenTier = "Advanced"
	elseif roll <= 95 then chosenTier = "Rare"
	else chosenTier = "Epic" end

	local tierPool = pools[chosenTier]
	if not tierPool or #tierPool == 0 then tierPool = pools["Basic"] end
	local spellName = tierPool[math.random(1, #tierPool)]

	if owns(data, spellName) then
		data.Gold += 100
		Gacha:FireClient(player, true, false, spellName, "Duplikat: " .. spellName .. ". Refund 100 Gold.")
	else
		table.insert(data.UnlockedSpells, spellName)
		table.insert(data.Inventory, {Type = "Spell", Name = spellName})
		Gacha:FireClient(player, true, true, spellName, "Spell baru: " .. spellName)
	end
	DataManager.Sync(player)
end)

Equip.OnServerEvent:Connect(function(player, spellName)
	if not spellName or type(spellName) ~= "string" then return end
	local data = DataManager.Get(player)
	if not data then return end
	local isWeapon = spellName:sub(1,4) == "Wpn:"
	local itemName = isWeapon and spellName:sub(5) or spellName
	if not ownsAny(data, spellName) then return end

	local equipped = data.EquippedSpells or {}

	if isWeapon then
		-- Weapon toggle: slot 4
		if equipped[4] == spellName then
			equipped[4] = nil -- unequip
		else
			-- Store without "Wpn:" prefix so inventory lookup stays consistent
			equipped[4] = itemName
		end
	else
		-- Spell: slots 1-3
		local existing
		for i = 1, 3 do if equipped[i] == spellName then existing = i break end end
		if existing then
			equipped[existing] = nil
		else
			local placed = false
			for i = 1, 3 do
				if not equipped[i] or equipped[i] == "" then equipped[i] = spellName placed = true break end
			end
			if not placed then equipped[1] = spellName end
		end
	end

	data.EquippedSpells = equipped
	DataManager.Sync(player)
end)

AllocateStat.OnServerEvent:Connect(function(player, stat)
	local valid = {Health = true, Magic = true, Mana = true, Speed = true, Cooldown = true}
	local data = DataManager.Get(player)
	if not valid[stat] or not data or (data.StatPoints or 0) <= 0 then return end
	data.StatPoints -= 1
	data.Stats[stat] = (data.Stats[stat] or 0) + 1
	data.MaxMana = 100 + ((data.Stats.Magic or 0) * 10) + ((data.Stats.Mana or 0) * 15)
	data.Mana = math.min(data.Mana, data.MaxMana)
	DataManager.ApplyCharacterStats(player)
	DataManager.Sync(player)
end)
