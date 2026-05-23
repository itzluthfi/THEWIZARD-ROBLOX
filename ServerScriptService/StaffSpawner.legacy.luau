--[[ StaffSpawner – Gives weapons to every joining player.
     Staff is cloned from ReplicatedStorage/Assets/Weapons.
     Weapon is auto-equipped in slot 4 (weapon slot).
     Supports multiple weapons from Assets/Weapons folder. ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Pre-create Staff remotes ONCE (idempotent) - MUST be done before ANY early returns
local function ensureRemote(name)
	if not Remotes:FindFirstChild(name) then
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = Remotes
	end
end
ensureRemote("StaffFireProjectile")
ensureRemote("LockTarget")

-- Weapon rarity map — determines name tier and gacha availability
local WEAPON_RARITY = {
	KorbloxStaff  = "Epic",
	StaffOfSparks = "Rare",
	AstralWand    = "Rare",   -- custom Rare wand
	Stick         = "Common",
	MasterStaff   = "Epic",
	StaffOmega    = "Legendary",
	AzureIceStaff = "Common",
}

-- Weapon display names (slot tooltip)
local WEAPON_DISPLAY = {
	KorbloxStaff  = "Korblox Destroyer Staff",
	StaffOfSparks = "Spark Mage Staff",
	AstralWand    = "Astral Wand",
	Stick         = "Wooden Training Stick",
	MasterStaff   = "Master Arcane Staff",
	StaffOmega    = "Omega Void Staff",
	AzureIceStaff = "Azure Ice Staff",
}

-- Weapon list - order by priority (BEST weapon first — high tier priority for spawn)
-- Weapons NOT in this list will NOT be given by default
local WEAPON_DEFAULTS = {
	{Name = "KorbloxStaff",    Priority = 1, Rarity = "Epic"},
	{Name = "StaffOfSparks",   Priority = 2, Rarity = "Rare"},
	{Name = "AstralWand",      Priority = 3, Rarity = "Rare"}, -- NEW Rare wand
	{Name = "Stick",           Priority = 4, Rarity = "Common"},
	{Name = "MasterStaff",     Priority = 5, Rarity = "Epic"},
	{Name = "StaffOmega",      Priority = 6, Rarity = "Legendary"},
	{Name = "AzureIceStaff",   Priority = 7, Rarity = "Common"},
}

-- Find first available weapon template
local function findWeaponTemplate()
	local Assets = ReplicatedStorage:FindFirstChild("Assets")
	if not Assets then return nil, nil end

	local Weapons = Assets:FindFirstChild("Weapons")
	if not Weapons then return nil, nil end

	-- Try each weapon in priority order
	for _, weaponInfo in ipairs(WEAPON_DEFAULTS) do
		local template = nil
		local weaponName = weaponInfo.Name

		-- Try suffixed name first (e.g. "AstralWand[rare]", "KorbloxStaff[epic]")
		local suffix = WEAPON_RARITY[weaponInfo.Name]
		if suffix then
			local suffixedName = weaponInfo.Name .. "[" .. suffix:lower() .. "]"
			-- SAFETY: Only accept Tool-class instances so broken / model-based entries are skipped
			local suffixedObj = Weapons:FindFirstChild(suffixedName)
			if suffixedObj and suffixedObj:IsA("Tool") then
				template = suffixedObj
				weaponName = suffixedName
			end
		end

		-- Fall back to bare name (only if it's a Tool)
		if not template then
			local bareObj = Weapons:FindFirstChild(weaponName)
			if bareObj and bareObj:IsA("Tool") then
				template = bareObj
			end
		end

		-- Fall back to suffixed name that might have been set above without matching suffix
		if not template and suffix then
			local suffixedName = weaponInfo.Name .. "[" .. suffix:lower() .. "]"
			local suffixedObj = Weapons:FindFirstChild(suffixedName)
			if suffixedObj and suffixedObj:IsA("Tool") then
				template = suffixedObj
				weaponName = suffixedName
			end
		end

		if template then
			print("[StaffSpawner] Found weapon: " .. weaponName)
			return template, weaponName
		end
	end

	return nil, nil
end

local function giveWeapon(plr)
	task.wait(2) -- wait for character
	local char = plr.Character
	if not char then char = plr.CharacterAdded:Wait() end

	-- ALWAYS register ALL weapons in player's data (register ALL, not just ones with templates)
	local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))
	local d = DataManager.Get(plr)
	if not d then
		task.wait(1)
		d = DataManager.Get(plr)
	end

	local bestWeapon = nil

	if d then
		-- Register ALL weapons from the list (not just ones with templates)
		d.UnlockedWeapons = d.UnlockedWeapons or {}

		for _, weaponInfo in ipairs(WEAPON_DEFAULTS) do
			local has = false
			for _, w in ipairs(d.UnlockedWeapons) do
				if w == weaponInfo.Name then has = true break end
			end
			if not has then
				table.insert(d.UnlockedWeapons, weaponInfo.Name)
				print("[StaffSpawner] Registered weapon: " .. weaponInfo.Name)
				-- First weapon in list becomes the best/active one
				if not bestWeapon then
					bestWeapon = weaponInfo.Name
				end
			end
		end

		-- Set EquippedSpells[4] to the best weapon (KorbloxStaff by default)
		d.EquippedSpells = d.EquippedSpells or {}
		if bestWeapon then
			d.EquippedSpells[4] = bestWeapon
			print("[StaffSpawner] Active weapon set to: " .. bestWeapon)
		end

		-- Sync to client immediately
		DataManager.Sync(plr)
	end

	-- Try to give visual weapon model if template exists
	local Assets = ReplicatedStorage:FindFirstChild("Assets")
	local Weapons = Assets and Assets:FindFirstChild("Weapons")

	if Weapons then
		local WeaponTemplate, weaponName = findWeaponTemplate()
		if WeaponTemplate then
			local backpack = plr:FindFirstChild("Backpack")
			if backpack then
				local weapon = WeaponTemplate:Clone()
				weapon.Parent = backpack
				-- Auto-equip the tool in character
				local char = plr.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						hum:EquipTool(weapon)
					end
				end
				print("[StaffSpawner] Equipped " .. weaponName .. " to " .. plr.Name)
			end
		end
	end
end

Players.PlayerAdded:Connect(giveWeapon)
for _, plr in ipairs(Players:GetPlayers()) do
	task.spawn(giveWeapon, plr)
end