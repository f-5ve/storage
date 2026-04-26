local cache = {models = {}}

local function generateKey(model)
    if model.GetDebugId then
        return model.Name .. "_" .. tostring(model:GetDebugId())
    else
        return model.Name .. "_" .. tostring(math.random(100000, 999999))
    end
end

local function getHumRootModels(parent)
    local models = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:FindFirstChild("HumanoidRootPart") then
            table.insert(models, child)
        elseif #child:GetChildren() > 0 then
            local subModels = getHumRootModels(child)
            for _, m in ipairs(subModels) do
                table.insert(models, m)
            end
        end
    end
    return models
end

local function add_part_data(address, part, name)
    if not part then
        print("[DEBUG] Skipping add_model_data for", name, "because part is nil")
        return
    end

    local key = generateKey(address)
    if cache.models[key] then return end

    print("[DEBUG] Adding model data for", name, "with key:", key)

    local data = {
        Username = name,
        Displayname = name,
        Userid = 0,
        Character = part,
        PrimaryPart = part,
        Head = part,
        Torso = part,
        LeftArm = part,
        LeftLeg = part,
        RightArm = part,
        RightLeg = part,
        BodyHeightScale = 1,
        RigType = 1,
        Whitelisted = false,
        Archenemies = false,
        Aimbot_Part = part,
        Aimbot_TP_Part = part,
        Triggerbot_Part = part,
        Health = 100,
        MaxHealth = 100
    }

    local success, err = pcall(function()
        add_model_data(data, key)
    end)

    if not success then
        warn("[ERROR] Failed add_model_data for", name, ":", err)
    else
        cache.models[key] = true
    end
end

-- One-time addition function
local function processAll()
    -- NPCs
    if workspace:FindFirstChild("Stampede") then
        local npcModels = getHumRootModels(workspace.Stampede.NPCs)
        for _, Model in ipairs(npcModels) do
            local Root = Model:FindFirstChild("HumanoidRootPart")
            add_part_data(Model, Root, Model.Name)
        end
    end

    -- Drops
    if workspace:FindFirstChild("Drops") then
        for _, drop in ipairs(workspace.Drops:GetChildren()) do
            local mainPart = drop:FindFirstChild('Main') or drop:FindFirstChild('main') 
                            or drop:FindFirstChildOfClass('MeshPart') or drop:FindFirstChildOfClass('Part')
            add_part_data(drop, mainPart, drop.Name)
        end
    end
end

-- Run **once** after a short delay (wait for models to exist)
task.delay(0.5, processAll)
