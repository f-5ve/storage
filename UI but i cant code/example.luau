-- Load the UI Library from GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/f-5ve/storage/refs/heads/main/UI%20but%20i%20cant%20code/main.luau"))()

-- Create the main window
local Window = Library:CreateWindow("Leny")

-- Create categories
local VisualsCategory = Window:CreateCategory("Visuals", "lucide-eye")
local WorldCategory = Window:CreateCategory("World", "lucide-globe")
local CommonCategory = Window:CreateCategory("Common", "lucide-settings")

-- Add search bar to Visuals category
Window:CreateSearchBar(VisualsCategory)

-- Players Section in Visuals
Window:CreateSection(VisualsCategory, "PLAYERS")

Window:CreateToggle(VisualsCategory, "Enabled", function(enabled)
    if enabled then
        print("Visuals Enabled")
    else
        print("Visuals Disabled")
    end
end, "lucide-eye")

Window:CreateToggle(VisualsCategory, "Teammates", function(enabled)
    if enabled then
        print("Teammates ESP Enabled")
    else
        print("Teammates ESP Disabled")
    end
end, "lucide-users")

Window:CreateToggle(VisualsCategory, "Bullet Tracers", function(enabled)
    if enabled then
        print("Bullet Tracers Enabled")
    else
        print("Bullet Tracers Disabled")
    end
end, "lucide-line")

-- Models Section in Visuals
Window:CreateSection(VisualsCategory, "MODELS")

Window:CreateToggle(VisualsCategory, "Enemies", function(enabled)
    if enabled then
        print("Enemies ESP Enabled")
    else
        print("Enemies ESP Disabled")
    end
end, "lucide-user-x")

Window:CreateToggle(VisualsCategory, "Teammates", function(enabled)
    if enabled then
        print("Teammates Models Enabled")
    else
        print("Teammates Models Disabled")
    end
end, "lucide-users")

Window:CreateToggle(VisualsCategory, "Local Player", function(enabled)
    if enabled then
        print("Local Player Model Enabled")
    else
        print("Local Player Model Disabled")
    end
end, "lucide-user")

Window:CreateToggle(VisualsCategory, "Ragdolls", function(enabled)
    if enabled then
        print("Ragdolls Enabled")
    else
        print("Ragdolls Disabled")
    end
end, "lucide-skull")

-- World Category
Window:CreateToggle(WorldCategory, "Bomb", function(enabled)
    if enabled then
        print("Bomb ESP Enabled")
    else
        print("Bomb ESP Disabled")
    end
end, "lucide-bomb")

Window:CreateToggle(WorldCategory, "Weapons", function(enabled)
    if enabled then
        print("Weapons ESP Enabled")
    else
        print("Weapons ESP Disabled")
    end
end, "lucide-sword")

Window:CreateToggle(WorldCategory, "Grenade Trajectory", function(enabled)
    if enabled then
        print("Grenade Trajectory Enabled")
    else
        print("Grenade Trajectory Disabled")
    end
end, "lucide-route")

Window:CreateToggle(WorldCategory, "Grenade Proximity Warning", function(enabled)
    if enabled then
        print("Grenade Warning Enabled")
    else
        print("Grenade Warning Disabled")
    end
end, "lucide-alert-triangle")

-- Common Category
Window:CreateToggle(CommonCategory, "Ambience", function(enabled)
    if enabled then
        print("Ambience Enabled")
    else
        print("Ambience Disabled")
    end
end, "lucide-sun")

Window:CreateToggle(CommonCategory, "Force Thirdperson", function(enabled)
    if enabled then
        print("Thirdperson Enabled")
    else
        print("Thirdperson Disabled")
    end
end, "lucide-camera")

-- Add dropdowns to Common Category
Window:CreateDropdown(CommonCategory, "Visual Recoil", {"Default", "None", "Custom"}, "Default")
Window:CreateDropdown(CommonCategory, "Crosshair", {"Default", "Custom", "None"}, "Select")
Window:CreateDropdown(CommonCategory, "Removals", {"Smoke", "Flash", "Blood", "All"}, "Select")
