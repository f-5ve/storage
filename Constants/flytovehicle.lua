local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local VehiclesFolder = workspace:WaitForChild("Vehicles")
local searchPriority = {"Heli", "Camaro", "Jeep"} -- Priority order

-- Helper to find nearest vehicle by name
local function findNearestVehicle(name)
	local nearest, shortest = nil, math.huge
	for _, d in ipairs(VehiclesFolder:GetDescendants()) do
		if d:IsA("Model") and d.Name == name and d.PrimaryPart then
			local dist = (d.PrimaryPart.Position - HRP.Position).Magnitude
			if dist < shortest then
				shortest, nearest = dist, d
			end
		end
	end
	return nearest
end

-- Find vehicle based on hierarchy
local targetVehicle
for _, name in ipairs(searchPriority) do
	local found = findNearestVehicle(name)
	if found then
		targetVehicle = found
		break
	end
end

if not targetVehicle then
	warn("No Heli, Camaro, or Jeep found in workspace.Vehicles")
	return
end

-- Freeze player
Humanoid.PlatformStand = true

-- Positions
local carPos = targetVehicle.PrimaryPart.Position
local upHeight = 300
local upPos = HRP.Position + Vector3.new(0, upHeight, 0)
local aboveCar = Vector3.new(carPos.X, upPos.Y, carPos.Z)
local finalPos = carPos + Vector3.new(0, 10, 0)

-- Helper for time at 150 studs/sec
local function timeFor(from, to)
	return (from - to).Magnitude / 150
end

-- 1️⃣ Instantly go up
HRP.CFrame = CFrame.new(upPos)

-- 2️⃣ Tween horizontally to vehicle XZ
local moveTime = timeFor(Vector3.new(HRP.Position.X, 0, HRP.Position.Z), Vector3.new(carPos.X, 0, carPos.Z))
local tween = TweenService:Create(
	HRP,
	TweenInfo.new(moveTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	{CFrame = CFrame.new(aboveCar)}
)

tween:Play()
tween.Completed:Wait()

-- 3️⃣ Instantly drop down onto vehicle
HRP.CFrame = CFrame.new(finalPos)

-- Restore control
Humanoid.PlatformStand = false
print("Arrived at", targetVehicle.Name, "!")
