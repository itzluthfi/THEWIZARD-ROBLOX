local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Store = DataStoreService:GetDataStore("TheWizard_PlayerData_v5")
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local UpdateData = Remotes:WaitForChild("UpdateData")
local SyncData = Remotes:WaitForChild("SyncData")
local GetData = Remotes.Functions:WaitForChild("GetPlayerData")

local DataManager = {}
local session = {}

local DEFAULT = {
	DataVersion = 5,
	Level = 1, XP = 0, XPToNext = 100,
	Gold = 100, Mana = 100, MaxMana = 100,
	Inventory = {}, UnlockedSpells = {}, EquippedSpells = {},
	UnlockedWeapons = {},
	ActiveQuests = {}, FreeSpins = 5, StatPoints = 0,
	Stats = {Health = 0, Magic = 0, Mana = 0, Speed = 0, Cooldown = 0},
}

local function copy(v)
	if type(v) ~= "table" then return v end
	local t = {}
	for k, x in pairs(v) do t[k] = copy(x) end
	return t
end

local function normalize(data)
	if type(data) ~= "table" or data.DataVersion ~= DEFAULT.DataVersion then
		data = copy(DEFAULT)
	end
	for k, v in pairs(DEFAULT) do
		if data[k] == nil then data[k] = copy(v) end
	end
	data.UnlockedSpells = data.UnlockedSpells or {}
	data.EquippedSpells = data.EquippedSpells or {}
	data.UnlockedWeapons = data.UnlockedWeapons or {}
	data.Inventory = data.Inventory or {}
	data.Stats = data.Stats or copy(DEFAULT.Stats)
	for k, v in pairs(DEFAULT.Stats) do
		if data.Stats[k] == nil then data.Stats[k] = v end
	end
	data.MaxMana = 100 + ((data.Stats.Magic or 0) * 10) + ((data.Stats.Mana or 0) * 15)
	data.Mana = math.clamp(data.Mana or data.MaxMana, 0, data.MaxMana)
	data.XPToNext = data.XPToNext or 100
	return data
end

function DataManager.Get(player) return session[player] end

function DataManager.Sync(player)
	if session[player] then SyncData:FireClient(player, session[player]) end
end

function DataManager.Update(player, key, value)
	local data = session[player]
	if not data then return end
	data[key] = value
	UpdateData:FireClient(player, key, value)
	SyncData:FireClient(player, data)
end

function DataManager.ApplyCharacterStats(player)
	local data = session[player]
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not data or not hum then return end
	local stats = data.Stats or DEFAULT.Stats
	hum.MaxHealth = 100 + ((stats.Health or 0) * 20)
	hum.Health = math.min(hum.Health > 0 and hum.Health or hum.MaxHealth, hum.MaxHealth)
	hum.WalkSpeed = 16 + ((stats.Speed or 0) * 1.5)
end

function DataManager.AddXP(player, amount)
	local data = session[player]
	if not data then return end
	data.XP += amount
	local leveledUp = false
	while data.XP >= data.XPToNext do
		data.XP -= data.XPToNext
		data.Level += 1
		data.StatPoints += 1
		data.XPToNext = math.floor(100 * (data.Level ^ 1.35))
		leveledUp = true
	end
	
	if leveledUp then
		-- Restore Health & Mana to maximum as reward
		data.Mana = data.MaxMana or (100 + (data.Stats.Mana or 0) * 15)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = hum.MaxHealth end

		-- Level Up Visual Effects (Golden light pillar, expanding shockwave ring, floating text)
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			task.spawn(function()
				-- 1. Golden Light Pillar
				local beam = Instance.new("Part")
				beam.Name = "LevelUpBeam"
				beam.Size = Vector3.new(6, 16, 6)
				beam.Position = root.Position
				beam.Color = Color3.fromRGB(255, 215, 0)
				beam.Material = Enum.Material.Neon
				beam.Transparency = 0.5
				beam.Anchored = true
				beam.CanCollide = false
				beam.Parent = workspace

				-- 2. Expanding Gold Shockwave Ring
				local ring = Instance.new("Part")
				ring.Name = "LevelUpRing"
				ring.Shape = Enum.PartType.Cylinder
				ring.Size = Vector3.new(0.5, 1, 1)
				ring.Color = Color3.fromRGB(255, 230, 100)
				ring.Material = Enum.Material.Neon
				ring.Transparency = 0.3
				ring.Anchored = true
				ring.CanCollide = false
				ring.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.pi / 2)
				ring.Parent = workspace

				-- 3. Floating Text
				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.new(0, 240, 0, 50)
				billboard.StudsOffset = Vector3.new(0, 4, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = root

				local text = Instance.new("TextLabel")
				text.Size = UDim2.new(1, 0, 1, 0)
				text.BackgroundTransparency = 1
				text.Text = "LEVEL UP! ✨"
				text.TextColor3 = Color3.fromRGB(255, 215, 0)
				text.TextStrokeColor3 = Color3.fromRGB(100, 50, 0)
				text.TextStrokeTransparency = 0.1
				text.Font = Enum.Font.GothamBold
				text.TextSize = 28
				text.Parent = billboard

				local ts = game:GetService("TweenService")
				ts:Create(beam, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(20, 0.1, 0.1),
					Transparency = 1
				}):Play()

				ts:Create(ring, TweenInfo.new(1.2, Enum.EasingStyle.OutQuad), {
					Size = Vector3.new(0.1, 20, 20),
					Transparency = 1
				}):Play()

				ts:Create(billboard, TweenInfo.new(1.5, Enum.EasingStyle.OutQuad), {
					StudsOffset = Vector3.new(0, 8, 0)
				}):Play()

				ts:Create(text, TweenInfo.new(1.5, Enum.EasingStyle.OutQuad), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()

				task.delay(1.5, function()
					beam:Destroy()
					ring:Destroy()
					billboard:Destroy()
				end)
			end)
		end
	end
	DataManager.Sync(player)
end

function DataManager.AddGold(player, amount)
	local data = session[player]
	if not data then return end
	data.Gold += amount
	DataManager.Sync(player)
end

function DataManager.SpendMana(player, amount)
	local data = session[player]
	if not data or data.Mana < amount then return false end
	data.Mana -= amount
	UpdateData:FireClient(player, "Mana", data.Mana)
	SyncData:FireClient(player, data)
	return true
end

function DataManager.Load(player)
	local key = "player_" .. player.UserId
	local success, val = pcall(function() return Store:GetAsync(key) end)
	local data = normalize(success and val)
	session[player] = data
	DataManager.Sync(player)
	DataManager.ApplyCharacterStats(player)
	
	-- Regenerate mana mechanism (recovers mana over time)
	task.spawn(function()
		while Players:GetPlayerByUserId(player.UserId) do
			task.wait(1)
			local d = session[player]
			if d and d.Mana < d.MaxMana then
				-- Regenerate 2 mana + additional based on Magic attribute
				local regen = 2 + ((d.Stats.Magic or 0) * 0.4)
				d.Mana = math.min(d.Mana + regen, d.MaxMana)
				UpdateData:FireClient(player, "Mana", d.Mana)
				SyncData:FireClient(player, d)
			end
		end
	end)
end

function DataManager.Save(player)
	local data = session[player]
	if not data then return end
	local key = "player_" .. player.UserId
	pcall(function() Store:SetAsync(key, data) end)
end

Players.PlayerAdded:Connect(DataManager.Load)
Players.PlayerRemoving:Connect(function(p)
	DataManager.Save(p)
	session[p] = nil
end)
game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do DataManager.Save(p) end
end)

GetData.OnServerInvoke = function(player)
	if not session[player] then DataManager.Load(player) end
	return session[player]
end

return DataManager
