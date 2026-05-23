local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local SpellCast = Remotes:WaitForChild("SpellCast")
local SlotCooldown = Remotes:WaitForChild("SlotCooldown")
local StaffFireProjectile = Remotes:WaitForChild("StaffFireProjectile")
local SpellsConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SpellsConfig"))
local DataManager = require(ReplicatedStorage:WaitForChild("DataManagerModule"))

local SpellService = {}

local function equipped(data, spellName)
	if spellName == "Basic Shot" then return true end
	local owns = false
	for _, s in ipairs(data.UnlockedSpells or {}) do if s == spellName then owns = true break end end
	if not owns then return false end
	for _, s in pairs(data.EquippedSpells or {}) do if s == spellName then return true end end
	return false
end

local function damage(player, model, amount)
	local hum = model and model:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 and model:GetAttribute("IsMonster") then
		model:SetAttribute("LastHitUserId", player.UserId)
		hum:TakeDamage(amount)

		-- Floating Damage Text Indicator
		local root = model:FindFirstChild("HumanoidRootPart")
		if root then
			task.spawn(function()
				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.new(0, 100, 0, 40)
				-- Randomize offset slightly so multiple damage numbers don't overlap perfectly
				billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3 + math.random(-1, 1), math.random(-2, 2))
				billboard.AlwaysOnTop = true
				billboard.Parent = root

				local text = Instance.new("TextLabel")
				text.Size = UDim2.new(1, 0, 1, 0)
				text.BackgroundTransparency = 1
				text.Text = tostring(math.floor(amount))
				text.TextColor3 = Color3.fromRGB(255, 75, 75) -- Premium Red
				text.TextStrokeTransparency = 0.2
				text.Font = Enum.Font.GothamBold
				text.TextSize = 22
				text.Parent = billboard

				local ts = game:GetService("TweenService")
				local moveTween = ts:Create(billboard, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					StudsOffset = billboard.StudsOffset + Vector3.new(0, 4, 0)
				})
				local fadeTween = ts:Create(text, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				})
				moveTween:Play()
				fadeTween:Play()
				
				-- Ensure destruction with Debris Service as fallback
				game:GetService("Debris"):AddItem(billboard, 1.4)
			end)
		end
	end
end

function SpellService.Handle(player, spellName, target)
	local data = DataManager.Get(player)
	local spell = SpellsConfig.GetSpell(spellName)
	if not data or not spell or not equipped(data, spellName) then return end
	if not DataManager.SpendMana(player, spell.ManaCost or 0) then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local stats = data.Stats or {}
	local amount = (spell.Damage or 0) + ((stats.Magic or 0) * 4)

	if spell.Type == "Projectile" then
		local dir = target - root.Position
		if dir.Magnitude > 0 then
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {player.Character}
			params.FilterType = Enum.RaycastFilterType.Exclude
			local hit = workspace:Raycast(root.Position, dir.Unit * (spell.Range or 60), params)
			if hit then damage(player, hit.Instance:FindFirstAncestorOfClass("Model"), amount) end
		end
	else
		for _, model in ipairs(workspace:GetDescendants()) do
			if model:IsA("Model") and model:GetAttribute("IsMonster") then
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if hrp and (hrp.Position - root.Position).Magnitude <= (spell.Radius or 20) then
					damage(player, model, amount)
				end
			end
		end
	end

	-- Fire visual effects to ALL clients so they can render the spell animation
	SpellCast:FireAllClients(player, spellName, target)
end

SpellCast.OnServerEvent:Connect(SpellService.Handle)

-- Forward slot cooldown events to all clients so MainUI can render the overlay
-- For spells: slot is spell index (1-4 for Z,X,C,V), isSpell = true
-- For items/weapons: slot is item slot (1-4), isSpell = false
SlotCooldown.OnServerEvent:Connect(function(player, slot, duration, isSpell)
	SlotCooldown:FireAllClients(slot, duration, isSpell)
end)

-- Handle staff / weapon projectile attacks fired from the client
-- This handles BASIC ATTACK with weapon - NO weapon check needed
StaffFireProjectile.OnServerEvent:Connect(function(player, wpnName, targetPos)
	local data = DataManager.Get(player)
	if not data then return end

	-- Get the weapon from slot 4 OR default to "Basic Shot" if none equipped
	local equippedWeapon = data.EquippedSpells and data.EquippedSpells[4]
	local weaponToUse = equippedWeapon or "Basic Shot"

	local sp = SpellsConfig.GetSpell(weaponToUse)
	if not sp then return end

	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local stats = data.Stats or {}
	local amount = (sp.Damage or 15) + ((stats.Magic or 0) * 4)

	-- If target is invalid (0,0,0 or too close), find nearest monster
	local actualTarget = targetPos
	if targetPos and (targetPos.X == 0 and targetPos.Y == 0 and targetPos.Z == 0) then
		actualTarget = nil
	end

	-- If no valid target, find nearest monster
	if not actualTarget then
		local nearestDist = 80
		for _, model in ipairs(workspace:GetDescendants()) do
			if model:IsA("Model") and model:GetAttribute("IsMonster") then
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if hrp and hrp.Parent then
					local hum = model:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						local dist = (hrp.Position - root.Position).Magnitude
						if dist < nearestDist then
							nearestDist = dist
							actualTarget = hrp.Position
						end
					end
				end
			end
		end
	end

	-- Raycast towards target to find a monster
	if actualTarget then
		local dir = actualTarget - root.Position
		if dir.Magnitude > 0 then
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			params.FilterType = Enum.RaycastFilterType.Exclude
			local rayHit = workspace:Raycast(root.Position, dir.Unit * (sp.Range or 65), params)
			if rayHit then
				local hitModel = rayHit.Instance:FindFirstAncestorOfClass("Model")
				if hitModel and hitModel:GetAttribute("IsMonster") then
					damage(player, hitModel, amount)
				end
			end
		end
	end

	-- Fire visual effects to ALL clients (projectile animation)
	SpellCast:FireAllClients(player, weaponToUse, actualTarget or root.Position + root.CFrame.LookVector * 50)

	-- Also fire LockTarget to show target indicator
	local lockRemote = Remotes:FindFirstChild("LockTarget")
	-- If actualTarget is nil and we just computed it, re-find the target model for lock
	local foundTargetModel = nil
	if actualTarget then
		-- Find the target model at the position
		for _, model in ipairs(workspace:GetDescendants()) do
			if model:IsA("Model") and model:GetAttribute("IsMonster") then
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if hrp and (hrp.Position - actualTarget).Magnitude < 5 then
					foundTargetModel = model
					break
				end
			end
		end
	end

	if foundTargetModel then
		lockRemote:FireAllClients(foundTargetModel)
	end
end)

return SpellService

