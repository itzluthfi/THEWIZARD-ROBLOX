local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonstersConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MonstersConfig"))
local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))

local MobService = {}

local function part(name, size, color, pos, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = false
	p.CanCollide = true
	p.Parent = parent
	return p
end

local function weld(a, b)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = a
end

local function billboard(root, monster)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 160, 0, 54)
	gui.StudsOffset = Vector3.new(0, math.max(monster.Size.Y, 3) + 2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = root
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.BackgroundTransparency = 1
	title.Text = "Lv. " .. monster.Level .. " " .. (monster.Name or "Monster")
	title.TextColor3 = Color3.new(1,1,1)
	title.TextStrokeTransparency = 0.2
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 15
	title.Parent = gui
	local bg = Instance.new("Frame")
	bg.Position = UDim2.new(0.08, 0, 0, 32)
	bg.Size = UDim2.new(0.84, 0, 0, 10)
	bg.BackgroundColor3 = Color3.fromRGB(35,35,35)
	bg.BorderSizePixel = 0
	bg.Parent = gui
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(210,40,40)
	fill.BorderSizePixel = 0
	fill.Parent = bg
	return fill
end

function MobService.SpawnMonster(monsterName, position, parent)
	local monster = MonstersConfig.GetMonster(monsterName) or {
		Name = monsterName, Level = 5, Health = 100, Damage = 10, Speed = 10,
		AggroRange = 25, AttackRange = 5, AttackCooldown = 2, ExpReward = 20, GoldReward = 10,
		Size = Vector3.new(3, 4, 3), Color = Color3.fromRGB(150, 150, 150)
	}

	local model = nil
	local template = nil
	local storage = game:GetService("ServerStorage")
	local repStorage = game:GetService("ReplicatedStorage")

	-- Check ServerStorage.Monsters or ReplicatedStorage.Monsters for custom Models
	local monsterFolder = storage:FindFirstChild("Monsters") or repStorage:FindFirstChild("Monsters")
	if monsterFolder then
		template = monsterFolder:FindFirstChild(monsterName)
	end

	local root = nil

	if template and template:IsA("Model") then
		model = template:Clone()
		model.Name = monsterName

		-- Rename the primary part or main part to HumanoidRootPart for proper physics/AI
		root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("Part")
		if root then
			root.Name = "HumanoidRootPart"
			model.PrimaryPart = root
		else
			warn("[MobService] Custom model " .. monsterName .. " has no valid Root Part! Falling back to procedural.")
			model:Destroy()
			model = nil
		end

		if model then
			-- Detect if it already has joint constraints or motor systems
			local hasRig = false
			for _, desc in ipairs(model:GetDescendants()) do
				if desc:IsA("JointInstance") or desc:IsA("WeldConstraint") or desc:IsA("Bone") then
					hasRig = true
					break
				end
			end

			-- Unanchor all parts so they can roam, and weld them dynamically if not pre-rigged
			for _, desc in ipairs(model:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Anchored = false
					if desc == root then
						desc.CanCollide = true
					else
						-- Non-collidable default parts to avoid physics clutter, but welded to root
						desc.CanCollide = false
						if not hasRig then
							local w = Instance.new("WeldConstraint")
							w.Part0 = root
							w.Part1 = desc
							w.Parent = root
						end
					end
				end
			end
		end
	end

	-- Procedural Model fallback
	if not model then
		model = Instance.new("Model")
		model.Name = monsterName

		root = part("HumanoidRootPart", monster.Size, monster.Color, position + Vector3.new(0, monster.Size.Y / 2, 0), model)
		root.Material = Enum.Material.Neon
		model.PrimaryPart = root

		if monster.CanFly or monsterName:find("Bat") or monsterName:find("Bird") then
			local l = part("LeftWing", Vector3.new(monster.Size.X * 1.8, 0.2, monster.Size.Z), monster.Color, root.Position + Vector3.new(-monster.Size.X, 0, 0), model)
			local r = part("RightWing", Vector3.new(monster.Size.X * 1.8, 0.2, monster.Size.Z), monster.Color, root.Position + Vector3.new(monster.Size.X, 0, 0), model)
			weld(root, l)
			weld(root, r)
		elseif monsterName:find("Wolf") then
			local h = part("Head", Vector3.new(monster.Size.X * .7, monster.Size.Y * .5, monster.Size.Z * .4), monster.Color, root.Position + Vector3.new(0, .2, -monster.Size.Z * .55), model)
			weld(root, h)
		elseif monsterName:find("Golem") or monsterName:find("Giant") or monsterName:find("Treant") then
			local h = part("Head", Vector3.new(monster.Size.X * .7, monster.Size.Y * .35, monster.Size.Z * .7), monster.Color, root.Position + Vector3.new(0, monster.Size.Y * .65, 0), model)
			weld(root, h)
		end
	end

	model:SetAttribute("IsMonster", true)
	model:SetAttribute("Level", monster.Level)
	model:SetAttribute("ExpReward", monster.ExpReward or 10)
	model:SetAttribute("GoldReward", monster.GoldReward or 5)

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then
		hum = Instance.new("Humanoid")
		hum.Parent = model
	end

	hum.MaxHealth = monster.Health
	hum.Health = monster.Health
	hum.WalkSpeed = monster.Speed or 8
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	-- Automatically set the HipHeight to prevent the custom model from sinking or falling through
	if hum.HipHeight == 0 then
		hum.HipHeight = math.max(root.Size.Y / 2, 1.5)
	end

	-- Teleport root part above ground using computed HipHeight
	root.CFrame = CFrame.new(position.X, position.Y + hum.HipHeight + root.Size.Y / 2 + 0.5, position.Z)

	-- Play a beautiful Neon Cyan Spawn Beam at the monster's spawn location
	task.spawn(function()
		local beam = Instance.new("Part")
		beam.Name = "SpawnBeam"
		beam.Size = Vector3.new(4, 18, 4)
		beam.Position = position + Vector3.new(0, 9, 0)
		beam.Color = Color3.fromRGB(50, 220, 255)
		beam.Material = Enum.Material.Neon
		beam.Transparency = 0.4
		beam.Anchored = true
		beam.CanCollide = false
		beam.Parent = workspace

		local ts = game:GetService("TweenService")
		ts:Create(beam, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 18, 0.1),
			Transparency = 1
		}):Play()
		task.delay(1.0, function()
			beam:Destroy()
		end)
	end)

	local fill = billboard(root, monster)
	hum:GetPropertyChangedSignal("Health"):Connect(function()
		fill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
	end)

	hum.Died:Connect(function()
		local player = Players:GetPlayerByUserId(model:GetAttribute("LastHitUserId") or 0)
		if player then
			DataManager.AddXP(player, monster.ExpReward or 10)
			DataManager.AddGold(player, monster.GoldReward or 5)
		end
		task.delay(2, function() if model then model:Destroy() end end)
	end)

	model.Parent = parent or workspace

	-- AI Loop
	task.spawn(function()
		while model.Parent and hum.Health > 0 do
			local target, distance
			for _, player in ipairs(Players:GetPlayers()) do
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local ph = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hrp and ph and ph.Health > 0 then
					local d = (hrp.Position - root.Position).Magnitude
					if d <= (monster.AggroRange or 25) and (not distance or d < distance) then target, distance = player, d end
				end
			end
			if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
				hum:MoveTo(target.Character.HumanoidRootPart.Position)
				local th = target.Character:FindFirstChildOfClass("Humanoid")
				if th and distance and distance <= (monster.AttackRange or 5) then
					th:TakeDamage(monster.Damage or 5)
					task.wait(monster.AttackCooldown or 2)
				end
			elseif (monster.Speed or 0) > 0 and math.random() < .25 then
				hum:MoveTo(root.Position + Vector3.new(math.random(-20,20), 0, math.random(-20,20)))
			end
			task.wait(.5)
		end
	end)

	return model
end

return MobService
