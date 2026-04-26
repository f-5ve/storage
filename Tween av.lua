-- No clip and teleport using TweenService

-- Function to toggle no clip mode
local function toggleNoClip(state)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character:WaitForChild("Humanoid")
    
    if state then
        -- No clip on: set the collision groups for all character parts
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        -- No clip off: revert collision settings
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Function to move player to target position with TweenService
local function tweenToPosition(targetPos, onComplete)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local TweenService = game:GetService("TweenService")

    -- Set the tween info (duration, easing style, etc.)
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Create the tween goal (target position)
    local goal = {CFrame = CFrame.new(targetPos)}

    -- Create the tween and play it
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()

    -- Call the onComplete function after the tween finishes
    if onComplete then
        tween.Completed:Connect(onComplete)
    end
end

-- Example usage
toggleNoClip(true) -- Enable no clip

-- Tween to first position (-488, 40, 604)
tweenToPosition(Vector3.new(-488, 40, 604), function()
    -- After reaching the first position, tween to the second position (-526, 41, 588)
    tweenToPosition(Vector3.new(-550, 41, 583), function()
        -- After reaching the second position, tween to the third position (-549, 40, 561)
        tweenToPosition(Vector3.new(-550, 40, 576), function()
            toggleNoClip(false) -- Disable no clip after reaching the third position
        end)
    end)
end)
