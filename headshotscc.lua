-- // Feature Table //

local headshots = {

    TargetAim = {
        Enabled = false,
        Target = "None",
        AutoFire = false,
        Strafe = false,
        CSync = false,
        VisualizeStrafe = false,
        VisualizeStrafeColor = Color3.new(155, 125, 175),
        StrafeMethod = "Randomize",
        Highlight = false,
        HighlightFillColor = Color3.new(155, 125, 175),
        HighlightOutlineColor = Color3.new(129, 105, 145),
        Tracer = false,
        TracerPosition = "Mouse",
        TracerFillColor = Color3.new(155, 125, 175),
        TracerOutlineColor = Color3.new(0, 0, 0),
        LookAt = false,
        VoidResolver = false,
        AutoStomp = false,
    },

    KillAura = {
        Enabled = false,
        Keybind = false,
        Distance = 200,
        StompAura = false,
    },

    ExtraESP = {
        MaterialEnabled = false,
        Material = "Neon",
        MaterialColor = Color3.new(255, 255, 255),
        HighlightEnabled = false,
        HighlightFillColor = Color3.new(0, 0, 0),
        HighlightOutlineColor = Color3.new(0, 0, 0),
    },

    CheaterProtection = {
        Enabled = false,
    },

    HitboxExpander = {
        Enabled = false,
        Visualize = false,
        Color = Color3.new(155, 125, 175),
        OutlineColor = Color3.new(155, 125, 175),
        FillTransparency = 0.5,
        OutlineTransparency = 0.3,
        Size = 37,
    },

    Target = {
        AutoKill = false,
        AutoKillDesync = false,
        Target = nil,
    },

    Desync = {
        Enabled = false,
        Keybind = false,
        Visualize = false,
        Tranparency = 0,
        Spam = false,
        InVoid = 0.4,
        OnGround = 0.133,
        Method = "Custom",
    },

    Network = {
        Desync = false,
        UseSenderRate = false,
        SenderRate = 60,
        FakePos = false,
        RefreshRate = 20,
    },

    Speed = {
        Enabled = false,
        Keybind = false,
        Speed = 20,
    },

    Fly = {
        Enabled = false,
        Keybind = false, 
        Speed = 20,
    },

    BulletTracers = {
        Enabled = false,
        TextureID = "rbxassetid://12781852245",
        Color = Color3.new(155, 125, 175),
        Size = 0.4,
        Transparency = 0,
        TimeAlive = 3,
    },

    HitEffects = {
        HitSounds = false,
        HitSoundID = "rbxassetid://97643101798871",
        HitSoundVolume = 5,
        HitNotifications = false,
        HitNotificationsTime = 3,
    },

    AutoReload = {
        Enabled = false,
    },

    AntiStomp = {
        Enabled = false,
    },

    RapidFire = {
        Enabled = false,
    },

    AutoLoadout = {
        Enabled = false,
        Gun = "[Rifle]"
    },

    AutoArmor = {
        Enabled = false,
    },

    SelfVisuals = {
        Character = false,
        CharacterMaterial = "ForceField",
        CharacterColor = Color3.new(155, 125, 175),
        Tool = false,
        ToolMaterial = "ForceField",
        ToolColor = Color3.new(155, 125, 175),
        Aura = false,
        AuraColor = Color3.new(155, 125, 175),
        AuraTexture = "Pink Shyt",
        WalkSteps = false,
        WalkStepsRate = 0.5,
        WalkStepsSize = NumberSequence.new(0, 0.25, 0, 0.5, 1.5, 0, 1, 2, 0),
        WalkStepsColor = Color3.new(255, 255, 255),
    },

}

loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // LocalPlayer Check Loaded

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- // Checking for getcustomasset

if not getcustomasset then
    getgenv().getcustomasset = function(z) return z end
end

-- // Anticheat Bypass

local t = {}

game:GetService("RunService").Heartbeat:Connect(function()
    for _, c in ipairs(getconnections(game:GetService("LogService").MessageOut)) do
        if not table.find(t, c) then
            t[#t+1] = c
            local u = pcall(getupvalues, c.Function) and getupvalues(c.Function) or {}
            if #u >= 9 and type(u[9]) == "table" and type(u[9][1]) == "function" then
                pcall(setupvalue, u[9][1], 14, function() return function(x)
                    if type(x) == "table" then for i = 1, 4 do
                        if type(x[i]) == "userdata" and x[i].Disconnect then pcall(x[i].Disconnect, x[i]) end
                    end end
                end end)
                pcall(setupvalue, u[9][1], 1, function() task.wait(200) end)
                local o = u[9][1]
                pcall(hookfunction, u[9][1], function() return {} end)
            end
        end
    end
end)

warn("[+] headshots.cc : anticheat bypassed.")

-- // UI Library //
local uis = cloneref(game:GetService("UserInputService"))
local ws = cloneref(game:GetService("Workspace"))
local http_service = cloneref(game:GetService("HttpService"))
local gui_service = cloneref(game:GetService("GuiService"))
local lighting = cloneref(game:GetService("Lighting"))
local run = cloneref(game:GetService("RunService"))
local stats = cloneref(game:GetService("Stats"))
local coregui = cloneref(game:GetService("CoreGui"))
local debris = cloneref(game:GetService("Debris"))
local tween_service = cloneref(game:GetService("TweenService"))
local sound_service = cloneref(game:GetService("SoundService"))
local starter_gui = cloneref(game:GetService("StarterGui"))
local rs = cloneref(game:GetService("ReplicatedStorage"))

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new 
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer 
local mouse = lp:GetMouse() 
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max 
local floor = math.floor 
local min = math.min 
local abs = math.abs 
local noise = math.noise
local rad = math.rad 
local random = math.random 
local pow = math.pow 
local sin = math.sin 
local pi = math.pi 
local tan = math.tan 
local atan2 = math.atan2 
local cos = math.cos 
local round = math.round;
local clamp = math.clamp; 
local ceil = math.ceil; 
local sqrt = math.sqrt;
local acos = math.acos; 

local insert = table.insert 
local find = table.find 
local remove = table.remove
local concat = table.concat
-- 

-- library init
local library = {
directory = "headshots",
folders = {
    "/fonts",
    "/configs",
    "/assets",
    "/images"
},
flags = {},
config_flags = {},
visible_flags = {}, 
guis = {}, 
connections = {},   
notifications = {},
playerlist_data = {
},

current_tab, 
current_element_open, 
dock_button_holder,  
font, 
keybind_list,
binds = {}, 
}

local flags = library.flags
local config_flags = library.config_flags

local themes = {
preset = {
    ["outline"] = rgb(32, 32, 38), -- 
    ["inline"] = rgb(60, 55, 75), --
    ["accent"] = rgb(155,125,175), --
    ["high_contrast"] = rgb(41, 41, 55),
    ["low_contrast"] = rgb(35, 35, 47),
    ["text"] = rgb(180, 180, 180),
    ["text_outline"] = rgb(0, 0, 0),
    ["glow"] = rgb(155, 125, 175), 
},

utility = {
    ["outline"] = {
        ["BackgroundColor3"] = {}, 	
        ["Color"] = {}, 
    },
    ["inline"] = {
        ["BackgroundColor3"] = {}, 	
    },
    ["accent"] = {
        ["BackgroundColor3"] = {}, 	
        ["TextColor3"] = {}, 
        ["ImageColor3"] = {}, 
        ["ScrollBarImageColor3"] = {} 
    },
    ["contrast"] = {
        ["Color"] = {}, 	
    },
    ["text"] = {
        ["TextColor3"] = {}, 	
    },
    ["text_outline"] = {
        ["Color"] = {}, 	
    },
    ["glow"] = {
        ["ImageColor3"] = {}, 	
    }, 
}, 

find = {
    ["Frame"] = "BackgroundColor3", 
    ["TextLabel"] = "TextColor3", 
    ["UIGradient"] = "Color",
    ["UIStroke"] = "Color",
    ["ImageLabel"] = "ImageColor3",
    ["TextButton"] = "BackgroundColor3", 
    ["ScrollingFrame"] = "ScrollBarImageColor3"
}
}

local keys = {
[Enum.KeyCode.LeftShift] = "LS",
[Enum.KeyCode.RightShift] = "RS",
[Enum.KeyCode.LeftControl] = "LC",
[Enum.KeyCode.RightControl] = "RC",
[Enum.KeyCode.Insert] = "INS",
[Enum.KeyCode.Backspace] = "BS",
[Enum.KeyCode.Return] = "Ent",
[Enum.KeyCode.LeftAlt] = "LA",
[Enum.KeyCode.RightAlt] = "RA",
[Enum.KeyCode.CapsLock] = "CAPS",
[Enum.KeyCode.One] = "1",
[Enum.KeyCode.Two] = "2",
[Enum.KeyCode.Three] = "3",
[Enum.KeyCode.Four] = "4",
[Enum.KeyCode.Five] = "5",
[Enum.KeyCode.Six] = "6",
[Enum.KeyCode.Seven] = "7",
[Enum.KeyCode.Eight] = "8",
[Enum.KeyCode.Nine] = "9",
[Enum.KeyCode.Zero] = "0",
[Enum.KeyCode.KeypadOne] = "Num1",
[Enum.KeyCode.KeypadTwo] = "Num2",
[Enum.KeyCode.KeypadThree] = "Num3",
[Enum.KeyCode.KeypadFour] = "Num4",
[Enum.KeyCode.KeypadFive] = "Num5",
[Enum.KeyCode.KeypadSix] = "Num6",
[Enum.KeyCode.KeypadSeven] = "Num7",
[Enum.KeyCode.KeypadEight] = "Num8",
[Enum.KeyCode.KeypadNine] = "Num9",
[Enum.KeyCode.KeypadZero] = "Num0",
[Enum.KeyCode.Minus] = "-",
[Enum.KeyCode.Equals] = "=",
[Enum.KeyCode.Tilde] = "~",
[Enum.KeyCode.LeftBracket] = "[",
[Enum.KeyCode.RightBracket] = "]",
[Enum.KeyCode.RightParenthesis] = ")",
[Enum.KeyCode.LeftParenthesis] = "(",
[Enum.KeyCode.Semicolon] = ",",
[Enum.KeyCode.Quote] = "'",
[Enum.KeyCode.BackSlash] = "\\",
[Enum.KeyCode.Comma] = ",",
[Enum.KeyCode.Period] = ".",
[Enum.KeyCode.Slash] = "/",
[Enum.KeyCode.Asterisk] = "*",
[Enum.KeyCode.Plus] = "+",
[Enum.KeyCode.Period] = ".",
[Enum.KeyCode.Backquote] = "`",
[Enum.UserInputType.MouseButton1] = "MB1",
[Enum.UserInputType.MouseButton2] = "MB2",
[Enum.UserInputType.MouseButton3] = "MB3",
[Enum.KeyCode.Escape] = "ESC",
[Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do 
makefolder(library.directory .. path)
end 

writefile(library.directory .. "/fonts/main.ttf", game:HttpGet("https://github.com/tulontop/headshots/raw/refs/heads/main/Storage/Fonts/fs-tahoma-8px.ttf"))

pcall(function()
    local tahoma = {
        name = "SmallestPixel7",
        faces = {
            {
                name = "Regular",
                weight = 400,
                style = "normal",
                assetId = getcustomasset(library.directory .. "/fonts/main.ttf")
            }
        }
    }
        
    writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(tahoma))
        
    library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)
end)

local config_holder 
-- 

-- library functions 
-- misc functions
function library:make_resizable(frame) 
    local Frame = Instance.new("TextButton")
    Frame.Position = dim2(1, -10, 1, -10)
    Frame.BorderColor3 = rgb(0, 0, 0)
    Frame.Size = dim2(0, 10, 0, 10)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = rgb(255, 255, 255)
    Frame.Parent = frame
    Frame.BackgroundTransparency = 1 
    Frame.Text = ""

    local resizing = false 
    local start_size 
    local start 
    local og_size = frame.Size  

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)

    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event) 
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y

            local current_size = dim2(
                start_size.X.Scale,
                math.clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    og_size.X.Offset,
                    viewport_x
                ),
                start_size.Y.Scale,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    og_size.Y.Offset,
                    viewport_y
                )
            )
            frame.Size = current_size
        end
    end)
end

function library:draggify(frame)
    local dragging = false 
    local start_size = frame.Position
    local start 

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            start_size = frame.Position

            if library.current_element_open then 
                library.current_element_open.set_visible(false)
                library.current_element_open.open = false 
                library.current_element_open = nil 
            end
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event) 
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y

            local current_position = dim2(
                0,
                clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    0,
                    viewport_x - frame.Size.X.Offset
                ),
                0,
                clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    0,
                    viewport_y - frame.Size.Y.Offset
                )
            )

            frame.Position = current_position
        end
    end)
end

function library:new_drawing(class, properties)
    local ins = Drawing.new(class)

    for _, v in next, properties do 
        ins[_] = v
    end 

    insert(nebula.drawings, ins)

    return ins 
end 

function library:new_item(class, properties) 
    local ins = Instance.new(class)

    for _, v in next, properties do 
        ins[_] = v
    end 

    insert(nebula.instances, ins)

    return ins 
end 

function library:convert_enum(enum)
    local enum_parts = {}

    for part in string.gmatch(enum, "[%w_]+") do
        insert(enum_parts, part)
    end

    local enum_table = Enum
    for i = 2, #enum_parts do
        local enum_item = enum_table[enum_parts[i]]

        enum_table = enum_item
    end

    return enum_table
end

function library:tween(obj, properties) 
    local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
        
    return tween
end 

function library:config_list_update() 
    if not config_holder then return end 

    local list = {}

    for idx, file in next, listfiles(library.directory .. "/configs") do
        local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\configs\\", "")
        list[#list + 1] = name
    end
    
    config_holder.refresh_options(list)
end 

function library:get_config()
    local Config = {}

    for _, v in flags do
        if type(v) == "table" and v.key then
            Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
        elseif type(v) == "table" and v["Transparency"] and v["Color"] then
            Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
        else
            Config[_] = v
        end
    end 
    
    return http_service:JSONEncode(Config)
end

function library:load_config(config_json) 
    local config = http_service:JSONDecode(config_json)

    for _, v in next, config do 
        local function_set = library.config_flags[_]
        
        if function_set then 
            if type(v) == "table" and v["Transparency"] and v["Color"] then
                function_set(hex(v["Color"]), v["Transparency"])
            elseif type(v) == "table" and v["active"] then 
                function_set(v)
            else 
                function_set(v)
            end
        end 
    end 
end 

function library:round(number, float) 
    local multiplier = 1 / (float or 1)

    return floor(number * multiplier + 0.5) / multiplier
end 

function library:apply_theme(instance, theme, property) 
    insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
    for _, property in next, themes.utility[theme] do 

        for m, object in next, property do 
            if object[_] == themes.preset[theme] or object.ClassName == "UIGradient" then
                object[_] = color 
            end
        end 
    end 

    themes.preset[theme] = color 
end 

function library:connection(signal, callback)
    local connection = signal:Connect(callback)
    
    insert(library.connections, connection)

    return connection 
end

function library:apply_stroke(parent) 
    local stroke = library:create("UIStroke", {
        Parent = parent,
        Color = themes.preset.text_outline, 
        LineJoinMode = Enum.LineJoinMode.Miter
    }) 
    
    library:apply_theme(stroke, "text_outline", "Color")
end

function library:create(instance, options)
    local ins = Instance.new(instance) 
    
    for prop, value in next, options do 
        ins[prop] = value
    end
    
    if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
        library:apply_theme(ins, "text", "TextColor3")
        library:apply_stroke(ins)
    elseif instance == "ScreenGui" then 
        insert(library.guis, ins)
    end
    
    return ins 
end

-- 

local function parentUI(gui)
    local success, failure = pcall(function()
        if get_hidden_gui or gethui then
            local hiddenUI = get_hidden_gui or gethui
            gui.Parent = hiddenUI()
        elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
            syn.protect_gui(gui)
            gui.Parent = game:GetService("CoreGui")
        elseif game:GetService("CoreGui") then
            gui.Parent = game:GetService("CoreGui")
        end
    end)

    if not success and failure then
        gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- elements 
local tooltip_sgui = library:create("ScreenGui", {
    Enabled = true,
    Parent = nil,
    Name = "",
    DisplayOrder = 500, 
})
parentUI(tooltip_sgui)

function library:tool_tip(options) 
    local cfg = {
        name = options.name or "hi", 
        path = options.path or nil, 
    }
    
    if cfg.path then 
        local watermark_outline = library:create("Frame", {
            Parent = tooltip_sgui,
            Name = "",
            Size = dim2(0, 0, 0, 22),
            Position = dim2(0, 500, 0, 300),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = themes.preset.outline
        })
        
        local watermark_inline = library:create("Frame", {
            Parent = watermark_outline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })
        
        local watermark_background = library:create("Frame", {
            Parent = watermark_inline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = watermark_background,
            Name = "",
            Color = rgbseq{rgbkey(0, rgb(41, 41, 55)), rgbkey(1, rgb(35, 35, 47))}
        }); library:apply_theme(UIGradient, "contrast", "Color")
        
        local text = library:create("TextLabel", {
            Parent = watermark_background,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = " " .. cfg.name .. " ",
            Size = dim2(0, 0, 1, 0),
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, -1),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIStroke = library:create("UIStroke", {
            Parent = text,
            Name = "",
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        cfg.path.MouseEnter:Connect(function()
            watermark_outline.Visible = true 
        end)   

        cfg.path.MouseLeave:Connect(function()
            watermark_outline.Visible = false 
        end)

        library:connection(uis.InputChanged, function(input)
            if watermark_outline.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
                watermark_outline.Position = dim_offset(input.Position.X + 10, input.Position.Y + 10)
            end
        end)
    end 
    
    return cfg
end 

function library:panel(options) 
    local cfg = {
        name = options.text or options.name or "Window", 
        size = options.size or dim2(0, 530, 0, 590),
        position = options.position or dim2(0, 500, 0, 500),
        anchor_point = options.anchor_point or vec2(0, 0)
    }

    local sgui = library:create("ScreenGui", {
        Enabled = true,
        Parent = nil,
        Name = "" 
    })
    parentUI(sgui)

    local main_holder = library:create("Frame", {
        Parent = sgui,
        Name = "",
        AnchorPoint = vec2(cfg.anchor_point.X, cfg.anchor_point.Y),
        Position = cfg.position,
        Active = true, 
        BorderColor3 = rgb(0, 0, 0),
        Size = cfg.size,
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.outline
    })

    library:draggify(main_holder)
    
    --library:apply_theme(main_holder, "outline", "BackgroundColor3") 
    
    local window_inline = library:create("Frame", {
        Parent = main_holder,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.accent
    })
    
    library:apply_theme(window_inline, "accent", "BackgroundColor3") 
    
    local window_holder = library:create("Frame", {
        Parent = window_inline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = themes.preset.outline,
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
                
    local UIGradient = library:create("UIGradient", {
        Parent = window_holder,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
        rgbkey(0, rgb(41, 41, 55)),
        rgbkey(1, rgb(35, 35, 47))
    }
    })

    library:apply_theme(UIGradient, "contrast", "Color") 
    
    local text = library:create("TextLabel", {
        Parent = window_holder,
        Name = "",
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = cfg.name,
        BackgroundTransparency = 1,
        Position = dim2(0, 2, 0, 4),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIStroke = library:create("UIStroke", {
        Parent = text,
        Name = "",
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    local UIPadding = library:create("UIPadding", {
        Parent = window_holder,
        Name = "",
        PaddingBottom = dim(0, 4),
        PaddingRight = dim(0, 4),
        PaddingLeft = dim(0, 4)
    })
    
    local outline = library:create("Frame", {
        Parent = window_holder,
        Name = "",
        Position = dim2(0, 0, 0, 18),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, -18),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    })
    
    library:apply_theme(outline, "inline", "BackgroundColor3") 
    
    local inline = library:create("Frame", {
        Parent = outline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.outline
    })
    
    library:apply_theme(inline, "outline", "BackgroundColor3") 
    
    local holder = library:create("Frame", {
        Parent = inline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIGradient = library:create("UIGradient", {
        Parent = holder,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
    })
    
    library:apply_theme(UIGradient, "contrast", "Color") 
    
    local UIPadding = library:create("UIPadding", {
        Parent = holder,
        Name = "",
        PaddingTop = dim(0, 5),
        PaddingBottom = dim(0, 5),
        PaddingRight = dim(0, 5),
        PaddingLeft = dim(0, 5)
    })
    
    local glow = library:create("ImageLabel", {
        Parent = main_holder,
        Name = "",
        ImageColor3 = themes.preset.glow,
        ScaleType = Enum.ScaleType.Slice,
        BorderColor3 = rgb(0, 0, 0),
        BackgroundColor3 = rgb(255, 255, 255),
        Visible = true,
        Image = "http://www.roblox.com/asset/?id=18245826428",
        BackgroundTransparency = 1,
        ImageTransparency = 0.8, 
        Position = dim2(0, -20, 0, -20),
        Size = dim2(1, 40, 1, 40),
        ZIndex = 2,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(21, 21), vec2(79, 79))
    })library:apply_theme(glow, "glow", "ImageColor3") 
    
    return holder, sgui      
end 

local sgui = library:create("ScreenGui", {
    Enabled = true,
    Parent = nil,
    Name = "",
    DisplayOrder = 2, 
})
parentUI(sgui)

function library:fold_elements(origin, elements)
    for _, x in next, elements do 
        local flag = library.visible_flags[x]

        if flag then    
            flag(flags[origin])
        end     
    end 
end 

function library:window(properties)
    local window = {}
    -- local button_holder  
    
    --[[local function create_dock_button(options) 
        local cfg = {
            image = options.image or "rbxassetid://79856374238119",
            open = options.open or true 
            callback = options.callback or function() end
        }

        local button = library:create("TextButton", {
            Parent = button_holder,
            Name = "",
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Size = dim2(0, 25, 0, 25),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = themes.preset.inline
        })
        
        local button_inline = library:create("Frame", {
            Parent = button,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(button_inline, "outline", "BackgroundColor3") 
        
        local button_inline = library:create("Frame", {
            Parent = button_inline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })library:apply_theme(button_inline, "inline", "BackgroundColor3")
        
        local UIGradient = library:create("UIGradient", {
            Parent = button_inline,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
            rgbkey(0, rgb(35, 35, 47)),
            rgbkey(1, rgb(41, 41, 55))
        }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local ImageLabel = library:create("ImageLabel", {
            Parent = button_inline,
            Name = "",
            ImageColor3 = themes.preset.accent,
            Image = "rbxassetid://79856374238119",
            BackgroundTransparency = 1,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })library:apply_theme(ImageLabel, "accent", "ImageColor3") 
        
        local UIPadding = library:create("UIPadding", {
            Parent = button_inline,
            Name = "",
            PaddingTop = dim(0, 4),
            PaddingBottom = dim(0, 4),
            PaddingRight = dim(0, 4),
            PaddingLeft = dim(0, 4)
        })

        button.MouseButton1Click:Connect(function()
            cfg.open = not cfg.open 

            cfg.callback(cfg.open) 
        end)
    end ]]

    -- main window
        local holder, path = library:panel({
            name = properties and properties.name or "nebula.tech", 
            size = dim2(0, 604, 0, 628),
            position = dim2(0, (camera.ViewportSize.X / 2) - 604/2, 0, (camera.ViewportSize.Y / 2) - 628/2),
        }) 

        -- create_dock_button({
        --     image = "rbxassetid://100959383267514",
        --     callback = function(open)
        --         path.Enabled = open 
        --     end 
        -- })

        window["tab_holder"] = library:create("Frame", {
            Parent = holder,
            Name = " ",
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 22),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 5,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        library:create("UIListLayout", {
            Parent = window["tab_holder"],
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local section_holder = library:create("Frame", {
            Parent = holder,
            Name = " ",
            BackgroundTransparency = 1,
            Position = dim2(0, -1, 0, 19),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, -22),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        window["section_holder"] = section_holder

        local outline = library:create("Frame", {
            Parent = section_holder,
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })
        
        library:apply_theme(outline, "outline", "BackgroundColor3") 

        local inline = library:create("Frame", {
            Parent = outline,
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })
        
        library:apply_theme(inline, "inline", "BackgroundColor3") 

        local background = library:create("Frame", {
            Parent = inline,
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        library.section_holder = background

        library:create("UIPadding", {
            Parent = background,
            PaddingTop = dim(0, 4),
            PaddingBottom = dim(0, 4),
            PaddingRight = dim(0, 4),
            PaddingLeft = dim(0, 4)
        })

        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(41, 41, 55)),
                rgbkey(1, rgb(35, 35, 47))
            }
        })
        
        library:apply_theme(UIGradient, "contrast", "Color") 

        library:make_resizable(path:FindFirstChildOfClass("Frame")) 
    -- 

    -- keybind list       
        local outline = library:create("Frame", {
            Parent = sgui,
            Name = "",
            Visible = false, 
            Active = true,
            Draggable = true, 
            Position = dim2(0, 50, 0, 200),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 182, 0, 25),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })
        library:apply_theme(outline, "outline", "BackgroundColor3") 
        library:draggify(outline)
        library.keybind_list_frame = outline 
        
        local inline = library:create("Frame", {
            Parent = outline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })
        library:apply_theme(inline, "inline", "BackgroundColor3")

        local background = library:create("Frame", {
            Parent = inline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, themes.preset.high_contrast),
                rgbkey(1, themes.preset.low_contrast)
            }
        })
        library:apply_theme(UIGradient, "contrast", "Color") 
        
        local bg = library:create("Frame", {
            Parent = background,
            Name = "a",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        }); library:apply_theme(bg, "accent", "BackgroundColor3")
        
        
        library:create("UIGradient", {
            Parent = bg,
            Name = "",
            Enabled = true, 
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })
        
        local text = library:create("TextLabel", {
            Parent = background,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "Keybinds",
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = 12,
            BackgroundColor3 = themes.preset.text
        }, "text")
        
        local UIStroke = library:create("UIStroke", {
            Parent = text,
            Name = "",
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        local text_holder = library:create("Frame", {
            Parent = background,
            Name = "",
            Size = dim2(0, 182, 0, 22),
            Position = dim2(0, -2, 1, 1),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = themes.preset.outline
        })
        library:apply_theme(text_holder, "outline", "BackgroundColor3")

        local inline = library:create("Frame", {
            Parent = text_holder,
            Name = "",
            Size = dim2(1, -2, 1, -2),
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            --AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = themes.preset.inline
        })
        library:apply_theme(inline, "inline", "BackgroundColor3")
        
        local background = library:create("Frame", {
            Parent = inline,
            Name = "",
            Size = dim2(1, -2, 1, -2),
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            --AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        library.keybind_list = background
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, themes.preset.high_contrast),
                rgbkey(1, themes.preset.low_contrast)
            }
        })
        library:apply_theme(UIGradient, "contrast", "Color") 
        
        library:create("UIListLayout", {
            Parent = background,
            Name = "",
            Padding = dim(0, -1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        library:create("UIPadding", {
            Parent = background,
            Name = "",
            PaddingBottom = dim(0, 4),
            PaddingLeft = dim(0, 5)
        })
        
    
    -- 

    -- -- dock innit
    --     local dock_outline = library:create("Frame", {
    --         Parent = sgui,
    --         Name = "",
    --         Visible = true,
    --         BorderColor3 = rgb(0, 0, 0),
    --         AnchorPoint = vec2(0.5, 0),
    --         Position = dim2(0.5, 0, 0, 20),
    --         Size = dim2(0, 127, 0, 39),
    --         BorderSizePixel = 0,
    --         BackgroundColor3 = themes.preset.outline
    --     })library:apply_theme(dock_outline, "outline", "BackgroundColor3") 
        
    --     local dock_inline = library:create("Frame", {
    --         Parent = dock_outline,
    --         Name = "",
    --         Position = dim2(0, 1, 0, 1),
    --         BorderColor3 = rgb(0, 0, 0),
    --         Size = dim2(1, -2, 1, -2),
    --         BorderSizePixel = 0,
    --         BackgroundColor3 = themes.preset.inline
    --     })library:apply_theme(dock_inline, "inline", "BackgroundColor3") 
        
    --     local dock_holder = library:create("Frame", {
    --         Parent = dock_inline,
    --         Name = "",
    --         Size = dim2(1, -2, 1, -2),
    --         Position = dim2(0, 1, 0, 1),
    --         BorderColor3 = themes.preset.outline,
    --         BorderSizePixel = 0,
    --         BackgroundColor3 = rgb(255, 255, 255)
    --     })library:apply_theme(dock_holder, "outline", "BackgroundColor3") 
        
    --     local accent = library:create("Frame", {
    --         Parent = dock_holder,
    --         Name = "",
    --         Size = dim2(1, 0, 0, 2),
    --         BorderColor3 = rgb(0, 0, 0),
    --         BorderSizePixel = 0,
    --         BackgroundColor3 = themes.preset.accent
    --     })library:apply_theme(accent, "accent", "BackgroundColor3") 
        
    --     local UIGradient = library:create("UIGradient", {
    --         Parent = accent,
    --         Name = "",
    --         Rotation = 90,
    --         Color = rgbseq{
    --         rgbkey(0, rgb(255, 255, 255)),
    --         rgbkey(1, rgb(167, 167, 167))
    --     }
    --     })
        
    --     button_holder = library:create("Frame", {
    --         Parent = dock_holder,
    --         Name = "",
    --         BackgroundTransparency = 1,
    --         Size = dim2(1, 0, 1, 0),
    --         BorderColor3 = rgb(0, 0, 0),
    --         BorderSizePixel = 0,
    --         BackgroundColor3 = rgb(255, 255, 255)
    --     })
        
    --     local UIListLayout = library:create("UIListLayout", {
    --         Parent = button_holder,
    --         Name = "",
    --         Padding = dim(0, 5),
    --         FillDirection = Enum.FillDirection.Horizontal,
    --         SortOrder = Enum.SortOrder.LayoutOrder
    --     })
        
    --     local UIPadding = library:create("UIPadding", {
    --         Parent = button_holder,
    --         Name = "",
    --         PaddingTop = dim(0, 6),
    --         PaddingBottom = dim(0, 4),
    --         PaddingRight = dim(0, 4),
    --         PaddingLeft = dim(0, 4)
    --     })
                
    --     local UIGradient = library:create("UIGradient", {
    --         Parent = dock_holder,
    --         Name = "",
    --         Rotation = 90,
    --         Color = rgbseq{
    --         rgbkey(0, rgb(41, 41, 55)),
    --         rgbkey(1, rgb(35, 35, 47))
    --     }
    --     })library:apply_theme(UIGradient, "contrast", "Color") 
    -- -- 

    -- -- cfg holder
        
    --     window["configs"], config_path = library:panel({
    --         name = "Configurations", 
    --         anchor_point = vec2(-1, 0),
    --         size = dim2(0, 322, 0, 391),
    --         position = dim2(0, holder.AbsolutePosition.X + holder.AbsoluteSize.X + 10, 0, holder.AbsolutePosition.Y - 22)
    --     }) 

    --     create_dock_button({
    --         image = "rbxassetid://79856374238119",
    --         callback = function(open)
    --             config_path.Enabled = open 
    --         end 
    --     })

    --     local UIGradient = library:create("UIGradient", {
    --         Parent = holder,
    --         Name = "",
    --         Rotation = 90,
    --         Color = rgbseq{
    --             rgbkey(0, rgb(41, 41, 55)),
    --             rgbkey(1, rgb(35, 35, 47))
    --         }
    --     })library:apply_theme(UIGradient, "contrast", "Color") 
        
    --     local UIPadding = library:create("UIPadding", {
    --         Parent = holder,
    --         Name = "",
    --         PaddingTop = dim(0, 5),
    --         PaddingBottom = dim(0, 5),
    --         PaddingRight = dim(0, 5),
    --         PaddingLeft = dim(0, 5)
    --     })
        
    --     local glow = library:create("ImageLabel", {
    --         Parent = config_outline,
    --         Name = "",
    --         ImageColor3 = themes.preset.accent,
    --         ScaleType = Enum.ScaleType.Slice,
    --         BorderColor3 = rgb(0, 0, 0),
    --         BackgroundColor3 = rgb(255, 255, 255),
    --         Visible = true,
    --         Image = "http://www.roblox.com/asset/?id=18245826428",
    --         BackgroundTransparency = 1,
    --         ImageTransparency = 0.8, 
    --         Position = dim2(0, -20, 0, -20),
    --         Size = dim2(1, 40, 1, 40),
    --         ZIndex = 2,
    --         BorderSizePixel = 0,
    --         SliceCenter = rect(vec2(21, 21), vec2(79, 79))
    --     })library:apply_theme(glow, "glow", "ImageColor3") 
        
    -- -- 

    -- -- playerlist 
    --     window["playerlist"], playerlist_gui = library:panel({
    --         name = "Playerlist", 
    --         anchor_point = vec2(-1, 0),
    --         size = dim2(0, 385, 0, 399),
    --         position = dim2(0, holder.AbsolutePosition.X - 395, 0, holder.AbsolutePosition.Y - 22)
    --     })    
        
    --     create_dock_button({
    --         image = "rbxassetid://115194686863276",
    --         callback = function(open)
    --             playerlist_gui.Enabled = open 
    --         end 
    --     })
    -- -- 
    
    -- -- theming 
    --     window["themes"], themes_gui = library:panel({
    --         name = "Style", 
    --         anchor_point = vec2(-1, 0),
    --         size = dim2(0, 322, 0, 391),
    --         position = dim2(0, window["configs"].AbsolutePosition.X + window["configs"].AbsoluteSize.X + 10, 0, window["configs"].AbsolutePosition.Y - 22)
    --     })   

    --     create_dock_button({
    --         image = "rbxassetid://115194686863276",
    --         callback = function(open)
    --             themes_gui.Enabled = open 
    --         end 
    --     })
    -- -- 
    
    function window.set_menu_visibility(bool) 
        path.Enabled = bool 
        tooltip_sgui.Enabled = bool

        if library.current_element_open then 
            library.current_element_open.set_visible(false)
            library.current_element_open.open = false 
            library.current_element_open = nil 
        end

        for _, v in tooltip_sgui:GetChildren() do 
            v.Visible = false
        end 
    end 

    return setmetatable(window, library)
end

function library:watermark(options) 
    local cfg = {
        default = options.text or options.default or os.date('drain.lol | %b %d %Y | %H:%M')
    }

    local watermark_outline = library:create("Frame", {
        Parent = sgui,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        AnchorPoint = vec2(1, 1),
        Position = dim2(1, -20, 0, 20),
        Size = dim2(0, 0, 0, 24),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = themes.preset.outline
    })library:apply_theme(watermark_outline, "outline", "BackgroundColor3") 
    watermark_outline.Position = dim_offset(watermark_outline.AbsolutePosition.X, watermark_outline.AbsolutePosition.Y)
    library:draggify(watermark_outline)

    local watermark_inline = library:create("Frame", {
        Parent = watermark_outline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    })library:apply_theme(watermark_inline, "inline", "BackgroundColor3") 
    
    local watermark_background = library:create("Frame", {
        Parent = watermark_inline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIGradient = library:create("UIGradient", {
        Parent = watermark_background,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
    })library:apply_theme(UIGradient, "contrast", "Color") 
    
    local text = library:create("TextLabel", {
        Parent = watermark_background,
        Name = "",
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = "  drain.lol | Beta | Aug 29 2024 | 07:29:00  ",
        Size = dim2(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Position = dim2(0, -1, 0, 1),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    library:create("UIStroke", {
        Parent = text,
        Name = "",
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    local accent = library:create("Frame", {
        Parent = watermark_outline,
        Name = "",
        Position = dim2(0, 2, 0, 2),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -4, 0, 2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.accent
    })library:apply_theme(accent, "accent", "BackgroundColor3") 
    
    local UIGradient = library:create("UIGradient", {
        Parent = accent,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
            rgbkey(0, rgb(255, 255, 255)),
            rgbkey(1, rgb(167, 167, 167))
        }
    })
    
    function cfg.change_text(input)
        text.Text = "  ".. input .."  "
    end 

    function cfg.set_visible(bool) 
        watermark_outline.Visible = bool
    end 


    cfg.change_text(cfg.default)

    return cfg 

end 

local notif_holder = library:create("ScreenGui", {
    Parent = nil,
    Name = "",
    IgnoreGuiInset = true, 
    DisplayOrder = -1, 
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
parentUI(notif_holder)

function library:refresh_notifications()  	
    for _, notif in next, library.notifications do 
        tween_service:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Position = dim2(0, 20, 0, 72 + (_ * 28))}):Play()
    end     
end

function library:notification(properties)
    local cfg = {
        time = properties.time or 5,
        text = properties.text or properties.name or "Notification",
        flashing = false, 
    }

    -- Instances
        local watermark_outline = library:create("Frame", {
            Parent = notif_holder,
            Name = "",
            Size = UDim2.new(0, 0, 0, 24),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 20, 0, 72 + (#library.notifications * 28)),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = themes.preset.outline,
            AnchorPoint = Vector2.new(1, 0)
        })
    
        local watermark_inline = library:create("Frame", {
            Parent = watermark_outline,
            Name = "",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })

        local watermark_background = library:create("Frame", {
            Parent = watermark_inline,
            Name = "",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local UIGradient = library:create("UIGradient", {
            Parent = watermark_background,
            Name = "",
            Color = ColorSequence.new{
                rgbkey(0, themes.preset.high_contrast),
                rgbkey(1, themes.preset.low_contrast)
            }
        })

        local text = library:create("TextLabel", {
            Parent = watermark_background,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "  " .. cfg.text .. "  ",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, -1),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local accent = library:create("Frame", {
            Parent = watermark_outline,
            Name = "",
            Position = UDim2.new(0, 2, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = UDim2.new(0, 1, 1, -4),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })

        library:apply_theme(accent, "accent", "BackgroundColor3")

        local UIGradient = library:create("UIGradient", {
            Parent = accent,
            Name = "",
            Rotation = 90,
            Color = ColorSequence.new{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })
        
        local accent_bottom = library:create("Frame", {
            Parent = watermark_outline,
            Name = "",
            Position = UDim2.new(0, 2, 1, -3),
            BorderColor3 = rgb(0, 0, 0),
            Size = UDim2.new(0, -4, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = accent,
            Name = "",
            Rotation = 90,
            Color = ColorSequence.new{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })

        local index = #library.notifications + 1
        library.notifications[index] =watermark_outline

        library:refresh_notifications()

        tween_service:Create(watermark_outline, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {AnchorPoint = Vector2.new(0, 0)}):Play()
        
        tween_service:Create(accent_bottom, TweenInfo.new(cfg.time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, -4, 0, 1)}):Play()
    --
    
    task.spawn(function()
        task.wait(cfg.time)

        library.notifications[index] = nil

        tween_service:Create(watermark_outline, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1}):Play()
        
        for _, v in next, watermark_outline:GetDescendants() do 
            if v:IsA("TextLabel") then 
                tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
            elseif v:IsA("Frame") then 
                tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
            elseif v:IsA("ImageLabel") then
                tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
            elseif v:IsA("UIStroke") then 
                tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
            end 
        end 

        task.wait(1)

        watermark_outline:Destroy()
    end)    
end 

function library:tab(options)	
    local cfg = {
        name = options.name or "tab", 
        enabled = false, 
    }
    
    -- button instances
        local tab_holder = library:create("TextButton", {
            Parent = self.tab_holder,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Name = "\0",
            BorderSizePixel = 0,
            Size = dim2(0, 0, 1, -2),
            ZIndex = 5,
            TextSize = 12,
            BackgroundColor3 = themes.preset.outline,
            AutoButtonColor = false
        })library:apply_theme(tab_holder, "outline", "BackgroundColor3") 

        local inline = library:create("Frame", {
            Parent = tab_holder,
            Size = dim2(1, -2, 1, 0),
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 5,
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 

        local background = library:create("Frame", {
            Parent = inline,
            Size = dim2(1, -2, 1, -1),
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 5,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Rotation = 90,
            Color = rgbseq{rgbkey(0, rgb(41, 41, 55)), rgbkey(1, rgb(35, 35, 47))}
        })library:apply_theme(UIGradient, "contrast", "Color") 

        local text = library:create("TextLabel", {
            Parent = background,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = cfg.name,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 12,
            ZIndex = 5,
            BackgroundColor3 = rgb(255, 255, 255)
        }, "text")
        library:apply_theme(text, "accent", "TextColor3")
    -- 

    -- section instances 
        local section_holder = library:create("Frame", {
            Parent = library.section_holder,
            BackgroundTransparency = 1,
            Name = "\0",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            Visible = false,
            BackgroundColor3 = rgb(255, 255, 255)
        })
    
        cfg["holder"] = section_holder

        library:create("UIListLayout", {
            Parent = section_holder,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    -- 

    function cfg.open_tab()
        if library.current_tab and library.current_tab[1] ~= background then 
            local button = library.current_tab[1]
            button.Size = dim2(1, -2, 1, -1)
            button:FindFirstChildOfClass("UIGradient").Rotation = 90
            button:FindFirstChildOfClass("TextLabel").TextColor3 = themes.preset.text
                
            library.current_tab[2].Visible = false
            
            library.current_tab = nil
        end
        
        library.current_tab = {
            background, section_holder
        }
        
        local button = library.current_tab[1] 
        button.Size = dim2(1, -2, 1, 0) -- ENABLED
        button:FindFirstChildOfClass("UIGradient").Rotation = -90
        button:FindFirstChildOfClass("TextLabel").TextColor3 = themes.preset.accent 

        library.current_tab[2].Visible = true 

        if library.current_element_open and library.current_element_open ~= cfg then 
            library.current_element_open.set_visible(false)
            library.current_element_open.open = false 
            library.current_element_open = nil 
        end
    end
    
    tab_holder.MouseButton1Click:Connect(cfg.open_tab)
    
    return setmetatable(cfg, library) 
end

function library:column(path) 
    local cfg = {}
    
    local holder = path and self[path] or self.holder
    
    local column = library:create("Frame", {
        Parent = holder,
        BackgroundTransparency = 1,
        Name = "\0",
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    })library:apply_theme(column, "inline", "BackgroundColor3") 
    
    library:create("UIListLayout", {
        Parent = column,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalFlex = Enum.UIFlexAlignment.Fill
    })
    
    cfg["holder"] = column

    return setmetatable(cfg, library) 
end

function library:multi_section(options)
    local cfg = {
        names = options.names or {"First", "Second", "Third"}, 
        sections = {},
    }

    local section = library:create("Frame", {
        Parent = self.holder,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    }) library:apply_theme(section, "inline", "BackgroundColor3")
    
    local inline = library:create("Frame", {
        Parent = section,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.outline
    }) library:apply_theme(inline, "outline", "BackgroundColor3") 
    
    local __background = library:create("Frame", {
        Parent = inline,
        Name = "",
        ClipsDescendants = true,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 1,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local accent = library:create("Frame", {
        Parent = __background,
        Name = "",
        Size = dim2(1, 0, 0, 2),
        BorderColor3 = rgb(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.accent
    }) library:apply_theme(accent, "accent", "BackgroundColor3")
    
    local UIGradient = library:create("UIGradient", {
        Parent = accent,
        Name = "",
        Rotation = 90,
        Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(167, 167, 167))}
    }) 
    
    local UIGradient = library:create("UIGradient", {
        Parent = __background,
        Name = "",
        Rotation = 90,
        Color = rgbseq{rgbkey(0, rgb(41, 41, 55)), rgbkey(1, rgb(35, 35, 47))}
    }) library:apply_theme(UIGradient, "contrast", "Color") 
    
    local tab_holder = library:create("Frame", {
        Parent = __background,
        Name = "",
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Position = dim2(0, -1, 0, 0),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 2, 0, 21),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    }) 
    
    library:create("UIListLayout", {
        Parent = tab_holder,
        Name = "",
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = dim(0, -3),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    for _, tab in next, cfg.names do 
        local multi = {
            open = false, 
        } 

        -- Tab
            local tabb = library:create("TextButton", {
                Parent = tab_holder,
                Name = "",
                AutoButtonColor = false,
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Text = "",
                BorderSizePixel = 0,
                Size = dim2(0, 0, 1, 0),
                ZIndex = 1,
                TextSize = 12,
                BackgroundColor3 = themes.preset.outline
            }) library:apply_theme(tabb, "outline", "BackgroundColor3") 
            
            local background = library:create("Frame", {
                Parent = tabb,
                Name = "",
                Size = dim2(1, 0, 1, -2),
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                ZIndex = 1,
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            
            local UIGradient = library:create("UIGradient", {
                Parent = background,
                Name = "",
                Rotation = 90,
                Color = rgbseq{rgbkey(0, rgb(41, 41, 55)), rgbkey(1, rgb(35, 35, 47))}
            }) library:apply_theme(UIGradient, "contrast", "Color")
            
            local text = library:create("TextLabel", {
                Parent = background,
                Name = "",
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Text = tab,
                BackgroundTransparency = 1,
                Size = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                BackgroundColor3 = rgb(255, 255, 255)
            }) 
            
            local UIStroke = library:create("UIStroke", {
                Parent = text,
                Name = "",
                LineJoinMode = Enum.LineJoinMode.Miter
            })
        -- 

        -- Element Handler
            local ScrollingFrame = library:create("ScrollingFrame", {
                Parent = __background,
                Name = "",
                ScrollBarImageColor3 = themes.preset.accent,
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                Size = dim2(1, 0, 1, -20),
                Visible = false, 
                BackgroundTransparency = 1,
                Position = dim2(0, 0, 0, 24),
                BackgroundColor3 = rgb(255, 255, 255),
                BorderColor3 = rgb(0, 0, 0),
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                CanvasSize = dim2(0, 0, 0, 0)
            }) library:apply_theme(ScrollingFrame, "accent", "ScrollBarImageColor3") 
            
            local elements = library:create("Frame", {
                Parent = ScrollingFrame,
                Name = "",
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 0, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            }) multi.holder = elements
            
            local UIListLayout = library:create("UIListLayout", {
                Parent = elements,
                Name = "",
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = dim(0, 4)
            })
            
            local UIPadding = library:create("UIPadding", {
                Parent = ScrollingFrame,
                Name = "",
                PaddingBottom = dim(0, 60)
            })
        --
        
        function multi:open_tab(bool) 
            ScrollingFrame.Visible = bool 
            UIGradient.Rotation = bool and -90 or 90
            tabb.Size = dim2(0, 0, 1, bool and 1 or 0)
        end

        library:connection(tabb.MouseButton1Click, function()
            for _, multi_s in next, cfg.sections do 
                multi_s:open_tab(false)
            end

            if library.current_element_open then 
                library.current_element_open.set_visible(false)
                library.current_element_open.open = false 
                library.current_element_open = nil 
            end

            multi:open_tab(true) 
        end)

        cfg.sections[#cfg.sections + 1] = setmetatable(multi, library)
    end 

    cfg.sections[1]:open_tab(true)

    return unpack(cfg.sections)
end 

function library:section(options)
    local cfg = {
        name = options.name or "Section", 
    }
    
    local section = library:create("Frame", {
        Parent = self.holder,
        Name = "\0",
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    })library:apply_theme(section, "inline", "BackgroundColor3") 

    local inline = library:create("Frame", {
        Parent = section,
        Name = "\0",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.outline
    })library:apply_theme(inline, "outline", "BackgroundColor3") 

    local background = library:create("Frame", {
        Parent = inline,
        Name = "\0",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })

    local text = library:create("TextLabel", {
        Parent = background,
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = cfg.name,
        Name = "\0",
        BackgroundTransparency = 1,
        Position = dim2(0, 6, 0, 4),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })

    library:create("UIStroke", {
        Parent = text,
        LineJoinMode = Enum.LineJoinMode.Miter
    })

    local accent = library:create("Frame", {
        Parent = background,
        Name = "\0",
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 0, 2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.accent
    })library:apply_theme(accent, "accent", "BackgroundColor3") 

    local UIGradient = library:create("UIGradient", {
        Parent = accent,
        Rotation = 90,
        Color = rgbseq{
            rgbkey(0, rgb(255, 255, 255)),
            rgbkey(1, rgb(167, 167, 167))
        }
    })

    local UIGradient = library:create("UIGradient", {
        Parent = background,
        Rotation = 90,
        Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
    })library:apply_theme(UIGradient, "contrast", "Color") 

    local ScrollingFrame = library:create("ScrollingFrame", {
        Parent = background,
        ScrollBarImageColor3 = themes.preset.accent,
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        Size = dim2(1, 0, 1, -20),
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 20),
        BackgroundColor3 = rgb(255, 255, 255),
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        CanvasSize = dim2(0, 0, 0, 0)
    })library:apply_theme(ScrollingFrame, "accent", "ScrollBarImageColor3") 

    ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if library.current_element_open then 
            library.current_element_open.set_visible(false)
            library.current_element_open.open = false 
            library.current_element_open = nil
        end
    end) 

    local elements = library:create("Frame", {
        Parent = ScrollingFrame,
        Name = "\0",
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    cfg.holder = elements 

    library:create("UIListLayout", {
        Parent = elements,
        Padding = dim(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    library:create("UIPadding", {
        Parent = ScrollingFrame,
        PaddingBottom = dim(0, 10)
    })

    return setmetatable(cfg, library)
end

function library:slider(options)
    local cfg = {
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = options.flag or tostring(2^789),
        callback = options.callback or function() end, 
        visible = options.visible or true, 

        min = options.min or options.minimum or 0,
        max = options.max or options.maximum or 100,
        intervals = options.interval or options.decimal or 1,
        default = options.default or 10,

        dragging = false,
        value = options.default or 10, 
    } 

    -- instances 
        local slider_REAL = library:create("TextLabel", {
            Parent = self.holder, 
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Name = "slider",
            ZIndex = 2,
            Size = dim2(1, -8, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local TEXT_LABEL; 
        if cfg.name then 
            local left_components = library:create("Frame", {
                Parent = slider_REAL,
                Name = "left_components",
                BackgroundTransparency = 1,
                Position = dim2(0, 2, 0, -1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 0, 0, 14),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            
            TEXT_LABEL = library:create("TextLabel", {
                Parent = left_components,
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Text = cfg.name,
                Name = "text",
                BackgroundTransparency = 1,
                Size = dim2(0, 0, 1, -1),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                BackgroundColor3 = rgb(255, 255, 255)
            }, "text")

            library:create("UIListLayout", {
                Parent = left_components,
                Padding = dim(0, 5),
                Name = "_",
                FillDirection = Enum.FillDirection.Horizontal
            })
        end 
        
        local bottom_components = library:create("Frame", {
            Parent = slider_REAL,
            Name = "bottom_components",
            Position = dim2(0, 0, 0, cfg.name and 15 or 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 26, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local slider = library:create("TextButton", {
            Parent = bottom_components,
            Name = "slider",
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -27, 1, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline,
            Text = "",
            AutoButtonColor = false,
        })library:apply_theme(slider, "outline", "BackgroundColor3") 
        
        local inline = library:create("Frame", {
            Parent = slider,
            Name = "inline",
            Position = dim2(0, 0, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -1, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
        
        local background = library:create("Frame", {
            Parent = inline,
            Name = "background",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })library:apply_theme(background, "accent", "BackgroundColor3") 
        
        local contrast = library:create("Frame", {
            Parent = background,
            Name = "contrast",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local slidertext = library:create("TextLabel", {
            Parent = contrast,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "12.50/100.00",
            Name = "text",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, -1),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = 12,
            ZIndex = 2,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local fill = library:create("Frame", {
            Parent = contrast,
            Name = "fill",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0.75, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })library:apply_theme(fill, "accent", "BackgroundColor3") 
        
        local UIGradient = library:create("UIGradient", {
            Parent = fill,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = contrast,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(41, 41, 55)),
                rgbkey(1, rgb(35, 35, 47))
            }
        }); library:apply_theme(UIGradient, "contrast", "Color")
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })
        
        library:create("UIListLayout", {
            Parent = bottom_components,
            Padding = dim(0, 10),
            Name = "_",
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        library:create("UIPadding", {
            Parent = slider,
            PaddingLeft = dim(0, 1)
        })
    --  

    function cfg.set(value)
        cfg.value = math.clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)

        fill.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        slidertext.Text = tostring(cfg.value) .. cfg.suffix .. "/" .. tostring(cfg.max) .. cfg.suffix
        flags[cfg.flag] = cfg.value

        cfg.callback(flags[cfg.flag])
    end

    function cfg.set_element_visible(bool)
        slider_REAL.Visible = bool 

        if TEXT_LABEL then 
            TEXT_LABEL.Visible = bool 
        end 
    end

    library:connection(uis.InputChanged, function(input)
        if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
            local size_x = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            local value = ((cfg.max - cfg.min) * size_x) + cfg.min
            cfg.set(value)
        end
    end)

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cfg.dragging = false 
        end 
    end)

    slider.MouseButton1Down:Connect(function()
        cfg.dragging = true
    end)

    if cfg.tooltip then 
        library:tool_tip({name = cfg.tooltip, path = slider_REAL})
    end

    cfg.set(cfg.default)
    cfg.set_element_visible(cfg.visible)
            
    config_flags[cfg.flag] = cfg.set

    library.config_flags[cfg.flag] = cfg.set
    library.visible_flags[cfg.flag] = cfg.set_element_visible

    return setmetatable(cfg, library) 
end 

function library:toggle(options)
    local cfg = {
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        flag = options.flag or tostring(random(1,9999999)),
        callback = options.callback or function() end,
        default = options.default or false,
        colorpicker = options.color or nil,
        visible = options.visible or true,
        tooltip = options.tooltip or nil,
    }
    
    -- instances
        local toggle_holder = library:create("TextButton", {
            Parent = self.holder,
            FontFace = library.font,
            TextColor3 = rgb(151, 151, 151),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Name = "toggle",
            ZIndex = 1,
            Size = dim2(1, -8, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
    
        local right_components = library:create("Frame", {
            Parent = toggle_holder,
            Name = "right_components",
            Position = dim2(1, -1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 0, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        cfg["right_holder"] = right_components
    
        local list = library:create("UIListLayout", {
            Parent = right_components,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = dim(0, 4),
            Name = "list",
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    
        library:create("UIPadding", {
            Parent = toggle_holder
        })
    
        local left_components = library:create("Frame", {
            Parent = toggle_holder,
            Name = "left_components",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 0, 0, 14),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local text = library:create("TextLabel", {
            Parent = left_components,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = cfg.name,
            Name = "text",
            BackgroundTransparency = 1,
            Size = dim2(0, 0, 1, -1),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
    
        library:create("UIStroke", {
            Parent = text,
            LineJoinMode = Enum.LineJoinMode.Miter
        })
    
        library:create("UIListLayout", {
            Parent = left_components,
            Padding = dim(0, 5),
            Name = "_",
            FillDirection = Enum.FillDirection.Horizontal
        })
    
        local toggle = library:create("TextButton", {
            Parent = left_components,
            Name = "!toggle",
            Text = "",
            AutoButtonColor = false,
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 14, 0, 14),
            BorderSizePixel = 0,
            ZIndex = 1, 
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(toggle, "outline", "BackgroundColor3") 
    
        local inline = library:create("Frame", {
            Parent = toggle,
            Name = "inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
    
        local background = library:create("Frame", {
            Parent = inline,
            Name = "background",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })
        library:apply_theme(background, "accent", "BackgroundColor3") 
        library:apply_theme(background, "accent", "BackgroundColor3") 
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })
    -- 
        
    function cfg.set(bool)
        background.BackgroundColor3 = bool and themes.preset.accent or themes.preset.inline

        flags[cfg.flag] = bool
        
        cfg.callback(bool)
    end

    function cfg.set_element_visible(bool)
        toggle_holder.Visible = bool 
    end 

    library:connection(toggle_holder.MouseButton1Click, function()
        cfg.enabled = not cfg.enabled

        cfg.set(cfg.enabled)
    end)

    library:connection(toggle.MouseButton1Click, function()
        cfg.enabled = not cfg.enabled

        cfg.set(cfg.enabled)
    end)

    if cfg.tooltip then 
        library:tool_tip({name = cfg.tooltip, path = toggle_holder})
    end

    cfg.set(cfg.default)
    
    cfg.set_element_visible(cfg.visible)
    
    library.config_flags[cfg.flag] = cfg.set
    library.visible_flags[cfg.flag] = cfg.set_element_visible

    return setmetatable(cfg, library)
end

function library:colorpicker(options)
    local parent = self.right_holder
    
    local cfg = {
        name = options.name or "Color", 
        flag = options.flag or tostring(2^789),
        color = options.color or color(1, 1, 1), -- Default to white color if not provided
        alpha = options.alpha or 1,
        callback = options.callback or function() end,
        right_holder = self.right_holder,
    }

    local dragging_sat = false 
    local dragging_hue = false 
    local dragging_alpha = false 

    local h, s, v = cfg.color:ToHSV() 
    local a = cfg.alpha 
    
    -- colorpicker button 
        local colorpicker_button = library:create("TextButton", {
            Parent = parent,
            Name = "outline",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 24, 0, 14),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline,
            Text = "",
            AutoButtonColor = false,
        })library:apply_theme(colorpicker_button, "outline", "BackgroundColor3") 
    
        local inline = library:create("Frame", {
            Parent = colorpicker_button,
            Name = "inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
    
        local handler = library:create("Frame", {
            Parent = inline,
            Name = "handler",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(250, 165, 27)
        })
    
        local UIGradient = library:create("UIGradient", {
            Parent = handler,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })
    -- 

    -- colorpicker instances
        local colorpicker_holder = library:create("Frame", {
            Parent = sgui,
            Name = "colorpicker",
            Position = dim2(0, colorpicker_button.AbsolutePosition.X + 1, 0, colorpicker_button.AbsolutePosition.Y + 17),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 190, 0, 190),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline,
            Visible = false,
            ZIndex = 1
        })library:apply_theme(colorpicker_holder, "outline", "BackgroundColor3") 

        library:make_resizable(colorpicker_holder)
        
        local window_inline = library:create("Frame", {
            Parent = colorpicker_holder,
            Name = "window_inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })library:apply_theme(window_inline, "accent", "BackgroundColor3") 
        
        local window_holder = library:create("Frame", {
            Parent = window_inline,
            Name = "window_holder",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = themes.preset.outline,
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = window_holder,
            Rotation = 90,
            Name = "_",
            Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local text = library:create("TextLabel", {
            Parent = window_holder,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = cfg.name,
            Name = "text",
            BackgroundTransparency = 1,
            Position = dim2(0, 2, 0, 4),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = text,
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        library:create("UIPadding", {
            Parent = window_holder,
            Name = "_",
            PaddingBottom = dim(0, 4),
            PaddingRight = dim(0, 4),
            PaddingLeft = dim(0, 4)
        })
        
        local main_holder = library:create("Frame", {
            Parent = window_holder,
            Name = "main_holder",
            Position = dim2(0, 0, 0, 20),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, -20),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(main_holder, "inline", "BackgroundColor3") 
        
        local main_holder_inline = library:create("Frame", {
            Parent = main_holder,
            Name = "main_holder_inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(main_holder_inline, "outline", "BackgroundColor3") 
        
        local main_holder_background = library:create("Frame", {
            Parent = main_holder_inline,
            Name = "main_holder_background",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = main_holder_background,
            Rotation = 90,
            Name = "_",
            Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        library:create("UIPadding", {
            Parent = main_holder_background,
            PaddingTop = dim(0, 4),
            Name = "_",
            PaddingBottom = dim(0, 4),
            PaddingRight = dim(0, 4),
            PaddingLeft = dim(0, 4)
        })
        
        local alpha = library:create("TextButton", {
            Parent = main_holder_background,
            AnchorPoint = vec2(0, 0.5),
            Name = "alpha",
            Position = dim2(0, 0, 1, -8),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -20, 0, 14),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline,
            Text = "",
            AutoButtonColor = false,
        })library:apply_theme(alpha, "inline", "BackgroundColor3") 
        
        local outline = library:create("Frame", {
            Parent = alpha,
            Name = "outline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(outline, "outline", "BackgroundColor3") 
        
        local alpha_drag = library:create("Frame", {
            Parent = outline,
            Name = "alpha_drag",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(0, 221, 255)
        })
        
        local alphaind = library:create("ImageLabel", {
            Parent = alpha_drag,
            ScaleType = Enum.ScaleType.Tile,
            BorderColor3 = rgb(0, 0, 0),
            Image = "rbxassetid://18274452449",
            BackgroundTransparency = 1,
            Name = "alphaind",
            Size = dim2(1, 0, 1, 0),
            TileSize = dim2(0, 6, 0, 6),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = alphaind,
            Transparency = numseq{
                numkey(0, 0),
                numkey(1, 1)
            }
        })
        
        local alpha_picker = library:create("Frame", {
            Parent = alpha_drag,
            Name = "alpha_picker",
            BorderMode = Enum.BorderMode.Inset,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 4, 1, 0),
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local hue = library:create("TextButton", {
            Parent = main_holder_background,
            AnchorPoint = vec2(1, 0),
            Name = "hue",
            Position = dim2(1, -1, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 14, 1, -20),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline,
            Text = "",
            AutoButtonColor = false
        })
        
        local outline = library:create("Frame", {
            Parent = hue,
            Name = "outline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })
        
        local Frame = library:create("Frame", {
            Parent = outline,
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = Frame,
            Rotation = 270,
            Color = rgbseq{
            rgbkey(0, rgb(255, 0, 0)),
            rgbkey(0.17000000178813934, rgb(255, 255, 0)),
            rgbkey(0.33000001311302185, rgb(0, 255, 0)),
            rgbkey(0.5, rgb(0, 255, 255)),
            rgbkey(0.6700000166893005, rgb(0, 0, 255)),
            rgbkey(0.8299999833106995, rgb(255, 0, 255)),
            rgbkey(1, rgb(255, 0, 0))
        }
        }) 
        
        local hue_picker = library:create("Frame", {
            Parent = Frame,
            Name = "hue_picker",
            BorderMode = Enum.BorderMode.Inset,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 4),
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local visualize = library:create("Frame", {
            Parent = main_holder_background,
            AnchorPoint = vec2(1, 1),
            Name = "visualize",
            Position = dim2(1, -1, 1, -1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 14, 0, 14),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(visualize, "inline", "BackgroundColor3") 
        
        local outline = library:create("Frame", {
            Parent = visualize,
            Size = dim2(1, -2, 1, -2),
            Name = "outline",
            Active = true,
            BorderColor3 = rgb(0, 0, 0),
            Position = dim2(0, 1, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(outline, "outline", "BackgroundColor3") 
        
        local visualize = library:create("Frame", {
            Parent = outline,
            Size = dim2(1, -2, 1, -2),
            Name = "visualize",
            Active = true,
            BorderColor3 = rgb(0, 0, 0),
            Position = dim2(0, 1, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(0, 221, 255)
        })
        
        local satval_picker = library:create("Frame", {
            Parent = main_holder_background,
            Name = "satval_picker",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -20, 1, -20),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(satval_picker, "inline", "BackgroundColor3") 
        
        local outline = library:create("Frame", {
            Parent = satval_picker,
            Name = "outline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(outline, "outline", "BackgroundColor3") 
        
        local colorpicker = library:create("Frame", {
            Parent = outline,
            Name = "colorpicker",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(0, 221, 255)
        })
        
        local sat = library:create("TextButton", {
            Parent = colorpicker,
            Name = "sat",
            Size = dim2(1, 0, 1, 0),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255),
            Text = "",
            AutoButtonColor = false,
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = sat,
            Rotation = 270,
            Transparency = numseq{
                numkey(0, 0),
                numkey(1, 1)
            },
            Color = rgbseq{
                rgbkey(0, rgb(0, 0, 0)),
                rgbkey(1, rgb(0, 0, 0))
            }
        })
        
        local val = library:create("TextButton", {
            Parent = colorpicker,
            Name = "val",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255),
            Text = "",
            AutoButtonColor = false,
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = val,
            Transparency = numseq{
                numkey(0, 0),
                numkey(1, 1)
            }
        })
        
        local satval_picker_REAL = library:create("Frame", {
            Parent = colorpicker,
            Name = "satval_picker_REAL",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 2, 0, 2),
            BorderSizePixel = 1,
            BackgroundColor3 = rgb(255, 255, 255),
            ZIndex = 3, 
        })
    -- 
        
    function cfg.set_visible(bool)
        colorpicker_holder.Visible = bool

        if bool then 
            if library.current_element_open and library.current_element_open ~= cfg then 
                library.current_element_open.set_visible(false)
                library.current_element_open.open = false 
            end

            library.current_element_open = cfg
            colorpicker_holder.Position = dim2(0, colorpicker_button.AbsolutePosition.X + 1, 0, colorpicker_button.AbsolutePosition.Y + 17)
        end
    end 

    colorpicker_button.MouseButton1Click:Connect(function()		
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open) 
    end)

    function cfg.set(color, alpha)
        if color then 
            h, s, v = color:ToHSV()
        end 
    
        if alpha then 
            a = alpha
        end 
    
        local hsv_position = Color3.fromHSV(h, s, v)
        local Color = Color3.fromHSV(h, s, v)
        
        local value = 1 - h
        local offset = (value < 1) and 0 or -4
        hue_picker.Position = dim2(0, 0, value, offset)

        local offset = (a < 1) and 0 or -4
        alpha_picker.Position = dim2(a, offset, 0, 0)

        alpha_drag.BackgroundColor3 = Color3.fromHSV(h, s, v)
        
        visualize.BackgroundColor3 = Color
        handler.BackgroundColor3 = Color 

        colorpicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        
        cfg.color = Color
        cfg.alpha = a
        
        local s_offset = (s < 1) and 0 or -3
        local v_offset = (1 - v < 1) and 0 or -3
        satval_picker_REAL.Position = dim2(s, s_offset, 1 - v, v_offset)

        flags[cfg.flag] = {} 
        flags[cfg.flag]["Color"] = Color
        flags[cfg.flag]["Transparency"] = a
    
        cfg.callback(Color, a)
    end

    function cfg.update_color() 
        local mouse = uis:GetMouseLocation() 

        if dragging_sat then	
            s = math.clamp((vec2(mouse.X, mouse.Y - gui_offset) - val.AbsolutePosition).X / val.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((vec2(mouse.X, mouse.Y - gui_offset) - sat.AbsolutePosition).Y / sat.AbsoluteSize.Y, 0, 1)
        elseif dragging_hue then 
            h = math.clamp(1 - (vec2(mouse.X, mouse.Y - gui_offset) - hue.AbsolutePosition).Y / hue.AbsoluteSize.Y, 0, 1)
        elseif dragging_alpha then 
            a = math.clamp((vec2(mouse.X, mouse.Y - gui_offset) - alpha.AbsolutePosition).X / alpha.AbsoluteSize.X, 0, 1)
        end

        cfg.set(nil, nil)
    end
    
    alpha.MouseButton1Down:Connect(function()
        dragging_alpha = true 
    end)

    hue.MouseButton1Down:Connect(function()
        dragging_hue = true 
    end)

    sat.MouseButton1Down:Connect(function()
        dragging_sat = true  
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging_sat = false
            dragging_hue = false
            dragging_alpha = false 
        end
    end)

    uis.InputChanged:Connect(function(input)
        if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
            cfg.update_color() 
        end
    end)	

    cfg.set(cfg.color, cfg.alpha)

    library.config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library) 
end

function library:keybind(options)
    local parent = self.right_holder

    local cfg = {
        flag = options.flag or "SET ME A FLAG NOWWW!!!!",
        callback = options.callback or function() end,
        open = false,
        binding = nil, 
        name = options.name or nil, 
        ignore_key = options.ignore or false, 

        key = options.key or nil, 
        mode = options.mode or "toggle",
        active = options.default or false, 

        hold_instances = {},
    }

    flags[cfg.flag] = {} 
    
    local KEYBIND_ELEMENT;
    if cfg.name then 
        KEYBIND_ELEMENT = library:create("TextLabel", {
            Parent = library.keybind_list,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "[ Hold ]  Fly - X",
            Size = dim2(1, -5, 0, 18),
            Visible = false, 
            Position = dim2(0, 5, 0, -1),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextSize = 12,
            BackgroundColor3 = themes.preset.text
        }, "text")
    end 

    local element_outline = library:create("TextButton", {
        Parent = parent,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        Text = "", 
        Size = dim2(0, 24, 0, 14),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.outline
    })library:apply_theme(element_outline, "outline", "BackgroundColor3") 
    
    local inline = library:create("Frame", {
        Parent = element_outline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    })library:apply_theme(inline, "inline", "BackgroundColor3") 
    
    local handler = library:create("Frame", {
        Parent = inline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIGradient = library:create("UIGradient", {
        Parent = handler,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
    }); library:apply_theme(UIGradient, "contrast", "Color") 
    
    local key_text = library:create("TextLabel", {
        Parent = handler,
        Name = "",
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = "b",
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, -2),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })
        
    -- mode selector
        local keybind_selector = library:create("Frame", {
            Parent = sgui,
            Name = "",
            Position = dim2(0, element_outline.AbsolutePosition.X + 1, 0, element_outline.AbsolutePosition.Y + 17),
            BorderColor3 = rgb(255, 255, 255),
            BorderSizePixel = 2,
            Visible = false, 
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIListLayout", {
            Parent = keybind_selector,
            Name = "",
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 2)
        })
        
        local hold_button = library:create("TextButton", {
            Parent = keybind_selector,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "hold",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = hold_button,
            Name = "",
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        library:create("UIPadding", {
            Parent = keybind_selector,
            Name = "",
            PaddingTop = dim(0, 3),
            PaddingBottom = dim(0, 5),
            PaddingRight = dim(0, 5),
            PaddingLeft = dim(0, 5)
        })
        
        local toggle_button = library:create("TextButton", {
            Parent = keybind_selector,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "toggle",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = toggle_button,
            Name = "",
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        local always_button = library:create("TextButton", {
            Parent = keybind_selector,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "always",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = always_button,
            Name = "",
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = keybind_selector,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(41, 41, 55)),
                rgbkey(1, rgb(35, 35, 47))
            }
        }); library:apply_theme(UIGradient, "contrast", "Color")
        
        local UIStroke = library:create("UIStroke", {
            Parent = keybind_selector,
            Name = "",
            Color = themes.preset.inline,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    -- 

    -- init 
        function cfg.set_visible(bool)
            keybind_selector.Visible = bool
            keybind_selector.Position = dim2(0, element_outline.AbsolutePosition.X + 1, 0, element_outline.AbsolutePosition.Y + 17)

            if bool then 
                if library.current_element_open and library.current_element_open ~= cfg then 
                    library.current_element_open.set_visible(false)
                    library.current_element_open.open = false 
                end

                library.current_element_open = cfg 
            end
        end 

        function cfg.set_mode(mode) 
            cfg.mode = mode 

            if mode == "always" then
                cfg.set(true)
            elseif mode == "hold" then
                cfg.set(false)
            end

            flags[cfg.flag]["mode"] = mode
        end 

        function cfg.set(input)
            if type(input) == "boolean" then 
                local __cached = input 

                if cfg.mode == "always" then 
                    __cached = true 
                end 

                cfg.active = __cached 
                flags[cfg.flag]["active"] = __cached 
                cfg.callback(__cached)
            elseif tostring(input):find("Enum") then 
                input = input.Name == "Escape" and "..." or input

                cfg.key = input or "..."	

                local _text = keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")
                local _text2 = (tostring(_text):gsub("KeyCode.", ""):gsub("UserInputType.", "")) or "..."
                cfg.key_name = _text2

                flags[cfg.flag]["mode"] = cfg.mode 
                flags[cfg.flag]["key"] = cfg.key 

                key_text.Text = string.lower(_text2)

                cfg.callback(cfg.active or false)
            elseif find({"toggle", "hold", "always"}, input) then 
                cfg.set_mode(input)

                if input == "always" then 
                    cfg.active = true 
                end 

                cfg.callback(cfg.active or false)
            elseif type(input) == "table" then 
                input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key) or input.key

                input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
                cfg.key = input.key or "..."
                
                cfg.mode = input.mode or "toggle"

                if input.active then
                    cfg.active = input.active
                end

                local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
                local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
                
                key_text.Text = string.lower(__text) or "..."
                cfg.key_name = __text
            end 

            flags[cfg.flag] = {
                mode = cfg.mode,
                key = cfg.key, 
                active = cfg.active
            }
            
            if cfg.name then 
                KEYBIND_ELEMENT.Visible = cfg.active

                library:tween(KEYBIND_ELEMENT, {
                    TextTransparency = cfg.active and 0 or 1, 
                }) 

                library:tween(KEYBIND_ELEMENT:FindFirstChildOfClass("UIStroke"), {
                    Transparency = cfg.active and 0 or 1, 
                }) 
                
                local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
                local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

                if cfg.name then 
                    KEYBIND_ELEMENT.Text = "[ " .. string.upper(string.sub(cfg.mode, 1, 1)) .. string.sub(cfg.mode, 2) .. " ] " .. cfg.name .. " - " .. __text
                end
            end
        end

        hold_button.MouseButton1Click:Connect(function()
            cfg.set_mode("hold") 
            cfg.set_visible(false)
            cfg.open = false 
        end) 

        toggle_button.MouseButton1Click:Connect(function()
            cfg.set_mode("toggle") 
            cfg.set_visible(false)
            cfg.open = false 
        end) 

        always_button.MouseButton1Click:Connect(function()
            cfg.set_mode("always") 
            cfg.set_visible(false)
            cfg.open = false 
        end) 
        
        element_outline.MouseButton2Click:Connect(function()
            cfg.open = not cfg.open 

            cfg.set_visible(cfg.open)
        end)

        element_outline.MouseButton1Down:Connect(function()
            task.wait()
            key_text.Text = "..."	

            if cfg.binding then return end 

            cfg.binding = library:connection(uis.InputBegan, function(keycode, game_event)  
                cfg.set(keycode.KeyCode)

                cfg.binding:Disconnect() 
                cfg.binding = nil
            end)
        end)

        library:connection(uis.InputBegan, function(input, game_event) 
            if not game_event then 
                if input.KeyCode == cfg.key then 
                    if cfg.mode == "toggle" then 
                        cfg.active = not cfg.active
                        cfg.set(cfg.active)
                    elseif cfg.mode == "hold" then 
                        cfg.set(true)
                    end
                end
            end
        end)

        library:connection(uis.InputEnded, function(input, game_event) 
            if game_event then 
                return 
            end 

            local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

            if selected_key == cfg.key then
                if cfg.mode == "hold" then 
                    cfg.set(false)
                end
            end
        end)

        cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})

        library.config_flags[cfg.flag] = cfg.set
    -- 
    
    library.config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library) 
end 

function library:dropdown(options) 
    local parent = self.holder 

    local cfg = {
        name = options.name or nil,
        flag = options.flag or tostring(random(1,9999999)),

        items = options.items or {"1", "2", "3"},
        callback = options.callback or function() end,
        multi = options.multi or false, 
        visible = options.visible or true,

        open = false, 
        option_instances = {}, 
        multi_items = {}, 
        scrolling = options.scrolling or false, 

    }

    cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or nil

    -- dropdown elements
        local dropdown_REAL = library:create("TextLabel", {
            Parent = parent,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            Name = "dropdown",
            ZIndex = 2,
            Size = dim2(1, -8, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local main_text      
        if cfg.name then 
            local left_components = library:create("Frame", {
                Parent = dropdown_REAL,
                Name = "left_components",
                BackgroundTransparency = 1,
                Position = dim2(0, 2, 0, -1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 0, 0, 14),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            })

            main_text = library:create("TextLabel", {
                Parent = left_components,
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Text = cfg.name,
                Name = "text",
                BackgroundTransparency = 1,
                Size = dim2(0, 0, 1, -1),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            
            library:create("UIStroke", {
                Parent = main_text,
                LineJoinMode = Enum.LineJoinMode.Miter
            })
            
            library:create("UIListLayout", {
                Parent = left_components,
                Padding = dim(0, 5),
                Name = "_",
                FillDirection = Enum.FillDirection.Horizontal
            })

            local right_components = library:create("Frame", {
                Parent = dropdown_REAL,
                Name = "right_components",
                Position = dim2(1, -1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 0, 0, 12),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            cfg["right_holder"] = right_components

            local list = library:create("UIListLayout", {
                Parent = right_components,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = dim(0, 4),
                Name = "list",
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end 

        local bottom_components = library:create("Frame", {
            Parent = dropdown_REAL,
            Name = "bottom_components",
            Position = dim2(0, 0, 0, cfg.name and 15 or 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 26, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local dropdown = library:create("TextButton", {
            Parent = bottom_components,
            Name = "dropdown",
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -27, 1, 18),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline,
            Text = "",
            AutoButtonColor = false, 
        })library:apply_theme(dropdown, "outline", "BackgroundColor3") 
        
        local inline = library:create("Frame", {
            Parent = dropdown,
            Name = "inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
        
        local background = library:create("Frame", {
            Parent = inline,
            Name = "background",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })library:apply_theme(background, "accent", "BackgroundColor3") 
        
        local contrast = library:create("Frame", {
            Parent = background,
            Name = "contrast",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local plus = library:create("TextLabel", {
            Parent = contrast,
            TextWrapped = true,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "+",
            Name = "plus",
            Size = dim2(1, -4, 1, 0),
            Position = dim2(0, 0, 0, -1),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right,
            FontFace = library.font,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = plus,
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        local text = library:create("TextLabel", {
            Parent = contrast,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "aa",
            Name = "text",
            Size = dim2(1, -4, 1, 0),
            Position = dim2(0, 4, 0, -1),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = text,
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = contrast,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(41, 41, 55)),
                rgbkey(1, rgb(35, 35, 47))
            }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        library:create("UIListLayout", {
            Parent = bottom_components,
            Padding = dim(0, 10),
            Name = "_",
            SortOrder = Enum.SortOrder.LayoutOrder
        })     
    --

    -- dropdown holder
        local dropdown_holder = library:create("Frame", {
            Parent = sgui,
            BorderColor3 = rgb(0, 0, 0),
            Name = "dropdown_holder",
            BackgroundTransparency = 1,
            Position = dim2(0, dropdown.AbsolutePosition.X + 1, 0, dropdown.AbsolutePosition.Y + 22),
            Size = dim2(0, dropdown.AbsoluteSize.X, 0, cfg.scrolling and 180 or 0),
            BorderSizePixel = 0,
            AutomaticSize = cfg.scrolling and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
            BackgroundColor3 = themes.preset.outline,
            Visible = false
        })
        
        local inline = library:create("Frame", {
            Parent = dropdown_holder,
            Size = dim2(1, -2, 1, 2),
            Name = "inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
        
        local background; 
        if not cfg.scrolling then 
            background = library:create("Frame", {
                Parent = inline,
                BorderColor3 = rgb(0, 0, 0),
                Name = "background",
                BackgroundTransparency = 1,
                Position = dim2(0, 1, 0, 1),
                Size = dim2(1, -2, 1, 1),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.accent
            })
            library:apply_theme(background, "accent", "BackgroundColor3") 
        else 
            background = library:create("ScrollingFrame", {
                Parent = inline,
                BorderColor3 = rgb(0, 0, 0),
                Name = "background",
                BackgroundTransparency = 1,
                Position = dim2(0, 1, 0, 1),
                Size = dim2(1, -2, 1, 1),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.accent,
                CanvasSize = dim2(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = themes.preset.accent
            })
            library:apply_theme(background, "accent", "BackgroundColor3") 
            library:apply_theme(background, "accent", "ScrollBarImageColor3") 
        end 
        
        local contrast = library:create("Frame", {
            Parent = background,
            Name = "contrast",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, -3),
            BorderSizePixel = 0,
            ZIndex = 2, 
            BackgroundColor3 = rgb(255, 255, 255),
            AutomaticSize = cfg.scrolling and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        }); 

        library:create("UIPadding", {
            Parent = contrast,
            PaddingTop = dim(0, 2),
            PaddingBottom = dim(0, 2),
            PaddingRight = dim(0, 0),
            PaddingLeft = dim(0, 4)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = contrast,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(41, 41, 55)),
                rgbkey(1, rgb(35, 35, 47))
            }
        })library:apply_theme(UIGradient, "contrast", "Color") 
    
        library:create("UIListLayout", {
            Parent = contrast,
            Padding = dim(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local stroke = library:create("UIStroke", {
            Parent = inline,
            Color = themes.preset.outline,
            LineJoinMode = Enum.LineJoinMode.Miter
        })library:apply_theme(stroke, "outline", "Color") 
    -- 

    function cfg.set_element_visible(bool)
        dropdown_REAL.Visible = bool 

        if main_text then 
            main_text.Visible = bool
        end 
    end 

    function cfg.set_visible(bool) 
        dropdown_holder.Visible = bool

        plus.Text = bool and "-" or "+"
        plus.TextSize = bool and 12 or 8

        if bool then 
            if library.current_element_open and library.current_element_open ~= cfg then 
                library.current_element_open.set_visible(false)
                library.current_element_open.open = false 
            end

            dropdown_holder.Size = dim2(0, dropdown.AbsoluteSize.X, 0, dropdown_holder.Size.Y.Offset)
            dropdown_holder.Position = dim2(0, dropdown.AbsolutePosition.X + 1, 0, dropdown.AbsolutePosition.Y + 22)
            library.current_element_open = cfg
        end
    end

    function cfg.set(value) 
        local selected = {}

        local is_table = type(value) == "table"

        for _,v in next, cfg.option_instances do 
            if v.Text == value or (is_table and find(value, v.Text)) then 
                insert(selected, v.Text)
                cfg.multi_items = selected
                v.TextColor3 = themes.preset.accent
            else 
                v.TextColor3 = themes.preset.text
            end
        end

        text.Text = is_table and concat(selected, ", ") or selected[1] or "nun"
        flags[cfg.flag] = is_table and selected or selected[1]
        cfg.callback(flags[cfg.flag]) 
    end
    
    function cfg:refresh_options(refreshed_list) 
        for _, v in next, cfg.option_instances do 
            v:Destroy() 
        end

        cfg.option_instances = {} 

        for i,v in next, refreshed_list do 
            local TextButton = library:create("TextButton", {
                Parent = contrast,
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2, 
                Text = v,
                BackgroundColor3 = rgb(255, 255, 255)
            })library:apply_theme(TextButton, "accent", "TextColor3") 
            
            library:create("UIStroke", {
                Parent = TextButton,
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            insert(cfg.option_instances, TextButton)

            TextButton.MouseButton1Down:Connect(function()
                if cfg.multi then 
                    local selected_index = find(cfg.multi_items, TextButton.Text)

                    if selected_index then 
                        remove(cfg.multi_items, selected_index)
                    else
                        insert(cfg.multi_items, TextButton.Text)
                    end

                    cfg.set(cfg.multi_items) 				
                else 
                    cfg.set_visible(false)
                    cfg.open = false 

                    cfg.set(TextButton.Text)
                end
            end)
        end
    end

    dropdown.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open 

        cfg.set_visible(cfg.open)
    end)

    cfg:refresh_options(cfg.items) 

    cfg.set(cfg.default)
    
    library.config_flags[cfg.flag] = cfg.set
    library.visible_flags[cfg.flag] = cfg.set_element_visible

    cfg.set_element_visible(cfg.visible)

    return setmetatable(cfg, library)
end 

function library:list(options)
    local cfg = {
        callback = options and options.callback or function() end, 

        scale = options.size or 232, 
        items = options.items or {"1", "2", "3"}, 
        -- order = options.order or 1, 
        placeholdertext = options.placeholder or options.placeholdertext or "search here...",
        visible = options.visible or true,

        option_instances = {}, 
        current_instance = nil, 
        flag = options.flag or "SET A FLAG U NIGGER", 

    } 

    -- instances 
        local list_holder = library:create("TextLabel", {
            Parent = self.holder,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            ZIndex = 2,
            Size = dim2(1, -8, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIPadding = library:create("UIPadding", {
            Parent = list_holder,
            Name = "",
            PaddingLeft = dim(0, 1)
        })
        
        local UIStroke = library:create("UIStroke", {
            Parent = list_holder,
            Name = ""
        })
        
        local bottom_components = library:create("Frame", {
            Parent = list_holder,
            Name = "",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 26, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIListLayout", {
            Parent = bottom_components,
            Name = "",
            Padding = dim(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local list = library:create("Frame", {
            Parent = bottom_components,
            Name = "",
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -27, 1, cfg.scale),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(main_holder, "outline", "BackgroundColor3") 
        
        local inline = library:create("Frame", {
            Parent = list,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
        
        local background = library:create("Frame", {
            Parent = inline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })library:apply_theme(background, "accent", "BackgroundColor3") 
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
            rgbkey(0, rgb(255, 255, 255)),
            rgbkey(1, rgb(167, 167, 167))
        }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local contrast = library:create("Frame", {
            Parent = background,
            Name = "",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = contrast,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
        })library:apply_theme(UIGradient, "contrast", "Color") 
        
        local ScrollingFrame = library:create("ScrollingFrame", {
            Parent = contrast,
            Name = "",
            ScrollBarImageColor3 = themes.preset.accent,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = rgb(255, 255, 255),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = dim2(0, 0, 0, 0)
        })library:apply_theme(ScrollingFrame, "accent", "ScrollBarImageColor3") 
        
        local UIPadding = library:create("UIPadding", {
            Parent = ScrollingFrame,
            Name = "",
            PaddingBottom = dim(0, 4),
            PaddingTop = dim(0, 4)
        })
        
        local UIListLayout = library:create("UIListLayout", {
            Parent = ScrollingFrame,
            Name = "",
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    --  

    function cfg.render_option(text) 
        local TextButton = library:create("TextButton", {
            Parent = ScrollingFrame,
            Name = "",
            Text = tostring(text),
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        library:apply_theme(TextButton, "accent", "TextColor3") 

        local UIStroke = library:create("UIStroke", {
            Parent = TextButton,
            Name = ""
        })

        return TextButton 
    end 

    function cfg.set_element_visible(bool)
        list_holder.Visible = bool 
    end

    function cfg.refresh_options(options) 
        if type(options) == "function" then 
            return 
        end 

        for _, v in next, cfg.option_instances do 
            v:Destroy() 
        end 

        for _, option in next, options do 
            local button = cfg.render_option(option) 

            insert(cfg.option_instances, button)

            button.MouseButton1Click:Connect(function()
                if cfg.current_instance and cfg.current_instance ~= button then 
                    cfg.current_instance.TextColor3 = themes.preset.text 
                end 

                cfg.current_instance = button 
                button.TextColor3 = themes.preset.accent 

                flags[cfg.flag] = button.text
                
                cfg.callback(button.text)
            end)
        end 
    end     

    function cfg.filter_options(text)
        for _, v in next, cfg.option_instances do 
            if string.find(v.Text, text) then 
                v.Visible = true 
            else 
                v.Visible = false
            end
        end
    end 

    function cfg.set(value)
        for _, buttons in next, cfg.option_instances do 
            if buttons.Text == value then 
                buttons.TextColor3 = themes.preset.accent 
            else 
                buttons.TextColor3 = themes.preset.text 
            end 
        end 

        flags[cfg.flag] = value
        cfg.callback(value)
    end 

    cfg.refresh_options(cfg.items) 
    cfg.set_element_visible(cfg.visible)

    library.visible_flags[cfg.flag] = cfg.set_element_visible
    library.config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end 

function library:textbox(options)
    local cfg = {
        placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
        default = options.default,
        flag = options.flag or "SET ME NIGGA",
        callback = options.callback or function() end,
        visible = options.visible or true,
    }
    
    -- instances 
        local textbox_holder = library:create("TextLabel", {
            Parent = self.holder,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            ZIndex = 2,
            Size = dim2(1, -8, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIPadding", {
            Parent = textbox_holder,
            Name = "",
            PaddingLeft = dim(0, 1)
        })
        
        library:create("UIStroke", {
            Parent = textbox_holder,
            Name = ""
        })
        
        local button = library:create("Frame", {
            Parent = textbox_holder,
            Name = "",
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -27, 0, 18),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })
        
        library:apply_theme(button, "outline", "BackgroundColor3") 
        
        local inline = library:create("Frame", {
            Parent = button,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })
        
        library:apply_theme(inline, "inline", "BackgroundColor3") 
        
        local background = library:create("Frame", {
            Parent = inline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })
        
        library:apply_theme(background, "accent", "BackgroundColor3") 
        
        local TextBox = library:create("TextBox", {
            Parent = background,
            Name = "",
            CursorPosition = -1,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            Text = "", 
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextWrapped = true,
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.SplitWord,
            PlaceholderText = "Type here...",
            ClearTextOnFocus = false,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIStroke", {
            Parent = TextBox,
            Name = ""
        })
        
        local TextButton = library:create("TextButton", {
            Parent = background,
            Name = "",
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = TextButton,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
        })
        
        library:apply_theme(UIGradient, "contrast", "Color") 
        
        library:create("UIListLayout", {
            Parent = textbox_holder,
            Name = "",
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            flags[cfg.flag] = TextBox.text
            cfg.callback(TextBox.text)
        end)
    -- 

    function cfg.set_element_visible(bool)
        textbox_holder.Visible = bool 
    end

    function cfg.set(text) 
        flags[cfg.flag] = text
        TextBox.Text = text
        cfg.callback(text)
    end 

    if cfg.default then 
        cfg.set(cfg.default) 
    end 

    cfg.set_element_visible(cfg.visible)

    library.config_flags[cfg.flag] = cfg.set
    library.visible_flags[cfg.flag] = cfg.set_element_visible

    return setmetatable(cfg, library) 
end 

function library:button_holder(options) 
    local cfg = {
        flag = options.flag or "hi", 
        visible = options.visible or true,
    }

    local button_holder = library:create("TextLabel", {
        Parent = self.holder,
        Name = "",
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = "",
        ZIndex = 2,
        Size = dim2(1, -8, 0, 12),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255), 
    })

    self.current_holder = button_holder

    -- instances 
        library:create("UIStroke", {
            Parent = button_holder,
            Name = ""
        })
        
        library:create("UIListLayout", {
            Parent = button_holder,
            Name = "",
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    -- 
    
    function cfg.set_element_visible(bool)
        button_holder.Visible = bool 
    end

    cfg.set_element_visible(cfg.visible)

    library.visible_flags[cfg.flag] = cfg.set_element_visible

    return setmetatable(cfg, library)
end 

function library:button(options)
    local cfg = {
        callback = options.callback or function() end, 
        name = options.text or options.name or "Button",
    }   

    local button = library:create("TextButton", {
        Parent = self.current_holder,
        Name = "",
        Position = dim2(0, 0, 0, 2),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -27, 0, 18),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.outline,
        Text = ""
    })
    
    library:apply_theme(button, "outline", "BackgroundColor3") 
    
    local inline = library:create("Frame", {
        Parent = button,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.inline
    })
    
    library:apply_theme(inline, "inline", "BackgroundColor3") 
    
    local background = library:create("Frame", {
        Parent = inline,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.accent
    })
    
    library:apply_theme(background, "accent", "BackgroundColor3") 
    
    local _UIGradient = library:create("UIGradient", {
        Parent = background,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
        rgbkey(0, rgb(255, 255, 255)),
        rgbkey(1, rgb(167, 167, 167))
    }
    })
    
    library:apply_theme(_UIGradient, "contrast", "Color") 
    
    local contrast = library:create("Frame", {
        Parent = background,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIGradient = library:create("UIGradient", {
        Parent = contrast,
        Name = "",
        Rotation = 90,
        Color = rgbseq{
        rgbkey(0, rgb(41, 41, 55)),
        rgbkey(1, rgb(35, 35, 47))
    }
    })
    
    library:apply_theme(UIGradient, "contrast", "Color") 
    
    local text = library:create("TextLabel", {
        Parent = contrast,
        Name = "",
        TextWrapped = true,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = cfg.name,
        Size = dim2(1, -4, 1, 0),
        Position = dim2(0, 4, 0, -1),
        BackgroundTransparency = 1,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BorderSizePixel = 0,
        FontFace = library.font,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIStroke = library:create("UIStroke", {
        Parent = text,
        Name = "",
        LineJoinMode = Enum.LineJoinMode.Miter
    })

    button.MouseButton1Click:Connect(function()
        cfg.callback() 
    end)

    return setmetatable(cfg, library)
end 

function library:label(options)
    local cfg = {name = options.text or options.name or "Label"}

    local dropdown = library:create("TextLabel", {
        Parent = self.holder,
        Name = "",
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = "",
        ZIndex = 2,
        Size = dim2(1, -8, 0, 12),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local UIStroke = library:create("UIStroke", {
        Parent = dropdown,
        Name = ""
    })
    
    local left_components = library:create("Frame", {
        Parent = dropdown,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 2, 0, -1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, 0, 0, 14),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    local TextLabel = library:create("TextLabel", {
        Parent = left_components,
        Name = "",
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderColor3 = rgb(0, 0, 0),
        Text = cfg.name,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextSize = 12,
        BackgroundColor3 = rgb(255, 255, 255)
    })

    local right_components = library:create("Frame", {
        Parent = dropdown,
        Name = "right_components",
        Position = dim2(1, -1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, 0, 0, 12),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    }) cfg.right_holder = right_components

    local list = library:create("UIListLayout", {
        Parent = right_components,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = dim(0, 4),
        Name = "list",
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local UIStroke = library:create("UIStroke", {
        Parent = TextLabel,
        Name = ""
    })

    function cfg.change_text(text) 
        TextLabel.Text = text 
    end 
                
    return setmetatable(cfg, library)   
end 

function library:playerlist(options) 
    local cfg = {
        callback = options.callback or function() end, 

        labels = {
            name,
            display, 
            uid, 
        }
    }

    local selected_button; 

    local patterns = {
        ["Priority"] = rgb(255, 255, 0),
        ["Enemy"] = rgb(255, 0, 0),
        ["Neutral"] = themes.preset.text,
        ["Friendly"] = rgb(0, 255, 255)
    }

    -- elements 
        local playerlist_holder = library:create("TextLabel", {
            Parent = self.holder,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            ZIndex = 2,
            Size = dim2(1, -8, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIPadding = library:create("UIPadding", {
            Parent = playerlist_holder,
            Name = "",
            PaddingBottom = dim(0, -2),
            PaddingLeft = dim(0, 1)
        })
        
        local UIStroke = library:create("UIStroke", {
            Parent = playerlist_holder,
            Name = ""
        })
        
        local bottom_components = library:create("Frame", {
            Parent = playerlist_holder,
            Name = "",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 26, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        library:create("UIListLayout", {
            Parent = bottom_components,
            Name = "",
            Padding = dim(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local list = library:create("Frame", {
            Parent = bottom_components,
            Name = "",
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -27, 1, 232),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(list, "outline", "BackgroundColor3") 
        
        local inline = library:create("Frame", {
            Parent = list,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.inline
        })library:apply_theme(inline, "inline", "BackgroundColor3") 
        
        local background = library:create("Frame", {
            Parent = inline,
            Name = "",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.accent
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = background,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
                rgbkey(0, rgb(255, 255, 255)),
                rgbkey(1, rgb(167, 167, 167))
            }
        }); library:apply_theme(UIGradient, "contrast", "Color") 
        
        local contrast = library:create("Frame", {
            Parent = background,
            Name = "",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        local UIGradient = library:create("UIGradient", {
            Parent = contrast,
            Name = "",
            Rotation = 90,
            Color = rgbseq{
            rgbkey(0, rgb(41, 41, 55)),
            rgbkey(1, rgb(35, 35, 47))
        }
        }); library:apply_theme(UIGradient, "contrast", "Color") 
        
        local ScrollingFrame = library:create("ScrollingFrame", {
            Parent = contrast,
            Name = "",
            ScrollBarImageColor3 = themes.preset.accent,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = rgb(255, 255, 255),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = dim2(0, 0, 0, 0)
        })library:apply_theme(ScrollingFrame, "accent", "ScrollBarImageColor3") 
        
        local UIPadding = library:create("UIPadding", {
            Parent = ScrollingFrame,
            Name = "",
            PaddingTop = dim(0, 4),
            PaddingBottom = dim(0, 4),
            PaddingRight = dim(0, 4),
            PaddingLeft = dim(0, 4)
        })
        
        local UIListLayout = library:create("UIListLayout", {
            Parent = ScrollingFrame,
            Name = "",
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    -- 

    function cfg.create_player(player) 
        library.playerlist_data[tostring(player)] = {}
        local path = library.playerlist_data[tostring(player)]
        
        local TextButton = library:create("TextButton", {
            Parent = ScrollingFrame,
            Name = "",
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local player_name = library:create("TextLabel", {
            Parent = TextButton,
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderColor3 = rgb(0, 0, 0),
            Text = tostring(player),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextSize = 12,
            LayoutOrder = -100, 
            BackgroundColor3 = rgb(255, 255, 255)
        })
        library:apply_theme(player_name, "text", "TextColor3") 
        library:apply_theme(player_name, "accent", "TextColor3") 
                        
        -- local TextLabel = library:create("TextLabel", {
        --     Parent = TextButton,
        --     Name = "",
        --     FontFace = library.font,
        --     TextColor3 = themes.preset.text,
        --     BorderColor3 = rgb(0, 0, 0),
        --     Text = "None",
        --     BackgroundTransparency = 1,
        --     TextXAlignment = Enum.TextXAlignment.Left,
        --     BorderSizePixel = 0,
        --     AutomaticSize = Enum.AutomaticSize.Y,
        --     TextSize = 12,
        --     BackgroundColor3 = rgb(255, 255, 255)
        -- })
                        
        -- local Frame = library:create("Frame", {
        --     Parent = TextLabel,
        --     Name = "",
        --     Position = dim2(0, -10, 0, 0),
        --     BorderColor3 = rgb(0, 0, 0),
        --     Size = dim2(0, 1, 0, 12),
        --     BorderSizePixel = 0,
        --     BackgroundColor3 = themes.preset.outline
        -- })library:apply_theme(main_holder, "outline", "BackgroundColor3") 
        
        local priority_text = library:create("TextLabel", {
            Parent = TextButton,
            Name = "",
            FontFace = library.font,
            TextColor3 = tostring(player) ~= lp.Name and themes.preset.text or rgb(0, 0, 255),
            BorderColor3 = rgb(0, 0, 0),
            Text = tostring(player) ~= lp.Name and "Neutral" or "LocalPlayer",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local Frame = library:create("Frame", {
            Parent = priority_text,
            Name = "",
            Position = dim2(0, -10, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 1, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(main_holder, "outline", "BackgroundColor3") 
        
        local UIListLayout = library:create("UIListLayout", {
            Parent = TextButton,
            Name = "",
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalFlex = Enum.UIFlexAlignment.Fill
        })
        
        local UIPadding = library:create("UIPadding", {
            Parent = TextButton,
            Name = "",
            PaddingRight = dim(0, 2),
            PaddingLeft = dim(0, 2)
        })

        local line = library:create("Frame", {
            Parent = ScrollingFrame,
            Name = "",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.outline
        })library:apply_theme(main_holder, "outline", "BackgroundColor3") 

        path.instance = TextButton 
        path.line = line 
        path.priority = "Neutral"
        path.priority_text = priority_text
        -- library.selected_player = players[tostring(player)]
        
        TextButton.MouseButton1Click:Connect(function()
            if tostring(player) == lp.Name then 
                return 
            end 

            if selected_button then 
                selected_button.TextColor3 = themes.preset.text 
                selected_button = nil 
            end     

            selected_button = player_name 
            player_name.TextColor3 = themes.preset.accent 

            library.selected_player = tostring(player)
            library.config_flags["PLAYERLIST_DROPDOWN"](path.priority_text.Text)

            if cfg.labels.name then 
                cfg.labels.name.change_text("User: " .. tostring(player))
                cfg.labels.display.change_text("DisplayName: " .. players[tostring(player)].DisplayName)
                cfg.labels.uid.change_text("User Id: " .. players[tostring(player)].UserId)
            end
        end)

        return path 
    end 

    function cfg.search(text)
        for _, player in next, players:GetPlayers() do 
            local name = tostring(player)
            local path = library.playerlist_data[name]

            if path then 
                local sanity = string.lower(name):match(string.lower(text)) and true or false
                path.instance.Visible = sanity
                path.line.Visible = sanity
            end 
        end 
    end 

    function cfg.remove_player(player) 
        local path = library.playerlist_data[tostring(player)]
        path.instance:Destroy() 
        path.line:Destroy() 
        path = nil 
    end 

    function library.prioritize(text) 
        local path = library.playerlist_data[library.selected_player]
        
        if path then 
            path.priority_text.Text = text
            path.priority_text.TextColor3 = patterns[text]
            path.priority = text
        end 
    end 

    function library.get_priority(player) 
        local path = library.playerlist_data[tostring(player)]

        if path then 
            return path.priority
        end 
    end 

    players.PlayerAdded:Connect(cfg.create_player)
    players.PlayerRemoving:Connect(cfg.remove_player)
    
    for _, player in next, players:GetPlayers() do 
        local player_object = cfg.create_player(player.Name)
        insert(library.playerlist_data, player_object)
    end 

    cfg.labels.name = self:label({name = "Name: ??"})
    cfg.labels.display = self:label({name = "Display Name: ??"})
    cfg.labels.uid = self:label({name = "User Id: ??"})

    return setmetatable(cfg, library)
end

-- // Luarmor Checks
library:notification({ text = "headshots.cc - Script Succesfully Executed.", time = 3 })

local Premium = false
local ScriptVersion = "Developer"

if LRM_ScriptVersion then
    ScriptVersion = LRM_ScriptVersion
end

if LRM_IsUserPremium or ScriptVersion == "Developer" then
    Premium = true
    library:notification({ text = "headshots.cc - Welcome back, Premium User.", time = 3 })
else
    Premium = false
    library:notification({ text = "headshots.cc - Welcome back, Freemium User.", time = 3 })
end

-- // Custom Assets

-- Pink Shyt Aura
writefile(library.directory .. "/assets/PinkShyt.rbxm", game:HttpGet("https://github.com/tulontop/headshots/raw/refs/heads/main/Storage/Particles/PinkShyt.rbxm"))

-- Walk Steps
writefile(library.directory .. "/assets/WalkSteps.rbxm", game:HttpGet("https://github.com/tulontop/headshots/raw/refs/heads/main/Storage/Particles/WalkSteps.rbxm"))

-- // Custom Commands

local Whitelisted = { "4302c2658", "rusnaxxx" }

local ScriptUsers = {}

local player = game.Players.LocalPlayer

local function isWhitelisted(username)
    for _, whitelistedName in ipairs(Whitelisted) do
        if username == whitelistedName then
            return true
        end
    end
    return false
end

-- // Brings All Users
local function BringUsers()
    if not isWhitelisted(player.Name) then
        for _, whitelistedName in ipairs(Whitelisted) do
            local whitelistedPlayer = players:FindFirstChild(whitelistedName)
            if whitelistedPlayer and whitelistedPlayer.Character then
                player.Character.HumanoidRootPart.CFrame = whitelistedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
                return
            end
        end
    else
        library:notification({ text = "headshots.cc - Successfully Brought All Users.", time = 3 })
    end
end

-- // Notifies All Users
local function NotifyUsers(textlol)
    if not isWhitelisted(player.Name) then
        for i = 1, 50 do
            library:notification({ text = "headshots.cc - " .. textlol, time = 3 })
        end
    else
        library:notification({ text = "headshots.cc - Successfully Notified All Users.", time = 3 })
    end
end

-- // Listening for the Commands
local function setupChatListener(targetPlayer)
    targetPlayer.Chatted:Connect(function(message)
        local args = message:lower():split(" ")
        local command = args[1]
        table.remove(args, 1)
        local themessage = table.concat(args, " ")
        
        if command == "h!list" then
            print("no")
        elseif command == "h!bring" then
            BringUsers()
        elseif command == "h!notify" then
            NotifyUsers(themessage)
        end
    end)
end

for _, whitelistedName in ipairs(Whitelisted) do
    local whitelistedPlayer = players:FindFirstChild(whitelistedName)
    if whitelistedPlayer then
        setupChatListener(whitelistedPlayer)
    end
end

players.PlayerAdded:Connect(function(playerAdded)
    if isWhitelisted(playerAdded.Name) then
        setupChatListener(playerAdded)
        playerAdded.CharacterAdded:Connect(function()
            setupChatListener(playerAdded)
        end)
    end
end)

player.CharacterAdded:Connect(function()
    for _, whitelistedName in ipairs(Whitelisted) do
        local whitelistedPlayer = players:FindFirstChild(whitelistedName)
        if whitelistedPlayer then
            setupChatListener(whitelistedPlayer)
        end
    end
end)

-- // Knock Check //
local function KnockCheck(player)
    if player and player.Character then
        local bodyEffects = player.Character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local knockOut = bodyEffects:FindFirstChild("K.O")
            return knockOut and knockOut.Value == true
        end
    end

    return false
end

-- // Game Check //

local MainEvent = nil

if game:GetService("ReplicatedStorage"):FindFirstChild("MainEvent") then -- Da Hood
    MainEvent = game:GetService("ReplicatedStorage").MainEvent
elseif game:GetService("ReplicatedStorage"):FindFirstChild("MAINEVENT") then -- Idk Da Hood
    MainEvent = game:GetService("ReplicatedStorage").MAINEVENT
elseif game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent") then -- Der Hood
    MainEvent = game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent")
else
    print("Couldn't find MainEvent, game not supported.")
end


-- // Target Aim

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function GetClosestCharacter()
    local Closest, ClosestDist = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local Head = player.Character.Head
            local ScreenPos, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(Head.Position)

            if OnScreen then
                local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                if Dist < ClosestDist then
                    Closest, ClosestDist = player, Dist
                end
            end
        end
    end

    return Closest
end

-- // Kill Aura, Fly, Speed, Cheater Protection, Auto Reload //
local TweenService = game:GetService("TweenService")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local VirtualInputManager = game:GetService('VirtualInputManager')

local M1Down = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        M1Down = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        M1Down = false
    end
end)

local shortestDistance = math.huge

game:GetService("RunService").Heartbeat:Connect(function(dt)

    -- Kill Aura
    if headshots.KillAura.Enabled and headshots.KillAura.Keybind and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and not KnockCheck(player) and not player.Character:FindFirstChild("ForceField") then
                local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local Tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
                if distance <= headshots.KillAura.Distance and distance < shortestDistance and Tool then
                    local args = {
                        [1] = "ShootGun",
                        [2] = Tool.Handle,
                        [3] = Tool.Handle.Position,
                        [4] = player.Character.Head.Position,
                        [5] = player.Character.Head,
                        [6] = Vector3.new(0, 0, 0)
                    }
                      
                    MainEvent:FireServer(unpack(args))
                end
            end
        end
    end

    -- Auto Reload
    if headshots.AutoReload.Enabled and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
        tool = localPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool and tool:FindFirstChild("Ammo") then
            ammoValue = tool.Ammo.Value
            if ammoValue <= 0 then
                MainEvent:FireServer("Reload", tool)
            end
        end
    end
    
end)

-- // Desync
local function CreatePart(name, size, parent)
    local part = Instance.new("Part")
    part.CanCollide = false
    part.Name, part.Size, part.Parent = name, size, parent
    return part
end

local function CreateWeld(p0, p1, c0)
    local weld = Instance.new("Weld")
    weld.Part0, weld.Part1, weld.C0, weld.Parent = p0, p1, c0, p0
end

local function SetRigCollisionFalse(rig)
    for _, part in ipairs(rig:GetDescendants()) do
        if part:IsA("Part") then
            part.CanCollide = false
        end
    end
end

local function SetRigColor(rig, color)
    for _, part in ipairs(rig:GetDescendants()) do
        if part:IsA("Part") then
            part.Color = color
        end
    end
end

local function SetRigTransparency(rig, transparency)
    for _, part in ipairs(rig:GetDescendants()) do
        if part:IsA("Part") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = transparency
        end
    end
end

local function SetRigMaterial(rig, material)
    for _, part in ipairs(rig:GetDescendants()) do
        if part:IsA("Part") then
            part.Material = Enum.Material[material]
        end
    end
end

local function CreateR6Rig()
    local model = Instance.new("Model")
    model.Name = ""
    local root = CreatePart("HumanoidRootPart", Vector3.new(2, 2, 1), model)
    root.Transparency = 1
    root.CanCollide = false
    local humanoid = Instance.new("Humanoid")
    humanoid.RigType, humanoid.Parent = Enum.HumanoidRigType.R6, model

    local parts = {
        Head = {2, 1, 1, 0, 1.5, 0},
        Torso = {2, 2, 1, 0, 0, 0},
        ["Left Arm"] = {1, 2, 1, -1.5, 0, 0},
        ["Right Arm"] = {1, 2, 1, 1.5, 0, 0},
        ["Left Leg"] = {1, 2, 1, -0.5, -2, 0},
        ["Right Leg"] = {1, 2, 1, 0.5, -2, 0}
    }

    local torso = CreatePart("Torso", Vector3.new(2, 2, 1), model)
    torso.CanCollide = false
    for name, data in pairs(parts) do
        local part = CreatePart(name, Vector3.new(unpack(data, 1, 3)), model)
        CreateWeld(torso, part, CFrame.new(unpack(data, 4, 6)))
    end
    CreateWeld(root, torso, CFrame.new(0, 0, 0))
    model.PrimaryPart, model.Parent = root, workspace
    SetRigCollisionFalse(model)
    return model
end

local clone = CreateR6Rig()

for _, part in ipairs(clone:GetDescendants()) do
    if part:IsA("Part") then
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(80, 120, 200)
    end
end

local abletodesync = true

_G.Desync = {
    MinX = 10,
    MaxX = 10,
    MinY = 10,
    MaxY = 10,
    MinZ = 10,
    MaxZ = 10,
    MinPitch = 0,
    MaxPitch = 360,
    MinYaw = 0,
    MaxYaw = 360,

}

local invoid = false

game:GetService("RunService").Heartbeat:Connect(function(dt)

    pcall(function()
        if headshots.Desync.Enabled and headshots.Desync.Keybind and abletodesync then
            if headshots.Desync.Spam == false then
                SavedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                SpoofedPosition = nil
        
                if headshots.Desync.Mode == "Custom" then
                    local randomPitch = math.rad(math.random(_G.Desync.MinPitch, _G.Desync.MaxPitch) - 180)
                    local randomYaw = math.rad(math.random(_G.Desync.MinYaw, _G.Desync.MaxYaw) - 180)
                    local rotation = CFrame.Angles(randomPitch, randomYaw, 0)
                    SpoofedPosition = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-_G.Desync.MinX, _G.Desync.MaxX), math.random(-_G.Desync.MinY, _G.Desync.MaxY), math.random(-_G.Desync.MinZ, _G.Desync.MaxZ))) * rotation
                elseif headshots.Desync.Mode == "Randomize" then
                    SpoofedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-50, 50), math.random(0, 50), math.random(-50, 50))
                elseif headshots.Desync.Mode == "Void" then
                    SpoofedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-80000, 80000), math.random(0, 80000), math.random(-80000, 80000))
                end
        
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SpoofedPosition
        
                if headshots.Desync.Visualize then
                    SetRigCollisionFalse(clone)
                    SetRigTransparency(clone, headshots.Desync.Transparency)
                    clone.HumanoidRootPart.CFrame = SpoofedPosition
                else
                    SetRigTransparency(clone, 1)
                end
        
                game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                    game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                end)
            elseif headshots.Desync.Spam == true then
                if invoid == true then
                    SavedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                    SpoofedPosition = nil
            
                    if headshots.Desync.Mode == "Custom" then
                        local randomPitch = math.rad(math.random(_G.Desync.MinPitch, _G.Desync.MaxPitch) - 180)
                        local randomYaw = math.rad(math.random(_G.Desync.MinYaw, _G.Desync.MaxYaw) - 180)
                        local rotation = CFrame.Angles(randomPitch, randomYaw, 0)
                        SpoofedPosition = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-_G.Desync.MinX, _G.Desync.MaxX), math.random(-_G.Desync.MinY, _G.Desync.MaxY), math.random(-_G.Desync.MinZ, _G.Desync.MaxZ))) * rotation
                    elseif headshots.Desync.Mode == "Randomize" then
                        SpoofedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-50, 50), math.random(0, 50), math.random(-50, 50))
                    elseif headshots.Desync.Mode == "Void" then
                        SpoofedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-80000, 80000), math.random(0, 80000), math.random(-80000, 80000))
                    end
            
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SpoofedPosition
            
                    if headshots.Desync.Visualize then
                        SetRigCollisionFalse(clone)
                        SetRigTransparency(clone, headshots.Desync.Transparency)
                        clone.HumanoidRootPart.CFrame = SpoofedPosition
                    else
                        SetRigTransparency(clone, 1)
                    end
            
                    game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                        game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                    end)
                else
                    SetRigTransparency(clone, 1)
                end
            end
        else
            SetRigTransparency(clone, 1)
        end
    end)
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)

    SavedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame

    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-50, 50), math.random(0, 50), math.random(-50, 50))
        
    game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
        game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
    end)
end)

task.spawn(function()
    while true do
        invoid = true
        task.wait(headshots.Desync.InVoid)
        invoid = false
        task.wait(headshots.Desync.OnGround)
    end
end)

local function IsPlayerVisible(targetCharacter)
    local head = targetCharacter:FindFirstChild("Head")
    if not head then return false end

    if head.Position.Y > 36 then
        return false
    end

    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (head.Position - origin)
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}

    local result = workspace:Raycast(origin, direction, rayParams)

    if result then
        return result.Instance:IsDescendantOf(targetCharacter)
    else
        return true
    end
end

-- Good Target Aim ( 90%+ UNC Method )

if getnamecallmethod then
    local Meta = getrawmetatable(game)
    local backupindex = Meta.__index
    setreadonly(Meta, false)
    local Handler = game:FindService("ReplicatedStorage").MainModule
    local Module = require(Handler)
    if workspace:FindFirstChild("Vehicles") then
        Module.Ignored = {workspace:WaitForChild("Vehicles"), workspace:WaitForChild("MAP"), workspace:WaitForChild("Ignored")}
    end

    Meta.__index = function(t, k)
        if k:lower() == "hit" then
            if headshots.TargetAim.Enabled and headshots.TargetAim.CSync == false and headshots.TargetAim.Target ~= "None" and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
                local TargetPlayer = players:FindFirstChild(headshots.TargetAim.Target)
                if TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") and not TargetPlayer.Character:FindFirstChild("ForceField") then
                    if not KnockCheck(TargetPlayer) then
                        return TargetPlayer.Character.Head.CFrame
                    end
                end
            end
        end
        return backupindex(t, k)
    end
end

-- Hood Customs Forcehit

if getnamecallmethod and game.GameId == 9825515356 then
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
    
        if method == "FireServer" and self.Name == "MainEvent" and args[1] == "Shoot" then

            if headshots.TargetAim.Enabled and headshots.TargetAim.AutoFire and headshots.TargetAim.Target ~= "None" and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
                local TargetPlayer = players:FindFirstChild(headshots.TargetAim.Target)
                if TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") and not TargetPlayer.Character:FindFirstChild("ForceField") then
                    if not KnockCheck(TargetPlayer) then
                        local TargetPart = TargetPlayer.Character.Head
                        if TargetPart and args[2] then
                            for _, info in pairs(args[2][1]) do
                                info["Instance"] = TargetPart
                            end
                            for _, info in pairs(args[2][2]) do
                                info["thePart"] = TargetPart
                                info["theOffset"] = CFrame.new()
                            end
                            return OldNamecall(self, unpack(args))
                        end
                    end
                end
            end
        end
    
        return OldNamecall(self, ...)
    end)
end

-- // Target Strafe
local strafeclone = CreateR6Rig()

for _, part in ipairs(strafeclone:GetDescendants()) do
    if part:IsA("Part") then
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(80, 120, 200)
    end
end

local pingvalue = nil
local split = nil
local ping = nil
local PredictionValue = nil

local GlobalPredictionMultiplier = 0.80

local basePredictionTable = {
    {ping = 130, value = 0.51},
    {ping = 125, value = 0.49},
    {ping = 110, value = 0.46},
    {ping = 105, value = 0.38},
    {ping = 90,  value = 0.36},
    {ping = 80,  value = 0.34},
    {ping = 70,  value = 0.31},
    {ping = 60,  value = 0.229},
    {ping = 50,  value = 0.225},
    {ping = 40,  value = 0.256}
}

local previousPositions = {}
local customVelocities = {}

game:GetService("RunService").Stepped:Connect(function()
    pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    split = string.split(pingvalue, '(')
    ping = tonumber(split[1])

    for _, data in ipairs(basePredictionTable) do
        if ping < data.ping then
            PredictionValue = data.value * GlobalPredictionMultiplier
            break
        end
    end
end)

local t = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
    local TargetPlayer = players:FindFirstChild(headshots.TargetAim.Target)
    if headshots.TargetAim.Enabled and headshots.TargetAim.Strafe and headshots.TargetAim.Target ~= "None" and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
        local Tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") and Tool then
            if not TargetPlayer.Character:FindFirstChild("ForceField") or Tool.Name == "[Rifle]" then
                if not KnockCheck(TargetPlayer) and localPlayer.Character and localPlayer.Character.BodyEffects and localPlayer.Character.BodyEffects.Reload.Value == false then

                    if headshots.TargetAim.VoidResolver then
                        if (TargetPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 0, 0)).Magnitude > 5000 then
                            return
                        end
                    end
    
                    local SavedPosition = localPlayer.Character.HumanoidRootPart.CFrame
                    local SpoofedPosition = nil
                    local currentPosition = TargetPlayer.Character.Head.Position
                    local lastPosition = previousPositions[TargetPlayer] or currentPosition
                    local estimatedVelocity = (currentPosition - lastPosition) / dt
                    local alpha = 0.5
    
                    customVelocities[TargetPlayer] = (customVelocities[TargetPlayer] or Vector3.zero) * alpha + estimatedVelocity * (1 - alpha)
                    previousPositions[TargetPlayer] = currentPosition
    
                    if headshots.TargetAim.StrafeMethod == "Orbit" then
                        SpoofedPosition = CFrame.lookAt(currentPosition + (customVelocities[TargetPlayer] * PredictionValue) + Vector3.new(math.cos(tick()*10)*10, 0, math.sin(tick()*10)*10), currentPosition)
                    elseif headshots.TargetAim.StrafeMethod == "Randomize" then
                        SpoofedPosition = CFrame.lookAt(currentPosition + (customVelocities[TargetPlayer] * PredictionValue) + Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15)), currentPosition)
                    end
    
                    localPlayer.Character.HumanoidRootPart.CFrame = SpoofedPosition
    
                    if headshots.TargetAim.VisualizeStrafe then
                        SetRigCollisionFalse(strafeclone)
                        SetRigTransparency(strafeclone, 0)
                        SetRigColor(strafeclone, headshots.TargetAim.VisualizeStrafeColor)
                        strafeclone.HumanoidRootPart.CFrame = SpoofedPosition
                    else
                        SetRigTransparency(strafeclone, 1)
                    end

                    local PredictedAimingPosition = currentPosition + (customVelocities[TargetPlayer] * PredictionValue)

                    local args = {
                        [1] = "ShootGun",
                        [2] = Tool.Handle,
                        [3] = Tool.Handle.Position,
                        [4] = PredictedAimingPosition,
                        [5] = TargetPlayer.Character.Head,
                        [6] = Vector3.new(0, 0, 0)
                    }

                    if headshots.TargetAim.AutoFire then
                        MainEvent:FireServer(unpack(args))
                    else
                        if M1Down then
                            MainEvent:FireServer(unpack(args))
                        end
                    end
    
                    if headshots.TargetAim.CSync then
                        game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                            localPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                            game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                        end)
                    end
                elseif KnockCheck(TargetPlayer) and headshots.TargetAim.AutoStomp and localPlayer.Character.BodyEffects.Reload.Value == false then
                    local bodyEffects = TargetPlayer.Character:FindFirstChild("BodyEffects")
                    local isDead = bodyEffects and bodyEffects:FindFirstChild("SDeath") and bodyEffects.SDeath.Value
                    if isDead == false then
                        SavedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
        
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TargetPlayer.Character.UpperTorso.Position + Vector3.new(0, 3, 0))

                        if headshots.TargetAim.VisualizeStrafe then
                            SetRigCollisionFalse(strafeclone)
                            SetRigTransparency(strafeclone, 0)
                            SetRigColor(strafeclone, headshots.TargetAim.VisualizeStrafeColor)
                            strafeclone.HumanoidRootPart.CFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                        else
                            SetRigTransparency(strafeclone, 1)
                        end
        
                        if headshots.HitEffects.HitNotifications then
                            if tick() - t >= 3 then
                                t = tick()
                                library:notification({ text = "headshots.cc - Attempted to Stomp Target: " .. TargetPlayer.Name, time = headshots.HitEffects.HitNotificationsTime })
                            end
                        end
            
                        MainEvent:FireServer("Stomp")
                    
                        game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                            game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                        end)
                    else
                        SetRigTransparency(strafeclone, 1)
                    end
                else
                    SetRigTransparency(strafeclone, 1)
                end
            else
                SetRigTransparency(strafeclone, 1)
            end
        else
            SetRigTransparency(strafeclone, 1)
        end
    else
        SetRigTransparency(strafeclone, 1)
    end
end)

local tracerOutline = Drawing.new("Line")
tracerOutline.Visible = false
tracerOutline.Color = headshots.TargetAim.TracerOutlineColor
tracerOutline.Thickness = 4

local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Color = headshots.TargetAim.TracerFillColor
tracer.Thickness = 2

game:GetService("RunService").Heartbeat:Connect(function(dt)
    
    -- Target Aim
    if headshots.TargetAim.Enabled and headshots.TargetAim.Target ~= "None" and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
        local TargetPlayer = players:FindFirstChild(headshots.TargetAim.Target)
        if TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") and not KnockCheck(TargetPlayer) then
            local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and TargetPlayer.Character and (not TargetPlayer.Character:FindFirstChild("ForceField") or tool.Name == "[Rifle]") then

                local distance = (TargetPlayer.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local Tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
    
                if Tool then
                    if headshots.TargetAim.AutoFire then
                        if game.PlaceId == 9825515356 then
                            local args = {
                                "Shoot",
                                {
                                    {
                                        [1] = {
                                            ["Instance"] = TargetPlayer.Character.Head,
                                            ["Normal"] = Vector3.new(0.9937344193458557, 0.10944880545139313, -0.022651424631476402),
                                            ["Position"] = Vector3.new(-141.78562927246094, 33.89368438720703, -365.6424865722656)
                                        },
                                        [2] = {
                                            ["Instance"] = TargetPlayer.Character.Head,
                                            ["Normal"] = Vector3.new(0.9937344193458557, 0.10944880545139313, -0.022651424631476402),
                                            ["Position"] = Vector3.new(-141.78562927246094, 33.89368438720703, -365.6424865722656)
                                        },
                                        [3] = {
                                            ["Instance"] = TargetPlayer.Character.Head,
                                            ["Normal"] = Vector3.new(0.9937343597412109, 0.10944879800081253, -0.022651422768831253),
                                            ["Position"] = TargetPlayer.Character.Head.Position 
                                        },
                                        [4] = {
                                            ["Instance"] = TargetPlayer.Character.Head,
                                            ["Normal"] = Vector3.new(0.9937344193458557, 0.10944880545139313, -0.022651424631476402),
                                            ["Position"] = TargetPlayer.Character.Head.Position 
                                        },
                                        [5] = {
                                            ["Instance"] = TargetPlayer.Character.Head,
                                            ["Normal"] = Vector3.new(0.9937344193458557, 0.10944880545139313, -0.022651424631476402),
                                            ["Position"] = Vector3.new(-141.79481506347656, 34.033607482910156, -365.369384765625)
                                        }
                                    },
                                    {
                                        [1] = {
                                            ["thePart"] = TargetPlayer.Character.Head,
                                            ["theOffset"] = CFrame.new(0, 0, 0)
                                        },
                                        [2] = {
                                            ["thePart"] = TargetPlayer.Character.Head,
                                            ["theOffset"] = CFrame.new(0, 0, 0)
                                        },
                                        [3] = {
                                            ["thePart"] = TargetPlayer.Character.Head,
                                            ["theOffset"] = CFrame.new(0, 0, 0)
                                        },
                                        [4] = {
                                            ["thePart"] = TargetPlayer.Character.Head,
                                            ["theOffset"] = CFrame.new(0, 0, 0)
                                        },
                                        [5] = {
                                            ["thePart"] = TargetPlayer.Character.Head,
                                            ["theOffset"] = CFrame.new(0, 0, 0)
                                        }
                                    },
                                    game.Players.LocalPlayer.Character.Head.Position,
                                    game.Players.LocalPlayer.Character.Head.Position,
                                    workspace:GetServerTimeNow()
                                }
                            }
                            MainEvent:FireServer(unpack(args))
                        else
                            if headshots.TargetAim.CSync == false then
                                local args = {
                                    [1] = "ShootGun",
                                    [2] = Tool.Handle,
                                    [3] = Tool.Handle.Position,
                                    [4] = TargetPlayer.Character.Head.Position,
                                    [5] = TargetPlayer.Character.Head,
                                    [6] = Vector3.new(0, 0, 0)
                                }
                                
                                MainEvent:FireServer(unpack(args))
                            end
                        end
                    else
                        -- Shitty Target Aim ( 90%- UNC Method )
                        if M1Down then
                            if not getnamecallmethod and headshots.TargetAim.CSync == false then
                                local args = {
                                    [1] = "ShootGun",
                                    [2] = Tool.Handle,
                                    [3] = Tool.Handle.Position,
                                    [4] = TargetPlayer.Character.Head.Position,
                                    [5] = TargetPlayer.Character.Head,
                                    [6] = Vector3.new(0, 0, 0)
                                }
                                  
                                MainEvent:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
        elseif KnockCheck(TargetPlayer) and headshots.TargetAim.AutoStomp and localPlayer.Character.BodyEffects.Reload.Value == false and headshots.TargetAim.Strafe == false then
            local bodyEffects = TargetPlayer.Character:FindFirstChild("BodyEffects")
            local isDead = bodyEffects and bodyEffects:FindFirstChild("SDeath") and bodyEffects.SDeath.Value
            if isDead == false then
                SavedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame

                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TargetPlayer.Character.UpperTorso.Position + Vector3.new(0, 3, 0))

                if headshots.HitEffects.HitNotifications then
                    if tick() - t >= 3 then
                        t = tick()
                        library:notification({ text = "headshots.cc - Attempted to Stomp Target: " .. TargetPlayer.Name, time = headshots.HitEffects.HitNotificationsTime })
                    end
                end
    
                MainEvent:FireServer("Stomp")
            
                game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                    game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                end)
            end
        end

        if headshots.TargetAim.Highlight then
            if TargetPlayer.Character:FindFirstChild("Highlight") then
                TargetPlayer.Character.Highlight.FillColor = headshots.TargetAim.HighlightFillColor
                TargetPlayer.Character.Highlight.OutlineColor = headshots.TargetAim.HighlightOutlineColor
            else
                local Highlight = Instance.new("Highlight")
                Highlight.Parent = TargetPlayer.Character
            end
        end

        if headshots.TargetAim.LookAt then
            localPlayer.Character.Humanoid.AutoRotate = false
            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(localPlayer.Character.HumanoidRootPart.Position, Vector3.new(TargetPlayer.Character.HumanoidRootPart.Position.X, localPlayer.Character.HumanoidRootPart.Position.Y, TargetPlayer.Character.HumanoidRootPart.Position.Z))
        else
            localPlayer.Character.Humanoid.AutoRotate = true
        end

        if headshots.TargetAim.Tracer then
            local mouseScreenPosition = UserInputService:GetMouseLocation()
        
            local head = TargetPlayer.Character:FindFirstChild("Head")
            local humanoidRootPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        
            if head and humanoidRootPart then
                local humanoidRootPart_Position = humanoidRootPart.CFrame
                local humanoidRootPart_Size = humanoidRootPart.Size
        
                local adjustedPosition = humanoidRootPart_Position * CFrame.new(0, -humanoidRootPart_Size.Y, 0).p
        
                local headScreenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
        
                if onScreen then
                    local adjustedMousePosition = Vector2.new(mouseScreenPosition.X, mouseScreenPosition.Y)
        
                    local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
                    if headshots.TargetAim.TracerPosition == "Tool" and tool and tool:FindFirstChild("Handle") then
                        local pos = workspace.CurrentCamera:WorldToViewportPoint(tool.Handle.Position)
                        tracer.From = Vector2.new(pos.X, pos.Y)
                        tracerOutline.From = Vector2.new(pos.X, pos.Y)
                    else
                        tracer.From = adjustedMousePosition
                        tracerOutline.From = adjustedMousePosition
                    end           

                    tracer.To = Vector2.new(headScreenPosition.X, headScreenPosition.Y)
                    tracerOutline.To = Vector2.new(headScreenPosition.X, headScreenPosition.Y)
        
                    tracerOutline.Visible = true
                    tracer.Visible = true
        
                    tracerOutline.Color = headshots.TargetAim.TracerOutlineColor
                    tracer.Color = headshots.TargetAim.TracerFillColor
                else
                    tracer.Visible = false
                    tracerOutline.Visible = false
                end
            end
        end
    else
        localPlayer.Character.Humanoid.AutoRotate = true
    end
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if headshots.KillAura.StompAura and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and KnockCheck(player) and not player.Character:FindFirstChild("ForceField") then
                local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= headshots.KillAura.Distance and distance < shortestDistance then
                    local bodyEffects = player.Character:FindFirstChild("BodyEffects")
                    local isDead = bodyEffects and bodyEffects:FindFirstChild("SDeath") and bodyEffects.SDeath.Value
                    if isDead == false then
                        if player.Character:FindFirstChild("UpperTorso") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                            SavedPosition = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame

                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.UpperTorso.Position + Vector3.new(0, 3, 0))

                            MainEvent:FireServer("Stomp")
                        
                            game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                                game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                            end)

                        end
                    end
                end
            end
        end
    end
end)

-- // Hit Sounds
local function createHitSound()
    local sound = Instance.new("Sound")
    sound.Parent = localPlayer.Character.HumanoidRootPart
    sound.SoundId = headshots.HitEffects.HitSoundID
    sound.Volume = headshots.HitEffects.HitSoundVolume

    sound:Play()

    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local lastHealth = nil

game:GetService("RunService").Heartbeat:Connect(function(dt)
    
    if headshots.TargetAim.Enabled and headshots.TargetAim.Target ~= "None" then
        local TargetPlayer = players:FindFirstChild(headshots.TargetAim.Target)
        
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") and TargetPlayer.Character:FindFirstChild("Head") and not TargetPlayer.Character:FindFirstChild("ForceField") then
            local humanoid = TargetPlayer.Character:FindFirstChild("Humanoid")
            
            if humanoid then
                local currentHealth = math.round(humanoid.Health)
                
                if lastHealth == nil or headshots.TargetAim.Target ~= lastTarget then
                    lastHealth = currentHealth
                end

                if currentHealth < lastHealth then
                    if headshots.HitEffects.HitNotifications then
                        library:notification({ text = "headshots.cc - Target Hit: " .. TargetPlayer.Name .. " - Health: " .. currentHealth, time = headshots.HitEffects.HitNotificationsTime })
                    end

                    if headshots.HitEffects.HitSounds then
                        createHitSound()
                    end
                end

                lastHealth = currentHealth
                lastTarget = headshots.TargetAim.Target
            end
        end
    end
end)

-- // World Modifications
local LightingModifications = false

local SelectedSkybox = "Black Storm"

local LightingSettings = {
    DefaultAmbient = lighting.Ambient,
    DefaultOutdoorAmbient = lighting.OutdoorAmbient,
    DefaultExposureCompensation = lighting.ExposureCompensation,
    DefaultFogStart = lighting.FogStart,
    DefaultFogEnd = lighting.FogEnd,
    DefaultFogColor = lighting.FogColor,
    DefaultBrightness = lighting.Brightness,
    DefaultClockTime = lighting.ClockTime,

    DefaultSkyboxBk = lighting.Sky.SkyboxBk,
    DefaultSkyboxDn = lighting.Sky.SkyboxDn,
    DefaultSkyboxFt = lighting.Sky.SkyboxFt,
    DefaultSkyboxLf = lighting.Sky.SkyboxLf,
    DefaultSkyboxRt = lighting.Sky.SkyboxRt,
    DefaultSkyboxUp = lighting.Sky.SkyboxUp,
    
    CustomAmbient = Color3.new(0, 0, 0),
    CustomOutdoorAmbient = Color3.new(80, 120, 200),
    CustomExposureCompensation = 0,
    CustomFogStart = 0,
    CustomFogEnd = 1000,
    CustomFogColor = Color3.new(80, 120, 200),
    CustomBrightness = 0,
    CustomClockTime = 0,
}

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if LightingModifications and game:FindFirstChild("Lighting") then
        lighting.Ambient = LightingSettings.CustomAmbient
        lighting.OutdoorAmbient = LightingSettings.CustomOutdoorAmbient
        lighting.ExposureCompensation = LightingSettings.ExposureCompensation
        lighting.FogStart = LightingSettings.CustomFogStart
        lighting.FogEnd = LightingSettings.CustomFogEnd
        lighting.FogColor = LightingSettings.CustomFogColor
        lighting.Brightness = LightingSettings.CustomBrightness
        lighting.ClockTime = LightingSettings.CustomClockTime
    end
end)

-- // Bullet Tracers
local function bullettracerlol(startPos, endPos)
    local startPart = Instance.new("Part")
    startPart.Name = "BulletStart"
    startPart.Anchored = true
    startPart.CanCollide = false
    startPart.Transparency = 1
    startPart.Size = Vector3.new(0.2, 0.2, 0.2)
    startPart.Material = Enum.Material.ForceField
    startPart.Color = Color3.new(1, 0, 0)
    startPart.Transparency = 1
    startPart.CanTouch = false
    startPart.CanQuery = false
    startPart.Massless = true
    startPart.CollisionGroupId = 0
    startPart.Position = startPos
    startPart.Parent = Workspace

    local endPart = Instance.new("Part")
    endPart.Name = "BulletEnd"
    endPart.Anchored = true
    endPart.CanCollide = false
    endPart.Size = Vector3.new(0.2, 0.2, 0.2)
    endPart.Material = Enum.Material.ForceField
    endPart.Color = Color3.new(1, 0, 0)
    endPart.Transparency = 1
    endPart.CanTouch = false
    endPart.CanQuery = false
    endPart.Massless = true
    endPart.CollisionGroupId = 0
    endPart.Position = endPos
    endPart.Parent = Workspace

    local beam = Instance.new("Beam")
    beam.Attachment0 = Instance.new("Attachment", startPart)
    beam.Attachment1 = Instance.new("Attachment", endPart)
    beam.Parent = startPart
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(headshots.BulletTracers.Color)
    beam.Texture = headshots.BulletTracers.TextureID
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(headshots.BulletTracers.Transparency)
    beam.Width0 = headshots.BulletTracers.Size
    beam.Width1 = headshots.BulletTracers.Size

    task.delay(headshots.BulletTracers.TimeAlive, function()
        if beam and beam.Parent then
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(beam, tweenInfo, { Width0 = 0, Width1 = 0 })
            tween:Play()
            
            tween.Completed:Wait()
        end

        if startPart and startPart.Parent then startPart:Destroy() end
        if endPart and endPart.Parent then endPart:Destroy() end
        if beam and beam.Parent then beam:Destroy() end
    end)

    return startPart, endPart, beam
end

-- // Rapid Fire
if getnamecallmethod then
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
        if headshots.RapidFire.Enabled and tool and tool:FindFirstChild("GunScript") then 
            for _, v in ipairs(getconnections(tool.Activated)) do
                local funcinfo = debug.getinfo(v.Function)
                for i = 1, funcinfo.nups do
                    local c, n = debug.getupvalue(v.Function, i)
                    if type(c) == "number" then 
                        debug.setupvalue(v.Function, i, 0.00000000000000000001)
                    end
                end
            end
        end
    end)
end

if getnamecallmethod and MainEvent ~= nil then
    local mt = getrawmetatable(MainEvent)
    setreadonly(mt, false)
            
    local cloned_mt = table.clone(mt)
    
    local oldnamecall = cloned_mt.__namecall
    
    setrawmetatable(MainEvent, {
        __namecall = (function(self, ...)
            local args = { ... }
            if getnamecallmethod() == "FireServer" then
                if args[1] == "ShootGun" then
    
                    -- Bullet Tracers
                    if headshots.BulletTracers.Enabled then
                        bullettracerlol(args[3], args[4])
                    end

                    -- Hit Effects etc. Adding Later..
    
                end
            end
    
            return oldnamecall(self, unpack(args))
        end),
    
        __index = cloned_mt.__index,
        __newindex = cloned_mt.__newindex,
        __call = cloned_mt.__call,
        __tostring = cloned_mt.__tostring,
    })
end

-- // SelfVisuals
local originalCharacterColors = {}
local originalToolColors = {}

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if game.Players.LocalPlayer.Character then
        local char = game.Players.LocalPlayer.Character

        if headshots.SelfVisuals.Character then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    if not originalCharacterColors[part] then
                        originalCharacterColors[part] = part.Color
                    end

                    part.Material = Enum.Material[headshots.SelfVisuals.CharacterMaterial]
                    part.Color = headshots.SelfVisuals.CharacterColor
                end
            end
        end

        -- Tool Material
        if headshots.SelfVisuals.Tool then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, part in ipairs(tool:GetChildren()) do
                    if part:IsA("BasePart") then
                        if not originalToolColors[part] then
                            originalToolColors[part] = part.Color
                        end

                        part.Material = Enum.Material[headshots.SelfVisuals.ToolMaterial]
                        part.Color = headshots.SelfVisuals.ToolColor
                    end
                end
            end
        end

        -- Aura
        if headshots.SelfVisuals.Aura then

            if headshots.SelfVisuals.AuraTexture == "Pink Shyt" then
                if localPlayer.Character.HumanoidRootPart:FindFirstChild("bottom") then
                    for _, attachment in ipairs(localPlayer.Character.HumanoidRootPart:GetDescendants()) do
                        if attachment.Name == "bottom" or attachment.Name == "fog" then
                            for _, child in ipairs(attachment:GetDescendants()) do
                                if child:IsA("ParticleEmitter") then
                                    child.Color = ColorSequence.new(headshots.SelfVisuals.AuraColor)
                                    child.Enabled = true
                                end
                            end
                        end
                    end
                else
                    local NewAura = game:GetObjects(getcustomasset(library.directory .. "/assets/PinkShyt.rbxm"))[1]
                    for _, v in ipairs(NewAura:GetChildren()) do
                        v.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
                    end
                    NewAura:Destroy()
                end
            end

        else
            if localPlayer.Character.HumanoidRootPart:FindFirstChild("bottom") then
                for _, attachment in ipairs(localPlayer.Character.HumanoidRootPart:GetDescendants()) do
                    if attachment.Name == "bottom" or attachment.Name == "fog" then
                        for _, child in ipairs(attachment:GetDescendants()) do
                            if child:IsA("ParticleEmitter") then
                                child.Enabled = false
                            end
                        end
                    end
                end
            end
        end

        -- Walk Steps
        if headshots.SelfVisuals.WalkSteps then

            if localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps") then
                localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps").Indicator.Color = ColorSequence.new(headshots.SelfVisuals.WalkStepsColor)
                localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps").Indicator.Rate = headshots.SelfVisuals.WalkStepsRate
                localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps").Indicator.Size = headshots.SelfVisuals.WalkStepsSize
                localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps").Indicator.Enabled = true
            else
                local NewAura = game:GetObjects(getcustomasset(library.directory .. "/assets/WalkSteps.rbxm"))[1]
                for _, v in ipairs(NewAura:GetChildren()) do
                    v.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
                end
                NewAura:Destroy()
            end

        else
            if localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps") then
                localPlayer.Character.HumanoidRootPart:FindFirstChild("Walksteps").Indicator.Enabled = false
            end
        end

    end
end)

function ResetCharacterColors()
    local char = game.Players.LocalPlayer.Character
    if char then
        for part, originalColor in pairs(originalCharacterColors) do
            if part and part:IsA("BasePart") then
                part.Color = originalColor
            end
        end
        originalCharacterColors = {}
    end
end

function ResetToolColors()
    local char = game.Players.LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for part, originalColor in pairs(originalToolColors) do
                if part and part:IsA("BasePart") then
                    part.Color = originalColor
                end
            end
        end
        originalToolColors = {}
    end
end

local SavedPosition = localPlayer.Character.HumanoidRootPart.CFrame

-- // Anti Stomp
game:GetService("RunService").Heartbeat:Connect(function(dt)

    if headshots.AntiStomp.Enabled then
        if game.Players.LocalPlayer.Character.Humanoid.Health <= 5 then
            if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Parent = game.Players.LocalPlayer.Backpack
            end

            for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if v:IsA('MeshPart') or v:IsA('Part') then
                    v:Destroy()
                end
            end
            for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if v:IsA('Accessory') then
                    v.Handle:Destroy()
                end
            end
        end
    end
    
end)

-- // AUTOBUYER2000 $$$$$$$$$$$$$$$$$$$

local SelectedGun = '[Rifle]'

local BuyingSingle = false
local BuyingAmmo = false

local ShopTable = {
    ["[Rifle]"] = {ShopName = "[Rifle] - $1694"},
    ["[Rifle Ammo]"] = {ShopName = "5 [Rifle Ammo] - $273"},
    ["[LMG]"] = {ShopName = "[LMG] - $4098"},
    ["[LMG Ammo]"] = {ShopName = "200 [LMG Ammo] - $328"},
    ["[AK47]"] = {ShopName = "[AK47] - $2459"},
    ["[AK47 Ammo]"] = {ShopName = "90 [AK47 Ammo] - $87"},
    ["[AUG]"] = {ShopName = "[AUG] - $2131"},
    ["[AUG Ammo]"] = {ShopName = "90 [AUG Ammo] - $87"},
    ["[AR]"] = {ShopName = "[AR] - $1093"},
    ["[AR Ammo]"] = {ShopName = "60 [AR Ammo] - $82"},
    ["[Double-Barrel SG]"] = {ShopName = "[Double-Barrel SG] - $1475"},
    ["[Double-Barrel SG Ammo]"] = {ShopName = "18 [Double-Barrel SG Ammo] - $55"},
    ["[Drum-Shotgun]"] = {ShopName = "[Drum-Shotgun] - $1202"},
    ["[Drum-Shotgun Ammo]"] = {ShopName = "18 [Drum-Shotgun Ammo] - $71"},
    ["[DrumGun]"] = {ShopName = "[DrumGun] - $3278"},
    ["[DrumGun Ammo]"] = {ShopName = "100 [DrumGun Ammo] - $219"},
    ["[Fire Armor]"] = {ShopName = "[Fire Armor] - $2623"},
    ["[Glock]"] = {ShopName = "[Glock] - $546"},
    ["[Glock Ammo]"] = {ShopName = "25 [Glock Ammo] - $66"},
    ["[P90]"] = {ShopName = "[P90] - $1093"},
    ["[P90 Ammo]"] = {ShopName = "120 [P90 Ammo] - $66"},
    ["[RPG]"] = {ShopName = "[RPG] - $21855"},
    ["[RPG Ammo]"] = {ShopName = "5 [RPG Ammo] - $1093"},
    ["[Revolver]"] = {ShopName = "[Revolver] - $1421"},
    ["[Revolver Ammo]"] = {ShopName = "12 [Revolver Ammo] - $82"},
    ["[Silencer]"] = {ShopName = "[Silencer] - $601"},
    ["[Silencer Ammo]"] = {ShopName = "25 [Silencer Ammo] - $55"},
    ["[SilencerAR]"] = {ShopName = "[SilencerAR] - $1366"},
    ["[SilencerAR Ammo]"] = {ShopName = "120 [SilencerAR Ammo] - $82"},
    ["[Shotgun]"] = {ShopName = "[Shotgun] - $1366"},
    ["[Shotgun Ammo]"] = {ShopName = "20 [Shotgun Ammo] - $66"},
    ["[SMG]"] = {ShopName = "[SMG] - $820"},
    ["[SMG Ammo]"] = {ShopName = "80 [SMG Ammo] - $66"},
    ["[TacticalShotgun]"] = {ShopName = "[TacticalShotgun] - $1912"},
    ["[TacticalShotgun Ammo]"] = {ShopName = "20 [TacticalShotgun Ammo] - $66"},
    ["[Taser]"] = {ShopName = "[Taser] - $1093"},
    ["[Grenade]"] = {ShopName = "[Grenade] - $765"},
}

game:GetService('RunService').Heartbeat:Connect(function()
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart then
        pcall(function()
            -- Buy Single
            if BuyingSingle and not game.Players.LocalPlayer.Character:FindFirstChild(SelectedGun) and not game.Players.LocalPlayer.Backpack:FindFirstChild(SelectedGun) then
                if game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[SelectedGun].ShopName):FindFirstChild("Head") then
                    SavedPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[SelectedGun].ShopName).Head.CFrame
                    fireclickdetector(game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[SelectedGun].ShopName):FindFirstChildOfClass("ClickDetector"))
                    game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                        game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                    end)
                end
            else
                BuyingSingle = false
            end

            -- Buy Ammo
            if BuyingAmmo then
                local AmmoName = "[" .. SelectedGun:sub(2, -2) .. " Ammo]"
                if ShopTable[AmmoName] then
                    if game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[AmmoName].ShopName):FindFirstChild("Head") then
                        if game.Players.LocalPlayer.Character:FindFirstChild(SelectedGun) then
                            game.Players.LocalPlayer.Character:FindFirstChild(SelectedGun).Parent = game.Players.LocalPlayer.Backpack
                        end
                        SavedPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[AmmoName].ShopName).Head.CFrame
                        fireclickdetector(game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[AmmoName].ShopName):FindFirstChildOfClass("ClickDetector"))
                        game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                            game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                        end)
                    end
                end
            end

            -- Auto Loadout
            if headshots.AutoLoadout.Enabled and headshots.AutoLoadout.Gun and ShopTable[headshots.AutoLoadout.Gun] and game.Players.LocalPlayer.Character and not game.Players.LocalPlayer.Character:FindFirstChild(headshots.AutoLoadout.Gun) and not game.Players.LocalPlayer.Backpack:FindFirstChild(headshots.AutoLoadout.Gun) then
                local ShopItem = game.Workspace.Ignored.Shop:FindFirstChild(ShopTable[headshots.AutoLoadout.Gun].ShopName)
                if ShopItem and ShopItem:FindFirstChild("Head") then
                    SavedPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = ShopItem.Head.CFrame
                    fireclickdetector(ShopItem:FindFirstChildOfClass("ClickDetector"))
                    game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                        game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                    end)
                else
                    print("Shop item not found for", headshots.AutoLoadout.Gun)
                end

            -- Auto Armor
            elseif headshots.AutoArmor.Enabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.BodyEffects and game.Players.LocalPlayer.Character.BodyEffects.Armor and game.Players.LocalPlayer.Character.BodyEffects.Armor.Value < 100 then
                SavedPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop:FindFirstChild('[High-Medium Armor] - $2513').Head.CFrame
                fireclickdetector(game.Workspace.Ignored.Shop:FindFirstChild('[High-Medium Armor] - $2513'):FindFirstChildOfClass("ClickDetector"))
                game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                    game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                end)
            end
        end)

    end
end)

-- // Hitbox Expander //

local RS = cloneref(game:GetService("RunService"))
local Client = Players.LocalPlayer
local highlights = {}

RS.RenderStepped:Connect(function()
    if headshots.HitboxExpander.Enabled then
        for _, Player in pairs(Players:GetPlayers()) do
            if Player == Client then continue end
            local HRP = Player.Character:WaitForChild("HumanoidRootPart")

            HRP.Size = Vector3.new(headshots.HitboxExpander.Size, headshots.HitboxExpander.Size, headshots.HitboxExpander.Size)
            HRP.CanCollide = false

            if headshots.HitboxExpander.Visualize then
                if not highlights[Player] then
                    local Visualize = Instance.new("Highlight")
                    HRP.Transparency = 0.9
                    Visualize.Parent = HRP
                    Visualize.FillColor = headshots.HitboxExpander.Color
                    Visualize.OutlineColor = headshots.HitboxExpander.OutlineColor
                    Visualize.FillTransparency = headshots.HitboxExpander.FillTransparency
                    Visualize.OutlineTransparency = headshots.HitboxExpander.OutlineTransparency
                    highlights[Player] = Visualize
                else
                    local Visualize = highlights[Player]
                    HRP.Transparency = 0.9
                    Visualize.FillColor = headshots.HitboxExpander.Color
                    Visualize.OutlineColor = headshots.HitboxExpander.OutlineColor
                    Visualize.FillTransparency = headshots.HitboxExpander.FillTransparency
                    Visualize.OutlineTransparency = headshots.HitboxExpander.OutlineTransparency
                end
            else
                local Visualize = highlights[Player]
                if Visualize then
                    Visualize:Destroy()
                    HRP.Transparency = 1
                    highlights[Player] = nil
                end
            end
        end
    end
end)

-- // Auto Kill Target

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if headshots.Target.AutoKill then
        if headshots.Target.Target ~= nil then
            local Target = game.Players:FindFirstChild(headshots.Target.Target)
            
            if Target and Target.Character and localPlayer and localPlayer.Character then
                local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                local head = localPlayer.Character:FindFirstChild("Head")
                local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
                local toolHandle = tool and tool:FindFirstChild("Handle")
                local targetHRP = Target.Character:FindFirstChild("HumanoidRootPart")
                local targetHead = Target.Character:FindFirstChild("Head")

                local SavedPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

                if humanoidRootPart and head and toolHandle and targetHRP and targetHead then
                    if not KnockCheck(Target) then
                        if not Target.Character:FindFirstChild("ForceField") or tool.Name == "[Rifle]" then
            
                            -- Kill Target
                            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Target.Character.Head.Position + Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15)), Target.Character.Head.Position)
                            library:notification({ text = "headshots.cc - Shooting Target.", time = 1 })
                            MainEvent:FireServer("ShootGun", toolHandle, toolHandle.Position, Target.Character.Head.Position, targetHead, Vector3.new(0, 1, 0))
                        else
                            -- Spawn Protection
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(math.random(-80000,80000), math.random(0,80000), math.random(-80000,80000))
                            library:notification({ text = "headshots.cc - Waiting.. Target has spawn protection.", time = 1 })
                            MainEvent:FireServer("Reload", tool)
                        end

                        if headshots.Target.AutoKillDesync then
                            game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                                game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                            end)
                        end
                    else
                        -- Handle dead targets
                        local bodyEffects = Target.Character:FindFirstChild("BodyEffects")
                        local isDead = bodyEffects and bodyEffects:FindFirstChild("SDeath") and bodyEffects.SDeath.Value
                        if isDead == false then
                            if Target.Character:FindFirstChild("UpperTorso") and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
                                humanoidRootPart.CFrame = CFrame.new(Target.Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                                library:notification({ text = "headshots.cc - Stomping Target.", time = 1 })
                                MainEvent:FireServer("Stomp")
                            end
                        elseif isDead == true then
                            -- Move to safe position when target is dead
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(math.random(-80000,80000), math.random(0,80000), math.random(-80000,80000))
                            library:notification({ text = "headshots.cc - Waiting.. Target is currently dead.", time = 1 })
                            MainEvent:FireServer("Reload", tool)
                        end

                        if headshots.Target.AutoKillDesync then
                            game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                                game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                            end)
                        end

                    end
                else
                    -- If gun is not equipped
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(math.random(-80000,80000), math.random(0,80000), math.random(-80000,80000))
                    library:notification({ text = "headshots.cc - Waiting.. Equip your gun while using 'Auto Kill Target'.", time = 1 })

                    if headshots.Target.AutoKillDesync then
                        game:GetService("RunService"):BindToRenderStep("RestoreCFrame", 199, function()
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
                            game:GetService("RunService"):UnbindFromRenderStep("RestoreCFrame")
                        end)
                    end
                end
            end
        else
            -- If no target is found
            local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(0, 500, 0)
            end
            library:notification({ text = "headshots.cc - Target not found.", time = 3 })
        end
    end
end)

-- // Creating the UI Library Buttons //

local window = library:window({
    name = os.date("headshots.cc - %b %d %Y"),
    size = dim2(0, 614, 0, 639)
})

local watermark = library:watermark({
    default = os.date("headshots.cc - %b %d %Y - %H:%M:%S")
})

-- // Creating Tabs // --

local Combat = window:tab({name = "combat"})
local Visuals = window:tab({name = "visuals"})
local Misc = window:tab({name = "misc"})
local PlayersTab = window:tab({name = "players"})
local Settings = window:tab({name = "settings"})

-- // Combat // --

local column = Combat:column()

local section = column:section({name = "target aim"})

section:toggle({name = "enabled", flag = "targetaim_enabled", callback = function(Value)
    headshots.TargetAim.Enabled = Value
end}):keybind({name = "target aim", flag = "targetaim_bind", callback = function(Value)
    if headshots.TargetAim.Enabled then
        if Value == false then
            headshots.TargetAim.Target = "None"
            if headshots.TargetAim.Highlight then
                for _, player in ipairs(game:GetService("Players"):GetChildren()) do
                    if player.Character then
                        if player.Character:FindFirstChild("Highlight") and player.Character:FindFirstChild("Highlight").FillColor == headshots.TargetAim.HighlightFillColor then
                            if headshots.ExtraESP.HighlightEnabled == false then
                                player.Character:FindFirstChild("Highlight"):Destroy()
                            else
                                player.Character:FindFirstChild("Highlight").FillColor = headshots.ExtraESP.HighlightFillColor
                                player.Character:FindFirstChild("Highlight").OutlineColor = headshots.ExtraESP.HighlightOutlineColor
                            end
                        end
                    end
                end
            end

            tracer.Visible = false
            tracerOutline.Visible = false
        elseif Value == true then
            local target = GetClosestCharacter()
            if target then
                headshots.TargetAim.Target = target.Name
            else
                headshots.TargetAim.Target = "None"
                if headshots.TargetAim.Highlight then
                    for _, player in ipairs(game:GetService("Players"):GetChildren()) do
                        if player.Character then
                            if player.Character:FindFirstChild("Highlight") and player.Character:FindFirstChild("Highlight").FillColor == headshots.TargetAim.HighlightFillColor then
                                player.Character:FindFirstChild("Highlight"):Destroy()
                            end
                        end
                    end
                end
                tracer.Visible = false
                tracerOutline.Visible = false
            end
        end
    end
end})

local lastTarget = nil

section:toggle({
    name = "auto select",
    flag = "targetaim_autoselect",
    callback = function(Value)
        if Value then
            task.spawn(function()
                while flags["targetaim_autoselect"] do
                    local target = GetClosestCharacter()

                    if lastTarget and lastTarget ~= target and lastTarget.Character then
                        local highlight = lastTarget.Character:FindFirstChild("Highlight")
                        if highlight and headshots.ExtraESP.HighlightEnabled == false then
                            highlight:Destroy()
                        else
                            highlight.FillColor = headshots.ExtraESP.HighlightFillColor
                            highlight.OutlineColor = headshots.ExtraESP.HighlightOutlineColor
                        end
                        tracer.Visible = false
                        tracerOutline.Visible = false
                    end

                    if target then
                        headshots.TargetAim.Target = target.Name
                    else
                        headshots.TargetAim.Target = "None"
                    end

                    lastTarget = target
                    task.wait()
                end

                if lastTarget and lastTarget.Character then
                    local highlight = lastTarget.Character:FindFirstChild("Highlight")
                    if highlight and headshots.ExtraESP.HighlightEnabled == false then
                        highlight:Destroy()
                    else
                        highlight.FillColor = headshots.ExtraESP.HighlightFillColor
                        highlight.OutlineColor = headshots.ExtraESP.HighlightOutlineColor
                    end
                    tracer.Visible = false
                    tracerOutline.Visible = false
                end
                lastTarget = nil
            end)
        else
            for _, player in ipairs(game:GetService("Players"):GetChildren()) do
                if player.Character and player.Character:FindFirstChild("Highlight") and player.Character:FindFirstChild("Highlight").FillColor == headshots.TargetAim.HighlightFillColor then
                    player.Character.Highlight:Destroy()
                end
            end
            tracer.Visible = false
            tracerOutline.Visible = false
            lastTarget = nil
        end
    end
})


section:toggle({name = "auto fire", flag = "targetaim_autofire", callback = function(Value)
    headshots.TargetAim.AutoFire = Value
end})

section:toggle({name = "highlight", flag = "targetaim_highlight", callback = function(Value)
    headshots.TargetAim.Highlight = Value
    for _, player in ipairs(game:GetService("Players"):GetChildren()) do
        if player.Character and player.Character:FindFirstChild("Highlight") and player.Character:FindFirstChild("Highlight").FillColor == headshots.TargetAim.HighlightFillColor then
            player.Character.Highlight:Destroy()
        end
    end
end}):colorpicker({name = "main", flag = "highlightfill", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.TargetAim.HighlightFillColor = Value
end}):colorpicker({name = "outline", flag = "highlightoutline", color = rgb(129, 105, 145), callback = function(Value, alpha)
    headshots.TargetAim.HighlightOutlineColor = Value
end})

section:toggle({name = "tracer", flag = "targetaim_tracer", callback = function(Value)
    headshots.TargetAim.Tracer = Value
    tracer.Visible = false
    tracerOutline.Visible = false
end}):colorpicker({name = "main", flag = "tracerfill", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.TargetAim.TracerFillColor = Value
end}):colorpicker({name = "outline", flag = "traceroutline", color = rgb(0, 0, 0), callback = function(Value, alpha)
    headshots.TargetAim.TracerOutlineColor = Value
end})

section:dropdown({
    name = "tracer position",
    items = {"Mouse", "Tool"},
    default = "Mouse",
    scrolling = true,
    callback = function(Value)
        headshots.TargetAim.TracerPosition = Value
    end
})

section:toggle({name = "lookat", flag = "targetaim_lookat", callback = function(Value)
    headshots.TargetAim.LookAt = Value
end})

section:toggle({name = "strafe", flag = "targetaim_strafe", callback = function(Value)
    headshots.TargetAim.Strafe = Value
end})

section:toggle({name = "csync", flag = "targetaim_csync", callback = function(Value)
    headshots.TargetAim.CSync = Value
end})

section:toggle({name = "visualize csync", flag = "visualize_csync", callback = function(Value)
    headshots.TargetAim.VisualizeStrafe = Value
end}):colorpicker({name = "main", flag = "visualizecsync_color", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.TargetAim.VisualizeStrafeColor = Value
end})


section:dropdown({
    name = "strafe method",
    items = {"Randomize", "Orbit"},
    default = "Randomize",
    scrolling = true,
    callback = function(Value)
        headshots.TargetAim.StrafeMethod = Value
    end
})

section:slider({name = "strafe prediction", min = 0.1, max = 5, default = 0.80, interval = 0.01, flag = "strafeprediction", callback = function(Value)
    GlobalPredictionMultiplier = Value
end})

section:toggle({name = "auto stomp", flag = "targetaim_autostomp", callback = function(Value)
    headshots.TargetAim.AutoStomp = Value
end})

section:toggle({name = "void resolver", flag = "void_resolver", callback = function(Value)
    headshots.TargetAim.VoidResolver = Value
end})

local section = column:section({name = "hit effects"})

section:toggle({name = "hit notifications", flag = "hitnotifications_enabled", callback = function(Value)
    headshots.HitEffects.HitNotifications = Value
end})

section:slider({name = "notification Time", min = 1, max = 10, default = 3, interval = 1, flag = "hitnotification_time", callback = function(Value)
    headshots.HitEffects.HitNotificationsTime = Value
end})

section:toggle({name = "hit sounds", flag = "hitsounds_enabled", callback = function(Value)
    headshots.HitEffects.HitSounds = Value
end})

section:dropdown({
    name = "select hit sound",
    items = {"neverlose", "gamesense", "bubble"},
    flag = "hitsounds_selected",
    default = "neverlose",
    scrolling = true,
    callback = function(Value)
        if Value == "neverlose" then
            headshots.HitEffects.HitSoundID = "rbxassetid://97643101798871"
        elseif Value == "gamesense" then
            headshots.HitEffects.HitSoundID = "rbxassetid://4817809188"
        elseif Value == "bubble" then
            headshots.HitEffects.HitSoundID = "rbxassetid://6534947588"
        end
    end
})

section:slider({name = "hit sound volume", min = 1, max = 10, default = 5, interval = 1, flag = "hitsound_volume", callback = function(Value)
    headshots.HitEffects.HitSoundVolume = Value
end})

local column = Combat:column()

local section = column:section({name = "kill aura"})

section:toggle({name = "enabled", flag = "killaura_enabled", callback = function(Value)
    headshots.KillAura.Enabled = Value
end}):keybind({name = "kill aura", flag = "killaura_bind", callback = function(Value)
    if headshots.KillAura.Enabled then
        headshots.KillAura.Keybind = Value
    end
end})

section:toggle({name = "stomp aura", flag = "stompaura_enabled", callback = function(Value)
    headshots.KillAura.StompAura = Value
end})

section:slider({name = "distance", min = 1, max = 200, default = 200, interval = 1, flag = "killaura_distance", callback = function(Value)
    headshots.KillAura.Distance = Value
end})

local section = column:section({name = "gun modifications"})

section:toggle({name = "rapid fire", flag = "rapidfire_enabled", callback = function(Value)
    if getnamecallmethod then
        headshots.RapidFire.Enabled = Value
    else
        library:notification({ text = "Your executor does not support this feature.", time = 3 })
    end
end})

section:toggle({name = "wallbang", flag = "wallbang_enabled", callback = function(Value)
    if getnamecallmethod then
        local Handler = game:FindService("ReplicatedStorage").MainModule
        local Module = require(Handler)
        if Value == true and workspace:FindFirstChild("Vehicles") then
            Module.Ignored = {workspace:WaitForChild("Vehicles"), workspace:WaitForChild("MAP"), workspace:WaitForChild("Ignored")}
        else
            if workspace:FindFirstChild("Vehicles") then
                Module.Ignored = {workspace:WaitForChild("Vehicles"), workspace:WaitForChild("Ignored")}
            end
        end
    else
        library:notification({ text = "Your executor does not support this feature.", time = 3 })
    end
end})

local section = column:section({name = "hitbox expander"})

section:toggle({name = "enabled", flag = "hitboxexpander_enabled", callback = function(Value)
    headshots.HitboxExpander.Enabled = Value
end})

section:toggle({name = "visualize", flag = "hitboxexpander_visualize", callback = function(Value)
    headshots.HitboxExpander.Visualize = Value
end}):colorpicker({name = "main", flag = "hitboxexpandermain", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.HitboxExpander.Color = Value
end}):colorpicker({name = "outline", flag = "hitboxexpanderoutline", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.HitboxExpander.OutlineColor = Value
end})

section:slider({name = "fill transparency", min = 0, max = 1, default = 0.5, interval = 0.01, flag = "hitboxexpander_filltransparency", callback = function(Value)
    headshots.HitboxExpander.FillTransparency = Value
end})

section:slider({name = "outline transparency", min = 0, max = 1, default = 0.3, interval = 0.01, flag = "hitboxexpander_outlinetransparency", callback = function(Value)
    headshots.HitboxExpander.OutlineTransparency = Value
end})

section:slider({name = "size", min = 1, max = 37, default = 37, interval = 1, flag = "hitboxexpander_size", callback = function(Value)
    headshots.HitboxExpander.Size = Value
end})

-- // Visuals // --

-- // ESP // --

getgenv().table = {
    fov = {
        enable = false,
		radius = 150,
        color = Color3.fromRGB(255, 255, 255),
        thickness = 1,
        filled = {
            enable = true,
            gradient = {
                enable = true,
                colors = {
                    ["1"] = Color3.fromRGB(106, 191, 247),
                    ["2"] = Color3.fromRGB(255, 255, 255)
                },
                rotation = 70,
                transparency = 0.5;
            }
        }
    },

    visuals = {
        enable = true,

        esp = {
            enable = true,
            boxes = {
                ['2D'] = {
                    enable = true,
                    type = 'full',
                    render = 'dynamic', -- static
                    thickness = 0.5,

                    colors = {
                        main = Color3.fromRGB(255,255,255),
                        inline = Color3.fromRGB(0,0,0),
                        outline = Color3.fromRGB(0,0,0);
                    },

					filled = {
						enable = false,
						gradient = {
							enable = true,
							colors = {
								["1"] = Color3.fromRGB(155, 125, 175),
                                ["2"] = Color3.fromRGB(0, 0, 0)
							},
							rotation = 45,
                            autorotation = true,
							transparency = 0.5
						}
					}
                },
                ['3D'] = {
                    enable = false,
                    type = 'full',
                    thickness = 1,
                    transparency = 0,

                    colors = {
                        main = Color3.fromRGB(255,255,255);
                    },

                    filled = {
                        enable = false,
                        gradient = {
                            enable = false,
                            colors = {
                                ['1'] = Color3.fromRGB(),
                                ['2'] = Color3.fromRGB()
                            },
                            rotation = 90,
                            transparency = 0.65;
                        }
                    }
                }
            },
            texts = {
                name = {
                    enable = true,
                    colors = {
                        main = Color3.fromRGB(255,255,255),
                        stroke = Color3.fromRGB(0,0,0);
                    }
                },
                
                health = {
                    enable = false,
                    colors = {
                        main = Color3.fromRGB(255,255,255),
                        stroke = Color3.fromRGB(0,0,0);
                    }
                },

                armor = {
                    enable = false,
                    colors = {
                        main = Color3.fromRGB(255,255,255),
                        stroke = Color3.fromRGB(0,0,0);
                    }
                },

                distance = {
                    enable = true,
                    auto_position = false,
                    colors = {
                        main = Color3.fromRGB(255,255,255),
                        stroke = Color3.fromRGB(0,0,0);
                    },
                    alignment = {
                        vertical = 'bottom',
                        horizontal = 'center';
                    };
                },

                tool = {
                    enable = true,
                    auto_position = false,
                    colors = {
                        main = Color3.fromRGB(255,255,255),
                        stroke = Color3.fromRGB(0,0,0);
                    },
                    alignment = {
                        vertical = 'top',
                        horizontal = 'center';
                    };
                }
            },
            bars = {
                health = {
                    enable = true,
                    thickness = 0.5,
                    alignment = {
                        vertical = 'top',
                        horizontal = 'left';
                    },
                    lerp = false,
                    colors = {
                        main = Color3.fromRGB(0,255,0),
                        outline = Color3.fromRGB(0,0,0);
                    },
                    filled = {
                        enable = false,
                        gradient = {
                            enable = true,
                            colors = {
                                ['1'] = Color3.fromRGB(),
                                ['2'] = Color3.fromRGB()
                            },
                            rotation = 90,
                            transparency = 0.65;
                        }
                    },
                    transparency = 0;
                },
                armor = {
                    enable = true,
                    thickness = 0.5,
                    lerp = false,
                    colors = {
                        main = Color3.fromRGB(0,0,255),
                        outline = Color3.fromRGB(0,0,0);
                    },
                    alignment = {
                        vertical = 'top',
                        horizontal = 'left';
                    },
                    filled = {
                        enable = false,
                        gradient = {
                            enable = true,
                            colors = {
                                ['1'] = Color3.fromRGB(),
                                ['2'] = Color3.fromRGB()
                            },
                            rotation = 90,
                            transparency = 0.65;
                        }
                    },
                    transparency = 0;
                },
            },
        tracers = {
            enable = false,
            position = {
                origin = 'mouse', -- screen/bottom, screen/top, self/rootpart, self/head, mouse, tool;
                to = 'rootpart' -- box/bottom, box/top, rootpart, head, 
            },
            color = Color3.fromRGB(255, 255, 255),
            thickness = 1,
            filled = {
                enable = false,
                gradient = {
                    enable = true,
                    colors = {
                        ['1'] = Color3.fromRGB(),
                        ['2'] = Color3.fromRGB()
                    },
                    rotation = 90,
                    transparency = 0.65;
                }
            },
            transparency = 0;
        };
        },
    },
}
-->
local table = getgenv().table

repeat 
    task.wait() 
until game:IsLoaded()
pcall(function()

    local start = tick()

    local assert, select, type, next, typeof, pcall, xpcall, tick, setmetatable, warn, pairs, ipairs, loadstring = 
    assert, select, type, next, typeof, pcall, xpcall, tick, setmetatable, warn, pairs, ipairs, loadstring

    local getrawmetatable, gethiddenproperty, sethiddenproperty, getrenv, getgenv, getgc, getreg = 
    getrawmetatable, gethiddenproperty, sethiddenproperty, getrenv, getgenv, getgc, getreg

    local services = setmetatable({}, {
        __index = function(t, k)
            if k == "game" then
                return game
            else
                return game:GetService(k)
            end
        end
    })

    local fonts = {
        {"ProggyClean.ttf", "ProggyClean.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/ProggyClean.txt"},
        {"ProggyTiny.ttf", "ProggyTiny.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/ProggyTiny.txt"},
        {"Minecraftia.ttf", "Minecraftia.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/Minecraftia.txt"},
        {"SmallestPixel7.ttf", "SmallestPixel7.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/SmallestPixel7.txt"},
        {"Verdana.ttf", "Verdana.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/Verdana.txt"},
        {"VerdanaBold.ttf", "VerdanaBold.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/VerdanaBold.txt"},
        {"Tahoma.ttf", "Tahoma.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/Tahoma.txt"},
        {"TahomaBold.ttf", "TahomaBold.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/TahomaBold.txt"},
        {"CSGO.ttf", "CSGO.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/CSGO.txt"},
        {"WindowsXPTahoma.ttf", "WindowsXPTahoma.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/windows-xp-tahoma.ttf"},
        {"Stratum2.ttf", "Stratum2.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/Stratum2.txt"},
        {"Visitor.ttf", "Visitor.json", "https://raw.githubusercontent.com/suspendthread/uwu/refs/heads/main/dependencies/assets/fonts/Visitor.txt"},
    }
    
    for _, font in pairs(fonts) do
        local ttf, json, url = font[1], font[2], font[3]
    
        if not isfile(ttf) then
            local fontData = game:HttpGet(url)
            writefile(ttf, fontData) 
        end
    
        if not isfile(json) then
            local fontJson = {
                name = ttf:match("([^%.]+)"),
                faces = {
                    {
                        name = "Regular",
                        weight = 200,
                        style = "normal",
                        assetId = getcustomasset(ttf)
                    }
                }
            }
            writefile(json, game:GetService('HttpService'):JSONEncode(fontJson))
        end
    end

    local enumed = {}
    for _, font in pairs(fonts) do
        enumed[font[1]:match("([^%.]+)")] = Font.new(getcustomasset(font[2]), Enum.FontWeight.Regular)
    end

    function getfontfromname(v) return enumed[v] end

    local  replicated_storage, workspace, run_service, tween_service, user_input_service, lighting, stats, http_service, gui_service = 
    services.ReplicatedStorage, services.Workspace, services.RunService, services.TweenService, services.UserInputService, services.Lighting, services.Stats, services.HttpService, services.GuiService

    local camera, client, mouse = workspace.CurrentCamera, players.LocalPlayer, user_input_service:GetMouseLocation()

    local data = http_service:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/weedhook/table/refs/heads/main/stored/hood_games.json"))
    local current_game = data.place_ids[tostring(game.PlaceId)] and data.place_ids[tostring(game.PlaceId)][1] or nil

    local vec_3, vec_2, cframe, udim_2, color_3, brickcolor = Vector3.new, Vector2.new, CFrame.new, UDim2.new, Color3.new, BrickColor.new
    local abs, acos, asin, atan, atans, ceil, cos, esp, floor, fmod, max, min = math.abs, math.acos, math.asin, math.atan, math.atan2, math.ceil, math.cos, math.exp, math.floor, math.fmod, math.max, math.min
    local rad, random, sin, sqrt, tan, pi, log, log10, deg, clamp, huge, tointeger, pow = math.rad, math.random, math.sin, math.sqrt, math.tan, math.pi, math.log, math.log10, math.deg, math.clamp, math.huge, math.tointeger, math.pow

    local desynchronize, synchronize, cancel, defer, spawn = task.desynchronize, task.synchronize, task.cancel, task.defer, task.spawn
    local isyieldable, running, status, create, resume, close, yield, wrap = coroutine.isyieldable, coroutine.running, coroutine.status, coroutine.create, coroutine.resume, coroutine.close, coroutine.yield, coroutine.wrap


--> tables
local utility, shared = {}, {};
    
--> Init
do
    utility.formula = {
        tick = tick();
    };

    utility.funcs = {};
    utility.funcs.universal = nil;
    utility.funcs.self = nil;
    utility.funcs.nmisc = nil;
end

do

--> shared.hooks <--
    shared.hooks = {};
    shared.hooks.silent = {};
    shared.hooks.aimbot = {};
    shared.hooks.global = {};
    shared.hooks.misc = {};

--> shared.connections <--
    shared.connections = {};
    shared.connections.loops = {
        main = nil,
        misc = nil,
        visual = nil;
    }
    shared.connections.workspace = nil;
    shared.connections.ignored = nil;
    shared.connections.gun = { ammo = nil, tool = nil, activated = nil, ray = nil; };
    shared.connections.players = { added = nil, removing = nil, health = nil}

    
end

do  


    table.stored = { 
        screen_gui = Instance.new('ScreenGui', gethui()),
        lighting = nil,
        fov = nil,
        folder = Instance.new('Folder', workspace),
        desync = nil,
        camera_position = nil,
        beams = {},
        beam_to_lines = {},
        current_bullets = nil,
        current_health = nil,
        beams_update = tick(),
        games = {
            handler = {},
            hood_games = {},
            funcs = {};
        }
    }

    table.locals = {
        silent = {
            hitbone = nil,
            old_hitbone = nil,
            air_hitbone = nil,
            is_air = false,
            point = nil,
            cframe = nil,
            desynced = false
        },
        aimbot = {
            prey = nil, 
            hitbone = nil,
            old_hitbone = nil,
            air_hitbone = nil,
            is_air = false,
            point = nil,
            position = nil,
            desynced = false
        },
        triggerbot = {
            prey = nil,
            point = nil,
            hitbone = nil,
            old_hitbone = nil,
            air_hitbone = nil,
            is_air = false,
            position = nil;
        },
        self = {
            gun = {
                tool = nil,
                ammo = nil;
            },
            old_cframe = nil,
            old_position = nil,
            last_activated = tick(),
            random_tick = tick(),
            movement = {
                velocity = nil,
                status = '',
                last_position = cframe()
            }
        }
    }
end
if not utility.funcs.self then
    do
        utility.funcs.self = {
            set_self_transparency = function(invisible)
                for _, obj in next, client.Character:GetChildren() do
                    if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and not obj.Name:match("CUFFS") and not obj.Name:match("Fake") then
                        obj.Transparency = invisible and 1 or 0
                        for _, decal in next, obj:GetChildren() do
                            if decal:IsA("Decal") then
                                decal.Transparency = invisible and 1 or 0
                            end
                        end
                    elseif obj:IsA("Accessory") and obj:FindFirstChild("Handle") then
                        obj.Handle.Transparency = invisible and 1 or 0
                    end
                end
            end
        }
    end
end
if not utility.funcs.universal then
    do
        utility.funcs.universal = {
            vec3_mouse = function()
                return vec_3(mouse.X, mouse.Y, 0)
            end,

            has_child = function(obj, child)
                if obj then
                    return obj:FindFirstChild(child)
                end
                return nil
            end,

            has_child_of_class = function(obj, class_name)
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA(class_name) then
                        return child
                    end
                end
                return nil
            end,

            is_a = function(obj, name)
                return obj and obj:IsA(name)
            end,

            is_player = function(obj)
                return obj and utility.funcs.universal.is_a(obj, 'Player')
            end,

            get_humanoid = function(char)
                return char and char:FindFirstChildOfClass('Humanoid')
            end,

            get_character = function(obj)
                return obj and (utility.funcs.universal.is_player(obj) and obj.Character or utility.funcs.universal.is_character(obj) and obj)
            end,

            is_character = function(obj)
                return obj and utility.funcs.universal.is_a(obj, 'Model') and utility.funcs.universal.get_humanoid(obj)
            end,
            is_descendant_of = function(obj, parent)
                return obj and parent and obj:IsDescendantOf(parent)
            end,

            is_visible = function(prey)
                local char = utility.funcs.universal.get_character(prey)
                local client_char = utility.funcs.universal.get_character(client)
                if not char or not client_char then return false end
            
                local root_part = utility.funcs.universal.has_child(char, 'HumanoidRootPart')
                local client_rp = utility.funcs.universal.has_child(client_char, 'HumanoidRootPart')
                if not root_part or not client_rp then return false end
            
                local screen_pos, on_screen = camera:WorldToScreenPoint(root_part.Position)
                if on_screen then
                    local ray = workspace:Raycast(client_rp.Position, root_part.Position - client_rp.Position)
                    return ray ~= nil
                end
            
                return false
            end,
            
            is_part_visible = function(part)
                local client_char = utility.funcs.universal.get_character(client)
                if not client_char then return false end
            
                local client_rp = utility.funcs.universal.has_child(client_char, 'HumanoidRootPart')
                if not client_rp then return false end
            
                local ray = workspace:Raycast(client_rp.Position, part - client_rp.Position)
                return ray ~= nil
            end,

            is_alive = function(prey, check_type)
                local char = utility.funcs.universal.get_character(prey)
                if not char then return false end
            
                local humanoid = utility.funcs.universal.get_humanoid(char)
                if not humanoid then return false end
            
                if check_type == "health" then
                    return humanoid.Health > 0
                elseif check_type == "physics" then
                    return humanoid:GetState() ~= Enum.HumanoidStateType.Physics
                elseif check_type == "arsenal" then
                    local player = game.Players:FindFirstChild(prey)
                    if not player or not player:FindFirstChild("NRPBS") or not player.Character then
                        return false
                    end
            
                    if player.NRPBS.Health.Value < 0 then
                        return false
                    end

                    return true
                end
            
                return false
            end,
            
            get_distance = function(obj, obj2, threshold)
                local distance = (obj - obj2).Magnitude
                return threshold and distance <= threshold or distance
            end,

            is_moving = function(prey)
                local root_part = utility.funcs.universal.has_child(utility.funcs.universal.get_character(prey), 'HumanoidRootPart')
                return root_part and root_part.Velocity.Magnitude > 0
            end,

            get_position = function(prey)
                local root_part = utility.funcs.universal.has_child(utility.funcs.universal.get_character(prey), 'HumanoidRootPart')
                return root_part and root_part.Position or vec_3(0, 0, 0)
            end,

            get_health = function(prey)
                local humanoid = utility.funcs.universal.get_humanoid(utility.funcs.universal.get_character(prey))
                return humanoid and humanoid.Health or 0
            end,

            get_direction = function(obj1, obj2)
                return obj1 and obj2 and (obj2 - obj1).Unit or vec_3(0, 0, 0)
            end,

            get_screen_res = function()
                return camera.ViewportSize
            end,

            get_velocity = function(prey, velocity_type)
                if not prey or not utility.funcs.universal.is_a(prey, 'BasePart') then
                    return vec_3(0, 0, 0)
                end

                if velocity_type == "regular" then
                    return prey.Velocity
                elseif velocity_type == "calculated" then
                    local pred_pos, pred_tick = prey.Position, tick()
                    local elapsed, current_pos, current_tick = 0, nil, nil
                    while elapsed < 0.1 do
                        run_service.PostSimulation:Wait()
                        current_pos, current_tick = prey.Position, tick()
                        elapsed = current_tick - pred_tick
                    end
                    return (current_pos - pred_pos) / elapsed
                end

                return Vector3.zero
            end,

            get_ping = function(ping_type)
                local ping = stats.Network.ServerStatsItem['Data Ping']:GetValue()
                return ping_type == 'secs' and (ping / 1000) or math.floor(ping)
            end,

            get_object_by_path = function(path)
                local parts = string.split(path, "/")
                local object = game:FindFirstChild(parts[1]) 
                table.remove(parts, 1)
            
                for _, part in ipairs(parts) do
                    if object then
                        object = object:FindFirstChild(part)
                    else
                        break
                    end
                end
                return object
            end;
        }
    end
end

--utility.formula
do
    if not utility.formula.predictions then
        local ping = utility.funcs.universal.get_ping()

        utility.formula.predictions = {
            no_pred = function(pos) return pos end,
            regular = function(pos, vel) return pos + vel * (ping / 1000) end,
            summon_v1 = function(pos, vel) return pos + (vel / vel.Magnitude) end,
            summon_v2 = function(pos, vel)
                local tick_now = tick()
                local sigma = (table.locals.self.random_tick - tick_now) / (ping / 1000)
                table.locals.self.random_tick = tick_now
                return pos + vel * sigma
            end,
            summon_v3 = function(pos, vel) return pos + vel * (vel.Magnitude / ping) end,
            default = function(pos, vel) return pos + vel * ((ping / 225) * 0.1 + 0.1) end,
            old_method = function(pos, vel) return pos + vel * (ping < 130 and (ping / 1000 + 0.037) or (ping / 1000 + 0.033)) end,
            best_method = function(pos, vel) return pos + vel * (ping < 130 and (ping / 1000 + 0.037) or (ping / 1000 + 0.033)) end,
            new_method = function(pos, vel)
                local rounded, pred = {30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200},
                                    {0.1125, 0.11, 0.135, 0.12, 0.125, 0.139, 0.135, 0.142, 0.145, 0.15, 0.155, 0.16, 0.165, 0.17, 0.175, 0.18, 0.185, 0.19}
                for i, v in ipairs(rounded) do
                    if ping < v then return pos + vel * pred[i] end
                end
                return pos
            end,
            distance = function(pos, vel)
                local pred = ({30, 40, 50, 60, 80, 90, 120, 140, 200})[ping] or 0.1
                return pos + vel * pred
            end,
            trajectory = function(pos, vel)
                local g, time = vec_3(0, -workspace.Gravity, 0), 0
                run_service.PostSimulation:Connect(function(dt)
                    time = time + dt * (vel.Magnitude or 0.25);
                    run_service.PostSimulation:Wait()
                    pos = pos + vel * time + 0.5 * g * time^2;
                end)
                return pos
            end
        }
    end
end

--
do  
    if not table.stored.lighting then
        table.stored.lighting = {}
    end

    for _, v in ipairs({
        "Ambient", "OutdoorAmbient", "Brightness", "ClockTime", 
        "ColorShift_Bottom", "ColorShift_Top", "ExposureCompensation", 
        "FogColor", "FogEnd", "FogStart"
    }) do
        table.stored.lighting[v] = lighting[v]
    end
end
if not table.funcs then
    table.funcs = {}

    table.funcs.wall_check = function(destination, ignore)
        local origin = camera.CFrame.p
        local check_ray = Ray.new(origin, destination - origin)
        local hit = workspace:FindPartOnRayWithIgnoreList(check_ray, ignore)
        return hit == nil
    end
    
    table.funcs.get_nearest_prey = function()
        local prey, nearest = nil, (table.fov.enable and table.stored.fov and table.stored.fov.circle) and table.stored.fov.circle.radius or (1/0)
    
        for _, player in pairs(players:GetPlayers()) do
            if player == client then continue end
    
            local character = utility.funcs.universal.get_character(player)
            if not character then continue end
    
            local root_part = utility.funcs.universal.has_child(character, "HumanoidRootPart")
            if not root_part then continue end
    
            local root_pos, on_s = camera:WorldToViewportPoint(root_part.Position)
            if not on_s then continue end

            local distance = (mouse - vec_2(root_pos.X, root_pos.Y)).Magnitude
            if distance < nearest and table.funcs.wall_check(root_part.Position, {client, character}) then
                nearest, prey = distance, player
            end
        end
    
        return prey
    end

    table.funcs.get_nearest_bone = function(player)
        if not player then return end;
        local nearest_bone, nearest = nil, (1/0)
        local new_mouse = utility.funcs.universal.vec3_mouse()

        for _, bone in ipairs(player:GetChildren()) do
            if utility.funcs.universal.is_a(bone, 'BasePart') then
                local distance = (new_mouse - bone.Position).Magnitude
                if distance < nearest then
                    nearest, nearest_bone = distance, bone
                end
            end
        end

        return nearest_bone
    end

    table.funcs.get_nearest_point = function(hitbone)
        if not hitbone or not utility.funcs.universal.is_a(hitbone, 'BasePart') then return end
        
        local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
        local relative = hitbone.CFrame:PointToObjectSpace(ray.Origin + ray.Direction * 1000)
        local size = hitbone.Size / 2
    
        return hitbone.CFrame:PointToWorldSpace(vec_3(
            math.clamp(relative.X, -size.X, size.X),
            math.clamp(relative.Y, -size.Y, size.Y),
            math.clamp(relative.Z, -size.Z, size.Z)
        ))
    end

end
----> shared.connections
do

        function utility.funcs.universal.closest_player_in_range(position, maxradius)
            local radius = maxradius or 20
            local nearest_prey = nil
            local shortest_distance = radius
        
            for _, plr in pairs(players:GetPlayers()) do
                if plr == client then continue end
        
                local character = utility.funcs.universal.get_character(plr)
                if not character then continue end
        
                local humanoid = utility.funcs.universal.get_humanoid(character)
                if not humanoid or humanoid.Health <= 0 then continue end
        
                local hrp = utility.funcs.universal.has_child(character, "HumanoidRootPart")
                if not hrp then continue end
        
                local distance = (position - hrp.Position).Magnitude
                if distance < shortest_distance then
                    shortest_distance = distance
                    nearest_prey = plr
                end
            end
        
            return nearest_prey
        end

        utility.funcs.universal.create_beam = function(beam, type, properties)
            if not beam or not beam:IsA("Beam") then return end

            if not beam.Parent then
                local lines = table.stored.beam_to_lines[beam]
                if lines then
                    for _, line in pairs(lines) do
                        line.Visible = false
                        if line.Remove then line:Remove() end
                    end
                    table.stored.beam_to_lines[beam] = nil
                end
                return
            end

            local attachment_0, attachment_1 = beam.Attachment0, beam.Attachment1
            type = type:lower()
            if type == "default" and properties then
                --
                beam.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, properties.colors["1"]),
                    ColorSequenceKeypoint.new(1, properties.colors["2"])
                })
                
                beam.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                --
            if properties.texture == 'lightning' then
                --
                beam.Texture = "rbxassetid://446111271"
                beam.TextureMode = Enum.TextureMode.Stretch

                beam.Width0 = 2
                beam.Width1 = 2
                beam.Segments = 10
                --
            elseif properties.texture == 'heartrate' then
                --
                beam.Texture = 'rbxassetid://5830549480'
                beam.TextureMode = Enum.TextureMode.Stretch

                beam.Width0 = 2
                beam.Width1 = 2
                beam.Segments = 10
                --
            elseif properties.texture == 'chain' then
                --
                beam.Texture = 'rbxassetid://9632168658'
                beam.TextureMode = Enum.TextureMode.Stretch

                beam.Width0 = 2
                beam.Width1 = 4
                beam.Segments = 10
                --
            elseif properties.texture == 'glitch' then
                --
                beam.Texture = 'http://www.roblox.com/asset/?id=8089467613'
                beam.TextureMode = Enum.TextureMode.Stretch
                beam.TextureSpeed = -1

                beam.Width0 = 3
                beam.Width1 = 3
                beam.Segments = 10
                --
            elseif properties.texture == 'swirl' then
                --
                beam.Texture = 'rbxassetid://5638168605'
                beam.TextureMode = Enum.TextureMode.Stretch

                beam.TextureSpeed = 1
                beam.Width0 = 2
                beam.Width1 = 2
                beam.Segments = 10
                --
            end
            elseif type == "drawing" then
                beam.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }
                beam.Enabled = false

                if not attachment_0 or not attachment_1 then return end

                local attach0, attach1 = camera:WorldToViewportPoint(attachment_0.WorldPosition), camera:WorldToViewportPoint(attachment_1.WorldPosition)
                local is_on_screen = attach0.Z > 0 and attach1.Z > 0 and
                                    (attach0.X >= 0 and attach0.X <= camera.ViewportSize.X) and
                                    (attach0.Y >= 0 and attach0.Y <= camera.ViewportSize.Y) and
                                    (attach1.X >= 0 and attach1.X <= camera.ViewportSize.X) and
                                    (attach1.Y >= 0 and attach1.Y <= camera.ViewportSize.Y)

                local ray_check_0 = utility.funcs.universal.is_part_visible(attach0)
                local ray_check_1 = utility.funcs.universal.is_part_visible(attach1)

                if is_on_screen and ray_check_0 and ray_check_1 then
                    local lines = table.stored.beam_to_lines[beam]
                    if not lines then
                        local beam_outline = Drawing.new("Line")
                        local beam_line = Drawing.new("Line")

                        beam_outline.From, beam_outline.To = vec_2(attach0.X, attach0.Y) + vec_2(2, 2), vec_2(attach1.X, attach1.Y) + vec_2(2, 2)
                        beam_outline.Color, beam_outline.Thickness, beam_outline.ZIndex, beam_outline.Visible = Color3.fromRGB(0, 0, 0), 2, 1, true
                        beam_line.From, beam_line.To = vec_2(attach0.X, attach0.Y), vec_2(attach1.X, attach1.Y)
                        beam_line.Color, beam_line.Thickness, beam_line.ZIndex, beam_line.Visible = properties.colors["1"], 1, 9e9, true

                        table.stored.beam_to_lines[beam] = {beam_line, beam_outline}
                    else
                        local beam_line, beam_outline = lines[1], lines[2]
                        local new_from, new_to = vec_2(attach0.X, attach0.Y), vec_2(attach1.X, attach1.Y)
                        if beam_line.From ~= new_from or beam_line.To ~= new_to then
                            beam_line.From, beam_line.To = new_from, new_to
                            beam_outline.From, beam_outline.To = new_from + vec_2(1, 1), new_to + vec_2(1, 1)
                        end
                    end
                elseif table.stored.beam_to_lines[beam] then
                    for _, line in pairs(table.stored.beam_to_lines[beam]) do
                        line.Visible = false
                        if line.Remove then line:Remove() end
                    end
                    table.stored.beam_to_lines[beam] = nil
                end
            end
        end
end
        
if not shared.connections.loops.misc then
    local root_part, humanoid;

    shared.connections.loops.misc = run_service.PostSimulation:Connect(function(dt)
        
        local char = utility.funcs.universal.get_character(client);
        local root_part = utility.funcs.universal.has_child(char, 'HumanoidRootPart');
        local is_alive;
        is_alive = utility.funcs.universal.is_alive(client, 'physics')

        if char then
            if not root_part or (not humanoid or humanoid.Parent ~= char) then
                root_part = utility.funcs.universal.has_child(char, 'HumanoidRootPart')
                humanoid = char:FindFirstChildWhichIsA'Humanoid'
            end
        end

        local tool = char and char:FindFirstChildWhichIsA("Tool")
        local ammo
        
        if tool and current_game.Ammo then
            local parts = string.split(current_game.Ammo, "/")
            local obj = tool
        
            for i = 2, #parts do
                if obj then
                    obj = obj:FindFirstChild(parts[i])
                end
            end
        
            if obj and obj:IsA("NumberValue") then
                ammo = obj.Value
            else
                for _, v in ipairs(tool:GetChildren()) do
                    if v:IsA("Script") or v:IsA("LocalScript") then
                        local deep = v
                        for i = 3, #parts do
                            if deep then
                                deep = deep:FindFirstChild(parts[i])
                            end
                        end
                        if deep and deep:IsA("NumberValue") then
                            ammo = deep.Value
                            break
                        end
                    end
                end
            end
        
            if not ammo then
                ammo = current_game.Ammo
            end
        end
    end)
end

do  
    table.funcs.create_fov = function()
        if table.fov.enable then
            local fov_elements = {
                circle = Drawing.new('Circle'),
                inline = Drawing.new('Circle'),
                outline = Drawing.new('Circle'),
                gradient = Instance.new('Frame', table.stored.screen_gui)
            }
    
            table.stored.fov = fov_elements
            return fov_elements
        end
    end

    table.funcs.update_fov = function()
        if table.stored.fov then
            local pos = user_input_service:GetMouseLocation() + gui_service:GetGuiInset() - vec_2(0, 58)
        
            table.stored.fov.circle.Color = table.fov.color
            table.stored.fov.circle.Thickness = table.fov.thickness
            table.stored.fov.circle.Filled = false
            table.stored.fov.circle.Visible = true
            table.stored.fov.circle.ZIndex = (2935482942384293)
            table.stored.fov.circle.Position = pos
            table.stored.fov.circle.Radius = table.fov.radius or 150
        
            table.stored.fov.inline.Color = Color3.new()
            table.stored.fov.inline.Thickness = table.fov.thickness
            table.stored.fov.inline.Filled = false
            table.stored.fov.inline.Visible = true
            table.stored.fov.inline.Position = pos
			table.stored.fov.inline.ZIndex = -9e9
            table.stored.fov.inline.Radius = table.stored.fov.circle.Radius - 1
        
            table.stored.fov.outline.Color = Color3.new()
            table.stored.fov.outline.Thickness = table.fov.thickness
            table.stored.fov.outline.Filled = false
            table.stored.fov.outline.Visible = true
            table.stored.fov.outline.Position = pos
            table.stored.fov.outline.Radius = table.stored.fov.circle.Radius + 1
			table.stored.fov.outline.ZIndex = -9e9

            if table.fov.filled.enable then
				table.stored.fov.circle.Filled = true
				if table.fov.filled.gradient.enable then
					table.stored.fov.circle.Filled = false
					table.stored.fov.gradient.BackgroundColor3 = Color3.new(1, 1, 1)
					table.stored.fov.gradient.BackgroundTransparency = table.fov.filled.gradient.transparency or 0.65
					table.stored.fov.gradient.Size = udim_2(0, table.stored.fov.inline.Radius * 2, 0, table.stored.fov.inline.Radius * 2)
					table.stored.fov.gradient.Position = udim_2(0, pos.X - table.stored.fov.inline.Radius, 0, pos.Y - table.stored.fov.inline.Radius - 58)
					local ui_corner = table.stored.fov.gradient:FindFirstChildOfClass'UICorner' or Instance.new('UICorner', table.stored.fov.gradient)
					ui_corner.CornerRadius = UDim.new(0, table.fov.radius)
					local ui_gradient = table.stored.fov.gradient:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", table.stored.fov.gradient)
					ui_gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, table.fov.filled.gradient.colors["1"]),
						ColorSequenceKeypoint.new(1, table.fov.filled.gradient.colors["2"])
					})
					ui_gradient.Rotation = table.fov.filled.gradient.rotation or 90
				else
					table.stored.fov.gradient.Visible = false
				end
			end
        end
        
    end
    --> create_fov after function
        table.funcs.create_fov();
    -->

    utility.funcs.universal.visuals = utility.funcs.universal.visuals or {};
    utility.funcs.universal.self_visuals = utility.funcs.universal.self_visuals or {}

    utility.funcs.universal.visuals.add_framework = function(player)

        if not player or not utility.funcs.universal.is_player(player) then return end
    
        local character = utility.funcs.universal.get_character(player)
        if not character then return end
        
        local root_part, humanoid = utility.funcs.universal.has_child(character, 'HumanoidRootPart'), utility.funcs.universal.get_humanoid(character)
        if not root_part or not humanoid then return end
    
        table.stored[player] = table.stored[player] or {}
        
        if table.visuals.enable and table.visuals.esp.enable then
            if table.visuals.esp.bars.health.enable then
                table.stored[player]['health_bar'] = table.stored[player]['health_bar'] or { square = Drawing.new("Square"), square_outline = Drawing.new("Square") }
                table.stored[player]['health_bar'].square.Visible, table.stored[player]['health_bar'].square_outline.Visible = false, false
            end
            if table.visuals.esp.bars.armor.enable then
                table.stored[player]['armor_bar'] = table.stored[player]['armor_bar'] or { square = Drawing.new("Square"), square_outline = Drawing.new("Square") }
                table.stored[player]['armor_bar'].square.Visible, table.stored[player]['armor_bar'].square_outline.Visible = false, false
            end
            local function create_ui_stoke(obj)
                if not obj:FindFirstChildOfClass('UIStroke') then
                    Instance.new('UIStroke', obj).Thickness = 1
                end
            end
            
            if table.visuals.esp.texts.health.enable then
                -- table.stored[player]['health_text'] = table.stored[player]['health_text'] or { text = Instance.new('TextLabel', table.stored.screen_gui)}
                -- create_ui_stoke(table.stored[player]['health_text'].text)
            end
            
            --[[if table.visuals.esp.texts.armor.enable then
                table.stored[player]['armor_text'] = table.stored[player]['armor_text'] or { text = Instance.new('TextLabel', table.stored.screen_gui)}
                create_ui_stoke(table.stored[player]['armor_text'].text)
            end
            ]]
            
            if table.visuals.esp.texts.tool.enable then
                table.stored[player]['tool_text'] = table.stored[player]['tool_text'] or { text = Instance.new('TextLabel', table.stored.screen_gui)}
                create_ui_stoke(table.stored[player]['tool_text'].text)
            end
            
            if table.visuals.esp.texts.distance.enable then
                table.stored[player]['distance_text'] = table.stored[player]['distance_text'] or { text = Instance.new('TextLabel', table.stored.screen_gui)}
                create_ui_stoke(table.stored[player]['distance_text'].text)
            end
            
            if table.visuals.esp.texts.name.enable then
                table.stored[player]['name_text'] = table.stored[player]['name_text'] or { text = Instance.new('TextLabel', table.stored.screen_gui)}
                create_ui_stoke(table.stored[player]['name_text'].text)
            end

            --name
            if table.visuals.esp.tracers.enable then
                table.stored[player]['tracer'] = table.stored[player]['tracer'] or {
                    line = Drawing.new('Line'),
                    outline = Drawing.new('Line')
                }
            end
            
            if table.visuals.esp.boxes['2D'].enable then
                table.stored[player]['2D'] = table.stored[player]['2D'] or {}
                table.stored[player]['2D']['full'] = table.stored[player]['2D']['full'] or {}
                table.stored[player]['2D']['full']['dynamic'] = table.stored[player]['2D']['full']['dynamic'] or {
                    square = Drawing.new('Square'),
                    square_inline = Drawing.new('Square'),
                    square_outline = Drawing.new('Square'),
                    gradient = Instance.new('Frame', table.stored.screen_gui);
                }
                
                for key, v in pairs(table.stored[player]['2D']['full']['dynamic']) do
                    if key ~= "gradient" then
                        v.Visible, v.Filled, v.Thickness = false, false, table.visuals.esp.boxes['2D'].thickness or 1
                    else
                        v.Visible = false;
                    end
                end

                table.stored[player]['2D']['full']['dynamic'].square.Color = (table.visuals.esp.boxes['2D'].colors.main or Color3.fromRGB(255, 255, 255))
                table.stored[player]['2D']['full']['dynamic'].square_inline.Color = (table.visuals.esp.boxes['2D'].colors.inline or Color3.fromRGB(0, 0, 0))
                table.stored[player]['2D']['full']['dynamic'].square_outline.Color = (table.visuals.esp.boxes['2D'].colors.outline or Color3.fromRGB(0, 0, 0))

                table.stored[player]['2D']['full']['dynamic'].gradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                table.stored[player]['2D']['full']['dynamic'].gradient.BackgroundTransparency = (table.visuals.esp.boxes['2D'].filled.gradient.transparency)

            end
        end
    end
    utility.funcs.universal.visuals.clear_esp = function(player)
        if not table.stored[player] then return end

        local d = (((table.stored[player]["2D"] or {}).full or {}).dynamic)
        if d then for _, v in pairs(d) do if v then v.Visible = false end end end

        for _, k in ipairs({ "armor_text", "health_text", "name_text", "distance_text", "tool_text" }) do
            local e = table.stored[player][k]
            if e and e.text then e.text.Visible = false end
        end

        for _, k in ipairs({ "armor_bar", "health_bar" }) do
            local e = table.stored[player][k]
            if e and e.square and e.square_outline then
                e.square.Visible = false
                e.square_outline.Visible = false
            end
        end
    end

    utility.funcs.universal.visuals.update_framework = function(player)
        if not player or not utility.funcs.universal.is_player(player) then return end
    
        if table.visuals.enable then
            local current_time = tick()
    
            local character = utility.funcs.universal.get_character(player)
            if not character then return end

            local root_part = utility.funcs.universal.has_child(character, 'HumanoidRootPart')
            local client_root_part = utility.funcs.universal.has_child(client.Character, 'HumanoidRootPart')
            local lower_torso = utility.funcs.universal.has_child(character, 'LowerTorso')
            local humanoid = utility.funcs.universal.get_humanoid(character)
    
            if not root_part or not humanoid then return end
    
            local char_height = character:GetExtentsSize().Y / 2
            local top, top_onscreen = camera:WorldToViewportPoint(root_part.Position + vec_3(0, char_height, 0))
            local realbottom_part = lower_torso or root_part
            local bottom, bottom_onscreen = camera:WorldToViewportPoint(realbottom_part.Position - vec_3(0, char_height, 0))
    
            if not top or not bottom then
                utility.funcs.universal.visuals.clear_esp(player)
                return
            end
    
            local screen_size = (bottom.Y - top.Y)
            if screen_size <= 0 then
                utility.funcs.universal.visuals.clear_esp(player)
                return
            end
    
            local position = vec_2(top.X - (screen_size * 0.65 / 2), top.Y)
            local size = vec_2(screen_size * 0.65, screen_size)
    
            if not (position and size) or not (root_part and character) then
                utility.funcs.universal.visuals.clear_esp(player)
                return
            end

            if table.visuals.esp.tracers.enable then
                if table.stored[player]['tracer'] then
                    
                    local from = Vector2.zero
                    local to = vec_2
            
                    if table.visuals.esp.tracers.position.origin == 'screen/bottom' then
                        from = vec_2(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    elseif table.visuals.esp.tracers.position.origin == 'screen/top' then
                        from = vec_2(camera.ViewportSize.X / 2, 0)
                    elseif table.visuals.esp.tracers.position.origin == 'mouse' then
                        from = user_input_service:GetMouseLocation()
                    elseif table.visuals.esp.tracers.position.origin == 'self/rootpart' then
                        local hrp = client.Character and utility.funcs.universal.has_child(client.Character, 'HumanoidRootPart')
                        if hrp then from = camera:WorldToViewportPoint(hrp.Position) end
                    elseif table.visuals.esp.tracers.position.origin == 'self/head' then
                        local head = client.Character and utility.funcs.universal.has_child(client.Character, 'Head')
                        if head then from = camera:WorldToViewportPoint(head.Position) end
                    end
            
                    if table.visuals.esp.tracers.position.to == 'box/top' then
                        to = vec_2(position.X, top.X)
                    elseif table.visuals.esp.tracers.position.to == 'box/bottom' then
                        to = vec_2(position.X, bottom.X)
                    elseif table.visuals.esp.tracers.position.to == 'rootpart' then
                        to = camera:WorldToViewportPoint(root.Position)
                    elseif table.visuals.esp.tracers.position.to == 'head' then
                        to = camera:WorldToViewportPoint(head.Position)
                    end
            
                    table.stored[player]['tracer'].outline.From = from
                    table.stored[player]['tracer'].outline.To = to
                    table.stored[player]['tracer'].outline.Thickness = table.visuals.esp.tracers.thickness + 2
                    table.stored[player]['tracer'].outline.Color = Color3.new(0, 0, 0)
                    table.stored[player]['tracer'].outline.Visible = true
            
                    table.stored[player]['tracer'].line.From = from
                    table.stored[player]['tracer'].line.To = to
                    table.stored[player]['tracer'].line.Thickness = table.visuals.esp.tracers.thickness
                    table.stored[player]['tracer'].line.Color = table.visuals.esp.tracers.color
                    table.stored[player]['tracer'].line.ZIndex = 9e9;
                    table.stored[player]['tracer'].line.Visible = true
                end
            end
            if top_onscreen and bottom_onscreen then
                if table.visuals.esp.enable  then
                    if table.visuals.esp.bars.health.enable and humanoid then
                        -->
                            if not humanoid then
                                table.stored[player]['health_bar'].square.Visible = false
                                table.stored[player]['health_bar'].square_outline.Visible = false
                            else
                                if table.stored[player]['health_bar'] then
                                    table.stored[player]['health_bar'].square.Visible = true
                                    table.stored[player]['health_bar'].square_outline.Visible = true
                                end
                            end

                        -->
                        if table.stored[player] and table.stored[player]['health_bar'] then
                            
                            local health_ratio = humanoid.Health / humanoid.MaxHealth
                            local bar_width;
                            local bottom_bar_width;
                            if table.visuals.esp.bars.health.alignment.vertical == 'top' then
                                bar_width = 2
                                if table.visuals.esp.bars.health.alignment.horizontal == 'left' then
                                    table.stored[player]['health_bar'].square.Position = vec_2(position.X - bar_width - 1, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(2, 0)
                                    table.stored[player]['health_bar'].square.Size = vec_2(bar_width, (screen_size * health_ratio + 1))
                                    table.stored[player]['health_bar'].square.Color = table.visuals.esp.bars.health.colors.main:Lerp(Color3.fromRGB(255, 0, 0), 1 - health_ratio)
                                    table.stored[player]['health_bar'].square.Filled = true
                                    table.stored[player]['health_bar'].square.Visible = true
                    
                                    table.stored[player]['health_bar'].square_outline.Position = vec_2(position.X - bar_width, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(4, 0)
                                    table.stored[player]['health_bar'].square_outline.Color = table.visuals.esp.bars.health.colors.outline
                                    table.stored[player]['health_bar'].square_outline.Size = vec_2(bar_width, (screen_size * health_ratio + 1)) + vec_2(2, 1)
                                    table.stored[player]['health_bar'].square_outline.Visible = true

                                    if table.stored[player]['armor_bar'] and table.visuals.esp.bars.armor.alignment.vertical == 'top' and table.visuals.esp.bars.armor.alignment.horizontal == 'left' then
                                        --table.stored[player]['health_bar'].square.Position = vec_2(position.X - bar_width - 8, position.Y + (screen_size - (screen_size * health_ratio + 1)) ) - vec_2(2, 0)
                                        --table.stored[player]['health_bar'].square_outline.Position = vec_2(position.X - bar_width - 7, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(4, 0)

                                        table.stored[player]['health_bar'].square.Position = vec_2(position.X - bar_width - 1, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(2, 0)
                                        table.stored[player]['health_bar'].square_outline.Position = vec_2(position.X - bar_width, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(4, 0)
                                    end
                                elseif table.visuals.esp.bars.health.alignment.horizontal == 'right' then
                                    --local right_position = (position.X + size.X) + (screen_size - (screen_size * health_ratio + 1)) + 11
                                    table.stored[player]['health_bar'].square.Position = vec_2((position.X + (screen_size * 0.65) + 10) - 4, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(2, -1)
                                    table.stored[player]['health_bar'].square.Size = vec_2(2, (screen_size * health_ratio + 1) - 1)
                                    table.stored[player]['health_bar'].square.Color = table.visuals.esp.bars.health.colors.main:Lerp(Color3.fromRGB(255, 0, 0), 1 - health_ratio)
                                    table.stored[player]['health_bar'].square.Filled = true
                                    table.stored[player]['health_bar'].square.ZIndex = 9e9
                                    table.stored[player]['health_bar'].square.Visible = true
    
                                    table.stored[player]['health_bar'].square_outline.Position = vec_2((position.X + (screen_size * 0.65) + 10) - 2 - 1, position.Y + (screen_size - (screen_size * health_ratio + 1))) - vec_2(4, 0)
                                    table.stored[player]['health_bar'].square_outline.Size = vec_2(4, (screen_size * health_ratio + 1) + 1)
                                    table.stored[player]['health_bar'].square_outline.Color = table.visuals.esp.bars.health.colors.outline
                                    table.stored[player]['health_bar'].square_outline.Visible = true
                                end
                            elseif table.visuals.esp.bars.health.alignment.vertical == 'bottom' then
                                if table.visuals.esp.bars.health.alignment.horizontal == 'center' then
                                    bottom_bar_width = (size.X * health_ratio)
                                    table.stored[player]['health_bar'].square.Position = vec_2(position.X + (size.X / 2) - (bottom_bar_width / 2), bottom.Y + 3) + vec_2(-1, 1)
                                    table.stored[player]['health_bar'].square.Size = vec_2(bottom_bar_width + 1, 2)
                                    table.stored[player]['health_bar'].square.Color = table.visuals.esp.bars.health.colors.main:Lerp(Color3.fromRGB(255, 0, 0), 1 - health_ratio)
                                    table.stored[player]['health_bar'].square.Filled = true
                                    table.stored[player]['health_bar'].square.Visible = true
                    
                                    table.stored[player]['health_bar'].square_outline.Position = vec_2(position.X + (size.X / 2) - (bottom_bar_width / 2), bottom.Y + 3) - vec_2(1, 0)
                                    table.stored[player]['health_bar'].square_outline.Color = table.visuals.esp.bars.health.colors.outline
                                    table.stored[player]['health_bar'].square_outline.Size = vec_2(bottom_bar_width + 2, 4)
                                    table.stored[player]['health_bar'].square_outline.Visible = true
                                end
                            end
                        else
                            if table.stored[player] and table.stored[player]['health_bar'] and table.stored[player]['health_bar'].square and table.stored[player]['health_bar'].square_outline then
                                table.stored[player]['health_bar'].square.Visible = false
                                table.stored[player]['health_bar'].square_outline.Visible = false
                            end
                        end
                    end
                    --[[if table.visuals.esp.texts.health.enable and humanoid then
                        if table.stored[player] and table.stored[player]['health_text'].text then
                            local health_ratio = humanoid.Health / humanoid.MaxHealth

                            table.stored[player]['health_text'].text.Text = string.format("%d%%", math.floor(health_ratio * 100))
                            table.stored[player]['health_text'].text.TextSize = 12
                            table.stored[player]['health_text'].text.AnchorPoint = vec_2(0.5, 0.5)
                            table.stored[player]['health_text'].text.TextColor3 = Color3.fromRGB(255 - (255 * health_ratio), 255 * health_ratio, 0)
                            table.stored[player]['health_text'].text.TextStrokeTransparency = 0;
                            table.stored[player]['health_text'].text.FontFace = library.font
                            table.stored[player]['health_text'].text.BackgroundTransparency = 1
                            table.stored[player]['health_text'].text.ZIndex = (9e9)
                            table.stored[player]['health_text'].text.Visible = true

							if table.visuals.esp.bars.health.alignment.vertical == 'top' then
								if table.visuals.esp.bars.health.alignment.horizontal == 'left' then
									table.stored[player]['health_text'].text.Position = udim_2(0, position.X - 23, 0, position.Y + (screen_size - (screen_size * health_ratio + 55)))
                                    if table.visuals.esp.bars.armor.alignment.horizontal == 'left' then
                                        table.stored[player]['health_text'].text.Position = udim_2(0, position.X - 58, 0, position.Y + (screen_size - (screen_size * health_ratio + 55)))
                                    end
								elseif table.visuals.esp.bars.health.alignment.horizontal == 'right' then
									table.stored[player]['health_text'].text.Position = udim_2(0, (position.X + (screen_size * 0.65) + 27) - 4, 0, position.Y + (screen_size - (screen_size * health_ratio + 55)))
									if table.visuals.esp.bars.armor.alignment.horizontal == 'right' then
										table.stored[player]['health_text'].text.Position = udim_2(0, (position.X + (screen_size * 0.65) + 34) - 4, 0, position.Y + (screen_size - (screen_size * health_ratio + 55)))
									end
								end
                            elseif table.visuals.esp.bars.health.alignment.vertical == 'bottom' then
                                if table.visuals.esp.bars.health.alignment.horizontal == 'center' then
                                    local health_bar_width = size.X * health_ratio
                                    table.stored[player]['health_text'].text.Position =  udim_2(0, position.X + health_bar_width + 18, 0, bottom.Y - 54)
                                end
							end
                        end
                    else
                        table.stored[player]['health_text'].text.Visible = false
                    end]]
                    if table.visuals.esp.bars.armor.enable and humanoid then
                        if table.stored[player] and table.stored[player]['armor_bar'] then
                            if not humanoid then
                                table.stored[player]['health_bar'].square.Visible = false
                                table.stored[player]['health_bar'].square_outline.Visible = false
                            else
                                table.stored[player]['health_bar'].square.Visible = true
                                table.stored[player]['health_bar'].square_outline.Visible = true
                            end
                            local armor_bar_width;
                            local armor_ratio;
                            
                            if current_game.Name == "Da Strike" then
                                if player.Character then
                                    local armor = player.Character:GetAttribute("Armor")
                                    if armor and armor > 0 then
                                        local max_armor = 100
                                        armor_ratio = armor / max_armor
                                    else
                                        armor_ratio = 0
                                    end
                                end
                            elseif current_game.Name == "Da Hood" then
                                if player.Character and player.Character:FindFirstChild("BodyEffects") then
                                    local armor_obj = player.Character.BodyEffects:FindFirstChild("Armor")
                                    if armor_obj and armor_obj.Value and armor_obj.Value > 0 then
                                        local max_armor = 200
                                        armor_ratio = armor_obj.Value / max_armor
                                    else
                                        armor_ratio = 0
                                    end
                                end
                            else 
                                table.visuals.esp.bars.armor.enable = false
                            
                                if table.stored[player] and table.stored[player]["armor_bar"] then
                                    table.stored[player]["armor_bar"].square.Visible = false
                                    table.stored[player]["armor_bar"].square_outline.Visible = false
                                end
                            end
                            if armor_ratio then
                                armor_bar_width = (size.X * armor_ratio)
                            end
                            if table.visuals.esp.bars.armor.alignment.vertical == 'bottom' then
                                if table.visuals.esp.bars.armor.alignment.horizontal == 'center' then
                                    table.stored[player]['armor_bar'].square.Position = vec_2(position.X, bottom.Y + 3) + vec_2(-1, 1)
                                    table.stored[player]['armor_bar'].square.Size = vec_2(armor_bar_width + 1, 2)
                                    table.stored[player]['armor_bar'].square.Color = table.visuals.esp.bars.armor.colors.main
                                    table.stored[player]['armor_bar'].square.Filled = true
                                    table.stored[player]['armor_bar'].square.Visible = true

                                    table.stored[player]['armor_bar'].square_outline.Position = vec_2(position.X, bottom.Y + 3) - vec_2(1, 0)
                                    table.stored[player]['armor_bar'].square_outline.Size = vec_2(armor_bar_width + 2, 4)
                                    table.stored[player]['armor_bar'].square_outline.Color = table.visuals.esp.bars.armor.colors.outline
                                    table.stored[player]['armor_bar'].square_outline.Visible = true

                                    if table.stored[player]['health_bar'] and table.visuals.esp.bars.health.alignment.vertical == 'bottom' and table.visuals.esp.bars.health.alignment.horizontal == 'center' then
                                        table.stored[player]['armor_bar'].square.Position = vec_2(position.X + (size.X / 2) - (armor_bar_width / 2), bottom.Y + 9) + vec_2(-1, 1)
                                        table.stored[player]['armor_bar'].square_outline.Position = vec_2(position.X + (size.X / 2) - (armor_bar_width / 2), bottom.Y + 9) - vec_2(1, 0)
                                    end
                                end
                            elseif table.visuals.esp.bars.armor.alignment.vertical == 'top' and armor_ratio then
                                if table.visuals.esp.bars.armor.alignment.horizontal == 'left' then

                                    table.stored[player]['armor_bar'].square.Position = vec_2(position.X - 2 - 9, position.Y + (screen_size - (screen_size * armor_ratio + 1))) - vec_2(2, 0)  -- Changed from -2-2 to -2-9 (7px left)
                                    table.stored[player]['armor_bar'].square.Size = vec_2(2, (screen_size * armor_ratio + 1))
                                    table.stored[player]['armor_bar'].square.Color = table.visuals.esp.bars.armor.colors.main
                                    table.stored[player]['armor_bar'].square.Filled = true
                                    table.stored[player]['armor_bar'].square.ZIndex = 9e9
                                    table.stored[player]['armor_bar'].square.Visible = true

                                    table.stored[player]['armor_bar'].square_outline.Position = vec_2(position.X - 2 - 8, position.Y + (screen_size - (screen_size * armor_ratio + 1))) - vec_2(4, 0)  -- Changed from -2-1 to -2-8 (7px left)
                                    table.stored[player]['armor_bar'].square_outline.Size = vec_2(2, (screen_size * armor_ratio + 1)) + vec_2(2, 1)
                                    table.stored[player]['armor_bar'].square_outline.Color = table.visuals.esp.bars.armor.colors.outline
                                    table.stored[player]['armor_bar'].square_outline.Visible = true

                                elseif table.visuals.esp.bars.armor.alignment.horizontal == 'right' then
                                    table.stored[player]['armor_bar'].square.Position = vec_2((position.X + (screen_size * 0.65) + 10) - 4, position.Y + (screen_size - (screen_size * armor_ratio + 1))) - vec_2(2, -1)
                                    table.stored[player]['armor_bar'].square.Size = vec_2(2, (screen_size * armor_ratio + 1) - 1)
                                    table.stored[player]['armor_bar'].square.Color = table.visuals.esp.bars.armor.colors.main
                                    table.stored[player]['armor_bar'].square.Filled = true
                                    table.stored[player]['armor_bar'].square.ZIndex = 9e9
                                    table.stored[player]['armor_bar'].square.Visible = true

                                    table.stored[player]['armor_bar'].square_outline.Position = vec_2((position.X + (screen_size * 0.65) + 10) - 2 - 1, position.Y + (screen_size - (screen_size * armor_ratio + 1))) - vec_2(4, 0)
                                    table.stored[player]['armor_bar'].square_outline.Size = vec_2(4, (screen_size * armor_ratio + 1) + 1)
                                    table.stored[player]['armor_bar'].square_outline.Color = table.visuals.esp.bars.armor.colors.outline
                                    table.stored[player]['armor_bar'].square_outline.Visible = true

                                    if table.stored[player]['health_bar'] and table.visuals.esp.bars.health.alignment.vertical == 'top' and table.visuals.esp.bars.health.alignment.horizontal == 'right' then
                                        table.stored[player]['armor_bar'].square.Position = vec_2((position.X + (screen_size * 0.65) + 10) + 2, position.Y + (screen_size - (screen_size * armor_ratio + 1))) - vec_2(2, -1)
                                        table.stored[player]['armor_bar'].square_outline.Position = vec_2((position.X + (screen_size * 0.65) + 10) + 4 - 1, position.Y + (screen_size - (screen_size * armor_ratio + 1))) - vec_2(4, 0)
                                    end
                                end
                            end
                        end
                    else
                        if table.stored[player] and table.stored[player]['armor_bar'] and table.stored[player]['armor_bar'].square then
                            table.stored[player]['armor_bar'].square.Visible = false
                        end
                    end

                    --[[if table.visuals.esp.texts.armor.enable and humanoid then
                        if table.stored[player] and table.stored[player]['armor_text'].text then
                            local armor_ratio;
                            
                            if current_game.Name == "Da Strike" then
                                if player.Character then
                                    local armor = player.Character:GetAttribute("Armor")
                                    if armor and armor > 0 then
                                        local max_armor = 100
                                        armor_ratio = armor / max_armor
                                    else
                                        armor_ratio = 0
                                    end
                                end
                            elseif current_game.Name == "Da Hood" then
                                if player.Character and player.Character:FindFirstChild("BodyEffects") then
                                    local armor_obj = player.Character.BodyEffects:FindFirstChild("Armor")
                                    if armor_obj and armor_obj.Value and armor_obj.Value > 0 then
                                        local max_armor = 150
                                        armor_ratio = armor_obj.Value / max_armor
                                    else
                                        armor_ratio = 0
                                    end
                                end
                            else 
                                table.visuals.esp.bars.armor.enable = false
                            
                                if table.stored[player] and table.stored[player]["armor_bar"] then
                                    table.stored[player]["armor_bar"].square.Visible = false
                                    table.stored[player]["armor_bar"].square_outline.Visible = false
                                end
                            end

                            if armor_ratio then
                                table.stored[player]['armor_text'].text.Text = string.format("%d%%", math.floor(armor_ratio * 100))
                            end
                            table.stored[player]['armor_text'].text.TextSize = 12
                            table.stored[player]['armor_text'].text.AnchorPoint = vec_2(0.5, 0.5)
                            table.stored[player]['armor_text'].text.TextColor3 = Color3.fromRGB(0, 120, 255)
                            table.stored[player]['armor_text'].text.TextStrokeTransparency = 0;
                            table.stored[player]['armor_text'].text.FontFace = library.font
                            table.stored[player]['armor_text'].text.BackgroundTransparency = 1
                            table.stored[player]['armor_text'].text.ZIndex = (9e9)
                            table.stored[player]['armor_text'].text.Visible = true
                            
                            if table.visuals.esp.bars.armor.alignment.vertical == 'top' and armor_ratio then
                                if table.visuals.esp.bars.armor.alignment.horizontal == 'left' then
                                    table.stored[player]['armor_text'].text.Position = udim_2(0, position.X - 28, 0, position.Y + (screen_size - (screen_size * armor_ratio + 55)))
                                elseif table.visuals.esp.bars.armor.alignment.horizontal == 'right' then
                                    table.stored[player]['armor_text'].text.Position = udim_2(0, (position.X + (screen_size * 0.65) + 28) - 4, 0, position.Y + (screen_size - (screen_size * armor_ratio + 55)))
                                    if table.visuals.esp.bars.health.alignment.horizontal == 'right' then
                                        table.stored[player]['armor_text'].text.Position = udim_2(0, (position.X + (screen_size * 0.65) + 64) - 4, 0, position.Y + (screen_size - (screen_size * armor_ratio + 55)))
                                    end
                                end
                            end
                            if table.visuals.esp.bars.armor.alignment.vertical == 'bottom' and armor_ratio then
                                if table.visuals.esp.bars.armor.alignment.horizontal == 'center' then
                                    local armor_bar_width = size.X * armor_ratio
                                    table.stored[player]['armor_text'].text.Position = udim_2(0, position.X + armor_bar_width + 18, 0, bottom.Y - 48)
                                end
                            end
                        end
                    else
                        table.stored[player]['armor_text'].text.Visible = false
                    end]]

                    if table.visuals.esp.texts.name.enable then
                        if table.stored[player] and table.stored[player]['name_text'] and table.stored[player]['name_text'].text then
                            table.stored[player]['name_text'].text.Position = udim_2(0, position.X + (size.X / 2), 0, top.Y - 68)
                            table.stored[player]['name_text'].text.TextSize = 12
                            table.stored[player]['name_text'].text.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                            table.stored[player]['name_text'].text.Size = udim_2(0, 20, 0, 20)
                            table.stored[player]['name_text'].text.AnchorPoint = vec_2(0.5, 0.5)
                            table.stored[player]['name_text'].text.TextColor3 = table.visuals.esp.texts.name.colors.main
                            table.stored[player]['name_text'].text.TextStrokeTransparency = 0;
                            table.stored[player]['name_text'].text.FontFace = library.font
                            table.stored[player]['name_text'].text.BackgroundTransparency = 1
                            table.stored[player]['name_text'].text.Visible = true
                            table.stored[player]['name_text'].text.ZIndex = (9e9^9e9)
                        end
                    else
                        if table.stored[player] and table.stored[player]['name_text'] and table.stored[player]['name_text'].text then
                            table.stored[player]['name_text'].text.Visible = false
                        end
                    end

                    if table.visuals.esp.texts.distance.enable and client_root_part then
                        if table.stored[player] and table.stored[player]['distance_text'] and table.stored[player]['distance_text'].text then
                            local distance = (client_root_part.Position - root_part.Position).Magnitude
                            local distance_text_position;
                            if (table.visuals.esp.bars.armor.alignment.vertical == 'bottom' and table.visuals.esp.bars.armor.alignment.horizontal == 'center') or
                            (table.visuals.esp.bars.health.alignment.vertical == 'bottom' and table.visuals.esp.bars.health.alignment.horizontal == 'center') then
                             distance_text_position = udim_2(0, position.X + (size.X / 2), 0, bottom.Y - (table.visuals.esp.bars.armor.alignment.vertical == 'bottom' and 
                                                                                                              table.visuals.esp.bars.armor.alignment.horizontal == 'center' and 
                                                                                                              table.visuals.esp.bars.health.alignment.vertical == 'bottom' and 
                                                                                                              table.visuals.esp.bars.health.alignment.horizontal == 'center' and 38 or 52))
                         else
                             distance_text_position = udim_2(0, position.X + (size.X / 2), 0, bottom.Y - 48)
                         end
                         
                            table.stored[player]['distance_text'].text.Position = distance_text_position
                            table.stored[player]['distance_text'].text.TextSize = 12
                            table.stored[player]['distance_text'].text.Text = string.format("%.0f stds", distance)
                            table.stored[player]['distance_text'].text.Size = udim_2(0, 20, 0, 20)
                            table.stored[player]['distance_text'].text.AnchorPoint = vec_2(0.5, 0.5)
                            table.stored[player]['distance_text'].text.TextColor3 = table.visuals.esp.texts.distance.colors.main
                            table.stored[player]['distance_text'].text.TextStrokeTransparency = 0
                            table.stored[player]['distance_text'].text.FontFace = library.font
                            table.stored[player]['distance_text'].text.BackgroundTransparency = 1
                            table.stored[player]['distance_text'].text.Visible = true
                        end
                    else
                        if table.stored[player] and table.stored[player]['distance_text'] and table.stored[player]['distance_text'].text then
                            table.stored[player]['distance_text'].text.Visible = false
                        end
                    end
                    if table.visuals.esp.texts.tool.enable and client_root_part then
                        if table.stored[player] and table.stored[player]['tool_text'] and table.stored[player]['tool_text'].text then
                            local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
                            if tool then
                                tool = tool.Name
                            else
                                tool = 'none'
                            end
                            local tool_text_position;
                            tool_text_position = udim_2(0, position.X + (size.X / 2), 0, bottom.Y - ((  
                                ((table.visuals.esp.bars.armor.alignment.vertical == 'bottom' and table.visuals.esp.bars.armor.alignment.horizontal == 'center') or  
                                (table.visuals.esp.bars.health.alignment.vertical == 'bottom' and table.visuals.esp.bars.health.alignment.horizontal == 'center')) and 26 or 38)))
                            

                            table.stored[player]['tool_text'].text.Position = tool_text_position
                            table.stored[player]['tool_text'].text.TextSize = 12
                            table.stored[player]['tool_text'].text.Text = tool
                            table.stored[player]['tool_text'].text.Size = udim_2(0, 20, 0, 20)
                            table.stored[player]['tool_text'].text.AnchorPoint = vec_2(0.5, 0.5)
                            table.stored[player]['tool_text'].text.TextColor3 = table.visuals.esp.texts.tool.colors.main
                            table.stored[player]['tool_text'].text.TextStrokeTransparency = 0
                            table.stored[player]['tool_text'].text.FontFace = library.font
                            table.stored[player]['tool_text'].text.BackgroundTransparency = 1
                            table.stored[player]['tool_text'].text.Visible = true
                        end
                    else
                        if table.stored[player] and table.stored[player]['distance_text'] and table.stored[player]['distance_text'].text then
                            table.stored[player]['distance_text'].text.Visible = false
                        end
                    end
                    if table.visuals.esp.boxes['2D'].enable and table.visuals.esp.boxes['2D'].type == 'full' and table.visuals.esp.boxes['2D'].render == 'dynamic' then
                        if table.stored[player] and table.stored[player]['2D'] and table.stored[player]['2D']['full'] and table.stored[player]['2D']['full']['dynamic'] then
                            table.stored[player]['2D']['full']['dynamic'].square.Position = position
                            table.stored[player]['2D']['full']['dynamic'].square.Color = table.visuals.esp.boxes['2D'].colors.main
                            table.stored[player]['2D']['full']['dynamic'].square.Size = size
                            table.stored[player]['2D']['full']['dynamic'].square.ZIndex = (9e9)
                            table.stored[player]['2D']['full']['dynamic'].square.Visible = true
                    
                            table.stored[player]['2D']['full']['dynamic'].square_inline.Position = position + vec_2(1, 1)
                            table.stored[player]['2D']['full']['dynamic'].square_inline.Color = table.visuals.esp.boxes['2D'].colors.inline
                            table.stored[player]['2D']['full']['dynamic'].square_inline.Size = size - vec_2(2, 2)
                            table.stored[player]['2D']['full']['dynamic'].square_inline.Visible = true
                    
                            table.stored[player]['2D']['full']['dynamic'].square_outline.Position = position - vec_2(1, 1)
                            table.stored[player]['2D']['full']['dynamic'].square_outline.Color = table.visuals.esp.boxes['2D'].colors.outline
                            table.stored[player]['2D']['full']['dynamic'].square_outline.Size = size + vec_2(2, 2)
                            table.stored[player]['2D']['full']['dynamic'].square_outline.Visible = true
                            
                            table.stored[player]['2D']['full']['dynamic'].gradient.ZIndex = -9e9
                            table.stored[player]['2D']['full']['dynamic'].gradient.Position = udim_2(0, table.stored[player]['2D']['full']['dynamic'].square_inline.Position.X, 0, table.stored[player]['2D']['full']['dynamic'].square_inline.Position.Y - 58);
                            table.stored[player]['2D']['full']['dynamic'].gradient.Size =  udim_2(0, table.stored[player]['2D']['full']['dynamic'].square_inline.Size.X, 0, table.stored[player]['2D']['full']['dynamic'].square_inline.Size.Y)
                            table.stored[player]['2D']['full']['dynamic'].gradient.Visible = true;
                            
                            if table.visuals.esp.boxes['2D'].filled.enable then
                                local player_data = table.stored[player]
                                local dynamic = player_data and player_data['2D'] and player_data['2D']['full'] and player_data['2D']['full']['dynamic']
                            
                                if dynamic then
                                    if table.visuals.esp.boxes['2D'].filled.gradient.enable then
                                        dynamic.square.Filled = false
                            
                                        if not dynamic.gradient:FindFirstChild("UIGradient") then
                                            local ui_gradient = Instance.new("UIGradient")
                                            ui_gradient.Name = "UIGradient"
                                            ui_gradient.Parent = dynamic.gradient
                                        end
                            
                                        local ui_gradient = dynamic.gradient:FindFirstChild("UIGradient")
                                        if ui_gradient then
                                            ui_gradient.Color = ColorSequence.new({
                                                ColorSequenceKeypoint.new(0, table.visuals.esp.boxes['2D'].filled.gradient.colors["1"]),
                                                ColorSequenceKeypoint.new(1, table.visuals.esp.boxes['2D'].filled.gradient.colors["2"])
                                            })
                                            ui_gradient.Rotation = table.visuals.esp.boxes['2D'].filled.gradient.rotation or 90
                                            ui_gradient.Transparency = NumberSequence.new(table.visuals.esp.boxes['2D'].filled.gradient.transparency)
                                            dynamic.gradient.Visible = true
                                        end
                                    else
                                        dynamic.square.Filled = true
                                        dynamic.gradient.Visible = false
                                    end
                                end
                            end
                            
                        end
                    end
                else
                    utility.funcs.universal.visuals.clear_esp(player)
                end
            else
                utility.funcs.universal.visuals.clear_esp(player)
            end
        end
    end
    

    utility.funcs.universal.visuals.remove_framework = function(player)
        
        utility.funcs.universal.visuals.clear_esp(player)

        if table.stored[player]['2D'] and table.stored[player]['2D']['full'] then
            for _, v in pairs(table.stored[player]['2D']['full']['dynamic']) do
                v.Visible = false
                if v.Remove then
                    v:Remove()
                else
                    v:Destroy()
                end
            end
        end

        if table.stored[player]['name_text'] and table.stored[player]['name_text'].text then
            table.stored[player]['name_text'].text.Visible = false
            table.stored[player]['name_text'].text:Remove()
        end
    
        if table.stored[player]['distance_text'] and table.stored[player]['distance_text'].text then
            table.stored[player]['distance_text'].text.Visible = false
            table.stored[player]['distance_text'].text:Remove()
        end
    
        if table.stored[player]['tool_text'] and table.stored[player]['tool_text'].text then
            table.stored[player]['tool_text'].text.Visible = false
            table.stored[player]['tool_text'].text:Remove()
        end
    
        if table.stored[player]['armor_bar'] then
            table.stored[player]['armor_bar'].square.Visible = false
            table.stored[player]['armor_bar'].square_outline.Visible = false
            table.stored[player]['armor_bar'].square:Remove()
            table.stored[player]['armor_bar'].square_outline:Remove()
        end
    
        if table.stored[player]['health_bar'] then
            table.stored[player]['health_bar'].square.Visible = false
            table.stored[player]['health_bar'].square_outline.Visible = false
            table.stored[player]['health_bar'].square:Remove()
            table.stored[player]['health_bar'].square_outline:Remove()
        end

        table.stored[player] = nil
    end


    shared.connections['player_removing'] = shared.connections['player_removing'] or players.PlayerRemoving:Connect(function(player)
        if table.stored[player] then
            utility.funcs.universal.visuals.remove_framework(player)
            table.stored[player] = nil
        end
    end)
    
    if not table.stored.fov then
        table.funcs.create_fov()
    end
    
    players.PlayerAdded:Connect(function(player)
        if not table.stored[player] then
            utility.funcs.universal.visuals.add_framework(player)
        end
        player.CharacterAdded:Connect(function()
            utility.funcs.universal.visuals.update_framework(player)
        end)
    end)
    
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= client then
            if not table.stored[player] then
                utility.funcs.universal.visuals.add_framework(player)
            end
        end
    end
    
    --utility.funcs.universal.create_hiteffect()
    if not shared.connections.loops.visuals then
        shared.connections.loops.visuals = run_service.PreRender:Connect(function()
            if not table.stored.fov then
                table.funcs.create_fov()
            else
                table.funcs.update_fov()
            end
    
            if table.visuals.enable then
                for _, player in ipairs(players:GetPlayers()) do
                    if player ~= client then
                        if not table.stored[player] then
                            utility.funcs.universal.visuals.add_framework(player)
                        end
                        utility.funcs.universal.visuals.update_framework(player)
                    end
                end
            end
        end)
    end
end
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if table.visuals.esp.boxes['2D'].filled.gradient.autorotation then
        table.visuals.esp.boxes['2D'].filled.gradient.rotation += 2
    end
end)

local column = Visuals:column()
local section = column:section({name = "esp"})

section:toggle({name = "enabled", flag = "esp_enabled", callback = function(Value)
    table.visuals.esp.enable = Value
end})

section:toggle({name = "box", flag = "boxes_enabled", callback = function(Value)
    table.visuals.esp.boxes['2D'].enable = Value
end}):colorpicker({name = "main", flag = "boxcolor", color = rgb(255, 255, 255), callback = function(Value, alpha)
    table.visuals.esp.boxes['2D'].colors.main = Value
end}):colorpicker({name = "online", flag = "boxinlinecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.boxes['2D'].colors.inline = Value
end}):colorpicker({name = "outline", flag = "boxoutlinecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.boxes['2D'].colors.outline = Value
end})

section:toggle({name = "gradient fill box", flag = "gradientfillboxes", callback = function(Value)
    table.visuals.esp.boxes['2D'].filled.enable = Value
end}):colorpicker({name = "first", flag = "gradientfillboxescolor1", color = rgb(155, 125, 175), callback = function(Value, alpha)
    table.visuals.esp.boxes['2D'].filled.gradient.colors["1"] = Value
end}):colorpicker({name = "second", flag = "gradientfillboxescolor2", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.boxes['2D'].filled.gradient.colors["2"] = Value
end})

section:slider({name = "fill transparency", min = 0, max = 1, default = 0.5, interval = 0.1, flag = "boxfilltransparency", callback = function(Value)
    table.visuals.esp.boxes['2D'].filled.gradient.transparency = Value
end})

section:slider({name = "gradient rotation", min = 0, max = 360, default = 45, interval = 1, flag = "boxgradientrotation", callback = function(Value)
    table.visuals.esp.boxes['2D'].filled.gradient.rotation = Value
end})

section:toggle({name = "auto rotation", flag = "boxgradientautorotation", callback = function(Value)
    table.visuals.esp.boxes['2D'].filled.gradient.autorotation = Value
end})

section:toggle({name = "name", flag = "names_enabled", callback = function(Value)
    table.visuals.esp.texts.name.enable = Value
end}):colorpicker({name = "main", flag = "namecolor", color = rgb(255, 255, 255), callback = function(Value, alpha)
    table.visuals.esp.texts.name.colors.main = Value
end}):colorpicker({name = "stroke", flag = "namestrokecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.texts.name.colors.stroke = Value
end})

section:toggle({name = "healthbar", flag = "healthbars_enabled", callback = function(Value)
    table.visuals.esp.bars.health.enable = Value
end}):colorpicker({name = "main", flag = "healthbarcolor", color = rgb(0, 255, 0), callback = function(Value, alpha)
    table.visuals.esp.bars.health.colors.main = Value
end}):colorpicker({name = "outline", flag = "healthbaroutlinecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.bars.health.colors.outline = Value
end})

section:toggle({name = "armorbar", flag = "armorbars_enabled", callback = function(Value)
    table.visuals.esp.bars.armor.enable = Value
end}):colorpicker({name = "main", flag = "armorbarcolor", color = rgb(0, 0, 255), callback = function(Value, alpha)
    table.visuals.esp.bars.armor.colors.main = Value
end}):colorpicker({name = "outline", flag = "armorbaroutlinecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.bars.armor.colors.outline = Value
end})

section:toggle({name = "distance", flag = "distances_enabled", callback = function(Value)
    table.visuals.esp.texts.distance.enable = Value
end}):colorpicker({name = "main", flag = "distancecolor", color = rgb(255, 255, 255), callback = function(Value, alpha)
    table.visuals.esp.texts.distance.colors.main = Value
end}):colorpicker({name = "stroke", flag = "distancestrokecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.texts.distance.colors.stroke = Value
end})

section:toggle({name = "tool", flag = "tools_enabled", callback = function(Value)
    table.visuals.esp.texts.tool.enable = Value
end}):colorpicker({name = "main", flag = "toolespcolor", color = rgb(255, 255, 255), callback = function(Value, alpha)
    table.visuals.esp.texts.tool.colors.main = Value
end}):colorpicker({name = "stroke", flag = "toolespstrokecolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    table.visuals.esp.texts.tool.colors.stroke = Value
end})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ESP = headshots.ExtraESP

local originalStates = {}

local function applyMaterialAndHighlight(char)
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "CUFF" then
            if ESP.MaterialEnabled then
                obj.Material = Enum.Material.Neon
                obj.Color = ESP.MaterialColor
                if obj:IsA("MeshPart") then
                    obj.TextureID = ""
                end
            else
                if not originalStates[obj] then
                    originalStates[obj] = {Material = obj.Material, Color = obj.Color, TextureID = obj:IsA("MeshPart") and obj.TextureID or nil}
                end
                obj.Material = originalStates[obj].Material
                obj.Color = originalStates[obj].Color
                if obj:IsA("MeshPart") then
                    obj.TextureID = originalStates[obj].TextureID or ""
                end
            end
        elseif obj:IsA("SpecialMesh") then
            if ESP.MaterialEnabled then
                obj.TextureId = ""
            else
                obj.TextureId = ""
            end
        elseif obj:IsA("Decal") and obj.Name == "face" then
            if ESP.MaterialEnabled then
                obj:Destroy()
            end
        end
    end

    for _, className in ipairs({"Pants", "Shirt", "ShirtGraphic"}) do
        local clothing = char:FindFirstChildOfClass(className)
        if clothing then
            if ESP.MaterialEnabled then
                clothing:Destroy()
            end
        end
    end

    local highlight = char:FindFirstChildOfClass("Highlight")
    if ESP.HighlightEnabled then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = char
        end
        highlight.FillColor = ESP.HighlightFillColor
        highlight.OutlineColor = ESP.HighlightOutlineColor
        highlight.FillTransparency = 0
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
    elseif highlight then
        if highlight.FillColor == ESP.HighlightFillColor then
            highlight.Enabled = false
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                applyMaterialAndHighlight(player.Character)
            end
        end
    end
end)

section:toggle({
    name = "material",
    flag = "materialesp_enabled",
    callback = function(Value)
        headshots.ExtraESP.MaterialEnabled = Value
    end
}):colorpicker({
    name = "main",
    flag = "materialespcolor",
    color = Color3.fromRGB(255, 255, 255),
    callback = function(Value)
        headshots.ExtraESP.MaterialColor = Value
    end
})

section:dropdown({
    name = "material",
    flag = "materialesp_material",
    items = {"Neon", "ForceField", "Plastic", "SmoothPlastic", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "DiamondPlate", "Metal", "CorrodedMetal", "Foil", "Grass", "Sand", "Fabric", "Ice", "Glass", "Asphalt", "LeafyGrass", "Salt", "Snow", "Mud", "Ground", "Basalt", "CrackedLava"},
    default = "Neon",
    callback = function(Value)
        headshots.ExtraESP.Material = Value
    end
})

section:toggle({
    name = "highlight",
    flag = "highlightesp_enabled",
    callback = function(Value)
        headshots.ExtraESP.HighlightEnabled = Value
    end
}):colorpicker({
    name = "main",
    flag = "highlightfill_esp",
    color = Color3.fromRGB(0, 0, 0),
    callback = function(Value)
        headshots.ExtraESP.HighlightFillColor = Value
    end
}):colorpicker({
    name = "outline",
    flag = "highlightoutline_esp",
    color = Color3.fromRGB(0, 0, 0),
    callback = function(Value)
        headshots.ExtraESP.HighlightOutlineColor = Value
    end
})

local section = column:section({name = "player"})

section:toggle({name = "aura", flag = "aura_enabled", callback = function(Value)
    if getnamecallmethod then
        headshots.SelfVisuals.Aura = Value
    else
        library:notification({ text = "Your executor does not support this feature.", time = 3 })
    end
end}):colorpicker({name = "main", flag = "auracolor", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.SelfVisuals.AuraColor = Value
end})

section:dropdown({name = "aura", flag = "aura_material", scrolling = true, items = {"Pink Shyt"}, default = "Pink Shyt", callback = function(Value)
    headshots.SelfVisuals.AuraTexture = Value
end})

section:toggle({name = "walk steps", flag = "walksteps_enabled", callback = function(Value)
    if getnamecallmethod then
        headshots.SelfVisuals.WalkSteps = Value
    else
        library:notification({ text = "Your executor does not support this feature.", time = 3 })
    end
end}):colorpicker({name = "main", flag = "walkstepscolor", color = rgb(255, 255, 255), callback = function(Value, alpha)
    headshots.SelfVisuals.WalkStepsColor = Value
end})

section:slider({name = "walksteps rate", min = 0, max = 3, default = 0.5, interval = 0.1, flag = "walkstepsrate", callback = function(Value)
    headshots.SelfVisuals.WalkStepsRate = Value
end})

section:slider({name = "walksteps size", min = 1, max = 10, default = 5, interval = 0.1, flag = "walkstepsize", callback = function(Value)
    headshots.SelfVisuals.WalkStepsSize = NumberSequence.new(
    0.1 * Value, 0.25 * Value, 0.5 * Value, 0.75 * Value, 1 * Value, 
    1.25 * Value, 1.5 * Value, 1.75 * Value, 2 * Value
    )

end})

local AnimationSpeed = 1

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://14352343065"

local animationTrack
local isPlaying = false
local flossEnabled = false

local function loadAnimationTrack(character)
    local humanoid = character:WaitForChild("Humanoid")
    if animationTrack then
        animationTrack:Stop()
    end
    animationTrack = humanoid:LoadAnimation(animation)
    animationTrack.Looped = true
    animationTrack.Priority = Enum.AnimationPriority.Action
    
    if flossEnabled then
        task.wait(0.6)
        animationTrack:Play()
        animationTrack:AdjustSpeed(AnimationSpeed)
        isPlaying = true
    end
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    loadAnimationTrack(character)
end)

if game:GetService("Players").LocalPlayer.Character then
    loadAnimationTrack(game:GetService("Players").LocalPlayer.Character)
end

section:toggle({
    name = "animation player", 
    flag = "dance_enabled", 
    callback = function(Value)
        flossEnabled = Value
        if Value and animationTrack then
            animationTrack:Play()
            animationTrack:AdjustSpeed(AnimationSpeed)
            isPlaying = true
        elseif not Value and animationTrack then
            animationTrack:Stop()
            isPlaying = false
        end
    end
})

section:dropdown({
    name = "animation", 
    flag = "dance_id", 
    scrolling = true, 
    items = {
        "Baby Queen - Bouncy Twirl",
        "Floss", 
        "Yungblud Happier Jump",  
        "Godlike", 
        "Mae Stephens - Piano Hands", 
        "Victory Dance", 
        "Elton John - Heart Skip", 
        "Sturdy Dance - Ice Spice", 
        "Old Town Road Dance - Lil Nas X (LNX)"
    }, 
    default = "Baby Queen - Bouncy Twirl", 
    callback = function(Value)
        if Value == "Floss" then
            animation.AnimationId = "rbxassetid://10714340543"
        elseif Value == "Yungblud Happier Jump" then
            animation.AnimationId = "rbxassetid://15609995579"
        elseif Value == "Baby Queen - Bouncy Twirl" then
            animation.AnimationId = "rbxassetid://14352343065"
        elseif Value == "Godlike" then
            animation.AnimationId = "rbxassetid://10714347256"
        elseif Value == "Mae Stephens - Piano Hands" then
            animation.AnimationId = "rbxassetid://16553163212"
        elseif Value == "Victory Dance" then
            animation.AnimationId = "rbxassetid://15505456446"
        elseif Value == "Elton John - Heart Skip" then
            animation.AnimationId = "rbxassetid://11309255148"
        elseif Value == "Sturdy Dance - Ice Spice" then
            animation.AnimationId = "rbxassetid://17746180844"
        elseif Value == "Old Town Road Dance - Lil Nas X (LNX)" then
            animation.AnimationId = "rbxassetid://10714391240"
        end
        
        if game:GetService("Players").LocalPlayer.Character then
            loadAnimationTrack(game:GetService("Players").LocalPlayer.Character)
        end
    end
})

section:slider({name = "animation speed", min = 0, max = 10, default = 1, interval = 0.1, flag = "animationplayerspeed", callback = function(Value)
    AnimationSpeed = Value
    if animationTrack and isPlaying then
        animationTrack:AdjustSpeed(AnimationSpeed)
    end
end})

local UserID = 244844600

section:toggle({name = "avatar changer", flag = "avatarchanger_enabled", callback = function(Value)
    if game.Players.LocalPlayer.Character.Humanoid.HumanoidDescription.RightArm == 0 then
        if Value then
            for _, item in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("Accessory") then
                    item:Destroy()
                end
            end
        
            game.Players.LocalPlayer.Character.Humanoid:ApplyDescriptionClientServer(game.Players:GetHumanoidDescriptionFromUserId(UserID))
        else
            game.Players.LocalPlayer.Character.Humanoid:ApplyDescriptionClientServer(game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.UserId))
        end
    else
        library:notification({ text = "headshots.cc - 'Avatar Changer' Module requires you to use the 'Blocky / Default Packages' Right Arm. Please change your avatar.", time = 3 })
    end
end})

section:dropdown({name = "avatar", flag = "avatarchanger_avatar", scrolling = true, items = {"Nex5us", "dtbbullet", "asdfxdheh", "tul"}, default = "Nex5us", callback = function(Value)
    if Value == "Nex5us" then
        UserID = 244844600
    elseif Value == "dtbbullet" then
        UserID = 2395613299
    elseif Value == "asdfxdheh" then
        UserID = 2611320910
    elseif Value == "tul" then
        UserID = 2547639113
    end
end})

section:toggle({name = "character", flag = "charactermaterial_enabled", callback = function(Value)
    headshots.SelfVisuals.Character = Value
    if Value == false then
        for _, part in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
            end
        end
        ResetCharacterColors()
    end
end}):colorpicker({name = "main", flag = "charactercolor", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.SelfVisuals.CharacterColor = Value
end})


section:dropdown({name = "character Material", flag = "charactermaterial_material", scrolling = true, items = {"ForceField", "Neon", "Plastic", "SmoothPlastic", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "DiamondPlate", "Metal", "CorrodedMetal", "Foil", "Grass", "Sand", "Fabric", "Ice", "Glass", "Asphalt", "LeafyGrass", "Salt", "Snow", "Mud", "Ground", "Basalt", "CrackedLava"}, default = "ForceField", callback = function(Value)
    headshots.SelfVisuals.CharacterMaterial = Value
end})

section:toggle({name = "tool", flag = "toolmaterial_enabled", callback = function(Value)
    headshots.SelfVisuals.Tool = Value
    if Value == false and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        for _, part in ipairs(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"):GetChildren()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
            end
        end
        ResetToolColors()
    end
end}):colorpicker({name = "main", flag = "toolcolor", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.SelfVisuals.ToolColor = Value
end})

section:dropdown({name = "tool material", flag = "toolmaterial_material", scrolling = true, items = {"ForceField", "Neon", "Plastic", "SmoothPlastic", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "DiamondPlate", "Metal", "CorrodedMetal", "Foil", "Grass", "Sand", "Fabric", "Ice", "Glass", "Asphalt", "LeafyGrass", "Salt", "Snow", "Mud", "Ground", "Basalt", "CrackedLava"}, default = "ForceField", callback = function(Value)
    headshots.SelfVisuals.ToolMaterial = Value
end})

local column = Visuals:column()

local section = column:section({name = "bullet tracers"})

section:toggle({name = "enabled", flag = "bullettracers_enabled", callback = function(Value)
    if getnamecallmethod then
        headshots.BulletTracers.Enabled = Value
    else
        library:notification({ text = "Your executor does not support this feature.", time = 3 })
    end
end}):colorpicker({name = "main", flag = "bullettracercolor", color = rgb(155, 125, 175), callback = function(Value, alpha)
    headshots.BulletTracers.Color = Value
end})

section:dropdown({name = "texture", flag = "bullettracers_texture", scrolling = true, items = {"Beam", "Lightning", "Heartrate", "Chain", "Glitch", "Swirl" }, default = "Beam", callback = function(Value)
    if Value == "Beam" then
        headshots.BulletTracers.TextureID = "rbxassetid://12781852245"
    elseif Value == "Lightning" then
        headshots.BulletTracers.TextureID = "rbxassetid://446111271"
    elseif Value == "Heartrate" then
        headshots.BulletTracers.TextureID = "rbxassetid://5830549480"
    elseif Value == "Chain" then
        headshots.BulletTracers.TextureID = "rbxassetid://9632168658"
    elseif Value == "Glitch" then
        headshots.BulletTracers.TextureID = "rbxassetid://8089467613"
    elseif Value == "Swirl" then
        headshots.BulletTracers.TextureID = "rbxassetid://5638168605"
    end
end})

section:slider({name = "size", min = 0.1, max = 3, default = 0.4, interval = 0.01, flag = "bullettracers_size", callback = function(Value)
    headshots.BulletTracers.Size = Value
end})

section:slider({name = "transparency", min = 0, max = 1, default = 0, interval = 0.01, flag = "bullettracers_transparency", callback = function(Value)
    headshots.BulletTracers.Transparency = Value
end})

section:slider({name = "time alive", min = 1, max = 10, default = 3, interval = 1, flag = "bullettracers_timealive", callback = function(Value)
    headshots.BulletTracers.TimeAlive = Value
end})


local section = column:section({name = "world"})

section:label({name = "ambient color"}):colorpicker({name = "main", flag = "ambientcolor", color = rgb(155, 125, 175), callback = function(Value, alpha)
    LightingSettings.CustomAmbient = Value
end})

section:label({name = "custom outdoor ambient"}):colorpicker({name = "main", flag = "customoutdoorambientcolor", color = rgb(0, 0 ,0), callback = function(Value, alpha)
    LightingSettings.CustomOutdoorAmbient = Value
end})

section:slider({name = "exposure compensation", min = -3, max = 3, default = 3, interval = 0.1, flag = "exposurecompensation", callback = function(Value)
    LightingSettings.CustomExposureCompensation = Value
end})

section:slider({name = "fog start", min = 0, max = 100, default = 0, interval = 1, flag = "fog_start", callback = function(Value)
    LightingSettings.CustomFogStart = Value
end})

section:slider({name = "fog end", min = 0, max = 1000, default = 500, interval = 1, flag = "fog_end", callback = function(Value)
    LightingSettings.CustomFogEnd = Value
end})

section:label({name = "fog color"}):colorpicker({name = "main", flag = "fogcolor", color = rgb(0, 0, 0), callback = function(Value, alpha)
    LightingSettings.CustomFogColor = Value
end})

section:slider({name = "brightness", min = 0, max = 10, default = 0, interval = 0.01, flag = "brightness", callback = function(Value)
    LightingSettings.CustomBrightness = Value
end})

section:slider({name = "clocktime", min = 0, max = 25, default = 0, interval = 1, flag = "clocktime", callback = function(Value)
    LightingSettings.CustomClockTime = Value
end})

section:toggle({name = "use custom lightning modifications", flag = "lightning_modifications", callback = function(Value)
    LightingModifications = Value
    if Value == false then
        lighting.Ambient = LightingSettings.DefaultAmbient
        lighting.OutdoorAmbient = LightingSettings.DefaultOutdoorAmbient
        lighting.FogStart = LightingSettings.DefaultFogStart
        lighting.FogEnd = LightingSettings.DefaultFogEnd
        lighting.FogColor = LightingSettings.DefaultFogColor
        lighting.Brightness = LightingSettings.DefaultBrightness

        lighting.Sky.SkyboxBk = LightingSettings.DefaultSkyboxBk
        lighting.Sky.SkyboxDn = LightingSettings.DefaultSkyboxDn
        lighting.Sky.SkyboxFt = LightingSettings.DefaultSkyboxFt
        lighting.Sky.SkyboxLf = LightingSettings.DefaultSkyboxLf
        lighting.Sky.SkyboxRt = LightingSettings.DefaultSkyboxRt
        lighting.Sky.SkyboxUp = LightingSettings.DefaultSkyboxUp
    end
end})

local DefaultSky = lighting:FindFirstChildOfClass("Sky")
local LightingSettings = {}

if DefaultSky then
    LightingSettings.DefaultSkyboxBk = DefaultSky.SkyboxBk
    LightingSettings.DefaultSkyboxDn = DefaultSky.SkyboxDn
    LightingSettings.DefaultSkyboxFt = DefaultSky.SkyboxFt
    LightingSettings.DefaultSkyboxLf = DefaultSky.SkyboxLf
    LightingSettings.DefaultSkyboxRt = DefaultSky.SkyboxRt
    LightingSettings.DefaultSkyboxUp = DefaultSky.SkyboxUp
end

local customSkyInstance = nil

local SkyboxAssets = {
    ["Black Storm"] = {
        Bk = "rbxassetid://15502511288",
        Dn = "rbxassetid://15502508460",
        Ft = "rbxassetid://15502510289",
        Lf = "rbxassetid://15502507918",
        Rt = "rbxassetid://15502509398",
        Up = "rbxassetid://15502511911"
    },
    ["Blue Space"] = {
        Bk = "rbxassetid://15536110634",
        Dn = "rbxassetid://15536112543",
        Ft = "rbxassetid://15536116141",
        Lf = "rbxassetid://15536114370",
        Rt = "rbxassetid://15536118762",
        Up = "rbxassetid://15536117282"
    },
    ["Realistic"] = {
        Bk = "rbxassetid://653719502",
        Dn = "rbxassetid://653718790",
        Ft = "rbxassetid://653719067",
        Lf = "rbxassetid://653719190",
        Rt = "rbxassetid://653718931",
        Up = "rbxassetid://653719321"
    },
    ["Stormy"] = {
        Bk = "http://www.roblox.com/asset/?id=18703245834",
        Dn = "http://www.roblox.com/asset/?id=18703243349",
        Ft = "http://www.roblox.com/asset/?id=18703240532",
        Lf = "http://www.roblox.com/asset/?id=18703237556",
        Rt = "http://www.roblox.com/asset/?id=18703235430",
        Up = "http://www.roblox.com/asset/?id=18703232671"
    },
    ["Pink"] = {
        Bk = "rbxassetid://12216109205",
        Dn = "rbxassetid://12216109875",
        Ft = "rbxassetid://12216109489",
        Lf = "rbxassetid://12216110170",
        Rt = "rbxassetid://12216110471",
        Up = "rbxassetid://12216108877"
    }
}

local function applyCustomSkybox(name)
    if customSkyInstance then
        customSkyInstance:Destroy()
    end

    customSkyInstance = Instance.new("Sky")
    local sky = SkyboxAssets[name]

    customSkyInstance.SkyboxBk = sky.Bk
    customSkyInstance.SkyboxDn = sky.Dn
    customSkyInstance.SkyboxFt = sky.Ft
    customSkyInstance.SkyboxLf = sky.Lf
    customSkyInstance.SkyboxRt = sky.Rt
    customSkyInstance.SkyboxUp = sky.Up
    customSkyInstance.Name = "CustomSky"

    customSkyInstance.Parent = lighting
end

local function restoreDefaultSkybox()
    if customSkyInstance then
        customSkyInstance:Destroy()
        customSkyInstance = nil
    end

    if DefaultSky then
        DefaultSky.SkyboxBk = LightingSettings.DefaultSkyboxBk
        DefaultSky.SkyboxDn = LightingSettings.DefaultSkyboxDn
        DefaultSky.SkyboxFt = LightingSettings.DefaultSkyboxFt
        DefaultSky.SkyboxLf = LightingSettings.DefaultSkyboxLf
        DefaultSky.SkyboxRt = LightingSettings.DefaultSkyboxRt
        DefaultSky.SkyboxUp = LightingSettings.DefaultSkyboxUp
        DefaultSky.Parent = lighting
    end
end

section:toggle({
    name = "custom skybox",
    flag = "customskybox_enabled",
    callback = function(Value)
        if Value then
            applyCustomSkybox(SelectedSkybox)
        else
            restoreDefaultSkybox()
        end
    end
})

section:dropdown({
    name = "skybox",
    flag = "skybox_selected",
    scrolling = true,
    items = {"Black Storm", "Blue Space", "Realistic", "Stormy", "Pink"},
    default = "Black Storm",
    callback = function(Value)
        SelectedSkybox = Value

        if library.flags.customskybox_enabled then
            applyCustomSkybox(SelectedSkybox)
        end
    end
})

-- // Misc // --

local column = Misc:column()
local section = column:section({name = "movement"})

section:toggle({name = "flyhack", flag = "fly_enabled", callback = function(Value)
    headshots.Fly.Enabled = Value
end}):keybind({name = "flyhack", flag = "fly_bind", callback = function(Value)
    if headshots.Fly.Enabled then
        headshots.Fly.Keybind = Value
    end
end})

section:slider({name = "fly speed", min = 1, max = 100, default = 20, interval = 1, flag = "fly_speed", callback = function(Value)
    headshots.Fly.Speed = Value
end})

section:toggle({name = "speedhack", flag = "speed_enabled", callback = function(Value)
    headshots.Speed.Enabled = Value
end}):keybind({name = "speedhack", flag = "speed_bind", callback = function(Value)
    if headshots.Speed.Enabled then
        headshots.Speed.Keybind = Value
    end
end})

section:slider({name = "speed speed", min = 1, max = 100, default = 20, interval = 1, flag = "speed_speed", callback = function(Value)
    headshots.Speed.Speed = Value
end})

local section = column:section({name = "quick buy"})

section:dropdown({
    name = "gun",
    items = {
        '[Rifle]',
        '[LMG]',
        '[AK47]',
        '[AUG]',
        '[AR]',
        '[Double-Barrel SG]',
        '[Drum-Shotgun]',
        '[DrumGun]',
        '[Glock]',
        '[P90]',
        '[Revolver]',
        '[RPG]',
        '[Shotgun]',
        '[Silencer]',
        '[SilencerAR]',
        '[TacticalShotgun]',
    },
    default = "[Rifle]",
    flag = "quickbuygun",
    scrolling = true,
    callback = function(Value)
        SelectedGun = Value
    end
})


section:button_holder({})
section:button({name = "buy selected gun", callback = function()
    BuyingSingle = true
end})

section:toggle({name = "buy ammo", flag = "buyingammo", callback = function(Value)
    BuyingAmmo = Value
end})


local section = column:section({name = "auto buys"})

section:toggle({name = "auto loadout", flag = "autoloadout_enabled", callback = function(Value)
    headshots.AutoLoadout.Enabled = Value
end})

section:dropdown({
    name = "gun",
    items = {
        '[Rifle]',
        '[LMG]',
        '[AK47]',
        '[AUG]',
        '[AR]',
        '[Double-Barrel SG]',
        '[Drum-Shotgun]',
        '[DrumGun]',
        '[Glock]',
        '[P90]',
        '[Revolver]',
        '[RPG]',
        '[Shotgun]',
        '[Silencer]',
        '[SilencerAR]',
        '[TacticalShotgun]',
    },
    default = "[Rifle]",
    flag = "autoloadoutgun",
    scrolling = true,
    callback = function(Value)
        headshots.AutoLoadout.Gun = Value
    end
})

section:toggle({name = "auto armor", flag = "autoarmor_enabled", callback = function(Value)
    headshots.AutoArmor.Enabled = Value
end})

local section = column:section({name = "money"})

section:button_holder({})
section:button({
    name = "redeem all codes",
    callback = function()
        local codes = { "TRADEME!", "DAUP", "pumpkins2023", "DACARNIVAL", "THANKSGIVING24", "HALLOWEEN2024", "RUBY", "SHRIMP", "VIP", "2025", "Duck", "Watch", "Quack", "Easter25", "Sushi", "HOUSE" }
        
        local successfulCodes = {}
        
        local function redeemCode(code)
            local args = {
                [1] = "EnterPromoCode",
                [2] = code
            }
        
            MainEvent:FireServer(unpack(args))
        
            local successIndicator = false
            MainEvent.OnClientEvent:Connect(function(response)
                if response == "CodeRedeemed" then
                    successIndicator = true
                end
            end)
        
            wait(1.5)
        
            if successIndicator then
                table.insert(successfulCodes, code)
            end
        end
        
        for _, code in ipairs(codes) do
            redeemCode(code)
        end
    end
})

local section = column:section({name = "animations"})

local Playerslol = game:GetService("Players")
local player = Playerslol.LocalPlayer

local animationBaseUrl = "http://www.roblox.com/asset/?id="

animations = {
    Rthro = {
        idle = animationBaseUrl .. "2510196951",
        walk = animationBaseUrl .. "2510202577",
        run = animationBaseUrl .. "2510198475",
        jump = animationBaseUrl .. "2510197830",
        climb = animationBaseUrl .. "2510192778",
        fall = animationBaseUrl .. "2510195892",
    },
    DaHoodian = {
        idle = animationBaseUrl .. "782841498",
        walk = animationBaseUrl .. "616168032",
        run = animationBaseUrl .. "616163682",
        jump = animationBaseUrl .. "1083218792",
        climb = animationBaseUrl .. "1083439238",
        fall = animationBaseUrl .. "707829716",
    },
    Astronaut = {
        idle = animationBaseUrl .. "891621366",
        jump = animationBaseUrl .. "891627522",
        fall = animationBaseUrl .. "891617961",
        walk = animationBaseUrl .. "891667138",
        run = animationBaseUrl .. "891636393",
        climb = animationBaseUrl .. "891609353",
    },
    Bubbly = {
        idle = animationBaseUrl .. "910004836",
        jump = animationBaseUrl .. "910016857",
        fall = animationBaseUrl .. "910001910",
        walk = animationBaseUrl .. "910034870",
        run = animationBaseUrl .. "910025107",
        climb = animationBaseUrl .. "940996062",
    },
    Cartoony = {
        idle = animationBaseUrl .. "742637544",
        jump = animationBaseUrl .. "742637942",
        fall = animationBaseUrl .. "742637151",
        walk = animationBaseUrl .. "742640026",
        run = animationBaseUrl .. "742638842",
        climb = animationBaseUrl .. "742636889",
    },
    Confident = {
        idle = animationBaseUrl .. "1069977950",
        jump = animationBaseUrl .. "1069984524",
        fall = animationBaseUrl .. "1069973677",
        walk = animationBaseUrl .. "1070017263",
        run = animationBaseUrl .. "1070001516",
        climb = animationBaseUrl .. "1069946257",
    },
    Cowboy = {
        idle = animationBaseUrl .. "1014390418",
        jump = animationBaseUrl .. "1014394726",
        fall = animationBaseUrl .. "1014384571",
        walk = animationBaseUrl .. "1014421541",
        run = animationBaseUrl .. "1014401683",
        climb = animationBaseUrl .. "1014380606",
    },
    Elder = {
        idle = animationBaseUrl .. "845397899",
        jump = animationBaseUrl .. "845398858",
        fall = animationBaseUrl .. "845396048",
        walk = animationBaseUrl .. "845403856",
        run = animationBaseUrl .. "845386501",
        climb = animationBaseUrl .. "845392038",
    },
    Knight = {
        idle = animationBaseUrl .. "657595757",
        jump = animationBaseUrl .. "658409194",
        fall = animationBaseUrl .. "657600338",
        walk = animationBaseUrl .. "657552124",
        run = animationBaseUrl .. "657564596",
        climb = animationBaseUrl .. "658360781",
    },
    Levitation = {
        idle = animationBaseUrl .. "616006778",
        jump = animationBaseUrl .. "616008936",
        fall = animationBaseUrl .. "616005863",
        walk = animationBaseUrl .. "616013216",
        run = animationBaseUrl .. "616010382",
        climb = animationBaseUrl .. "616003713",
    },
    Mage = {
        idle = animationBaseUrl .. "707742142",
        jump = animationBaseUrl .. "707853694",
        fall = animationBaseUrl .. "707829716",
        walk = animationBaseUrl .. "707897309",
        run = animationBaseUrl .. "707861613",
        climb = animationBaseUrl .. "707826056",
    },
    Ninja = {
        idle = animationBaseUrl .. "656117400",
        jump = animationBaseUrl .. "656117878",
        fall = animationBaseUrl .. "656115606",
        walk = animationBaseUrl .. "656121766",
        run = animationBaseUrl .. "656118852",
        climb = animationBaseUrl .. "656114359",
    },
    Patrol = {
        idle = animationBaseUrl .. "1149612882",
        jump = animationBaseUrl .. "1148811837",
        fall = animationBaseUrl .. "1148863382",
        walk = animationBaseUrl .. "1151231493",
        run = animationBaseUrl .. "1150967949",
        climb = animationBaseUrl .. "1148811837",
    },
    Pirate = {
        idle = animationBaseUrl .. "750781874",
        jump = animationBaseUrl .. "750782230",
        fall = animationBaseUrl .. "750780242",
        walk = animationBaseUrl .. "750785693",
        run = animationBaseUrl .. "750783738",
        climb = animationBaseUrl .. "750779899",
    },
    Princess = {
        idle = animationBaseUrl .. "941003647",
        jump = animationBaseUrl .. "941008832",
        fall = animationBaseUrl .. "941000007",
        walk = animationBaseUrl .. "941028902",
        run = animationBaseUrl .. "941015281",
        climb = animationBaseUrl .. "940996062",
    },
    Robot = {
        idle = animationBaseUrl .. "616088211",
        jump = animationBaseUrl .. "616090535",
        fall = animationBaseUrl .. "616087089",
        walk = animationBaseUrl .. "616095330",
        run = animationBaseUrl .. "616091570",
        climb = animationBaseUrl .. "616086039",
    },
    Sneaky = {
        idle = animationBaseUrl .. "1132473842",
        jump = animationBaseUrl .. "1132489853",
        fall = animationBaseUrl .. "1132469004",
        walk = animationBaseUrl .. "1132510133",
        run = animationBaseUrl .. "1132494274",
        climb = animationBaseUrl .. "1132461372",
    },
    Stylish = {
        idle = animationBaseUrl .. "616136790",
        jump = animationBaseUrl .. "616139451",
        fall = animationBaseUrl .. "616134815",
        walk = animationBaseUrl .. "616146177",
        run = animationBaseUrl .. "616140816",
        climb = animationBaseUrl .. "616133594",
    },
    Superhero = {
        idle = animationBaseUrl .. "616111295",
        jump = animationBaseUrl .. "616115533",
        fall = animationBaseUrl .. "616108001",
        walk = animationBaseUrl .. "616122287",
        run = animationBaseUrl .. "616117076",
        climb = animationBaseUrl .. "616104706",
    },
    Toy = {
        idle = animationBaseUrl .. "782841498",
        jump = animationBaseUrl .. "782847020",
        fall = animationBaseUrl .. "782846423",
        walk = animationBaseUrl .. "782843345",
        run = animationBaseUrl .. "782842708",
        climb = animationBaseUrl .. "782843869",
    },
    Vampire = {
        idle = animationBaseUrl .. "1083445855",
        jump = animationBaseUrl .. "1083455352",
        fall = animationBaseUrl .. "1083443587",
        walk = animationBaseUrl .. "1083473930",
        run = animationBaseUrl .. "1083462077",
        climb = animationBaseUrl .. "1083439238",
    },
    Werewolf = {
        idle = animationBaseUrl .. "1083195517",
        jump = animationBaseUrl .. "1083218792",
        fall = animationBaseUrl .. "1083189019",
        walk = animationBaseUrl .. "1083178339",
        run = animationBaseUrl .. "1083216690",
        climb = animationBaseUrl .. "1083182000",
    },
    Zombie = {
        idle = animationBaseUrl .. "616158929",
        jump = animationBaseUrl .. "616161997",
        fall = animationBaseUrl .. "616157476",
        walk = animationBaseUrl .. "616168032",
        run = animationBaseUrl .. "616163682",
        climb = animationBaseUrl .. "616156119",
    },
}

local function apply_animations(animate, preset)
    if animate and preset then
        if animate.idle and animate.idle:FindFirstChild("Animation1") then
            animate.idle.Animation1.AnimationId = preset.idle
        else
            warn("Idle animation or Animation1 not found")
        end
        
        if animate.walk and animate.walk:FindFirstChild("WalkAnim") then
            animate.walk.WalkAnim.AnimationId = preset.walk
        else
            warn("Walk animation or WalkAnim not found")
        end

        if animate.run and animate.run:FindFirstChild("RunAnim") then
            animate.run.RunAnim.AnimationId = preset.run
        else
            warn("Run animation or RunAnim not found")
        end

        if animate.jump and animate.jump:FindFirstChild("JumpAnim") then
            animate.jump.JumpAnim.AnimationId = preset.jump
        else
            warn("Jump animation or JumpAnim not found")
        end

        if animate.climb and animate.climb:FindFirstChild("ClimbAnim") then
            animate.climb.ClimbAnim.AnimationId = preset.climb
        else
            warn("Climb animation or ClimbAnim not found")
        end

        if animate.fall and animate.fall:FindFirstChild("FallAnim") then
            animate.fall.FallAnim.AnimationId = preset.fall
        else
            warn("Fall animation or FallAnim not found")
        end
    end
end

local function apply_selected_animations(character)
    local animate = character:FindFirstChild("Animate")
    if animate and currentAnimationPreset ~= "None" then
        local selectedPreset = animations[currentAnimationPreset]
        apply_animations(animate, selectedPreset)
    end
end

section:dropdown({name = "animation pack", flag = "selected_animation", scrolling = true, items = {'None', 'Rthro', 'DaHoodian', 'Sneaky', 'Cowboy', 'Stylish', 'Robot', 'Pirate', 'Mage', 'Cartoony', 'Zombie', 'Knight', 'Astronaut', 'Werewolf', 'Toy', 'Bubbly', 'Levitation', 'Princess', 'Superhero', 'Vampire', 'Patrol', 'Confident', 'Ninja', 'Elder'}, default = "None", callback = function(Value)
    currentAnimationPreset = Value
    task.wait()
end})

local column = Misc:column()

local Desync, Custom  = column:multi_section({names = {"desync", "custom"}})

Desync:toggle({name = "enabled", flag = "desync_enabled", callback = function(Value)
    headshots.Desync.Enabled = Value
end}):keybind({name = "desync", flag = "desync_bind", callback = function(Value)
    if headshots.Desync.Enabled then
        headshots.Desync.Keybind = Value
    end
end})

Desync:dropdown({name = "desync mode", flag = "desync_mode", scrolling = true, items = {"Custom", "Randomize", "Void" }, default = "Custom", callback = function(Value)
    headshots.Desync.Mode = Value
end})

Desync:toggle({name = "spam", flag = "spam_desync", callback = function(Value)
    headshots.Desync.Spam = Value
end})

Desync:slider({name = "in void time", min = 0.001, max = 1, default = 0.4, interval = 0.001, flag = "invoidtime", callback = function(Value)
    headshots.Desync.InVoid = Value
end})

Desync:slider({name = "on ground time", min = 0.001, max = 1, default = 0.133, interval = 0.001, flag = "ongroundtime", callback = function(Value)
    headshots.Desync.OnGround = Value
end})

Desync:toggle({name = "visualize", flag = "visualize_desync", callback = function(Value)
    headshots.Desync.Visualize = Value
end}):colorpicker({name = "main", flag = "desynccolor", color = rgb(155, 125, 175), callback = function(Value, alpha)
    SetRigColor(clone, Value)
end})

Desync:dropdown({name = "material", flag = "visualize_material", scrolling = true, items = {"Neon", "ForceField", "Plastic", "SmoothPlastic", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "DiamondPlate", "Metal", "CorrodedMetal", "Foil", "Grass", "Sand", "Fabric", "Ice", "Glass", "Asphalt", "LeafyGrass", "Salt", "Snow", "Mud", "Ground", "Basalt", "CrackedLava"}, default = "Neon", callback = function(Value)
    SetRigMaterial(clone, Value)
end})

Desync:slider({name = "transparency", min = 0, max = 1, default = 0, interval = 0.01, flag = "visualize_transparency", callback = function(Value)
    headshots.Desync.Transparency = Value
end})

Custom:slider({name = "min x", min = 0, max = 1000, default = Desync.MinX, interval = 1, flag = "customdesync_minx", callback = function(Value)
    _G.Desync.MinX = Value
end})

Custom:slider({name = "max x", min = 0, max = 1000, default = Desync.MaxX, interval = 1, flag = "customdesync_maxx", callback = function(Value)
    _G.Desync.MaxX = Value
end})

Custom:slider({name = "min y", min = 0, max = 1000, default = Desync.MinY, interval = 1, flag = "customdesync_miny", callback = function(Value)
    _G.Desync.MinY = Value
end})

Custom:slider({name = "max y", min = 0, max = 1000, default = Desync.MaxY, interval = 1, flag = "customdesync_maxy", callback = function(Value)
    _G.Desync.MaxY = Value
end})

Custom:slider({name = "min z", min = 0, max = 1000, default = Desync.MinZ, interval = 1, flag = "customdesync_minz", callback = function(Value)
    _G.Desync.MinZ = Value
end})

Custom:slider({name = "max z", min = 0, max = 1000, default = Desync.MaxZ, interval = 1, flag = "customdesync_maxz", callback = function(Value)
    _G.Desync.MaxZ = Value
end})

Custom:slider({name = "min pitch", min = 0, max = 180, default = 0, interval = 1, flag = "customdesync_minpitch", callback = function(Value)
    _G.Desync.MinPitch = Value
end})

Custom:slider({name = "max pitch", min = 180, max = 360, default = 360, interval = 1, flag = "customdesync_maxpitch", callback = function(Value)
    _G.Desync.MaxPitch = Value
end})

Custom:slider({name = "min yaw", min = 0, max = 180, default = 0, interval = 1, flag = "customdesync_minyaw", callback = function(Value)
    _G.Desync.MinYaw = Value
end})

Custom:slider({name = "max yaw", min = 180, max = 360, default = 360, interval = 1, flag = "customdesync_maxyaw", callback = function(Value)
    _G.Desync.MaxYaw = Value
end})

local section = column:section({name = "network"})

local a = false
game:GetService("RunService").Heartbeat:Connect(function()
    if headshots.Network.Desync then
        a = not a
        sethiddenproperty(game.Players.LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", a)
        if headshots.Network.UseSenderRate and headshots.Network.FakePos == false then
            if a then
                setfflag("S2PhysicsSenderRate", tostring(headshots.Network.SenderRate))
            else
                setfflag("S2PhysicsSenderRate", "20")
            end
        end
    end
end)

coroutine.wrap(function()
    while true do
        if headshots.Network.FakePos then
            setfflag("S2PhysicsSenderRate", "1")
            setfpscap(1)
            task.wait(0.1)
            setfflag("S2PhysicsSenderRate", "20000")
            setfpscap(240)
        end
        task.wait(headshots.Network.RefreshRate)
    end
end)()

section:toggle({name = "network desync", flag = "networkdesync_enabled", callback = function(Value)
    headshots.Network.Desync = Value
end})

section:toggle({name = "physicssenderrate", flag = "S2PhysicsSenderRate_enabled", callback = function(Value)
    headshots.Network.UseSenderRate = Value
end})

section:slider({name = "s2physicssenderrate", min = -20000, max = 20000, default = 60, interval = 1, flag = "S2PhysicsSenderRate_value", callback = function(Value)
    headshots.Network.SenderRate = Value
end})

section:toggle({name = "fake pos", flag = "fakepos_enabled", callback = function(Value)
    headshots.Network.Desync = Value
    if Value then
        setfflag("S2PhysicsSenderRate", "1")
        setfpscap(1)
        task.wait(0.1)
        setfflag("S2PhysicsSenderRate", "20000")
        setfpscap(240)
    end
end})

section:toggle({name = "fake pos refresh", flag = "fakepos_enabled", callback = function(Value)
    headshots.Network.FakePos = Value
end})

section:slider({name = "refresh rate", min = 5, max = 200, default = 20, interval = 1, flag = "refresh_value", callback = function(Value)
    headshots.Network.RefreshRate = Value
end})

local section = column:section({name = "other"})

section:toggle({name = "anti stomp", flag = "antistomp_enabled", callback = function(Value)
    headshots.AntiStomp.Enabled = Value
end})

local cachedSeats = {}

local function processSeat(seat, state)
if seat:IsA("Seat") and not cachedSeats[seat] then
    cachedSeats[seat] = seat
end
if cachedSeats[seat] then
    seat.Disabled = state
    if state then
        game:GetService("CollectionService"):AddTag(seat, "Seat")
    else
        game:GetService("CollectionService"):RemoveTag(seat, "Seat")
    end
end
end

local function initializeSeats()
for _, object in ipairs(workspace:GetDescendants()) do
    if object:IsA("Seat") then
        cachedSeats[object] = object
    end
end
end

local function monitorNewSeats()
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Seat") then
        processSeat(descendant, game:GetService("CollectionService"):HasTag(descendant, "Seat"))
    end
end)
end

initializeSeats()
monitorNewSeats()

section:toggle({name = "disable seats", flag = "disableseats_enabled", callback = function(Value)
    for seat, _ in pairs(cachedSeats) do
        if seat and seat:IsA("Seat") then
            seat.Disabled = Value
            if Value then
                game:GetService("CollectionService"):AddTag(seat, "Seat")
            else
                game:GetService("CollectionService"):RemoveTag(seat, "Seat")
            end
        end
    end
end})

section:toggle({name = "auto reload", flag = "autoreload_enabled", callback = function(Value)
    headshots.AutoReload.Enabled = Value
end})

-- // Players // --

local column = PlayersTab:column()

if Premium then

    local section = column:section({ name = "playerlist" })

    local playerlist = section:playerlist({})
    
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        local selectedplayername = library.selected_player
            
        if selectedplayername then
            headshots.Target.Target = selectedplayername
        end
    end)
    
    local section = column:section({ name = "actions" })
    
    section:button_holder({})
    
    section:button({name = "kill", callback = function()
        local originalCFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
        while task.wait() do
            local Target = game.Players:FindFirstChild(headshots.Target.Target)
            if not localPlayer or not localPlayer.Character then continue end
    
            local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local Tool = localPlayer.Character:FindFirstChildOfClass("Tool")
            
            if headshots.Target.Target ~= nil then
                if Target and Target.Character and humanoidRootPart and Tool and Tool:FindFirstChild("Handle") then
                    local targetHRP = Target.Character:FindFirstChild("HumanoidRootPart")
                    local targetHead = Target.Character:FindFirstChild("Head")
        
                    if not KnockCheck(Target) and targetHead and targetHRP then
                        if (not Target.Character:FindFirstChild("ForceField")) or (Tool.Name == "[Rifle]") then
                            humanoidRootPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25)))
                            task.wait()
                            MainEvent:FireServer("ShootGun", Tool.Handle, Tool.Handle.Position, targetHead.Position, targetHead, Vector3.new(0, 1, 0))
                        else
                            humanoidRootPart.CFrame = CFrame.new(50000, 10000, 0) + Vector3.new(math.random(-25, 25), math.random(-25, 0), math.random(-25, 25))
                            library:notification({ text = "headshots.cc - Waiting.. Target has spawn protection.", time = 1 })
                            MainEvent:FireServer("Reload", Tool)
                        end
                    else
                        if Target.Character:FindFirstChild("BodyEffects") and Target.Character.BodyEffects:FindFirstChild("SDeath") and Target.Character.BodyEffects.SDeath.Value == false then
                            if Target.Character:FindFirstChild("UpperTorso") and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
                                humanoidRootPart.CFrame = CFrame.new(Target.Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                                game:GetService("ReplicatedStorage"):WaitForChild("MainEvent"):FireServer("Stomp")
                            end
                        elseif Target.Character:FindFirstChild("BodyEffects") and Target.Character.BodyEffects:FindFirstChild("SDeath") and Target.Character.BodyEffects.SDeath.Value == true then
                            task.wait(1)
                            library:notification({ text = "headshots.cc - Target has been killed.", time = 3 })
                            humanoidRootPart.CFrame = originalCFrame
                            return
                        end
                    end
                else
                    library:notification({ text = "headshots.cc - please equip your gun before using 'Kill Target'.", time = 3 })
                    return
                end
            end
        end
    end})
    
    section:button({name = "knock", callback = function()
        local originalCFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
        while task.wait() do
            local Target = game.Players:FindFirstChild(headshots.Target.Target)
            if not localPlayer or not localPlayer.Character then continue end
    
            local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local Tool = localPlayer.Character:FindFirstChildOfClass("Tool")
            
            if headshots.Target.Target ~= nil then
                if Target and Target.Character and humanoidRootPart and Tool and Tool:FindFirstChild("Handle") then
                    local targetHRP = Target.Character:FindFirstChild("HumanoidRootPart")
                    local targetHead = Target.Character:FindFirstChild("Head")
        
                    if not KnockCheck(Target) and targetHead and targetHRP then
                        if (not Target.Character:FindFirstChild("ForceField")) or (Tool.Name == "[Rifle]") then
                            humanoidRootPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25)))
                            task.wait()
                            MainEvent:FireServer("ShootGun", Tool.Handle, Tool.Handle.Position, targetHead.Position, targetHead, Vector3.new(0, 1, 0))
                        else
                            humanoidRootPart.CFrame = CFrame.new(50000, 10000, 0) + Vector3.new(math.random(-25, 25), math.random(-25, 0), math.random(-25, 25))
                            library:notification({ text = "headshots.cc - Waiting.. Target has spawn protection.", time = 1 })
                            MainEvent:FireServer("Reload", Tool)
                        end
                    else
                        library:notification({ text = "headshots.cc - Target has been knocked.", time = 3 })
                        humanoidRootPart.CFrame = originalCFrame
                        return
                    end
                else
                    library:notification({ text = "headshots.cc - please equip your gun before using 'Knock Target'.", time = 3 })
                    return
                end
            end
        end
    end})
    
    section:button_holder({})
    
    section:button({name = "go-to", callback = function()
        local Target = game.Players:FindFirstChild(headshots.Target.Target)
        if headshots.Target.Target ~= nil and Target and Target.Character and localPlayer then
            localPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame
        else
            library:notification({ text = "headshots.cc - please select a target before using 'Go-To Target'.", time = 3 })
        end
    end})

    local SavedCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

    local conn
    section:toggle({
        name = "spectate",
        callback = function(v)
            if v then
                local t = game.Players:FindFirstChild(headshots.Target.Target)
                if t and t.Character and t.Character:FindFirstChild("Humanoid") then
                    conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
                        workspace.CurrentCamera.CameraSubject = t.Character.Humanoid
                    end)
                else
                    library:notification({ text = "headshots.cc - please select a target before using 'Spectate Target'.", time = 3 })
                end
            else
                if conn then conn:Disconnect() conn = nil end
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            end
        end
    })
    
    section:toggle({name = "auto kill", callback = function(Value)
        if Value == true then
            SavedCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        headshots.Target.AutoKill = Value
        if Value == false then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = SavedCFrame
        end
    end})

    section:toggle({name = "csync", callback = function(Value)
        headshots.Target.AutoKillDesync = Value
    end})

else
    local section = column:section({ name = "Locked" })
    section:label({ name = "This Tab is only for Premium Users of headshots.cc" })
    section:label({ name = "How to get Premium?" })
    section:label({ name = "1. Head to the headshots.cc Discord Server." })
    section:label({ name = "2. Open the #script channel at the very top." })
    section:label({ name = "3. There will be a link, where you can buy a Premium Key (Process is Automated)." })
    section:label({ name = "4. Once you have your key, go back to the #script channel and press 'Redeem Key' and input your Premium Key." })
    section:label({ name = "5. Click 'Get Script' and enjoy." })
end

-- // Settings // --

getgenv().load_config = function(name)
    library:load_config(readfile(library.directory .. "/configs/" .. name .. ".cfg"))
end

local column = Settings:column()
local section = column:section({ name = "options" })

local old_config = library:get_config()
config_holder = section:list({ flag = "config_name_list" })

section:textbox({ flag = "config_name_text_box" })

section:button_holder({})

section:button({
    name = "create",
    callback = function()
        writefile(library.directory .. "/configs/" .. flags["config_name_text_box"] .. ".cfg", library:get_config())
        library:config_list_update()
    end
})

section:button({
    name = "delete",
    callback = function()
        delfile(library.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg")
        library:config_list_update()
    end
})

section:button_holder({})

section:button({
    name = "load",
    callback = function()
        library:load_config(readfile(library.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg"))
        library:notification({ text = "Loaded Config: " .. flags["config_name_list"], time = 3 })
    end
})

section:button({
    name = "save",
    callback = function()
        writefile(library.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg", library:get_config())
        library:config_list_update()
        library:notification({ text = "Saved Config: " .. flags["config_name_list"], time = 3 })
    end
})

section:button_holder({})

section:button({ name = "refresh configs", callback = function() library:config_list_update() end })
section:button_holder({})

section:button({ name = "unload config", callback = function() library:load_config(old_config) end })

section:button({
    name = "unload menu",
    callback = function()
        library:load_config(old_config)
        for _, gui in library.guis do gui:Destroy() end
        for _, connection in library.connections do connection:Disconnect() end
    end
})

-- Theme Section
local column = Settings:column()
local section = column:section({ name = "theme" })

section:label({ name = "accent" })
    :colorpicker({
        name = "accent",
        color = themes.preset.accent,
        flag = "accent",
        callback = function(color, alpha)
            library:update_theme("accent", color)
        end
    })

section:label({ name = "contrast" })
    :colorpicker({
        name = "low",
        color = themes.preset.low_contrast,
        flag = "low_contrast",
        callback = function(color)
            if flags["high_contrast"] and flags["low_contrast"] then
                library:update_theme("contrast", rgbseq{
                    rgbkey(0, flags["low_contrast"].Color),
                    rgbkey(1, flags["high_contrast"].Color)
                })
            end
        end
    })
    :colorpicker({
        name = "high",
        color = themes.preset.high_contrast,
        flag = "high_contrast",
        callback = function(color)
            library:update_theme("contrast", rgbseq{
                rgbkey(0, flags["low_contrast"].Color),
                rgbkey(1, flags["high_contrast"].Color)
            })
        end
    })

section:label({ name = "inline" })
    :colorpicker({
        name = "inline",
        color = themes.preset.inline,
        flag = "inline",
        callback = function(color, alpha)
            library:update_theme("inline", color)
        end
    })

section:label({ name = "outline" })
    :colorpicker({
        name = "outline",
        color = themes.preset.outline,
        flag = "outline",
        callback = function(color, alpha)
            library:update_theme("outline", color)
        end
    })

section:label({ name = "text color" })
    :colorpicker({
        name = "main",
        color = themes.preset.text,
        flag = "textcolor",
        callback = function(color, alpha)
            library:update_theme("text", color)
        end
    })
    :colorpicker({
        name = "outline",
        color = themes.preset.text_outline,
        flag = "text_outline",
        callback = function(color, alpha)
            library:update_theme("text_outline", color)
        end
    })

section:label({ name = "glow" })
    :colorpicker({
        name = "glow",
        color = themes.preset.glow,
        flag = "glow",
        callback = function(color, alpha)
            library:update_theme("glow", color)
        end
    })

section:label({ name = "ui bind" })
    :keybind({ callback = window.set_menu_visibility, key = Enum.KeyCode.Insert })

section:toggle({
    name = "keybind list",
    flag = "keybind_list",
    callback = function(bool)
        library.keybind_list_frame.Visible = bool
    end
})

section:toggle({
    name = "watermark",
    flag = "watermark",
    callback = function(bool)
        watermark.set_visible(bool)
    end
})

section:button_holder({})
section:button({ name = "copy j*bid", callback = function() setclipboard(game.JobId) end })
section:button_holder({})
section:button({ name = "copy gameid", callback = function() setclipboard(game.GameId) end })
section:button_holder({})

section:button({
    name = "copy join script",
    callback = function()
        setclipboard('game:GetService("TeleportService"):TeleportToPlaceInstance(' ..
            game.PlaceId .. ', "' .. game.JobId .. '", game.Players.LocalPlayer)')
    end
})

section:button_holder({})
section:button({
    name = "rejoin",
    callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end
})

section:button_holder({})
section:button({
    name = "join new server",
    callback = function()
        local apiRequest = game:GetService("HttpService"):JSONDecode(
            game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        local data = apiRequest.data[random(1, #apiRequest.data)]
        
        if data.playing <= flags["max_players"] then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, data.id)
        end
    end
})

section:slider({
    name = "max players",
    flag = "max_players",
    min = 0,
    max = 40,
    default = 15,
    interval = 1
})

-- // Finishing Touches // --

game:GetService("RunService").Heartbeat:Connect(function(dt)
    local TargetAimActive = false
    local BuyingActive = false
    local AutoArmorActive = false
    local AutoLoadoutActive = false
    local BuyingSingleActive = false

    -- Target Aim Logic
    if headshots.TargetAim.Enabled and headshots.TargetAim.Strafe and headshots.TargetAim.Target ~= "None" and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Head") then
        local TargetPlayer = players:FindFirstChild(headshots.TargetAim.Target)
        local Tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") and Tool then
            if not TargetPlayer.Character:FindFirstChild("ForceField") or Tool.Name == "[Rifle]" then
                local bodyEffects = TargetPlayer.Character:FindFirstChild("BodyEffects")
                local isDead = bodyEffects and bodyEffects:FindFirstChild("SDeath") and bodyEffects.SDeath.Value   
                if ((not KnockCheck(TargetPlayer)) or (headshots.TargetAim.AutoStomp and isDead == false)) and localPlayer.Character and localPlayer.Character:FindFirstChild("BodyEffects") and localPlayer.Character.BodyEffects:FindFirstChild("Reload") and localPlayer.Character.BodyEffects.Reload.Value == false then
                    if headshots.TargetAim.VoidResolver then
                        if (TargetPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 0, 0)).Magnitude > 5000 then
                            return
                        end
                    end
                    TargetAimActive = true
                end
            end
        end
    end

    -- Buy Single Logic
    if BuyingSingle and not game.Players.LocalPlayer.Character:FindFirstChild(SelectedGun) and not game.Players.LocalPlayer.Backpack:FindFirstChild(SelectedGun) then
        BuyingSingleActive = true
    end

    -- Auto Loadout Logic
    if headshots.AutoLoadout.Enabled and headshots.AutoLoadout.Gun and ShopTable[headshots.AutoLoadout.Gun] and not game.Players.LocalPlayer.Character:FindFirstChild(headshots.AutoLoadout.Gun) and not game.Players.LocalPlayer.Backpack:FindFirstChild(headshots.AutoLoadout.Gun) then
        AutoLoadoutActive = true
    end

    -- Auto Armor Logic
    if headshots.AutoArmor.Enabled and game.Players.LocalPlayer.Character.BodyEffects.Armor.Value < 100 then
        AutoArmorActive = true
    end

    -- Checking
    if TargetAimActive or headshots.Target.AutoKill or AutoArmorActive or AutoLoadoutActive or BuyingAmmo or BuyingSingleActive then
        abletodesync = false
    else
        abletodesync = true
    end

end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    -- Fly
    if headshots.Fly.Enabled and headshots.Fly.Keybind then
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local move_direction = localPlayer.Character.Humanoid.MoveDirection;
            local hrp = localPlayer.Character.HumanoidRootPart;
            local add = Vector3.new(0, (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) and headshots.Fly.Speed /  8 or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) and -headshots.Fly.Speed / 8) or 0, 0);
            hrp.CFrame = hrp.CFrame + (move_direction * dt) * headshots.Fly.Speed * 10;
            hrp.CFrame = hrp.CFrame + add;
            hrp.Velocity = (hrp.Velocity * Vector3.new(1, 0, 1)) + Vector3.new(0, 1.9, 0);
        end
    end
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    -- Speed
    if headshots.Speed.Enabled and headshots.Speed.Keybind then
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local move_direction = localPlayer.Character.Humanoid.MoveDirection;
            local hrp = localPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + (move_direction * dt) * headshots.Speed.Speed * 10
        end
    end
end)

Combat.open_tab() 

task.spawn(function()
    while task.wait(1) do 
        watermark.change_text(os.date('headshots.cc - version: ' .. ScriptVersion .. ' - %b %d %Y - %H:%M:%S'))
    end 
end) 
-- 

library:config_list_update()

for index, value in next, themes.preset do 
    pcall(function()
        library:update_theme(index, value)
    end)
end

-- // Yep // --