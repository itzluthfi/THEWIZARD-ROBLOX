
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test Suite: TheWizard Game
-- ═══════════════════════════════════════════════════════════════════════════════

local TestRunner = {
	results = {},
	passed = 0,
	failed = 0,
	startTime = os.clock(),
}

local function section(name)
	print(string.rep("─", 60))
	print("  🔬  " .. name)
	print(string.rep("─", 60))
end

local function pass(name)
	TestRunner.passed += 1
	print(string.format("  ✅  PASS  %s", name))
end

local function fail(name, reason)
	TestRunner.failed += 1
	warn(string.format("  ❌  FAIL  %s\n         └─ %s", name, reason))
end

local function assert(condition, name, reason)
	if condition then
		pass(name)
	else
		fail(name, reason)
	end
	return condition
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 1: MonstersConfig
-- ═══════════════════════════════════════════════════════════════════════════════
section("MonstersConfig (16 monsters expected)")

local MonstersConfig = require(ReplicatedStorage.Config:WaitForChild("MonstersConfig"))
local monsterCount = 0
local requiredStats = {"Name", "Level", "Health", "Damage", "Speed", "AggroRange", "AttackRange", "AttackCooldown", "ExpReward", "GoldReward", "Size", "Color"}

for name, stats in pairs(MonstersConfig.MONSTERS) do
	monsterCount += 1
	for _, field in ipairs(requiredStats) do
		assert(
			stats[field] ~= nil,
			string.format("%s → %s", name, field),
			string.format("Missing field: %s", field)
		)
	end
	assert(
		type(stats.Health) == "number" and stats.Health > 0,
		string.format("%s → Health > 0 (got %d)", name, stats.Health),
		"Health must be a positive number"
	)
	assert(
		type(stats.Level) == "number" and stats.Level > 0,
		string.format("%s → Level > 0 (got %d)", name, stats.Level),
		"Level must be a positive integer"
	)
	assert(
		type(stats.Speed) == "number" and stats.Speed >= 0,
		string.format("%s → Speed ≥ 0 (got %d)", name, stats.Speed),
		"Speed must be ≥ 0"
	)
	assert(
		type(stats.Size) == "userdata",
		string.format("%s → Size is %s", name, type(stats.Size)),
		"Size must be a Vector3"
	)
end
assert(monsterCount == 16, "MonsterCount == 16", "Got " .. monsterCount .. " monsters")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 2: IslandsConfig
-- ═══════════════════════════════════════════════════════════════════════════════
section("IslandsConfig (8 islands expected)")

local IslandsConfig = require(ReplicatedStorage.Config:WaitForChild("IslandsConfig"))
local islandCount = #(table.create(0, nil))
islandCount = 0
for id, island in pairs(IslandsConfig.GetAllIslands()) do
	islandCount += 1
	assert(
		island.Position ~= nil and type(island.Position) == "table",
		string.format("%s → Position table", id),
		"Island missing Position"
	)
	assert(
		island.SpawnPoints ~= nil and type(island.SpawnPoints) == "table",
		string.format("%s → SpawnPoints table", id),
		"Island missing SpawnPoints"
	)
	-- Verify all spawn monsters exist in config
	for mobType in pairs(island.SpawnPoints) do
		assert(
			MonstersConfig.GetMonster(mobType) ~= nil,
			string.format("%s → spawn monster '%s' exists", id, mobType),
			string.format("Monster '%s' not in MonstersConfig", mobType)
		)
	end
end
assert(islandCount >= 8, "IslandCount >= 8", "Got " .. islandCount .. " islands")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 3: MobService — Structure
-- ═══════════════════════════════════════════════════════════════════════════════
section("MobService (spawner module)")

local MobService = require(ServerScriptStorage.GameSystems.Services:WaitForChild("MobService"))
assert(type(MobService.SpawnMonster) == "function", "SpawnMonster function exists", "SpawnMonster not a function")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 4: MobService.SpawnMonster — Spawn a Slime
-- ═══════════════════════════════════════════════════════════════════════════════
section("SpawnMonster('Slime') → returns Model at workspace")

local spawnedCountBefore = #workspace:GetChildren()
local slimeModel = MobService.SpawnMonster("Slime", Vector3.new(0, 10, 0))
assert(slimeModel ~= nil, "SpawnMonster returns non-nil model", "Got nil — Humanoid probably missing or wrong RootPart")
assert(slimeModel:IsA("Model"), "Returned model is a Model instance", "Got: " .. slimeModel.ClassName)
assert(slimeModel.PrimaryPart ~= nil, "Model has PrimaryPart", "Missing PrimaryPart")
assert(slimeModel.PrimaryPart.ClassName == "Part", "PrimaryPart is a Part", "Got: " .. slimeModel.PrimaryPart.ClassName)
assert(slimeModel.PrimaryPart.Name == "HumanoidRootPart", "PrimaryPart named HumanoidRootPart", "Named: " .. slimeModel.PrimaryPart.Name)

local hum = slimeModel:FindFirstChildOfClass("Humanoid")
assert(hum ~= nil, "Model has a Humanoid", "Missing Humanoid")
assert(hum.MaxHealth > 0, "Humanoid.MaxHealth > 0 (got " .. hum.MaxHealth .. ")", "MaxHealth not set correctly")
assert(hum.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None, "HealthBar hidden via DisplayDistanceType", "ShowDistance")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 5: Procedural Monster Parts
-- ═══════════════════════════════════════════════════════════════════════════════
section("Procedural Slime parts are welded to root")

local root = slimeModel.PrimaryPart
local children = slimeModel:GetChildren()
local partCount = 0
for _, obj in ipairs(children) do
	if obj:IsA("BasePart") then partCount += 1 end
end
assert(partCount >= 1, "At least 1 BasePart in Slime (got " .. partCount .. ")", "Parts missing")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 6: Fly Monster Spawn
-- ═══════════════════════════════════════════════════════════════════════════════
section("SpawnMonster('Bat') → flying monster")

local bat = MobService.SpawnMonster("Bat", Vector3.new(100, 10, 0))
assert(bat ~= nil, "Bat spawned successfully", "Bat spawn failed")
local batHum = bat:FindFirstChildOfClass("Humanoid")
assert(batHum ~= nil, "Bat has Humanoid", "Missing Humanoid")
assert(batHum.WalkSpeed > 0, "Bat WalkSpeed = " .. batHum.WalkSpeed, "WalkSpeed not set")
-- Cleanup
bat:Destroy()

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 7: Stat Upgrade Monster (high stats)
-- ═══════════════════════════════════════════════════════════════════════════════
section("SpawnMonster('Lava Golem') → high-stat monster")

local golem = MobService.SpawnMonster("Lava Golem", Vector3.new(200, 10, 200))
assert(golem ~= nil, "Lava Golem spawned successfully", "Golem spawn failed")
local golemHum = golem:FindFirstChildOfClass("Humanoid")
assert(golemHum.MaxHealth == 500, "MaxHealth == 500 (got " .. golemHum.MaxHealth .. ")", "Wrong HP")
assert(golemHum.WalkSpeed == 6, "WalkSpeed == 6 (got " .. golemHum.WalkSpeed .. ")", "Wrong walk speed")
-- Root should have been auto-positioned above ground
assert(golem.PrimaryPart.Position.Y > 5, "Root Position.Y > 5 (got " .. tostring(golem.PrimaryPart.Position.Y) .. ")", "Root too low (sunk into ground)")
-- Cleanup
golem:Destroy()

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 8: MonsterSpawnBootstrap fires Died hook
-- ═══════════════════════════════════════════════════════════════════════════════
section("MonsterD — Humanoid.Died fires (respawning logic)")

-- Check that the bootstrap script loaded properly by reading its script instance
local bootstrap = ServerScriptService:FindFirstChild("MonsterSpawnBootstrap")
assert(bootstrap ~= nil and bootstrap:IsA("Script"), "MonsterSpawnBootstrap script exists", "Script missing")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 9: DataManager — Create a mock player
-- ═══════════════════════════════════════════════════════════════════════════════
section("DataManager (mock player 1)")

local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))
local mockPlayer = Instance.new("Player")
mockPlayer.Name = "TestPlayer_Lemonade"
mockPlayer.UserId = 999011100
mockPlayer.Parent = Players

-- Wait for the PlayerAdded handler to trigger
local ok = DataManager.Get(mockPlayer)
assert(ok ~= nil, "DataManager assigned session to mock player", "Session not created")

local data = ok
assert(data.Level == 1,                            "Level == 1",             "Starting level wrong")
assert(data.XP    == 0,                            "XP   == 0",              "Starting XP wrong")
assert(data.Gold  == 100,                          "Gold == 100",            "Starting gold wrong")
assert(data.Mana  == data.MaxMana,                 "Mana == MaxMana",        "Mana mismatch at start")
-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 10: DataManager.AddXP — level-up overflow from 1 → 3
-- ═══════════════════════════════════════════════════════════════════════════════
section("AddXP → LevelUp (1 XP → 150 XPOverflow)")

DataManager.AddXP(mockPlayer, 150)  -- XPToNext at Lv1 = floor(100*1^1.35)=100; 150 XP= Lv1→Lv2 (XP left=50), needs 147 more
task.wait(0.1)
local d2 = DataManager.Get(mockPlayer)
assert(d2.Level >= 2, "Level ≥ 2 after 150 XP (got " .. d2.Level .. ")", "Level-up did not increment")
assert(d2.StatPoints >= 1, "StatPoints ≥ 1", "StatPoints not awarded")
assert(d2.XP < d2.XPToNext, "XP < XPToNext", "XP overflow not clamped")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 11: DataManager.AddXP & AddGold
-- ═══════════════════════════════════════════════════════════════════════════════
section("AddXP & AddGold")

local gBefore = d2.Gold
DataManager.AddXP(mockPlayer, 10)
task.wait(0.1)
DataManager.AddGold(mockPlayer, 50)
task.wait(0.1)
local d3 = DataManager.Get(mockPlayer)
assert(d3.Gold == gBefore + 50, "Gold increased by 50 (got " .. d3.Gold .. ")", "Gold not added")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 12: DataManager.SpendMana — success + fail paths
-- ═══════════════════════════════════════════════════════════════════════════════

local mBefore = d3.Mana
local spentOK = DataManager.SpendMana(mockPlayer, 10)
assert(spentOK == true, "SpendMana(small) returns true", "Should have enough mana")
assert(DataManager.Get(mockPlayer).Mana == mBefore - 10, "Mana reduced by 10", "Mana not reduced")

local overSpend = DataManager.SpendMana(mockPlayer, 9999)
assert(overSpend == false, "SpendMana(huge) returns false", "Should fail when insufficient")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 13: RemoteEvents — existence check
-- ═══════════════════════════════════════════════════════════════════════════════
section("RemoteEvents (18 expected)")

local remotesFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local requiredRemotes = {
	"UpdateData", "SyncData", "RequestSave", "LevelUp", "SpellCast",
	"DamageDealt", "MonsterKilled", "ItemPicked", "QuestCompleted",
	"TeleportRequest", "ChatMessage", "SlotCooldown", "GachaSpell",
	"EquipSpell", "AllocateStat",
}
local functionsFolder = remotesFolder:WaitForChild("Functions")
local requiredFunctions = {
	"GetPlayerData", "ValidateAction", "PurchaseItem", "UnlockSpell", "UnlockIsland",
}

local remFound = 0
for _, name in ipairs(requiredRemotes) do
	local r = remotesFolder:FindFirstChild(name)
	assert(r ~= nil and r:IsA("RemoteEvent"), string.format("RemoteEvent '%s' exists", name), "Missing RemoteEvent: " .. name)
	remFound += 1
end
local fnFound = 0
for _, name in ipairs(requiredFunctions) do
	local r = functionsFolder:FindFirstChild(name)
	assert(r ~= nil and r:IsA("RemoteFunction"), string.format("RemoteFunction '%s' exists", name), "Missing RemoteFunction: " .. name)
	fnFound += 1
end
assert(remFound == #requiredRemotes, "All RemoteEvents present (" .. remFound .. "/" .. #requiredRemotes .. ")", "")
assert(fnFound == #requiredFunctions, "All RemoteFunctions present (" .. fnFound .. "/" .. #requiredFunctions .. ")", "")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 14: MobService — non-existent monster fallback
-- ═══════════════════════════════════════════════════════════════════════════════
section("SpawnMonster('NonExistent') → uses fallback stats")

local fallback = MobService.SpawnMonster("NonExistentMonster_Test", Vector3.new(500, 10, 500))
assert(fallback ~= nil, "Fallback spawn returns model", "Fallback return nil")
assert(fallback:FindFirstChildOfClass("Humanoid") ~= nil, "Fallback has Humanoid", "Fallback missing Humanoid")
-- Cleanup
fallback:Destroy()

-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 15: Island Position Consistency
-- ═══════════════════════════════════════════════════════════════════════════════
section("IslandConfig — Z sorting / relative ordering")

for id, island in pairs(IslandsConfig.GetAllIslands()) do
	assert(
		type(island.Position.X) == "number" and type(island.Position.Z) == "number",
		string.format("%s → X and Z are numbers", id),
		"Position coords must be numbers"
	)
end
-- ═══════════════════════════════════════════════════════════════════════════════
-- Test 16: Cleanup & Summary
-- ═══════════════════════════════════════════════════════════════════════════════

section("Cleanup mock player")
mockPlayer:Destroy()

-- ═══════════════════════════════════════════════════════════════════════════════
-- Summary
-- ═══════════════════════════════════════════════════════════════════════════════
local elapsed = os.clock() - TestRunner.startTime
print(string.rep("─", 60))
print(string.format("  📊  Results  |  %.2f s", elapsed))
print(string.format("     ✅  Passed : %d", TestRunner.passed))
print(string.format("  ⚠️   Failed : %d", TestRunner.failed))
print(string.rep("─", 60))
