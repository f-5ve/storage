repeat task.wait(1) until game:IsLoaded()
getfenv().LPH_NO_VIRTUALIZE = function(f) return f end;

local blur = Instance.new("BlurEffect", game.Lighting)
blur.Size = 0

for i = 1, 50, 2 do
	blur.Size = i
	task.wait()
end

task.wait(0.1)

for i = 1, 50, 2 do
	blur.Size = 50 - i
	task.wait()
end

task.wait(.1)

getgenv().Settings = {
    --// Movement Speed
    player_speed = 160, -- max 160
    vehicle_speed = 575, -- max 575
    heli_speed = 8000, -- max 8000

	cooldown = 10, -- default : 10
	waitBeforeSell = 10, -- default: 10
	maxPowerPlant = 6000, -- default: 6000
	cargoShipSellCooldown = 5, -- default: 5

	teleport = false, -- default: false
	copDetection = true, -- default: true
	hyperMode = false, -- default: false
	killaura = false, -- default: false
	robSmallStores = true, -- default: true
	safeDo = true, -- default: true
	placeDynamite = false, -- default: false

	--Toggles
	doAirdrop = true,
	doBank = true,
	doCraterBank = true,
	doCargoTrain = true,
	doCargoShip = true,
	doCasino = true,
	doJewelry = true,
	doMuseum = true,
	doOilRig = true,
	doPassengerTrain = true,
	doPlane = true,
	doPowerPlant = true,
	doTomb = true,

	--Logging
	url = "", -- default: ""
	userIdNum = "", -- default: ""
	hyperCount = 0, -- default: 0
	doHyperLog = true, -- default: true
}

settingsShort = getgenv().Settings

disableNpcs = true
copDetectionRange = 25

local viableLoactions = {
    Vector3.new(150, 18, 1373),
	Vector3.new(47.801971435546875,156.32640075683594,-4727.21240234375),
	Vector3.new(843.54364, 19.3194962, -3664.38721),
	Vector3.new(1195.02527, 101.805832, 1181.16199),
	Vector3.new(738.76886, 70.5028839, 1095.50732),
}

task.spawn(function()
    if not getgenv().LoadedMap then
        LPH_NO_VIRTUALIZE(function()
            coroutine.wrap(function()
				pcall(function()
					local Plyr = game.Players.LocalPlayer
					local StartP = Vector3.new(-1528, 39, -5179)
					local EndP = Vector3.new(1567, 99, -717)

					for _, pos in ipairs(viableLoactions) do
						Plyr:RequestStreamAroundAsync(pos, 1000)
					end

					for x = StartP.X , EndP.X, 750 do
						for z = StartP.Z, EndP.Z, 750 do
							Plyr:RequestStreamAroundAsync(Vector3.new(x, 50, z), 1000)
						end
					end
				end)
            end)()
        end)()
	task.wait(1)
	end
end)

--#region allSetupBeforeGUI
function AntiLag()
	local Terrain = workspace:FindFirstChildOfClass('Terrain')
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 0
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").FogEnd = 9e9
	for i,v in pairs(game:GetDescendants()) do
		if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
			v.Material = "Plastic"
			v.Reflectance = 0
		elseif v:IsA("Decal") then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		elseif v:IsA("Explosion") then
			v.BlastPressure = 1
			v.BlastRadius = 1
		end
	end
	for i,v in pairs(game:GetService("Lighting"):GetDescendants()) do
		if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFiegetgenv().SettingsldEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA('ForceField') then
				game:GetService("RunService").Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA('Sparkles') then
				game:GetService("RunService").Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA('Smoke') or child:IsA('Fire') then
				game:GetService("RunService").Heartbeat:Wait()
				child:Destroy()
			end
		end)
	end)
end

local Services = setmetatable({}, {
    __index = function(self, service)
        return cloneref(game:GetService(service))
    end
})

Workspace = Services.Workspace
players = Services.Players
Players = Services.Players
Teams = Services.Teams
HttpService = Services.HttpService
Lighting = Services.Lighting
replicated_storage = Services.ReplicatedStorage
PathfindingService = Services.PathfindingService
CollectionService = game:GetService("CollectionService")
RunService = Services.RunService
MarketplaceService = Services.MarketplaceService
TeleportService = Services.TeleportService
CoreGui = Services.CoreGui
UIS = Services.UserInputService
TextChatService = Services.TextChatService

--[[ Define Variables ]]--
Player = game:GetService("Players").LocalPlayer
local player = game:GetService("Players").LocalPlayer
UI = require(game:GetService("ReplicatedStorage").Module:WaitForChild("UI"))
RobberyMoneyGui = Player.PlayerGui:WaitForChild("RobberyMoneyGui")
MansionRobbery = game.Workspace.MansionRobbery
shipRobbedTimes = 0
reachedEvent = Instance.new("BindableEvent")
reached = false
playerId = players.LocalPlayer.UserId
placeId = game.PlaceId
jobId = game.JobId
AirDropCframe = nil
offset = nil
offsetY = nil
altOffset = nil
AirDropTp = nil
initialTp = nil
Char = nil
Root = nil
Hum = nil
whatLevel = nil
whatColor = nil
messageSent = false

local Other_Modules = {
    Vehicle = require(replicated_storage.Vehicle.VehicleUtils),
    DefaultActions = require(replicated_storage.Game.DefaultActions),
    ItemSystem = require(replicated_storage.Game.ItemSystem.ItemSystem),
	inventoryItemSystem = require(replicated_storage.Inventory.InventoryItemSystem),
	gameUtil = require(replicated_storage.Game.GameUtil),
    GunItem = require(replicated_storage.Game.Item.Gun),
    PlayerUtils = require(replicated_storage.Game.PlayerUtils),
    CharUtils = require(replicated_storage.Game.CharacterUtil),
    Raycast = require(replicated_storage.Module.RayCast),
    UI = require(replicated_storage.Module.UI),
    GunShopUI = require(replicated_storage.Game.GunShop.GunShopUI),
    GunShopUtils = require(replicated_storage.Game.GunShop.GunShopUtils),
    RobberyConsts = require(replicated_storage.Robbery.RobberyConsts),
    NpcShared = require(replicated_storage.GuardNPC.GuardNPCShared),
    Npc = require(replicated_storage.NPC.NPC),
    SafeConsts = require(replicated_storage.Safes.SafesConsts),
    MansionUtils = require(replicated_storage.MansionRobbery.MansionRobberyUtils),
    BossConsts = require(replicated_storage.MansionRobbery.BossNPCConsts),
    BulletEmitter = require(replicated_storage.Game.ItemSystem.BulletEmitter),
    Store = require(replicated_storage.App.store),
    TagUtils = require(replicated_storage.Tag.TagUtils),
    TeamChooseUI = require(replicated_storage.Game.TeamChooseUI),
    Paraglide = require(replicated_storage.Game.Paraglide),
    vehicle_data = require(replicated_storage.Game.Garage.VehicleData),
	store = require(replicated_storage.App.store),
	settings = require(replicated_storage.Resource.Settings),
}

local dependencies = {
    variables = {
        up_vector = Vector3.new(0, 500, 0),
        raycast_params = RaycastParams.new(),
        path = PathfindingService:CreatePath({ WaypointSpacing = 3 }),
        teleporting = false,
        stopVelocity = false,
    },
    door_positions = {},
}

movement = {}
utilities = {}

OwnedHelis = {"Heli"}
OwnedCars = {"Camaro", "Jeep"}
OwnedVehicles = {"Camaro", "Heli", "Jeep"}
unsupportedVehicles = {}

GetVehicleModel = Other_Modules.Vehicle.GetLocalVehicleModel
GetVehiclePacket = Other_Modules.Vehicle.GetLocalVehiclePacket
RayIgnore = Other_Modules.Raycast.RayIgnoreNonCollideWithIgnoreList

--// get free vehicles, owned helicopters, motorcycles and unsupported/new vehicles
--[[
for index, vehicle_data in next, Other_Modules.vehicle_data do
     if vehicle_data.Type == "Heli" then -- helicopters
		table.insert(OwnedHelis, vehicle_data.Make)
        --OwnedHelis[vehicle_data.Make] = true;
     end;
     if not vehicle_data.Price then -- free vehicles
		table.insert(OwnedVehicles, vehicle_data.Make)
		table.insert(OwnedHelis, vehicle_data.Make)
		--OwnedVehicles[vehicle_data.Make] = true;
	 end
 end;
]]


function spawnCar()
    local GarageSpawnCar = replicated_storage.GarageSpawnVehicle

    local args = {
        [1] = "Chassis",
        [2] = "Camaro"
    }

    GarageSpawnCar:FireServer(unpack(args))
end

function FindVehicle()
	for k, v in pairs(game.Workspace.Vehicles:GetChildren()) do
		if v:FindFirstChild("Seat") then
			if v.Seat.PlayerName.Value == player.Name then
				return v
			end
		end
	end
	return nil
end

--Teleport vars
local Vehicles = workspace.Vehicles
local Terrain = workspace.Terrain
local Camera = workspace.CurrentCamera
-- Setting CameraType to Custom
Camera.CameraType = Enum.CameraType.Custom
local TeleportParams = RaycastParams.new()
local door_positions = {}

--Platform
local platform = Instance.new("Part")
platform.Position = Vector3.new(0,20,0)
platform.Size = Vector3.new(75, 1, 75)
platform.Color = Color3.fromRGB(22, 36, 68)
platform.Name = "SafeSpotPlatform"
platform.Anchored = true
platform.CanCollide = true
platform.Parent = workspace


--[[ Essential Functions ]]--
function chatSpam()
	task.spawn(function()
		local doTimes = 0
		repeat
			local ChatMessages = {
				"nigga",
			}
			local TextChatService = game:GetService('TextChatService')

			for i, message in ipairs(ChatMessages) do
				TextChatService.TextChannels['RBXGeneral']:SendAsync(message, "All")
				task.wait(0.1)
			end

			doTimes = doTimes + 1
			task.wait(.1)
		until doTimes == 1
	end)
end

task.spawn(function() --Hijacking prompt
local UI = require(game:GetService("ReplicatedStorage").Module:WaitForChild("UI"));
for i = 1, 100 do
for k, v in pairs(UI.CircleAction.Specs) do
	if (v.Name == "Hijack") then
		v.Duration = 0;
		v.Timed = true;
		v:Callback(v, true)
	end
end
task.wait()
end
end)

repeat
	task.wait()
until workspace:FindFirstChild("Casino")

LPH_NO_VIRTUALIZE(function()
	coroutine.wrap(function()
		while task.wait(0.01) do
			for i,v in pairs(workspace.Casino.Computers:GetDescendants()) do
				if v:IsA("Model") and (game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position - v:FindFirstChild("Display").Position).Magnitude < 10 and v.Name == "Computer" then
					v.CasinoComputerHack:FireServer()
				end
			end
			for i,v in pairs(workspace.Casino.Loots:GetDescendants()) do
				if v:IsA("MeshPart") and (game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position - v.Position).Magnitude < 10 and v.Name == "Casino_Cash" then
					v.CasinoLootCollect:FireServer()
				end
			end
		end
	end)()
end)()


-- -- Function to handle the ChildAdded event
-- local function onChildAdded(child)
-- 	if child:IsA("Sound") then
-- 		child.Volume = 0
-- 	end
-- end

-- -- Connect the ChildAdded event to the function
-- player.ChildAdded:Connect(onChildAdded)

-- local function disableCarSound()
-- 	local SoundService = game:GetService("SoundService")
-- 	for _, descendant in pairs(SoundService:GetDescendants()) do
-- 		local parent = descendant.Parent
-- 		while parent do
-- 			if parent.Name == "Chassis" then
-- 				parent.Volume = 0
-- 				break
-- 			end
-- 			parent = parent.Parent
-- 		end
-- 	end
-- end

--Anti laser
local modifiedParts = {}

local disableTouch = LPH_NO_VIRTUALIZE(function()
	for k, part in pairs(game.Workspace:GetDescendants()) do
		if not modifiedParts[part] then
			if part.Name == "TouchInterest" then
				if part.Parent then
					local parentName = part.Parent.Name
					local grandparentName = part.Parent.Parent and part.Parent.Parent.Name
					if parentName ~= "LaserTouch" and parentName ~= "TriggerDoor" and parentName ~= "TouchToEnter" and parentName ~= "HatchTouch" and parentName ~= "TriggerFoundBossRoom" and grandparentName ~= "ExitDoor" then
						part.Parent:GetAttributeChangedSignal("CanTouch"):Connect(function()
							part.Parent.CanTouch = false
						end)
						part.Parent.CanTouch = false
						modifiedParts[part] = true
					end
				end
			end
		end
	end
end)

-- Function to handle the ChildAdded event
function onChildAdded(child)
	if child:IsA("Sound") then
		child.Volume = 0
	end
end

-- Connect the ChildAdded event to the function
player.ChildAdded:Connect(onChildAdded)

function disableCarSound()
	local SoundService = game:GetService("SoundService")
	for _, descendant in pairs(SoundService:GetDescendants()) do
		local parent = descendant.Parent
		while parent do
			if parent.Name == "Chassis" then
				parent.Volume = 0
				break
			end
			parent = parent.Parent
		end
	end
end

-- Connect to Heartbeat, but throttle the frequency (e.g., every 1 second)
local lastTime = tick()
local throttleTime = 1

RunService.Heartbeat:Connect(function()
	local currentTime = tick()
	if currentTime - lastTime >= throttleTime then
		disableTouch()
		lastTime = currentTime
	end
end)

--Noclip
local NoclipConnection
local runNCLoop
function enableNoclip()
	if NoclipConnection then
		return  -- Exit if noclip is already on
	end

	NoclipConnection = LPH_NO_VIRTUALIZE(function()
		if player.Character then
			for _, part in pairs(player.Character:GetDescendants()) do
				if part:IsA('BasePart') then
					part.CanCollide = false
				end
			end
		end
	end)
	runNCLoop = RunService.Stepped:Connect(NoclipConnection)
end
function disableNoclip()
	if NoclipConnection then
		runNCLoop:Disconnect()
		NoclipConnection = nil
	end
	if player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA('BasePart') then
				part.CanCollide = true
			end
		end
	end
end

--Send notify
Notify = function(callback)
    return require(game:GetService("ReplicatedStorage").Game.Notification).new(callback)
end


--[[ AC Bypass ]]--
local OverwriteCnt = 0
local BypassFunc = nil

LPH_NO_VIRTUALIZE(function()
	for i, v in pairs(getgc(true)) do
		if typeof(v) =="function" then
			if debug.info(v, "n"):match("CheatCheck") then
				hookfunction(v, function() end)
			end
		end
		if typeof(v) == "function" and getfenv(v).script == player.PlayerScripts.LocalScript then
			local con = getconstants(v)
			if table.find(con, "LastVehicleExit") and table.find(con, "tick") then
				BypassFunc = v
			end
		end
	end
end)()

--[[ Set up Anti Functions ]]--
-- no fall damage or ragdoll

local tagutils = require(game:GetService("ReplicatedStorage").Tag.TagUtils)
local paraglide = require(game:GetService("ReplicatedStorage").Game.Paraglide)

local old_is_point_in_tag = tagutils.isPointInTag;

tagutils.isPointInTag = function(Point, Tag)
    if Tag == "NoRagdoll" or Tag == "NoFallDamage" or Tag == "NoParachute" then
        return true
    end
    return old_is_point_in_tag(Point, Tag)
end

--[[ Set up Teleport Stuff ]]--
TeleportParams.FilterType = Enum.RaycastFilterType.Blacklist
TeleportParams.IgnoreWater = true
function CheckRaycast(Position, Vector)
	local Raycasted = workspace:Raycast(Position, Vector, TeleportParams)
	return Raycasted ~= nil
end

local raycast_params = RaycastParams.new()
local up_vector = Vector3.new(0, 500, 0)

raycast_params.FilterType = Enum.RaycastFilterType.Blacklist;
raycast_params.FilterDescendantsInstances = { game:GetService("Players").LocalPlayer.Character, workspace.Vehicles, workspace:FindFirstChild("Rain"), workspace:FindFirstChild("Bag") };

function SetChar(plrChar)
	Char, Root, Hum = plrChar, plrChar:WaitForChild("HumanoidRootPart"), plrChar:WaitForChild("Humanoid")
	TeleportParams.FilterDescendantsInstances = {Vehicles, Terrain.Clouds, Char, workspace:FindFirstChild("Rain")}
	Hum.Died:Connect(function()
		Char, Root, Hum = nil, nil, nil
	end)
end

if Player.Character and Player.Character:FindFirstChild("Humanoid") then
	SetChar(Player.Character)
end

function FTI(part)
	if Root then
		firetouchinterest(part, Root, 1)
		task.wait()
		firetouchinterest(part, Root, 0)
	end
end

Player.CharacterAdded:Connect(SetChar, Player.Character)

--[[ Get all Door Locations ]]--
LPH_NO_VIRTUALIZE(function()
	for _, Door in pairs(workspace:GetDescendants()) do
		if Door.Name:sub(-4, -1) == "Door" then
			local DoorTouch = Door:FindFirstChild("Touch")

			if DoorTouch and DoorTouch:IsA("BasePart") then
				for _, instance in pairs(Door:GetDescendants()) do
					pcall(function()
						instance.CanCollide = false
					end)
					pcall(function()
						instance.Transparency = 1.000
					end)
				end
				for Distance = 7, 100, 7 do
					local DoorF = DoorTouch.Position + DoorTouch.CFrame.LookVector * (Distance + 20)
					local DoorB = DoorTouch.Position + DoorTouch.CFrame.LookVector * -(Distance + 20)
					if not CheckRaycast(DoorF, Vector3.new(0, 1000, 0)) then
						table.insert(door_positions, DoorF)
						break
					elseif not CheckRaycast(DoorB, Vector3.new(0, 1000, 0)) then
						table.insert(door_positions, DoorB)
						break
					end
				end
			end
		end
	end
end)()

function DistanceXZ(firstPos, secondPos)
	local XZVector = Vector3.new(firstPos.X, 0, firstPos.Z) - Vector3.new(secondPos.X, 0, secondPos.Z)
	return XZVector.Magnitude
end

function Arrested()
	if Player.PlayerGui.MainGui.CellTime.Visible == true or Player.Folder:FindFirstChild("Cuffed") then
		return true
	end
	return false
end

function Lag(part)
	local ShouldStop = false
	local OldPosition = part.Position
	local Signal = part:GetPropertyChangedSignal("CFrame"):Connect(LPH_NO_VIRTUALIZE(function()
		local CurrentPosition = part.Position
		if DistanceXZ(CurrentPosition, OldPosition) > 7 then
			LaggedBack = true
			task.delay(0.2, function()
				LaggedBack = false
			end)
		end
	end))
	task.spawn(function()
		while part and ShouldStop == false do
			OldPosition = part.Position
			task.wait()
		end
	end)
	return {
		Stop = function()
			ShouldStop = true
			Signal:Disconnect()
		end
	}
end

function noClipStart()
	local NoclipLoop = LPH_NO_VIRTUALIZE(function()
		pcall(function()
			for i, child in pairs(Char:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true then
					child.CanCollide = false
				end
			end
		end)
	end)
	local Noclipper = RunService.Stepped:Connect(NoclipLoop)

	return {
		Stop = function()
			Noclipper:Disconnect()
		end
	}
end

function InstantEscape()
    local distance
    repeat
        game:GetService("Players").LocalPlayer.Character:PivotTo(CFrame.new(-1425.38720703125, 122.0971450805664, 2822.10009765625))
        task.wait(0.01)
        distance = (game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position - Vector3.new(-1425.54345703125, 41.46807098388672, 2821.73193359375)).Magnitude
    until distance < 2
	task.wait()
    Small(CFrame.new(-1442.767333984375, 41.46807098388672, 2829.26806640625))
	task.wait(.2)
	if Player.TeamColor == BrickColor.new("Bright orange")  then
		repeat
			task.wait()
		until Player.TeamColor ~= BrickColor.new("Bright orange")
	end
	spawnCar()
	local waitCounter = 5
	for i = 1, 9e9 do
		task.wait(1)
		waitCounter -= 1
		if waitCounter == 0 then
			break
		end
		if GetVehiclePacket() then
			break
		end
	end
	task.wait(.2)
end

function ExitCar()
	BypassFunc()
	repeat
		task.wait(0.1)
	until not GetVehiclePacket()
	task.wait(.1)
end

function Small(cframe)
	if not Char or not Root or Arrested() then
		return false
	end

	if settingsShort.player_speed <= 0 then
        settingsShort.player_speed = 1
        Notify({Text="The player movement speed can't be negative or equal to 0!"})
    end

    if settingsShort.player_speed > 160 then
        settingsShort.player_speed = 160
        Notify({Text="The max player movement speed is 160!"})
    end

	HideCar()
	local IsTargetMoving = type(cframe) == "function"
	local LagCheck = Lag(Root)
	local Noclip = noClipStart()
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local LagbackCount = 0
	local Success = true
	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	repeat
		if not Root or Hum.Health == 0 or Arrested() then
			Success = false
		else
			TargetPos = (IsTargetMoving and cframe() or cframe).Position
			Mover.Velocity = CFrame.new(Root.Position, TargetPos).LookVector * settingsShort.player_speed
			Hum:SetStateEnabled("Running", false)
			Hum:SetStateEnabled("Climbing", false)

			task.wait(0.03)

			if LaggedBack then
				LagbackCount = LagbackCount + 1
				Mover.Velocity = Vector3.zero
				task.wait(.5)
				if LagbackCount == 5 then
					Mover:Destroy()
					Noclip:Stop()
					LagCheck:Stop()
					if GetVehicleModel() then
						ExitCar()
					end
					Hum.Health = 0
					replaceStatus("Resetting to fix path (lower your speed!)")
					Success = false
					task.wait(7)
					InstantEscape()
					error("Close function")
				end
			end
		end
	until (Root.Position - TargetPos).Magnitude <= 5 or not Success
	if Success then
		Mover.Velocity = Vector3.new(0, 0, 0)
		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		Root.CFrame = CFrame.new(TargetPos)
		task.wait(0.001)
		Hum:SetStateEnabled("Running", true)
		Hum:SetStateEnabled("Climbing", true)

		Mover:Destroy()
		Noclip:Stop()
		LagCheck:Stop()
	end
	return Success
end

function SmallWithOrientation(cframe)
	if not Char or not Root or Arrested() then
		return false
	end

	if settingsShort.player_speed <= 0 then
        settingsShort.player_speed = 1
        Notify({Text="The player movement speed can't be negative or equal to 0!"})
    end

    if settingsShort.player_speed > 160 then
        settingsShort.player_speed = 160
        Notify({Text="The max player movement speed is 160!"})
    end


	HideCar()
	local IsTargetMoving = type(cframe) == "function"
	local LagCheck = Lag(Root)
	local Noclip = noClipStart()
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local LagbackCount = 0
	local Success = true
	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	repeat
		if not Root or Hum.Health == 0 or Arrested() then
			Success = false
		else
			TargetPos = (IsTargetMoving and cframe() or cframe).Position
			Mover.Velocity = CFrame.new(Root.Position, TargetPos).LookVector * settingsShort.player_speed
			Hum:SetStateEnabled("Running", false)
			Hum:SetStateEnabled("Climbing", false)
			task.wait(0.03)

			if LaggedBack then
				LagbackCount = LagbackCount + 1
				Mover.Velocity = Vector3.zero
				task.wait(.5)
				if LagbackCount == 5 then
					Mover:Destroy()
					Noclip:Stop()
					LagCheck:Stop()
					Hum.Health = 0
					replaceStatus("Resetting to fix path (lower your speed!)")
					Success = false
					task.wait(7)
					InstantEscape()
					error("Close function")
				end
			end
		end
	until (Root.Position - TargetPos).Magnitude <= 5 or not Success
	if Success then
		Mover.Velocity = Vector3.new(0, 0, 0)
		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		Root.CFrame = (IsTargetMoving and cframe() or cframe)
		task.wait(0.001)
		Hum:SetStateEnabled("Running", true)
		Hum:SetStateEnabled("Climbing", true)

		Mover:Destroy()
		Noclip:Stop()
		LagCheck:Stop()
	end
	return Success
end

function FindD(tried)
	local Distance, Nearest, tried = math.huge, nil, tried or {}
	for _, Position in pairs(door_positions) do
		if not table.find(tried, Position) then
			local Magnitude = (Position - Root.Position).Magnitude
			if Magnitude < Distance then
				Distance = Magnitude
				Nearest = Position
			end
		end
	end
	local RenderedPath = PathfindingService:CreatePath({WaypointSpacing = 5})
	RenderedPath:ComputeAsync(Root.Position, Nearest)
	if RenderedPath.Status == Enum.PathStatus.Success then
		local waypoints = RenderedPath:GetWaypoints()
		for i, waypoint in pairs(waypoints) do
			if not Small(CFrame.new(waypoint.Position + Vector3.new(0, 3.5, 0)), 40) then return end
			if not CheckRaycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
				return true
			end
		end
	end
	if not CheckRaycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
		return true
	end
	return FindD(tried)
end

function BigT(cframe)
	if not Char or not Root or Arrested() then
		return false
	end

    if settingsShort.player_speed <= 0 then
        settingsShort.player_speed = 1
        Notify({Text="The player movement speed can't be negative or equal to 0!"})
    end

    if settingsShort.player_speed > 160 then
        settingsShort.player_speed = 160
        Notify({Text="The max player movement speed is 160!"})
    end

	local IsTargetMoving = type(cframe) == "function"

	if DistanceXZ(Root.Position, (IsTargetMoving and cframe() or cframe).Position) < 20 then
		Root.CFrame = CFrame.new((IsTargetMoving and cframe() or cframe).Position)
		return true
	end

	if CheckRaycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
		FindD()
		task.wait(0.5)
	end
	local LagCheck = Lag(Root)
	local Noclip = noClipStart()
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local TargetOffset = Vector3.new(TargetPos.X, 1000, TargetPos.Z)
	local LagbackCount = 0
	local Success = true
	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	repeat
		if not Root or Hum.Health == 0 or Arrested() then
			Success = false
		else
			TargetPos = (IsTargetMoving and cframe() or cframe).Position
			TargetOffset = Vector3.new(TargetPos.X, 1000, TargetPos.Z)

			Root.CFrame = CFrame.new(Root.CFrame.X, 1000, Root.CFrame.Z)
			Mover.Velocity = (TargetOffset - Root.Position).Unit * settingsShort.player_speed
			task.wait(0.03)

			if LaggedBack then
				LagbackCount = LagbackCount + 1
				Mover.Velocity = Vector3.zero
				task.wait(.5)
				if CheckRaycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
					FindD()
					task.wait(0.5)
				end
				if LagbackCount == 10 then
					Mover:Destroy()
					Noclip:Stop()
					LagCheck:Stop()
					if GetVehicleModel() then
						ExitCar()
					end
					Hum.Health = 0
					replaceStatus("Resetting to fix path (lower your speed!)")
					Success = false
					task.wait(7)
					InstantEscape()
					error("Close function")
				end
			end
		end
		if GetVehiclePacket() then
			Mover.Velocity = Vector3.zero
			ExitCar()
			repeat task.wait() until not GetVehiclePacket()
		end
	until not Success or DistanceXZ(Root.Position, TargetOffset) < 15
	if Success then
		Mover.Velocity = Vector3.new(0, 0, 0)
		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		Root.CFrame = CFrame.new(TargetPos)
		task.wait(0.05)
		Mover:Destroy()
		Noclip:Stop()
		LagCheck:Stop()
		task.wait(0.6)
		if (Root.Position - TargetPos).Magnitude > 30 then
			return BigT(cframe)
		end
	end
	return Success
end

function HideCar()
	if GetVehiclePacket() then
		LPH_NO_VIRTUALIZE(function()
			for _, v in pairs(GetVehicleModel():GetDescendants()) do
				pcall(function()
					v.CanCollide = false
				end)
			end
		end)()
	end
end

function unHideCar()
	if GetVehiclePacket() then
		LPH_NO_VIRTUALIZE(function()
			for _, v in pairs(GetVehicleModel():GetDescendants()) do
				pcall(function()
					v.CanCollide = true
				end)
			end
		end)()
	end
end

function IsCarLock()
	local Success, Result = pcall(function()
		return Player.PlayerGui.AppUI.Speedometer.Top.Lock.Icon.Image
	end)
	if Success then
		return Result ~= "rbxassetid://5928936296"
	end
end

function LockCar()
	if GetVehiclePacket() and not IsCarLock() then
		Other_Modules.Vehicle.toggleLocalLocked()
	end
end

function EnterVehicle()
    if not Char or not Root or Arrested() then
		return false
	end

    if GetVehiclePacket() and (table.find(OwnedHelis, GetVehicleModel().Name) or table.find(OwnedCars, GetVehicleModel().Name)) then
		HideCar()
		return true
	else
		BypassFunc()
		repeat task.wait() until not GetVehiclePacket()
	end
    local SortedCars = Vehicles:GetChildren()
	table.sort(SortedCars, function(v, v2)
		local v3 = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
		local v4 = v2.PrimaryPart or v2:FindFirstChildWhichIsA("Part")
		if v3 ~= nil and v4 ~= nil then
			return DistanceXZ(v3.Position, Root.Position) < DistanceXZ(v4.Position, Root.Position)
		end
	end)
	if GetVehiclePacket() and (table.find(OwnedCars, GetVehicleModel().Name) and Other_Modules.store._state.garageOwned.Vehicles[GetVehicleModel().Name]) then
        HideCar()
		return GetVehicleModel()
	end
    for _, v in pairs(SortedCars) do
		if v.PrimaryPart ~= nil and v.Seat.PlayerName.Value == "" and (table.find(OwnedHelis, v.Name) or table.find(OwnedCars, v.Name)) and not CheckRaycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then
			if not BigT(v.Seat.CFrame + Vector3.new(0, 3, 0)) then return false end
			local Timeout = tick()
			repeat
				if v.PrimaryPart and v.Seat then
					Root.Velocity = Vector3.new(0, 0, 0)
					for _, spec in pairs(Other_Modules.UI.CircleAction.Specs) do
							if spec.Part == v.Seat then
							spec:Callback(true)
						end
					end
				end
				if DistanceXZ(Root.Position, v.PrimaryPart.Position) > 20 then
					if not BigT(v.Seat.CFrame + Vector3.new(0, 3, 0)) then return false end
				end
				task.wait(0.3)
			until GetVehiclePacket() or tick() - Timeout > 5
			if GetVehiclePacket() then
				HideCar()
				return GetVehiclePacket()
			end
		end
	end
    return EnterVehicle()
end

function EnterHeli()
	if not Char or not Root or Arrested() then
		return false
	end

	if GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
		HideCar()
		return true
	else
		BypassFunc()
		repeat task.wait() until not GetVehiclePacket()
	end
	local SortedCars = Vehicles:GetChildren()
	table.sort(SortedCars, function(v, v2)
		local v3 = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
		local v4 = v2.PrimaryPart or v2:FindFirstChildWhichIsA("Part")
		if v3 ~= nil and v4 ~= nil then
			return DistanceXZ(v3.Position, Root.Position) < DistanceXZ(v4.Position, Root.Position)
		end
	end)
	if GetVehiclePacket() and (table.find(OwnedHelis, GetVehicleModel().Name) and (Other_Modules.store._state.garageOwned.Vehicles[GetVehicleModel().Name])) then
		return GetVehicleModel()
	end
	for _, v in pairs(SortedCars) do
		if v.PrimaryPart ~= nil and v.Seat.PlayerName.Value == "" and table.find(OwnedHelis, v.Name) and not CheckRaycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then
			if not BigT(v.Seat.CFrame + Vector3.new(0, 3, 0)) then return false end
			local Timeout = tick()
			repeat
				if v.PrimaryPart and v.Seat then
					Root.Velocity = Vector3.new(0, 0, 0)
					for _, spec in pairs(Other_Modules.UI.CircleAction.Specs) do
							if spec.Part == v.Seat then
							spec:Callback(true)
						end
					end
				end
				if DistanceXZ(Root.Position, v.PrimaryPart.Position) > 20 then
					if not BigT(v.Seat.CFrame + Vector3.new(0, 3, 0)) then return false end
				end
				task.wait(0.3)
			until GetVehiclePacket() or tick() - Timeout > 5
			if GetVehiclePacket() then
				HideCar()
				return GetVehiclePacket()
			end
		end
	end
	return EnterHeli()
end

function EnterCar()
    if not Char or not Root or Arrested() then
		return false
	end

    if GetVehiclePacket() and (table.find(OwnedHelis, GetVehicleModel().Name) or table.find(OwnedCars, GetVehicleModel().Name)) then
		HideCar()
		return true
	else
		BypassFunc()
		repeat task.wait() until not GetVehiclePacket()
	end
    local SortedCars = Vehicles:GetChildren()
	table.sort(SortedCars, function(v, v2)
		local v3 = v.PrimaryPart or v:FindFirstChildWhichIsA("Part")
		local v4 = v2.PrimaryPart or v2:FindFirstChildWhichIsA("Part")
		if v3 ~= nil and v4 ~= nil then
			return DistanceXZ(v3.Position, Root.Position) < DistanceXZ(v4.Position, Root.Position)
		end
	end)
	if GetVehiclePacket() and (table.find(OwnedCars, GetVehicleModel().Name) and Other_Modules.store._state.garageOwned.Vehicles[GetVehicleModel().Name]) then
        HideCar()
		return GetVehicleModel()
	end
    for _, v in pairs(SortedCars) do
		if v.PrimaryPart ~= nil and v.Seat.PlayerName.Value == "" and table.find(OwnedCars, v.Name) and not CheckRaycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then
			if not BigT(v.Seat.CFrame + Vector3.new(0, 3, 0)) then return false end
			local Timeout = tick()
			repeat
				if v.PrimaryPart and v.Seat then
					Root.Velocity = Vector3.new(0, 0, 0)
					for _, spec in pairs(Other_Modules.UI.CircleAction.Specs) do
							if spec.Part == v.Seat then
							spec:Callback(true)
						end
					end
				end
				if DistanceXZ(Root.Position, v.PrimaryPart.Position) > 20 then
					if not BigT(v.Seat.CFrame + Vector3.new(0, 3, 0)) then return false end
				end
				task.wait(0.3)
			until GetVehiclePacket() or tick() - Timeout > 5
			if GetVehiclePacket() then
				HideCar()
				return GetVehiclePacket()
			end
		end
	end
    return EnterCar()
end


local MoneyMade, RunTime = 0, 0
local ServerStartMoney = Player:WaitForChild("leaderstats"):WaitForChild("Money").Value
local queuedMoney = false
local start = ""

function FormatCash(number)
	local totalnum = tostring(number):split("")

	if #totalnum == 7 then
		return totalnum[1].."."..totalnum[2].."M"
	elseif #totalnum >= 10 then
		return totalnum[1].."."..totalnum[2].."B"
	elseif #totalnum == 4 and #totalnum[2] == 0 then
		return totalnum[1].."k"
	elseif #totalnum == 4  then
		return totalnum[1].."."..totalnum[2].."k"
	elseif #totalnum == 5  then
		return totalnum[1]..totalnum[2].."."..totalnum[3].."k"
	elseif #totalnum == 6  then
		return totalnum[1]..totalnum[2]..totalnum[3].."k"
	else
		return number
	end
end

function TickToHMS(seconds)
local minutes = (seconds - seconds % 60) / 60
seconds = seconds % 60
local hours = (minutes - minutes % 60) / 60
minutes = minutes % 60

return string.format("%dh/%dm/%ds", hours, minutes, seconds)
end

function Teleport()

if queuedMoney == false then
	queuedMoney = true

	start = start .. " getgenv().StartingMoney = " .. getgenv().StartingMoney
	start = start .. " getgenv().StartingTime = " .. getgenv().StartingTime

	if syn then
		syn.queue_on_teleport(start)
	else
	queue_on_teleport(start)
	end

	local earningsSoFar = 0
	pcall(function()
		earningsSoFar = Player.leaderstats.Money.Value - ServerStartMoney
	end)
	warn("You made $" .. FormatCash(earningsSoFar) .. " this session")
end

while true do
	local Servers = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
	local Server, Next = nil, nil

	function ListServers(cursor)
		local Raw = game:HttpGet(Servers .. ((cursor and "&cursor="..cursor) or ""))

		return HttpService:JSONDecode(Raw)
	end

	repeat
		local Servers = ListServers(Next)
		Server = Servers.data[math.random(1, (#Servers.data / 3))]
		Next = Servers.nextPageCursor
	until Server
	if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
		warn(pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, Player)
		end))
	end
	task.wait(1)
end
end

function CarT(cframe, offset)
	if not Char or not Root or Arrested() then
		return false
	end
	if not GetVehiclePacket() then
		local IsTargetMoving = type(cframe) == "function"
		local TargetPos = (IsTargetMoving and cframe() or cframe).Position
		if DistanceXZ(Root.Position, TargetPos) < 150 then
			return BigT(cframe)
		end
		if not EnterVehicle() then
            warn"No car avalible // Universal Farm"
        end
	end
	offset = (offset or 1000)

	HideCar()

	local IsTargetMoving = type(cframe) == "function"
	local CarModel = GetVehicleModel().PrimaryPart
	local CarModelPart = GetVehicleModel()
	local LagCheck = Lag(CarModel)
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local TargetOffset = Vector3.new(TargetPos.X, offset, TargetPos.Z)
	local LagbackCount = 0
	local Success = true
	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	local helicopterSpeed = settingsShort.heli_speed
	local vehicleSpeeds = settingsShort.vehicle_speed

	repeat
		if not Root or Hum.Health == 0 or Arrested() or not GetVehiclePacket() then
			Success = false
			if GetVehicleModel() then
				ExitCar()
			end
			Hum.Health = 0
			replaceStatus("Error while teleporting.. resetting")
			Success = false
			task.wait(7)
			InstantEscape()
			error("Close function")
		else
			TargetPos = (IsTargetMoving and cframe() or cframe).Position
			TargetOffset = Vector3.new(TargetPos.X, offset, TargetPos.Z)
			CarModel.CFrame = CFrame.new(CarModel.CFrame.X, offset, CarModel.CFrame.Z)
			if GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
				Mover.Velocity = (TargetOffset - CarModel.Position).Unit * helicopterSpeed
			elseif GetVehiclePacket() and table.find(OwnedCars, GetVehicleModel().Name) then
				Mover.Velocity = (TargetOffset - CarModel.Position).Unit * vehicleSpeeds
			else
				warn"No car data in the tables // Universal Farm"
			end
			task.wait(0.03)
            if DistanceXZ(CarModel.Position, TargetOffset) < 100 then
				if GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
					helicopterSpeed = (settingsShort.heli_speed / 8)
				else
					warn"No car data in the tables // Universal Farm"
				end
			else
				if GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
					helicopterSpeed = settingsShort.heli_speed
				else
					warn"No car data in the tables // Universal Farm"
				end
            end
			if LaggedBack then
				LagbackCount = LagbackCount + 1
				Mover.Velocity = Vector3.zero
				task.wait(.5)
				if LagbackCount == 10 then
					Mover:Destroy()
					if offset == 1000 then
						LagCheck:Stop()
					end
					if GetVehicleModel() then
						ExitCar()
					end
					Hum.Health = 0
					replaceStatus("Resetting to fix path (lower your speed!)")
					Success = false
					task.wait(7)
					InstantEscape()
					error("Close function")
				end
			end
		end
	until not Success or DistanceXZ(CarModel.Position, TargetOffset) < 15
	reached = true
	reachedEvent:Fire()
	if Success then
        settingsShort.vehicle_speed = settingsShort.vehicle_speed
		LockCar()
		Mover.Velocity = Vector3.new(0, 0.01, 0)
		task.wait(0.01)
		Mover:Destroy()
		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		CarModel.CFrame = CFrame.new(TargetPos)
		task.wait(0.01)
		LagCheck:Stop()
	end
	return Success
end

function InstantT(cframe, offset)
	if not Char or not Root or Arrested() then
		return false
	end
	if not GetVehiclePacket() then
		local IsTargetMoving = type(cframe) == "function"
		local TargetPos = (IsTargetMoving and cframe() or cframe).Position
		if DistanceXZ(Root.Position, TargetPos) < 150 then
			return BigT(cframe)
		end
		if not EnterCar() then
            warn"No car avalible // Universal Farm"
        end
	end
	offset = (offset or 1000)

	HideCar()

	local IsTargetMoving = type(cframe) == "function"
	local CarModel = GetVehicleModel().PrimaryPart
	local CarModelPart = GetVehicleModel()
	local LagCheck = Lag(CarModel)
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local TargetOffset = Vector3.new(TargetPos.X, offset, TargetPos.Z)
	local LagbackCount = 0
	local Success = true
	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	repeat
		if not Root or Hum.Health == 0 or Arrested() then
			Success = false
			if GetVehicleModel() then
				ExitCar()
			end
			Hum.Health = 0
			replaceStatus("Error while teleporting.. resetting")
			Success = false
			task.wait(7)
			error("Close function")
		else
			TargetPos = (IsTargetMoving and cframe() or cframe).Position
			TargetOffset = Vector3.new(TargetPos.X, offset, TargetPos.Z)
			CarModel.CFrame = CFrame.new(CarModel.CFrame.X, offset, CarModel.CFrame.Z)
			if GetVehiclePacket() then
				repeat
					GetVehicleModel().PrimaryPart.CFrame = cframe
					task.wait(0.01)
				until not GetVehiclePacket() or Hum.Health == 0 or Arrested()
			else
				warn"No car data in the tables // Universal Farm"
			end
		end
	until not Success or DistanceXZ(CarModel.Position, TargetOffset) < 15
	reached = true
	reachedEvent:Fire()
	if Success then
        settingsShort.vehicle_speed = settingsShort.vehicle_speed
		LockCar()
		Mover.Velocity = Vector3.new(0, 0.01, 0)
		task.wait(0.01)
		Mover:Destroy()
		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		CarModel.CFrame = CFrame.new(TargetPos)
		task.wait(0.01)
		LagCheck:Stop()
	end
	return Success
end

-- [[ Locations For AutoRob ]]
-- setclipboard(tostring(game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position))
-- setclipboard(tostring(game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame))

local robCargoLocation = CFrame.new(-472, 167, 1923)
local homeCFrame = CFrame.new(111, 5000, -995)
local cargoPlaneSell = CFrame.new(-347, 23, 2051)
local oilRigSell = CFrame.new(-507, 33, 2131)
local criminalBaseCity = CFrame.new(-244, 20, 1615)
local volcano = CFrame.new(2197, 81, -2578)
local powerOutside = CFrame.new(79, 23, 2371)
local casinoTop = CFrame.new(50, 155, -4733)
local oilPlatform = CFrame.new(-2785, 134, -4066)
local jewelryOut = CFrame.new(137, 21, 1375)

if not getgenv().StartingMoney then
getgenv().StartingMoney = Player.leaderstats.Money.Value
end

if not getgenv().StartingTime then
getgenv().StartingTime = os.time()
end

pcall(function()
MoneyMade = Player:WaitForChild("leaderstats"):WaitForChild("Money").Value - getgenv().StartingMoney
end)

pcall(function()
RunTime = os.time() - getgenv().StartingTime
end)

local PuzzleFlow = require(game.ReplicatedStorage.Game.Robbery.PuzzleFlow)
local Puzzle = getupvalue(PuzzleFlow.Init, 3)
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local Request = (syn and syn.request) or (http and http.request) or request
function SolveNumberLink()
	if PlayerGui:FindFirstChild("FlowGui") then
		repeat task.wait()
			local Success = false

			pcall(function()
				local GridCopy = {}

				for i,v in pairs(Puzzle.Grid) do
					GridCopy[i] = {}
					for i2,v2 in pairs(v) do
						GridCopy[i][i2] = v2 + 1
					end
				end

				local Body = Request({
					Url = "https://numberlink-solver.brizzy9999.repl.co",
					Method = "POST",
					Body = HttpService:JSONEncode({
						Matrix = GridCopy
					}),
					Headers = {
						["Content-Type"] = "application/json"
					}
				}).Body

				local Solution = HttpService:JSONDecode(Body).Solution

				for i, row in ipairs(Solution) do
					for i2, val in ipairs(row) do
						Puzzle.Grid[i][i2] = val
						Puzzle.OnConnection()
					end
				end

				WaitUntil(function()
					return not PlayerGui:FindFirstChild("FlowGui")
				end, 5)

				Success = true
			end, "SolveNumberlink")

			if not Success then
				Puzzle:Reset()
			end
		until not PlayerGui:FindFirstChild("FlowGui")
	end
end

function TPhome()
	replaceStatus("Teleporting to Home")
	CarT(homeCFrame, offset)
	unHideCar()
	platform.CFrame = CFrame.new(player.Character.PrimaryPart.Position.X, 4990, player.Character.PrimaryPart.Position.Z)
end

function sellVolcano()
	replaceStatus("Teleporting to Volcano Base")
	CarT(volcano, offset)
	task.wait(.1)
	Small(volcano)
	replaceStatus("Selling")
	local Points = { CFrame.new(2285, 71, -2590), CFrame.new(2285, 28, -2589) }
	for _, v in next, Points do
		Small(v)
	end
	repeat
		wait()
	until game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == false
	replaceStatus("Escaping")
	local Points = { CFrame.new(2285, 71, -2590), volcano}
	for _, v in next, Points do
		Small(v)
	end
	Small(volcano * CFrame.new(0, 150, 0))
	task.wait(.5)
end

function break_npcs()
	local npccanSeeTarget

	local function on_loadup()
		npccanSeeTarget = require(game:GetService("ReplicatedStorage").GuardNPC.GuardNPCShared).canSeeTarget
	end
	on_loadup()
	local function hook(x, y)
		local canSeeTarget = npccanSeeTarget
		if disableNpcs then
			return wait(9e9)
		end
		return canSeeTarget(x, y)
	end
	require(game:GetService("ReplicatedStorage").GuardNPC.GuardNPCShared).canSeeTarget = hook
end
break_npcs()

function hasKey()
	local inventoryItemSystem = Other_Modules.inventoryItemSystem
	local gameUtil = Other_Modules.gameUtil
	local settings = Other_Modules.settings
	if gameUtil.Team == settings.EnumTeam.Police then
		return true
	end
	return inventoryItemSystem.playerHasItem(player, "Key")
end

hasKey()

Other_Modules.TeamChooseUI.Hide()
task.wait(0.5)

--#region HyperLogging
local connectedToMessageReceived = false
-- Function to ` Discord Webhook message
function sendDiscord()
local fieldsString = "Time from start: " .. TickToHMS(RunTime) .. "\nLevel: Level " .. whatLevel
local wrappedFieldsContent = "```\n" .. fieldsString .. "\n```"
local data = {
	["content"] = "<@"..settingsShort.userIdNum..">",
	['embeds'] = {{
		['title'] = "You have earned a " .. whatColor .. "HyperChrome",
		['color'] = 82888,
		['description'] = wrappedFieldsContent
	}},
}
	local newdata = game:GetService("HttpService"):JSONEncode(data)
	local headers = {
		["content-type"] = "application/json"
	}
	request = http_request or request or HttpPost or syn.request
	local abcdef = {Url = settingsShort.url, Body = newdata, Method = "POST", Headers = headers}
	request(abcdef)
end

-- Function to handle all incoming messages
local function HandleChatMessage(textChatMessage)
	local messageText = tostring(textChatMessage.Text)
	local color, level = string.match(messageText, player.Name .. " got a Hyper(%a+)%s*Lvl(%d+)")

	if color and level and not messageSent then
		local colorMappings = {
			Blue = "Blue",
			Red = "Red",
			Orange = "Orange",
			Yellow = "Yellow",
			Green = "Green",
			Diamond = "Diamond",
			Purple = "Purple",
			Pink = "Pink",
		}

		-- Check if the color is mapped and set level
		whatColor = colorMappings[color] or "Unknown"
		whatLevel = tonumber(level)

		sendDiscord()
		settingsShort.hyperCount = settingsShort.hyperCount + 1
		messageSent = true
		-- Delay for 5 seconds before allowing another message to be sent
		wait(5)
		messageSent = false
	end
end

local function checkReceive()
	if not connectedToMessageReceived then
		TextChatService.MessageReceived:Connect(HandleChatMessage)
		connectedToMessageReceived = true  -- Set the flag to true to indicate that the event is connected
	end
end
task.spawn(function()
	while task.wait(1) do
		if settingsShort.doHyperLog == true and messageSent == false then
			checkReceive()
		end
	end
end)
--#endregion

--#region otherLogging

--#endregion

--#endregion

--#region actualGUISource
local ui_options = {
	main_color = Color3.fromRGB(41, 74, 122),
	min_size = Vector2.new(400, 300),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
}

do
	local imgui = game:GetService("CoreGui"):FindFirstChild("UniversalFarm")
	if imgui then imgui:Destroy() end
end

local imgui = Instance.new("ScreenGui")
local Prefabs = Instance.new("Frame")
local Label = Instance.new("TextLabel")
local Window = Instance.new("ImageLabel")
local Resizer = Instance.new("Frame")
local Bar = Instance.new("Frame")
local Toggle = Instance.new("ImageButton")
local Base = Instance.new("ImageLabel")
local Top = Instance.new("ImageLabel")
local Tabs = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TabSelection = Instance.new("ImageLabel")
local TabButtons = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Frame = Instance.new("Frame")
local Tab = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local TextBox = Instance.new("TextBox")
local TextBox_Roundify_4px = Instance.new("ImageLabel")
local Slider = Instance.new("ImageLabel")
local Title_2 = Instance.new("TextLabel")
local Indicator = Instance.new("ImageLabel")
local Value = Instance.new("TextLabel")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local Circle = Instance.new("ImageLabel")
local UIListLayout_3 = Instance.new("UIListLayout")
local Dropdown = Instance.new("TextButton")
local Indicator_2 = Instance.new("ImageLabel")
local Box = Instance.new("ImageButton")
local Objects = Instance.new("ScrollingFrame")
local UIListLayout_4 = Instance.new("UIListLayout")
local TextButton_Roundify_4px = Instance.new("ImageLabel")
local TabButton = Instance.new("TextButton")
local TextButton_Roundify_4px_2 = Instance.new("ImageLabel")
local Folder = Instance.new("ImageLabel")
local Button = Instance.new("TextButton")
local TextButton_Roundify_4px_3 = Instance.new("ImageLabel")
local Toggle_2 = Instance.new("ImageLabel")
local Objects_2 = Instance.new("Frame")
local UIListLayout_5 = Instance.new("UIListLayout")
local HorizontalAlignment = Instance.new("Frame")
local UIListLayout_6 = Instance.new("UIListLayout")
local Console = Instance.new("ImageLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local Source = Instance.new("TextBox")
local Comments = Instance.new("TextLabel")
local Globals = Instance.new("TextLabel")
local Keywords = Instance.new("TextLabel")
local RemoteHighlight = Instance.new("TextLabel")
local Strings = Instance.new("TextLabel")
local Tokens = Instance.new("TextLabel")
local Numbers = Instance.new("TextLabel")
local Info = Instance.new("TextLabel")
local Lines = Instance.new("TextLabel")
local ColorPicker = Instance.new("ImageLabel")
local Palette = Instance.new("ImageLabel")
local Indicator_3 = Instance.new("ImageLabel")
local Sample = Instance.new("ImageLabel")
local Saturation = Instance.new("ImageLabel")
local Indicator_4 = Instance.new("Frame")
local Switch = Instance.new("TextButton")
local TextButton_Roundify_4px_4 = Instance.new("ImageLabel")
local Title_3 = Instance.new("TextLabel")
local Button_2 = Instance.new("TextButton")
local TextButton_Roundify_4px_5 = Instance.new("ImageLabel")
local DropdownButton = Instance.new("TextButton")
local Keybind = Instance.new("ImageLabel")
local Title_4 = Instance.new("TextLabel")
local Input = Instance.new("TextButton")
local Input_Roundify_4px = Instance.new("ImageLabel")
local Windows = Instance.new("Frame")

imgui.Name = "UniversalFarm"
imgui.Parent = game:GetService("CoreGui")

Prefabs.Name = "Prefabs"
Prefabs.Parent = imgui
Prefabs.BackgroundColor3 = Color3.new(1, 1, 1)
Prefabs.Size = UDim2.new(0, 100, 0, 100)
Prefabs.Visible = false

Label.Name = "Label"
Label.Parent = Prefabs
Label.BackgroundColor3 = Color3.new(1, 1, 1)
Label.BackgroundTransparency = 1
Label.Size = UDim2.new(0, 200, 0, 20)
Label.Font = Enum.Font.GothamSemibold
Label.Text = "Hello, world 123"
Label.TextColor3 = Color3.new(1, 1, 1)
Label.TextSize = 14
Label.TextXAlignment = Enum.TextXAlignment.Left

Window.Name = "Window"
Window.Parent = Prefabs
Window.Active = true
Window.BackgroundColor3 = Color3.new(1, 1, 1)
Window.BackgroundTransparency = 1
Window.ClipsDescendants = true
Window.Position = UDim2.new(0, 20, 0, 20)
Window.Selectable = true
Window.Size = UDim2.new(0, 200, 0, 200)
Window.Image = "rbxassetid://2851926732"
Window.ImageColor3 = Color3.new(0.0823529, 0.0862745, 0.0901961)
Window.ScaleType = Enum.ScaleType.Slice
Window.SliceCenter = Rect.new(12, 12, 12, 12)

Resizer.Name = "Resizer"
Resizer.Parent = Window
Resizer.Active = true
Resizer.BackgroundColor3 = Color3.new(1, 1, 1)
Resizer.BackgroundTransparency = 1
Resizer.BorderSizePixel = 0
Resizer.Position = UDim2.new(1, -20, 1, -20)
Resizer.Size = UDim2.new(0, 20, 0, 20)

Bar.Name = "Bar"
Bar.Parent = Window
Bar.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
Bar.BorderSizePixel = 0
Bar.Position = UDim2.new(0, 0, 0, 5)
Bar.Size = UDim2.new(1, 0, 0, 15)

Toggle.Name = "Toggle"
Toggle.Parent = Bar
Toggle.BackgroundColor3 = Color3.new(1, 1, 1)
Toggle.BackgroundTransparency = 1
Toggle.Position = UDim2.new(0, 5, 0, -2)
Toggle.Rotation = 0
Toggle.Size = UDim2.new(0, 20, 0, 20)
Toggle.ZIndex = 2
Toggle.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=15768480457"

Base.Name = "Base"
Base.Parent = Bar
Base.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
Base.BorderSizePixel = 0
Base.Position = UDim2.new(0, 0, 0.800000012, 0)
Base.Size = UDim2.new(1, 0, 0, 10)
Base.Image = "rbxassetid://2851926732"
Base.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
Base.ScaleType = Enum.ScaleType.Slice
Base.SliceCenter = Rect.new(12, 12, 12, 12)

Top.Name = "Top"
Top.Parent = Bar
Top.BackgroundColor3 = Color3.new(1, 1, 1)
Top.BackgroundTransparency = 1
Top.Position = UDim2.new(0, 0, 0, -5)
Top.Size = UDim2.new(1, 0, 0, 10)
Top.Image = "rbxassetid://2851926732"
Top.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
Top.ScaleType = Enum.ScaleType.Slice
Top.SliceCenter = Rect.new(12, 12, 12, 12)

Tabs.Name = "Tabs"
Tabs.Parent = Window
Tabs.BackgroundColor3 = Color3.new(1, 1, 1)
Tabs.BackgroundTransparency = 1
Tabs.Position = UDim2.new(0, 15, 0, 60)
Tabs.Size = UDim2.new(1, -30, 1, -60)

Title.Name = "Title"
Title.Parent = Window
Title.BackgroundColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 30, 0, 3)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "Gamer Time"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

TabSelection.Name = "TabSelection"
TabSelection.Parent = Window
TabSelection.BackgroundColor3 = Color3.new(1, 1, 1)
TabSelection.BackgroundTransparency = 1
TabSelection.Position = UDim2.new(0, 15, 0, 30)
TabSelection.Size = UDim2.new(1, -30, 0, 25)
TabSelection.Visible = false
TabSelection.Image = "rbxassetid://2851929490"
TabSelection.ImageColor3 = Color3.new(0.145098, 0.14902, 0.156863)
TabSelection.ScaleType = Enum.ScaleType.Slice
TabSelection.SliceCenter = Rect.new(4, 4, 4, 4)

TabButtons.Name = "TabButtons"
TabButtons.Parent = TabSelection
TabButtons.BackgroundColor3 = Color3.new(1, 1, 1)
TabButtons.BackgroundTransparency = 1
TabButtons.Size = UDim2.new(1, 0, 1, 0)

UIListLayout.Parent = TabButtons
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

Frame.Parent = TabSelection
Frame.BackgroundColor3 = Color3.new(0.12549, 0.227451, 0.372549)
Frame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 0, 1, 0)
Frame.Size = UDim2.new(1, 0, 0, 2)

Tab.Name = "Tab"
Tab.Parent = Prefabs
Tab.BackgroundColor3 = Color3.new(1, 1, 1)
Tab.BackgroundTransparency = 1
Tab.Size = UDim2.new(1, 0, 1, 0)
Tab.Visible = false

UIListLayout_2.Parent = Tab
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_2.Padding = UDim.new(0, 5)

TextBox.Parent = Prefabs
TextBox.BackgroundColor3 = Color3.new(1, 1, 1)
TextBox.BackgroundTransparency = 1
TextBox.BorderSizePixel = 0
TextBox.Size = UDim2.new(1, 0, 0, 20)
TextBox.ZIndex = 2
TextBox.Font = Enum.Font.GothamSemibold
TextBox.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
TextBox.PlaceholderText = "Input Text"
TextBox.Text = ""
TextBox.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
TextBox.TextSize = 14

TextBox_Roundify_4px.Name = "TextBox_Roundify_4px"
TextBox_Roundify_4px.Parent = TextBox
TextBox_Roundify_4px.BackgroundColor3 = Color3.new(1, 1, 1)
TextBox_Roundify_4px.BackgroundTransparency = 1
TextBox_Roundify_4px.Size = UDim2.new(1, 0, 1, 0)
TextBox_Roundify_4px.Image = "rbxassetid://2851929490"
TextBox_Roundify_4px.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
TextBox_Roundify_4px.ScaleType = Enum.ScaleType.Slice
TextBox_Roundify_4px.SliceCenter = Rect.new(4, 4, 4, 4)

Slider.Name = "Slider"
Slider.Parent = Prefabs
Slider.BackgroundColor3 = Color3.new(1, 1, 1)
Slider.BackgroundTransparency = 1
Slider.Position = UDim2.new(0, 0, 0.178571433, 0)
Slider.Size = UDim2.new(1, 0, 0, 20)
Slider.Image = "rbxassetid://2851929490"
Slider.ImageColor3 = Color3.new(0.145098, 0.14902, 0.156863)
Slider.ScaleType = Enum.ScaleType.Slice
Slider.SliceCenter = Rect.new(4, 4, 4, 4)

Title_2.Name = "Title"
Title_2.Parent = Slider
Title_2.BackgroundColor3 = Color3.new(1, 1, 1)
Title_2.BackgroundTransparency = 1
Title_2.Position = UDim2.new(0.5, 0, 0.5, -10)
Title_2.Size = UDim2.new(0, 0, 0, 20)
Title_2.ZIndex = 2
Title_2.Font = Enum.Font.GothamBold
Title_2.Text = "Slider"
Title_2.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Title_2.TextSize = 14

Indicator.Name = "Indicator"
Indicator.Parent = Slider
Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
Indicator.BackgroundTransparency = 1
Indicator.Size = UDim2.new(0, 0, 0, 20)
Indicator.Image = "rbxassetid://2851929490"
Indicator.ImageColor3 = Color3.new(0.254902, 0.262745, 0.278431)
Indicator.ScaleType = Enum.ScaleType.Slice
Indicator.SliceCenter = Rect.new(4, 4, 4, 4)

Value.Name = "Value"
Value.Parent = Slider
Value.BackgroundColor3 = Color3.new(1, 1, 1)
Value.BackgroundTransparency = 1
Value.Position = UDim2.new(1, -55, 0.5, -10)
Value.Size = UDim2.new(0, 50, 0, 20)
Value.Font = Enum.Font.GothamBold
Value.Text = "0%"
Value.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Value.TextSize = 14

TextLabel.Parent = Slider
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(1, -20, -0.75, 0)
TextLabel.Size = UDim2.new(0, 26, 0, 50)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "]"
TextLabel.TextColor3 = Color3.new(0.627451, 0.627451, 0.627451)
TextLabel.TextSize = 14

TextLabel_2.Parent = Slider
TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.Position = UDim2.new(1, -65, -0.75, 0)
TextLabel_2.Size = UDim2.new(0, 26, 0, 50)
TextLabel_2.Font = Enum.Font.GothamBold
TextLabel_2.Text = "["
TextLabel_2.TextColor3 = Color3.new(0.627451, 0.627451, 0.627451)
TextLabel_2.TextSize = 14

Circle.Name = "Circle"
Circle.Parent = Prefabs
Circle.BackgroundColor3 = Color3.new(1, 1, 1)
Circle.BackgroundTransparency = 1
Circle.Image = "rbxassetid://266543268"
Circle.ImageTransparency = 0.5

UIListLayout_3.Parent = Prefabs
UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_3.Padding = UDim.new(0, 20)

Dropdown.Name = "Dropdown"
Dropdown.Parent = Prefabs
Dropdown.BackgroundColor3 = Color3.new(1, 1, 1)
Dropdown.BackgroundTransparency = 1
Dropdown.BorderSizePixel = 0
Dropdown.Position = UDim2.new(-0.055555556, 0, 0.0833333284, 0)
Dropdown.Size = UDim2.new(0, 200, 0, 20)
Dropdown.ZIndex = 2
Dropdown.Font = Enum.Font.GothamBold
Dropdown.Text = "      Dropdown"
Dropdown.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Dropdown.TextSize = 14
Dropdown.TextXAlignment = Enum.TextXAlignment.Left

Indicator_2.Name = "Indicator"
Indicator_2.Parent = Dropdown
Indicator_2.BackgroundColor3 = Color3.new(1, 1, 1)
Indicator_2.BackgroundTransparency = 1
Indicator_2.Position = UDim2.new(0.899999976, -10, 0.100000001, 0)
Indicator_2.Rotation = -90
Indicator_2.Size = UDim2.new(0, 15, 0, 15)
Indicator_2.ZIndex = 2
Indicator_2.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4744658743"

Box.Name = "Box"
Box.Parent = Dropdown
Box.BackgroundColor3 = Color3.new(1, 1, 1)
Box.BackgroundTransparency = 1
Box.Position = UDim2.new(0, 0, 0, 25)
Box.Size = UDim2.new(1, 0, 0, 150)
Box.ZIndex = 3
Box.Image = "rbxassetid://2851929490"
Box.ImageColor3 = Color3.new(0.129412, 0.133333, 0.141176)
Box.ScaleType = Enum.ScaleType.Slice
Box.SliceCenter = Rect.new(4, 4, 4, 4)

Objects.Name = "Objects"
Objects.Parent = Box
Objects.BackgroundColor3 = Color3.new(1, 1, 1)
Objects.BackgroundTransparency = 1
Objects.BorderSizePixel = 0
Objects.Size = UDim2.new(1, 0, 1, 0)
Objects.ZIndex = 3
Objects.CanvasSize = UDim2.new(0, 0, 0, 0)
Objects.ScrollBarThickness = 8

UIListLayout_4.Parent = Objects
UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder

TextButton_Roundify_4px.Name = "TextButton_Roundify_4px"
TextButton_Roundify_4px.Parent = Dropdown
TextButton_Roundify_4px.BackgroundColor3 = Color3.new(1, 1, 1)
TextButton_Roundify_4px.BackgroundTransparency = 1
TextButton_Roundify_4px.Size = UDim2.new(1, 0, 1, 0)
TextButton_Roundify_4px.Image = "rbxassetid://2851929490"
TextButton_Roundify_4px.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
TextButton_Roundify_4px.ScaleType = Enum.ScaleType.Slice
TextButton_Roundify_4px.SliceCenter = Rect.new(4, 4, 4, 4)

TabButton.Name = "TabButton"
TabButton.Parent = Prefabs
TabButton.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
TabButton.BackgroundTransparency = 1
TabButton.BorderSizePixel = 0
TabButton.Position = UDim2.new(0.185185179, 0, 0, 0)
TabButton.Size = UDim2.new(0, 71, 0, 20)
TabButton.ZIndex = 2
TabButton.Font = Enum.Font.GothamSemibold
TabButton.Text = "Test tab"
TabButton.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
TabButton.TextSize = 14

TextButton_Roundify_4px_2.Name = "TextButton_Roundify_4px"
TextButton_Roundify_4px_2.Parent = TabButton
TextButton_Roundify_4px_2.BackgroundColor3 = Color3.new(1, 1, 1)
TextButton_Roundify_4px_2.BackgroundTransparency = 1
TextButton_Roundify_4px_2.Size = UDim2.new(1, 0, 1, 0)
TextButton_Roundify_4px_2.Image = "rbxassetid://2851929490"
TextButton_Roundify_4px_2.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
TextButton_Roundify_4px_2.ScaleType = Enum.ScaleType.Slice
TextButton_Roundify_4px_2.SliceCenter = Rect.new(4, 4, 4, 4)

Folder.Name = "Folder"
Folder.Parent = Prefabs
Folder.BackgroundColor3 = Color3.new(1, 1, 1)
Folder.BackgroundTransparency = 1
Folder.Position = UDim2.new(0, 0, 0, 50)
Folder.Size = UDim2.new(1, 0, 0, 20)
Folder.Image = "rbxassetid://2851929490"
Folder.ImageColor3 = Color3.new(0.0823529, 0.0862745, 0.0901961)
Folder.ScaleType = Enum.ScaleType.Slice
Folder.SliceCenter = Rect.new(4, 4, 4, 4)

Button.Name = "Button"
Button.Parent = Folder
Button.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
Button.BackgroundTransparency = 1
Button.BorderSizePixel = 0
Button.Size = UDim2.new(1, 0, 0, 20)
Button.ZIndex = 2
Button.Font = Enum.Font.GothamSemibold
Button.Text = "      Folder"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 14
Button.TextXAlignment = Enum.TextXAlignment.Left

TextButton_Roundify_4px_3.Name = "TextButton_Roundify_4px"
TextButton_Roundify_4px_3.Parent = Button
TextButton_Roundify_4px_3.BackgroundColor3 = Color3.new(1, 1, 1)
TextButton_Roundify_4px_3.BackgroundTransparency = 1
TextButton_Roundify_4px_3.Size = UDim2.new(1, 0, 1, 0)
TextButton_Roundify_4px_3.Image = "rbxassetid://2851929490"
TextButton_Roundify_4px_3.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
TextButton_Roundify_4px_3.ScaleType = Enum.ScaleType.Slice
TextButton_Roundify_4px_3.SliceCenter = Rect.new(4, 4, 4, 4)

Toggle_2.Name = "Toggle"
Toggle_2.Parent = Button
Toggle_2.BackgroundColor3 = Color3.new(1, 1, 1)
Toggle_2.BackgroundTransparency = 1
Toggle_2.Position = UDim2.new(0, 5, 0, 0)
Toggle_2.Size = UDim2.new(0, 20, 0, 20)
Toggle_2.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4731371541"

Objects_2.Name = "Objects"
Objects_2.Parent = Folder
Objects_2.BackgroundColor3 = Color3.new(1, 1, 1)
Objects_2.BackgroundTransparency = 1
Objects_2.Position = UDim2.new(0, 10, 0, 25)
Objects_2.Size = UDim2.new(1, -10, 1, -25)
Objects_2.Visible = false

UIListLayout_5.Parent = Objects_2
UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_5.Padding = UDim.new(0, 5)

HorizontalAlignment.Name = "HorizontalAlignment"
HorizontalAlignment.Parent = Prefabs
HorizontalAlignment.BackgroundColor3 = Color3.new(1, 1, 1)
HorizontalAlignment.BackgroundTransparency = 1
HorizontalAlignment.Size = UDim2.new(1, 0, 0, 20)

UIListLayout_6.Parent = HorizontalAlignment
UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_6.Padding = UDim.new(0, 5)

Console.Name = "Console"
Console.Parent = Prefabs
Console.BackgroundColor3 = Color3.new(1, 1, 1)
Console.BackgroundTransparency = 1
Console.Size = UDim2.new(1, 0, 0, 200)
Console.Image = "rbxassetid://2851928141"
Console.ImageColor3 = Color3.new(0.129412, 0.133333, 0.141176)
Console.ScaleType = Enum.ScaleType.Slice
Console.SliceCenter = Rect.new(8, 8, 8, 8)

ScrollingFrame.Parent = Console
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Size = UDim2.new(1, 0, 1, 1)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

Source.Name = "Source"
Source.Parent = ScrollingFrame
Source.BackgroundColor3 = Color3.new(1, 1, 1)
Source.BackgroundTransparency = 1
Source.Position = UDim2.new(0, 40, 0, 0)
Source.Size = UDim2.new(1, -40, 0, 10000)
Source.ZIndex = 3
Source.ClearTextOnFocus = false
Source.Font = Enum.Font.Code
Source.MultiLine = true
Source.PlaceholderColor3 = Color3.new(0.8, 0.8, 0.8)
Source.Text = ""
Source.TextColor3 = Color3.new(1, 1, 1)
Source.TextSize = 15
Source.TextStrokeColor3 = Color3.new(1, 1, 1)
Source.TextWrapped = true
Source.TextXAlignment = Enum.TextXAlignment.Left
Source.TextYAlignment = Enum.TextYAlignment.Top

Comments.Name = "Comments"
Comments.Parent = Source
Comments.BackgroundColor3 = Color3.new(1, 1, 1)
Comments.BackgroundTransparency = 1
Comments.Size = UDim2.new(1, 0, 1, 0)
Comments.ZIndex = 5
Comments.Font = Enum.Font.Code
Comments.Text = ""
Comments.TextColor3 = Color3.new(0.231373, 0.784314, 0.231373)
Comments.TextSize = 15
Comments.TextXAlignment = Enum.TextXAlignment.Left
Comments.TextYAlignment = Enum.TextYAlignment.Top

Globals.Name = "Globals"
Globals.Parent = Source
Globals.BackgroundColor3 = Color3.new(1, 1, 1)
Globals.BackgroundTransparency = 1
Globals.Size = UDim2.new(1, 0, 1, 0)
Globals.ZIndex = 5
Globals.Font = Enum.Font.Code
Globals.Text = ""
Globals.TextColor3 = Color3.new(0.517647, 0.839216, 0.968628)
Globals.TextSize = 15
Globals.TextXAlignment = Enum.TextXAlignment.Left
Globals.TextYAlignment = Enum.TextYAlignment.Top

Keywords.Name = "Keywords"
Keywords.Parent = Source
Keywords.BackgroundColor3 = Color3.new(1, 1, 1)
Keywords.BackgroundTransparency = 1
Keywords.Size = UDim2.new(1, 0, 1, 0)
Keywords.ZIndex = 5
Keywords.Font = Enum.Font.Code
Keywords.Text = ""
Keywords.TextColor3 = Color3.new(0.972549, 0.427451, 0.486275)
Keywords.TextSize = 15
Keywords.TextXAlignment = Enum.TextXAlignment.Left
Keywords.TextYAlignment = Enum.TextYAlignment.Top

RemoteHighlight.Name = "RemoteHighlight"
RemoteHighlight.Parent = Source
RemoteHighlight.BackgroundColor3 = Color3.new(1, 1, 1)
RemoteHighlight.BackgroundTransparency = 1
RemoteHighlight.Size = UDim2.new(1, 0, 1, 0)
RemoteHighlight.ZIndex = 5
RemoteHighlight.Font = Enum.Font.Code
RemoteHighlight.Text = ""
RemoteHighlight.TextColor3 = Color3.new(0, 0.568627, 1)
RemoteHighlight.TextSize = 15
RemoteHighlight.TextXAlignment = Enum.TextXAlignment.Left
RemoteHighlight.TextYAlignment = Enum.TextYAlignment.Top

Strings.Name = "Strings"
Strings.Parent = Source
Strings.BackgroundColor3 = Color3.new(1, 1, 1)
Strings.BackgroundTransparency = 1
Strings.Size = UDim2.new(1, 0, 1, 0)
Strings.ZIndex = 5
Strings.Font = Enum.Font.Code
Strings.Text = ""
Strings.TextColor3 = Color3.new(0.678431, 0.945098, 0.584314)
Strings.TextSize = 15
Strings.TextXAlignment = Enum.TextXAlignment.Left
Strings.TextYAlignment = Enum.TextYAlignment.Top

Tokens.Name = "Tokens"
Tokens.Parent = Source
Tokens.BackgroundColor3 = Color3.new(1, 1, 1)
Tokens.BackgroundTransparency = 1
Tokens.Size = UDim2.new(1, 0, 1, 0)
Tokens.ZIndex = 5
Tokens.Font = Enum.Font.Code
Tokens.Text = ""
Tokens.TextColor3 = Color3.new(1, 1, 1)
Tokens.TextSize = 15
Tokens.TextXAlignment = Enum.TextXAlignment.Left
Tokens.TextYAlignment = Enum.TextYAlignment.Top

Numbers.Name = "Numbers"
Numbers.Parent = Source
Numbers.BackgroundColor3 = Color3.new(1, 1, 1)
Numbers.BackgroundTransparency = 1
Numbers.Size = UDim2.new(1, 0, 1, 0)
Numbers.ZIndex = 4
Numbers.Font = Enum.Font.Code
Numbers.Text = ""
Numbers.TextColor3 = Color3.new(1, 0.776471, 0)
Numbers.TextSize = 15
Numbers.TextXAlignment = Enum.TextXAlignment.Left
Numbers.TextYAlignment = Enum.TextYAlignment.Top

Info.Name = "Info"
Info.Parent = Source
Info.BackgroundColor3 = Color3.new(1, 1, 1)
Info.BackgroundTransparency = 1
Info.Size = UDim2.new(1, 0, 1, 0)
Info.ZIndex = 5
Info.Font = Enum.Font.Code
Info.Text = ""
Info.TextColor3 = Color3.new(0, 0.635294, 1)
Info.TextSize = 15
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top

Lines.Name = "Lines"
Lines.Parent = ScrollingFrame
Lines.BackgroundColor3 = Color3.new(1, 1, 1)
Lines.BackgroundTransparency = 1
Lines.BorderSizePixel = 0
Lines.Size = UDim2.new(0, 40, 0, 10000)
Lines.ZIndex = 4
Lines.Font = Enum.Font.Code
Lines.Text = "1\n"
Lines.TextColor3 = Color3.new(1, 1, 1)
Lines.TextSize = 15
Lines.TextWrapped = true
Lines.TextYAlignment = Enum.TextYAlignment.Top

ColorPicker.Name = "ColorPicker"
ColorPicker.Parent = Prefabs
ColorPicker.BackgroundColor3 = Color3.new(1, 1, 1)
ColorPicker.BackgroundTransparency = 1
ColorPicker.Size = UDim2.new(0, 180, 0, 110)
ColorPicker.Image = "rbxassetid://2851929490"
ColorPicker.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
ColorPicker.ScaleType = Enum.ScaleType.Slice
ColorPicker.SliceCenter = Rect.new(4, 4, 4, 4)

Palette.Name = "Palette"
Palette.Parent = ColorPicker
Palette.BackgroundColor3 = Color3.new(1, 1, 1)
Palette.BackgroundTransparency = 1
Palette.Position = UDim2.new(0.0500000007, 0, 0.0500000007, 0)
Palette.Size = UDim2.new(0, 100, 0, 100)
Palette.Image = "rbxassetid://698052001"
Palette.ScaleType = Enum.ScaleType.Slice
Palette.SliceCenter = Rect.new(4, 4, 4, 4)

Indicator_3.Name = "Indicator"
Indicator_3.Parent = Palette
Indicator_3.BackgroundColor3 = Color3.new(1, 1, 1)
Indicator_3.BackgroundTransparency = 1
Indicator_3.Size = UDim2.new(0, 5, 0, 5)
Indicator_3.ZIndex = 2
Indicator_3.Image = "rbxassetid://2851926732"
Indicator_3.ImageColor3 = Color3.new(0, 0, 0)
Indicator_3.ScaleType = Enum.ScaleType.Slice
Indicator_3.SliceCenter = Rect.new(12, 12, 12, 12)

Sample.Name = "Sample"
Sample.Parent = ColorPicker
Sample.BackgroundColor3 = Color3.new(1, 1, 1)
Sample.BackgroundTransparency = 1
Sample.Position = UDim2.new(0.800000012, 0, 0.0500000007, 0)
Sample.Size = UDim2.new(0, 25, 0, 25)
Sample.Image = "rbxassetid://2851929490"
Sample.ScaleType = Enum.ScaleType.Slice
Sample.SliceCenter = Rect.new(4, 4, 4, 4)

Saturation.Name = "Saturation"
Saturation.Parent = ColorPicker
Saturation.BackgroundColor3 = Color3.new(1, 1, 1)
Saturation.Position = UDim2.new(0.649999976, 0, 0.0500000007, 0)
Saturation.Size = UDim2.new(0, 15, 0, 100)
Saturation.Image = "rbxassetid://3641079629"

Indicator_4.Name = "Indicator"
Indicator_4.Parent = Saturation
Indicator_4.BackgroundColor3 = Color3.new(1, 1, 1)
Indicator_4.BorderSizePixel = 0
Indicator_4.Size = UDim2.new(0, 20, 0, 2)
Indicator_4.ZIndex = 2

Switch.Name = "Switch"
Switch.Parent = Prefabs
Switch.BackgroundColor3 = Color3.new(1, 1, 1)
Switch.BackgroundTransparency = 1
Switch.BorderSizePixel = 0
Switch.Position = UDim2.new(0.229411766, 0, 0.20714286, 0)
Switch.Size = UDim2.new(0, 20, 0, 20)
Switch.ZIndex = 2
Switch.Font = Enum.Font.SourceSans
Switch.Text = ""
Switch.TextColor3 = Color3.new(1, 1, 1)
Switch.TextSize = 18

TextButton_Roundify_4px_4.Name = "TextButton_Roundify_4px"
TextButton_Roundify_4px_4.Parent = Switch
TextButton_Roundify_4px_4.BackgroundColor3 = Color3.new(1, 1, 1)
TextButton_Roundify_4px_4.BackgroundTransparency = 1
TextButton_Roundify_4px_4.Size = UDim2.new(1, 0, 1, 0)
TextButton_Roundify_4px_4.Image = "rbxassetid://2851929490"
TextButton_Roundify_4px_4.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
TextButton_Roundify_4px_4.ImageTransparency = 0.5
TextButton_Roundify_4px_4.ScaleType = Enum.ScaleType.Slice
TextButton_Roundify_4px_4.SliceCenter = Rect.new(4, 4, 4, 4)

Title_3.Name = "Title"
Title_3.Parent = Switch
Title_3.BackgroundColor3 = Color3.new(1, 1, 1)
Title_3.BackgroundTransparency = 1
Title_3.Position = UDim2.new(1.20000005, 0, 0, 0)
Title_3.Size = UDim2.new(0, 20, 0, 20)
Title_3.Font = Enum.Font.GothamSemibold
Title_3.Text = "Switch"
Title_3.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Title_3.TextSize = 14
Title_3.TextXAlignment = Enum.TextXAlignment.Left

Button_2.Name = "Button"
Button_2.Parent = Prefabs
Button_2.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
Button_2.BackgroundTransparency = 1
Button_2.BorderSizePixel = 0
Button_2.Size = UDim2.new(0, 91, 0, 20)
Button_2.ZIndex = 2
Button_2.Font = Enum.Font.GothamSemibold
Button_2.TextColor3 = Color3.new(1, 1, 1)
Button_2.TextSize = 14

TextButton_Roundify_4px_5.Name = "TextButton_Roundify_4px"
TextButton_Roundify_4px_5.Parent = Button_2
TextButton_Roundify_4px_5.BackgroundColor3 = Color3.new(1, 1, 1)
TextButton_Roundify_4px_5.BackgroundTransparency = 1
TextButton_Roundify_4px_5.Size = UDim2.new(1, 0, 1, 0)
TextButton_Roundify_4px_5.Image = "rbxassetid://2851929490"
TextButton_Roundify_4px_5.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
TextButton_Roundify_4px_5.ScaleType = Enum.ScaleType.Slice
TextButton_Roundify_4px_5.SliceCenter = Rect.new(4, 4, 4, 4)

DropdownButton.Name = "DropdownButton"
DropdownButton.Parent = Prefabs
DropdownButton.BackgroundColor3 = Color3.new(0.129412, 0.133333, 0.141176)
DropdownButton.BorderSizePixel = 0
DropdownButton.Size = UDim2.new(1, 0, 0, 20)
DropdownButton.ZIndex = 3
DropdownButton.Font = Enum.Font.GothamBold
DropdownButton.Text = "      Button"
DropdownButton.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
DropdownButton.TextSize = 14
DropdownButton.TextXAlignment = Enum.TextXAlignment.Left

Keybind.Name = "Keybind"
Keybind.Parent = Prefabs
Keybind.BackgroundColor3 = Color3.new(1, 1, 1)
Keybind.BackgroundTransparency = 1
Keybind.Size = UDim2.new(0, 200, 0, 20)
Keybind.Image = "rbxassetid://2851929490"
Keybind.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
Keybind.ScaleType = Enum.ScaleType.Slice
Keybind.SliceCenter = Rect.new(4, 4, 4, 4)

Title_4.Name = "Title"
Title_4.Parent = Keybind
Title_4.BackgroundColor3 = Color3.new(1, 1, 1)
Title_4.BackgroundTransparency = 1
Title_4.Size = UDim2.new(0, 0, 1, 0)
Title_4.Font = Enum.Font.GothamBold
Title_4.Text = "Keybind"
Title_4.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Title_4.TextSize = 14
Title_4.TextXAlignment = Enum.TextXAlignment.Left

Input.Name = "Input"
Input.Parent = Keybind
Input.BackgroundColor3 = Color3.new(1, 1, 1)
Input.BackgroundTransparency = 1
Input.BorderSizePixel = 0
Input.Position = UDim2.new(1, -85, 0, 2)
Input.Size = UDim2.new(0, 80, 1, -4)
Input.ZIndex = 2
Input.Font = Enum.Font.GothamSemibold
Input.Text = "RShift"
Input.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
Input.TextSize = 12
Input.TextWrapped = true

Input_Roundify_4px.Name = "Input_Roundify_4px"
Input_Roundify_4px.Parent = Input
Input_Roundify_4px.BackgroundColor3 = Color3.new(1, 1, 1)
Input_Roundify_4px.BackgroundTransparency = 1
Input_Roundify_4px.Size = UDim2.new(1, 0, 1, 0)
Input_Roundify_4px.Image = "rbxassetid://2851929490"
Input_Roundify_4px.ImageColor3 = Color3.new(0.290196, 0.294118, 0.313726)
Input_Roundify_4px.ScaleType = Enum.ScaleType.Slice
Input_Roundify_4px.SliceCenter = Rect.new(4, 4, 4, 4)

Windows.Name = "Windows"
Windows.Parent = imgui
Windows.BackgroundColor3 = Color3.new(1, 1, 1)
Windows.BackgroundTransparency = 1
Windows.Position = UDim2.new(0, 20, 0, 20)
Windows.Size = UDim2.new(1, 20, 1, -20)

--[[ Script ]]--
script.Parent = imgui

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("RunService")
local ps = game:GetService("Players")

local p = ps.LocalPlayer
local mouse = p:GetMouse()

local Prefabs = script.Parent:WaitForChild("Prefabs")
local Windows = script.Parent:FindFirstChild("Windows")

local checks = {
	["binding"] = false,
}

UIS.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == ((typeof(ui_options.toggle_key) == "EnumItem") and ui_options.toggle_key or Enum.KeyCode.RightShift) then
		if script.Parent then
			if not checks.binding then
				script.Parent.Enabled = not script.Parent.Enabled
			end
		end
	end
end)

local function Resize(part, new, _delay)
	_delay = _delay or 0.5
	local tweenInfo = TweenInfo.new(_delay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(part, tweenInfo, new)
	tween:Play()
end

local function rgbtohsv(r, g, b) -- idk who made this function, but thanks
	r, g, b = r / 255, g / 255, b / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then
		s = 0
	else
		s = d / max
	end

	if max == min then
		h = 0
	else
		if max == r then
			h = (g - b) / d
			if g < b then
				h = h + 6
			end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, v
end

local function hasprop(object, prop)
	local a, b = pcall(function()
		return object[tostring(prop)]
	end)
	if a then
		return b
	end
end

local function gNameLen(obj)
	return obj.TextBounds.X + 15
end

local function gMouse()
	return Vector2.new(UIS:GetMouseLocation().X + 1, UIS:GetMouseLocation().Y - 35)
end

local function ripple(button, x, y)
	spawn(function()
		button.ClipsDescendants = true

		local circle = Prefabs:FindFirstChild("Circle"):Clone()

		circle.Parent = button
		circle.ZIndex = 1000

		local new_x = x - circle.AbsolutePosition.X
		local new_y = y - circle.AbsolutePosition.Y
		circle.Position = UDim2.new(0, new_x, 0, new_y)

		local size = 0
		if button.AbsoluteSize.X > button.AbsoluteSize.Y then
			 size = button.AbsoluteSize.X * 1.5
		elseif button.AbsoluteSize.X < button.AbsoluteSize.Y then
			 size = button.AbsoluteSize.Y * 1.5
		elseif button.AbsoluteSize.X == button.AbsoluteSize.Y then
			size = button.AbsoluteSize.X * 1.5
		end

		circle:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size / 2, 0.5, -size / 2), "Out", "Quad", 0.5, false, nil)
		Resize(circle, {ImageTransparency = 1}, 0.5)

		wait(0.5)
		circle:Destroy()
	end)
end

local windows = 0
local library = {}

local function format_windows()
	local ull = Prefabs:FindFirstChild("UIListLayout"):Clone()
	ull.Parent = Windows
	local data = {}

	for i,v in next, Windows:GetChildren() do
		if not (v:IsA("UIListLayout")) then
			data[v] = v.AbsolutePosition
		end
	end

	ull:Destroy()

	for i,v in next, data do
		i.Position = UDim2.new(0, v.X, 0, v.Y)
	end
end

function library:FormatWindows()
	format_windows()
end

function library:AddWindow(title, options)
	windows = windows + 1
	local dropdown_open = false
	title = tostring(title or "New Window")
	options = (typeof(options) == "table") and options or ui_options
	options.tween_time = 0.1

	local Window = Prefabs:FindFirstChild("Window"):Clone()
	Window.Parent = Windows
	Window:FindFirstChild("Title").Text = title
	Window.Size = UDim2.new(0, options.min_size.X, 0, options.min_size.Y)
	Window.ZIndex = Window.ZIndex + (windows * 10)

	do -- Altering Window Color
		local Title = Window:FindFirstChild("Title")
		local Bar = Window:FindFirstChild("Bar")
		local Base = Bar:FindFirstChild("Base")
		local Top = Bar:FindFirstChild("Top")
		local SplitFrame = Window:FindFirstChild("TabSelection"):FindFirstChild("Frame")
		local Toggle = Bar:FindFirstChild("Toggle")

		spawn(function()
			while true do
				Bar.BackgroundColor3 = options.main_color
				Base.BackgroundColor3 = options.main_color
				Base.ImageColor3 = options.main_color
				Top.ImageColor3 = options.main_color
				SplitFrame.BackgroundColor3 = options.main_color

				RS.Heartbeat:Wait()
			end
		end)

	end

	local Resizer = Window:WaitForChild("Resizer")

	local window_data = {}
	Window.Draggable = true

	do -- Resize Window
		local oldIcon = mouse.Icon
		local Entered = false
		Resizer.MouseEnter:Connect(function()
			Window.Draggable = false
			if options.can_resize then
				oldIcon = mouse.Icon
				-- mouse.Icon = "http://www.roblox.com/asset?id=4745131330"
			end
			Entered = true
		end)

		Resizer.MouseLeave:Connect(function()
			Entered = false
			if options.can_resize then
				mouse.Icon = oldIcon
			end
			Window.Draggable = true
		end)

		local Held = false
		UIS.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				Held = true

				spawn(function() -- Loop check
					if Entered and Resizer.Active and options.can_resize then
						while Held and Resizer.Active do

							local mouse_location = gMouse()
							local x = mouse_location.X - Window.AbsolutePosition.X
							local y = mouse_location.Y - Window.AbsolutePosition.Y

							--
							if x >= options.min_size.X and y >= options.min_size.Y then
								Resize(Window, {Size = UDim2.new(0, x, 0, y)}, options.tween_time)
							elseif x >= options.min_size.X then
								Resize(Window, {Size = UDim2.new(0, x, 0, options.min_size.Y)}, options.tween_time)
							elseif y >= options.min_size.Y then
								Resize(Window, {Size = UDim2.new(0, options.min_size.X, 0, y)}, options.tween_time)
							else
								Resize(Window, {Size = UDim2.new(0, options.min_size.X, 0, options.min_size.Y)}, options.tween_time)
							end

							RS.Heartbeat:Wait()
						end
					end
				end)
			end
		end)
		UIS.InputEnded:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				Held = false
			end
		end)
	end

	do -- [Open / Close] Window
		local open_close = Window:FindFirstChild("Bar"):FindFirstChild("Toggle")
		local open = true
		local canopen = true

		local oldwindowdata = {}
		local oldy = Window.AbsoluteSize.Y
		open_close.MouseButton1Click:Connect(function()
			if canopen then
				canopen = false

				if open then
					-- Close

					oldwindowdata = {}
					for i,v in next, Window:FindFirstChild("Tabs"):GetChildren() do
						oldwindowdata[v] = v.Visible
						v.Visible = false
					end

					Resizer.Active = false

					oldy = Window.AbsoluteSize.Y
					Resize(open_close, {Rotation = 360}, options.tween_time)
					Resize(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, 26)}, options.tween_time)
					open_close.Parent:FindFirstChild("Base").Transparency = 1

				else
					-- Open

					for i,v in next, oldwindowdata do
						i.Visible = v
					end

					Resizer.Active = true

					Resize(open_close, {Rotation = 0}, options.tween_time)
					Resize(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, oldy)}, options.tween_time)
					open_close.Parent:FindFirstChild("Base").Transparency = 0

				end

				open = not open
				wait(options.tween_time)
				canopen = true

			end
		end)
	end

	do -- UI Elements
		local tabs = Window:FindFirstChild("Tabs")
		local tab_selection = Window:FindFirstChild("TabSelection")
		local tab_buttons = tab_selection:FindFirstChild("TabButtons")

		do -- Add Tab
			function window_data:AddTab(tab_name)
				local tab_data = {}
				tab_name = tostring(tab_name or "New Tab")
				tab_selection.Visible = true

				local new_button = Prefabs:FindFirstChild("TabButton"):Clone()
				new_button.Parent = tab_buttons
				new_button.Text = tab_name
				new_button.Size = UDim2.new(0, gNameLen(new_button), 0, 20)
				new_button.ZIndex = new_button.ZIndex + (windows * 10)
				new_button:GetChildren()[1].ZIndex = new_button:GetChildren()[1].ZIndex + (windows * 10)

				local new_tab = Prefabs:FindFirstChild("Tab"):Clone()
				new_tab.Parent = tabs
				new_tab.ZIndex = new_tab.ZIndex + (windows * 10)

				local function show()
					if dropdown_open then return end
					for i, v in next, tab_buttons:GetChildren() do
						if not (v:IsA("UIListLayout")) then
							v:GetChildren()[1].ImageColor3 = Color3.fromRGB(52, 53, 56)
							Resize(v, {Size = UDim2.new(0, v.AbsoluteSize.X, 0, 20)}, options.tween_time)
						end
					end
					for i, v in next, tabs:GetChildren() do
						v.Visible = false
					end

					Resize(new_button, {Size = UDim2.new(0, new_button.AbsoluteSize.X, 0, 25)}, options.tween_time)
					new_button:GetChildren()[1].ImageColor3 = Color3.fromRGB(73, 75, 79)
					new_tab.Visible = true
				end

				new_button.MouseButton1Click:Connect(function()
					show()
				end)

				function tab_data:Show()
					show()
				end

				do -- Tab Elements

					function tab_data:AddLabel(label_text) -- [Label]
						label_text = tostring(label_text or "New Label")

						local label = Prefabs:FindFirstChild("Label"):Clone()

						label.Parent = new_tab
						label.Text = label_text
						label.Size = UDim2.new(0, gNameLen(label), 0, 20)
						label.ZIndex = label.ZIndex + (windows * 10)

						return label
					end

					function tab_data:AddButton(button_text, callback) -- [Button]
						button_text = tostring(button_text or "New Button")
						callback = typeof(callback) == "function" and callback or function()end

						local button = Prefabs:FindFirstChild("Button"):Clone()

						button.Parent = new_tab
						button.Text = button_text
						button.Size = UDim2.new(0, gNameLen(button), 0, 20)
						button.ZIndex = button.ZIndex + (windows * 10)
						button:GetChildren()[1].ZIndex = button:GetChildren()[1].ZIndex + (windows * 10)

						spawn(function()
							while true do
								if button and button:GetChildren()[1] then
									button:GetChildren()[1].ImageColor3 = options.main_color
								end
								RS.Heartbeat:Wait()
							end
						end)

						button.MouseButton1Click:Connect(function()
							ripple(button, mouse.X, mouse.Y)
							pcall(callback)
						end)

						return button
					end

					function tab_data:AddSwitch(switch_text, callback) -- [Switch]
						local switch_data = {}

						switch_text = tostring(switch_text or "New Switch")
						callback = typeof(callback) == "function" and callback or function()end

						local switch = Prefabs:FindFirstChild("Switch"):Clone()

						switch.Parent = new_tab
						switch:FindFirstChild("Title").Text = switch_text

						switch:FindFirstChild("Title").ZIndex = switch:FindFirstChild("Title").ZIndex + (windows * 10)
						switch.ZIndex = switch.ZIndex + (windows * 10)
						switch:GetChildren()[1].ZIndex = switch:GetChildren()[1].ZIndex + (windows * 10)

						spawn(function()
							while true do
								if switch and switch:GetChildren()[1] then
									switch:GetChildren()[1].ImageColor3 = options.main_color
								end
								RS.Heartbeat:Wait()
							end
						end)

						local toggled = false
						switch.MouseButton1Click:Connect(function()
							toggled = not toggled
							switch.Text = toggled and utf8.char(10003) or ""
							pcall(callback, toggled)
						end)

						function switch_data:Set(bool)
							toggled = (typeof(bool) == "boolean") and bool or false
							switch.Text = toggled and utf8.char(10003) or ""
							pcall(callback,toggled)
						end

						return switch_data, switch
					end

					function tab_data:AddTextBox(textbox_text, callback, textbox_options)
						textbox_text = tostring(textbox_text or "New TextBox")
						callback = typeof(callback) == "function" and callback or function()end
						textbox_options = typeof(textbox_options) == "table" and textbox_options or {["clear"] = true}
						textbox_options = {
							["clear"] = ((textbox_options.clear) == true)
						}

						local textbox = Prefabs:FindFirstChild("TextBox"):Clone()

						textbox.Parent = new_tab
						textbox.PlaceholderText = textbox_text
						textbox.ZIndex = textbox.ZIndex + (windows * 10)
						textbox:GetChildren()[1].ZIndex = textbox:GetChildren()[1].ZIndex + (windows * 10)

						textbox.FocusLost:Connect(function(ep)
							if ep then
								if #textbox.Text > 0 then
									pcall(callback, textbox.Text)
									if textbox_options.clear then
										textbox.Text = ""
									end
								end
							end
						end)

						return textbox
					end

					function tab_data:AddSlider(slider_text, callback, slider_options)
						local slider_data = {}

						slider_text = tostring(slider_text or "New Slider")
						callback = typeof(callback) == "function" and callback or function()end
						slider_options = typeof(slider_options) == "table" and slider_options or {}
						slider_options = {
							["min"] = slider_options.min or 0,
							["max"] = slider_options.max or 100,
							["readonly"] = slider_options.readonly or false,
						}

						local slider = Prefabs:FindFirstChild("Slider"):Clone()

						slider.Parent = new_tab
						slider.ZIndex = slider.ZIndex + (windows * 10)

						local title = slider:FindFirstChild("Title")
						local indicator = slider:FindFirstChild("Indicator")
						local value = slider:FindFirstChild("Value")
						title.ZIndex = title.ZIndex + (windows * 10)
						indicator.ZIndex = indicator.ZIndex + (windows * 10)
						value.ZIndex = value.ZIndex + (windows * 10)

						title.Text = slider_text

						do -- Slider Math
							local Entered = false
							slider.MouseEnter:Connect(function()
								Entered = true
								Window.Draggable = false
							end)
							slider.MouseLeave:Connect(function()
								Entered = false
								Window.Draggable = true
							end)

							local Held = false
							UIS.InputBegan:Connect(function(inputObject)
								if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
									Held = true

									spawn(function() -- Loop check
										if Entered and not slider_options.readonly then
											while Held and (not dropdown_open) do
												local mouse_location = gMouse()
												local x = (slider.AbsoluteSize.X - (slider.AbsoluteSize.X - ((mouse_location.X - slider.AbsolutePosition.X)) + 1)) / slider.AbsoluteSize.X

												local min = 0
												local max = 1

												local size = min
												if x >= min and x <= max then
													size = x
												elseif x < min then
													size = min
												elseif x > max then
													size = max
												end

												Resize(indicator, {Size = UDim2.new(size or min, 0, 0, 20)}, options.tween_time)
												local p = math.floor((size or min) * 100)

												local maxv = slider_options.max
												local minv = slider_options.min
												local diff = maxv - minv

												local sel_value = math.floor(((diff / 100) * p) + minv)

												value.Text = tostring(sel_value)
												pcall(callback, sel_value)

												RS.Heartbeat:Wait()
											end
										end
									end)
								end
							end)
							UIS.InputEnded:Connect(function(inputObject)
								if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
									Held = false
								end
							end)

							function slider_data:Set(new_value)
								new_value = tonumber(new_value) or 0
								new_value = (((new_value >= 0 and new_value <= 100) and new_value) / 100)

								Resize(indicator, {Size = UDim2.new(new_value or 0, 0, 0, 20)}, options.tween_time)
								local p = math.floor((new_value or 0) * 100)

								local maxv = slider_options.max
								local minv = slider_options.min
								local diff = maxv - minv

								local sel_value = math.floor(((diff / 100) * p) + minv)

								value.Text = tostring(sel_value)
								pcall(callback, sel_value)
							end

							slider_data:Set(slider_options["min"])
						end

						return slider_data, slider
					end

					function tab_data:AddKeybind(keybind_name, callback, keybind_options)
						local keybind_data = {}

						keybind_name = tostring(keybind_name or "New Keybind")
						callback = typeof(callback) == "function" and callback or function()end
						keybind_options = typeof(keybind_options) == "table" and keybind_options or {}
						keybind_options = {
							["standard"] = keybind_options.standard or Enum.KeyCode.RightShift,
						}

						local keybind = Prefabs:FindFirstChild("Keybind"):Clone()
						local input = keybind:FindFirstChild("Input")
						local title = keybind:FindFirstChild("Title")
						keybind.ZIndex = keybind.ZIndex + (windows * 10)
						input.ZIndex = input.ZIndex + (windows * 10)
						input:GetChildren()[1].ZIndex = input:GetChildren()[1].ZIndex + (windows * 10)
						title.ZIndex = title.ZIndex + (windows * 10)

						keybind.Parent = new_tab
						title.Text = "  " .. keybind_name
						keybind.Size = UDim2.new(0, gNameLen(title) + 80, 0, 20)

						local shortkeys = { -- thanks to stroketon for helping me out with this
				            RightControl = 'RightCtrl',
				            LeftControl = 'LeftCtrl',
				            LeftShift = 'LShift',
				            RightShift = 'RShift',
				            MouseButton1 = "Mouse1",
				            MouseButton2 = "Mouse2"
				        }

						local keybind = keybind_options.standard

						function keybind_data:SetKeybind(Keybind)
							local key = shortkeys[Keybind.Name] or Keybind.Name
							input.Text = key
							keybind = Keybind
						end

						UIS.InputBegan:Connect(function(a, b)
							if checks.binding then
								spawn(function()
									wait()
									checks.binding = false
								end)
								return
							end
							if a.KeyCode == keybind and not b then
								pcall(callback, keybind)
							end
						end)

						keybind_data:SetKeybind(keybind_options.standard)

						input.MouseButton1Click:Connect(function()
							if checks.binding then return end
							input.Text = "..."
							checks.binding = true
							local a, b = UIS.InputBegan:Wait()
							keybind_data:SetKeybind(a.KeyCode)
						end)

						return keybind_data, keybind
					end

					function tab_data:AddDropdown(dropdown_name, callback)
						local dropdown_data = {}
						dropdown_name = tostring(dropdown_name or "New Dropdown")
						callback = typeof(callback) == "function" and callback or function()end

						local dropdown = Prefabs:FindFirstChild("Dropdown"):Clone()
						local box = dropdown:FindFirstChild("Box")
						local objects = box:FindFirstChild("Objects")
						local indicator = dropdown:FindFirstChild("Indicator")
						dropdown.ZIndex = dropdown.ZIndex + (windows * 10)
						box.ZIndex = box.ZIndex + (windows * 10)
						objects.ZIndex = objects.ZIndex + (windows * 10)
						indicator.ZIndex = indicator.ZIndex + (windows * 10)
						dropdown:GetChildren()[3].ZIndex = dropdown:GetChildren()[3].ZIndex + (windows * 10)

						dropdown.Parent = new_tab
						dropdown.Text = "      " .. dropdown_name
						box.Size = UDim2.new(1, 0, 0, 0)

						local open = false
						dropdown.MouseButton1Click:Connect(function()
							open = not open

							local len = (#objects:GetChildren() - 1) * 20
							if #objects:GetChildren() - 1 >= 10 then
								len = 10 * 20
								objects.CanvasSize = UDim2.new(0, 0, (#objects:GetChildren() - 1) * 0.1, 0)
							end

							if open then -- Open
								if dropdown_open then return end
								dropdown_open = true
								Resize(box, {Size = UDim2.new(1, 0, 0, len)}, options.tween_time)
								Resize(indicator, {Rotation = 90}, options.tween_time)
							else -- Close
								dropdown_open = false
								Resize(box, {Size = UDim2.new(1, 0, 0, 0)}, options.tween_time)
								Resize(indicator, {Rotation = -90}, options.tween_time)
							end

						end)

						function dropdown_data:Add(n)
							local object_data = {}
							n = tostring(n or "New Object")

							local object = Prefabs:FindFirstChild("DropdownButton"):Clone()

							object.Parent = objects
							object.Text = n
							object.ZIndex = object.ZIndex + (windows * 10)

							object.MouseEnter:Connect(function()
								object.BackgroundColor3 = options.main_color
							end)
							object.MouseLeave:Connect(function()
								object.BackgroundColor3 = Color3.fromRGB(33, 34, 36)
							end)

							if open then
								local len = (#objects:GetChildren() - 1) * 20
								if #objects:GetChildren() - 1 >= 10 then
									len = 10 * 20
									objects.CanvasSize = UDim2.new(0, 0, (#objects:GetChildren() - 1) * 0.1, 0)
								end
								Resize(box, {Size = UDim2.new(1, 0, 0, len)}, options.tween_time)
							end

							object.MouseButton1Click:Connect(function()
								if dropdown_open then
									dropdown.Text = "      [ " .. n .. " ]"
									dropdown_open = false
									open = false
									Resize(box, {Size = UDim2.new(1, 0, 0, 0)}, options.tween_time)
									Resize(indicator, {Rotation = -90}, options.tween_time)
									pcall(callback, n)
								end
							end)

							function object_data:Remove()
								object:Destroy()
							end

							return object, object_data
						end

						return dropdown_data, dropdown
					end

					function tab_data:AddColorPicker(callback)
						local color_picker_data = {}
						callback = typeof(callback) == "function" and callback or function()end

						local color_picker = Prefabs:FindFirstChild("ColorPicker"):Clone()

						color_picker.Parent = new_tab
						color_picker.ZIndex = color_picker.ZIndex + (windows * 10)

						local palette = color_picker:FindFirstChild("Palette")
						local sample = color_picker:FindFirstChild("Sample")
						local saturation = color_picker:FindFirstChild("Saturation")
						palette.ZIndex = palette.ZIndex + (windows * 10)
						sample.ZIndex = sample.ZIndex + (windows * 10)
						saturation.ZIndex = saturation.ZIndex + (windows * 10)

						do -- Color Picker Math
							local h = 0
							local s = 1
							local v = 1

							local function update()
								local color = Color3.fromHSV(h, s, v)
								sample.ImageColor3 = color
								saturation.ImageColor3 = Color3.fromHSV(h, 1, 1)
								pcall(callback, color)
							end

							do
								local color = Color3.fromHSV(h, s, v)
								sample.ImageColor3 = color
								saturation.ImageColor3 = Color3.fromHSV(h, 1, 1)
							end

							local Entered1, Entered2 = false, false
							palette.MouseEnter:Connect(function()
								Window.Draggable = false
								Entered1 = true
							end)
							palette.MouseLeave:Connect(function()
								Window.Draggable = true
								Entered1 = false
							end)
							saturation.MouseEnter:Connect(function()
								Window.Draggable = false
								Entered2 = true
							end)
							saturation.MouseLeave:Connect(function()
								Window.Draggable = true
								Entered2 = false
							end)

							local palette_indicator = palette:FindFirstChild("Indicator")
							local saturation_indicator = saturation:FindFirstChild("Indicator")
							palette_indicator.ZIndex = palette_indicator.ZIndex + (windows * 10)
							saturation_indicator.ZIndex = saturation_indicator.ZIndex + (windows * 10)

							local Held = false
							UIS.InputBegan:Connect(function(inputObject)
								if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
									Held = true

									spawn(function() -- Loop check
										while Held and Entered1 and (not dropdown_open) do -- Palette
											local mouse_location = gMouse()

											local x = ((palette.AbsoluteSize.X - (mouse_location.X - palette.AbsolutePosition.X)) + 1)
											local y = ((palette.AbsoluteSize.Y - (mouse_location.Y - palette.AbsolutePosition.Y)) + 1.5)

											local color = Color3.fromHSV(x / 100, y / 100, 0)
											h = x / 100
											s = y / 100

											Resize(palette_indicator, {Position = UDim2.new(0, math.abs(x - 100) - (palette_indicator.AbsoluteSize.X / 2), 0, math.abs(y - 100) - (palette_indicator.AbsoluteSize.Y / 2))}, options.tween_time)

											update()
											RS.Heartbeat:Wait()
										end

										while Held and Entered2 and (not dropdown_open) do -- Saturation
											local mouse_location = gMouse()
											local y = ((palette.AbsoluteSize.Y - (mouse_location.Y - palette.AbsolutePosition.Y)) + 1.5)
											v = y / 100

											Resize(saturation_indicator, {Position = UDim2.new(0, 0, 0, math.abs(y - 100))}, options.tween_time)

											update()
											RS.Heartbeat:Wait()
										end
									end)
								end
							end)
							UIS.InputEnded:Connect(function(inputObject)
								if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
									Held = false
								end
							end)

							function color_picker_data:Set(color)
								color = typeof(color) == "Color3" and color or Color3.new(1, 1, 1)
								local h2, s2, v2 = rgbtohsv(color.r * 255, color.g * 255, color.b * 255)
								sample.ImageColor3 = color
								saturation.ImageColor3 = Color3.fromHSV(h2, 1, 1)
								pcall(callback, color)
							end
						end

						return color_picker_data, color_picker
					end

					function tab_data:AddConsole(console_options)
						local console_data = {}

						console_options = typeof(console_options) == "table" and console_options or {["readonly"] = true,["full"] = false,}
						console_options = {
							["y"] = tonumber(console_options.y) or 200,
							["source"] = console_options.source or "Logs",
							["readonly"] = ((console_options.readonly) == true),
							["full"] = ((console_options.full) == true),
						}

						local console = Prefabs:FindFirstChild("Console"):Clone()

						console.Parent = new_tab
						console.ZIndex = console.ZIndex + (windows * 10)
						console.Size = UDim2.new(1, 0, console_options.full and 1 or 0, console_options.y)

						local sf = console:GetChildren()[1]
						local Source = sf:FindFirstChild("Source")
						local Lines = sf:FindFirstChild("Lines")
						Source.ZIndex = Source.ZIndex + (windows * 10)
						Lines.ZIndex = Lines.ZIndex + (windows * 10)

						Source.TextEditable = not console_options.readonly

						do -- Syntax Zindex
							for i,v in next, Source:GetChildren() do
								v.ZIndex = v.ZIndex + (windows * 10) + 1
							end
						end
						Source.Comments.ZIndex = Source.Comments.ZIndex + 1

						do -- Highlighting (thanks to whoever made this)
							local lua_keywords = {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"}
							local global_env = {"getrawmetatable", "newcclosure", "islclosure", "setclipboard", "game", "workspace", "script", "math", "string", "table", "print", "wait", "BrickColor", "Color3", "next", "pairs", "ipairs", "select", "unpack", "Instance", "Vector2", "Vector3", "CFrame", "Ray", "UDim2", "Enum", "assert", "error", "warn", "tick", "loadstring", "_G", "shared", "getfenv", "setfenv", "newproxy", "setmetatable", "getmetatable", "os", "debug", "pcall", "ypcall", "xpcall", "rawequal", "rawset", "rawget", "tonumber", "tostring", "type", "typeof", "_VERSION", "coroutine", "delay", "require", "spawn", "LoadLibrary", "settings", "stats", "time", "UserSettings", "version", "Axes", "ColorSequence", "Faces", "ColorSequenceKeypoint", "NumberRange", "NumberSequence", "NumberSequenceKeypoint", "gcinfo", "elapsedTime", "collectgarbage", "PhysicalProperties", "Rect", "Region3", "Region3int16", "UDim", "Vector2int16", "Vector3int16", "load", "fire", "Fire"}

							local Highlight = function(string, keywords)
							    local K = {}
							    local S = string
							    local Token =
							    {
							        ["="] = true,
							        ["."] = true,
							        [","] = true,
							        ["("] = true,
							        [")"] = true,
							        ["["] = true,
							        ["]"] = true,
							        ["{"] = true,
							        ["}"] = true,
							        [":"] = true,
							        ["*"] = true,
							        ["/"] = true,
							        ["+"] = true,
							        ["-"] = true,
							        ["%"] = true,
									[";"] = true,
									["~"] = true
							    }
							    for i, v in pairs(keywords) do
							        K[v] = true
							    end
							    S = S:gsub(".", function(c)
							        if Token[c] ~= nil then
							            return "\32"
							        else
							            return c
							        end
							    end)
							    S = S:gsub("%S+", function(c)
							        if K[c] ~= nil then
							            return c
							        else
							            return (" "):rep(#c)
							        end
							    end)

							    return S
							end

							local hTokens = function(string)
							    local Token =
							    {
							        ["="] = true,
							        ["."] = true,
							        [","] = true,
							        ["("] = true,
							        [")"] = true,
							        ["["] = true,
							        ["]"] = true,
							        ["{"] = true,
							        ["}"] = true,
							        [":"] = true,
							        ["*"] = true,
							        ["/"] = true,
							        ["+"] = true,
							        ["-"] = true,
							        ["%"] = true,
									[";"] = true,
									["~"] = true
							    }
							    local A = ""
							    string:gsub(".", function(c)
							        if Token[c] ~= nil then
							            A = A .. c
							        elseif c == "\n" then
							            A = A .. "\n"
									elseif c == "\t" then
										A = A .. "\t"
							        else
							            A = A .. "\32"
							        end
							    end)

							    return A
							end

							local strings = function(string)
							    local highlight = ""
							    local quote = false
							    string:gsub(".", function(c)
							        if quote == false and c == "\34" then
							            quote = true
							        elseif quote == true and c == "\34" then
							            quote = false
							        end
							        if quote == false and c == "\34" then
							            highlight = highlight .. "\34"
							        elseif c == "\n" then
							            highlight = highlight .. "\n"
									elseif c == "\t" then
									    highlight = highlight .. "\t"
							        elseif quote == true then
							            highlight = highlight .. c
							        elseif quote == false then
							            highlight = highlight .. "\32"
							        end
							    end)

							    return highlight
							end

							local info = function(string)
							    local highlight = ""
							    local quote = false
							    string:gsub(".", function(c)
							        if quote == false and c == "[" then
							            quote = true
							        elseif quote == true and c == "]" then
							            quote = false
							        end
							        if quote == false and c == "\]" then
							            highlight = highlight .. "\]"
							        elseif c == "\n" then
							            highlight = highlight .. "\n"
									elseif c == "\t" then
									    highlight = highlight .. "\t"
							        elseif quote == true then
							            highlight = highlight .. c
							        elseif quote == false then
							            highlight = highlight .. "\32"
							        end
							    end)

							    return highlight
							end

							local comments = function(string)
							    local ret = ""
							    string:gsub("[^\r\n]+", function(c)
							        local comm = false
							        local i = 0
							        c:gsub(".", function(n)
							            i = i + 1
							            if c:sub(i, i + 1) == "--" then
							                comm = true
							            end
							            if comm == true then
							                ret = ret .. n
							            else
							                ret = ret .. "\32"
							            end
							        end)
							        ret = ret
							    end)

							    return ret
							end

							local numbers = function(string)
							    local A = ""
							    string:gsub(".", function(c)
							        if tonumber(c) ~= nil then
							            A = A .. c
							        elseif c == "\n" then
							            A = A .. "\n"
									elseif c == "\t" then
										A = A .. "\t"
							        else
							            A = A .. "\32"
							        end
							    end)

							    return A
							end

							local highlight_lua = function(type)
								if type == "Text" then
									Source.Text = Source.Text:gsub("\13", "")
									Source.Text = Source.Text:gsub("\t", "      ")
									local s = Source.Text

									Source.Keywords.Text = Highlight(s, lua_keywords)
									Source.Globals.Text = Highlight(s, global_env)
									Source.RemoteHighlight.Text = Highlight(s, {"FireServer", "fireServer", "InvokeServer", "invokeServer"})
									Source.Tokens.Text = hTokens(s)
									Source.Numbers.Text = numbers(s)
									Source.Strings.Text = strings(s)
									Source.Comments.Text = comments(s)

									local lin = 1
									s:gsub("\n", function()
										lin = lin + 1
									end)

									Lines.Text = ""
									for i = 1, lin do
										Lines.Text = Lines.Text .. i .. "\n"
									end

									sf.CanvasSize = UDim2.new(0, 0, lin * 0.153846154, 0)
								end

							local highlight_logs = function(type)
							end
								if type == "Text" then
									Source.Text = Source.Text:gsub("\13", "")
									Source.Text = Source.Text:gsub("\t", "      ")
									local s = Source.Text

									Source.Info.Text = info(s)

									local lin = 1
									s:gsub("\n", function()
										lin = lin + 1
									end)

									sf.CanvasSize = UDim2.new(0, 0, lin * 0.153846154, 0)
								end
							end

							if console_options.source == "Lua" then
								highlight_lua("Text")
								Source.Changed:Connect(highlight_lua)
							elseif console_options.source == "Logs" then
								Lines.Visible = false

								highlight_logs("Text")
								Source.Changed:Connect(highlight_logs)
							end

							function console_data:Set(code)
								Source.Text = tostring(code)
							end

							function console_data:Get()
								return Source.Text
							end

							function console_data:Log(msg)
								Source.Text = Source.Text .. "[*] " .. tostring(msg) .. "\n"
							end

						end

						return console_data, console
					end

					function tab_data:AddHorizontalAlignment()
						local ha_data = {}

						local ha = Prefabs:FindFirstChild("HorizontalAlignment"):Clone()
						ha.Parent = new_tab

						function ha_data:AddButton(...)
							local data, object
							local ret = {tab_data:AddButton(...)}
							if typeof(ret[1]) == "table" then
								data = ret[1]
								object = ret[2]
								object.Parent = ha
								return data, object
							else
								object = ret[1]
								object.Parent = ha
								return object
							end
						end

						return ha_data, ha
					end

					function tab_data:AddFolder(folder_name) -- [Folder]
						local folder_data = {}

						folder_name = tostring(folder_name or "New Folder")

						local folder = Prefabs:FindFirstChild("Folder"):Clone()
						local button = folder:FindFirstChild("Button")
						local objects = folder:FindFirstChild("Objects")
						local toggle = button:FindFirstChild("Toggle")
						folder.ZIndex = folder.ZIndex + (windows * 10)
						button.ZIndex = button.ZIndex + (windows * 10)
						objects.ZIndex = objects.ZIndex + (windows * 10)
						toggle.ZIndex = toggle.ZIndex + (windows * 10)
						button:GetChildren()[1].ZIndex = button:GetChildren()[1].ZIndex + (windows * 10)

						folder.Parent = new_tab
						button.Text = "      " .. folder_name

						spawn(function()
							while true do
								if button and button:GetChildren()[1] then
									button:GetChildren()[1].ImageColor3 = options.main_color
								end
								RS.Heartbeat:Wait()
							end
						end)

						local function gFolderLen()
							local n = 25
							for i,v in next, objects:GetChildren() do
								if not (v:IsA("UIListLayout")) then
									n = n + v.AbsoluteSize.Y + 5
								end
							end
							return n
						end

						local open = false
						button.MouseButton1Click:Connect(function()
							if open then -- Close
								Resize(toggle, {Rotation = 0}, options.tween_time)
								objects.Visible = false
							else -- Open
								Resize(toggle, {Rotation = 90}, options.tween_time)
								objects.Visible = true
							end

							open = not open
						end)

						spawn(function()
							while true do
								Resize(folder, {Size = UDim2.new(1, 0, 0, (open and gFolderLen() or 20))}, options.tween_time)
								wait()
							end
						end)

						for i,v in next, tab_data do
							folder_data[i] = function(...)
								local data, object
								local ret = {v(...)}
								if typeof(ret[1]) == "table" then
									data = ret[1]
									object = ret[2]
									object.Parent = objects
									return data, object
								else
									object = ret[1]
									object.Parent = objects
									return object
								end
							end
						end

						return folder_data, folder
					end

				end

				return tab_data, new_tab
			end
		end
	end

	do
		for i, v in next, Window:GetDescendants() do
			if hasprop(v, "ZIndex") then
				v.ZIndex = v.ZIndex + (windows * 10)
			end
		end
	end

	return window_data, Window
end
--#endregion

--#region allRobberySetupAndFunctions
--[[ All robbery vars ]]--
robbedShip = false
robbedBank = false
robbedCrater = false
robbedCasino = false
robbedJstore = false
robbedMuseum = false
robbedTomb = false
robbedPlane = false
robbedPass = false
mainToggle = false
robbedPower = false
robbedCargoT = false
robbedRig = false
killAuraEnabled = true
robberystatuses = replicated_storage:WaitForChild("RobberyState")

local mansionState = robberystatuses["16"]

--#region [[ DECIDING FUNCTIONS ]]
function WaitForReward()
	if Player.PlayerGui.AppUI:FindFirstChild("RewardSpinner") then
		repeat
			task.wait()
		until not Player.PlayerGui.AppUI:FindFirstChild("RewardSpinner")
	end
	return true
end

function isMansionOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.MANSION) then
			return (v.Value == 1)
		end
	end
end

function isShipOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.CARGO_SHIP) then
			return (v.Value == 1)
		end
	end
end

function isBankOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.BANK) then
			return (v.Value == 1 or v.Value == 2)
		end
	end
end

function isAlternateBankOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.BANK2) then
			return (v.Value == 1 or v.Value == 2)
		end
	end
end

function isJstoreOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.JEWELRY) then
			return (v.Value == 1 or v.Value == 2)
		end
	end
end

function checkcrate()
	if workspace:FindFirstChild("Plane") then
		local ic = workspace:FindFirstChild("Plane"):WaitForChild("Crates"):GetChildren()
		for jc = 1, #ic do
			local kc = ic[jc]:FindFirstChild("1")
			if kc and kc.Transparency == 0 then
				return kc
			end
		end
	end
end

function isPlaneOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.CARGO_PLANE) and checkcrate() then
			return (v.Value == 1)
		end
	end
end

function isTombOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.TOMB) then
			return (v.Value == 2)
		end
	end
end

function isCasinoOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.CASINO) then
			return (v.Value == 1 or v.Value == 2)
		end
	end
end

function isMuseumOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.MUSEUM) then
			return (v.Value == 2)
		end
	end
end

function isPassTrainOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.TRAIN_PASSENGER) then
			return (v.Value == 1)
		end
	end
end

function isPowerOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.POWER_PLANT) then
			return (v.Value == 1 or v.Value == 2)
		end
	end
end

function isCargoTrainOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.TRAIN_CARGO) then
			return (v.Value == 1)
		end
	end
end

function isGasOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if (v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.STORE_GAS)) then
			return (v.Value == 1)
		end
	end
end

function isDonutOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if (v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.STORE_DONUT)) then
			return (v.Value == 1)
		end
	end
end

function isRigOpen()
	for i,v in pairs(robberystatuses:GetChildren()) do
		if (v.Name == tostring(Other_Modules.RobberyConsts.ENUM_ROBBERY.OIL_RIG)) and workspace.OilRig.GuardCounters.GuardCounter.SurfaceGui.TextLabel.Text == "00"  then
			return (v.Value == 2)
		end
	end
end
--#endregion

function returnstring(ic)
	return tonumber((tostring(ic):gsub("%D", "")))
end

function fullBag()
	local ic, jc = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui").RobberyMoneyGui.Container.Bottom.Progress.Amount.Text:match("(.-)/(.+)")
	return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui").RobberyMoneyGui.Enabled and ic and jc and returnstring(ic) >= returnstring(jc)
end

function powerValue()
	local ic, jc = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui").PowerPlantRobberyGui.Price.TextLabel.Text:match("(.-): (.+)")
	if settingsShort.maxPowerPlant > 6000 then
		settingsShort.maxPowerPlant = 6000
	end
	return jc and returnstring(jc) <= settingsShort.maxPowerPlant
end

--Check Arrests and Dead
LPH_NO_VIRTUALIZE(function()
	coroutine.wrap(function()
		while wait(10) do
			if Player.PlayerGui.MainGui.CellTime.Visible == true then
				InstantEscape()
				TPhome()
			end
			if Player.Character.Humanoid.Health == 0 then
				InstantEscape()
				TPhome()
			end
		end
	end)()
end)()

function RobDrop(airdrop)
	replaceStatus("Airdrop Ready")
	task.wait(.5)

	local drop = airdrop

	if not drop:GetAttribute("BriefcaseLanded") then
        replaceStatus("Waiting for drop to land")
        repeat task.wait() until drop:GetAttribute("BriefcaseLanded") == true
    end

	replaceStatus("Teleporting to Airdrop")
	CarT(drop.PrimaryPart.CFrame * CFrame.new(15, 10, 0), offset)
	task.wait(.5)
    ExitCar()
    Small(drop.PrimaryPart.CFrame * CFrame.new(0, 6, 0))
	replaceStatus("Collecting drop")
	repeat
        drop.BriefcasePress:FireServer()
        drop.BriefcaseCollect:FireServer()
		task.wait()
    until drop:GetAttribute("BriefcaseCollected") == true or not drop.PrimaryPart or not Char or not Root or (settingsShort.copDetection == true and checkForCops() == true)
    Small(drop.PrimaryPart.CFrame * CFrame.new(0, 6, 0))
	drop.Name = ""
    repeat
		task.wait()
	until Workspace.DroppedCash:GetChildren()[1] ~= nil or (settingsShort.copDetection == true and checkForCops() == true)
    replaceStatus("Collecting cash")
    for i = 1, 10 do
		if settingsShort.copDetection then
			if checkForCops() == true then
				break
			end
		end
        for _, v in pairs(Other_Modules.UI.CircleAction.Specs) do
            if v.Name:sub(1, 7) == "Collect" then
                v:Callback(true)
            end
        end
        task.wait(0.5)
    end
    task.wait(.5)
end

function RobPlane()
	if workspace:FindFirstChild("Plane") then
		replaceStatus("CargoPlane Ready")
		task.wait(.5)
		local checkUIElement = LPH_NO_VIRTUALIZE(function()
			local uiElement =  Other_Modules.UI.CircleAction.Specs
			for index, action in next, Other_Modules.UI.CircleAction.Specs do
				if action.Name == "Inspect Crate" then
					return uiElement ~= nil
				end
			end
		end)
		local function waitForUIElement()
			while not checkUIElement() do
				task.wait()
			end
		end
		replaceStatus("Waiting for takeoff")
		waitForUIElement()
		local crates = workspace:FindFirstChild("Plane").Crates:GetChildren()
		for crate = 1, #crates do
			if fullBag() then
				break
			end
			if workspace:FindFirstChild("Plane") == nil then
				break
			end
			if crates == nil then
				break
			end

			local currentCrate = crates[crate].PrimaryPart
			if currentCrate and currentCrate.Transparency < 1 then
				for i,v in pairs(crates[crate]:GetDescendants()) do
					if v and v:IsA("MeshPart") then
						v.CanCollide = false
					end
				end
				replaceStatus("Inspecting Crate #" .. crate)
				for cratesteal = 1, 100 do
					if settingsShort.teleport == false then
						CarT(currentCrate, offset)
					else
    					if GetVehicleModel() then
							GetVehicleModel().PrimaryPart.CFrame = currentCrate.CFrame
						else
							game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = currentCrate.CFrame
						end
					end

					for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
						if v.Name == "Inspect Crate" then
							v:Callback(true)
							break
						end
					end

					task.wait(0.01)


					if settingsShort.hyperMode == false then
						if fullBag() then
							break
						end
					else
						if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
							break
						end
					end

					if currentCrate.Transparency == 1 or currentCrate == nil then
						break
					end
				end
			end
		end

		if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
			replaceStatus("Teleporting to Cargo Port")
			CarT(CFrame.new(cargoPlaneSell.X, 5000, cargoPlaneSell.Z), offset)
			if GetVehiclePacket() and table.find(OwnedCars, GetVehicleModel().Name) then
				unHideCar()
			elseif GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
				HideCar()
			end
			platform.CFrame = CFrame.new(cargoPlaneSell.X, 4990, cargoPlaneSell.Z)
			local waitBeforeSellTime = settingsShort.waitBeforeSell
			for seconds = 1, 100 do
				if waitBeforeSellTime <= 0 then
					break
				end
				replaceStatus("Waiting to sell.. (" .. waitBeforeSellTime .. "s)")
				task.wait(1)
				waitBeforeSellTime -= 1
			end

			replaceStatus("Selling")
			CarT(cargoPlaneSell, offset)

			repeat
				task.wait()
			until game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == false
		end
	end
end

function RobPassenger()
	replaceStatus("PassengerTrain Ready")
	task.wait(.5)
	for try = 1, 5 do
		replaceStatus("Grabbing items")
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
			if v.Name == "Grab computer" then
				v:Callback(true)
				break
			end
		end
		task.wait(1.5)
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
			if v.Name == "Grab phone" then
				v:Callback(true)
				break
			end
		end
		task.wait(1.5)
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
			if v.Name == "Grab documents" then
				v:Callback(true)
				break
			end
		end
		task.wait(1.5)
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
			if v.Name == "Grab spyglasses" then
				v:Callback(true)
				break
			end
		end
		task.wait(1.5)
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
			if v.Name == "Grab briefcase" then
				v:Callback(true)
				break
			end
		end
		task.wait(1.5)
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
			if v.Name == "Grab Cash" then
				v:Callback(true)
				break
			end
		end
		task.wait(1.5)
		if settingsShort.hyperMode == false then
			if fullBag() then
				break
			end
		else
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
	end
	task.wait()
	if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
		sellVolcano()
	end
end

function RobPower()
	local powerState = robberystatuses["5"]
	replaceStatus("PowerPlant Ready")
	task.wait(.5)
	replaceStatus("Teleporting to PowerPlant")
	if settingsShort.teleport == false then
		CarT(powerOutside, offset)
		task.wait(.5)
		ExitCar()
	else
		InstantT(CFrame.new(171, 0, 2157))
		task.wait(.5)
		if (game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position - Vector3.new(59.32557678222656, 21.88442039489746, 2250.90283203125)).Magnitude < 2 then
			local Points = { CFrame.new(26, 23, 2258), CFrame.new(45, 26, 2315) }
			for _, v in next, Points do
				Small(v)
			end
		elseif (game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position - Vector3.new(37.706790924072266, 21.53441619873047, 2277.969970703125)).Magnitude < 2 then
			Small(CFrame.new(45, 26, 2315))
		end
	end

	if powerState.Value == 2 then
		replaceStatus("Going to puzzle #2")
		if (game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position - Vector3.new(171, 0, 2157)).Magnitude > 5 then
			local Points = { CFrame.new(65, 23, 2300), CFrame.new(80, 22, 2285), CFrame.new(102, 22, 2293), CFrame.new(120, 21, 2284), CFrame.new(110, 20, 2269), CFrame.new(97, 15, 2253), CFrame.new(80, 7, 2233), CFrame.new(63, 0, 2212), CFrame.new(53, -4, 2195), CFrame.new(58, -11, 2179), CFrame.new(43, -20, 2162), CFrame.new(26, -22, 2136), CFrame.new(30, -24, 2108), CFrame.new(54, -23, 2099), CFrame.new(77, -23, 2106), CFrame.new(91, -19, 2123), CFrame.new(103, -8, 2132), CFrame.new(116, -9, 2105), CFrame.new(121, -10, 2099) }
			for _, v in next, Points do
				Small(v)
			end
		else
			local Points = { CFrame.new(149, -6, 2102), CFrame.new(120, -10, 2099) }
			for _, v in next, Points do
				Small(v)
			end
		end
		repeat
			task.wait()
		until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		replaceStatus("Solving puzzle #2")
		repeat
			SolveNumberLink()
		until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		task.wait()
		replaceStatus("Escaping")
		local Points = { CFrame.new(118, -9, 2107), CFrame.new(99, -9, 2108), CFrame.new(74, -17, 2104), CFrame.new(61, -23, 2102), CFrame.new(26, -31, 2112), CFrame.new(26, -31, 2123), CFrame.new(40, -27, 2148), CFrame.new(52, -12, 2179), CFrame.new(60, 0, 2207), CFrame.new(68, 4, 2222), CFrame.new(90, 16, 2254), CFrame.new(98, 19, 2263), CFrame.new(95, 23, 2267), CFrame.new(88, 23, 2275), CFrame.new(80, 21, 2284), CFrame.new(63, 22, 2302) }
		for _, v in next, Points do
			Small(v)
		end
	end
	if powerState.Value == 1 then
		replaceStatus("Going to puzzle #1")
		Small(CFrame.new(89, 22, 2325))
		repeat
			task.wait()
		until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		replaceStatus("Solving puzzle #1")
		repeat
			SolveNumberLink()
		until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		task.wait(.1)
		replaceStatus("Going to puzzle #2")
		local Points = { CFrame.new(93, 30, 2338), CFrame.new(210, 20, 2246), CFrame.new(149, -6, 2102), CFrame.new(120, -10, 2099) }
		for _, v in next, Points do
			Small(v)
		end
		repeat
			task.wait()
		until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		replaceStatus("Solving puzzle #2")
		repeat
			SolveNumberLink()
		until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		task.wait(.1)
		replaceStatus("Escaping")
		local Points = { CFrame.new(82, -4, 2107), CFrame.new(71, -27, 2101), CFrame.new(12, -30, 2110), CFrame.new(51, -6, 2179), CFrame.new(59, 0, 2211), CFrame.new(108, 21, 2273), CFrame.new(90, 25, 2278), CFrame.new(62, 21, 2301) }
		for _, v in next, Points do
			Small(v)
		end
	end
	replaceStatus("Teleporting to Volcano Base")
	CarT(volcano, offset)
	Small(volcano)
	platform.CFrame = CFrame.new(volcano.X, volcano.Y - 10, volcano.Z)
	if GetVehiclePacket() and table.find(OwnedCars, GetVehicleModel().Name) then
		unHideCar()
	elseif GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
		HideCar()
	end
	task.wait(.1)
	replaceStatus("Waiting for $" .. settingsShort.maxPowerPlant .. " value")
	for waitingLoop = 1, 9e9 do
		task.wait(0.01)
		if powerValue() or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PowerPlantRobberyGui") == nil then
			break
		end
	end
	replaceStatus("Selling")
	platform.CFrame = CFrame.new(0,0,0)
	local Points = { CFrame.new(2285, 71, -2590), CFrame.new(2285, 28, -2589) }
	for _, v in next, Points do
    	Small(v)
	end

	repeat
		task.wait()
	until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PowerPlantRobberyGui") == nil
	replaceStatus("Escaping")
	local Points = { CFrame.new(2285, 71, -2590), volcano}
	for _, v in next, Points do
    	Small(v)
	end
	Small(volcano * CFrame.new(0, 150, 0))

	task.wait(.5)
end

function RobShip()
	replaceStatus("CargoShip Ready")
	task.wait(.5)
	if not (GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name)) then
		replaceStatus("Getting a helicopter")
		EnterHeli()
		if GetVehiclePacket() then
			GetVehicleModel().PrimaryPart.CFrame = GetVehicleModel().PrimaryPart.CFrame * CFrame.new(0, 250, 0)
			task.wait(.5)
		end
	end
	local robsDone = 0
	local shipcrates = game:GetService("Workspace"):FindFirstChild("CargoShip").Crates:GetChildren()
	if GetVehiclePacket() then
		for crate = 1, #shipcrates do
			if workspace:FindFirstChild("CargoShip") == nil then
				break
			end
			local currentCrate = shipcrates[crate].PrimaryPart
			if currentCrate == nil then
				break
			else
				if robsDone >= 2 then
					break
				end
				if settingsShort.teleport == false then
					replaceStatus("Attaching Crate #" .. crate)
					if GetVehicleModel().Preset:FindFirstChild("RopePull") == nil then
						require(game.ReplicatedStorage.Vehicle.VehicleUtils).Classes.Heli.attemptDropRope()
					end
					repeat
						task.wait()
					until GetVehicleModel():FindFirstChild("Preset") and GetVehicleModel().Preset:FindFirstChild("RopePull")
					local RopePull = GetVehicleModel().Preset:FindFirstChild("RopePull")
					RopePull.CanCollide = false
					CarT(currentCrate, offset)
					repeat
						pcall(function()
							RopePull.CFrame = currentCrate.CFrame
							RopePull.ReqLink:FireServer(currentCrate.Parent, Vector3.zero)
						end)
						task.wait()
					until RopePull.AttachedTo.Value or not workspace:FindFirstChild("CargoShip") or not currentCrate
					replaceStatus("Selling")
					CarT(robCargoLocation, offset)
					local Timeout = os.time()
					repeat
						pcall(function()
							local sellPart = currentCrate.Parent
							sellPart:SetPrimaryPartCFrame(CFrame.new(-475, -43, 1905))
							sellPart.PrimaryPart.Velocity, sellPart.PrimaryPart.RotVelocity = Vector3.new(), Vector3.new()
							task.wait(0.1)
							sellPart:SetPrimaryPartCFrame(CFrame.new(-475, -53, 1905))
							sellPart.PrimaryPart.Velocity, sellPart.PrimaryPart.RotVelocity = Vector3.new(), Vector3.new()
							task.wait(0.1)
						end)
					until os.time() - Timeout > 2 or not currentCrate
					RopePull.ReqUnlink:FireServer(currentCrate.Parent)
					robsDone += 1
					task.wait(1)
					local waitAfterSellTime = settingsShort.cargoShipSellCooldown
					for seconds = 1, 100 do
						if waitAfterSellTime <= 0 then
							break
						end
						replaceStatus("CargoShip cooldown.. (" .. waitAfterSellTime .. "s)")
						task.wait(1)
						waitAfterSellTime -= 1
					end
				else
					replaceStatus("Teleporting to Cargo Port")
					CarT(robCargoLocation, offset)
					task.wait()
					local RopePull = GetVehicleModel().Preset:FindFirstChild("RopePull")
					local Crate = currentCrate.Parent
					if GetVehiclePacket() then
						if GetVehicleModel().Preset:FindFirstChild("RopePull") == nil then
							require(game.ReplicatedStorage.Vehicle.VehicleUtils).Classes.Heli.attemptDropRope()
						end
						repeat
							task.wait()
						until GetVehicleModel():FindFirstChild("Preset") and GetVehicleModel().Preset:FindFirstChild("RopePull")

						pcall(function()
							GetVehicleModel().Winch.RopeConstraint.Length = 10000
							RopePull.CanCollide = false
							if Crate == nil then
								return
							end
							if GetVehiclePacket() then
								replaceStatus("Attaching Crate #" .. crate)
								repeat
									pcall(function()
										RopePull.CFrame = Crate.PrimaryPart.CFrame
										RopePull.ReqLink:FireServer(Crate, Vector3.zero)
									end)

									task.wait()
								until RopePull.AttachedTo.Value or not Workspace:FindFirstChild("CargoShip") or not Workspace.CargoShip.Crates:FindFirstChild("Crate")
								local Timeout = os.time()
								replaceStatus("Selling")
								repeat
									pcall(function()
										Crate:SetPrimaryPartCFrame(CFrame.new(-475, -43, 1905))
										Crate.PrimaryPart.Velocity, Crate.PrimaryPart.RotVelocity = Vector3.new(), Vector3.new()
										task.wait(0.1)
										Crate:SetPrimaryPartCFrame(CFrame.new(-475, -53, 1905))
										Crate.PrimaryPart.Velocity, Crate.PrimaryPart.RotVelocity = Vector3.new(), Vector3.new()
										task.wait(0.1)
									end)
								until os.time() - Timeout > 2 or not Crate.PrimaryPart
								RopePull.ReqUnlink:FireServer(Crate)
								robsDone += 1
								task.wait(1)
								local waitAfterSellTime = settingsShort.cargoShipSellCooldown
								for seconds = 1, 100 do
									if waitAfterSellTime <= 0 then
										break
									end
									replaceStatus("CargoShip cooldown.. (" .. waitAfterSellTime .. "s)")
									task.wait(1)
									waitAfterSellTime -= 1
								end
							end
						end)
					end
				end
			end
		end
	end
end

function checkAboveModel(model)
    local parts = model:GetDescendants() -- Get all parts within the model

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            if not workspace:Raycast(part.Position, up_vector, raycast_params) then
                return true -- nothing above any part in the model
            end
        end
    end

    return false -- something above at least one part in the model
end

checkForCops = function()
    local Closest = nil;
    local Distance = 50;
    for i, v in next, game:GetService("Players"):GetPlayers() do
        if v.Name ~= game:GetService("Players").LocalPlayer.Name and v.Team == game:GetService("Teams"):FindFirstChild("Police") and v.Team ~= game:GetService("Teams"):FindFirstChild("Prisoner") then
            if workspace[v.Name] and workspace[v.Name]:FindFirstChild("Humanoid") and workspace[v.Name]:FindFirstChild("HumanoidRootPart") and workspace[v.Name]:FindFirstChild("Humanoid").Health ~= 0 then
                local Magnitude = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - workspace[v.Name].HumanoidRootPart.Position).Magnitude;
                if Magnitude < Distance then
                    Closest = workspace[v.Name];
                    Distance = Magnitude;
                    end;
                end;
            end;
        end;

	if Closest then
		return true
	end

    return false
end;

function RobTrain()
	replaceStatus("CargoTrain Ready")
	task.wait(.5)
	local roofTpUpdated = Instance.new("BindableEvent")
    local robTpUpdated = Instance.new("BindableEvent")

    local robTp = nil
    local roofTp = nil
    local doLoop = true

	local checkpoint = CFrame.new(-1357.54932, 24.9493866, 276.430115, -0.641858339, 2.16122054e-09, 0.766823232, -7.04815484e-10, 1, -3.40836337e-09, -0.766823232, -2.72815548e-09, -0.641858339)

    local function getRoofTp()
        return roofTp
    end

    local function getRobTp()
        return robTp
    end

	spawn(function()
		while doLoop do
			local trains = workspace.Trains
			-- Search for BoxCar and retrieve robTp
			for _, trainCar in pairs(trains:GetChildren()) do
				if string.sub(trainCar.Name, 1, 6) == "BoxCar" then
					local model = trainCar:FindFirstChild("Model")
					if model then
						local rob = model:FindFirstChild("Rob")
						local box = model:FindFirstChild("Box")
						if rob or box then
							local gold = rob:FindFirstChild("Gold")
							local roof = box:FindFirstChild("Roof")
							if gold or roof then
								roofTp = roof
								roofTpUpdated:Fire()
								robTp = gold
								robTpUpdated:Fire()
								break
							end
						end
					end
				end
			end
			task.wait()
		end
	end)
	task.wait(0.5)
	getRoofTp()
	getRobTp()
	task.wait()
	if roofTp then
		if settingsShort.teleport == false then
			replaceStatus("Teleporting to CargoTrain")
			CarT(roofTp, offset)
			for i = 1, 9e9 do
				if checkAboveModel(roofTp.Parent.Parent.Parent) == true then
					break
				end
				replaceStatus("Waiting to exit the tunnel")
				if GetVehicleModel() then
					GetVehicleModel().PrimaryPart.CFrame = CFrame.new(roofTp.Position.X, 500, roofTp.Position.Z)
				else
					game:GetService("Players").LocalPlayer.PrimaryPart.CFrame = CFrame.new(roofTp.Position.X, 500, roofTp.Position.Z)
				end
				task.wait(0.01)
			end
			if not robTp then
				repeat
					getRobTp()
					task.wait()
				until robTp
			end
			ExitCar()
			for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
				if v.Name == "Open Door" then
					v:Callback(v, true)
				end
			end
			task.wait()
			for i,v in pairs(require(game:GetService('ReplicatedStorage').Module.UI).CircleAction.Specs) do
				if v.Name == "Breach Vault" then
					v:Callback(v, true)
				end
			end
		else
			local function roofActivate()
			task.spawn(function()
				for i = 1, 10 do
					local UI = require(game:GetService("ReplicatedStorage").Module:WaitForChild("UI"));
					for _, v in pairs(UI.CircleAction.Specs) do
						if v.Name == "Breach Vault" then
							v:Callback(v, true)
						end
					end
					for _, v in pairs(UI.CircleAction.Specs) do
						if v.Name == "Open Door" then
							v:Callback(v, true)
						end
					end
				task.wait()
			end
			end)
			if roofTp then
				replaceStatus("Teleporting to CargoTrain")
				for i = 1, 10 do
					local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if humanoidRootPart then
						humanoidRootPart.CFrame = CFrame.new(roofTp.Position.X, roofTp.Position.Y + 1, roofTp.Position.Z)
						task.wait()
					end
				end
			end
			end
			ExitCar()
			roofActivate()
		end

		for i = 1, 100 do
			game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(robTp.Position.X, robTp.Position.Y + 4.6, robTp.Position.Z)
			task.wait(0.01)
			if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
				break
			end
		end
		replaceStatus("Collecting money")
		repeat
			game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(robTp.Position.X, robTp.Position.Y + 4.6, robTp.Position.Z)
			task.wait(0.01)
			if settingsShort.copDetection then
				if checkForCops() == true then
					break
				end
			end
			local distance = (player.Character:FindFirstChild("HumanoidRootPart").Position - checkpoint.Position).Magnitude
		until (settingsShort.hyperMode == false and fullBag()) or (settingsShort.hyperMode == true and game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true) or game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == false or robTp == nil or distance <= 2
		for i = 1, 9e9 do
			if checkAboveModel(roofTp.Parent.Parent.Parent) == true then
				break
			end
			replaceStatus("Waiting to exit the tunnel")
			game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(robTp.Position.X, robTp.Position.Y + 4.6, robTp.Position.Z)
			task.wait(0.01)
		end
		replaceStatus("Escaping")
		game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 500 ,0)

		task.wait(1)
	end
end

function RobCasino()
	replaceStatus("Casino Ready")
	task.wait(.5)
	local computersHacked = false

	for i,v in pairs(workspace.Casino.Computers:GetDescendants()) do
		if v:IsA("Model") and v.Name == "Computer" then
			if v.PrimaryPart.BrickColor == BrickColor.new("Lime green") then
				computersHacked = true
			end
		end
	end

	if settingsShort.teleport == false then
		replaceStatus("Teleporting to Casino")
		CarT(casinoTop, offset)
		task.wait(.5)
		ExitCar()

		local Points = { CFrame.new(-13, 155, -4739), CFrame.new(-18, 155, -4755) }
		for _, v in next, Points do
    		Small(v)
		end

		if computersHacked == false then
			replaceStatus("Hacking computers")
			local Points = { CFrame.new(-18, 71, -4755), CFrame.new(-13, 71, -4737), CFrame.new(54, 71, -4723), CFrame.new(69, 76, -4663), CFrame.new(-117, 76, -4610), CFrame.new(-17, 76, -4667), CFrame.new(26, 76, -4680), CFrame.new(74, 76, -4693), CFrame.new(57, 71, -4722), CFrame.new(-13, 71, -4741), CFrame.new(-18, 71, -4755) }
			for _, v in next, Points do
				Small(v)
			end
		end

		replaceStatus("Going to vault")
		local Points = { CFrame.new(-18, -76, -4756), CFrame.new(-14, -76, -4740), CFrame.new(9, -76, -4746) }
		for _, v in next, Points do
    		Small(v)
		end

		task.wait(.2)
		for i,v in pairs(workspace.Casino:GetDescendants()) do
			if v:IsA("Part") and v.Name == "Glass" then
				v.CutRemote:FireServer()
			end
		end
		task.wait(.5)

		local Points = { CFrame.new(23, -77, -4750), CFrame.new(49, -77, -4669), CFrame.new(9, -77, -4656), CFrame.new(26, -76, -4595), CFrame.new(43, -76, -4568), CFrame.new(76, -76, -4542), CFrame.new(112, -76, -4528), CFrame.new(141, -76, -4526) }
		for _, v in next, Points do
			Small(v)
		end

		replaceStatus("Cracking the vault")

		local OpenVaults = LPH_NO_VIRTUALIZE(function()
			local HackingVault = false
			local hacked = 0
			local Rotate = true
			local VaultLight = game:GetService("Workspace").Casino.HackableVaults.VaultDoorMain.InnerModel.Model.UnlockedLED
			while hacked < 4 do
				if not HackingVault then
					game:GetService("Workspace").Casino.HackableVaults.VaultDoorMain.InnerModel.Puzzle.RequestHack:FireServer()
					HackingVault = true
					hacked = hacked + 1
				end
				if HackingVault then
					if VaultLight.BrickColor == BrickColor.new("Lime green") and Rotate then
						game:GetService("Workspace").Casino.HackableVaults.VaultDoorMain.InnerModel.Puzzle.UpdateDirection:FireServer()
						hacked = hacked + 1
						Rotate = false
					end
					if VaultLight.BrickColor ~= BrickColor.new("Lime green") then
						Rotate = true
					end
					wait(0.01)
				end
			end
		end)

		OpenVaults()
		replaceStatus("Collecting money")

		local Points = { CFrame.new(199, -70, -4527), CFrame.new(264, -77, -4445), CFrame.new(251, -77, -4439), CFrame.new(243, -76, -4455), CFrame.new(258, -77, -4512), CFrame.new(244, -76, -4527), CFrame.new(251, -77, -4542), CFrame.new(269, -76, -4525), CFrame.new(260, -76, -4593), CFrame.new(240, -76, -4599), CFrame.new(265, -77, -4615), CFrame.new(249, -77, -4582), CFrame.new(298, -76, -4484) }
		for _, v in next, Points do
			if settingsShort.hyperMode == false then
				if fullBag() then
					break
				end
			else
				if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
					break
				end
			end
    		Small(v)
		end
		replaceStatus("Escaping")
		local Points = { CFrame.new(251, -71, -4527), CFrame.new(131, -77, -4527), CFrame.new(88, -77, -4536), CFrame.new(48, -77, -4564), CFrame.new(25, -77, -4599), CFrame.new(9, -77, -4657), CFrame.new(-32, -77, -4645), CFrame.new(-49, -77, -4730) }
		for _, v in next, Points do
    		Small(v)
		end

		task.wait(.2)
		for i,v in pairs(workspace.Casino:GetDescendants()) do
			if v:IsA("Part") and v.Name == "Glass" then
				v.CutRemote:FireServer()
			end
		end
		task.wait(.5)

		local Points = { CFrame.new(-14, -77, -4740), CFrame.new(-18, -77, -4755), CFrame.new(-18, 155, -4756), CFrame.new(-12, 155, -4736), CFrame.new(33, 155, -4739) }
		for _, v in next, Points do
    		Small(v)
		end
	else
		local function collectCash()
			repeat
				local parent = game.Workspace:FindFirstChild("Casino")
				if parent then
					local loots = parent:FindFirstChild("Loots")
					if loots then
						local firstInstance = loots:GetChildren()[6]
						if firstInstance then
							local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
							if humanoidRootPart then
								humanoidRootPart.CFrame = firstInstance.CFrame
								task.wait()  -- If you need to wait, you can do it here
							end
						end
					end
				end
				task.wait()
			until (settingsShort.hyperMode == false and fullBag()) or (settingsShort.hyperMode == true and game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true)
		end
		ExitCar()
		task.wait(.5)
		for i,v in pairs(workspace.Casino.Computers:GetDescendants()) do
			replaceStatus("Hacking computers")
			if v:IsA("Model") and v.Name == "Computer" then
				if v.PrimaryPart.BrickColor == BrickColor.new("Really black") then
					repeat
						game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = v.PrimaryPart.CFrame
						task.wait(0.01)
					until v.PrimaryPart.BrickColor == BrickColor.new("Lime green") or v.PrimaryPart.BrickColor == BrickColor.new("Institutional white")
				end
			end
		end
		task.wait(.5)
		replaceStatus("Collecting money")
		collectCash()
	end

	if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
		sellVolcano()
	end
end

function RobOilRig() -- // Add hypermode later
	replaceStatus("OilRig Ready")
	task.wait(.5)
	for i, v in pairs(workspace.OilRig.GuardsFolder:GetChildren()) do
		if v:IsA("Model") then
			v:Destroy()
		end
	end
	local distanceFromOil

	if workspace.OilRig:FindFirstChild("Turrets") then
		workspace.OilRig:FindFirstChild("Turrets"):Destroy()
	end
	replaceStatus("Teleporting to OilRig")
	CarT(oilPlatform, offset)
	task.wait(.5)
	ExitCar()
	-- Small(CFrame.new(-2780, 134, -4002))
	-- Trigger Dynamite
	Small(CFrame.new(-2809, 134, -4066))

	local entranceDoorOil = workspace.OilRig.ElevatorLockPuzzle.SlideDoor.InnerModel.Door

	if entranceDoorOil.CFrame == CFrame.new(-2900.07056, 137.399994, -4065.89355, 0, 0, 1, 0, 1, 0, -1, 0, 0) then
		replaceStatus("Pulling lever")
		local Points = { CFrame.new(-2866, 134, -4065), CFrame.new(-2892, 134, -4031), CFrame.new(-2905, 134, -4031), CFrame.new(-2908, 134, -4046) }
		for _, v in next, Points do
			Small(v)
		end
		task.wait(.2)
		repeat
			for _, v in pairs(UI.CircleAction.Specs) do
				if v.Part and v.Part.Parent.Name == 'Lever_UnlockElevator' then
					v:Callback(v, true)
				end
			end
			task.wait()
		until entranceDoorOil.CFrame ~= CFrame.new(-2900.07056, 137.399994, -4065.89355, 0, 0, 1, 0, 1, 0, -1, 0, 0)
		local Points = { CFrame.new(-2906, 134, -4031), CFrame.new(-2887, 134, -4031) }
		for _, v in next, Points do
			Small(v)
		end
	end

	replaceStatus("Collecting oil")
	local Points = { CFrame.new(-2894, 134, -4066), CFrame.new(-2905, 135, -4073), CFrame.new(-2905, 152, -4107), CFrame.new(-2921, 152, -4110), CFrame.new(-2922, 164, -4085), CFrame.new(-2914, 164, -4082), CFrame.new(-2898, 164, -4082) }
	for _, v in next, Points do
		Small(v)
	end

	-- Activate the prompt
	local crackDoorThing = workspace.OilRig.CommandRoomDoor.InnerModel.DoorVisual

	if crackDoorThing.CFrame == CFrame.new(-2886.07104, 166.855942, -4082.29297, 0, 0, 1, 0, 1, -0, -1, 0, 0) then
		Small(CFrame.new(-2889, 164, -4081))
		task.wait()
		repeat
			for _, v in pairs(UI.CircleAction.Specs) do
				if v.Part and v.Part.Parent.Name == 'CommandFlowPuzzle' and v.Part.Name == "Part" then
					v:Callback(v, true)
				end
			end
			task.wait()
		until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
		repeat
			SolveNumberLink()
		until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FlowGui")
	end

	-- After it solves
	local Points = { CFrame.new(-2864, 164, -4081), CFrame.new(-2864, 164, -4042) }
	for _, v in next, Points do
		Small(v)
	end

	-- Collecting Oil #1
	local oilTank = nil

	for i, v in pairs(workspace.OilRig.OilTanks:GetChildren()) do
		if (v.Oil.Position - game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position).Magnitude < 15 then
			oilTank = v.Oil
			break
		end
	end

	repeat
		distanceFromOil = (Vector3.new(-2864, 165, -4042) - game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position).Magnitude
		if distanceFromOil > 2 then
			Small(CFrame.new(-2864, 165, -4042))
		end
		task.wait()
	until fullBag() or oilTank.Transparency == 1 or game:GetService("Players").LocalPlayer.Character.Humanoid.Health < 20

	-- Collecting Oil #2
	Small(CFrame.new(-2862, 165, -4081))

	if not player.Folder:FindFirstChild("Key") then
		local Points = { CFrame.new(-2893, 164, -4082), CFrame.new(-2892, 164, -4052), CFrame.new(-2903, 164, -4050) }

		for _, v in next, Points do
    		Small(v)
		end

		repeat
			for _, v in pairs(UI.CircleAction.Specs) do
				if v.Part and v.Part.Name == 'KeyCardGiver' then
					v:Callback(v, true)
				end
			end
			task.wait()
		until player.Folder:FindFirstChild("Key")

		local Points = { CFrame.new(-2893, 164, -4070), CFrame.new(-2895, 164, -4082) }

		for _, v in next, Points do
    		Small(v)
		end
	end


	local Points = { CFrame.new(-2921, 164, -4082), CFrame.new(-2921, 164, -4086), CFrame.new(-2920, 152, -4110), CFrame.new(-2913, 152, -4111) }

	for _, v in next, Points do
    	Small(v)
	end

	Small(CFrame.new(-2913, 152, -4113))
	task.wait(1)
	Small(CFrame.new(-2913, 152, -4132))

	for i, v in pairs(workspace.OilRig.OilTanks:GetChildren()) do
		if (v.Oil.Position - game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position).Magnitude < 15 then
			oilTank = v.Oil
			break
		end
	end

	repeat
		distanceFromOil = (Vector3.new(-2913, 152, -4132) - game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position).Magnitude
		if distanceFromOil > 2 then
			Small(CFrame.new(-2913, 152, -4132))
		end
		task.wait()
	until fullBag() or oilTank.Transparency == 1 or game:GetService("Players").LocalPlayer.Character.Humanoid.Health < 20

	replaceStatus("Escaping")

	local Points = { CFrame.new(-2913, 152, -4109), CFrame.new(-2906, 152, -4106), CFrame.new(-2905, 134, -4068), CFrame.new(-2845, 134, -4067) }
	for _, v in next, Points do
		Small(v)
	end
	task.wait(.5)
	game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 500 ,0)
	task.wait(1)
	replaceStatus("Selling")
	task.wait()
	CarT(oilRigSell, offset)
	repeat
		task.wait()
	until game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == false
end

function RobJewelry()
	replaceStatus("Jewelry Ready")
	task.wait(.5)
	local function findJewelryModel()
		-- Iterate through the children of game.Workspace.Jewelrys
		for _, jewelry in pairs((game.Workspace.Jewelrys:GetChildren())) do
			if jewelry:IsA("Model") then
				local layout = jewelry:FindFirstChild("Floors")
				if layout and layout:IsA("Model") then
					for _, childModel in pairs(layout:GetChildren()) do
						if childModel:IsA("Model") then
							return childModel.Name
						end
					end
				end
			end
			break
		end
		return nil -- Returns nil if it didn't find any matching models
	end

	local jewelryName = findJewelryModel()
	local currentBox

	function punch()
		local punchFunction
		for i, v in pairs(game:GetService("Workspace").Jewelrys:GetChildren()[1].Boxes:GetChildren()) do
			if (v.Position - game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position).magnitude < 4 then
				currentBox = v
			end
		end
		for _, func in pairs(getgc(true)) do
			if type(func) == "function" and debug.getinfo(func).name == "attemptPunch" then
				punchFunction = func
			end
		end
		repeat
			punchFunction()
			task.wait()
		until currentBox.Transparency == 1
	end

	local function getOutBitch()
		replaceStatus("Escaping")
		if game.Players.LocalPlayer.Character.PrimaryPart.Position.Y < 34 then
			-- First Floor
			if (game.Players.LocalPlayer.Character.PrimaryPart.Position.X < 134 and game.Players.LocalPlayer.Character.PrimaryPart.Position.X > 100) and (game.Players.LocalPlayer.Character.PrimaryPart.Position.Z < 1340 and game.Players.LocalPlayer.Character.PrimaryPart.Position.Z > 1278) then
				local Points = { CFrame.new(119, 18, 1305), CFrame.new(124, 18, 1337), CFrame.new(107, 18, 1341), CFrame.new(97, 36, 1285), CFrame.new(107, 36, 1284), CFrame.new(120, 36, 1340), CFrame.new(106, 36, 1341), CFrame.new(97, 54, 1287) }
				for _, v in next, Points do
					Small(v)
				end
			elseif (game.Players.LocalPlayer.Character.PrimaryPart.Position.X < 151 and game.Players.LocalPlayer.Character.PrimaryPart.Position.X > 134) and (game.Players.LocalPlayer.Character.PrimaryPart.Position.Z < 1340 and game.Players.LocalPlayer.Character.PrimaryPart.Position.Z > 1278) then
				local Points = { CFrame.new(148, 18, 1301), CFrame.new(145, 18, 1284), CFrame.new(116, 18, 1289), CFrame.new(125, 18, 1339), CFrame.new(106, 18, 1342), CFrame.new(97, 36, 1285), CFrame.new(107, 36, 1284), CFrame.new(121, 36, 1341), CFrame.new(106, 36, 1342), CFrame.new(97, 54, 1287) }
				for _, v in next, Points do
					Small(v)
				end
			else
				warn"No area found // Universal Farm"
			end
		else
			-- Second Floor
			if (game.Players.LocalPlayer.Character.PrimaryPart.Position.X < 134 and game.Players.LocalPlayer.Character.PrimaryPart.Position.X > 100) and (game.Players.LocalPlayer.Character.PrimaryPart.Position.Z < 1340 and game.Players.LocalPlayer.Character.PrimaryPart.Position.Z > 1278) then
				local Points = { CFrame.new(118, 36, 1306), CFrame.new(120, 36, 1341), CFrame.new(106, 36, 1341), CFrame.new(97, 54, 1287) }
				for _, v in next, Points do
					Small(v)
				end
			elseif (game.Players.LocalPlayer.Character.PrimaryPart.Position.X < 151 and game.Players.LocalPlayer.Character.PrimaryPart.Position.X > 134) and (game.Players.LocalPlayer.Character.PrimaryPart.Position.Z < 1340 and game.Players.LocalPlayer.Character.PrimaryPart.Position.Z > 1278) then
				local Points = { CFrame.new(143, 36, 1282), CFrame.new(113, 36, 1290), CFrame.new(121, 36, 1341), CFrame.new(106, 36, 1342), CFrame.new(97, 54, 1287) }
				for _, v in next, Points do
					Small(v)
				end
			else
				warn"No area found // Universal Farm"
			end
		end

		if jewelryName == "1_Classic" then
			local Points = { CFrame.new(95, 54, 1284), CFrame.new(124, 54, 1281), CFrame.new(126, 54, 1296), CFrame.new(140, 54, 1293), CFrame.new(146, 54, 1324), CFrame.new(127, 54, 1328), CFrame.new(129, 54, 1339), CFrame.new(140, 54, 1337), CFrame.new(163, 61, 1333), CFrame.new(154, 78, 1278), CFrame.new(153, 78, 1273), CFrame.new(124, 78, 1279), CFrame.new(133, 78, 1337), CFrame.new(138, 78, 1336), CFrame.new(163, 85, 1333), CFrame.new(153, 102, 1277), CFrame.new(153, 102, 1273), CFrame.new(137, 102, 1277), CFrame.new(135, 102, 1335), CFrame.new(124, 102, 1339), CFrame.new(119, 110, 1313), CFrame.new(114, 118, 1286), CFrame.new(135, 118, 1282), CFrame.new(142, 118, 1330) }
			for _, v in next, Points do
				Small(v)
			end
		elseif jewelryName == "2_StorageAndMeeting" then
			local Points = { CFrame.new(100, 54, 1285), CFrame.new(137, 54, 1283), CFrame.new(139, 54, 1302), CFrame.new(116, 54, 1307), CFrame.new(110, 54, 1310), CFrame.new(112, 54, 1330), CFrame.new(133, 54, 1335), CFrame.new(163, 61, 1334), CFrame.new(153, 78, 1273), CFrame.new(136, 78, 1284), CFrame.new(126, 78, 1290), CFrame.new(113, 78, 1278), CFrame.new(97, 78, 1283), CFrame.new(103, 78, 1326), CFrame.new(106, 78, 1341), CFrame.new(163, 85, 1333), CFrame.new(153, 102, 1274), CFrame.new(135, 102, 1284), CFrame.new(140, 102, 1325), CFrame.new(126, 102, 1339), CFrame.new(120, 105, 1326), CFrame.new(116, 114, 1301), CFrame.new(114, 118, 1284), CFrame.new(127, 118, 1279), CFrame.new(135, 118, 1301), CFrame.new(137, 118, 1307), CFrame.new(141, 118, 1322), CFrame.new(143, 118, 1332) }
			for _, v in next, Points do
				Small(v)
			end
		elseif jewelryName == "3_ExpandedStore" then
			local Points = { CFrame.new(114, 54, 1289), CFrame.new(135, 60, 1338), CFrame.new(162, 61, 1333), CFrame.new(152, 82, 1276), CFrame.new(113, 78, 1283), CFrame.new(99, 78, 1297), CFrame.new(132, 78, 1298), CFrame.new(141, 78, 1313), CFrame.new(106, 78, 1317), CFrame.new(116, 78, 1329), CFrame.new(145, 79, 1336), CFrame.new(163, 84, 1333), CFrame.new(151, 102, 1274), CFrame.new(136, 102, 1277), CFrame.new(133, 102, 1295), CFrame.new(138, 102, 1334), CFrame.new(125, 102, 1337), CFrame.new(114, 118, 1287), CFrame.new(127, 118, 1282), CFrame.new(131, 118, 1285), CFrame.new(138, 118, 1311), CFrame.new(139, 118, 1320) }
			for _, v in next, Points do
				Small(v)
			end
		elseif jewelryName == "4_CameraFloors" then
			local Points = { CFrame.new(96, 54, 1284), CFrame.new(139, 54, 1276), CFrame.new(142, 54, 1287), CFrame.new(113, 54, 1293), CFrame.new(114, 54, 1307), CFrame.new(143, 54, 1303), CFrame.new(146, 54, 1317), CFrame.new(120, 54, 1322), CFrame.new(122, 54, 1339), CFrame.new(140, 54, 1337), CFrame.new(162, 61, 1333), CFrame.new(153, 78, 1279), CFrame.new(153, 78, 1274), CFrame.new(144, 78, 1276), CFrame.new(122, 78, 1337), CFrame.new(140, 78, 1337), CFrame.new(163, 85, 1333), CFrame.new(154, 102, 1278), CFrame.new(153, 102, 1274), CFrame.new(136, 102, 1277), CFrame.new(135, 102, 1338), CFrame.new(124, 102, 1340), CFrame.new(120, 110, 1315), CFrame.new(115, 118, 1285), CFrame.new(134, 118, 1282), CFrame.new(142, 118, 1328) }
			for _, v in next, Points do
				Small(v)
			end
		elseif jewelryName == "5_TheCEO" then
			local Points = { CFrame.new(108, 54, 1282), CFrame.new(136, 54, 1338), CFrame.new(163, 61, 1333), CFrame.new(153, 78, 1275), CFrame.new(145, 78, 1276), CFrame.new(130, 78, 1292), CFrame.new(101, 78, 1296), CFrame.new(102, 78, 1304), CFrame.new(137, 78, 1336), CFrame.new(162, 85, 1333), CFrame.new(153, 102, 1275), CFrame.new(138, 102, 1277), CFrame.new(135, 102, 1336), CFrame.new(123, 102, 1338), CFrame.new(120, 109, 1318), CFrame.new(115, 118, 1290), CFrame.new(114, 118, 1282), CFrame.new(132, 118, 1279), CFrame.new(142, 118, 1325) }
			for _, v in next, Points do
				Small(v)
			end
		elseif jewelryName == "6_LaserRooms" then
			local Points = { CFrame.new(96, 54, 1285), CFrame.new(109, 54, 1283), CFrame.new(119, 54, 1339), CFrame.new(139, 54, 1336), CFrame.new(163, 61, 1333), CFrame.new(153, 78, 1274), CFrame.new(124, 78, 1278), CFrame.new(134, 78, 1338), CFrame.new(163, 85, 1333), CFrame.new(153, 102, 1275), CFrame.new(136, 102, 1278), CFrame.new(134, 102, 1336), CFrame.new(122, 102, 1338), CFrame.new(119, 110, 1316), CFrame.new(114, 118, 1288), CFrame.new(136, 118, 1281), CFrame.new(141, 118, 1330) }
			for _, v in next, Points do
				Small(v)
			end
		end
	end

	local function punchBoxes1()
		local BoxPoints1 = {
			CFrame.new(116, 19, 1326, -0.177785426, 2.27791705e-08, 0.984069288, -1.78493043e-08, 1, -2.63726534e-08, -0.984069288, -2.22536265e-08, -0.177785426),
			CFrame.new(114, 19, 1316, -0.177785426, 2.27791705e-08, 0.984069288, -1.78493043e-08, 1, -2.63726534e-08, -0.984069288, -2.22536265e-08, -0.177785426),
			CFrame.new(112, 19, 1305, -0.177785426, 2.27791705e-08, 0.984069288, -1.78493043e-08, 1, -2.63726534e-08, -0.984069288, -2.22536265e-08, -0.177785426),
			CFrame.new(132, 19, 1312, 0.177314565, -3.77038134e-09, -0.984154224, -1.14153542e-09, 1, -4.03675759e-09, 0.984154224, 1.83922289e-09, 0.177314565),
			CFrame.new(130, 19, 1302, 0.177314565, -3.77038134e-09, -0.984154224, -1.14153542e-09, 1, -4.03675759e-09, 0.984154224, 1.83922289e-09, 0.177314565),
			CFrame.new(105.026, 18.6256, 1285.77),
			CFrame.new(115.999, 18.6256, 1283.86),
			CFrame.new(126.492, 18.6256, 1281.95),
			CFrame.new(137.53805541992188, 18.607439041137695, 1280.27734375),
			CFrame.new(140, 19, 1300,-0.177785426, 2.27791705e-08, 0.984069288, -1.78493043e-08, 1, -2.63726534e-08, -0.984069288, -2.22536265e-08, -0.177785426),
			CFrame.new(142, 19, 1310,-0.177785426, 2.27791705e-08, 0.984069288, -1.78493043e-08, 1, -2.63726534e-08, -0.984069288, -2.22536265e-08, -0.177785426),
			CFrame.new(153, 19, 1308, 0.177314565, -3.77038134e-09, -0.984154224, -1.14153542e-09, 1, -4.03675759e-09, 0.984154224, 1.83922289e-09, 0.177314565),
			CFrame.new(150, 19, 1293, 0.177314565, -3.77038134e-09, -0.984154224, -1.14153542e-09, 1, -4.03675759e-09, 0.984154224, 1.83922289e-09, 0.177314565),
		}
		for _, point in ipairs(BoxPoints1) do
            if (settingsShort.hyperMode == false and fullBag()) or (settingsShort.hyperMode == true and game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true) then
                if settingsShort.teleport == false then
					getOutBitch()
				else
					InstantEscape()
				end
                break
            else
				replaceStatus("Breaking Boxes")
                SmallWithOrientation(point)
                punch()
            end
        end
	end

	local function punchBoxes2()
		local BoxPoints2 = {
			CFrame.new(118, 37, 1283),
			CFrame.new(127, 37, 1281),
			CFrame.new(137, 37, 1279),
			CFrame.new(140, 37, 1300),
			CFrame.new(142.54509, 37.605484, 1310.36523, -0.172443584, -2.0999269e-09, 0.985019386, -3.58758662e-10, 1, 2.06905693e-09, -0.985019386, 3.41135995e-12, -0.172443584),
			CFrame.new(142.54509, 37.605484, 1310.36523, -0.172443584, -2.0999269e-09, 0.985019386, -3.58758662e-10, 1, 2.06905693e-09, -0.985019386, 3.41135995e-12, -0.172443584),
			CFrame.new(123, 37, 1291),
			CFrame.new(130.361328, 37.8323021, 1301.91431, 0.157227069, -2.09142232e-08, -0.987562478, -5.35775468e-09, 1, -2.20306138e-08, 0.987562478, 8.75492656e-09, 0.157227069),
			CFrame.new(132.097733, 37.8323021, 1312.82922, 0.157227114, -3.2817919e-08, -0.987562478, 4.75782302e-09, 1, -3.24737535e-08, 0.987562478, 4.07107237e-10, 0.157227114),
			CFrame.new(109.783592, 37.2382088, 1301.92151, -0.1346239, -6.25610497e-08, 0.990896761, -8.46230908e-09, 1, 6.19860927e-08, -0.990896761, -4.04652145e-11, -0.1346239),
			CFrame.new(111.57653, 36.8322792, 1308.32483, -0.164289832, -4.7342219e-08, 0.986412108, 2.52641161e-08, 1, 5.2202175e-08, -0.986412108, 3.34971162e-08, -0.164289832),
			CFrame.new(113.908508, 36.8322792, 1318.72314, -0.151454329, 6.89725184e-08, 0.988464236, 5.29888915e-08, 1, -6.16583975e-08, -0.988464236, 4.30391935e-08, -0.151454329),


		}
		local PathFindToBox2 = {
			CFrame.new(142, 19, 1284),
			CFrame.new(116, 19, 1289),
			CFrame.new(125, 19, 1338),
			CFrame.new(106, 19, 1342),
			CFrame.new(97, 37, 1286),
		}
		for _, point in ipairs(PathFindToBox2) do
            Small(point)
        end
		for _, point in ipairs(BoxPoints2) do
            if (settingsShort.hyperMode == false and fullBag()) or (settingsShort.hyperMode == true and game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true) then
				if settingsShort.teleport == false then
					getOutBitch()
				else
					InstantEscape()
				end
                break
            else
				replaceStatus("Breaking Boxes")
                SmallWithOrientation(point)
				if point ~= CFrame.new(123, 37, 1291) then
					punch()
				end
            end
        end
	end

	replaceStatus("Teleporting to Jewelry")
	if settingsShort.teleport == false then
		CarT(jewelryOut, offset)
		task.wait(.5)
		ExitCar()
		Small(CFrame.new(136, 19, 1346))
		task.wait(0.05)
	else
		InstantT(CFrame.new(122, 22, 1319), offset)
		task.wait(.5)
		if (game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position - Vector3.new(178.4422607421875, 18.66192054748535, 1353.650634765625)).Magnitude < 5 then
			Small(CFrame.new(136, 19, 1346))
			task.wait(0.05)
		end
	end

	punchBoxes1()
	if not fullBag() then
		punchBoxes2()
	end
	task.wait()

	if game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true then
		replaceStatus("Selling")
		CarT(criminalBaseCity, offset)
		repeat
			task.wait()
		until game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == false
	end
end

function RobMuseum()
	replaceStatus("Museum Ready")
	task.wait(.5)

	local function collectMummy()
		task.spawn(function()
			repeat
				for i,v in pairs (UI.CircleAction.Specs) do
					if v.Name == "Grab Mummy" then
						v:Callback(true)
					end
				end
				task.wait()
			until fullBag() or game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true
		end)
		repeat
			local parent = game.Workspace:FindFirstChild("Museum")
			if parent then
				local loots = parent:FindFirstChild("MummyCase")
				if loots then
					local robMummyPart = loots:FindFirstChild("MummyNode")
					if robMummyPart then
						local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
						if humanoidRootPart then
							humanoidRootPart.CFrame = robMummyPart.CFrame
							task.wait()
						end
					end
				end
			end
			task.wait()
		until fullBag() or game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true
	end

	if settingsShort.teleport == false then
		replaceStatus("Teleporting to Museum")
		task.wait()
		CarT(CFrame.new(1191, 103, 1197), offset)
		task.wait(.5)
		ExitCar()
		replaceStatus("Grabbing Mummy")
		local Points = { CFrame.new(1176.2664794921875, 102.38555145263672, 1215.1329345703125), CFrame.new(1160.1767578125, 102.37088012695312, 1235.9283447265625) }
		for _, v in next, Points do
			Small(v)
		end

		repeat
			for i,v in pairs (UI.CircleAction.Specs) do
				if v.Name == "Grab Mummy" then
					v:Callback(true)
				end
			end
			task.wait()
		until fullBag() or game:GetService("Players").LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == true

		replaceStatus("Escaping")
		local Points = { CFrame.new(1176.2664794921875, 102.38555145263672, 1215.1329345703125), CFrame.new(1191, 103, 1197)}
		for _, v in next, Points do
			Small(v)
		end
	else
		ExitCar()
		task.wait(.5)
		replaceStatus("Grabbing Mummy")
		collectMummy()
		-- InstantT cframe is CFrame.new(1160.1767578125, 102, 1235.9283447265625)
	end
	task.wait()
	TPhome()
	local waitBeforeSellTime = settingsShort.waitBeforeSell
	for seconds = 1, 100 do
		if waitBeforeSellTime <= 0 then
			break
		end
		replaceStatus("Waiting to sell.. (" .. waitBeforeSellTime .. "s)")
		task.wait(1)
		waitBeforeSellTime -= 1
	end
	sellVolcano()
	task.wait()
end

function RobGas()
	replaceStatus("Teleporting to Gas Station")
	task.wait()
	CarT(CFrame.new(-1593, 32, 711), offset)
	if GetVehiclePacket() and table.find(OwnedCars, GetVehicleModel().Name) then
		unHideCar()
	elseif GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
		HideCar()
	end
	task.wait(.5)
	for i,v in pairs (UI.CircleAction.Specs) do
		if v.Name == "Rob" then
			replaceStatus("Robbing Asimo3089..")
			v:Callback()
			task.wait(v.Duration)
			v:Callback(true)
			task.wait(1)
		end
	end
end

function RobDonut()
	replaceStatus("Teleporting to Donut Store")
	task.wait()
	CarT(CFrame.new(78.01358795166016, 32, -1594.1177978515625), offset)
	if GetVehiclePacket() and table.find(OwnedCars, GetVehicleModel().Name) then
		unHideCar()
	elseif GetVehiclePacket() and table.find(OwnedHelis, GetVehicleModel().Name) then
		HideCar()
	end
	task.wait(.5)
	for i,v in pairs (UI.CircleAction.Specs) do
		if v.Name == "Rob" then
			replaceStatus("Robbing Badcc..")
			v:Callback()
			task.wait(v.Duration)
			v:Callback(true)
			task.wait(1)
		end
	end
end
--#endregion

--#region allGUI Interaction
LPH_NO_VIRTUALIZE(function()
	coroutine.wrap(function()
		while true do
			if not isShipOpen() then
				robbedShip = false
			end
			if not isBankOpen() then
				robbedBank = false
			end
			if not isAlternateBankOpen() then
				robbedCrater = false
			end
			if not isRigOpen() then
				robbedRig = false
			end
			if not isCasinoOpen() then
				robbedCasino = false
			end
			if not isJstoreOpen() then
				robbedJstore = false
			end
			if not isMuseumOpen() then
				robbedMuseum = false
			end
			if not isTombOpen() then
				robbedTomb = false
			end
			if not isPlaneOpen() then
				robbedPlane = false
			end
			if not isPassTrainOpen() then
				robbedPass = false
			end
			if not isPowerOpen() then
				robbedPower = false
			end
			if not isCargoTrainOpen() then
				robbedCargoT = false
			end
		task.wait(0.01)
		end
	end)()
end)()

--Check for robberies

checkAndDoAutoRob = LPH_NO_VIRTUALIZE(function()
	while mainToggle == true do
		local SafeAmt = #Other_Modules.Store._state.safesInventoryItems
			if SafeAmt ~= 0 and settingsShort.safeDo == true then
				task.spawn(function()
					for i = 1, SafeAmt do
						local CurrentSafe = Other_Modules.Store._state.safesInventoryItems[1]

						replicated_storage[Other_Modules.SafeConsts.SAFE_OPEN_REMOTE_NAME]:FireServer(CurrentSafe.itemOwnedId)
						task.wait(3)
					end
				end)
			end
		-- Restore normal cursor behavior
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		if workspace:FindFirstChild("Drop") and settingsShort.doAirdrop and (mansionState.Value == 1 or mansionState.Value == 3) then
			pcall(RobDrop, workspace:FindFirstChild("Drop"))
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isShipOpen() and not robbedShip and settingsShort.doCargoShip then
			robbedShip = true
			pcall(RobShip)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		-- elseif isMansionOpen() and (mansionState.Value == 1 or mansionState.Value == 3) then
		-- 	pcall(mansion)
		-- 	if workspace.MansionRobbery:FindFirstChild("GuardsFolder") then
		-- 		for i, v in pairs(workspace.MansionRobbery.GuardsFolder:GetChildren()) do
		-- 			v:Remove()
		-- 		end
		-- 	end
		elseif isPowerOpen() and not robbedPower and settingsShort.doPowerPlant and (mansionState.Value == 1 or mansionState.Value == 3) then
			robbedPower = true
			pcall(RobPower)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isRigOpen() and not robbedRig and settingsShort.doOilRig and (mansionState.Value == 1 or mansionState.Value == 3)  then
			robbedRig = true
			pcall(RobOilRig)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isCasinoOpen() and not robbedCasino and settingsShort.doCasino and (mansionState.Value == 1 or mansionState.Value == 3)  then
			robbedCasino = true
			pcall(RobCasino)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isMuseumOpen() and not robbedMuseum and settingsShort.doMuseum and (mansionState.Value == 1 or mansionState.Value == 3)  then
			robbedMuseum = true
			pcall(RobMuseum)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		-- elseif isTombOpen() and not robbedTomb and (mansionState.Value == 1 or mansionState.Value == 3)  then
		-- 	robbedTomb = true
		-- 	killAuraEnabled = false
		-- 	pcall(tomb)
		elseif isJstoreOpen() and not robbedJstore and settingsShort.doJewelry and (mansionState.Value == 1 or mansionState.Value == 3)  then
			robbedJstore = true
			killAuraEnabled = false
			pcall(RobJewelry)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		-- elseif isBankOpen() and not robbedBank and (mansionState.Value == 1 or mansionState.Value == 3)  then
		-- 	robbedBank = true
		-- 	pcall(bank)
		-- elseif isAlternateBankOpen() and not robbedCrater and (mansionState.Value == 1 or mansionState.Value == 3)  then
		-- 	robbedCrater = true
		-- 	pcall(bankCrater)
		elseif isCargoTrainOpen() and not robbedCargoT and settingsShort.doCargoTrain and (mansionState.Value == 1 or mansionState.Value == 3) then
			robbedCargoT = true
			pcall(RobTrain)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isPlaneOpen() and not robbedPlane and settingsShort.doPlane and (mansionState.Value == 1 or mansionState.Value == 3) then
			robbedPlane = true
			pcall(RobPlane)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isPassTrainOpen() and not robbedPass and settingsShort.doPassengerTrain and (mansionState.Value == 1 or mansionState.Value == 3) then
			robbedPass = true
			pcall(RobPassenger)
			TPhome()
			local cooldowntimer = settingsShort.cooldown
			for seconds = 1, 100 do
				if cooldowntimer <= 0 then
					break
				end
				replaceStatus("Cooldown.. (" .. cooldowntimer .. "s)")
				task.wait(1)
				cooldowntimer -= 1
			end
		elseif isGasOpen() and settingsShort.robSmallStores and (mansionState.Value == 1 or mansionState.Value == 3) then
			pcall(RobGas)
			TPhome()
		elseif isDonutOpen() and settingsShort.robSmallStores and (mansionState.Value == 1 or mansionState.Value == 3) then
			pcall(RobDonut)
			TPhome()
		else
			replaceStatus("Waiting for robberies..")
		end
		task.wait(0.01)
	end

	if mainToggle == false then
		replaceStatus("Disabled.")
	end
end)

game:GetService("Players").LocalPlayer.Idled:connect(function()
	local VirtualUser = game:GetService("VirtualUser")
	VirtualUser:CaptureController()VirtualUser:ClickButton2(Vector2.new())
end)

do
	local Window = library:AddWindow("Universal Farm - Free // dsc.gg/universalfarm", {
		main_color = Color3.fromRGB(0, 44, 57),
		min_size = Vector2.new(380, 445),
		toggle_key = Enum.KeyCode.T,
		can_resize = true,
	})

	local Main = Window:AddTab("Main")
	local Settings = Window:AddTab("Settings")
	local Robberies = Window:AddTab("Robberies")
	local WebhooksTab = Window:AddTab("Webhooks")
	local toggleFolder = Robberies:AddFolder("Robbery Toggles")
	local statusesFolder = Robberies:AddFolder("Robbery Status")

	--[[ CONSOLE ]]--
	local statusLabel = Main:AddLabel("Status: Disabled.")
	function replaceStatus(stat)
		statusLabel.Text = "Status: ".. stat
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	--[[ AUTO ROB ]]--
	--Auto rob toggle
	local toggleAuto = Main:AddSwitch("AutoRob", function(value)
		if value == true then
			mainToggle = true
			-- task.spawn(function ()
			-- 	while true do
			-- 		chatSpam()
			-- 		task.wait(300)  -- Wait for 300 seconds, which is 5 minutes
			-- 	end
			-- end)
			replaceStatus("Starting...")
			task.wait(.1)
			replaceStatus("Scanning locations...")
			task.wait(.1)
			TPhome()
			checkAndDoAutoRob()
		end
		if value == false then
			mainToggle = false
		end
	end)
	toggleAuto:Set(false)

	--[[ SETTINGS ]]
	local PlayerSpeedSlider = Settings:AddSlider("Player Teleport Speed", function(x)
		settingsShort.player_speed = x / 1.6
	end, {
		["min"] = 1,
		["max"] = 160,
	})

	local CarSpeedSlider = Settings:AddSlider("Car Teleport Speed", function(x)
		settingsShort.vehicle_speed = x
	end, {
		["min"] = 1,
		["max"] = 575,
	})

	local HeliSpeedSlider = Settings:AddSlider("Helicopter Teleport Speed", function(x)
		settingsShort.heli_speed = x
	end, {
		["min"] = 1,
		["max"] = 8000,
	})

	--Kill aura
	local KillAuraSwitch = Main:AddSwitch("Kill Aura", function(x)
		settingsShort.killaura = x
			local function firePistolClickDetector()
			for _, giver in pairs(workspace.Givers:GetChildren()) do
				local itemValue = giver:FindFirstChildOfClass("StringValue")
				if itemValue and itemValue.Value == "Pistol" and giver:FindFirstChildOfClass("ClickDetector") then
					fireclickdetector(giver.ClickDetector)
					break
				end
			end
		end
		local function onCharacterAdded(character)
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

			if humanoidRootPart and not player.Folder:FindFirstChild("Pistol") and killAuraEnabled then
				firePistolClickDetector()
			end
		end
		onCharacterAdded(game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait())
		game:GetService("Players").LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
		if getgenv().killauraloaded then return end
		local function getNearestEnemy()
			local nearestDistance, nearestEnemy = 6000, nil
			local myTeam = tostring(game:GetService("Players").LocalPlayer.Team)
			for i,v in pairs(game:GetService("Players"):GetPlayers()) do
				local theirTeam = tostring(v.Team)
				if ((myTeam == "Police" and theirTeam == "Criminal") or theirTeam == "Police") and theirTeam ~= myTeam and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
					if (v.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < nearestDistance then
						nearestDistance, nearestEnemy = (v.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude, v
					end
				end
			end
			return nearestEnemy
		end
		local function ShootGun()
			local currentGun = Other_Modules.ItemSystem.GetLocalEquipped()
			if not currentGun then
				return
			end
			Other_Modules.GunItem._attemptShoot(currentGun)
		end
		getgenv().killauraloaded = true
		task.spawn(function ()
			while wait(0.5) do
				task.spawn(function()
					while wait(0.5) do
					if MansionRobbery:GetAttribute("MansionRobberyProgressionState") == 4 then
						killAuraEnabled = false
					elseif not MansionRobbery:GetAttribute("MansionRobberyProgressionState") == 4 then
						killAuraEnabled = true
					end
				end
				end)
				if killAuraEnabled == false or settingsShort.killaura == false then continue end
				if not game:GetService("Players").LocalPlayer.Character then continue end
				if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
				local nearestEnemy = getNearestEnemy()
				if nearestEnemy and killAuraEnabled == true then
						Other_Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = function(...)
						local arg = {RayIgnore(...)}
						if (tostring(getfenv(2).script) == "BulletEmitter" or tostring(getfenv(2).script) == "Taser") and nearestEnemy then
							local targetPart = nearestEnemy:IsA('Player') and nearestEnemy.Character and nearestEnemy.Character:FindFirstChild("HumanoidRootPart") or nearestEnemy:FindFirstChild("HumanoidRootPart")
							local targetHumanoid = nearestEnemy:IsA('Player') and nearestEnemy.Character and nearestEnemy.Character:FindFirstChild("Humanoid") or nearestEnemy:FindFirstChild("Humanoid")
							if targetPart and targetHumanoid and (targetPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 600 and targetHumanoid.Health > 0 then
								arg[1] = targetPart
								arg[2] = targetPart.Position
							end
						end
						return unpack(arg)
					end
					if not game:GetService("Players").LocalPlayer.Folder:FindFirstChild("Pistol") and killAuraEnabled == true then
						firePistolClickDetector()
					end
					if game:GetService("Players").LocalPlayer.Folder:FindFirstChild("Pistol") and killAuraEnabled == true then
						while game:GetService("Players").LocalPlayer.Folder:FindFirstChild("Pistol") and nearestEnemy and nearestEnemy.Character and nearestEnemy.Character:FindFirstChild("HumanoidRootPart") and nearestEnemy.Character:FindFirstChild("Humanoid") and (nearestEnemy.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 600 and nearestEnemy.Character.Humanoid.Health > 0 do
							game:GetService("Players").LocalPlayer.Folder.Pistol.InventoryEquipRemote:FireServer(true)
							task.wait()
							ShootGun()
						end
					end
					-- Other_Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = RayIgnore
					if game:GetService("Players").LocalPlayer.Folder:FindFirstChild("Pistol") and killAuraEnabled == true then
						game:GetService("Players").LocalPlayer.Folder.Pistol.InventoryEquipRemote:FireServer(false)
					end
				end
			end
		end)
	end)

	local robSmallStoresSwitch = Main:AddSwitch("Rob Small Stores", function(bool)
		settingsShort.robSmallStores = bool
	end)

	local serverHopSwitch = Main:AddSwitch("Server Hop", function(bool)

	end)

	local TeleportSwitch = Settings:AddSwitch("Instant Teleport [VERY FAST]", function(bool)
		settingsShort.teleport = bool
	end)

	local DetectCopsSwitch = Settings:AddSwitch("Cop Detection", function(bool)
		settingsShort.copDetection = bool
	end)

	local HyperModeSwitch = Settings:AddSwitch("Hyper Mode", function(bool)
		settingsShort.hyperMode = bool
	end)

	local AutoPlaceDynamiteSwitch = Settings:AddSwitch("Auto Place Museum Dynamite", function(bool)
		settingsShort.placeDynamite = bool
		if settingsShort.placeDynamite  then
			LPH_NO_VIRTUALIZE(function()
				coroutine.wrap(function()
					while true do
							for k, v in pairs(UI.CircleAction.Specs) do
								if (v.Name == "Place Dynamite") and settingsShort.placeDynamite  then
									v:Callback(v, true)
								end
							end
							local notificationMessage = game.Players.localPlayer.PlayerGui.NotificationGui.ContainerNotification.Message.Text
							if string.find(notificationMessage, "open") or string.find(notificationMessage, "player") or string.find(notificationMessage, "seconds") then
								game.Players.localPlayer.PlayerGui.NotificationGui.Enabled = false
							end
						task.wait()
					end
				end)()
			end)()
		end
	end)

	local cooldownSlider = Settings:AddSlider("Robbery Cooldown", function(x)
		settingsShort.cooldown = x
	end, {
		["min"] = 0,
		["max"] = 60,
	})

	local waitBeforeSellSlider = Settings:AddSlider("Wait Before Sell", function(x)
		settingsShort.waitBeforeSell = x
	end, {
		["min"] = 0,
		["max"] = 60,
	})

	local cargoShipSlider = Settings:AddSlider("CargoShip Sell Cooldown", function(x)
		settingsShort.cargoShipSellCooldown = x
	end, {
		["min"] = 0,
		["max"] = 60,
	})

	local powerPlantValueSlider = Settings:AddSlider("PowerPlant Value", function(x)
		settingsShort.maxPowerPlant = x
	end, {
		["min"] = 0,
		["max"] = 6000,
	})

	--[[ TOGGLES ]]
	local AirdropSwitch = toggleFolder:AddSwitch("Airdrop", function(bool)
		settingsShort.doAirdrop = bool
	end)

	local BankSwitch = toggleFolder:AddSwitch("Bank", function(bool)
		settingsShort.doBank = bool
	end)

	local CraterBankSwitch = toggleFolder:AddSwitch("CraterBank", function(bool)
		settingsShort.doCraterBank = bool
	end)

	local CargoTrainSwitch = toggleFolder:AddSwitch("CargoTrain", function(bool)
		settingsShort.doCargoTrain = bool
	end)

	local CargoShipSwitch = toggleFolder:AddSwitch("CargoShip", function(bool)
		settingsShort.doCargoShip = bool
	end)

	local CasinoSwitch = toggleFolder:AddSwitch("Casino", function(bool)
		settingsShort.doCasino = bool
	end)

	local JewelrySwitch = toggleFolder:AddSwitch("Jewelry", function(bool)
		settingsShort.doJewelry = bool
	end)

	local MuseumSwitch = toggleFolder:AddSwitch("Museum", function(bool)
		settingsShort.doMuseum = bool
	end)

	local OilRigSwitch = toggleFolder:AddSwitch("OilRig", function(bool)
		settingsShort.doOilRig = bool
	end)

	local PassengerTrainSwitch = toggleFolder:AddSwitch("PassengerTrain", function(bool)
		settingsShort.doPassengerTrain = bool
	end)

	local PlaneSwitch = toggleFolder:AddSwitch("CargoPlane", function(bool)
		settingsShort.doPlane = bool
	end)

	local PowerPlantSwitch = toggleFolder:AddSwitch("PowerPlant", function(bool)
		settingsShort.doPowerPlant = bool
	end)

	local TombSwitch = toggleFolder:AddSwitch("Tomb", function(bool)
		settingsShort.doTomb = bool
	end)

	--[[ WEBHOOKS ]]--
	WebhooksTab:AddTextBox("Discord Webhook For Logs", function(text)
		settingsShort.url = text
	end)
	WebhooksTab:AddTextBox("UserID For Ping", function(text)
		settingsShort.userIdNum = text
	end)

	local logHyper = WebhooksTab:AddSwitch("Log Hypers", function(bool)
		settingsShort.doHyperLog = bool
	end)
	logHyper:Set(true)

	local SafeOpenSwitch = WebhooksTab:AddSwitch("Auto open safes", function(bool)
		settingsShort.safeDo = bool
	end)


	PlayerSpeedSlider:Set(tonumber(settingsShort.player_speed) * (100/160))
	CarSpeedSlider:Set(tonumber(settingsShort.vehicle_speed) * (100/575))
	HeliSpeedSlider:Set(tonumber(settingsShort.heli_speed)* (100/8000))
	KillAuraSwitch:Set(settingsShort.killaura)
	robSmallStoresSwitch:Set(settingsShort.robSmallStores)
	TeleportSwitch:Set(settingsShort.teleport)
	DetectCopsSwitch:Set(settingsShort.copDetection)
	HyperModeSwitch:Set(settingsShort.hyperMode)
	HyperModeSwitch:Set(settingsShort.placeDynamite)
	cooldownSlider:Set(tonumber(settingsShort.cooldown) * (100/60))
	waitBeforeSellSlider:Set(tonumber(settingsShort.waitBeforeSell) * (100/60))
	cargoShipSlider:Set(tonumber(settingsShort.cargoShipSellCooldown) * (100/60))
	powerPlantValueSlider:Set(tonumber(settingsShort.maxPowerPlant) * (100/6000))

	AirdropSwitch:Set(settingsShort.doAirdrop)
	BankSwitch:Set(settingsShort.doBank)
	CraterBankSwitch:Set(settingsShort.doCraterBank)
	CargoTrainSwitch:Set(settingsShort.doCargoTrain)
	CargoShipSwitch:Set(settingsShort.doCargoShip)
	CasinoSwitch:Set(settingsShort.doCasino)
	JewelrySwitch:Set(settingsShort.doJewelry)
	MuseumSwitch:Set(settingsShort.doMuseum)
	OilRigSwitch:Set(settingsShort.doOilRig)
	PassengerTrainSwitch:Set(settingsShort.doPassengerTrain)
	PlaneSwitch:Set(settingsShort.doPlane)
	PowerPlantSwitch:Set(settingsShort.doPowerPlant)
	TombSwitch:Set(settingsShort.doTomb)

	SafeOpenSwitch:Set(settingsShort.safeDo)

	--[[ Statuses ]]
	local AirdropStatus = statusesFolder:AddLabel("Airdrop")
	local BankStatus = statusesFolder:AddLabel("Bank")
	local CraterBankStatus = statusesFolder:AddLabel("CraterBank")
	local CargoTrainStatus = statusesFolder:AddLabel("CargoTrain")
	local CargoShipStatus = statusesFolder:AddLabel("CargoShip")
	local CasinoStatus = statusesFolder:AddLabel("Casino")
	local JewelryStatus = statusesFolder:AddLabel("Jewelry")
	local MuseumStatus = statusesFolder:AddLabel("Museum")
	local OilRigStatus = statusesFolder:AddLabel("OilRig")
	local PassengerTrainStatus = statusesFolder:AddLabel("PassengerTrain")
	local PlaneStatus = statusesFolder:AddLabel("CargoPlane")
	local PowerPlantStatus = statusesFolder:AddLabel("PowerPlant")
	local TombStatus = statusesFolder:AddLabel("Tomb")

	--Status changes
	LPH_NO_VIRTUALIZE(function()
		coroutine.wrap(function()
			while true do
				if workspace:FindFirstChild("Drop") then
					AirdropStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				else
					AirdropStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isBankOpen() and not robbedBank then
					BankStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedBank == true then
					BankStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					BankStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isAlternateBankOpen() and not robbedCrater  then
					CraterBankStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedCrater == true then
					CraterBankStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					CraterBankStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isCargoTrainOpen() and not robbedCargoT then
					CargoTrainStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedCargoT == true then
					CargoTrainStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					CargoTrainStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isShipOpen() and not robbedShip then
					CargoShipStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedShip == true then
					CargoShipStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					CargoShipStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isCasinoOpen() and not robbedCasino then
					CasinoStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedCasino == true then
					CasinoStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					CasinoStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isJstoreOpen() and not robbedJstore then
					JewelryStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedJstore == true then
					JewelryStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					JewelryStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isMuseumOpen() and not robbedMuseum  then
					MuseumStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedMuseum == true then
					MuseumStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					MuseumStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isRigOpen() and not robbedRig then
					OilRigStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedRig == true then
					OilRigStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					OilRigStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isPassTrainOpen() and not robbedPass  then
					PassengerTrainStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedPass == true then
					PassengerTrainStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					PassengerTrainStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isPlaneOpen() and not robbedPlane then
					PlaneStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedPlane == true then
					PlaneStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					PlaneStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isPowerOpen() and not robbedPower  then
					PowerPlantStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedPower == true then
					PowerPlantStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					PowerPlantStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				if isTombOpen() and not robbedTomb then
					TombStatus.TextColor3 = Color3.fromRGB(43, 201, 22)
				elseif robbedTomb == true then
					TombStatus.TextColor3 = Color3.fromRGB(235, 204, 52)
				else
					TombStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				task.wait(0.01)
			end
		end)()
	end)()

	local moneyEarned = Main:AddLabel("Money Earned:")
	local elapsedTime = Main:AddLabel("Elapsed Time:")
	local hourly = Main:AddLabel("Estimated Hourly: $")


	library:FormatWindows()

	LPH_NO_VIRTUALIZE(function()
		coroutine.wrap(function()
			while true do
				disableCarSound()
				wait(.5)
			end
		end)()
	end)()
	task.spawn(function()
	Notify({Text="Thanks for using S3CRET.AutoRob - Free! Unlock all features by buying Paid!"})
	wait(5)
	Notify({Text="P.S. Enable Kill Aura for less chance of being arrested! :)"})
	wait(10)
	end)
	task.spawn(function()
		while task.wait(0.5) do
			pcall(function()
				MoneyMade = Player:WaitForChild("leaderstats"):WaitForChild("Money").Value - getgenv().StartingMoney
			end)
			pcall(function()
				RunTime = os.time() - getgenv().StartingTime
			end)
			moneyEarned.Text = "Money Earned: $" .. FormatCash(MoneyMade)
			elapsedTime.Text = "Time Elapsed: " .. TickToHMS(RunTime)
			hourly.Text = "Estimated Hourly: $" .. FormatCash(math.round((3600 / RunTime) * MoneyMade))
		end
	end)
end
--#endregion

AntiLag()

local Decal = Instance.new("Decal")
Decal.Texture = "http://www.roblox.com/asset/?id=15716501890"
Decal.Parent = platform
Decal.Face = Enum.NormalId.Top
