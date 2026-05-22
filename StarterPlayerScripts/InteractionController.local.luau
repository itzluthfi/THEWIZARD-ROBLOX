local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local pgui = player:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TakeQuestRemote = RemoteEvents:WaitForChild("TakeQuest")
local BuyItemRemote = RemoteEvents:WaitForChild("BuyItem")

local QuestsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("QuestsConfig"))
local ShopConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ShopConfig"))

-- Simple UI Construction
local function createMenu(title)
	local sg = Instance.new("ScreenGui")
	sg.Name = title.."Gui"
	sg.Enabled = false
	sg.Parent = pgui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 400)
	frame.Position = UDim2.new(0.5, -150, 0.5, -200)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.Parent = sg
	
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 40)
	t.Text = title
	t.TextColor3 = Color3.new(1, 1, 1)
	t.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	t.Parent = frame
	
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -30, 0, 0)
	close.Text = "X"
	close.BackgroundColor3 = Color3.new(1, 0, 0)
	close.Parent = frame
	close.MouseButton1Click:Connect(function() sg.Enabled = false end)
	
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -50)
	scroll.Position = UDim2.new(0, 5, 0, 45)
	scroll.BackgroundTransparency = 1
	scroll.Parent = frame
	
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 5)
	list.Parent = scroll
	
	return sg, scroll
end

local questGui, questScroll = createMenu("Quest")
local shopGui, shopScroll = createMenu("Shop")

-- Populate Quest
for id, data in pairs(QuestsConfig.QUESTS) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 50)
	btn.Text = data.Name .. "\n[Req Lv."..data.LevelReq.."]"
	btn.Parent = questScroll
	btn.MouseButton1Click:Connect(function()
		TakeQuestRemote:FireServer(id)
		questGui.Enabled = false
	end)
end

-- Populate Shop
for id, data in pairs(ShopConfig.ITEMS) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 50)
	btn.Text = data.Name .. " - " .. data.Price .. " Gold"
	btn.Parent = shopScroll
	btn.MouseButton1Click:Connect(function()
		BuyItemRemote:FireServer(id)
	end)
end

-- Interaction
mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target and target.Parent then
		local npcType = target:GetAttribute("Type")
		if npcType == "QuestGiver" then
			questGui.Enabled = true
		elseif npcType == "Merchant" then
			shopGui.Enabled = true
		end
	end
end)
