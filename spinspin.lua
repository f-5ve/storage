getgenv().crosshair = {
    Enabled = true,
    refreshRate = 0.015,
    mode = 'mouse', -- center, mouse, custom
    customPos = Vector2.new(0, 0), -- custom position
    lineWidth = 2.5,
    lineLength = 10,
    lineRadius = 11,
    lineColor = Color3.fromRGB(255, 255, 255),
    isSpinning = true, -- animate the rotation
    spinSpeed = 150,
    maxSpinAngle = 340,
    spinEasingStyle = "Circular", -- supports Sine, Back, Quad, Quart, Quint, Bounce, Elastic, Exponential, Circular, Cubic
    isResizing = false, -- animate the length
    resizeSpeed = 150,
    minResizeLength = 5,
    maxResizeLength = 22,
}

local crosshair = getgenv().crosshair
local runservice = game:GetService('RunService')
local inputservice = game:GetService('UserInputService')
local tweenservice = game:GetService('TweenService')
local camera = workspace.CurrentCamera

local lastRender = 0

-- Easing style mapping
local easingStyles = {
    Sine = Enum.EasingStyle.Sine,
    Back = Enum.EasingStyle.Back,
    Quad = Enum.EasingStyle.Quad,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Exponential = Enum.EasingStyle.Exponential,
    Circular = Enum.EasingStyle.Circular,
    Cubic = Enum.EasingStyle.Cubic,
    Linear = Enum.EasingStyle.Linear
}

local drawings = {
    crosshair = {},
    text = {
        Drawing.new('Text', {Size = 13, Font = 2, Outline = true, Text = 'Misery', Color = Color3.new(1, 1, 1)}),
        Drawing.new('Text', {Size = 13, Font = 2, Outline = true, Text = '.cc'}),
    }
}

for idx = 1, 4 do
    drawings.crosshair[idx] = Drawing.new('Line')
    drawings.crosshair[idx + 4] = Drawing.new('Line')
end

local function solve(angle, radius)
    return Vector2.new(
        math.sin(math.rad(angle)) * radius,
        -math.cos(math.rad(angle)) * radius
    )
end

runservice.PostSimulation:Connect(function()
    local _tick = tick()
    if _tick - lastRender > crosshair.refreshRate then
        lastRender = _tick

        local position = (
            crosshair.mode == 'center' and camera.ViewportSize / 2 or
            crosshair.mode == 'mouse' and inputservice:GetMouseLocation() or
            crosshair.customPos
        )

        local text1 = drawings.text[1]
        local text2 = drawings.text[2]

        text1.Visible = crosshair.Enabled
        text2.Visible = crosshair.Enabled

        if crosshair.Enabled then
            local textWidth = text1.TextBounds.X + text2.TextBounds.X
            text1.Position = position + Vector2.new(-textWidth / 2, crosshair.lineRadius + (crosshair.isResizing and crosshair.maxResizeLength or crosshair.lineLength) + 15)
            text2.Position = text1.Position + Vector2.new(text1.TextBounds.X)
            text2.Color = crosshair.lineColor
            
            for idx = 1, 4 do
                local outline = drawings.crosshair[idx]
                local inline = drawings.crosshair[idx + 4]
    
                local angle = (idx - 1) * 90
                local length = crosshair.lineLength
    
                if crosshair.isSpinning then
                    local spinAngle = -_tick * crosshair.spinSpeed % 360
                    local easingStyle = easingStyles[crosshair.spinEasingStyle] or Enum.EasingStyle.Linear
                    angle = angle + tweenservice:GetValue(spinAngle / crosshair.maxSpinAngle, easingStyle, Enum.EasingDirection.InOut) * 360
                end
    
                if crosshair.isResizing then
                    local resizeLength = _tick * crosshair.resizeSpeed % 180
                    length = crosshair.minResizeLength + math.sin(math.rad(resizeLength)) * (crosshair.maxResizeLength - crosshair.minResizeLength)
                end
    
                inline.Visible = true
                inline.Color = crosshair.lineColor
                inline.From = position + solve(angle, crosshair.lineRadius)
                inline.To = position + solve(angle, crosshair.lineRadius + length)
                inline.Thickness = crosshair.lineWidth
    
                outline.Visible = true
                outline.From = position + solve(angle, crosshair.lineRadius - 1)
                outline.To = position + solve(angle, crosshair.lineRadius + length + 1)
                outline.Thickness = crosshair.lineWidth + 1.5    
            end
        else
            for idx = 1, 4 do
                drawings.crosshair[idx].Visible = false
                drawings.crosshair[idx + 4].Visible = false
            end
        end
    end
end)
