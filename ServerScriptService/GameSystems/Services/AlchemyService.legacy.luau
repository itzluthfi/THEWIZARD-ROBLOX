local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local AlchemyService = {}

-- Basic recipes for testing
local RECIPES = {
	HealthPotion = {
		Ingredients = { RedHerb = 2, Water = 1 },
		Result = "Health Potion"
	},
	ManaPotion = {
		Ingredients = { BlueHerb = 2, Water = 1 },
		Result = "Mana Potion"
	}
}

function AlchemyService.Craft(player, recipeName)
	local recipe = RECIPES[recipeName]
	if not recipe then return end
	
	local data = DataManager.Get(player)
	if not data then return end
	
	-- Check ingredients
	for item, count in pairs(recipe.Ingredients) do
		local currentCount = data.Inventory[item] or 0
		if currentCount < count then
			print("[AlchemyService] Missing " .. item)
			return
		end
	end
	
	-- Consume ingredients
	local newInventory = table.clone(data.Inventory)
	for item, count in pairs(recipe.Ingredients) do
		newInventory[item] -= count
	end
	
	-- Add result
	newInventory[recipe.Result] = (newInventory[recipe.Result] or 0) + 1
	
	DataManager.Update(player, "Inventory", newInventory)
	print("[AlchemyService] " .. player.Name .. " crafted " .. recipe.Result)
end

-- Hook up RemoteEvents if any for Alchemy specifically, 
-- but for now we'll use generic ItemPicked if needed or new ones if created later.

return AlchemyService
