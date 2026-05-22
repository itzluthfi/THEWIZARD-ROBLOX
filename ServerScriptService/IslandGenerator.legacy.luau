local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IslandsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("IslandsConfig"))

local palettes = {
	Plains  = {Color=Color3.fromRGB(75,155,75),   Material=Enum.Material.Grass,        Base=Vector3.new(280,18,280), Height=18},
	Forest  = {Color=Color3.fromRGB(34,125,34),   Material=Enum.Material.Grass,        Base=Vector3.new(270,22,270), Height=22},
	Volcano = {Color=Color3.fromRGB(48,22,22),    Material=Enum.Material.Basalt,       Base=Vector3.new(290,26,290), Height=26, Volcano=true},
	Ice     = {Color=Color3.fromRGB(195,225,250), Material=Enum.Material.Glacier,      Base=Vector3.new(260,20,260), Height=20, Ice=true},
	Void    = {Color=Color3.fromRGB(18,0,32),     Material=Enum.Material.Rock,         Base=Vector3.new(280,18,280), Height=18, Void=true},
	Swamp   = {Color=Color3.fromRGB(55,72,55),    Material=Enum.Material.Mud,          Base=Vector3.new(260,16,260), Height=16, Swamp=true},
	Default = {Color=Color3.fromRGB(140,140,140), Material=Enum.Material.Rock,         Base=Vector3.new(260,18,260), Height=18},
}
local function pal(theme) return palettes[theme] or palettes.Default end

local function addLabel(parent, text, offset, color)
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.new(0,240,0,60)
	b.StudsOffset = offset
	b.AlwaysOnTop = true
	b.Parent = parent
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1,0,1,0)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or Color3.new(1,1,1)
	t.TextStrokeTransparency = 0.2
	t.Font = Enum.Font.GothamBold
	t.TextSize = 22
	t.Parent = b
end

local function makeNPC(parent, surfY, ix, iz, name, kind, ox, oz, color)
	local glow = Instance.new("Part")
	glow.Name = name .. "_Glow"
	glow.Size = Vector3.new(10, 0.4, 10)
	glow.Position = Vector3.new(ix + ox, surfY + 0.1, iz + oz)
	glow.Anchored = true
	glow.CanCollide = true
	glow.Color = kind == "QuestGiver" and Color3.fromRGB(255,200,50) or Color3.fromRGB(50,200,255)
	glow.Material = Enum.Material.Neon
	glow.Parent = parent

	local npc = Instance.new("Part")
	npc.Name = name
	npc.Anchored = true
	npc.CanCollide = true
	npc.Size = Vector3.new(3, 5, 3)
	npc.Color = color
	npc.Material = Enum.Material.SmoothPlastic
	npc:SetAttribute("Type", kind)
	npc.Position = Vector3.new(ix + ox, surfY + 2.7, iz + oz)
	npc.Parent = parent

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(2, 2, 2)
	head.Color = Color3.fromRGB(240, 200, 180)
	head.Position = npc.Position + Vector3.new(0, 3.6, 0)
	head.Anchored = true
	head.Parent = npc

	local lc = kind == "QuestGiver" and Color3.fromRGB(255,230,80) or Color3.fromRGB(80,230,230)
	addLabel(npc, name .. "\n[" .. kind .. "]", Vector3.new(0,5.5,0), lc)
end

-- cleanup old parts
for _, n in ipairs({"Ocean","OceanFloor"}) do
	local old = workspace:FindFirstChild(n)
	if old then old:Destroy() end
end

-- Beautiful translucent Ocean
local ocean = Instance.new("Part")
ocean.Name = "Ocean"
ocean.Size = Vector3.new(6000, 6, 6000)
ocean.Position = Vector3.new(0, -1, 0)
ocean.Anchored = true
ocean.CanCollide = false
ocean.Color = Color3.fromRGB(24, 110, 195)
ocean.Material = Enum.Material.Glass
ocean.Transparency = 0.35
ocean.Reflectance = 0.15
ocean.CastShadow = false
ocean.Parent = workspace

local floor = Instance.new("Part")
floor.Name = "OceanFloor"
floor.Size = Vector3.new(6000, 2, 6000)
floor.Position = Vector3.new(0, -40, 0)
floor.Anchored = true
floor.CanCollide = true
floor.Color = Color3.fromRGB(15, 30, 75)
floor.Material = Enum.Material.Slate
floor.Parent = workspace

-- Detect any baseplate / black box in workspace (placed at center) to build stairs dynamically
local blackBox = nil
for _, item in ipairs(workspace:GetChildren()) do
	if item:IsA("BasePart") and item.Name ~= "Terrain" and item.Name ~= "Ocean" and item.Name ~= "OceanFloor" then
		if (item.Position - Vector3.new(0, item.Position.Y, 0)).Magnitude < 150 then
			if item.Size.X > 50 and item.Size.Z > 50 then
				blackBox = item
				break
			end
		end
	end
end

for islandId, data in pairs(IslandsConfig.GetAllIslands()) do
	local old = workspace:FindFirstChild(islandId)
	if old then old:Destroy() end
	local p = pal(data.Theme)
	local folder = Instance.new("Folder")
	folder.Name = islandId
	folder.Parent = workspace

	-- Generate organic looking island layout using a main center base and surrounding edge parts
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = p.Base
	base.Position = Vector3.new(data.Position.X, 6 - p.Height / 2, data.Position.Z)
	base.Anchored = true
	base.CanCollide = true
	base.Color = p.Color
	base.Material = p.Material
	base.Parent = folder

	local surfY = base.Position.Y + base.Size.Y / 2
	addLabel(base, data.Name, Vector3.new(0, p.Height + 12, 0))

	for _, childName in ipairs({"Buildings","Resources","NPCs","Monsters"}) do
		local f = Instance.new("Folder")
		f.Name = childName
		f.Parent = folder
	end

	-- Add organic side pieces
	for i = 1, 4 do
		local side = Instance.new("Part")
		side.Size = Vector3.new(p.Base.X * 0.4, p.Base.Y * 0.9, p.Base.Z * 0.4)
		local angle = (i / 4) * math.pi * 2
		local radius = p.Base.X * 0.45
		side.Position = base.Position + Vector3.new(math.cos(angle) * radius, -p.Base.Y * 0.05, math.sin(angle) * radius)
		side.Anchored = true
		side.CanCollide = true
		side.Color = p.Color
		side.Material = p.Material
		side.Parent = folder
	end

	-- Procedural stairs for the black box / baseplate on StarterIsland
	if islandId == "StarterIsland" and blackBox then
		local bBox = blackBox
		local bPos = bBox.Position
		local bSize = bBox.Size
		local topY = bPos.Y + bSize.Y / 2
		local bottomY = surfY
		local height = topY - bottomY
		
		if height > 1 then
			local stepsCount = math.ceil(height / 1.5)
			local stepWidth = 24
			local stepDepth = 2.5
			
			local stairsFolder = Instance.new("Folder")
			stairsFolder.Name = "Stairs"
			stairsFolder.Parent = folder
			
			-- Front & Back stairs (Z axis)
			for _, side in ipairs({1, -1}) do
				for i = 1, stepsCount do
					local step = Instance.new("Part")
					step.Name = "StepZ_" .. i
					step.Anchored = true
					step.CanCollide = true
					step.Color = bBox.Color
					step.Material = bBox.Material
					
					local stepSizeY = 1.5
					local currentDepth = stepDepth * (stepsCount - i + 1)
					step.Size = Vector3.new(stepWidth, stepSizeY, currentDepth)
					
					local stepY = bottomY + (i - 0.5) * stepSizeY
					local stepZ = bPos.Z + side * (bSize.Z / 2 + currentDepth / 2)
					step.Position = Vector3.new(bPos.X, stepY - 0.75, stepZ)
					step.Parent = stairsFolder
				end
			end
			
			-- Left & Right stairs (X axis)
			for _, side in ipairs({1, -1}) do
				for i = 1, stepsCount do
					local step = Instance.new("Part")
					step.Name = "StepX_" .. i
					step.Anchored = true
					step.CanCollide = true
					step.Color = bBox.Color
					step.Material = bBox.Material
					
					local stepSizeY = 1.5
					local currentDepth = stepDepth * (stepsCount - i + 1)
					step.Size = Vector3.new(currentDepth, stepSizeY, stepWidth)
					
					local stepY = bottomY + (i - 0.5) * stepSizeY
					local stepX = bPos.X + side * (bSize.X / 2 + currentDepth / 2)
					step.Position = Vector3.new(stepX, stepY - 0.75, bPos.Z)
					step.Parent = stairsFolder
				end
			end
		end
	end

	-- Thematic terrain decorators
	if p.Volcano then
		local cone = Instance.new("Part")
		cone.Name = "LavaCone"
		cone.Size = Vector3.new(50, 40, 50)
		cone.Position = base.Position + Vector3.new(0, base.Size.Y/2 + 20, 0)
		cone.Color = Color3.fromRGB(30,12,12)
		cone.Material = Enum.Material.Basalt
		cone.Anchored = true
		cone.Parent = folder

		local lava = Instance.new("Part")
		lava.Name = "Lava"
		lava.Size = Vector3.new(38, 2, 38)
		lava.Position = cone.Position + Vector3.new(0, 19.5, 0)
		lava.Color = Color3.fromRGB(255, 60, 0)
		lava.Material = Enum.Material.Neon
		lava.Anchored = true
		lava.Parent = folder
	elseif p.Ice then
		for j = 1, 6 do
			local cry = Instance.new("Part")
			cry.Size = Vector3.new(4, math.random(10, 22), 4)
			cry.Color = Color3.fromRGB(150, 220, 255)
			cry.Material = Enum.Material.Neon
			local a = (j/6)*math.pi*2
			cry.Position = base.Position + Vector3.new(math.cos(a)*80, base.Size.Y/2 + cry.Size.Y/2, math.sin(a)*80)
			cry.Orientation = Vector3.new(math.random(-20,20), 0, math.random(-20,20))
			cry.Anchored = true
			cry.Parent = folder
		end
	elseif p.Void then
		for j = 1, 5 do
			local stone = Instance.new("Part")
			stone.Size = Vector3.new(12, 12, 12)
			stone.Color = Color3.fromRGB(75, 20, 120)
			stone.Material = Enum.Material.Glass
			local a = (j/5)*math.pi*2
			stone.Position = base.Position + Vector3.new(math.cos(a)*65, base.Size.Y/2 + 35, math.sin(a)*65)
			stone.Anchored = true
			stone.Parent = folder
			task.spawn(function()
				local t = 0
				while stone and stone.Parent do
					t += 0.05
					stone.Position = stone.Position + Vector3.new(0, math.sin(t)*0.1, 0)
					stone.Orientation = stone.Orientation + Vector3.new(0.2, 0.4, 0.1)
					task.wait()
				end
			end)
		end
	elseif p.Swamp then
		for j = 1, 4 do
			local tree = Instance.new("Part")
			tree.Size = Vector3.new(6, 30, 6)
			tree.Color = Color3.fromRGB(60, 45, 30)
			tree.Material = Enum.Material.Wood
			local a = (j/4)*math.pi*2
			tree.Position = base.Position + Vector3.new(math.cos(a)*75, base.Size.Y/2 + 15, math.sin(a)*75)
			tree.Anchored = true
			tree.Parent = folder

			local leaves = Instance.new("Part")
			leaves.Shape = Enum.PartType.Ball
			leaves.Size = Vector3.new(22, 16, 22)
			leaves.Color = Color3.fromRGB(40, 55, 30)
			leaves.Material = Enum.Material.Grass
			leaves.Position = tree.Position + Vector3.new(0, 15, 0)
			leaves.Anchored = true
			leaves.Parent = folder
		end
	end

	-- NPC Spawns (Starter Island Only - Repositioned near the shore edges of the 280x280 island)
	if islandId == "StarterIsland" then
		local edgeX = 115
		local edgeZ = 20
		makeNPC(folder.NPCs, surfY, data.Position.X, data.Position.Z, "ElderMarcus", "QuestGiver", edgeX, edgeZ, Color3.fromRGB(150,150,225))
		makeNPC(folder.NPCs, surfY, data.Position.X, data.Position.Z, "Lily", "Merchant", -edgeX, -edgeZ, Color3.fromRGB(225,150,150))
	end
	print("[IslandGenerator] Created " .. data.Name)
end
print("[IslandGenerator] Generation complete.")
