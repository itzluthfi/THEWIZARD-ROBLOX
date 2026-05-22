local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BuyItemRemote = Instance.new("RemoteEvent")
BuyItemRemote.Name = "BuyItem"
BuyItemRemote.Parent = RemoteEvents

local ShopConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ShopConfig"))
local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))

local ShopService = {}

function ShopService.HandlePurchase(player, itemId)
	local data = DataManager.Get(player)
	if not data then return end
	
	local itemConfig = ShopConfig.ITEMS[itemId]
	if not itemConfig then return end
	
	if data.Gold < itemConfig.Price then return end
	
	-- Handle different types
	if itemConfig.Type == "Spell" then
		-- Check if already unlocked
		local alreadyHas = false
		for _, s in ipairs(data.UnlockedSpells) do
			if s == itemId then
				alreadyHas = true; break
			end
		end
		
		if not alreadyHas then
			DataManager.Update(player, "Gold", data.Gold - itemConfig.Price)
			local unlocked = data.UnlockedSpells
			table.insert(unlocked, itemId)
			DataManager.Update(player, "UnlockedSpells", unlocked)
			print("[ShopService] " .. player.Name .. " bought spell: " .. itemId)
		end
		
	elseif itemConfig.Type == "Potion" then
		DataManager.Update(player, "Gold", data.Gold - itemConfig.Price)
		-- Add to inventory logic here
		local inv = data.Inventory or {}
		table.insert(inv, itemId)
		DataManager.Update(player, "Inventory", inv)
		print("[ShopService] " .. player.Name .. " bought potion: " .. itemId)
	end
end

BuyItemRemote.OnServerEvent:Connect(ShopService.HandlePurchase)

return ShopService
