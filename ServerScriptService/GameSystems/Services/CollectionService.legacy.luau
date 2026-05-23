local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
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
remote("CastSpell")

-- BindableEvent for client-to-client communication
local CastSpellBindable = ensureBindable("CastSpellBindable")

-- Admin panel for local player
local AdminRemote = remote("AdminCommand")
local MY_USER_ID = 5118120773  -- Your Roblox ID for admin hint

-- Remote for damage counter
local DamageCounterRemote = remote("DamageCounter")

-- Send damage counter to player
local function sendDamageToPlayer(player, totalDamage)
	DamageCounterRemote:FireClient(player, totalDamage)
end

-- Track damage dealt by each player
local playerDamageTracker = {}

local function trackDamage(player, amount)
	playerDamageTracker[player] = (playerDamageTracker[player] or 0) + amount
	sendDamageToPlayer(player, playerDamageTracker[player])
end

-- Reset damage on new session
Players.PlayerAdded:Connect(function(p)
	playerDamageTracker[p] = 0
end)
Players.PlayerRemoving:Connect(function(p)
	playerDamageTracker[p] = nil
end)

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
	if not data then
		warn("[Gacha] No player data for " .. player.Name)
		return
	end

	-- Safety check: prevent spam
	if not data.FreeSpins then data.FreeSpins = 0 end
	if not data.Gold then data.Gold = 0 end
	if not data.UnlockedSpells then data.UnlockedSpells = {} end

	-- Check if player can spin
	local canSpin = false
	local spinCost = 500

	if (data.FreeSpins or 0) > 0 then
		canSpin = true
		data.FreeSpins -= 1
	elseif data.Gold >= spinCost then
		canSpin = true
		data.Gold -= spinCost
	else
		Gacha:FireClient(player, false, false, "", "Gold kurang. Butuh " .. spinCost .. " Gold.")
		return
	end

	-- Build tier pools (exclude Basic Shot which is not a gacha spell)
	local tierPools = {Basic = {}, Advanced = {}, Rare = {}, Epic = {}}
	for spellName, spell in pairs(SpellsConfig.SPELLS) do
		if spellName ~= "Basic Shot" then
			local tier = spell.Tier or "Basic"
			if tierPools[tier] then
				table.insert(tierPools[tier], spellName)
			end
		end
	end

	-- Weighted Roll
	local roll = math.random(1, 100)
	local chosenTier = "Basic"
	if roll <= 50 then chosenTier = "Basic"
	elseif roll <= 80 then chosenTier = "Advanced"
	elseif roll <= 95 then chosenTier = "Rare"
	else chosenTier = "Epic" end

	-- Get pool for chosen tier
	local pool = tierPools[chosenTier]
	if not pool or #pool == 0 then
		-- Fallback to basic if pool is empty
		pool = tierPools["Basic"]
	end

	if not pool or #pool == 0 then
		warn("[Gacha] No spells available to roll!")
		-- Refund the spin
		data.Gold = (data.Gold or 0) + spinCost
		Gacha:FireClient(player, false, false, "", "Error: No spells available!")
		return
	end

	-- Random spell from pool
	local spellName = pool[math.random(1, #pool)]

	-- Validate spell name
	if not spellName or type(spellName) ~= "string" or spellName == "" then
		warn("[Gacha] Invalid spell name!")
		return
	end

	-- Check if player already owns this spell
	local alreadyHas = false
	for _, s in ipairs(data.UnlockedSpells) do
		if s == spellName then alreadyHas = true break end
	end

	if alreadyHas then
		-- Dupe refund
		local refundAmount = 100
		data.Gold = (data.Gold or 0) + refundAmount
		Gacha:FireClient(player, true, false, spellName, "Duplikat! Refund " .. refundAmount .. " Gold.")
	else
		-- New spell!
		table.insert(data.UnlockedSpells, spellName)
		Gacha:FireClient(player, true, true, spellName, "✨ Spell baru: " .. spellName)
	end

	DataManager.Sync(player)
	print("[Gacha] " .. player.Name .. " rolled " .. chosenTier .. " spell: " .. spellName)
end)

Equip.OnServerEvent:Connect(function(player, itemName)
	if not itemName or type(itemName) ~= "string" then return end
	local data = DataManager.Get(player)
	if not data then return end

	-- List of known weapons - always allow these to be equipped
	local KNOWN_WEAPONS = {
		["Stick"] = true,
		["StaffOfSparks"] = true,
		["AstralWand"] = true,      -- NEW Rare wand
		["MasterStaff"] = true,
		["StaffOmega"] = true,
		["KorbloxStaff"] = true,
		["AzureIceStaff"] = true,
	}

	-- Check if item is weapon or spell
	local isWeapon = KNOWN_WEAPONS[itemName] or false
	local isSpell = false

	-- Check if in UnlockedWeapons
	for _, w in ipairs(data.UnlockedWeapons or {}) do
		if w == itemName then isWeapon = true break end
	end

	-- Check if in UnlockedSpells
	for _, s in ipairs(data.UnlockedSpells or {}) do
		if s == itemName then isSpell = true break end
	end

	-- If weapon not in UnlockedWeapons yet, add it automatically
	if isWeapon and not table.find(data.UnlockedWeapons or {}, itemName) then
		data.UnlockedWeapons = data.UnlockedWeapons or {}
		table.insert(data.UnlockedWeapons, itemName)
		print("[CollectionService] Added weapon to inventory: " .. itemName)
	end

	-- DEBUG
	print("[CollectionService] " .. player.Name .. " equip: " .. itemName .. " isWeapon=" .. tostring(isWeapon) .. " isSpell=" .. tostring(isSpell))

	if isWeapon then
		-- WEAPON: Equip/unequip in slot 4
		local equipped = data.EquippedSpells or {}
		if equipped[4] == itemName then
			equipped[4] = nil
			print("[CollectionService] Unequipped weapon: " .. itemName)
		else
			equipped[4] = itemName
			print("[CollectionService] Equipped weapon: " .. itemName)
		end
		data.EquippedSpells = equipped
		DataManager.Sync(player)
		return
	end

	if isSpell then
		-- SPELL: Equip in spell bar (slots Z,X,C,V)
		local spellBar = data.SpellBar or {}
		-- Find if spell already in bar
		local found = nil
		for i = 1, 4 do
			if spellBar[i] == itemName then found = i break end
		end
		if found then
			spellBar[found] = nil
			print("[CollectionService] Unequipped spell: " .. itemName)
		else
			-- Find empty slot (prioritize Z,X,C,V)
			local placed = false
			for i = 1, 4 do
				if not spellBar[i] or spellBar[i] == "" then
					spellBar[i] = itemName
					print("[CollectionService] Equipped spell " .. itemName .. " in slot " .. i)
					placed = true
					break
				end
			end
			if not placed then
				spellBar[4] = itemName  -- replace slot V if all full
				print("[CollectionService] Spell bar full, replaced slot V with " .. itemName)
			end
		end
		data.SpellBar = spellBar
		DataManager.Sync(player)
		return
	end

	-- Item not owned
	print("[CollectionService] Cannot equip: " .. itemName .. " - not owned")
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
