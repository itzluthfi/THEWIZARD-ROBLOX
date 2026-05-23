--[[ AdminPanel UI - Client-side admin panel for testing
     Toggle with Ctrl+Shift+A or /admin in chat
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Remotes = RS:WaitForChild("RemoteEvents")
local AdminRemote = Remotes:WaitForChild("AdminCommand")

-- Declare gui HERE — single shared upvalue for ALL closures
local gui = nil
local isOpen = false

local function createAdminPanel()
	if gui then gui:Destroy() end

	gui = Instance.new("ScreenGui")
	gui.Name = "AdminPanel"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 400, 0, 350)
	panel.Position = UDim2.new(0.5, -200, 0.5, -175)
	panel.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke", panel)
	stroke.Color = Color3.fromRGB(80, 80, 120)
	stroke.Thickness = 2

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "⚙️ Admin Panel"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = panel

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = panel
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	closeBtn.MouseButton1Click:Connect(function()
		gui.Enabled = false
		isOpen = false
	end)

	local commands = {
		{name = "Add Gold", cmd = "addgold", args = "1000"},
		{name = "Add XP", cmd = "addxp", args = "500"},
		{name = "Add Spins", cmd = "addspin", args = "5"},
		{name = "Set Level", cmd = "setlevel", args = "10"},
		{name = "Unlock All", cmd = "unlockall", args = ""},
		{name = "Heal", cmd = "heal", args = ""},
		{name = "Spawn Mob", cmd = "spawnmob", args = "TestSlime 3"},
	}

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -20, 1, -100)
	list.Position = UDim2.new(0, 10, 0, 50)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 6
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = list

	local resultLabel = Instance.new("TextLabel")
	resultLabel.Size = UDim2.new(1, 0, 0, 40)
	resultLabel.Position = UDim2.new(0, 10, 1, -45)
	resultLabel.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
	resultLabel.TextColor3 = Color3.new(1, 1, 1)
	resultLabel.Font = Enum.Font.Gotham
	resultLabel.TextSize = 11
	resultLabel.TextWrapped = true
	resultLabel.Parent = panel
	Instance.new("UICorner", resultLabel).CornerRadius = UDim.new(0, 6)

	for i, cmdInfo in ipairs(commands) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 40)
		btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
		btn.Text = cmdInfo.name .. " (" .. cmdInfo.cmd .. " " .. cmdInfo.args .. ")"
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.Parent = list
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		btn.MouseButton1Click:Connect(function()
			local args = {}
			if cmdInfo.args ~= "" then
				for arg in cmdInfo.args:gmatch("%S+") do
					local num = tonumber(arg)
					table.insert(args, num or arg)
				end
			end
			AdminRemote:FireServer(cmdInfo.cmd, args)
		end)
	end

	return gui
end

-- Toggle admin panel
local function toggleAdmin()
	if not gui then
		gui = createAdminPanel()
	end
	isOpen = not isOpen
	gui.Enabled = isOpen
end

-- Listen for admin responses
AdminRemote.OnClientEvent:Connect(function(success, message)
	if not gui then
		toggleAdmin()  -- create panel on first server response
	end
	-- Re-check gui in case toggleAdmin failed
	if not gui then return end
	local result = gui:FindFirstChildWhichIsA("TextLabel")
	if result and message then
		result.Text = success and "✅ " .. message or "❌ " .. message
	end
end)

-- Keyboard shortcut: Ctrl+Shift+A
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.A and
	   UIS:IsKeyDown(Enum.KeyCode.LeftControl) and
	   UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
		toggleAdmin()
	end
end)

print("[AdminPanel] Press Ctrl+Shift+A to open Admin Panel")
print("[AdminPanel] Or type /admin [command] in chat")