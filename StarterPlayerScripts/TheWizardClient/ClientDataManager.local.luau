--[[
	ClientDataManager.lua
	Client-side data management for TheWizard game
	Handles data requests, synchronization, and local caching
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- Remote Events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local GetDataEvent = RemoteEvents.Functions:WaitForChild("GetPlayerData")
local UpdateDataEvent = RemoteEvents:WaitForChild("UpdateData")
local SyncDataEvent = RemoteEvents:WaitForChild("SyncData")
local RequestSaveEvent = RemoteEvents:WaitForChild("RequestSave")
local LevelUpEvent = RemoteEvents:WaitForChild("LevelUp")

-- Remote Functions (Verify folder existence)
local FunctionsFolder = RemoteEvents:FindFirstChild("Functions")
local GetPlayerDataFunction = FunctionsFolder and FunctionsFolder:FindFirstChild("GetPlayerData")
local PurchaseItemFunction = FunctionsFolder and FunctionsFolder:FindFirstChild("PurchaseItem")
local UnlockSpellFunction = FunctionsFolder and FunctionsFolder:FindFirstChild("UnlockSpell")
local UnlockIslandFunction = FunctionsFolder and FunctionsFolder:FindFirstChild("UnlockIsland")

-- ClientDataManager Module
local ClientDataManager = {}

-- Local data cache
local playerData = nil
local dataLoaded = false
local onDataLoadedCallbacks = {}

-- Get cached player data
function ClientDataManager.GetData()
	return playerData
end

-- Get specific field from data
function ClientDataManager.GetField(field)
	if playerData and playerData[field] ~= nil then
		return playerData[field]
	end
	return nil
end

-- Update local data and sync to server
function ClientDataManager.UpdateData(field, value)
	if playerData then
		playerData[field] = value
		UpdateDataEvent:FireServer(field, value)
	end
end

-- Request data from server
function ClientDataManager.RequestData()
	GetDataEvent:InvokeServer()
end

-- Request manual save
function ClientDataManager.RequestSave()
	RequestSaveEvent:FireServer()
end

-- Purchase item
function ClientDataManager.PurchaseItem(itemId, price, currencyType)
	if PurchaseItemFunction then
		local success, message = PurchaseItemFunction:InvokeServer(itemId, price, currencyType)
		return success, message
	end
	return false, "RemoteFunction not found"
end

-- Unlock spell
function ClientDataManager.UnlockSpell(spellName)
	if UnlockSpellFunction then
		local success, message = UnlockSpellFunction:InvokeServer(spellName)
		return success, message
	end
	return false, "RemoteFunction not found"
end

-- Unlock island
function ClientDataManager.UnlockIsland(islandName)
	if UnlockIslandFunction then
		local success, message = UnlockIslandFunction:InvokeServer(islandName)
		return success, message
	end
	return false, "RemoteFunction not found"
end

-- Check if data is loaded
function ClientDataManager.IsDataLoaded()
	return dataLoaded
end

-- Register callback for when data is loaded
function ClientDataManager.OnDataLoaded(callback)
	if dataLoaded then
		callback(playerData)
	else
		table.insert(onDataLoadedCallbacks, callback)
	end
end

-- Getters
function ClientDataManager.GetLevel() return playerData and playerData.Level or 1 end
function ClientDataManager.GetExperience() return playerData and (playerData.Experience or playerData.XP) or 0 end
function ClientDataManager.GetGold() return playerData and playerData.Gold or 0 end
function ClientDataManager.GetHealth() return playerData and playerData.Health or 100 end
function ClientDataManager.GetMana() return playerData and playerData.Mana or 100 end

-- Handle data sync from server
SyncDataEvent.OnClientEvent:Connect(function(data)
	playerData = data
	dataLoaded = true
	
	for _, callback in ipairs(onDataLoadedCallbacks) do
		callback(playerData)
	end
	onDataLoadedCallbacks = {}
	
	print("[ClientDataManager] Data synced")
end)

-- Request initial data
task.wait(1)
GetDataEvent:InvokeServer()

return ClientDataManager
