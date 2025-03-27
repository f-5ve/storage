-- Load the UI Library from GitHub
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/f-5ve/storage/main/UI%20but%20i%20cant%20code/main.luau'))()

-- Create the main window
local Window = Library:CreateWindow("Leny")

-- Create categories
local VisualsCategory = Window:CreateCategory("Visuals", "lucide-eye")
local WorldCategory = Window:CreateCategory("World", "lucide-globe")
local CommonCategory = Window:CreateCategory("Common", "lucide-settings")

-- Make the Visuals category visible by default
for _, content in pairs(VisualsCategory.Parent:GetChildren()) do
    content.Visible = false
end
VisualsCategory.Visible = true

-- Add search bar to Visuals category
local SearchBar = Window:CreateSearchBar(VisualsCategory)

-- Add sections to Visuals category
local PlayersSection = Window:CreateSection(VisualsCategory, "PLAYERS")
wait(0.1) -- Small wait to ensure proper positioning
local ModelsSection = Window:CreateSection(VisualsCategory, "MODELS")

-- Add toggles to Players section
wait(0.1) -- Small wait to ensure proper positioning
Window:CreateToggle(VisualsCategory, "Enabled", function(enabled)
    print("Enabled:", enabled)
end, "lucide-eye")

wait(0.1) -- Small wait to ensure proper positioning
Window:CreateToggle(VisualsCategory, "Teammates", function(enabled)
    print("Teammates:", enabled)
end, "lucide-users")

wait(0.1) -- Small wait to ensure proper positioning
Window:CreateToggle(VisualsCategory, "Bullet Tracers", function(enabled)
    print("Bullet Tracers:", enabled)
end, "lucide-line")

-- Add toggles to Models section
wait(0.1) -- Small wait to ensure proper positioning
Window:CreateToggle(VisualsCategory, "Enemies", function(enabled)
    print("Enemies ESP:", enabled)
end, "lucide-user-x")

wait(0.1) -- Small wait to ensure proper positioning
Window:CreateToggle(VisualsCategory, "Teammates", function(enabled)
    print("Teammates Models:", enabled)
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

-- Add dropdowns to Common category
wait(0.1) -- Small wait to ensure proper positioning
Window:CreateDropdown(CommonCategory, "Visual Recoil", {"Default", "None", "Custom"}, "Default")
wait(0.1) -- Small wait to ensure proper positioning
Window:CreateDropdown(CommonCategory, "Crosshair", {"Default", "Custom", "None"}, "Default")
wait(0.1) -- Small wait to ensure proper positioning
Window:CreateDropdown(CommonCategory, "Removals", {"Smoke", "Flash", "Blood", "All"}, "None")
