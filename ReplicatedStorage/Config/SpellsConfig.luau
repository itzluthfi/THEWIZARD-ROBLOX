local SpellsConfig = {}
SpellsConfig.SPELLS = {
	["Basic Shot"] = {
		Element="Arcane", Type="Projectile", Tier="Basic",
		Damage=8, ManaCost=0, Cooldown=0.6, Range=55, Speed=120,
		Effect={Color=Color3.fromRGB(220,220,255), Secondary=Color3.fromRGB(150,150,250), Element="Arcane"},
	},
	["Crimson Bolt"] = {
		Element="Fire", Type="Projectile", Tier="Basic",
		Damage=18, ManaCost=8, Cooldown=1.5, Range=65, Speed=95,
		Effect={Color=Color3.fromRGB(255,100,20), Secondary=Color3.fromRGB(255,200,50), Element="Fire"},
	},
	["Inferno Cascade"] = {
		Element="Fire", Type="AOE", Tier="Advanced",
		Damage=30, ManaCost=22, Cooldown=4, Radius=18, Speed=70,
		Effect={Color=Color3.fromRGB(255,60,0), Secondary=Color3.fromRGB(255,180,30), Element="Fire"},
	},
	["Phoenix Wrath"] = {
		Element="Fire", Type="Projectile", Tier="Rare",
		Damage=45, ManaCost=30, Cooldown=3, Range=75, Speed=110,
		Effect={Color=Color3.fromRGB(255,130,0), Secondary=Color3.fromRGB(255,255,100), Element="Fire"},
	},
	["Apocalypse Flare"] = {
		Element="Fire", Type="AOE", Tier="Epic",
		Damage=65, ManaCost=50, Cooldown=6, Radius=24, Speed=60,
		Effect={Color=Color3.fromRGB(200,20,0), Secondary=Color3.fromRGB(255,160,0), Element="Fire"},
	},
	["Frost Fang"] = {
		Element="Ice", Type="Projectile", Tier="Basic",
		Damage=15, ManaCost=7, Cooldown=1.2, Range=60, Speed=100,
		Effect={Color=Color3.fromRGB(100,200,255), Secondary=Color3.fromRGB(220,240,255), Element="Ice"},
	},
	["Glacial Nova"] = {
		Element="Ice", Type="AOE", Tier="Advanced",
		Damage=28, ManaCost=20, Cooldown=3.5, Radius=16, Speed=65,
		Effect={Color=Color3.fromRGB(50,150,255), Secondary=Color3.fromRGB(200,230,255), Element="Ice"},
	},
	["Winter's Embrace"] = {
		Element="Ice", Type="Projectile", Tier="Rare",
		Damage=40, ManaCost=28, Cooldown=3, Range=70, Speed=105,
		Effect={Color=Color3.fromRGB(30,120,255), Secondary=Color3.fromRGB(180,220,255), Element="Ice"},
	},
	["Eternal Frost"] = {
		Element="Ice", Type="AOE", Tier="Epic",
		Damage=60, ManaCost=45, Cooldown=5.5, Radius=22, Speed=55,
		Effect={Color=Color3.fromRGB(20,80,200), Secondary=Color3.fromRGB(150,200,255), Element="Ice"},
	},
	["Venom Strike"] = {
		Element="Poison", Type="Projectile", Tier="Basic",
		Damage=14, ManaCost=6, Cooldown=1.3, Range=55, Speed=85,
		Effect={Color=Color3.fromRGB(80,200,40), Secondary=Color3.fromRGB(150,255,50), Element="Poison"},
	},
	["Plague Cloud"] = {
		Element="Poison", Type="AOE", Tier="Advanced",
		Damage=25, ManaCost=18, Cooldown=3.5, Radius=15, Speed=60,
		Effect={Color=Color3.fromRGB(40,150,20), Secondary=Color3.fromRGB(120,200,30), Element="Poison"},
	},
	["Death Blossom"] = {
		Element="Poison", Type="AOE", Tier="Rare",
		Damage=42, ManaCost=32, Cooldown=4, Radius=20, Speed=50,
		Effect={Color=Color3.fromRGB(20,120,10), Secondary=Color3.fromRGB(80,180,20), Element="Poison"},
	},
	["Arcane Missile"] = {
		Element="Arcane", Type="Projectile", Tier="Basic",
		Damage=20, ManaCost=10, Cooldown=1.8, Range=70, Speed=90,
		Effect={Color=Color3.fromRGB(160,50,255), Secondary=Color3.fromRGB(220,150,255), Element="Arcane"},
	},
	["Rift Pulse"] = {
		Element="Arcane", Type="AOE", Tier="Advanced",
		Damage=32, ManaCost=24, Cooldown=4, Radius=17, Speed=65,
		Effect={Color=Color3.fromRGB(120,20,220), Secondary=Color3.fromRGB(200,120,255), Element="Arcane"},
	},
	["Celestial Barrage"] = {
		Element="Arcane", Type="Projectile", Tier="Rare",
		Damage=48, ManaCost=35, Cooldown=3.5, Range=80, Speed=115,
		Effect={Color=Color3.fromRGB(180,80,255), Secondary=Color3.fromRGB(255,200,255), Element="Arcane"},
	},
	["Void Annihilation"] = {
		Element="Arcane", Type="AOE", Tier="Epic",
		Damage=70, ManaCost=55, Cooldown=7, Radius=25, Speed=50,
		Effect={Color=Color3.fromRGB(60,0,120), Secondary=Color3.fromRGB(150,50,255), Element="Arcane"},
	},
	["Spark Lance"] = {
		Element="Lightning", Type="Projectile", Tier="Basic",
		Damage=22, ManaCost=12, Cooldown=2, Range=75, Speed=130,
		Effect={Color=Color3.fromRGB(255,255,80), Secondary=Color3.fromRGB(255,255,200), Element="Lightning"},
	},
	["Thunder Dome"] = {
		Element="Lightning", Type="AOE", Tier="Advanced",
		Damage=35, ManaCost=26, Cooldown=4, Radius=18, Speed=70,
		Effect={Color=Color3.fromRGB(255,220,50), Secondary=Color3.fromRGB(200,200,255), Element="Lightning"},
	},
	["Storm Judgement"] = {
		Element="Lightning", Type="Projectile", Tier="Rare",
		Damage=52, ManaCost=38, Cooldown=4, Range=85, Speed=140,
		Effect={Color=Color3.fromRGB(200,200,255), Secondary=Color3.fromRGB(255,255,100), Element="Lightning"},
	},
}
-- Weapon Projectiles (these go in EquippedSpells[4])
SpellsConfig.SPELLS["Stick"] = {
	Element="Physical", Type="Projectile", Tier="Basic",
	Damage=15, ManaCost=0, Cooldown=1.0, Range=50, Speed=100,
	Effect={Color=Color3.fromRGB(139,90,43), Secondary=Color3.fromRGB(210,180,140), Element="Physical"},
}
SpellsConfig.SPELLS["StaffOfSparks"] = {
	Element="Lightning", Type="Projectile", Tier="Rare",
	Damage=40, ManaCost=0, Cooldown=0.7, Range=70, Speed=130,
	Effect={Color=Color3.fromRGB(255,255,80), Secondary=Color3.fromRGB(255,220,50), Element="Lightning"},
}
SpellsConfig.SPELLS["MasterStaff"] = {
	Element="Arcane", Type="Projectile", Tier="Epic",
	Damage=55, ManaCost=0, Cooldown=0.6, Range=80, Speed=120,
	Effect={Color=Color3.fromRGB(180,80,255), Secondary=Color3.fromRGB(220,150,255), Element="Arcane"},
}
SpellsConfig.SPELLS["StaffOmega"] = {
	Element="Void", Type="Projectile", Tier="Legendary",
	Damage=75, ManaCost=0, Cooldown=0.5, Range=90, Speed=140,
	Effect={Color=Color3.fromRGB(60,0,120), Secondary=Color3.fromRGB(150,50,255), Element="Void"},
}
SpellsConfig.SPELLS["KorbloxStaff"] = {
	Element="Dark", Type="Projectile", Tier="Epic",
	Damage=60, ManaCost=0, Cooldown=0.55, Range=85, Speed=125,
	Effect={Color=Color3.fromRGB(128,0,128), Secondary=Color3.fromRGB(200,100,200), Element="Dark"},
}
SpellsConfig.SPELLS["AstralWand"] = {
	Element="Arcane", Type="Projectile", Tier="Rare",
	Damage=38, ManaCost=0, Cooldown=0.8, Range=75, Speed=130,
	Effect={Color=Color3.fromRGB(140,200,255), Secondary=Color3.fromRGB(220,240,255), Element="Arcane"},
}
-- Legacy fallback
SpellsConfig.SPELLS["AzUkr_wpn"] = {
	Element="Ice", Type="Projectile", Tier="Basic",
	Damage=35, ManaCost=0, Cooldown=0.8, Range=65, Speed=110,
	Effect={Color=Color3.fromRGB(100,200,255), Secondary=Color3.fromRGB(220,255,255), Element="Ice"},
}
SpellsConfig.SPELLS["AzureIceStaff"] = {
	Element="Ice", Type="Projectile", Tier="Basic",
	Damage=35, ManaCost=0, Cooldown=0.8, Range=65, Speed=110,
	Effect={Color=Color3.fromRGB(100,200,255), Secondary=Color3.fromRGB(220,255,255), Element="Ice"},
}

function SpellsConfig.GetSpell(name)
	-- Direct lookup first
	if SpellsConfig.SPELLS[name] then return SpellsConfig.SPELLS[name] end

	-- Map legacy names
	local legacyMap = {
		["AzureIceStaff"] = "Stick",
		["AzUkr_wpn"] = "Stick",
	}
	if legacyMap[name] and SpellsConfig.SPELLS[legacyMap[name]] then
		return SpellsConfig.SPELLS[legacyMap[name]]
	end

	return nil
end

-- Get weapon tier by name
function SpellsConfig.GetWeaponTier(name)
	local tiers = {
		Stick = "Common",
		StaffOfSparks = "Rare",
		AstralWand = "Rare",      -- NEW rare wand
		MasterStaff = "Epic",
		StaffOmega = "Legendary",
		KorbloxStaff = "Epic",
		AzureIceStaff = "Common",
	}
	return tiers[name] or "Common"
end

return SpellsConfig
