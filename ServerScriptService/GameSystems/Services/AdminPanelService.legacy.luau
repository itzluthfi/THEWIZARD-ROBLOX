--[[ AdminPanel Service - Admin commands for testing and management
     Add commands via RemoteEvent or chat
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))

local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Create admin remote
local AdminRemote = Instance.new("RemoteEvent")
AdminRemote.Name = "AdminCommand"
AdminRemote.Parent = Remotes

-- Admin panel for local player (can be toggled with /admin or Ctrl+Shift+A)
local ADMIN_PREFIX = "/admin"

-- List of admin user IDs
local ADMIN_IDS = {
	-- Add your user ID here:
	5118120773,  -- Your Roblox ID
}

-- Check if player is admin
local function isAdmin(player)
	-- Allow all if no IDs specified (for testing)
	if #ADMIN_IDS == 0 then return true end
	for _, id in ipairs(ADMIN_IDS) do
		if player.UserId == id then return true end
	end
	return false
end

-- Admin commands
local commands = {
	["addgold"] = function(player, args)
		local amount = tonumber(args[1]) or 1000
		local data = DataManager.Get(player)
		if data then
			data.Gold = (data.Gold or 0) + amount
			DataManager.Sync(player)
			return true, "Added " .. amount .. " gold!"
		end
		return false, "Data not found"
	end,

	["addxp"] = function(player, args)
		local amount = tonumber(args[1]) or 100
		local data = DataManager.Get(player)
		if data then
			DataManager.AddXP(player, amount)
			return true, "Added " .. amount .. " XP!"
		end
		return false, "Data not found"
	end,

	["addspin"] = function(player, args)
		local amount = tonumber(args[1]) or 5
		local data = DataManager.Get(player)
		if data then
			data.FreeSpins = (data.FreeSpins or 0) + amount
			DataManager.Sync(player)
			return true, "Added " .. amount .. " free spins!"
		end
		return false, "Data not found"
	end,

	["setlevel"] = function(player, args)
		local level = tonumber(args[1]) or 1
		local data = DataManager.Get(player)
		if data then
			data.Level = math.max(1, level)
			data.XP = 0
			data.XPToNext = math.floor(100 * (level ^ 1.35))
			DataManager.Sync(player)
			return true, "Set level to " .. level
		end
		return false, "Data not found"
	end,

	["unlockall"] = function(player, args)
		local data = DataManager.Get(player)
		if not data then return false, "Data not found" end

		-- Unlock all spells
		local SpellsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SpellsConfig"))
		for spellName, spell in pairs(SpellsConfig.SPELLS) do
			if spellName ~= "Basic Shot" then
				local has = false
				for _, s in ipairs(data.UnlockedSpells or {}) do
					if s == spellName then has = true break end
				end
				if not has then
					table.insert(data.UnlockedSpells, spellName)
				end
			end
		end

		-- Unlock all weapons
		local weapons = {"Stick", "StaffOfSparks", "MasterStaff", "StaffOmega", "KorbloxStaff"}
		for _, wpn in ipairs(weapons) do
			local has = false
			for _, w in ipairs(data.UnlockedWeapons or {}) do
				if w == wpn then has = true break end
			end
			if not has then
				table.insert(data.UnlockedWeapons, wpn)
			end
		end

		DataManager.Sync(player)
		return true, "Unlocked all spells and weapons!"
	end,

	["heal"] = function(player, args)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = hum.MaxHealth
			local data = DataManager.Get(player)
			if data then
				data.Mana = data.MaxMana
				DataManager.Sync(player)
			end
			return true, "Fully healed!"
		end
		return false, "Character not found"
	end,

	["setstat"] = function(player, args)
		local stat = args[1] or "Health"
		local amount = tonumber(args[2]) or 10
		local data = DataManager.Get(player)
		if data then
			data.Stats = data.Stats or {}
			data.Stats[stat] = amount
			DataManager.ApplyCharacterStats(player)
			DataManager.Sync(player)
			return true, "Set " .. stat .. " to " .. amount
		end
		return false, "Data not found"
	end,

	["spawnmob"] = function(player, args)
		local mobName = args[1] or "TestSlime"
		local count = tonumber(args[2]) or 1

		-- Simple mob spawner
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return false, "Character not found" end

		for i = 1, math.min(count, 10) do
			task.spawn(function()
				local mob = Instance.new("Model")
				mob.Name = mobName
				mob:SetAttribute("IsMonster", true)

				local hrp = Instance.new("Part")
				hrp.Name = "HumanoidRootPart"
				hrp.Size = Vector3.new(2, 2, 1)
				hrp.Position = root.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
				hrp.Anchored = false
				hrp.Parent = mob

				local hum = Instance.new("Humanoid")
				hum.MaxHealth = 100
				hum.Health = 100
				hum.Parent = mob

				local body = Instance.new("Part")
				body.Name = "Body"
				body.Size = Vector3.new(2, 3, 2)
				body.Position = hrp.Position + Vector3.new(0, 2, 0)
				body.Parent = mob

				mob.Parent = workspace
			end)
		end

		return true, "Spawned " .. count .. " " .. mobName
	end,

	["help"] = function(player)
		return true, [[Admin Commands:
/admin addgold [amount]
/admin addxp [amount]
/admin addspin [amount]
/admin setlevel [level]
/admin unlockall
/admin heal
/admin setstat [stat] [amount]
/admin spawnmob [name] [count]
/admin help]]
	end,
}

-- Handle admin commands from client
AdminRemote.OnServerEvent:Connect(function(player, command, args)
	if not isAdmin(player) then
		AdminRemote:FireClient(player, false, "Not authorized!")
		return
	end

	command = command:lower()
	local cmd = commands[command]
	if cmd then
		local success, message = cmd(player, args or {})
		AdminRemote:FireClient(player, success, message)
	else
		AdminRemote:FireClient(player, false, "Unknown command: " .. command)
	end
end)

-- Handle chat commands
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message:sub(1, #ADMIN_PREFIX) == ADMIN_PREFIX then
			local args = {}
			for arg in message:gmatch("%S+") do
				table.insert(args, arg)
			end

			if #args < 2 then
				if isAdmin(player) then
					commands["help"](player)
				end
				return
			end

			local command = args[2]:lower()
			table.remove(args, 1)
			table.remove(args, 1)

			if isAdmin(player) then
				local cmd = commands[command]
				if cmd then
					local success, result = cmd(player, args)
					print("[Admin] " .. player.Name .. ": /" .. command .. " -> " .. tostring(result))
				end
			end
		end
	end)
end)

print("[AdminPanel] Admin service loaded! " .. #ADMIN_IDS .. " admin(s) configured.")