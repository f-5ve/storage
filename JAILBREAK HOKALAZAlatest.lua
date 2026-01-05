-- ts file was generated at discord.gg/25ms


local v1 = game:GetService("Players").LocalPlayer
local vu2 = Instance.new("ScreenGui", v1:WaitForChild("PlayerGui"))
vu2.Name = "HOKALAZA_KeySystem"
vu2.ResetOnSpawn = false
local v3 = Instance.new("Frame", vu2)
v3.Size = UDim2.new(0, 360, 0, 230)
v3.Position = UDim2.new(0.5, 0, 0.5, 0)
v3.AnchorPoint = Vector2.new(0.5, 0.5)
v3.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
v3.BorderSizePixel = 0
Instance.new("UICorner", v3).CornerRadius = UDim.new(0, 12)
local v4 = Instance.new("TextLabel", v3)
v4.Text = "\239\191\189\239\191\189\239\191\189\239\191\189\239\191\189\239\191\189 Enter Key to Unlock Script"
v4.Size = UDim2.new(1, - 20, 0, 40)
v4.Position = UDim2.new(0, 10, 0, 14)
v4.BackgroundTransparency = 1
v4.TextColor3 = Color3.fromRGB(0, 255, 200)
v4.Font = Enum.Font.GothamBlack
v4.TextSize = 20
local vu5 = Instance.new("CRAZYJAIL", v3)
vu5.PlaceholderText = "Enter key here..."
vu5.Size = UDim2.new(1, - 40, 0, 36)
vu5.Position = UDim2.new(0, 20, 0, 68)
vu5.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
vu5.TextColor3 = Color3.fromRGB(255, 255, 255)
vu5.Font = Enum.Font.Gotham
vu5.TextSize = 18
vu5.ClearTextOnFocus = false
Instance.new("UICorner", vu5).CornerRadius = UDim.new(0, 8)
local vu6 = Instance.new("TextButton", v3)
vu6.Text = "Unlock"
vu6.Size = UDim2.new(1, - 40, 0, 36)
vu6.Position = UDim2.new(0, 20, 0, 122)
vu6.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
vu6.TextColor3 = Color3.fromRGB(18, 22, 28)
vu6.Font = Enum.Font.GothamBold
vu6.TextSize = 20
Instance.new("UICorner", vu6).CornerRadius = UDim.new(0, 8)
local vu7 = Instance.new("TextButton", v3)
vu7.Text = "Get Key (Discord)"
vu7.Size = UDim2.new(1, - 40, 0, 32)
vu7.Position = UDim2.new(0, 20, 0, 172)
vu7.BackgroundColor3 = Color3.fromRGB(0, 175, 255)
vu7.TextColor3 = Color3.fromRGB(0, 0, 0)
vu7.Font = Enum.Font.GothamBold
vu7.TextSize = 18
Instance.new("UICorner", vu7).CornerRadius = UDim.new(0, 8)
local function v8()
    if setclipboard then
        setclipboard("https://discord.gg/4myWDtW8yj")
    elseif toclipboard then
        toclipboard("https://discord.gg/4myWDtW8yj")
    elseif syn and syn.clipboard then
        syn.clipboard.set("https://discord.gg/4myWDtW8yj")
    end
    vu7.Text = "Link Copied!"
    task.wait(1.4)
    vu7.Text = "Get Key (Discord)"
end
vu7.MouseButton1Click:Connect(v8)
vu6.MouseButton1Click:Connect(function()
    if vu5.Text ~= "CRAZYJAIL" then
        vu6.Text = "Invalid Key!"
        task.wait(1.4)
        vu6.Text = "Unlock"
    else
        vu2:Destroy()
        getgenv().isfunctionhooked = isfunctionhooked or ishooked
        local vu119 = {
            DraggingEnabled = function(_, p9, p10)
                local vu11 = p10 or p9
                local vu12 = nil
                local vu13 = nil
                local vu14 = nil
                local vu15 = nil
                local function vu18(p16)
                    local v17 = p16.Position - vu14
                    game:GetService("TweenService"):Create(vu11, TweenInfo.new(0.15), {
                        Position = UDim2.new(vu15.X.Scale, vu15.X.Offset + v17.X, vu15.Y.Scale, vu15.Y.Offset + v17.Y)
                    }):Play()
                end
                vu11.InputBegan:Connect(function(pu19)
                    if pu19.UserInputType == Enum.UserInputType.MouseButton1 or pu19.UserInputType == Enum.UserInputType.Touch then
                        vu12 = true
                        vu14 = pu19.Position
                        vu15 = vu11.Position
                        pu19.Changed:Connect(function()
                            if pu19.UserInputState == Enum.UserInputState.End then
                                vu12 = false
                            end
                        end)
                    end
                end)
                vu11.InputChanged:Connect(function(p20)
                    if p20.UserInputType == Enum.UserInputType.MouseMovement or p20.UserInputType == Enum.UserInputType.Touch then
                        vu13 = p20
                    end
                end)
                game:GetService("UserInputService").InputChanged:Connect(function(p21)
                    if p21 == vu13 and vu12 then
                        vu18(p21)
                    end
                end)
            end,
            SetupUI = function(p22, pu23)
                local v24 = Instance.new("ScreenGui")
                local vu25 = Instance.new("Frame")
                local v26 = Instance.new("UICorner")
                local v27 = Instance.new("Frame")
                local v28 = Instance.new("UICorner")
                local v29 = Instance.new("Frame")
                local v30 = Instance.new("TextLabel")
                local v31 = Instance.new("ImageButton")
                local v32 = Instance.new("ImageButton")
                local v33 = Instance.new("Frame")
                local vu34 = Instance.new("Frame")
                local vu35 = Instance.new("ScrollingFrame")
                local v36 = Instance.new("UIListLayout")
                local vu37 = Instance.new("Frame")
                v24.Parent = game:GetService("Players").LocalPlayer.PlayerGui
                v24.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                vu25.Parent = v24
                vu25.BackgroundColor3 = Color3.fromRGB(21, 23, 22)
                vu25.BorderColor3 = Color3.fromRGB(0, 0, 0)
                vu25.BorderSizePixel = 0
                vu25.ClipsDescendants = true
                vu25.Position = UDim2.new(0.222632244, 0, 0.171314746, 0)
                vu25.Size = UDim2.new(0, 440, 0, 310)
                v26.Name = "MainCorner"
                v26.Parent = vu25
                v27.Name = "TopBar"
                v27.Parent = vu25
                v27.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                v27.BorderColor3 = Color3.fromRGB(0, 0, 0)
                v27.BorderSizePixel = 0
                v27.Size = UDim2.new(0, 440, 0, 25)
                v28.Name = "TopbarCorner"
                v28.Parent = v27
                v29.Name = "TopbarCornerHide"
                v29.Parent = v27
                v29.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                v29.BorderColor3 = Color3.fromRGB(0, 0, 0)
                v29.BorderSizePixel = 0
                v29.Position = UDim2.new(0, 0, 0.75999999, 0)
                v29.Size = UDim2.new(0, 450, 0, 6)
                v30.Name = "TopbarText"
                v30.Parent = v27
                v30.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                v30.BackgroundTransparency = 1
                v30.BorderColor3 = Color3.fromRGB(0, 0, 0)
                v30.BorderSizePixel = 0
                v30.Position = UDim2.new(0.0688888878, 0, 0.280000001, 0)
                v30.Size = UDim2.new(0, 303, 0, 10)
                v30.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                v30.TextColor3 = Color3.fromRGB(255, 255, 255)
                v30.TextSize = 14
                v30.TextXAlignment = Enum.TextXAlignment.Left
                v30.Text = p22
                vu119:DraggingEnabled(v30, vu25)
                v31.Name = "TopbarHideButton"
                v31.Parent = v27
                v31.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                v31.BackgroundTransparency = 1
                v31.BorderColor3 = Color3.fromRGB(0, 0, 0)
                v31.BorderSizePixel = 0
                v31.Position = UDim2.new(0, 5, 0.0799999982, 0)
                v31.Rotation = 90
                v31.Size = UDim2.new(0, 20, 0, 20)
                v31.Image = "http://www.roblox.com/asset/?id=4731371527"
                v32.Name = "TopbarSaveButton"
                v32.Position = UDim2.new(0.948, 0, 0.2, 0)
                v32.BackgroundTransparency = 1
                v32.Image = "rbxassetid://10734941499"
                v32.Size = UDim2.fromOffset(15, 15)
                v32.Parent = v27
                v32.MouseButton1Click:Connect(function()
                    pu23()
                end)
                vu34.Name = "PageList"
                vu34.Parent = vu25
                vu34.BackgroundColor3 = Color3.fromRGB(37, 38, 40)
                vu34.BorderColor3 = Color3.fromRGB(0, 0, 0)
                vu34.BorderSizePixel = 0
                vu34.Position = UDim2.new(0.0219697431, 0, 0, 30)
                vu34.Size = UDim2.new(0, 420, 0, 30)
                vu35.Name = "PageListScroll"
                vu35.Parent = vu34
                vu35.Active = true
                vu35.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                vu35.BackgroundTransparency = 1
                vu35.BorderColor3 = Color3.fromRGB(0, 0, 0)
                vu35.BorderSizePixel = 0
                vu35.Size = UDim2.new(0, 420, 0, 25)
                vu35.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
                vu35.CanvasSize = UDim2.new(2, 0, 0, 0)
                vu35.ScrollBarThickness = 0
                vu35.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
                v36.Name = "PageListScrollLayout"
                v36.Parent = vu35
                v36.FillDirection = Enum.FillDirection.Horizontal
                v36.SortOrder = Enum.SortOrder.LayoutOrder
                v36.Padding = UDim.new(0, 1)
                v33.Name = "PageListLine"
                v33.Parent = vu34
                v33.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                v33.BorderColor3 = Color3.fromRGB(0, 0, 0)
                v33.BorderSizePixel = 0
                v33.Position = UDim2.new(0, 0, 1, 0)
                v33.Size = UDim2.new(0, 420, 0, 3)
                vu37.Name = "PageContainer"
                vu37.Parent = vu25
                vu37.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                vu37.BackgroundTransparency = 1
                vu37.BorderColor3 = Color3.fromRGB(0, 0, 0)
                vu37.BorderSizePixel = 0
                vu37.Position = UDim2.new(0.0204545446, 0, 0.225806445, 0)
                vu37.Size = UDim2.new(0, 420, 0, 240)
                local vu38 = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
                local vu39 = false
                v31.MouseButton1Click:Connect(function()
                    if vu39 ~= false then
                        vu39 = false
                        game:GetService("TweenService"):Create(vu25, vu38, {
                            Size = UDim2.fromOffset(440, 310)
                        }):Play()
                        vu34.Visible = true
                        vu37.Visible = true
                    else
                        vu39 = true
                        game:GetService("TweenService"):Create(vu25, vu38, {
                            Size = UDim2.fromOffset(440, 25)
                        }):Play()
                        vu34.Visible = false
                        vu37.Visible = false
                    end
                end)
                return {
                    NewPage = function(p40)
                        local v41 = Instance.new("UICorner")
                        local v42 = Instance.new("TextButton")
                        local vu43 = Instance.new("ScrollingFrame")
                        local vu44 = Instance.new("UIListLayout")
                        v42.Name = p40
                        v42.Parent = vu35
                        v42.BackgroundColor3 = Color3.fromRGB(73, 75, 79)
                        v42.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        v42.BorderSizePixel = 0
                        v42.Size = UDim2.new(0, 0, 0, 0)
                        v42.AutoButtonColor = false
                        v42.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                        v42.Text = p40
                        v42.TextColor3 = Color3.fromRGB(255, 255, 255)
                        v42.TextSize = 14
                        v41.CornerRadius = UDim.new(0, 3)
                        v41.Name = "PageButtonCorner"
                        v41.Parent = v42
                        vu43.Name = p40
                        vu43.Parent = vu37
                        vu43.Active = true
                        vu43.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        vu43.BackgroundTransparency = 1
                        vu43.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        vu43.BorderSizePixel = 0
                        vu43.Size = UDim2.new(0, 420, 0, 240)
                        vu43.ScrollBarThickness = 0
                        vu44.Name = "PageListLayout"
                        vu44.Parent = vu43
                        vu44.SortOrder = Enum.SortOrder.LayoutOrder
                        vu44.Padding = UDim.new(0, 1)
                        v42.Size = UDim2.fromOffset(v42.TextBounds.X + 15, 25)
                        game:GetService("RunService").RenderStepped:Connect(function()
                            vu43.CanvasSize = UDim2.new(0, 0, 0, vu44.AbsoluteContentSize.Y)
                        end)
                        local vu45 = vu37
                        local v46 = vu35
                        local v47 = next
                        local v48, v49 = v46:GetChildren()
                        local vu50 = vu43
                        while true do
                            local vu51
                            v49, vu51 = v47(v48, v49)
                            if v49 == nil then
                                break
                            end
                            if vu51.ClassName == "TextButton" then
                                vu51.MouseButton1Click:Connect(function()
                                    local v52 = next
                                    local v53, v54 = vu45:GetChildren()
                                    while true do
                                        local v55
                                        v54, v55 = v52(v53, v54)
                                        if v54 == nil then
                                            break
                                        end
                                        if v55.Name ~= vu51.Name then
                                            v55.Visible = false
                                        else
                                            v55.Visible = true
                                        end
                                    end
                                end)
                            end
                        end
                        return {
                            NewSection = function(p56)
                                local vu57 = Instance.new("Frame")
                                local vu58 = Instance.new("Frame")
                                local v59 = Instance.new("UICorner")
                                local v60 = Instance.new("ImageButton")
                                local v61 = Instance.new("TextLabel")
                                local vu62 = Instance.new("Frame")
                                local vu63 = Instance.new("UIListLayout")
                                vu57.Name = "Section"
                                vu57.Parent = vu50
                                vu57.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                                vu57.BackgroundTransparency = 1
                                vu57.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                vu57.BorderSizePixel = 0
                                vu57.Position = UDim2.new(3.63304515e-8, 0, 0, 0)
                                vu57.Size = UDim2.new(0, 420, 0, 25)
                                vu58.Name = "SectionShow"
                                vu58.Parent = vu57
                                vu58.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                                vu58.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                vu58.BorderSizePixel = 0
                                vu58.Size = UDim2.new(0, 420, 0, 25)
                                v59.CornerRadius = UDim.new(0, 3)
                                v59.Name = "SectionShowCorner"
                                v59.Parent = vu58
                                v60.Name = "SectionShowMinimize"
                                v60.Parent = vu58
                                v60.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                v60.BackgroundTransparency = 1
                                v60.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                v60.BorderSizePixel = 0
                                v60.Position = UDim2.new(0.938095212, 0, 0.0799999982, 0)
                                v60.Rotation = 90
                                v60.Size = UDim2.new(0, 20, 0, 20)
                                v60.Image = "http://www.roblox.com/asset/?id=4731371527"
                                v61.Name = "SectionShowText"
                                v61.Parent = vu58
                                v61.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                v61.BackgroundTransparency = 1
                                v61.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                v61.BorderSizePixel = 0
                                v61.Position = UDim2.new(0.0190476198, 0, 0, 0)
                                v61.Size = UDim2.new(0, 200, 0, 25)
                                v61.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                v61.Text = p56
                                v61.TextColor3 = Color3.fromRGB(255, 255, 255)
                                v61.TextSize = 14
                                v61.TextXAlignment = Enum.TextXAlignment.Left
                                vu62.Name = "SectionContent"
                                vu62.Parent = vu58
                                vu62.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                vu62.BackgroundTransparency = 0.99
                                vu62.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                vu62.BorderSizePixel = 0
                                vu62.ClipsDescendants = true
                                vu62.Position = UDim2.new(0, 8, 0, 28)
                                vu62.Size = UDim2.new(0, 412, 0, 250)
                                vu63.Name = "SectionContentLayout"
                                vu63.Parent = vu62
                                vu63.SortOrder = Enum.SortOrder.LayoutOrder
                                vu63.Padding = UDim.new(0, 2)
                                game:GetService("TweenService"):Create(vu57, vu38, {
                                    Size = UDim2.fromOffset(420, 25)
                                }):Play()
                                game:GetService("TweenService"):Create(vu58.SectionContent, vu38, {
                                    Size = UDim2.fromOffset(420, 0)
                                }):Play()
                                game:GetService("TweenService"):Create(vu58.SectionShowMinimize, vu38, {
                                    Rotation = 0
                                }):Play()
                                local vu64 = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
                                local vu65 = false
                                vu58.SectionShowMinimize.MouseButton1Click:Connect(function()
                                    if vu65 ~= false then
                                        vu65 = false
                                        game:GetService("TweenService"):Create(vu57, vu64, {
                                            Size = UDim2.fromOffset(420, 25)
                                        }):Play()
                                        game:GetService("TweenService"):Create(vu58.SectionContent, vu64, {
                                            Size = UDim2.fromOffset(420, 0)
                                        }):Play()
                                        game:GetService("TweenService"):Create(vu58.SectionShowMinimize, vu64, {
                                            Rotation = 0
                                        }):Play()
                                    else
                                        vu65 = true
                                        game:GetService("TweenService"):Create(vu57, vu64, {
                                            Size = UDim2.fromOffset(420, vu63.AbsoluteContentSize.Y + 30)
                                        }):Play()
                                        game:GetService("TweenService"):Create(vu58.SectionContent, vu64, {
                                            Size = UDim2.fromOffset(420, vu63.AbsoluteContentSize.Y)
                                        }):Play()
                                        game:GetService("TweenService"):Create(vu58.SectionShowMinimize, vu64, {
                                            Rotation = 90
                                        }):Play()
                                    end
                                end)
                                local v66 = vu63
                                vu63.GetPropertyChangedSignal(v66, "AbsoluteContentSize"):Connect(function()
                                    if vu65 == true then
                                        game:GetService("TweenService"):Create(vu57, vu64, {
                                            Size = UDim2.fromOffset(420, vu63.AbsoluteContentSize.Y + 30)
                                        }):Play()
                                        game:GetService("TweenService"):Create(vu58.SectionContent, vu64, {
                                            Size = UDim2.fromOffset(420, vu63.AbsoluteContentSize.Y)
                                        }):Play()
                                    end
                                end)
                                return {
                                    NewToggle = function(p67, pu68, p69)
                                        local v70 = Instance.new("Frame")
                                        local vu71 = Instance.new("TextButton")
                                        local v72 = Instance.new("UICorner")
                                        local v73 = Instance.new("TextLabel")
                                        v70.Name = "Toggle"
                                        v70.Parent = vu62
                                        v70.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v70.BackgroundTransparency = 1
                                        v70.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v70.BorderSizePixel = 0
                                        v70.Position = UDim2.new(0.0294117648, 0, 0, 0)
                                        v70.Size = UDim2.new(0, 330, 0, 20)
                                        vu71.Name = "ToggleTrigger"
                                        vu71.Parent = v70
                                        vu71.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                                        vu71.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        vu71.BorderSizePixel = 0
                                        vu71.Position = UDim2.new(0, 0, - 0.0199996941, 0)
                                        vu71.Size = UDim2.new(0, 20, 0, 20)
                                        vu71.AutoButtonColor = false
                                        vu71.Font = Enum.Font.SourceSansSemibold
                                        vu71.Text = ""
                                        vu71.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        vu71.TextSize = 16
                                        v72.CornerRadius = UDim.new(0, 4)
                                        v72.Name = "ButtonCorner"
                                        v72.Parent = vu71
                                        v73.Parent = v70
                                        v73.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v73.BackgroundTransparency = 0.99
                                        v73.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v73.BorderSizePixel = 0
                                        v73.Position = UDim2.new(0.0787878782, 0, - 0.0199996941, 0)
                                        v73.Size = UDim2.new(0, 100, 0, 20)
                                        v73.Font = Enum.Font.SourceSans
                                        v73.Text = p67
                                        v73.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        v73.TextSize = 14
                                        v73.TextXAlignment = Enum.TextXAlignment.Left
                                        local vu74
                                        if (p69 or false) == true then
                                            vu74 = true
                                            vu71.Text = utf8.char(10003)
                                            pu68(vu74)
                                        else
                                            vu74 = false
                                            vu71.Text = ""
                                            pu68(vu74)
                                        end
                                        vu71.MouseButton1Click:Connect(function()
                                            if vu74 ~= false then
                                                vu74 = false
                                                vu71.Text = ""
                                                pu68(vu74)
                                            else
                                                vu74 = true
                                                vu71.Text = utf8.char(10003)
                                                pu68(vu74)
                                            end
                                        end)
                                        return {
                                            SetState = function(p75)
                                                if p75 == true then
                                                    vu74 = true
                                                    vu71.Text = utf8.char(10003)
                                                    pu68(vu74)
                                                else
                                                    vu74 = false
                                                    vu71.Text = ""
                                                    pu68(vu74)
                                                end
                                            end
                                        }
                                    end,
                                    NewButton = function(p76, pu77)
                                        local v78 = Instance.new("Frame")
                                        local vu79 = Instance.new("TextButton")
                                        local v80 = Instance.new("UICorner")
                                        v78.Name = "Button"
                                        v78.Parent = vu62
                                        v78.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v78.BackgroundTransparency = 0.99
                                        v78.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v78.BorderSizePixel = 0
                                        v78.Position = UDim2.new(0.0294117648, 0, 0, 0)
                                        v78.Size = UDim2.new(0, 330, 0, 25)
                                        vu79.Name = "ButtonText"
                                        vu79.Parent = v78
                                        vu79.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                                        vu79.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        vu79.BorderSizePixel = 0
                                        vu79.Position = UDim2.new(0, 0, 0.0799999982, 0)
                                        vu79.Size = UDim2.new(0, 58, 0, 20)
                                        vu79.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        vu79.Text = p76
                                        vu79.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        vu79.TextSize = 12
                                        vu79.AutoButtonColor = false
                                        v80.CornerRadius = UDim.new(0, 4)
                                        v80.Name = "ButtonCorner"
                                        v80.Parent = vu79
                                        game:GetService("RunService").RenderStepped:Connect(function()
                                            vu79.Size = UDim2.fromOffset(vu79.TextBounds.X + 10, 20)
                                        end)
                                        vu79.MouseButton1Click:Connect(function()
                                            pu77()
                                        end)
                                    end,
                                    NewSlider = function(p81, p82, p83, p84, p85, pu86)
                                        local v87 = Instance.new("Frame")
                                        local v88 = Instance.new("TextButton")
                                        local v89 = Instance.new("UICorner")
                                        local v90 = Instance.new("Frame")
                                        local v91 = Instance.new("UICorner")
                                        local v92 = Instance.new("TextLabel")
                                        local v93 = Instance.new("TextLabel")
                                        v87.Name = "Slider"
                                        v87.Parent = vu62
                                        v87.AnchorPoint = Vector2.new(0.5, 0.5)
                                        v87.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v87.BackgroundTransparency = 0.99
                                        v87.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v87.BorderSizePixel = 0
                                        v87.Position = UDim2.new(0.485436887, 0, 0.51592356, 0)
                                        v87.Size = UDim2.new(0, 400, 0, 20)
                                        v88.Name = "SliderMain"
                                        v88.Parent = v87
                                        v88.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
                                        v88.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v88.BorderSizePixel = 0
                                        v88.ClipsDescendants = true
                                        v88.Position = UDim2.new(0, 0, - 0.00198059087, 0)
                                        v88.Size = UDim2.new(0, 400, 0, 20)
                                        v88.AutoButtonColor = false
                                        v88.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        v88.Text = ""
                                        v88.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        v88.TextSize = 12
                                        v89.CornerRadius = UDim.new(0, 4)
                                        v89.Name = "SliderMainCorner"
                                        v89.Parent = v88
                                        v90.Name = "SliderFill"
                                        v90.Parent = v88
                                        v90.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
                                        v90.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v90.BorderSizePixel = 0
                                        v90.Position = UDim2.new(- 2.7743252e-7, 0, 0, 0)
                                        v90.Size = UDim2.new(0, 0, 0, 20)
                                        v91.CornerRadius = UDim.new(0, 4)
                                        v91.Name = "SliderFillCorner"
                                        v91.Parent = v90
                                        v92.Name = "SliderText"
                                        v92.Parent = v88
                                        v92.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v92.BackgroundTransparency = 1
                                        v92.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v92.BorderSizePixel = 0
                                        v92.Position = UDim2.new(3.81469718e-8, 0, 0, 0)
                                        v92.Size = UDim2.new(0, 400, 0, 20)
                                        v92.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        v92.Text = p81
                                        v92.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        v92.TextSize = 12
                                        v93.Name = "SliderValue"
                                        v93.Parent = v92
                                        v93.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v93.BackgroundTransparency = 1
                                        v93.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v93.BorderSizePixel = 0
                                        v93.Position = UDim2.new(0.934546947, 0, 0, 0)
                                        v93.Size = UDim2.new(0, 20, 0, 20)
                                        v93.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        v93.Text = "100"
                                        v93.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        v93.TextSize = 12
                                        v93.TextXAlignment = Enum.TextXAlignment.Right
                                        local vu94 = game:GetService("Players").LocalPlayer:GetMouse()
                                        local vu95 = game:GetService("UserInputService")
                                        local vu96 = p82
                                        local vu97 = p83
                                        local vu98 = p85 or false
                                        local vu99 = v88.SliderFill
                                        local vu100 = v88.SliderText.SliderValue
                                        local vu101 = 400
                                        if p84 then
                                            if p84 <= vu96 then
                                                p84 = vu96
                                            elseif vu97 <= p84 then
                                                p84 = vu97
                                            end
                                            vu99.Size = UDim2.new(1 - (vu97 - p84) / (vu97 - vu96), 0, 0, 20)
                                            vu100.Text = p84
                                            pu86(p84)
                                        end
                                        v88.MouseButton1Down:Connect(function()
                                            isSliding = true
                                            local vu102 = vu98 and tonumber(string.format("%.1f", (tonumber(vu97) - tonumber(vu96)) / vu101 * vu99.AbsoluteSize.X + tonumber(vu96))) or math.floor((tonumber(vu97) - tonumber(vu96)) / vu101 * vu99.AbsoluteSize.X + tonumber(vu96))
                                            pcall(function()
                                                pu86(vu102)
                                                vu100.Text = vu102
                                            end)
                                            vu99.Size = UDim2.new(0, math.clamp(vu94.X - vu99.AbsolutePosition.X, 0, vu101), 0, 20)
                                            moveconnection = vu94.Move:Connect(function()
                                                local vu103 = vu98 and tonumber(string.format("%.1f", (tonumber(vu97) - tonumber(vu96)) / vu101 * vu99.AbsoluteSize.X + tonumber(vu96))) or math.floor((tonumber(vu97) - tonumber(vu96)) / vu101 * vu99.AbsoluteSize.X + tonumber(vu96))
                                                pcall(function()
                                                    pu86(vu103)
                                                    vu100.Text = vu103
                                                end)
                                                vu99.Size = UDim2.new(0, math.clamp(vu94.X - vu99.AbsolutePosition.X, 0, vu101), 0, 20)
                                            end)
                                            releaseconnection = vu95.InputEnded:Connect(function(p104)
                                                if p104.UserInputType == Enum.UserInputType.MouseButton1 or p104.UserInputType == Enum.UserInputType.Touch then
                                                    local vu105 = vu98 and tonumber(string.format("%.1f", (tonumber(vu97) - tonumber(vu96)) / vu101 * vu99.AbsoluteSize.X + tonumber(vu96))) or math.floor((tonumber(vu97) - tonumber(vu96)) / vu101 * vu99.AbsoluteSize.X + tonumber(vu96))
                                                    pcall(function()
                                                        pu86(vu105)
                                                        vu100.Text = vu105
                                                    end)
                                                    vu99.Size = UDim2.new(0, math.clamp(vu94.X - vu99.AbsolutePosition.X, 0, vu101), 0, 20)
                                                end
                                            end)
                                            vu95.InputEnded:Connect(function(p106)
                                                if p106.UserInputType == Enum.UserInputType.MouseButton1 or p106.UserInputType == Enum.UserInputType.Touch then
                                                    moveconnection:Disconnect()
                                                    releaseconnection:Disconnect()
                                                    isSliding = false
                                                end
                                            end)
                                        end)
                                    end,
                                    NewInformation = function(p107, p108)
                                        local v109 = Instance.new("Frame")
                                        local v110 = Instance.new("UICorner")
                                        local v111 = Instance.new("ImageLabel")
                                        local v112 = Instance.new("TextLabel")
                                        local v113 = Instance.new("TextLabel")
                                        local v114 = Instance.new("Frame")
                                        local v115 = Instance.new("UIListLayout")
                                        v109.Name = "Information"
                                        v109.Parent = vu62
                                        v109.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                                        v109.BackgroundTransparency = 0.5
                                        v109.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v109.BorderSizePixel = 0
                                        v109.Position = UDim2.new(0, 0, 0.508000016, 0)
                                        v109.Size = UDim2.new(0, 280, 0, 70)
                                        v110.CornerRadius = UDim.new(0, 4)
                                        v110.Name = "InformationCorner"
                                        v110.Parent = v109
                                        v111.Name = "InformationImage"
                                        v111.Parent = v109
                                        v111.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v111.BackgroundTransparency = 0.99
                                        v111.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v111.BorderSizePixel = 0
                                        v111.Position = UDim2.new(0.0199999996, 0, 0.0833333358, 0)
                                        v111.Size = UDim2.new(0, 50, 0, 50)
                                        v111.Image = "https://www.roblox.com/bust-thumbnail/image?userId=5031712282&width=420&height=420&format=png"
                                        v112.Name = "InformationText"
                                        v112.Parent = v109
                                        v112.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v112.BackgroundTransparency = 1
                                        v112.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v112.BorderSizePixel = 0
                                        v112.Position = UDim2.new(0.22857143, 0, 0.0666666701, 0)
                                        v112.Size = UDim2.new(0, 206, 0, 15)
                                        v112.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        v112.Text = p107
                                        v112.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        v112.TextSize = 14
                                        v112.TextXAlignment = Enum.TextXAlignment.Left
                                        v113.Name = "InformationDescription"
                                        v113.Parent = v109
                                        v113.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v113.BackgroundTransparency = 1
                                        v113.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v113.BorderSizePixel = 0
                                        v113.Position = UDim2.new(0.22857143, 0, 0.316666514, 0)
                                        v113.Size = UDim2.new(0, 150, 0, 26)
                                        v113.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        v113.Text = p108
                                        v113.TextColor3 = Color3.fromRGB(201, 201, 201)
                                        v113.TextSize = 12
                                        v113.TextXAlignment = Enum.TextXAlignment.Left
                                        v113.TextYAlignment = Enum.TextYAlignment.Top
                                        v114.Name = "InformationFunctions"
                                        v114.Parent = v109
                                        v114.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v114.BackgroundTransparency = 1
                                        v114.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v114.BorderSizePixel = 0
                                        v114.Position = UDim2.new(0.22857143, 0, 0.685714304, 0)
                                        v114.Size = UDim2.new(0, 206, 0, 20)
                                        v115.Name = "InformationListLayout"
                                        v115.Parent = v114
                                        v115.FillDirection = Enum.FillDirection.Horizontal
                                        v115.SortOrder = Enum.SortOrder.LayoutOrder
                                        v115.Padding = UDim.new(0, 1)
                                    end,
                                    NewLabel = function(p116)
                                        local v117 = Instance.new("Frame")
                                        local v118 = Instance.new("TextButton")
                                        v117.Name = "Label"
                                        v117.Parent = vu62
                                        v117.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        v117.BackgroundTransparency = 1
                                        v117.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v117.BorderSizePixel = 0
                                        v117.Position = UDim2.new(0, 0, 0.732484102, 0)
                                        v117.Size = UDim2.new(0, 400, 0, 15)
                                        v118.Name = "LabelText"
                                        v118.Parent = v117
                                        v118.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
                                        v118.BackgroundTransparency = 1
                                        v118.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                        v118.BorderSizePixel = 0
                                        v118.Position = UDim2.new(0, 2, 0.0329999998, 0)
                                        v118.Size = UDim2.new(0, 58, 0, 15)
                                        v118.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                                        v118.Text = p116
                                        v118.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        v118.TextSize = 13
                                        v118.TextXAlignment = Enum.TextXAlignment.Left
                                    end
                                }
                            end
                        }
                    end
                }
            end
        }
        getgenv().debugOutput = false
        local v120, vu121 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/refs/heads/main/Scripts/Jailbreak/KeyFetcher.lua"))()
        local vu122 = getupvalue(network.FireServer, 1)
        configs = {
            player = {
                walktog = false,
                walkval = 0,
                infjump = false,
                autoescape = false,
                nofall = false,
                norag = false,
                noislow = false,
                nosky = false,
                nostun = false,
                norwait = false,
                nocslow = false,
                nocircwait = false,
                nopwait = false,
                bypasskd = false,
                alwayssilentp = false,
                alwaysp = false,
                juiced = false,
                crawlequip = false,
                backbone = false
            },
            vehicle = {
                fspeed = 10,
                ftog = false,
                fx = 0,
                fy = 0,
                fz = 0,
                engine = false,
                enginesp = 0,
                brake = false,
                brakesp = 0,
                suspension = false,
                suspensionhe = 0,
                turnsp = 0,
                turn = false,
                tirepop = false,
                infnitro = false,
                rinfnitro = false,
                autoflip = false,
                helibreak = false,
                helienginesp = 0,
                heliengine = false,
                heliheight = false,
                instanttow = false,
                driveonwater = false
            },
            combat = {
                hitboxradius = 3,
                noequipt = false,
                nospread = false,
                norecoil = false,
                nobulletg = false,
                alwaysauto = false,
                alwaysheadshot = false,
                pistolswat = false,
                snipernoblur = false,
                snipernogui = false,
                wallbang = false,
                nogrenadesmoke = false,
                tasermodz = false,
                instantrocketseek = false,
                forcefieldnomiss = false,
                increasetakedowndamage = false,
                increaseforcedamage = false,
                silentaim = {
                    enabled = false,
                    includetaser = false,
                    includeplasma = false,
                    radius = 250,
                    wallcheck = false,
                    fovcirc = false,
                    fovthick = 5,
                    fovtransp = 0
                },
                arrestaura = {
                    enabled = false
                },
                batonsword = {
                    noreloadtime = false,
                    spamlunge = false,
                    spamswoosh = false
                }
            },
            teleportation = {},
            robberies = {
                guardnodmg = false
            },
            nametags = {}
        }
        local vu123 = {
            ropedata = {},
            lastvehiclestats = {
                GarageEngineSpeed = nil,
                Height = nil,
                TurnSpeed = nil
            },
            lastvehiclemodel = nil,
            vehicleEntered = false,
            originalequippeddata = {},
            doorAddedFunction = getconnections(game:GetService("CollectionService"):GetInstanceAddedSignal("Door"))[1].Function,
            remoteid = {
                punch = v120.Punch,
                taser = v120.Taze
            },
            activeaction = {}
        }
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function safe(name, fn)
    local ok, result = pcall(fn)
    if not ok then
        warn("[FAILED]", name, result)
        return nil
    end
    return result
end

local v124 = {
    updateseeking = safe("updateseeking", function()
        return require(ReplicatedStorage.VehicleLink.VehicleLinkBinder)
            ._constructor._updateSeeking
    end),

    hittargetwithspeed = safe("hittargetwithspeed", function()
        return require(ReplicatedStorage.Module.SimulatedPhysicsProjectile)
            .HitTargetWithSpeed
    end),

    isflying = safe("isflying", function()
        return require(ReplicatedStorage.Game.Paraglide).IsFlying
    end),

    tase = safe("tase", function()
        return require(ReplicatedStorage.Game.Item.Taser).Tase
    end),

    doesplayerowncached = safe("doesplayerowncached", function()
        return require(ReplicatedStorage.Gamepass.GamepassSystem) 
            .doesPlayerOwnCached
    end),

    update = safe("update", function()
        return require(ReplicatedStorage.Module.UI).CircleAction.Update
    end),

    getequiptime = safe("getequiptime", function()
        return require(ReplicatedStorage.Game.GunShop.GunUtils).getEquipTime
    end),

    rayignorenon = safe("rayignorenon", function()
        return require(ReplicatedStorage.Module.RayCast).RayIgnoreNonCollide
    end),

    plasmashootother = safe("plasmashootother", function()
        return require(ReplicatedStorage.Game.Item.PlasmaGun).ShootOther
    end),

    pistolsetupmodel = safe("pistolsetupmodel", function()
        return require(ReplicatedStorage.Game.Item.Pistol).SetupModel
    end),

    rayignore = safe("rayignore", function()
        return require(ReplicatedStorage.Module.RayCast)
            .RayIgnoreNonCollideWithIgnoreList
    end),

    shoot = safe("shoot", function()
        return require(ReplicatedStorage.Game.Item.Gun).Shoot
    end),

    attemptToggleCrawling = safe("attemptToggleCrawling", function()
        return getupvalue(
            require(ReplicatedStorage.Game.DefaultActions)
                .crawlButton.onPressed,
            1
        ).attemptToggleCrawling
    end),
}

        vu123.ori = v124
        vu123.guardnpcbinder = require(game:GetService("ReplicatedStorage").GuardNPC.GuardNPCBinder)
        vu123.combatconst = require(game:GetService("ReplicatedStorage").Combat.CombatConsts)
        vu123.combatutils = require(game:GetService("ReplicatedStorage").Combat.CombatUtils)
        vu123.playerutil = require(game:GetService("ReplicatedStorage").Game.PlayerUtils)
        vu123.actionbuttonservice = require(game:GetService("ReplicatedStorage").ActionButton.ActionButtonService)
        vu123.settingss = require(game:GetService("ReplicatedStorage").Resource.Settings)
        vu123.characterutil = require(game:GetService("ReplicatedStorage").Game.CharacterUtil)
        vu123.paraglide = require(game:GetService("ReplicatedStorage").Game.Paraglide)
        vu123.alexchassis = require(game:GetService("ReplicatedStorage").Module.AlexChassis)
        vu123.itemgun = require(game:GetService("ReplicatedStorage").Game.Item.Gun)
        vu123.itemsys = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem)
        vu123.gunutil = require(game:GetService("ReplicatedStorage").Game.GunShop.GunUtils)
        vu123.gamepasssystem = require(game:GetService("ReplicatedStorage").Gamepass.GamepassSystem)
        vu123.pistolitem = require(game:GetService("ReplicatedStorage").Game.Item.Pistol)
        vu123.smokegrenadeitem = require(game:GetService("ReplicatedStorage").Game.SmokeGrenade.SmokeGrenade)
        vu123.circleac = require(game:GetService("ReplicatedStorage").Module.UI).CircleAction
        vu123.tase = require(game:GetService("ReplicatedStorage").Game.Item.Taser)
        vu123.plasmagun = require(game:GetService("ReplicatedStorage").Game.Item.PlasmaGun)
        vu123.duck = require(game:GetService("ReplicatedStorage").Game.Robbery.TombRobbery.TombRobberySystem).duck
        vu123.onvehicleentered = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).OnVehicleEntered
        vu123.onvehicleexited = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).OnVehicleExited
        vu123.onlocalitemequipped = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem).OnLocalItemEquipped
        vu123.onlocalitemunequipped = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem).OnLocalItemUnequipped
        vu123.bulletonlocalhitplayer = require(game:GetService("ReplicatedStorage").Game.Item.Gun).BulletEmitterOnLocalHitPlayer
        vu123.vehiclelinkbinder = require(game:GetService("ReplicatedStorage").VehicleLink.VehicleLinkBinder)
        vu123.raycast = require(game:GetService("ReplicatedStorage").Module.RayCast)
        vu123.door = {
            openDoor = getupvalue(getproto(getupvalue(vu123.doorAddedFunction, 2), 1, true)[1], 7),
            doors = getupvalue(vu123.doorAddedFunction, 1)
        }
        vu123.hittargetwithspeed = require(game:GetService("ReplicatedStorage").Module.SimulatedPhysicsProjectile).HitTargetWithSpeed
        local vu125 = game:GetService("ReplicatedStorage").Game.ItemConfig:Clone()
        vu125.Name = "ItemConfigBackup"
        getgenv().Circle = Drawing.new("Circle")
        Circle.Color = Color3.new(1, 1, 1)
        Circle.Thickness = configs.combat.silentaim.fovthick
        Circle.Radius = configs.combat.silentaim.radius
        Circle.Visible = configs.combat.silentaim.fovcirc
        Circle.NumSides = 100
        Circle.Filled = false
        Circle.Transparency = configs.combat.silentaim.fovtransp
        local v126 = next
        local v127, v128 = getgc()
        local v129 = vu119
        while true do
            local v130
            v128, v130 = v126(v127, v128)
            if v128 == nil then
                break
            end
            if type(v130) == "function" and (islclosure(v130) and tostring(getfenv(v130).script) == "LocalScript") then
                local v131 = tostring(getinfo(v130).name)
                if getconstants(v130)[3] == "StartRagdolling" then
                    vu123.stunnedragdoll = v130
                end
                if v131 == "AttemptArrest" then
                    vu123.attemptarrest = v130
                end
                if v131 == "StartNitro" then
                    vu123.startnitro = v130
                    vu123.nitro = getupvalue(v130, 8)
                end
                if v131 == "StopNitro" then
                    vu123.stopnitro = v130
                end
                if v131:find("CheatCheck") then
                    hookfunction(v130, function()
                    end)
                end
            end
        end
        local v132 = next
        local v133, v134 = getconnections(game:GetService("RunService").Heartbeat)
        while true do
            local v135
            v134, v135 = v132(v133, v134)
            if v134 == nil then
                break
            end
            if v135.Function and islclosure(v135.Function) then
                if getconstants(v135.Function)[13] == "Time/UI" then
                    vu123.walkspeedfun = getupvalue(v135.Function, 6)
                end
                if getconstants(v135.Function)[3] == "Vehicle Heartbeat" then
                    vu123.heli = getupvalue(v135.Function, 1).Heli
                    vu123.ori.heliupdate = vu123.heli.Update
                end
            end
        end
        local v136 = next
        local v137 = vu123.actionbuttonservice.active
        local v138 = nil
        while true do
            local v139
            v138, v139 = v136(v137, v138)
            if v138 == nil then
                break
            end
            if table.find(v139.keyCodes, Enum.KeyCode.V) then
                vu123.activeaction.flip = v139
            end
            if table.find(v139.keyCodes, Enum.KeyCode.LeftControl) then
                vu123.activeaction.roll = v139
            end
        end
        function vu123.punchCorrection()
            while true do
                if configs.player.alwayssilentp ~= true then
                    task.wait(0.3)
                    vu121:FireServer(vu123.remoteid.punch)
                else
                    task.wait(0.5)
                    getupvalue(require(game:GetService("ReplicatedStorage").Game.DefaultActions).punchButton.onPressed, 1).attemptPunch()
                end
                if configs.player.alwaysp == false then
                    return
                end
            end
        end
        function vu123.duckCorrection()
            repeat
                vu123.duck()
                task.wait(2)
            until configs.player.backbone == false
        end
        function vu123.flipCorrection()
            repeat
                task.wait(0.1)
                pcall(function()
                    local v140 = next
                    local v141 = vu123.actionbuttonservice.active
                    local v142 = nil
                    while true do
                        local v143
                        v142, v143 = v140(v141, v142)
                        if v142 == nil then
                            break
                        end
                        if table.find(v143.keyCodes, Enum.KeyCode.V) then
                            v143.onPressed(true)
                        end
                    end
                end)
            until configs.vehicle.autoflip == false
        end
        function vu123.hasKeyCorrection(p144)
            if p144 then
                hookfunction(vu123.playerutil.hasKey, function()
                    return true
                end)
            elseif isfunctionhooked(vu123.playerutil.hasKey) then
                restorefunction(vu123.playerutil.hasKey)
            end
        end
        function vu123.headshotCorrection(p145)
            if p145 then
                epichook = hookfunction(vu123.bulletonlocalhitplayer, function(...)
                    local v146 = {
                        ...
                    }
                    v146[15].isWallbang = false
                    v146[15].isHeadshot = true
                    return epichook(...)
                end)
            elseif isfunctionhooked(vu123.bulletonlocalhitplayer) then
                restorefunction(vu123.bulletonlocalhitplayer)
            end
        end
        function vu123.smokeGrenadeHook(p147)
            if p147 then
                hookfunction(vu123.smokegrenadeitem._playExplosionFx, function()
                end)
            elseif isfunctionhooked(vu123.smokegrenadeitem._playExplosionFx) then
                restorefunction(vu123.smokegrenadeitem._playExplosionFx)
            end
        end
        function vu123.isCrawlingCorrection()
            repeat
                task.wait(0.1)
                vu123.characterutil.IsCrawling = false
            until configs.player.crawlequip == false
        end
        function vu123.nitroCorrection()
            repeat
                task.wait()
                vu123.nitro.NitroLastMax = 250
                vu123.nitro.Nitro = configs.vehicle.rinfnitro and math.random(10, 249) or 249
                vu123.nitro.NitroForceUIUpdate = true
            until configs.vehicle.infnitro == false
        end
        function vu123.launchVehicleFlight()
            local v148 = Instance.new("BodyGyro", game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
            local v149 = Instance.new("BodyVelocity", game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
            local v150 = game:GetService("UserInputService")
            local v151 = workspace.CurrentCamera
            v149.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            v148.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            v148.D = 50000
            v148.P = 1500000000
            while true do
                task.wait()
                v148.CFrame = v151.CFrame * CFrame.Angles(math.rad(configs.vehicle.fx), math.rad(configs.vehicle.fy), math.rad(configs.vehicle.fz))
                workspace.CurrentCamera.CameraType = Enum.CameraType.Track
                v149.Velocity = Vector3.new()
                if v150:IsKeyDown(Enum.KeyCode.W) then
                    v149.Velocity = v149.Velocity + v151.CFrame.LookVector
                end
                if v150:IsKeyDown(Enum.KeyCode.A) then
                    v149.Velocity = v149.Velocity - v151.CFrame.RightVector
                end
                if v150:IsKeyDown(Enum.KeyCode.S) then
                    v149.Velocity = v149.Velocity - v151.CFrame.LookVector
                end
                if v150:IsKeyDown(Enum.KeyCode.D) then
                    v149.Velocity = v149.Velocity + v151.CFrame.RightVector
                end
                v149.Velocity = v149.Velocity * configs.vehicle.fspeed
                if vu123.vehicleEntered == false or configs.vehicle.ftog == false then
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                    v148:Destroy()
                    v149:Destroy()
                    return
                end
            end
        end
        function vu123.getOldWeaponData(p152, p153)
            return rawget(require(vu125[p152]), p153)
        end
        function vu123.setBatonSwordTime(p154)
            local v155 = require(game:GetService("ReplicatedStorage").Game.Item.Baton)
            local v156 = require(game:GetService("ReplicatedStorage").Game.Item.Sword)
            getupvalue(v155.new, 2).ReloadTime = p154 and 0 or 0.5
            getupvalue(v156.new, 2).ReloadTime = p154 and 0 or 0.5
        end
        function vu123.spamBatonSwordSwoosh()
            while true do
                task.wait()
                local v157 = vu123.itemsys.GetLocalEquipped()
                if v157 and (v157.__ClassName == "Sword" or v157.__ClassName == "Baton") then
                    require(game:GetService("ReplicatedStorage").Game.Item[v157.__ClassName]).SwingSwoosh(v157)
                end
                if configs.combat.batonsword.spamswoosh == false then
                    return
                end
            end
        end
        function vu123.spamBatonSwordLunge()
            while true do
                task.wait()
                local v158 = vu123.itemsys.GetLocalEquipped()
                if v158 and (v158.__ClassName == "Sword" or v158.__ClassName == "Baton") then
                    require(game:GetService("ReplicatedStorage").Game.Item[v158.__ClassName]).SwingLunge(v158)
                end
                if configs.combat.batonsword.spamlunge == false then
                    return
                end
            end
        end
        function vu123.notInWall(p159, p160, p161)
            if not p161 then
                return true
            end
            local v162 = Ray.new(game:GetService("Workspace").CurrentCamera.CFrame.p, p159 - game:GetService("Workspace").CurrentCamera.CFrame.p)
            return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(v162, p160) == nil
        end
        function vu123.isEnemies(p163, p164)
            local v165 = tostring(p163)
            local v166 = tostring(p164)
            if v165 == "Criminal" and v166 == "Police" then
                return true
            end
            if v165 == "Criminal" and v166 == "Prisoner" then
                return false
            end
            if v165 == "Police" and v166 == "Criminal" then
                return true
            end
            if v165 == "Police" and v166 == "Prisoner" then
                return false
            end
            if v165 == "Prisoner" and v166 == "Police" then
                return true
            end
            if v165 == "Prisoner" and v166 == "Criminal" then
                return false
            end
        end
        function vu123.getNearestToCursor()
            local v167 = vu123.notInWall
            local v168 = vu123.isEnemies
            local v169 = next
            local v170, v171 = game:GetService("Players"):GetPlayers()
            local v172 = nil
            while true do
                local v173
                v171, v173 = v169(v170, v171)
                if v171 == nil then
                    break
                end
                if v168(game:GetService("Players").LocalPlayer.Team, v173.Team) and (v173 ~= game:GetService("Players").LocalPlayer and v173.Character and (v173.Character:FindFirstChild("HumanoidRootPart") and (v173.Character:FindFirstChild("Humanoid") and v173.Character.Humanoid.Health ~= 0 and (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v173.Character.HumanoidRootPart.Position).magnitude < 9000000000))) then
                    local v174, v175 = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(v173.Character.HumanoidRootPart.Position)
                    if v175 and v167(v173.Character.HumanoidRootPart.Position, {
                        game:GetService("Players").LocalPlayer.Character,
                        v173.Character
                    }, configs.combat.silentaim.wallcheck) then
                        if (Vector2.new(v174.X, v174.Y) - Vector2.new(game:GetService("Players").LocalPlayer:GetMouse().X, game:GetService("Players").LocalPlayer:GetMouse().Y)).magnitude < configs.combat.silentaim.radius then
                            v172 = v173
                        end
                    end
                end
            end
            return v172
        end
        function vu123.getPlayerVehicle(p176)
            local v177 = next
            local v178, v179 = game:GetService("CollectionService"):GetTagged("Vehicle")
            local v180 = nil
            while true do
                local v181
                v179, v181 = v177(v178, v179)
                if v179 == nil then
                    break
                end
                local v182 = next
                local v183, v184 = v181:GetChildren()
                while true do
                    local v185
                    v184, v185 = v182(v183, v184)
                    if v184 == nil then
                        break
                    end
                    if v185.Name == "Seat" or v185.Name == "Passenger" then
                        local v186 = v185:FindFirstChild("PlayerName")
                        if v186 and v186.Value == p176 then
                            return v180
                        end
                    end
                end
            end
            return v180
        end
        function vu123.getNearestVehicle()
            local v187 = game:GetService("Players").LocalPlayer.Character
            local v188 = next
            local v189, v190 = game:GetService("CollectionService"):GetTagged("Vehicle")
            local v191 = 100
            local v192 = nil
            while true do
                local v193
                v190, v193 = v188(v189, v190)
                if v190 == nil then
                    break
                end
                if v193:FindFirstChild("Seat") or v193:FindFirstChild("Passenger") then
                    local v194 = (v187:FindFirstChild("HumanoidRootPart").Position - v193:GetModelCFrame().Position).magnitude
                    if v194 < v191 then
                        v192 = v193
                        v191 = v194
                    end
                end
            end
            return v192
        end
        function vu123.getNearestPlayerNoCuffed()
            local v195 = next
            local v196, v197 = game:GetService("Players"):GetPlayers()
            local v198 = 18
            while true do
                local v199
                v197, v199 = v195(v196, v197)
                if v197 == nil then
                    break
                end
                if tostring(v199.Team) == "Criminal" then
                    local v200 = v199.Character or nil
                    if v200 ~= nil and not v199.Character:GetAttribute("Handcuffs") then
                        local v201 = v200:FindFirstChild("Head") or nil
                        local v202 = v200:FindFirstChild("Humanoid") or nil
                        if v201 ~= nil and v202 ~= nil and ((game:GetService("Players").LocalPlayer.Character:GetModelCFrame().Position - v201.Position).magnitude < v198 and v199 ~= nil) then
                            return v199
                        end
                    end
                end
            end
            return false
        end
        function vu123.launchArrestAura()
            local v203 = vu123.getNearestPlayerNoCuffed
            while true do
                task.wait(0.15)
                local v204 = v203()
                if v204 then
                    vu123.attemptarrest(game:GetService("Players"):FindFirstChild(tostring(v204)))
                end
                if configs.combat.arrestaura.enabled == false then
                    return
                end
            end
        end
        function vu123.updateToOriginalChassisStats()
            local v205 = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).GetLocalVehiclePacket()
            if v205 ~= nil and (vu123.lastvehiclestats ~= nil and (vu123.lastvehiclemodel ~= nil and v205.Model ~= v205.lastvehiclemodel)) then
                local v206 = vu123.lastvehiclestats
                if configs.vehicle.engine == false then
                    v205.GarageEngineSpeed = v206.GarageEngineSpeed
                end
                if configs.vehicle.suspension == false then
                    v205.Height = v206.Height
                end
                if configs.vehicle.turn == false then
                    v205.TurnSpeed = v206.TurnSpeed
                end
            end
        end
        function vu123.changeHitboxRadius(p207)
            local v208 = setreadonly
            local v209 = vu123.combatconst
            local v210 = isreadonly(vu123.combatconst)
            if v210 then
                v210 = false
            end
            v208(v209, v210)
            vu123.combatconst.DEFAULT_ROOT_PART_HIT_RADIUS = p207
        end
        function vu123.hookNearestObj()
            local v211 = vu123.ropedata.nearestObj.PrimaryPart.CFrame:PointToObjectSpace(require(game:GetService("ReplicatedStorage"):WaitForChild("Std"):WaitForChild("GeomUtils")).closestPointInPart(vu123.ropedata.nearestObj.PrimaryPart, vu123.ropedata.obj.Position))
            vu123.ropedata.manifest.reqLinkRemote:FireServer(vu123.ropedata.nearestObj, v211)
        end
        function vu123.onHitSurfaceHook()
            if configs.combat.increasetakedowndamage then
                local v212 = vu123.itemsys.GetLocalEquipped()
                if v212.FakeName ~= "Sniper" then
                    v212.FakeName = "Sniper"
                end
                repeat
                    wait()
                until v212.BulletEmitter ~= nil
                setconstant(v212.BulletEmitter.OnHitSurface._handlerListHead._fn, 75, "FakeName")
            end
        end
        task.spawn(function()
            setupvalue(vu121.FireServer, 1, function(p213, ...)
                if # {
                    ...
                } ~= 2 or not debug.traceback():find("LocalScript:1343") then
                    return vu122(p213, ...)
                end
            end)
            function vu123.hittargetwithspeed(...)
                local v214 = {
                    ...
                }
                if configs.combat.forcefieldnomiss then
                    v214[3] = 0
                end
                return vu123.ori.hittargetwithspeed(unpack(v214))
            end
            old2 = hookfunction(vu123.bulletonlocalhitplayer, function(...)
                local v215 = {
                    ...
                }
                if configs.combat.alwaysheadshot then
                    v215[15].isHeadshot = true
                    v215[15].isWallbang = false
                end
                return old2(unpack(v215))
            end)
            function vu123.itemgun.Shoot(p216, p217)
                if configs.combat.silentaim.enabled then
                    local v218 = vu123.getNearestToCursor()
                    if v218 then
                        v218 = vu123.getNearestToCursor().Character
                    end
                    if v218 then
                        v218 = v218:FindFirstChild("HumanoidRootPart")
                    end
                    if v218 then
                        p216.TipDirection = (v218.Position - p216.Tip.Position).Unit
                    end
                end
                vu123.ori.shoot(p216, p217)
            end
            function vu123.plasmagun.ShootOther(p219, p220)
                if configs.combat.silentaim.enabled and configs.combat.silentaim.includeplasma then
                    local v221 = vu123.getNearestToCursor()
                    if v221 then
                        v221 = vu123.getNearestToCursor().Character
                    end
                    if v221 then
                        v221 = v221:FindFirstChild("HumanoidRootPart")
                    end
                    if v221 then
                        p219.TipDirection = (v221.Position - p219.Tip.Position).Unit
                    end
                end
                vu123.ori.plasmashootother(p219, p220)
            end
            function vu123.tase.Tase(p222, ...)
                if configs.combat.tasermodz then
                    p222._lastDraw = 0
                end
                return vu123.ori.tase(p222, ...)
            end
            function vu123.raycast.RayIgnoreNonCollideWithIgnoreList(...)
                if debug.traceback():find("Taser") and (configs.combat.silentaim.enabled and configs.combat.silentaim.includetaser) then
                    local v223 = vu123.getNearestToCursor()
                    if v223 then
                        v223 = vu123.getNearestToCursor().Character
                    end
                    if v223 then
                        v223 = v223:FindFirstChild("HumanoidRootPart")
                    end
                    if v223 then
                        return v223, v223.Position, v223.Position, ...
                    end
                end
                return vu123.ori.rayignore(...)
            end
            function vu123.raycast.RayIgnoreNonCollide(...)
                local v224 = {
                    ...
                }
                if configs.vehicle.driveonwater and debug.traceback():find("AlexChassis") then
                    v224[6] = true
                end
                return vu123.ori.rayignorenon(unpack(v224))
            end
            function vu123.gamepasssystem.doesPlayerOwnCached(...)
                return configs.combat.pistolswat and (tostring(({
                    ...
                })[1]) == game:GetService("Players").LocalPlayer.Name and debug.traceback():find("tem.Pistol")) and true or vu123.ori.doesplayerowncached(...)
            end
            function vu123.gunutil.getEquipTime(...)
                return configs.combat.noequipt and 0 or vu123.ori.getequiptime(...)
            end
            function vu123.circleac.Update(...)
                local vu225 = ...
                pcall(function()
                    vu123.ori.update(vu225)
                    if configs.player.nocircwait then
                        vu123.circleac.Spec.PressedAt = 0.01
                    end
                end)
            end
            function vu123.paraglide.IsFlying(...)
                return configs.player.nosky and (debug.traceback():find("Falling") and true) or vu123.ori.isflying(...)
            end
            function vu123.vehiclelinkbinder._constructor._updateSeeking(p226)
                vu123.ropedata = p226
                return vu123.ori.updateseeking(p226)
            end
            game:GetService("Players").LocalPlayer:GetMouse().Move:Connect(function()
                local v227 = game:GetService("UserInputService"):GetMouseLocation()
                Circle.Position = Vector2.new(v227.X, v227.Y)
            end)
            game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
                local v228 = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                if v228 then
                    if configs.player.nofall then
                        v228:AddTag("NoFallDamage")
                    end
                    if configs.player.norag then
                        v228:AddTag("NoRagdoll")
                    end
                end
            end)
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if configs.player.infjump then
                    game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
            game:GetService("Players").LocalPlayer.PlayerGui.ChildAdded:Connect(function(p229)
                if p229.Name == "LoadingBarGui" then
                    if vu123.ropedata.nearestObj ~= nil then
                        if configs.vehicle.instanttow and vu123.ropedata.obj.Name == "MetalHook" then
                            vu123.hookNearestObj()
                        elseif configs.vehicle.helipick and vu123.ropedata.obj.Name == "RopePull" then
                            vu123.hookNearestObj()
                        end
                    end
                    print("wow mama is exist in playergui!@!!!!")
                end
            end)
            game.Lighting.ChildAdded:connect(function(pu230)
                if configs.combat.snipernoblur and pu230.Name == "Blur" then
                    pu230:GetPropertyChangedSignal("Size"):connect(function()
                        pu230.Enabled = false
                    end)
                end
            end)
            vu123.onvehicleentered:Connect(function(p231)
                vu123.vehicleEntered = true
                if p231.Model ~= vu123.lastvehiclemodel and p231.Type == "Chassis" then
                    vu123.lastvehiclemodel = p231.Model
                    vu123.lastvehiclestats.GarageEngineSpeed = p231.GarageEngineSpeed
                    vu123.lastvehiclestats.TurnSpeed = p231.TurnSpeed
                    vu123.lastvehiclestats.Height = p231.Height
                    print("changed")
                end
                if configs.vehicle.ftog then
                    vu123.launchVehicleFlight()
                end
                if p231.Type ~= "Heli" then
                    if p231.Type == "Chassis" then
                        p231.TirePopDuration = configs.vehicle.nopop and 0 or 7.5
                        p231.DisableDuration = configs.vehicle.nopop and 0 or 7.5
                        p231.TirePopProportion = configs.vehicle.nopop and 0 or 0.5
                    end
                else
                    p231.MaxHeight = configs.vehicle.heliheight and 9000000000 or 400
                    p231.FallOutOfSkyDuration = configs.vehicle.helibreak and 0 or 10
                    p231.DisableDuration = configs.vehicle.helibreak and 0 or 10
                end
            end)
            vu123.onvehicleexited:Connect(function()
                vu123.vehicleEntered = false
            end)
            vu123.onlocalitemequipped:Connect(function(_)
                local v232 = vu123.getOldWeaponData
                local v233 = vu123.itemsys.GetLocalEquipped()
                if v233.FakeName ~= "Sniper" then
                    v233.FakeName = "Sniper"
                end
                task.spawn(function()
                    vu123.onHitSurfaceHook()
                end)
                if v232(v233.__ClassName, "EquipTime") ~= nil then
                    v233.Config.EquipTime = configs.combat.noequipt and 0 or v232(v233.__ClassName, "EquipTime")
                end
                if v232(v233.__ClassName, "FireAuto") ~= nil then
                    v233.Config.FireAuto = configs.combat.alwaysauto and true or v232(v233.__ClassName, "FireAuto")
                end
                if v232(v233.__ClassName, "BulletSpread") ~= nil then
                    v233.Config.BulletSpread = configs.combat.nospread and 0 or v232(v233.__ClassName, "BulletSpread")
                end
                if v232(v233.__ClassName, "CamShakeMagnitude") ~= nil then
                    v233.Config.CamShakeMagnitude = configs.combat.norecoil and 0 or v232(v233.__ClassName, "CamShakeMagnitude")
                end
                if v233.__ClassName == "Taser" and (v232(v233.__ClassName, "ReloadTimeHit") ~= nil and v232(v233.__ClassName, "ReloadTime") ~= nil) then
                    v233.Config.ReloadTimeHit = configs.combat.tasermodz and 0 or v232(v233.__ClassName, "ReloadTimeHit")
                    v233.Config.ReloadTime = configs.combat.tasermodz and 0 or v232(v233.__ClassName, "ReloadTime")
                end
                if v233 and (v233.BulletEmitter and v233.BulletEmitter.GravityVector) then
                    local v234 = v233.BulletEmitter
                    local _ = configs.combat.nobulletg
                    v234.GravityVector = Vector3.new(0, - workspace.Gravity / 10, 0)
                end
            end)
            task.spawn(function()
                while true do
                    task.wait()
                    pcall(function()
                        local v235 = game:GetService("Players").LocalPlayer.Character.Humanoid or nil
                        local v236 = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).GetLocalVehiclePacket() or nil
                        if v235 ~= nil and (v236 ~= nil and (vu123.vehicleEntered and v236.Type == "Chassis")) then
                            if configs.vehicle.engine then
                                v236.GarageEngineSpeed = configs.vehicle.enginesp
                            end
                            if configs.vehicle.suspension then
                                v236.Height = configs.vehicle.suspensionhe
                            end
                            if configs.vehicle.turn then
                                v236.TurnSpeed = configs.vehicle.turnsp
                            end
                        end
                    end)
                end
            end)
        end)
        local v237 = v129.SetupUI("bru what", function()
        end)
        local v238 = v237.NewPage("Players")
        local v239 = v238.NewSection("Character")
        v239.NewSlider("Walkspeed", 0, 10, 5, configs.player.walkval, function(p240)
            configs.player.walkval = p240
        end)
        v239.NewToggle("Enable Walkspeed", function(p241)
            configs.player.walktog = p241
        end, configs.player.walktog)
        v239.NewToggle("Inf Jump", function(p242)
            configs.player.infjump = p242
        end, configs.player.infjump)
        local v243 = v238.NewSection("Utilities")
        v243.NewToggle("Automatic Escape(BETA)", function(p244)
            configs.player.autoescape = p244
        end, configs.player.autoescape)
        v243.NewToggle("No Ragdoll", function(p245)
            configs.player.norag = p245
            local v246 = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart") or nil
            if configs.player.norag ~= false or v246 == nil then
                if configs.player.norag == true and v246 ~= nil then
                    v246:AddTag("NoRagdoll")
                end
            else
                v246:RemoveTag("NoRagdoll")
            end
        end, configs.player.norag)
        v243.NewToggle("No Fall Injury", function(p247)
            configs.player.nofall = p247
            local v248 = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart") or nil
            if configs.player.nofall ~= false or v248 == nil then
                if configs.player.nofall == true and v248 ~= nil then
                    v248:AddTag("NoFallDamage")
                end
            else
                v248:RemoveTag("NoFallDamage")
            end
        end, configs.player.nofall)
        v243.NewToggle("No Skydive", function(p249)
            configs.player.nosky = p249
        end, configs.player.nosky)
        v243.NewToggle("No Ragdoll Stun", function(p250)
            configs.player.nostun = p250
            vu123.settingss.Time.Stunned = configs.player.nostun and 0 or 5
            local v251 = setupvalue
            local v252 = vu123.stunnedragdoll
            local v253 = 1
            local v254 = configs.player.nostun
            if v254 then
                v254 = nil
            end
            v251(v252, v253, v254)
        end, configs.player.nostun)
        v243.NewToggle("No Roll Wait", function(p255)
            configs.player.norwait = p255
            vu123.activeaction.roll.useEvery = configs.player.norwait and 0 or 5
        end, configs.player.norwait)
        v243.NewToggle("No Crawling Slow", function(p256)
            configs.player.nocslow = p256
            setconstant(vu123.walkspeedfun, 16, configs.player.nocslow and 1 or 0.4)
        end, configs.player.nocslow)
        v243.NewToggle("No Circle Hold", function(p257)
            configs.player.nocircwait = p257
        end, configs.player.nocircwait)
        v243.NewToggle("No Injury Slow", function(p258)
            configs.player.noislow = p258
            setconstant(vu123.walkspeedfun, 8, configs.player.noislow and 1 or 0.5)
        end, configs.player.noislow)
        v243.NewToggle("No Spotlight Slow", function(p259)
            configs.player.nospslow = p259
            setconstant(vu123.walkspeedfun, 35, configs.player.nospslow and 1 or 0.8)
        end, configs.player.nospslow)
        v243.NewToggle("Always Keycard", function(p260)
            configs.player.bypasskd = p260
            vu123.hasKeyCorrection(configs.player.bypasskd)
        end, configs.player.bypasskd)
        v243.NewToggle("Allow Equip While Crawling", function(p261)
            configs.player.crawlequip = p261
            if configs.player.crawlequip then
                vu123.isCrawlingCorrection()
            end
        end, configs.player.crawlequip)
        v243.NewToggle("Allow Walk When Arrested", function(p262)
            configs.player.allowwalkcuffed = p262
        end, configs.player.allowwalkcuffed)
        v243.NewToggle("Break Your Back Bone", function(p263)
            configs.player.backbone = p263
            if configs.player.backbone then
                vu123.duckCorrection()
            end
        end, configs.player.backbone)
        v243.NewToggle("Get Avatar Outfit On Respawn", function(p264)
            configs.player.getclothes = p264
        end, configs.player.getclothes)
        v243.NewButton("Get Avatar Outfit", function()
        end)
        v243.NewButton("Get Police Outfit", function()
        end)
        v243.NewLabel("NOTE: No Circle Hold might broke/not working on some actions")
        local v265 = v237.NewPage("Vehicle")
        local v266 = v265.NewSection("Utilities")
        v266.NewSlider("Flight Speed", 10, 1000, configs.vehicle.fspeed, true, function(p267)
            configs.vehicle.fspeed = p267
        end)
        v266.NewSlider("Flight Rotation X", 0, 360, configs.vehicle.fx, false, function(p268)
            configs.vehicle.fx = p268
        end)
        v266.NewSlider("Flight Rotation Y", 0, 360, configs.vehicle.fy, false, function(p269)
            configs.vehicle.fy = p269
        end)
        v266.NewSlider("Flight Rotation Z", 0, 360, configs.vehicle.fz, false, function(p270)
            configs.vehicle.fz = p270
        end)
        v266.NewToggle("Vehicle Flight", function(p271)
            configs.vehicle.ftog = p271
            if configs.vehicle.ftog and vu123.vehicleEntered == true then
                vu123.launchVehicleFlight()
            end
        end, configs.vehicle.ftog)
        v266.NewToggle("Infinite Nitro", function(p272)
            configs.vehicle.infnitro = p272
            if configs.vehicle.infnitro then
                vu123.nitroCorrection()
            end
        end, configs.vehicle.infnitro)
        v266.NewToggle("Random Infinite Nitro", function(p273)
            configs.vehicle.rinfnitro = p273
        end, configs.vehicle.rinfnitro)
        v266.NewToggle("Always Nitro", function(p274)
            configs.vehicle.alwaysnit = p274
        end, configs.vehicle.alwaysnit)
        v266.NewToggle("No Hijack Vehicle", function(p275)
            configs.vehicle.alwayshij = p275
        end, configs.vehicle.alwayshij)
        local v276 = v265.NewSection("Car Mods")
        v276.NewSlider("Engine Speed", 1, 200, configs.vehicle.enginesp, false, function(p277)
            configs.vehicle.enginesp = p277
        end)
        v276.NewToggle("Apply Engine Speed", function(p278)
            configs.vehicle.engine = p278
            if configs.vehicle.engine == false then
                vu123.updateToOriginalChassisStats()
            end
        end, configs.vehicle.engine)
        v276.NewSlider("Suspension Height", 1, 150, configs.vehicle.suspensionhe, false, function(p279)
            configs.vehicle.suspensionhe = p279
        end)
        v276.NewToggle("Apply Suspension Height", function(p280)
            configs.vehicle.suspension = p280
            if configs.vehicle.suspension == false then
                vu123.updateToOriginalChassisStats()
            end
        end, configs.vehicle.suspension)
        v276.NewSlider("Turn Speed", 1, 5, configs.vehicle.turnsp, true, function(p281)
            configs.vehicle.turnsp = p281
        end)
        v276.NewToggle("Apply Turn Speed", function(p282)
            configs.vehicle.turn = p282
            if configs.vehicle.suspension == false then
                vu123.updateToOriginalChassisStats()
            end
        end, configs.vehicle.turn)
        v276.NewToggle("Anti Tire Pop", function(p283)
            configs.vehicle.nopop = p283
        end, configs.vehicle.nopop)
        v276.NewToggle("Automatic Flip", function(p284)
            configs.vehicle.autoflip = p284
            if configs.vehicle.autoflip then
                vu123.flipCorrection()
            end
        end, configs.vehicle.autoflip)
        v276.NewToggle("Instant Tow", function(p285)
            configs.vehicle.instanttow = p285
        end, configs.vehicle.instanttow)
        v276.NewToggle("Drive On Water", function(p286)
            configs.vehicle.driveonwater = p286
            setconstant(vu123.alexchassis.UpdateEngine, 280, configs.vehicle.driveonwater and 1 or 0.625)
        end, configs.vehicle.driveonwater)
        local v287 = v265.NewSection("Heli Mods")
        v287.NewSlider("Engine Speed", 1, 100, configs.vehicle.helienginesp, false, function(p288)
            configs.vehicle.helienginesp = p288 / 1000
        end)
        v287.NewToggle("Infinite Height", function(p289)
            configs.vehicle.heliheight = p289
        end, configs.vehicle.heliheight)
        v287.NewToggle("Anti Heli Break", function(p290)
            configs.vehicle.helibreak = p290
            if configs.vehicle.helibreak then
                vu123.heliBreakCorrection()
            end
        end, configs.vehicle.helibreak)
        v287.NewToggle("Instant Pickup", function(p291)
            configs.vehicle.helipick = p291
        end, configs.vehicle.helipick)
        local v292 = v237.NewPage("Combats")
        local v293 = v292.NewSection("Weapons")
        v293.NewToggle("Always Auto", function(p294)
            configs.combat.alwaysauto = p294
        end, configs.combat.alwaysauto)
        v293.NewToggle("No Recoil", function(p295)
            configs.combat.norecoil = p295
        end, configs.combat.norecoil)
        v293.NewToggle("No Spread", function(p296)
            configs.combat.nospread = p296
        end, configs.combat.nospread)
        v293.NewToggle("No Bullet Gravity", function(p297)
            configs.combat.nobulletg = p297
        end, configs.combat.nobulletg)
        v293.NewToggle("No Equip Time", function(p298)
            configs.combat.noequipt = p298
        end, configs.combat.noequipt)
        v293.NewToggle("Wallbang", function(p299)
            configs.combat.wallbang = p299
        end, configs.combat.wallbang)
        v293.NewToggle("Headshot Only", function(p300)
            configs.combat.alwaysheadshot = p300
        end, configs.combat.alwaysheadshot)
        v293.NewToggle("Increase Takedown Damage", function(p301)
            configs.combat.increasetakedowndamage = p301
        end, configs.combat.increasetakedowndamage)
        v293.NewToggle("Free Pistol Swat", function(p302)
            configs.combat.pistolswat = p302
        end, configs.combat.pistolswat)
        v293.NewToggle("Fast Taser", function(p303)
            configs.combat.tasermodz = p303
        end, configs.combat.tasermodz)
        v293.NewToggle("Forcefield Anti Misses", function(p304)
            configs.combat.forcefieldnomiss = p304
        end, configs.combat.forcefieldnomiss)
        v293.NewToggle("No Sniper Scope Gui", function(p305)
            configs.combat.snipernogui = p305
        end, false)
        v293.NewToggle("No Sniper Scope Blur", function(p306)
            configs.combat.snipernoblur = p306
        end, false)
        v293.NewToggle("No Grenade Smoke", function(p307)
            configs.combat.nogrenadesmoke = p307
            vu123.smokeGrenadeHook(configs.combat.nogrenadesmoke)
        end, configs.combat.nogrenadesmoke)
        v293.NewButton("Open Gunstore Ui", function()
            set_thread_identity(2)
            require(game:GetService("ReplicatedStorage").Game.GunShop.GunShopUI).open()
            set_thread_identity(10)
        end)
        local v308 = v292.NewSection("Melee")
        v308.NewToggle("No Reload Time", function(p309)
            configs.combat.batonsword.noreloadtime = p309
            if configs.combat.batonsword.noreloadtime then
                vu123.setBatonSwordTime(configs.combat.batonsword.noreloadtime)
            end
        end, configs.combat.batonsword.noreloadtime)
        v308.NewToggle("Always Swoosh", function(p310)
            configs.combat.batonsword.spamswoosh = p310
            if configs.combat.batonsword.spamswoosh then
                vu123.spamBatonSwordSwoosh()
            end
        end, configs.combat.batonsword.spamswoosh)
        v308.NewToggle("Always Lunge", function(p311)
            configs.combat.batonsword.spamlunge = p311
            if configs.combat.batonsword.spamlunge then
                vu123.spamBatonSwordLunge()
            end
        end, configs.combat.batonsword.spamlunge)
        local v312 = v292.NewSection("Silent Aim [Unoptimized]")
        v312.NewToggle("Enabled", function(p313)
            configs.combat.silentaim.enabled = p313
        end, false)
        v312.NewToggle("Include Taser", function(p314)
            configs.combat.silentaim.includetaser = p314
        end, false)
        v312.NewToggle("Include Plasma Gun", function(p315)
            configs.combat.silentaim.includetaser = p315
        end, false)
        v312.NewSlider("Radius", 10, 1000, 250, false, function(p316)
            configs.combat.silentaim.radius = p316
            Circle.Radius = p316
        end)
        v312.NewToggle("Wallcheck", function(p317)
            configs.combat.silentaim.wallcheck = p317
        end, false)
        v312.NewToggle("FOV Circle", function(p318)
            configs.combat.silentaim.fovcirc = p318
            Circle.Visible = p318
        end, false)
        v312.NewSlider("Circle Thickness", 0, 10, 0, true, function(p319)
            configs.combat.silentaim.fovthick = p319
            Circle.Thickness = p319
        end)
        v312.NewSlider("Circle Transparency", 1, 0, 0, true, function(p320)
            configs.combat.silentaim.fovtransp = p320
            Circle.Transparency = p320
        end)
        v292.NewSection("Arrest Aura").NewToggle("Enabled", function(p321)
            configs.combat.arrestaura.enabled = p321
            if configs.combat.arrestaura.enabled then
                vu123.launchArrestAura()
            end
        end, configs.combat.arrestaura.enabled)
        v292.NewSection("Others").NewSlider("Hitbox Radius", 3, 50, configs.combat.hitboxradius, true, function(p322)
            configs.combat.hitboxradius = p322
            vu123.changeHitboxRadius(configs.combat.hitboxradius)
        end)
    end
end)