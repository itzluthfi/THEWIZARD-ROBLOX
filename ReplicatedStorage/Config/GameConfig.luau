--[[
	GameConfig.lua
	Main configuration file for TheWizard game
	Contains all core game settings and constants
]]

local GameConfig = {}

-- Game Info
GameConfig.GAME_NAME = "TheWizard"
GameConfig.GAME_VERSION = "1.0.0"
GameConfig.GAME_DESCRIPTION = "A magical wizard RPG with alchemy, combat, and exploration"

-- Data Store Settings
GameConfig.DATA_STORE_NAME = "TheWizardPlayerData"
GameConfig.DATA_STORE_VERSION = 1
GameConfig.AUTO_SAVE_INTERVAL = 60 -- seconds

-- Player Settings
GameConfig.STARTING_GOLD = 100
GameConfig.STARTING_GEMS = 0
GameConfig.MAX_HEALTH = 100
GameConfig.MAX_MANA = 100
GameConfig.HEALTH_REGEN = 1 -- per second
GameConfig.MANA_REGEN = 5 -- per second
GameConfig.BASE_WALK_SPEED = 16
GameConfig.BASE_JUMP_POWER = 50

-- Level System
GameConfig.MAX_LEVEL = 100
GameConfig.BASE_EXP_REQUIRED = 100
GameConfig.EXP_MULTIPLIER = 1.5
GameConfig.EXP_PER_MONSTER_LEVEL = 50

-- Element Types
GameConfig.ELEMENTS = {
	"Fire",
	"Ice",
	"Lightning",
	"Earth",
	"Wind",
	"Water",
	"Light",
	"Dark",
	"Arcane",
	"Nature",
	"Poison"
}

-- Rarity System
GameConfig.RARITIES = {
	Common = {
		Color = Color3.fromRGB(200, 200, 200),
		Multiplier = 1.0,
		DropChance = 0.6
	},
	Uncommon = {
		Color = Color3.fromRGB(50, 205, 50),
		Multiplier = 1.25,
		DropChance = 0.25
	},
	Rare = {
		Color = Color3.fromRGB(65, 105, 225),
		Multiplier = 1.5,
		DropChance = 0.10
	},
	Epic = {
		Color = Color3.fromRGB(148, 0, 211),
		Multiplier = 2.0,
		DropChance = 0.04
	},
	Legendary = {
		Color = Color3.fromRGB(255, 165, 0),
		Multiplier = 3.0,
		DropChance = 0.009
	},
	Mythic = {
		Color = Color3.fromRGB(255, 50, 50),
		Multiplier = 5.0,
		DropChance = 0.001
	}
}

-- Equipment Slots
GameConfig.EQUIPMENT_SLOTS = {
	"Wand",
	"Staff",
	"Robe",
	"Hat",
	"Amulet",
	"Ring1",
	"Ring2",
	"Relic"
}

-- Currency Types
GameConfig.CURRENCIES = {
	Gold = {
		Name = "Gold",
		Color = Color3.fromRGB(255, 215, 0),
		Icon = "rbxassetid://7072726342"
	},
	Gems = {
		Name = "Gems",
		Color = Color3.fromRGB(0, 255, 255),
		Icon = "rbxassetid://7072726343"
	},
	ManaCrystals = {
		Name = "Mana Crystals",
		Color = Color3.fromRGB(138, 43, 226),
		Icon = "rbxassetid://7072726344"
	}
}

-- Combat Settings
GameConfig.COMBAT = {
	BASE_DAMAGE = 10,
	CRITICAL_CHANCE = 0.1,
	CRITICAL_MULTIPLIER = 2.0,
	DAMAGE_VARIANCE = 0.1, -- +/- 10%
	COOLDOWN_GLOBAL = 0.5,
	PROJECTILE_SPEED = 100,
	PROJECTILE_LIFETIME = 5
}

-- Broom Settings
GameConfig.BROOM = {
	BASE_SPEED = 50,
	MAX_SPEED = 150,
	ACCELERATION = 20,
	FLIGHT_HEIGHT_MIN = 10,
	FLIGHT_HEIGHT_MAX = 200,
	STAMINA_DRAIN = 1, -- per second
	STAMINA_REGEN = 2 -- per second when grounded
}

-- Crafting Settings
GameConfig.CRAFTING = {
	BASE_SUCCESS_RATE = 0.8,
	CRITICAL_CRAFT_CHANCE = 0.05,
	CRITICAL_CRAFT_BONUS = 0.25 -- 25% bonus stats
}

-- Monster Settings
GameConfig.MONSTER = {
	SPAWN_RADIUS = 100,
	MAX_SPAWN_PER_AREA = 10,
	RESPAWN_TIME = 30,
	AGGRO_RANGE = 50,
	CHASE_SPEED = 12,
	PATROL_SPEED = 6
}

-- Quest Settings
GameConfig.QUEST = {
	MAX_ACTIVE_QUESTS = 5,
	DAILY_QUEST_COUNT = 3,
	DAILY_RESET_HOUR = 0 -- midnight UTC
}

-- Island Unlock Costs
GameConfig.ISLAND_UNLOCK = {
	StarterIsland = {Level = 1, Gold = 0},
	AcademyIsland = {Level = 5, Gold = 500},
	ForestIsland = {Level = 10, Gold = 1000},
	SwampIsland = {Level = 15, Gold = 2000},
	VolcanoIsland = {Level = 25, Gold = 5000},
	IceIsland = {Level = 35, Gold = 8000},
	RuinsIsland = {Level = 50, Gold = 15000},
	SkyIsland = {Level = 70, Gold = 30000},
	VoidIsland = {Level = 90, Gold = 50000}
}

-- PvP Settings
GameConfig.PVP = {
	ENABLED = true,
	ARENA_SIZE = 100,
	MATCHMAKING_RANGE = 5, -- level difference
	REWARD_WIN = 50,
	REWARD_LOSS = 10
}

-- Social Settings
GameConfig.SOCIAL = {
	MAX_PARTY_SIZE = 4,
	MAX_FRIENDS_DISPLAYED = 50,
	TRADE_FEE = 0.1 -- 10% tax
}

return GameConfig