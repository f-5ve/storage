local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local SPIN_Y  = 99999
local SPIN_XZ = 45000

local MAGNET_SPEED   = 1800

local CONTACT_RADIUS = 10
local CONTACT_TIME   = 1.1
local STEP           = 0.015

local IMPACT_SPIKE   = 1400
local IMPACT_DECAY   = 0.12
local JUMP_PUNISH_Y  = 90

local SNAP_DISTANCE  = 14
local SNAP_OFFSET    = 3
local SNAP_COOLDOWN  = 0.10

local LEAD_BASE      = 0.22
local LEAD_DIST_K    = 0.0004
local LEAD_VERT_BIAS = 0.40

local MAX_VELOCITY  = 900
local MAX_DISTANCE  = 2500
local MAP_CENTER    = Vector3.new(0, 20, 0)

local SPECTATE_SWITCH_DELAY = 0.6
local QUEUE_REBUILD_DELAY = 0.1

local CHAM_FILL_COLOR    = Color3.fromRGB(255, 0, 0)
local CHAM_FILL_ALPHA    = 0.75
local CHAM_OUTLINE_COLOR = Color3.fromRGB(255, 50, 50)

local SPIN_POOL_SIZE = 64
local spinPool = table.create(SPIN_POOL_SIZE)
for i = 1, SPIN_POOL_SIZE do
	spinPool[i] = Vector3.new(
		math.random(-SPIN_XZ, SPIN_XZ),
		SPIN_Y,
		math.random(-SPIN_XZ, SPIN_XZ)
	)
end
local spinIdx = 0

local char, hum, hrp
local bav, linVel, linAttach

local viewingPlayer
local viewDied, viewChanged

local targetQueue = {}
local queueIndex = 1
local chammedPlayers = {}

local lastSnap = 0

local function setupCharacter(c)
	char = c
	hum  = c:WaitForChild("Humanoid")
	hrp  = c:WaitForChild("HumanoidRootPart")

	local parts = {}
	for _, v in ipairs(c:GetDescendants()) do
		if v:IsA("BasePart") then parts[#parts + 1] = v end
	end
	for _, v in ipairs(parts) do
		v.CanCollide = false
		v.Massless   = true
		v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
	end
end

local function clearSpectate()
	if viewDied    then viewDied:Disconnect()    end
	if viewChanged then viewChanged:Disconnect() end
	viewDied, viewChanged = nil, nil
	viewingPlayer = nil
	if hum then cam.CameraSubject = hum end
end

local function spectatePlayer(plr)
	if viewingPlayer == plr then return end
	clearSpectate()
	viewingPlayer = plr
	if not plr.Character then return end
	cam.CameraSubject = plr.Character

	viewDied = plr.CharacterAdded:Connect(function()
		repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		cam.CameraSubject = plr.Character
	end)
end

local function applyGreenCham(plr)
	if not plr.Character then return end
	
	local highlight = plr.Character:FindFirstChild("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Parent = plr.Character
	end
	
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.FillTransparency = CHAM_FILL_ALPHA
	highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineTransparency = 0.2
end

local function applyRedCham(plr)
	if not plr.Character then return end
	
	local highlight = plr.Character:FindFirstChild("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Parent = plr.Character
	end
	
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = CHAM_FILL_ALPHA
	highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
	highlight.OutlineTransparency = 0.2
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function removeChams(plr)
	if not plr.Character then return end
	local highlight = plr.Character:FindFirstChild("Highlight")
	if highlight then highlight:Destroy() end
	chammedPlayers[plr] = nil
end

local function cleanupAllChams()
	for plr, _ in pairs(chammedPlayers) do
		removeChams(plr)
	end
	chammedPlayers = {}
end

local function startSpin()
	if bav then bav:Destroy() end
	bav = Instance.new("BodyAngularVelocity")
	bav.Parent    = hrp
	bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bav.P         = math.huge

	task.spawn(function()
		while hum.Health > 0 do
			spinIdx = (spinIdx % SPIN_POOL_SIZE) + 1
			bav.AngularVelocity = spinPool[spinIdx]
			RunService.Heartbeat:Wait()
		end
	end)
end

local function buildMagnet()
	if linVel    then linVel:Destroy()    end
	if linAttach then linAttach:Destroy() end
	linAttach = Instance.new("Attachment", hrp)
	linVel = Instance.new("LinearVelocity")
	linVel.Parent      = hrp
	linVel.Attachment0 = linAttach
	linVel.MaxForce    = math.huge
	linVel.RelativeTo  = Enum.ActuatorRelativeTo.World
	linVel.VectorVelocity = Vector3.zero
end

local function getDynamicLeadPosition(thrp)
	local vel  = thrp.AssemblyLinearVelocity
	local dist = (thrp.Position - hrp.Position).Magnitude
	local lead = LEAD_BASE + dist * LEAD_DIST_K

	local vertBias = 0
	if vel.Y > 5 then
		vertBias = vel.Y * LEAD_VERT_BIAS * (1 / math.max(vel.Magnitude, 1))
	end

	return thrp.Position + vel * lead + Vector3.new(0, vertBias, 0)
end

local function magnetizePredictive(thrp)
	if not thrp or not thrp.Parent then return end
	local aim = getDynamicLeadPosition(thrp)
	local dir = aim - hrp.Position
	if dir.Magnitude < 1 then return end
	linVel.VectorVelocity = dir.Unit * MAGNET_SPEED
end

local function stopMagnet()
	if linVel then linVel.VectorVelocity = Vector3.zero end
end

local function clampVelocity()
	local vel = hrp.AssemblyLinearVelocity
	if vel.Magnitude > MAX_VELOCITY then
		hrp.AssemblyLinearVelocity = vel.Unit * MAX_VELOCITY
	end
end

local function applyImpulse(v3)
	hrp.AssemblyLinearVelocity = v3
	clampVelocity()
end

local function microSnapToward(thrp)
	local now = os.clock()
	if now - lastSnap < SNAP_COOLDOWN then return end
	lastSnap = now
	local dir = thrp.Position - hrp.Position
	if dir.Magnitude <= SNAP_DISTANCE then
		hrp.CFrame = CFrame.new(thrp.Position - dir.Unit * SNAP_OFFSET)
	end
end

local function targetValid(thrp)
	return thrp and thrp.Parent and (thrp.Position - hrp.Position).Magnitude < 2000
end

local function buildQueue()
	targetQueue = {}
	queueIndex = 1
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp and plr.Character then
			local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local thum = plr.Character:FindFirstChildOfClass("Humanoid")
			if thrp and thum and thum.Health > 0 then
				table.insert(targetQueue, plr)
			end
		end
	end

	for _, plr in ipairs(targetQueue) do
		if plr.Character then
			applyGreenCham(plr)
			chammedPlayers[plr] = true
		end
	end
end

local function flingTarget(plr)
	if not plr.Character then return false end
	
	local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
	local thum = plr.Character:FindFirstChildOfClass("Humanoid")
	if not (thrp and thum and thum.Health > 0) then return false end

	spectatePlayer(plr)
	applyRedCham(plr)

	while hum.Health > 0 and targetValid(thrp) do
		if (hrp.Position - thrp.Position).Magnitude <= CONTACT_RADIUS then break end
		magnetizePredictive(thrp)
		task.wait(STEP)
	end

	if not targetValid(thrp) then
		stopMagnet()
		applyImpulse(Vector3.new(0, 0, 0))
		task.wait(SPECTATE_SWITCH_DELAY)
		removeChams(plr)
		return false
	end

	local dir = (thrp.Position - hrp.Position).Unit
	stopMagnet()
	applyImpulse(dir * IMPACT_SPIKE + Vector3.new(0, JUMP_PUNISH_Y, 0))
	task.wait(IMPACT_DECAY)

	local t0 = os.clock()
	while hum.Health > 0 and targetValid(thrp) and os.clock() - t0 < CONTACT_TIME do
		magnetizePredictive(thrp)
		microSnapToward(thrp)
		task.wait(STEP)
	end

	stopMagnet()
	applyImpulse(Vector3.new(
		hrp.AssemblyLinearVelocity.X * 0.15,
		0,
		hrp.AssemblyLinearVelocity.Z * 0.15
	))
	task.wait(SPECTATE_SWITCH_DELAY)
	removeChams(plr)
	return true
end

RunService.Heartbeat:Connect(function()
	if not hrp or not hum then return end

	if hum:GetState() == Enum.HumanoidStateType.Seated then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	if (hrp.Position - MAP_CENTER).Magnitude > MAX_DISTANCE then
		stopMagnet()
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = CFrame.new(MAP_CENTER)
	end

	clampVelocity()
end)

task.spawn(function()
	buildQueue()
	
	while true do
		if not hum or hum.Health <= 0 then
			clearSpectate()
			task.wait(0.1)
			continue
		end

		if queueIndex > #targetQueue then
			clearSpectate()
			cleanupAllChams()
			task.wait(QUEUE_REBUILD_DELAY)
			buildQueue()
			continue
		end

		local plr = targetQueue[queueIndex]
		if plr and plr.Parent then
			flingTarget(plr)
		end
		queueIndex = queueIndex + 1
	end
end)

setupCharacter(lp.Character or lp.CharacterAdded:Wait())
buildMagnet()
startSpin()

RunService.Stepped:Connect(function()
	if not char then return end
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") then v.CanCollide = false end
	end
end)

lp.CharacterAdded:Connect(function(c)
	task.wait(0.1)
	clearSpectate()
	cleanupAllChams()
	setupCharacter(c)
	buildMagnet()
	startSpin()
end)