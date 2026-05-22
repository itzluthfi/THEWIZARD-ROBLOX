local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TakeQuestRemote = Instance.new("RemoteEvent")
TakeQuestRemote.Name = "TakeQuest"
TakeQuestRemote.Parent = RemoteEvents

local CompleteQuestRemote = Instance.new("RemoteEvent")
CompleteQuestRemote.Name = "CompleteQuest"
CompleteQuestRemote.Parent = RemoteEvents

local QuestsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("QuestsConfig"))
local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))

local QuestService = {}

function QuestService.AcceptQuest(player, questId)
	local data = DataManager.Get(player)
	if not data then return end
	
	local quest = QuestsConfig.GetQuest(questId)
	if not quest then return end
	
	if data.Level < quest.LevelReq then return end
	
	-- Check if already has quest
	for _, q in ipairs(data.ActiveQuests or {}) do
		if q.Id == questId then return end
	end
	
	local activeQuests = data.ActiveQuests or {}
	table.insert(activeQuests, {Id = questId, Progress = 0})
	DataManager.Update(player, "ActiveQuests", activeQuests)
	
	print("[QuestService] " .. player.Name .. " accepted " .. quest.Name)
end

function QuestService.UpdateProgress(player, target)
	local data = DataManager.Get(player)
	if not data or not data.ActiveQuests then return end
	
	local quests = data.ActiveQuests
	local updated = false
	
	for i, q in ipairs(quests) do
		local questConfig = QuestsConfig.GetQuest(q.Id)
		if questConfig and questConfig.Target == target then
			q.Progress = q.Progress + 1
			updated = true
			
			if q.Progress >= questConfig.Amount then
				print("[QuestService] " .. player.Name .. " completed " .. questConfig.Name)
				QuestService.CompleteQuest(player, i)
			end
		end
	end
	
	if updated then
		DataManager.Update(player, "ActiveQuests", quests)
	end
end

function QuestService.CompleteQuest(player, index)
	local data = DataManager.Get(player)
	local questEntry = data.ActiveQuests[index]
	local questConfig = QuestsConfig.GetQuest(questEntry.Id)
	
	-- Rewards
	DataManager.Update(player, "Gold", data.Gold + questConfig.Rewards.Gold)
	DataManager.Update(player, "XP", data.XP + questConfig.Rewards.XP)
	
	-- Remove from active
	table.remove(data.ActiveQuests, index)
	DataManager.Update(player, "ActiveQuests", data.ActiveQuests)
	
	CompleteQuestRemote:FireClient(player, questConfig.Name, questConfig.Rewards)
end

TakeQuestRemote.OnServerEvent:Connect(QuestService.AcceptQuest)

return QuestService
