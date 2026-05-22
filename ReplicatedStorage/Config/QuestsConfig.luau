local QuestsConfig = {}

QuestsConfig.QUESTS = {
	StarterHunt = {
		Name = "Starter Slime Hunt",
		Description = "Clear some slimes to help the island.",
		Type = "Kill",
		Target = "Slime",
		Amount = 5,
		LevelReq = 1,
		Rewards = {
			Gold = 100,
			XP = 200,
			Items = {}
		}
	},
	RatProblem = {
		Name = "The Rat Problem",
		Description = "Those rats are everywhere! Kill 10 of them.",
		Type = "Kill",
		Target = "Rat",
		Amount = 10,
		LevelReq = 2,
		Rewards = {
			Gold = 250,
			XP = 500,
			Items = {}
		}
	},
	ForestSpiritHunt = {
		Name = "Forest Guardian",
		Description = "The Forest Spirits are restless. Defeat 5 of them.",
		Type = "Kill",
		Target = "ForestSpirit",
		Amount = 5,
		LevelReq = 10,
		Rewards = {
			Gold = 1000,
			XP = 2000,
			Items = {}
		}
	},
	VoidSlayer = {
		Name = "Legend of the Void",
		Description = "Defeat the mighty Void Dragon to prove your power.",
		Type = "Kill",
		Target = "VoidDragon",
		Amount = 1,
		LevelReq = 90,
		Rewards = {
			Gold = 50000,
			XP = 100000,
			Items = {"LegendaryWand"}
		}
	}
}

function QuestsConfig.GetQuest(questId)
	return QuestsConfig.QUESTS[questId]
end

return QuestsConfig
