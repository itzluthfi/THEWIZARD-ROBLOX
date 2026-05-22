local IslandsConfig = {}
local Islands = {
	StarterIsland = {
		Name = "Starter Island", Theme = "Plains",
		Position = {X = 0, Z = 0},
		SpawnPoints = {
			Slime = {
				{offset={X=-40,Z=-30}, count=2},
				{offset={X=35,Z=35}, count=2},
			},
			Bat = {
				{offset={X=45,Z=-40}, count=1},
			},
			Rat = {
				{offset={X=-45,Z=35}, count=2},
			},
			["Tiny Goblin"] = {
				{offset={X=50,Z=-25}, count=1},
			},
			["Brainrot God Lucky Block"] = {
				{offset={X=70,Z=70}, count=1},
			},
		},
	},
	AcademyIsland = {
		Name = "Academy Island", Theme = "Default",
		Position = {X = 600, Z = 0}, SpawnPoints = {},
	},
	ForestIsland = {
		Name = "Forest Island", Theme = "Forest",
		Position = {X = -600, Z = 500},
		SpawnPoints = {
			Wolf = {
				{offset={X=-30,Z=-30}, count=2},
				{offset={X=40,Z=40}, count=2},
			},
			Spider = {
				{offset={X=40,Z=-40}, count=2},
				{offset={X=-45,Z=45}, count=1},
			},
		},
	},
	SwampIsland = {
		Name = "Swamp Island", Theme = "Swamp",
		Position = {X = 0, Z = 900},
		SpawnPoints = {
			["Mud Monster"] = {
				{offset={X=-30,Z=30}, count=2},
				{offset={X=40,Z=-40}, count=1},
			},
			Mosquito = {
				{offset={X=-45,Z=-35}, count=2},
				{offset={X=35,Z=40}, count=2},
			},
		},
	},
	VolcanoIsland = {
		Name = "Volcano Island", Theme = "Volcano",
		Position = {X = 750, Z = 750},
		SpawnPoints = {
			["Fire Imp"] = {
				{offset={X=-35,Z=-35}, count=3},
				{offset={X=40,Z=40}, count=2},
			},
			["Lava Golem"] = {
				{offset={X=0,Z=50}, count=1},
			},
		},
	},
	IceIsland = {
		Name = "Ice Island", Theme = "Ice",
		Position = {X = -750, Z = -550},
		SpawnPoints = {
			["Ice Beetle"] = {
				{offset={X=-40,Z=30}, count=2},
				{offset={X=45,Z=-35}, count=2},
			},
			["Frost Spirit"] = {
				{offset={X=-20,Z=-45}, count=2},
			},
		},
	},
	RuinsIsland = {
		Name = "Ruins Island", Theme = "Default",
		Position = {X = 650, Z = -650},
		SpawnPoints = {
			Skeleton = {
				{offset={X=-40,Z=-40}, count=2},
				{offset={X=45,Z=45}, count=2},
			},
			Wraith = {
				{offset={X=40,Z=-45}, count=1},
				{offset={X=-45,Z=40}, count=1},
			},
		},
	},
	SkyIsland = {
		Name = "Sky Island", Theme = "Default",
		Position = {X = -500, Z = -950},
		SpawnPoints = {
			["Cloud Sprite"] = {
				{offset={X=-35,Z=35}, count=3},
				{offset={X=40,Z=-40}, count=2},
			},
			Wyvern = {
				{offset={X=45,Z=45}, count=1},
			},
		},
	},
	VoidIsland = {
		Name = "Void Island", Theme = "Void",
		Position = {X = 0, Z = -1500},
		SpawnPoints = {
			["Void Crawler"] = {
				{offset={X=-40,Z=-40}, count=2},
				{offset={X=45,Z=45}, count=2},
			},
			["Void Watcher"] = {
				{offset={X=0,Z=60}, count=1},
			},
		},
	},
}
function IslandsConfig.GetIsland(id) return Islands[id] end
function IslandsConfig.GetAllIslands() return Islands end
return IslandsConfig
