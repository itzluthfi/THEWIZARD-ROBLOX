local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local Remotes = RS:WaitForChild("RemoteEvents")
local SpellCast = Remotes:WaitForChild("SpellCast")
local StaffFireProjectile = Remotes:WaitForChild("StaffFireProjectile")
local SlotCooldown = Remotes:WaitForChild("SlotCooldown")
local SyncData = Remotes:WaitForChild("SyncData")
local GetData  = Remotes.Functions:WaitForChild("GetPlayerData")
local SpellsConfig = require(RS:WaitForChild("Config"):WaitForChild("SpellsConfig"))
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local data, cooldowns = nil, {}
local V = Vector3.new
local C = function(r,g,b) return Color3.fromRGB(r,g,b) end

data = GetData:InvokeServer()  -- fetch initial data immediately
SyncData.OnClientEvent:Connect(function(d) data = d end)

-- Listen for UI-triggered casts (clicking spell slots in MainUI)
-- Uses BindableEvent for client-to-client communication
local CastSpellBindable = Remotes:FindFirstChild("CastSpellBindable")
if CastSpellBindable and CastSpellBindable:IsA("BindableEvent") then
	CastSpellBindable.Event:Connect(function(slot)
		cast(slot)
	end)
else
	-- Fallback: listen for legacy CastSpell RemoteEvent
	local CastSpell = Remotes:WaitForChild("CastSpell", 3)
	if CastSpell then
		CastSpell.OnClientEvent:Connect(function(slot)
			if type(slot) == "number" then cast(slot) end
		end)
	end
end

local function cdScale()
	local st = data and data.Stats or {}
	return math.max(0.45, 1 - ((st.Cooldown or 0) * 0.03))
end

local function showAlert(text, color)
	local gui = player.PlayerGui:FindFirstChild("TheWizardUI")
	if not gui then return end
	local old = gui:FindFirstChild("ManaAlertText")
	if old then old:Destroy() end

	local alert = Instance.new("TextLabel")
	alert.Name = "ManaAlertText"
	alert.Size = UDim2.new(0,400,0,50)
	alert.Position = UDim2.new(0.5,-200,0.3,0)
	alert.BackgroundTransparency = 1
	alert.Text = text
	alert.TextColor3 = color
	alert.Font = Enum.Font.GothamBold
	alert.TextSize = 28
	alert.TextStrokeColor3 = Color3.new(0,0,0)
	alert.TextStrokeTransparency = 0.2
	alert.Parent = gui

	alert.Size = UDim2.new(0,100,0,10)
	alert.Position = UDim2.new(0.5,-50,0.32,0)
	TS:Create(alert, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0,400,0,50),
		Position = UDim2.new(0.5,-200,0.3,0)
	}):Play()

	task.delay(1.2, function()
		if alert and alert.Parent then
			local tw = TS:Create(alert, TweenInfo.new(0.4), {TextTransparency=1, TextStrokeTransparency=1})
			tw:Play()
			tw.Completed:Connect(function() alert:Destroy() end)
		end
	end)
end

local function cast(slot)
	local sn = data and data.EquippedSpells and data.EquippedSpells[slot]
	if not sn then return end
	if cooldowns[sn] and cooldowns[sn] > os.clock() then return end
	local sp = SpellsConfig.GetSpell(sn)
	if not sp then return end

	local cost = sp.ManaCost or 0
	local currentMana = data and data.Mana or 0
	if currentMana < cost then
		showAlert("Mana Tidak Cukup! ❌", Color3.fromRGB(255, 60, 60))
		return
	end

	local dur = (sp.Cooldown or 1) * cdScale()
	cooldowns[sn] = os.clock() + dur
	SlotCooldown:FireServer(slot, dur)
	SpellCast:FireServer(sn, mouse.Hit.Position)
end

-- ══════ MOVEMENT: DOUBLE JUMP & DASH ══════
local maxJumps = 2
local currentJumps = 0
local canDoubleJump = false
local dashCooldown = 0
local isDashing = false

local function setupMovement(char)
	local hum = char:WaitForChild("Humanoid")
	currentJumps = 0
	canDoubleJump = false
	
	hum.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Landed then
			currentJumps = 0
			canDoubleJump = false
		elseif newState == Enum.HumanoidStateType.Freefall then
			if currentJumps == 0 then
				currentJumps = 1
				canDoubleJump = true
			end
		end
	end)
end

player.CharacterAdded:Connect(setupMovement)
if player.Character then setupMovement(player.Character) end

local function performDash()
	if os.clock() < dashCooldown or isDashing then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end
	
	isDashing = true
	dashCooldown = os.clock() + 2.0
	
	local dir = hum.MoveDirection
	if dir.Magnitude == 0 then
		dir = root.CFrame.LookVector
	end
	dir = Vector3.new(dir.X, 0, dir.Z).Unit
	
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(100000, 0, 100000)
	bodyVel.Velocity = dir * 75
	bodyVel.Parent = root
	
	-- Trail Effect
	local att0 = Instance.new("Attachment", root)
	att0.Position = Vector3.new(0, 1, 0)
	local att1 = Instance.new("Attachment", root)
	att1.Position = Vector3.new(0, -1, 0)
	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 200, 255))
	trail.WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
	trail.Lifetime = 0.25
	trail.Parent = root
	
	task.delay(0.2, function()
		bodyVel:Destroy()
		isDashing = false
	end)
	task.delay(0.4, function()
		trail:Destroy()
		att0:Destroy()
		att1:Destroy()
	end)
end

-- Key & Click Bindings
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	-- LMB Basic Attack OR weapon attack if weapon is equipped
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local wpn = data and data.EquippedSpells and data.EquippedSpells[4]
		if wpn then
			-- Weapon attack — fire StaffFireProjectile
			if cooldowns["WpnAttack"] and cooldowns["WpnAttack"] > os.clock() then return end
			local sp = SpellsConfig.GetSpell(wpn)
			if not sp then return end
			cooldowns["WpnAttack"] = os.clock() + (sp.Cooldown or 0.8)
			StaffFireProjectile:FireServer(wpn, mouse.Hit.Position)
			return
		end
		-- Default Basic Shot spell attack
		if cooldowns["Basic Shot"] and cooldowns["Basic Shot"] > os.clock() then return end
		local sp = SpellsConfig.GetSpell("Basic Shot")
		if not sp then return end
		cooldowns["Basic Shot"] = os.clock() + 0.6
		SpellCast:FireServer("Basic Shot", mouse.Hit.Position)
		return
	end

	if input.KeyCode == Enum.KeyCode.One then cast(1)
	elseif input.KeyCode == Enum.KeyCode.Two then cast(2)
	elseif input.KeyCode == Enum.KeyCode.Three then cast(3)
	elseif input.KeyCode == Enum.KeyCode.Four then 
		-- Slot 4 weapon attack
		local wpn = data and data.EquippedSpells and data.EquippedSpells[4]
		if wpn then
			if cooldowns["WpnAttack"] and cooldowns["WpnAttack"] > os.clock() then return end
			local sp = SpellsConfig.GetSpell(wpn)
			if not sp then return end
			cooldowns["WpnAttack"] = os.clock() + (sp.Cooldown or 0.8)
			StaffFireProjectile:FireServer(wpn, mouse.Hit.Position)
		end
	elseif input.KeyCode == Enum.KeyCode.Q then performDash()
	elseif input.KeyCode == Enum.KeyCode.Space then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if hum and root and canDoubleJump and currentJumps < maxJumps then
			currentJumps += 1
			canDoubleJump = false
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			
			-- Expanding jump ring effect at feet
			local ringPart = Instance.new("Part")
			ringPart.Shape = Enum.PartType.Cylinder
			ringPart.Size = Vector3.new(0.2, 5, 5)
			ringPart.CFrame = root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
			ringPart.Color = Color3.fromRGB(200, 240, 255)
			ringPart.Material = Enum.Material.Neon
			ringPart.Transparency = 0.4
			ringPart.Anchored = true
			ringPart.CanCollide = false
			ringPart.Parent = workspace
			
			TS:Create(ringPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.2, 12, 12),
				Transparency = 1
			}):Play()
			task.delay(0.35, function() ringPart:Destroy() end)
		end
	end
end)

-- ══════ HELPERS ══════
local function mkP(pos, sz, col, mat, shape)
	local p = Instance.new("Part")
	p.Shape = shape or Enum.PartType.Ball
	p.Size = V(sz,sz,sz)
	p.Material = mat or Enum.Material.Neon
	p.Color = col  p.Anchored = true  p.CanCollide = false  p.CastShadow = false
	p.Position = pos  p.Parent = workspace
	return p
end
local function mkL(par, col, br, rng)
	local l = Instance.new("PointLight")
	l.Color = col  l.Brightness = br or 2  l.Range = rng or 12
	l.Parent = par
	return l
end
local function mkE(par, c1, c2, sz, rate, spread, glow)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)})
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,sz or 1.2),NumberSequenceKeypoint.new(1,0)})
	e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,1)})
	e.Lifetime = NumberRange.new(0.15,0.4)
	e.Rate = rate or 60  e.Speed = NumberRange.new(1,4)
	e.SpreadAngle = Vector2.new(spread or 25, spread or 25)
	e.LightEmission = glow or 0.8
	e.Parent = par
	return e
end
local function fly(part, tgt, spd)
	local d = (tgt-part.Position).Magnitude
	local tw = TS:Create(part, TweenInfo.new(math.clamp(d/(spd or 90),0.08,1.5), Enum.EasingStyle.Linear), {Position=tgt})
	tw:Play()
	return tw
end
local function boom(pos, col, sz, dur)
	local b = mkP(pos, 1, col)
	b.Transparency = 0.3
	mkL(b, col, 4, 20)
	TS:Create(b, TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size=V(sz,sz,sz), Transparency=1
	}):Play()
	task.delay((dur or 0.35)+0.15, function() b:Destroy() end)
end
local function ring(pos, col, sz, dur)
	local r = Instance.new("Part")
	r.Shape = Enum.PartType.Cylinder
	r.Size = V(0.3,2,2)
	r.CFrame = CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90))
	r.Material = Enum.Material.Neon
	r.Color = col  r.Anchored = true  r.CanCollide = false  r.CastShadow = false
	r.Transparency = 0.3  r.Parent = workspace
	TS:Create(r, TweenInfo.new(dur or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size=V(0.3,sz,sz), Transparency=1
	}):Play()
	task.delay((dur or 0.5)+0.1, function() r:Destroy() end)
end

-- ══════ PER-SPELL ANIMATIONS ══════
local SA = {}

SA["Basic Shot"] = function(s,t,sp)
	local p = mkP(s,0.8,sp.Effect.Color)
	mkL(p, sp.Effect.Secondary, 1.5, 8)
	mkE(p, sp.Effect.Secondary, C(200,200,255), 0.6, 30, 15, 0.6)
	fly(p,t,sp.Speed).Completed:Connect(function()
		boom(t,sp.Effect.Color,3.5,0.2)
		p:Destroy()
	end)
end

SA["Crimson Bolt"] = function(s,t,sp)
	local p = mkP(s,1.8,sp.Effect.Color)
	mkL(p, sp.Effect.Secondary, 3, 14)
	mkE(p, sp.Effect.Secondary, C(180,30,0), 1.5, 80, 30, 1)
	fly(p,t,sp.Speed).Completed:Connect(function()
		boom(t,sp.Effect.Color,8,0.35)
		ring(t,sp.Effect.Secondary,12,0.4)
		task.delay(0.4, function() p:Destroy() end)
	end)
end

SA["Inferno Cascade"] = function(s,t,sp)
	for i=1,6 do
		task.delay(i*0.08, function()
			local a=(i/6)*math.pi*2
			local pos = t + V(math.cos(a)*7, 0, math.sin(a)*7)
			local pillar = mkP(pos, 1, sp.Effect.Color, nil, Enum.PartType.Block)
			pillar.Size = V(2,1,2)
			mkL(pillar, sp.Effect.Secondary, 3, 10)
			TS:Create(pillar, TweenInfo.new(0.25), {Size=V(2,14,2), Position=pos+V(0,7,0)}):Play()
			task.delay(0.3, function()
				TS:Create(pillar, TweenInfo.new(0.3), {Transparency=1, Size=V(1,16,1)}):Play()
				task.delay(0.35, function() pillar:Destroy() end)
			end)
		end)
	end
	task.delay(0.6, function() boom(t,sp.Effect.Color,12,0.4) end)
end

SA["Phoenix Wrath"] = function(s,t,sp)
	local body = mkP(s,2.5,sp.Effect.Color)
	local lw = mkP(s+V(-2.5,0.5,0),1.2,sp.Effect.Secondary)
	local rw = mkP(s+V(2.5,0.5,0),1.2,sp.Effect.Secondary)
	mkL(body, sp.Effect.Secondary, 5, 20)
	mkE(body, sp.Effect.Secondary, C(200,40,0), 2.5, 120, 20, 1)
	local d=math.clamp((t-s).Magnitude/(sp.Speed or 110),0.08,1.5)
	TS:Create(body, TweenInfo.new(d,Enum.EasingStyle.Linear), {Position=t}):Play()
	TS:Create(lw, TweenInfo.new(d,Enum.EasingStyle.Linear), {Position=t+V(-2,0,0)}):Play()
	TS:Create(rw, TweenInfo.new(d,Enum.EasingStyle.Linear), {Position=t+V(2,0,0)}):Play()
	task.delay(d, function()
		boom(t,sp.Effect.Color,14,0.45)
		ring(t,sp.Effect.Secondary,18,0.5)
		for i=1,5 do
			local fp = mkP(t+V(math.random(-5,5),0,math.random(-5,5)),1,sp.Effect.Secondary)
			mkE(fp,sp.Effect.Secondary,C(180,30,0),1.2,25,30,1)
			TS:Create(fp,TweenInfo.new(1.2),{Transparency=1}):Play()
			task.delay(1.3, function() fp:Destroy() end)
		end
		body:Destroy() lw:Destroy() rw:Destroy()
	end)
end

SA["Apocalypse Flare"] = function(s,t,sp)
	local meteor = mkP(t+V(0,80,0), 5, sp.Effect.Color)
	mkL(meteor, sp.Effect.Secondary, 6, 35)
	mkE(meteor, sp.Effect.Secondary, C(200,30,0), 3, 120, 15, 1)
	TS:Create(meteor, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position=t}):Play()
	task.delay(0.7, function()
		meteor:Destroy()
		boom(t,sp.Effect.Color,20,0.5)
		boom(t,sp.Effect.Secondary,14,0.3)
		ring(t,sp.Effect.Color,28,0.6)
		for i=1,8 do
			local d = mkP(t,1.2,sp.Effect.Secondary)
			local a=(i/8)*math.pi*2
			TS:Create(d,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				Position=t+V(math.cos(a)*14,math.random(3,10),math.sin(a)*14),Transparency=1
			}):Play()
			task.delay(0.6, function() d:Destroy() end)
		end
	end)
end

SA["Frost Fang"] = function(s,t,sp)
	local p = mkP(s,1.4,sp.Effect.Color,Enum.Material.Ice,Enum.PartType.Block)
	p.Size = V(1,1.2,2.8)
	mkL(p,sp.Effect.Secondary,2,10)
	mkE(p,Color3.new(1,1,1),sp.Effect.Color,0.8,50,15,0.6)
	local dir=(t-s)
	local u = dir.Magnitude>0 and dir.Unit or V(0,0,-1)
	task.spawn(function()
		local a=0
		while p and p.Parent do
			a+=12
			p.CFrame = CFrame.new(p.Position,p.Position+u)*CFrame.Angles(0,0,math.rad(a))
			task.wait()
		end
	end)
	fly(p,t,sp.Speed).Completed:Connect(function()
		for i=1,6 do
			local sh = mkP(t,0.6,sp.Effect.Secondary,Enum.Material.Ice,Enum.PartType.Block)
			local a=(i/6)*math.pi*2
			TS:Create(sh,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				Position=t+V(math.cos(a)*5,math.random(2,5),math.sin(a)*5),Transparency=1,Size=V(0.1,0.1,0.1)
			}):Play()
			task.delay(0.5, function() sh:Destroy() end)
		end
		boom(t,sp.Effect.Color,8,0.3)
		p:Destroy()
	end)
end

SA["Glacial Nova"] = function(s,t,sp)
	for i=1,8 do
		task.delay(i*0.06, function()
			local a=(i/8)*math.pi*2
			local pos = t + V(math.cos(a)*8,0,math.sin(a)*8)
			local spike = mkP(pos,0.5,sp.Effect.Color,Enum.Material.Ice,Enum.PartType.Block)
			spike.Size = V(1.5,0.5,1.5)
			TS:Create(spike,TweenInfo.new(0.2),{Size=V(1.5,10,1.5),Position=pos+V(0,5,0)}):Play()
			task.delay(0.5, function()
				TS:Create(spike,TweenInfo.new(0.4),{Transparency=1}):Play()
				task.delay(0.45, function() spike:Destroy() end)
			end)
		end)
	end
	task.delay(0.3, function() boom(t,sp.Effect.Secondary,10,0.3) end)
end

SA["Winter's Embrace"] = function(s,t,sp)
	local p = mkP(s,2,sp.Effect.Color,Enum.Material.Ice)
	mkL(p,sp.Effect.Secondary,3,14)
	mkE(p,Color3.new(1,1,1),sp.Effect.Color,1.8,70,40,0.7)
	local shards = {}
	for i=1,3 do
		local sh = mkP(s,0.5,sp.Effect.Secondary,Enum.Material.Ice,Enum.PartType.Block)
		table.insert(shards,sh)
	end
	task.spawn(function()
		local a=0
		while p and p.Parent do
			a+=8
			for i,sh in ipairs(shards) do
				if sh.Parent then
					local off = CFrame.Angles(0,math.rad(a+i*120),0)*V(3,0,0)
					sh.Position = p.Position+off
				end
			end
			task.wait()
		end
	end)
	fly(p,t,sp.Speed).Completed:Connect(function()
		boom(t,sp.Effect.Color,10,0.35)
		for i=1,4 do
			local wall = mkP(t,0.5,sp.Effect.Secondary,Enum.Material.Ice,Enum.PartType.Block)
			wall.Size=V(0.5,6,4)
			wall.CFrame=CFrame.new(t)*CFrame.Angles(0,math.rad(i*90),0)*CFrame.new(0,3,-4)
			wall.Transparency=0.3
			TS:Create(wall,TweenInfo.new(1),{Transparency=1}):Play()
			task.delay(1.1, function() wall:Destroy() end)
		end
		for _,sh in ipairs(shards) do sh:Destroy() end
		p:Destroy()
	end)
end

SA["Eternal Frost"] = function(s,t,sp)
	local ground = mkP(t,0.5,sp.Effect.Color,Enum.Material.Ice,Enum.PartType.Cylinder)
	ground.Size=V(0.2,1,1)
	ground.CFrame=CFrame.new(t)*CFrame.Angles(0,0,math.rad(90))
	TS:Create(ground,TweenInfo.new(0.6),{Size=V(0.2,28,28)}):Play()
	for i=1,6 do
		task.delay(0.1+i*0.08, function()
			local a=(i/6)*math.pi*2
			local pos=t+V(math.cos(a)*10,0,math.sin(a)*10)
			local pillar=mkP(pos,0.5,sp.Effect.Secondary,Enum.Material.Ice,Enum.PartType.Block)
			pillar.Size=V(1.5,0.5,1.5)
			TS:Create(pillar,TweenInfo.new(0.25),{Size=V(1.5,12,1.5),Position=pos+V(0,6,0)}):Play()
			task.delay(0.8, function()
				TS:Create(pillar,TweenInfo.new(0.5),{Transparency=1}):Play()
				task.delay(0.55, function() pillar:Destroy() end)
			end)
		end)
	end
	task.delay(1.5, function()
		TS:Create(ground,TweenInfo.new(0.5),{Transparency=1}):Play()
		task.delay(0.55, function() ground:Destroy() end)
	end)
end

SA["Venom Strike"] = function(s,t,sp)
	local p = mkP(s,1,sp.Effect.Color,nil,Enum.PartType.Block)
	p.Size = V(0.5,0.5,2)
	local dir=(t-s)
	if dir.Magnitude>0 then p.CFrame=CFrame.new(s,s+dir.Unit) end
	mkE(p,sp.Effect.Secondary,sp.Effect.Color,0.6,30,10,0.5)
	task.spawn(function()
		while p and p.Parent do
			local drip=mkP(p.Position,0.3,sp.Effect.Color)
			TS:Create(drip,TweenInfo.new(0.4),{Position=drip.Position+V(0,-3,0),Transparency=1,Size=V(0.1,0.1,0.1)}):Play()
			task.delay(0.45, function() drip:Destroy() end)
			task.wait(0.08)
		end
	end)
	local d=math.clamp(dir.Magnitude/(sp.Speed or 85),0.08,1.5)
	local u = dir.Magnitude>0 and dir.Unit or V(0,0,-1)
	TS:Create(p,TweenInfo.new(d,Enum.EasingStyle.Linear),{CFrame=CFrame.new(t,t+u)}):Play()
	task.delay(d, function()
		local pool=mkP(t,0.5,sp.Effect.Color,nil,Enum.PartType.Cylinder)
		pool.Size=V(0.2,8,8)
		pool.CFrame=CFrame.new(t)*CFrame.Angles(0,0,math.rad(90))
		pool.Transparency=0.4
		TS:Create(pool,TweenInfo.new(0.4),{Size=V(0.2,8,8)}):Play()
		task.delay(1.5, function()
			TS:Create(pool,TweenInfo.new(0.5),{Transparency=1}):Play()
			task.delay(0.55, function() pool:Destroy() end)
		end)
		p:Destroy()
	end)
end

SA["Plague Cloud"] = function(s,t,sp)
	local cloud = mkP(t,2,sp.Effect.Color)
	cloud.Transparency = 0.4
	mkE(cloud,sp.Effect.Secondary,C(30,60,10),4,80,180,0.3)
	TS:Create(cloud,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
		Size=V(18,18,18),Transparency=0.7
	}):Play()
	for i=1,8 do
		task.delay(i*0.12, function()
			local bubble=mkP(t+V(math.random(-6,6),0,math.random(-6,6)),math.random()*1+0.5,sp.Effect.Secondary)
			bubble.Transparency=0.3
			TS:Create(bubble,TweenInfo.new(0.6),{Position=bubble.Position+V(0,math.random(4,8),0),Size=V(0.1,0.1,0.1),Transparency=1}):Play()
			task.delay(0.65, function() bubble:Destroy() end)
		end)
	end
	task.delay(1.5, function()
		TS:Create(cloud,TweenInfo.new(0.5),{Transparency=1}):Play()
		task.delay(0.55, function() cloud:Destroy() end)
	end)
end

SA["Death Blossom"] = function(s,t,sp)
	local center = mkP(t,1.5,sp.Effect.Color)
	mkL(center,sp.Effect.Secondary,2,12)
	TS:Create(center,TweenInfo.new(0.3),{Size=V(3,3,3)}):Play()
	task.delay(0.3, function()
		for i=1,10 do
			local a=(i/10)*math.pi*2
			local petal = mkP(t,1,sp.Effect.Secondary,nil,Enum.PartType.Block)
			petal.Size = V(1.5,0.3,2)
			petal.CFrame = CFrame.new(t)*CFrame.Angles(0,a,math.rad(30))
			TS:Create(petal,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				Position=t+V(math.cos(a)*12,math.random(1,5),math.sin(a)*12),Transparency=1,Size=V(0.5,0.1,0.5)
			}):Play()
			task.delay(0.55, function() petal:Destroy() end)
		end
		boom(t,sp.Effect.Color,10,0.35)
		center:Destroy()
	end)
end

SA["Arcane Missile"] = function(s,t,sp)
	local p = mkP(s,1.6,sp.Effect.Color)
	mkL(p,sp.Effect.Secondary,2.5,14)
	mkE(p,sp.Effect.Secondary,sp.Effect.Color,1,60,25,1)
	task.spawn(function()
		while p and p.Parent do
			local rune=mkP(p.Position,0.1,sp.Effect.Secondary,nil,Enum.PartType.Cylinder)
			rune.Size=V(0.05,2,2)
			rune.CFrame=CFrame.new(rune.Position)*CFrame.Angles(math.random()*math.pi,math.random()*math.pi,math.rad(90))
			rune.Transparency=0.3
			TS:Create(rune,TweenInfo.new(0.3),{Size=V(0.05,0.5,0.5),Transparency=1}):Play()
			task.delay(0.35, function() rune:Destroy() end)
			task.wait(0.06)
		end
	end)
	fly(p,t,sp.Speed).Completed:Connect(function()
		boom(t,sp.Effect.Color,10,0.4)
		ring(t,sp.Effect.Secondary,14,0.45)
		p:Destroy()
	end)
end

SA["Rift Pulse"] = function(s,t,sp)
	local crack = mkP(t,0.5,sp.Effect.Color,nil,Enum.PartType.Block)
	crack.Size = V(0.3,8,0.3)
	crack.Transparency = 0.2
	mkL(crack,sp.Effect.Secondary,3,15)
	TS:Create(crack,TweenInfo.new(0.3),{Size=V(0.3,12,8)}):Play()
	mkE(crack,sp.Effect.Secondary,sp.Effect.Color,1.5,80,180,1)
	task.delay(0.3, function()
		boom(t,sp.Effect.Color,16,0.5)
		ring(t,sp.Effect.Secondary,20,0.5)
	end)
	task.delay(1, function()
		TS:Create(crack,TweenInfo.new(0.3),{Size=V(0.1,0.1,0.1),Transparency=1}):Play()
		task.delay(0.35, function() crack:Destroy() end)
	end)
end

SA["Celestial Barrage"] = function(s,t,sp)
	for i=0,2 do
		task.delay(i*0.18, function()
			local offset = V(math.random(-2,2),math.random(0,3),math.random(-2,2))
			local p = mkP(s+offset,1.3,sp.Effect.Color)
			mkL(p,sp.Effect.Secondary,2,10)
			mkE(p,sp.Effect.Secondary,sp.Effect.Color,0.8,40,20,1)
			fly(p,t+V(math.random(-2,2),0,math.random(-2,2)),sp.Speed).Completed:Connect(function()
				boom(t,sp.Effect.Color,7,0.25)
				p:Destroy()
			end)
		end)
	end
	task.delay(0.6, function() ring(t,sp.Effect.Secondary,12,0.4) end)
end

SA["Void Annihilation"] = function(s,t,sp)
	local vortex = mkP(t,1,Color3.new(0,0,0))
	vortex.Transparency = 0.1
	mkL(vortex,C(80,0,160),4,25)
	local suck = Instance.new("ParticleEmitter")
	suck.Color = ColorSequence.new(C(150,50,255),C(30,0,60))
	suck.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,3),NumberSequenceKeypoint.new(1,0)})
	suck.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(1,1)})
	suck.Speed = NumberRange.new(-20,-8)
	suck.SpreadAngle = Vector2.new(180,180)
	suck.Rate = 150  suck.Lifetime = NumberRange.new(0.3,0.6)
	suck.LightEmission = 1
	suck.Parent = vortex
	TS:Create(vortex,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=V(12,12,12)}):Play()
	task.spawn(function()
		local a=0
		while vortex and vortex.Parent do
			a+=6
			vortex.CFrame=CFrame.new(t)*CFrame.Angles(math.rad(a),math.rad(a*1.3),0)
			task.wait()
		end
	end)
	task.delay(1, function()
		suck.Enabled = false
		TS:Create(vortex,TweenInfo.new(0.15),{Size=V(0.5,0.5,0.5)}):Play()
		task.delay(0.15, function()
			boom(t,C(120,0,255),24,0.6)
			boom(t,C(60,0,120),18,0.4)
			ring(t,C(150,50,255),35,0.6)
			task.delay(0.1, function() ring(t,C(80,0,160),25,0.5) end)
			vortex:Destroy()
		end)
	end)
end

SA["Spark Lance"] = function(s,t,sp)
	local p = mkP(s,1,sp.Effect.Color)
	mkL(p,Color3.new(1,1,1),5,20)
	mkE(p,Color3.new(1,1,1),sp.Effect.Color,0.4,200,8,1)
	fly(p,t,sp.Speed).Completed:Connect(function()
		boom(t,Color3.new(1,1,1),6,0.15)
		boom(t,sp.Effect.Color,10,0.3)
		for i=1,4 do
			local arc = Instance.new("Part")
			arc.Size = V(0.15,0.15,math.random(4,8))
			arc.Material = Enum.Material.Neon
			arc.Color = sp.Effect.Color  arc.Anchored = true  arc.CanCollide = false  arc.CastShadow = false
			arc.CFrame = CFrame.new(t)*CFrame.Angles(math.rad(math.random(-40,40)),math.rad(i*90+math.random(-30,30)),0)*CFrame.new(0,0,-arc.Size.Z/2)
			arc.Parent = workspace
			TS:Create(arc,TweenInfo.new(0.2),{Transparency=1}):Play()
			task.delay(0.3, function() arc:Destroy() end)
		end
		p:Destroy()
	end)
end

SA["Thunder Dome"] = function(s,t,sp)
	local dome = mkP(t,2,sp.Effect.Color)
	dome.Transparency = 0.4
	mkL(dome,Color3.new(1,1,1),6,25)
	TS:Create(dome,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
		Size=V(22,22,22),Transparency=0.8
	}):Play()
	for i=1,6 do
		task.delay(i*0.06, function()
			local bolt = Instance.new("Part")
			bolt.Size = V(0.2,math.random(5,12),0.2)
			bolt.Material = Enum.Material.Neon
			bolt.Color = sp.Effect.Secondary  bolt.Anchored = true  bolt.CanCollide = false  bolt.CastShadow = false
			bolt.Position = t + V(math.random(-8,8),math.random(1,10),math.random(-8,8))
			bolt.CFrame = bolt.CFrame*CFrame.Angles(math.rad(math.random(-60,60)),0,math.rad(math.random(-60,60)))
			bolt.Parent = workspace
			TS:Create(bolt,TweenInfo.new(0.15),{Transparency=1}):Play()
			task.delay(0.2, function() bolt:Destroy() end)
		end)
	end
	task.delay(0.8, function()
		TS:Create(dome,TweenInfo.new(0.3),{Transparency=1}):Play()
		task.delay(0.35, function() dome:Destroy() end)
	end)
end

SA["Storm Judgement"] = function(s,t,sp)
	local warn = mkP(t,0.1,sp.Effect.Color,nil,Enum.PartType.Cylinder)
	warn.Size = V(0.1,4,4)
	warn.CFrame = CFrame.new(t)*CFrame.Angles(0,0,math.rad(90))
	warn.Transparency = 0.5
	TS:Create(warn,TweenInfo.new(0.25),{Size=V(0.1,8,8),Transparency=0.8}):Play()
	task.delay(0.3, function()
		local bolt = Instance.new("Part")
		bolt.Size = V(2,90,2)
		bolt.Position = t+V(0,45,0)
		bolt.Material = Enum.Material.Neon
		bolt.Color = sp.Effect.Color
		bolt.Anchored = true  bolt.CanCollide = false  bolt.CastShadow = false
		bolt.Parent = workspace
		mkL(bolt,Color3.new(1,1,1),8,35)
		boom(t,Color3.new(1,1,1),10,0.2)
		boom(t,sp.Effect.Color,14,0.35)
		ring(t,sp.Effect.Secondary,16,0.4)
		task.delay(0.1, function()
			TS:Create(bolt,TweenInfo.new(0.15),{Transparency=1,Size=V(0.1,90,0.1)}):Play()
			task.delay(0.2, function() bolt:Destroy() end)
		end)
		task.delay(0.4, function() warn:Destroy() end)
	end)
end

-- ══════ DISPATCH ══════
SpellCast.OnClientEvent:Connect(function(caster, spellName, target)
	local spell = SpellsConfig.GetSpell(spellName)
	local root = caster and caster.Character and caster.Character:FindFirstChild("HumanoidRootPart")
	if not spell or not root then return end
	local startPos = root.Position + V(0, 2, 0)
	local fn = SA[spellName]
	if fn then
		fn(startPos, target, spell)
	else
		local p = mkP(startPos, 1.5, spell.Effect and spell.Effect.Color or Color3.new(1,1,1))
		fly(p, target, spell.Speed or 90).Completed:Connect(function()
			boom(target, spell.Effect and spell.Effect.Color or Color3.new(1,1,1), 8, 0.35)
			p:Destroy()
		end)
	end
end)