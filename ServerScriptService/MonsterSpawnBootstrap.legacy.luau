local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local IslandsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("IslandsConfig"))
local MobService = require(ServerScriptService:WaitForChild("GameSystems"):WaitForChild("Services"):WaitForChild("MobService"))

local function islandFolder(id)
	return workspace:FindFirstChild(id) or (workspace:FindFirstChild("Islands") and workspace.Islands:FindFirstChild(id))
end

local function monsterFolder(id)
	local island = islandFolder(id)
	if not island then return nil end
	local folder = island:FindFirstChild("Monsters")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Monsters"
		folder.Parent = island
	end
	return folder
end

local function spawnAll()
	local total = 0
	for islandId, island in pairs(IslandsConfig.GetAllIslands()) do
		local folder = monsterFolder(islandId)
		if folder then
			for _, child in ipairs(folder:GetChildren()) do
				if child:GetAttribute("IsMonster") then child:Destroy() end
			end
			local islandF = islandFolder(islandId)
			local base = islandF and islandF:FindFirstChild("Base")
			local surfaceY = 6
			if base and base:IsA("BasePart") then
				surfaceY = base.Position.Y + base.Size.Y / 2
			end
			local cx = island.Position and island.Position.X or 0
			local cz = island.Position and island.Position.Z or 0

			-- Dynamic height checker to place monsters correctly on top of obstacles/terrain
			local function getSpawnY(spawnPos)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = {workspace}
				local result = workspace:Raycast(spawnPos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), raycastParams)
				if result then
					return result.Position.Y
				end
				return surfaceY
			end

			-- Spawn and hook up respawn tracking automatically
			local function trackMonster(monsterName, spawnPos)
				local model = MobService.SpawnMonster(monsterName, spawnPos, folder)
				if model then
					local hum = model:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.Died:Connect(function()
							task.delay(10, function()
								-- Respawn at the same coordinate after 10s cooldown
								trackMonster(monsterName, spawnPos)
							end)
						end)
					end
				else
					-- Retry spawn if loading failed
					task.delay(5, function()
						trackMonster(monsterName, spawnPos)
					end)
				end
			end

			for monsterName, groups in pairs(island.SpawnPoints or {}) do
				for _, entry in ipairs(groups) do
					local ox = entry.offset and entry.offset.X or 0
					local oz = entry.offset and entry.offset.Z or 0
					for i = 1, (entry.count or 1) do
						local spread = Vector3.new((i-1)*12, 0, (i-1)*9)
						local rawPos = Vector3.new(cx + ox, surfaceY, cz + oz) + spread
						local actualY = getSpawnY(rawPos)
						local pos = Vector3.new(rawPos.X, actualY, rawPos.Z)

						trackMonster(monsterName, pos)
						total += 1
					end
				end
			end
		end
	end
	print("[MonsterSpawnBootstrap] Tracked " .. total .. " monster spawners.")
end
task.wait(8)
spawnAll()
