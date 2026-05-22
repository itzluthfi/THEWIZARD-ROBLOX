local ShopConfig = {}

ShopConfig.ITEMS = {
	-- Spells (Buying unlocks them)
	IceSpike = {
		Name = "Ice Spike Scroll",
		Type = "Spell",
		Price = 100,
		Description = "Unlock the Ice Spike spell."
	},
	LightningBolt = {
		Name = "Lightning Bolt Scroll",
		Type = "Spell",
		Price = 300,
		Description = "Unlock the Lightning Bolt spell."
	},
	
	-- Potions
	SmallHealthPotion = {
		Name = "Health Potion (S)",
		Type = "Potion",
		Price = 50,
		Value = 50,
		TargetStat = "Health",
		Description = "Heals 50 Health."
	},
	SmallManaPotion = {
		Name = "Mana Potion (S)",
		Type = "Potion",
		Price = 50,
		Value = 50,
		TargetStat = "Mana",
		Description = "Restores 50 Mana."
	}
}

return ShopConfig
