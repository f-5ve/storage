local env = getgenv and getgenv() or _G

rawset(env, "crosshair", {
    enabled = true,
    mode = "mouse", -- center, mouse, custom
    position = Vector2.new(0, 0),

    width = 2.5,
    length = 10,
    radius = 11,
    color = Color3.fromRGB(66, 84, 245),

    outline = true,
    outline_color = Color3.new(0, 0, 0),

    outline_gradient = false,
    outline_gradient_rgb1 = Color3.fromRGB(0, 0, 0),
    outline_gradient_rgb2 = Color3.fromRGB(66, 84, 245),
    outline_gradient_animate = true,
    outline_gradient_speed = 0.75,

    spin = true,
    spin_speed = 150,
    spin_max = 360,
    spin_style = Enum.EasingStyle.Linear,

    resize = true,
    resize_speed = 150,
    resize_min = 5,
    resize_max = 22,

    gradient_lines = true,
    gradient_lines_rgb1 = Color3.fromRGB(255, 255, 255),
    gradient_lines_rgb2 = Color3.fromRGB(66, 84, 245),
    gradient_lines_segments = 18,
    gradient_lines_animate = true,
    gradient_lines_speed = 0.75,

    text = true,
    text_1 = "Misery",
    text_2 = ".cc",
    text_size = 13,
    text_font = 2,

    text_color = Color3.new(1, 1, 1),
    text_accent_color = Color3.fromRGB(66, 84, 245),
    text_outline = true,
    text_outline_color = Color3.new(0, 0, 0),

    gradient_text = true,
    gradient_text_animate = true,
    gradient_text_speed = 0.75,

    gradient_text_rgb1 = Color3.fromRGB(255, 255, 255),
    gradient_text_rgb2 = Color3.fromRGB(66, 84, 245),

    gradient_text_1 = true,
    gradient_text_1_from = 1,
    gradient_text_1_to = 0,
    gradient_text_1_rgb1 = Color3.fromRGB(255, 255, 255),
    gradient_text_1_rgb2 = Color3.fromRGB(66, 84, 245),

    gradient_text_2 = true,
    gradient_text_2_from = 1,
    gradient_text_2_to = 0,
    gradient_text_2_rgb1 = Color3.fromRGB(255, 255, 255),
    gradient_text_2_rgb2 = Color3.fromRGB(66, 84, 245),

    zindex = 1
})

local crosshair = rawget(env, "crosshair")

local uis = game:GetService("UserInputService")
local tweenservice = game:GetService("TweenService")
local camera = workspace.CurrentCamera

local modes = { "center", "mouse", "custom" }

local oldConnection = rawget(env, "__di_crosshair_connection")
if oldConnection then
    pcall(function()
        oldConnection:Disconnect()
    end)
end

local function get(key, fallback)
    local value = rawget(crosshair, key)

    if value == nil then
        return fallback
    end

    return value
end

local function v2(x, y)
    return Vector2.new(tonumber(x) or 0, tonumber(y) or 0)
end

local function add(a, b)
    return v2(
        (a and a.X or 0) + (b and b.X or 0),
        (a and a.Y or 0) + (b and b.Y or 0)
    )
end

local function sub(a, b)
    return v2(
        (a and a.X or 0) - (b and b.X or 0),
        (a and a.Y or 0) - (b and b.Y or 0)
    )
end

local function mul(a, n)
    return v2(
        (a and a.X or 0) * n,
        (a and a.Y or 0) * n
    )
end

local function clamp(n, min, max)
    return math.max(min, math.min(max, n))
end

local function colorLerp(c1, c2, alpha)
    alpha = clamp(alpha, 0, 1)

    return Color3.new(
        c1.R + ((c2.R - c1.R) * alpha),
        c1.G + ((c2.G - c1.G) * alpha),
        c1.B + ((c2.B - c1.B) * alpha)
    )
end

local function gradientAlpha(alpha, animated, speed, now)
    alpha = clamp(alpha, 0, 1)

    if animated then
        return (math.sin((alpha + now * speed) * math.pi * 2) + 1) / 2
    end

    return alpha
end

local function center()
    camera = workspace.CurrentCamera or camera

    if camera and camera.ViewportSize then
        return v2(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end

    return v2(960, 540)
end

local function mouse()
    local ok, pos = pcall(function()
        return uis:GetMouseLocation()
    end)

    if ok and pos then
        return v2(pos.X, pos.Y)
    end

    return center()
end

local function getPosition()
    local modeIndex = table.find(modes, get("mode", "mouse"))

    if modeIndex == 1 then
        return center()
    end

    if modeIndex == 2 then
        return mouse()
    end

    local pos = get("position", v2(0, 0))
    return v2(pos.X, pos.Y)
end

local function solve(angle, radius)
    return v2(
        math.sin(math.rad(angle)) * radius,
        math.cos(math.rad(angle)) * radius
    )
end

local function drawLine(from, to, color, thickness)
    pcall(function()
        DrawingImmediate.Line(from, to, color, 1, thickness)
    end)
end

local function drawGradientLine(from, to, color1, color2, thickness, segments, animated, speed, now)
    segments = math.floor(tonumber(segments) or 18)

    if segments < 2 then
        segments = 2
    end

    local delta = sub(to, from)
    local i = 0

    while i < segments do
        local a1 = i / segments
        local a2 = (i + 1) / segments

        local p1 = add(from, mul(delta, a1))
        local p2 = add(from, mul(delta, a2))

        local alpha = gradientAlpha(i / (segments - 1), animated, speed, now)
        local color = colorLerp(color1, color2, alpha)

        drawLine(p1, p2, color, thickness)

        i = i + 1
    end
end

local function drawText(pos, font, size, color, str)
    if get("text_outline", true) then
        pcall(function()
            DrawingImmediate.OutlinedText(
                pos,
                font,
                size,
                color,
                1,
                get("text_outline_color", Color3.new(0, 0, 0)),
                1,
                tostring(str),
                false
            )
        end)
    else
        pcall(function()
            DrawingImmediate.Text(
                pos,
                font,
                size,
                color,
                1,
                tostring(str),
                false
            )
        end)
    end
end

local function charWidth(char, size)
    char = tostring(char or "")

    if char == " " then
        return size * 0.33
    end

    if char == "." or char == "," or char == "'" or char == "\"" then
        return size * 0.28
    end

    if char == "i" or char == "l" or char == "I" then
        return size * 0.3
    end

    if char == "m" or char == "w" or char == "M" or char == "W" then
        return size * 0.75
    end

    return size * 0.55
end

local function textWidth(str, size)
    str = tostring(str or "")

    local width = 0
    local i = 1

    while i <= #str do
        width = width + charWidth(string.sub(str, i, i), size)
        i = i + 1
    end

    return width
end

local function getGradientRange(str, fromIndex, toIndex)
    str = tostring(str or "")

    local len = #str

    if len <= 0 then
        return 1, 0
    end

    local startIndex = math.floor(tonumber(fromIndex) or 1)
    local endIndex = math.floor(tonumber(toIndex) or 0)

    if endIndex <= 0 then
        endIndex = len
    end

    startIndex = clamp(startIndex, 1, len)
    endIndex = clamp(endIndex, 1, len)

    if endIndex < startIndex then
        endIndex = startIndex
    end

    return startIndex, endIndex
end

local function drawPartialGradientText(pos, font, size, str, baseColor, gradientEnabled, fromIndex, toIndex, color1, color2, animated, speed, now)
    str = tostring(str or "")

    local rangeStart, rangeEnd = getGradientRange(str, fromIndex, toIndex)
    local offset = 0
    local i = 1
    local len = #str
    local gradientSize = math.max(1, rangeEnd - rangeStart)

    while i <= len do
        local char = string.sub(str, i, i)
        local color = baseColor

        if gradientEnabled and i >= rangeStart and i <= rangeEnd then
            local alpha = (i - rangeStart) / gradientSize
            alpha = gradientAlpha(alpha, animated, speed, now)
            color = colorLerp(color1, color2, alpha)
        end

        drawText(add(pos, v2(offset, 0)), font, size, color, char)

        offset = offset + charWidth(char, size)
        i = i + 1
    end
end

local function getSpinAngle(baseAngle, now)
    if not get("spin", true) then
        return baseAngle
    end

    local spinSpeed = get("spin_speed", 150)
    local spinMax = get("spin_max", 360)

    if spinMax <= 0 then
        spinMax = 360
    end

    local cycle = ((-now * spinSpeed) % spinMax) / spinMax
    cycle = clamp(cycle, 0, 1)

    local ok, eased = pcall(function()
        return tweenservice:GetValue(
            cycle,
            get("spin_style", Enum.EasingStyle.Linear),
            Enum.EasingDirection.InOut
        )
    end)

    local value = ok and eased or cycle

    return baseAngle + (value * spinMax)
end

local function getSmoothLength(now)
    local length = get("length", 10)

    if not get("resize", true) then
        return length
    end

    local minLength = get("resize_min", 5)
    local maxLength = get("resize_max", 22)
    local speed = get("resize_speed", 150)

    local wave = (now * speed) % 360
    local alpha = (math.sin(math.rad(wave)) + 1) / 2

    return minLength + ((maxLength - minLength) * alpha)
end

local function drawArm(pos, baseAngle, length, now)
    local angle = getSpinAngle(baseAngle, now)
    local radius = get("radius", 11)
    local width = get("width", 2.5)

    local outlineFrom = add(pos, solve(angle, radius - 1))
    local outlineTo = add(pos, solve(angle, radius + length + 1))

    local lineFrom = add(pos, solve(angle, radius))
    local lineTo = add(pos, solve(angle, radius + length))

    if get("outline", true) then
        if get("outline_gradient", false) then
            drawGradientLine(
                outlineFrom,
                outlineTo,
                get("outline_gradient_rgb1", Color3.new(0, 0, 0)),
                get("outline_gradient_rgb2", Color3.fromRGB(66, 84, 245)),
                width + 1.5,
                get("gradient_lines_segments", 18),
                get("outline_gradient_animate", true),
                get("outline_gradient_speed", 0.75),
                now
            )
        else
            drawLine(
                outlineFrom,
                outlineTo,
                get("outline_color", Color3.new(0, 0, 0)),
                width + 1.5
            )
        end
    end

    if get("gradient_lines", true) then
        drawGradientLine(
            lineFrom,
            lineTo,
            get("gradient_lines_rgb1", Color3.fromRGB(255, 255, 255)),
            get("gradient_lines_rgb2", Color3.fromRGB(66, 84, 245)),
            width,
            get("gradient_lines_segments", 18),
            get("gradient_lines_animate", true),
            get("gradient_lines_speed", 0.75),
            now
        )
    else
        drawLine(
            lineFrom,
            lineTo,
            get("color", Color3.fromRGB(66, 84, 245)),
            width
        )
    end
end

local signal = DrawingImmediate.GetPaint(get("zindex", 1))

rawset(env, "__di_crosshair_connection", signal:Connect(function()
    if not get("enabled", true) then
        return
    end

    local now = tick()
    local pos = getPosition()
    local length = getSmoothLength(now)

    drawArm(pos, 0, length, now)
    drawArm(pos, 90, length, now)
    drawArm(pos, 180, length, now)
    drawArm(pos, 270, length, now)

    if get("text", true) then
        local size = get("text_size", 13)
        local font = get("text_font", 2)

        local text1 = tostring(get("text_1", "Misery"))
        local text2 = tostring(get("text_2", ".cc"))

        local w1 = textWidth(text1, size)
        local w2 = textWidth(text2, size)
        local total = w1 + w2

        local y = get("radius", 11) + get("resize_max", 22) + 15
        local start = add(pos, v2(-total / 2, y))

        if get("gradient_text", true) then
            drawPartialGradientText(
                start,
                font,
                size,
                text1,
                get("text_color", Color3.new(1, 1, 1)),
                get("gradient_text_1", true),
                get("gradient_text_1_from", 1),
                get("gradient_text_1_to", 0),
                get("gradient_text_1_rgb1", get("gradient_text_rgb1", Color3.fromRGB(255, 255, 255))),
                get("gradient_text_1_rgb2", get("gradient_text_rgb2", Color3.fromRGB(66, 84, 245))),
                get("gradient_text_animate", true),
                get("gradient_text_speed", 0.75),
                now
            )

            drawPartialGradientText(
                add(start, v2(w1, 0)),
                font,
                size,
                text2,
                get("text_accent_color", get("color", Color3.fromRGB(66, 84, 245))),
                get("gradient_text_2", true),
                get("gradient_text_2_from", 1),
                get("gradient_text_2_to", 0),
                get("gradient_text_2_rgb1", get("gradient_text_rgb1", Color3.fromRGB(255, 255, 255))),
                get("gradient_text_2_rgb2", get("gradient_text_rgb2", Color3.fromRGB(66, 84, 245))),
                get("gradient_text_animate", true),
                get("gradient_text_speed", 0.75),
                now
            )
        else
            drawText(
                start,
                font,
                size,
                get("text_color", Color3.new(1, 1, 1)),
                text1
            )

            drawText(
                add(start, v2(w1, 0)),
                font,
                size,
                get("text_accent_color", get("color", Color3.fromRGB(66, 84, 245))),
                text2
            )
        end
    end
end))
