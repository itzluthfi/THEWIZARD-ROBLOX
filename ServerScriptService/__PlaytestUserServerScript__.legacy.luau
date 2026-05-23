
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

-- Check all weapons are Tools
print("[TEST] Checking weapon types:")
local weapons = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Weapons")
if weapons then
	for _, w in weapons:GetChildren() do
		print("  " .. w.Name .. " is " .. w.ClassName)
	end
end

-- Monitor StaffSpawner-style weapon giving
Players.PlayerAdded:Connect(function(plr)
	print("[TEST] Player " .. plr.Name .. " joined")
end)
print("[TEST] Current players:")
for _, p in Players:GetPlayers() do print("  " .. p.Name) end
