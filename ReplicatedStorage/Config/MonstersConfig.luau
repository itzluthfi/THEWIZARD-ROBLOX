local MonstersConfig = {}
MonstersConfig.MONSTERS = {
	-- 🟢 Starter Island (Plains)
	Slime = {
		Name="Slime", Level=1, Health=45, Damage=3, Speed=6,
		AggroRange=20, AttackRange=4, AttackCooldown=2.5, ExpReward=8, GoldReward=3,
		Size=Vector3.new(3,2.5,3), Color=Color3.fromRGB(80,200,80),
	},
	Bat = {
		Name="Bat", Level=2, Health=30, Damage=5, Speed=10,
		AggroRange=25, AttackRange=4.5, AttackCooldown=2, ExpReward=12, GoldReward=5, CanFly=true,
		Size=Vector3.new(2.5,1.5,2.5), Color=Color3.fromRGB(60,40,60),
	},
	Rat = {
		Name="Rat", Level=2, Health=35, Damage=4, Speed=11,
		AggroRange=18, AttackRange=3.5, AttackCooldown=1.8, ExpReward=10, GoldReward=4,
		Size=Vector3.new(2,1.5,3), Color=Color3.fromRGB(100,80,60),
	},
	["Tiny Goblin"] = {
		Name="Tiny Goblin", Level=3, Health=55, Damage=7, Speed=9,
		AggroRange=22, AttackRange=4, AttackCooldown=2.2, ExpReward=18, GoldReward=8,
		Size=Vector3.new(2.5,3,2.5), Color=Color3.fromRGB(80,140,60),
	},
	-- 🌲 Forest Island
	Wolf = {
		Name="Wolf", Level=5, Health=90, Damage=12, Speed=14,
		AggroRange=28, AttackRange=5, AttackCooldown=1.8, ExpReward=30, GoldReward=15,
		Size=Vector3.new(3.5,3.2,5), Color=Color3.fromRGB(100,100,110),
	},
	Spider = {
		Name="Spider", Level=6, Health=80, Damage=15, Speed=10,
		AggroRange=24, AttackRange=4.5, AttackCooldown=1.5, ExpReward=32, GoldReward=18,
		Size=Vector3.new(4,2.2,4), Color=Color3.fromRGB(40,30,30),
	},
	-- 🪰 Swamp Island
	["Mud Monster"] = {
		Name="Mud Monster", Level=8, Health=160, Damage=18, Speed=7,
		AggroRange=24, AttackRange=5, AttackCooldown=2.4, ExpReward=55, GoldReward=25,
		Size=Vector3.new(4.5,5,4.5), Color=Color3.fromRGB(80,70,55),
	},
	Mosquito = {
		Name="Mosquito", Level=9, Health=90, Damage=22, Speed=16,
		AggroRange=30, AttackRange=5, AttackCooldown=1.2, ExpReward=60, GoldReward=28, CanFly=true,
		Size=Vector3.new(2,2,2), Color=Color3.fromRGB(120,40,40),
	},
	-- 🌋 Volcano Island
	["Fire Imp"] = {
		Name="Fire Imp", Level=12, Health=220, Damage=30, Speed=12,
		AggroRange=26, AttackRange=6, AttackCooldown=2, ExpReward=110, GoldReward=50,
		Size=Vector3.new(3,4.5,3), Color=Color3.fromRGB(220,90,30),
	},
	["Lava Golem"] = {
		Name="Lava Golem", Level=15, Health=500, Damage=45, Speed=6,
		AggroRange=32, AttackRange=8, AttackCooldown=3, ExpReward=250, GoldReward=120,
		Size=Vector3.new(7,9,7), Color=Color3.fromRGB(100,20,10),
	},
	-- ❄️ Ice Island
	["Ice Beetle"] = {
		Name="Ice Beetle", Level=18, Health=350, Damage=35, Speed=10,
		AggroRange=25, AttackRange=5.5, AttackCooldown=2.2, ExpReward=220, GoldReward=95,
		Size=Vector3.new(4,3.2,4.5), Color=Color3.fromRGB(120,200,255),
	},
	["Frost Spirit"] = {
		Name="Frost Spirit", Level=20, Health=280, Damage=50, Speed=15,
		AggroRange=30, AttackRange=7, AttackCooldown=1.6, ExpReward=260, GoldReward=110, CanFly=true,
		Size=Vector3.new(3,5,3), Color=Color3.fromRGB(200,240,255),
	},
	-- 🏛️ Ruins Island
	Skeleton = {
		Name="Skeleton", Level=23, Health=450, Damage=55, Speed=11,
		AggroRange=28, AttackRange=5.5, AttackCooldown=2, ExpReward=380, GoldReward=160,
		Size=Vector3.new(3.2,6.5,3.2), Color=Color3.fromRGB(200,200,190),
	},
	Wraith = {
		Name="Wraith", Level=25, Health=380, Damage=70, Speed=14,
		AggroRange=32, AttackRange=6.5, AttackCooldown=1.7, ExpReward=450, GoldReward=190, CanFly=true,
		Size=Vector3.new(3,7,3), Color=Color3.fromRGB(80,40,120),
	},
	-- ☁️ Sky Island
	["Cloud Sprite"] = {
		Name="Cloud Sprite", Level=28, Health=550, Damage=65, Speed=18,
		AggroRange=30, AttackRange=6, AttackCooldown=1.5, ExpReward=620, GoldReward=240, CanFly=true,
		Size=Vector3.new(3.5,3.5,3.5), Color=Color3.fromRGB(240,240,255),
	},
	Wyvern = {
		Name="Wyvern", Level=32, Health=800, Damage=90, Speed=20,
		AggroRange=40, AttackRange=9, AttackCooldown=2.2, ExpReward=950, GoldReward=380, CanFly=true,
		Size=Vector3.new(10,5,10), Color=Color3.fromRGB(60,110,150),
	},
	-- 🌌 Void Island
	["Void Crawler"] = {
		Name="Void Crawler", Level=36, Health=1200, Damage=120, Speed=12,
		AggroRange=35, AttackRange=8, AttackCooldown=1.8, ExpReward=1600, GoldReward=600,
		Size=Vector3.new(6,4,8), Color=Color3.fromRGB(40,0,80),
	},
	["Void Watcher"] = {
		Name="Void Watcher", Level=40, Health=2200, Damage=180, Speed=8,
		AggroRange=50, AttackRange=12, AttackCooldown=2.5, ExpReward=3200, GoldReward=1200, CanFly=true,
		Size=Vector3.new(8,8,8), Color=Color3.fromRGB(15,0,30),
	},
	-- 🟡 Starter Island — Rare Boss
	["Brainrot God Lucky Block"] = {
		Name="Brainrot God Lucky Block", Level=50, Health=5000, Damage=150, Speed=8,
		AggroRange=40, AttackRange=10, AttackCooldown=3, ExpReward=5000, GoldReward=2000,
		Size=Vector3.new(6,6,6), Color=Color3.fromRGB(255,215,0),
	},
}
function MonstersConfig.GetMonster(name) return MonstersConfig.MONSTERS[name] end
return MonstersConfig
