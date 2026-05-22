--[[ StaffSpawner – Gives AzureIceStaff to every joining player.
     Staff is cloned from ReplicatedStorage/Assets. ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local Assets            = ReplicatedStorage:WaitForChild("Assets")
local StaffTemplate     = Assets:FindFirstChild("AzureIceStaff")

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

local function giveStaff(plr)
	task.wait(2) -- wait for character
	local char = plr.Character
	if not char then char = plr.CharacterAdded:Wait() end
	local backpack = plr:FindFirstChild("Backpack") or plr:WaitForChild("Backpack", 5)
	if not backpack then return end

	if not StaffTemplate then
		warn("[StaffSpawner] AzureIceStaff not found in ReplicatedStorage.Assets – skipping staff give for " .. plr.Name)
		return -- Remote still created above, so no issue
	end

	-- Register weapon in player data (wait for DataManager load if needed)
	local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))
	local d = DataManager.Get(plr)
	if not d then
		task.wait(1)
		d = DataManager.Get(plr)
	end
	if d then
		d.UnlockedWeapons = d.UnlockedWeapons or {}
		local has = false
		for _, w in ipairs(d.UnlockedWeapons) do if w == "AzureIceStaff" then has = true break end end
		if not has then table.insert(d.UnlockedWeapons, "AzureIceStaff") end
	end

	local staff = StaffTemplate:Clone()
	staff.Parent = backpack
end

Players.PlayerAdded:Connect(giveStaff)
for _, plr in ipairs(Players:GetPlayers()) do
	task.spawn(giveStaff, plr)
end