--[[
	MonsterSpawner.lua
	Server-side per-island spawn system — replaces the old MobService spawn loop.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IslandsConfig   = require(ReplicatedStorage.Config.IslandsConfig)
local MonstersConfig  = require(ReplicatedStorage.Config.MonstersConfig)
local MobService      = require(game.ServerScriptService.GameSystems.Services.MobService) -- same env

local MonsterSpawner = {}

local activeMobMap     = {}   -- [islandId] = { [label] = {MonsterType, Instance, RespawnPos, RespawnType} }
local currentIslandId  = ""   -- track current island for respawn cooldown lookup
local debug            = false

local function log(...)
	if debug then print("[MonsterSpawner]", ...) end
end

-- ─── Spawn a single mob at a world position ─────────────────────────────────
local function spawnOne(mobType, worldPos)
	local model = MobService.SpawnMonster(mobType, worldPos)
	if not model then return nil end

	local hum = model:WaitForChild("Humanoid", 10)
	if not hum then
		warn("[MonsterSpawner] No Humanoid in " .. mobType)
		model:Destroy()
		return nil
	end

	-- ─── Respawn cooldown (use RespawnCooldown from IslandsConfig, fallback to 10s) ──
	local respawnCD = IslandsConfig.GetIsland(currentIslandId) and IslandsConfig.GetIsland(currentIslandId).RespawnCooldown or 10

	hum.Died:Connect(function()
		for islandId, slotMap in pairs(activeMobMap) do
			for label, data in pairs(slotMap) do
				if data.Instance == model then
					slotMap[label] = nil
					log(label, "(" .. data.MonsterType .. ") died on", islandId,
					    "→ respawning in", respawnCD, "s")

					task.delay(respawnCD, function()
						if activeMobMap[islandId] and not activeMobMap[islandId][label] then
							local newModel = MobService.SpawnMonster(data.RespawnType, data.RespawnPos)
							if newModel then
								activeMobMap[islandId][label] = {
									MonsterType = data.RespawnType;
									Instance    = newModel;
									RespawnPos  = data.RespawnPos;
									RespawnType = data.RespawnType;
								}
								local newHum = newModel:WaitForChild("Humanoid", 10)
								if newHum then
									newHum.Died:Connect(function()
										for iid, sm in pairs(activeMobMap) do
											for lbl, d in pairs(sm) do
												if d.Instance == newModel then
													sm[lbl] = nil
													task.delay(respawnCD, function()
														if not sm[lbl] then
															local m = MobService.SpawnMonster(d.RespawnType, d.RespawnPos)
															if m then sm[lbl] = {MonsterType=d.RespawnType,Instance=m,RespawnPos=d.RespawnPos,RespawnType=d.RespawnType} end
														end
													end)
													return
												end
											end
										end
									end)
								end
							end
						end
					end)
					return
				end
			end
		end
	end)

	return model
end


-- ─── Spawn AND track all islands ────────────────────────────────────────────
function MonsterSpawner.SpawnAll()
	local islandIndex = 0
	for islandId, islandData in pairs(IslandsConfig.GetAllIslands()) do
		if not islandData.SpawnPoints then goto continue end

		activeMobMap[islandId] = {}
		currentIslandId = islandId -- store for respawn cooldown lookup
		-- Island center position (world space)
		local cx = islandData.Position and islandData.Position.X or 0
		local cz = islandData.Position and islandData.Position.Z or 0
		local slotIdx = 0

		for mobType, posGroups in pairs(islandData.SpawnPoints) do
			for _, entry in ipairs(posGroups) do
				local ox = entry.offset and entry.offset.X or 0
				local oz = entry.offset and entry.offset.Z or 0
				for i = 1, (entry.count or 1) do
					slotIdx += 1
					local label = islandId .. "_s" .. slotIdx
					-- Compute world position: island center + offset + spread if multiple mobs in same group
					local spread = ((i - 1) * 8) -- small spread so same-group mobs don't stack on top of each other
					local worldPos = Vector3.new(cx + ox + math.random(-spread, spread), 50, cz + oz + math.random(-spread, spread))

					-- Raycast down to get ground Y
					local rayParams = RaycastParams.new()
					rayParams.FilterDescendantsInstances = {workspace}
					rayParams.FilterType = Enum.RaycastFilterType.Exclude
					local rayResult = workspace:Raycast(worldPos + Vector3.new(0, 80, 0), Vector3.new(0, -200, 0), rayParams)
					local worldY = rayResult and rayResult.Position.Y or 6

					local model = spawnOne(mobType, Vector3.new(worldPos.X, worldY, worldPos.Z))

					if model then
						activeMobMap[islandId][label] = {
							MonsterType = mobType;
							Instance    = model;
							RespawnPos  = Vector3.new(worldPos.X, worldY, worldPos.Z);
							RespawnType = mobType;
						}
						log("Spawned", mobType, "on", islandId, "slot", slotIdx, "pos=", tostring(Vector3.new(worldPos.X, worldY, worldPos.Z)))
					end
				end
			end
		end

		::continue::
	end

	print("[MonsterSpawner] All islands populated.")
end

-- ─── Init ────────────────────────────────────────────────────────────────────
task.wait(5)
MonsterSpawner.SpawnAll()

return MonsterSpawner
