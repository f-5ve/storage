
if global then
    print("crewbattler is already running")
    while true do task.wait() end
end

local execution_time = tick()

while true do
    if game:IsLoaded() then
        if table.find({606849621, 6898041828, 17190407811, 108098425719662}, game.PlaceId) then break end
    end
    task.wait()
end

if not LPH_OBFUSCATED then
    IS_NOT_OBFUSCATED = true
    LPH_ENCNUM = function(a,...)assert(type(a)=="number" and #{...}==0,"LPH_ENCNUM only accepts a single constant double or integer as an argument.")return a end
    LPH_NUMENC = function(a,...)assert(type(a)=="number" and #{...}==0,"LPH_ENCNUM only accepts a single constant double or integer as an argument.")return a end
    LPH_ENCSTR = function(a,...)assert(type(a)=="string" and #{...}==0,"LPH_ENCSTR only accepts a single constant string as an argument.")return a end
    LPH_STRENC = function(a,...)assert(type(a)=="string" and #{...}==0,"LPH_ENCSTR only accepts a single constant string as an argument.")return a end
    LPH_ENCFUNC = function(a,b,c,...)assert(type(a)=="function" and type(b)=="string" and #{...}==0,"LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")return a end
    LPH_FUNCENC = function(a,b,c,...)assert(type(a)=="function" and type(b)=="string" and #{...}==0,"LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")return a end
    LPH_JIT = function(f,...)assert(type(f)=="function" and #{...}==0,"LPH_JIT only accepts a single constant function as an argument.")return f end
    LPH_JIT_MAX = function(f,...)assert(type(f)=="function" and #{...}==0,"LPH_JIT only accepts a single constant function as an argument.")return f end
    LPH_NO_VIRTUALIZE = function(f,...)assert(type(f)=="function" and #{...}==0,"LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")return f end
    LPH_NO_UPVALUES = function(f,...)assert(type(setfenv)=="function","LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")assert(type(f)=="function" and #{...}==0,"LPH_NO_UPVALUES only accepts a single constant function as an argument.")return f end
    LPH_CRASH = function(...)assert(#{...}==0,"LPH_CRASH does not accept any arguments.")end
end

local CloneRef = cloneref or function(...) return ... end
local players = CloneRef(game:GetService("Players"))
local player = players and (players.LocalPlayer or players.PlayerAdded:Wait())
local runservice = CloneRef(game:GetService("RunService"))
local repl = CloneRef(game:GetService("ReplicatedStorage"))
local textService = CloneRef(game:GetService("TextChatService"))
local httpservice = CloneRef(game:GetService("HttpService"))
local teleportservice = CloneRef(game:GetService("TeleportService"))
local uis = CloneRef(game:GetService("UserInputService"))
local lighting = CloneRef(game:GetService("Lighting"))
local teams = CloneRef(game:GetService("Teams"))
local tweenservice = CloneRef(game:GetService("TweenService"))
local collectionservice = CloneRef(game:GetService("CollectionService"))
local coregui = CloneRef(game:GetService("CoreGui"))
local ContentProvider = CloneRef(game:GetService("ContentProvider"))

-- > ( anticheat bypass )
-- This is intentionally the first thing the script does. Jailbreak's "Hawkeye"
-- anticheat invokes ReplicatedStorage.HawkeyeRemoteFunction.OnClientInvoke on
-- the client and expects the player's locale table back (verified in the game
-- source: StarterPlayerScripts/Hawkeye.client.lua). We replace the callback with
-- one that returns exactly that benign structure, so any detection logic in the
-- live callback never runs while the server's invoke still succeeds (returning
-- blank/nil, as the old bypass did, is itself a failed-response signal).
-- If the remote no longer exists / can't be overridden, the method is outdated
-- for this game version, so we kick rather than let the user play exposed.
local function hawkeyeBypass()
    if getgenv and getgenv().__crewbattler_hawkeye then return end
    local function outdated(reason)
        warn("[crewbattler] Hawkeye bypass outdated: " .. tostring(reason))
        pcall(function()
            player:Kick("crewbattler: the anticheat bypass is outdated (" .. tostring(reason) .. ").\nWait for an update before playing.")
        end)
    end
    local localization = CloneRef(game:GetService("LocalizationService"))
    if not localization then return outdated("no LocalizationService") end
    -- The game reparents HawkeyeRemoteFunction to nil after setup (confirmed by recon:
    -- it is not in the tree, but its OnClientInvoke closure is alive and the instance
    -- shows up under getnilinstances). So look in the live tree AND in nil-parented
    -- instances, and poll briefly because the create -> reparent step races our load.
    local function findHawkeye()
        local found = repl:FindFirstChild("HawkeyeRemoteFunction")
        if found and found:IsA("RemoteFunction") then return found end
        if type(getnilinstances) == "function" then
            local ok, nils = pcall(getnilinstances)
            if ok and type(nils) == "table" then
                for _, inst in ipairs(nils) do
                    if inst.ClassName == "RemoteFunction" and inst.Name == "HawkeyeRemoteFunction" then return inst end
                end
            end
        end
        return nil
    end
    local hawkeye
    local deadline = tick() + 10
    repeat
        hawkeye = findHawkeye()
        if hawkeye then break end
        task.wait(0.1)
    until tick() > deadline
    if not hawkeye then return outdated("HawkeyeRemoteFunction not found (tree or nil)") end
    -- mirror the legit client response exactly
    local function legitResponse()
        return {
            system_locale = localization.SystemLocaleId,
            account_locale = localization.RobloxLocaleId,
        }
    end
    -- prefer a clean reassignment; fall back to hooking the live callback
    local applied = pcall(function() hawkeye.OnClientInvoke = legitResponse end)
    if not applied and type(hookfunction) == "function" and type(getcallbackvalue) == "function" then
        local cb = getcallbackvalue(hawkeye, "OnClientInvoke")
        if type(cb) == "function" then
            applied = pcall(hookfunction, cb, LPH_NO_VIRTUALIZE(function()
                local loc = game:GetService("LocalizationService")
                return {
                    system_locale = loc.SystemLocaleId,
                    account_locale = loc.RobloxLocaleId,
                }
            end))
        end
    end
    if not applied then return outdated("cannot override OnClientInvoke") end
    if getgenv then getgenv().__crewbattler_hawkeye = true end
end
hawkeyeBypass()

-- > ( outgoing-request bypass : cheatcheck )
-- The CH4 client funnels every gameplay packet through one helper (`u12`) that
-- grabs the raw `RemoteEvent.FireServer` C function ONCE (`local f =
-- Instance.new("RemoteEvent").FireServer`) and calls it *directly* as
-- `f(genericRemote, packetName, ...)`. That direct call is specifically chosen
-- to dodge `__namecall` hooks (the NAMECALL opcode only fires on `obj:Method()`
-- syntax, never on a stored function value). So hooking `game.__namecall` would
-- NOT see these packets at all. We instead hook the FireServer C closure itself,
-- which catches both the game's direct calls and any `remote:FireServer(...)`.
--
-- Hawkeye's "CheatCheck0" and its sibling detectors (NoClip, BackpackTool,
-- Getupvalues/VisDetect, FailedPcall, ...) all report a positive detection by
-- calling `u12(REPORT, reason, false)`, where REPORT decodes to the literal
-- "mkjwjcjo" in the live client (verified across all four detection sites in
-- StarterPlayerScripts/LocalScript.client.lua). A clean client sends NOTHING on
-- that name -- the report only fires when a detection trips -- so dropping it has
-- no missing-heartbeat signal (unlike the Hawkeye invoke). We forward everything
-- else untouched. Exact-string match on a unique obfuscated name means a wrong
-- guess fails soft (does nothing) rather than breaking legit gameplay.
local function installRequestBypass()
    if getgenv and getgenv().__cb_requestbypass then return end
    if type(hookfunction) ~= "function" or type(newcclosure) ~= "function" then return end
    local okFn, fireServer = pcall(function() return Instance.new("RemoteEvent").FireServer end)
    if not okFn or type(fireServer) ~= "function" then return end
    -- decoded anticheat report packet (see comment above)
    local REPORT_PACKET = "mkjwjcjo"
    -- The client remaps every packet name through a server-sent table (`u7`)
    -- before it hits the wire -- live Cobalt capture shows gameplay packets going
    -- out as "!<guid>" rather than their source names, so the literal above is
    -- almost never what travels. We resolve the remapped wire name once by finding
    -- the remap table in the GC (it's the one keyed by the source name) and caching
    -- u7[REPORT_PACKET]. The remap arrives during the load handshake, so poll
    -- briefly. getgc is not one of the detected primitives (the AC only flags the
    -- existence of debug.getupvalues), so this scan is safe. Falls back to the
    -- literal if no remap is active.
    local REPORT_WIRE = nil
    if type(getgc) == "function" then
        task.spawn(function()
            for _ = 1, 60 do
                local ok, gc = pcall(getgc, true)
                if ok and type(gc) == "table" then
                    for _, v in ipairs(gc) do
                        if type(v) == "table" then
                            local mapped = rawget(v, REPORT_PACKET)
                            if type(mapped) == "string" and mapped ~= REPORT_PACKET then
                                REPORT_WIRE = mapped
                                return
                            end
                        end
                    end
                end
                task.wait(0.25)
            end
        end)
    end
    -- resolve a caller-discriminator once (Potassium exposes checkcaller as an
    -- undocumented global; getcallingscript is the documented fallback -> nil
    -- means the call came from our own executor thread, which we must not touch).
    local checkSelf
    if type(checkcaller) == "function" then
        checkSelf = checkcaller
    elseif type(getcallingscript) == "function" then
        local gcs = getcallingscript
        checkSelf = function() return gcs() == nil end
    else
        checkSelf = function() return false end
    end
    local oldFireServer
    oldFireServer = hookfunction(fireServer, newcclosure(LPH_NO_VIRTUALIZE(function(self, ...)
        -- hot path: skip our own FireServer calls, then a single string compare
        if checkSelf() then return oldFireServer(self, ...) end
        local a1 = ...
        if a1 == REPORT_PACKET or (REPORT_WIRE and a1 == REPORT_WIRE) then
            -- toggle: drop unless the user explicitly turned it off
            if not (global and global.ui_status and global.ui_status.anti_cheatcheck == false) then
                return -- drop: the detection report never reaches the server
            end
        end
        -- Force hit + aim spoof, gated behind the toggle so there is ZERO extra cost when
        -- off. This lives in the FireServer hook (NOT a global __namecall hook): a __namecall
        -- hook runs on every method call in the game and reading self.Name there thousands
        -- of times a second tripped the engine watchdog -> random crashes. hookfunction only
        -- fires on FireServer, and the heavy target resolution it calls does not re-enter
        -- here (only FireServer does), so there is no amplification.
        if global and global.ui_status and global.ui_status.force_hit and typeof(self) == "Instance" then
            local name = self.Name
            if name == "Shoot" then
                local ret = oldFireServer(self, ...)            -- forward the real shoot
                local fh = global.registry and global.registry.forceHitOnShoot
                if fh then pcall(fh, self) end                  -- then forge the hit (additive)
                return ret
            elseif name == "ItemSystemGunMouseMovement" then
                -- rewrite the replicated aim to the target's head so the server sees us
                -- aiming at whoever we forge a hit on.
                local resolve = global.registry and global.registry.forceHitAimPos
                if resolve then
                    local ok, pos = pcall(resolve)
                    if ok and typeof(pos) == "Vector3" then return oldFireServer(self, pos) end
                end
            elseif name == "Damage" and global.ui_status.force_hit_single then
                -- 1:1 mode: drop the game's real gun-hit if we just forged one this shot, so
                -- the server sees exactly one Damage per Shoot. Our forged packet goes out via
                -- the raw FireServer copy and never reaches this hook, so it is unaffected. If
                -- no forge happened (no target), __cb_lastForge is stale and the real hit
                -- passes through -- so a no-target shot still does normal damage.
                local par = self.Parent
                if par and par:FindFirstChild("Shoot") then
                    local lf = global.__cb_lastForge
                    if lf and tick() - lf < 0.5 then return end
                end
            end
        end
        return oldFireServer(self, ...)
    end)))
    if not oldFireServer then return end
    -- expose the unhooked FireServer copy so force hit can send its forged packet
    -- WITHOUT re-entering this hook (avoids any checkcaller ambiguity / self-drop).
    if getgenv then
        getgenv().__cb_rawFireServer = oldFireServer
        getgenv().__cb_requestbypass = true
    end
end
installRequestBypass()

local function http_request(url)
    local request = request or syn and syn.request
    return request({
        Url = url;
        Method = "GET";
    })
end
local function ON_LOADUP()
    local function ON_VERSION_REQUEST()
        getrenv()._version = "2.0.1"
        getrenv().discord_id = LRM_LinkedDiscordID or 0
    end
    ON_VERSION_REQUEST()
    local function ON_SERVER_CONNECT()
        if global or key or IS_WORKING == true or CONNECTIONS and CONNECTIONS > 1 then
            if player and player.Kick then return player:Kick("crewbattler cannot run multiple times. restart game!") end
            return
        end
        local env = getrenv and getrenv() or _G
        env.global = env.global or {}
        global = env.global
        global.registry = global.registry or {doors = {}, sounds = {}}
        global.ui = global.ui or {}
        global.ui.statusControls = {}
        global.ui.colorControls = {}
        global.ui.flagControls = {}
        global.ui.noSaveFlags = {}
        global.ui.pendingControlConfig = nil
        print("hooked badd.cc")

        global.ui.loadLibrary = function()
            if global.ui.libraryLoaded then return true end
            global.ui.libraryLoaded = true

            local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/f-5ve/storage/bd48cb29886f5aa0c31d0b38ebf93994e28c46ae/secrethaxx_autoload.lua"))()
            global.ui.Library = Library
            if Library and not Library.RegisterFlag then
                Library.PendingConfig = Library.PendingConfig or {}
                Library.IgnoredFlags = Library.IgnoredFlags or {}
                Library.IsLoadingConfig = false

                local function isKeybindConfig(index, value)
                    index = tostring(index)

                    return type(value) == "table" and value.Key
                        or index:sub(-12) == "ModeDropdown"
                        or index:sub(-18) == "ShowInKeybindsList"
                        or index:sub(-4) == "Sync"
                end

                local function priority(index, value)
                    if type(value) == "table" and value.Color then
                        return 1
                    elseif isKeybindConfig(index, value) then
                        return 2
                    elseif type(value) == "string" then
                        return 3
                    elseif type(value) == "number" then
                        return 4
                    elseif type(value) == "boolean" then return 5 end

                    return 6
                end

                local function applyConfigValue(index, value)
                    if Library.IgnoredFlags[index] then return end

                    local setFunction = Library.SetFlags and Library.SetFlags[index]

                    if not setFunction then
                        Library.PendingConfig[index] = value
                        return
                    end

                    if type(value) == "table" and value.Key then
                        setFunction(value)
                    elseif type(value) == "table" and value.Color then
                        setFunction(value.Color, value.Alpha)
                    else
                        setFunction(value)
                    end
                end

                if type(Library.SetFlags) == "table" and getmetatable(Library.SetFlags) == nil then
                    setmetatable(Library.SetFlags, {
                        __newindex = function(target, flag, setter)
                            rawset(target, flag, setter)

                            if Library.PendingConfig[flag] ~= nil and not Library.IgnoredFlags[flag] then
                                local pending = Library.PendingConfig[flag]
                                Library.PendingConfig[flag] = nil

                                local wasLoading = Library.IsLoadingConfig
                                Library.IsLoadingConfig = true
                                local ok, err = pcall(function()
                                    applyConfigValue(flag, pending)
                                end)
                                Library.IsLoadingConfig = wasLoading

                                if not ok then warn(("[crewbattler merge] failed applying pending config %s: %s"):format(tostring(flag), tostring(err))) end
                            end
                        end,
                    })
                end

                local rawGetConfig = Library.GetConfig
                Library.GetConfig = function(self)
                    if type(rawGetConfig) ~= "function" then
                        return "{}"
                    end

                    local ok, encoded = pcall(rawGetConfig, self)
                    if not ok or type(encoded) ~= "string" then return encoded end

                    local decodeOk, decoded = pcall(function()
                        return httpservice:JSONDecode(encoded)
                    end)

                    if not decodeOk or type(decoded) ~= "table" then return encoded end

                    for flag in next, Library.IgnoredFlags do decoded[flag] = nil end

                    return httpservice:JSONEncode(decoded)
                end

                Library.LoadConfig = function(self, config)
                    local decoded = httpservice:JSONDecode(config)
                    local keys = {}

                    for index in next, decoded do
                        if not Library.IgnoredFlags[index] then table.insert(keys, index) end
                    end

                    table.sort(keys, function(a, b)
                        local aPriority = priority(a, decoded[a])
                        local bPriority = priority(b, decoded[b])

                        if aPriority == bPriority then return tostring(a) < tostring(b) end

                        return aPriority < bPriority
                    end)

                    local wasLoading = Library.IsLoadingConfig
                    Library.IsLoadingConfig = true
                    local ok, err = pcall(function()
                        for _, flag in keys do applyConfigValue(flag, decoded[flag]) end
                    end)
                    Library.IsLoadingConfig = wasLoading

                    return ok, err
                end

                local rawTextbox = Library.Textbox
                Library.Textbox = function(self, params)
                    local textbox = rawTextbox(self, params)

                    if params and params.Save == false and params.Flag then
                        local flag = params.Flag
                        Library.IgnoredFlags[flag] = true
                        Library.PendingConfig[flag] = nil

                        if Library.SetFlags then Library.SetFlags[flag] = nil end

                        if Library.Flags then Library.Flags[flag] = nil end

                        if textbox and type(textbox.Set) == "function" then
                            local rawSet = textbox.Set
                            textbox.Set = function(setSelf, ...)
                                local result = rawSet(setSelf, ...)

                                if Library.Flags then Library.Flags[flag] = nil end

                                return result
                            end
                        end
                    end

                    return textbox
                end
            end
        do
            local setThreadIdentity = syn and syn.set_thread_identity or set_thread_identity or setthreadidentity
            local getThreadEnv = gettenv
            local rootEnv
            pcall(function()
                rootEnv = getThreadEnv and getThreadEnv(coroutine.running()) or nil
            end)
            local rootScript = type(rootEnv) == "table" and rawget(rootEnv, "script") or nil

            local function isCapabilityError(err)
                local message = tostring(err)
                return message:find("cannot access 'Instance'", 1, true) or message:find("lacking capability", 1, true)
            end

            local function patchThreadContext()
                if getThreadEnv then
                    pcall(function()
                        local env = getThreadEnv()
                        if type(env) == "table" then
                            env.global = global
                            if rootScript ~= nil then env.script = rootScript end
                        end
                    end)
                end
                if setThreadIdentity then pcall(setThreadIdentity, 7) end
            end

            local function safeLibraryCall(callback, ...)
                patchThreadContext()
                local ok, result = pcall(callback, ...)
                if ok then return result end
                if not isCapabilityError(result) then warn(tostring(result)) end
                return nil
            end

            if Library and type(Library.Connect) == "function" then
                local rawConnect = Library.Connect
                Library.Connect = function(self, signal, callback)
                    if type(callback) == "function" then
                        local rawCallback = callback
                        callback = function(...)
                            return safeLibraryCall(rawCallback, ...)
                        end
                    end
                    return rawConnect(self, signal, callback)
                end
            end

            if Library and type(Library.Tween) == "function" then
                local rawTween = Library.Tween
                Library.Tween = function(self, properties, info, isRawItem)
                    patchThreadContext()
                    local ok, result = pcall(rawTween, self, properties, info, isRawItem)
                    if ok then return result end
                    if not isCapabilityError(result) then warn(tostring(result)) end
                    local object = self and (rawget(self, "Instance") or isRawItem) or isRawItem
                    if object and type(properties) == "table" then
                        for property, value in next, properties do
                            pcall(function()
                                object[property] = value
                            end)
                        end
                    end
                    return {
                        Completed = {
                            Connect = function(_, callback)
                                if callback then task.defer(callback) end
                                return {Disconnect = function() end}
                            end,
                        },
                        Play = function() end,
                    }
                end
            end

            global.ui.patchThreadContext = patchThreadContext
            global.ui.isCapabilityError = isCapabilityError
        end
        local WindowConfig = {
            Name = 'crewbattler<font color="rgb(84, 0, 255)">.club</font> | <font color="rgb(84, 0, 255)">nightly</font>',
            Rank = "developer"
        }
        local Window = Library:Window(WindowConfig)

        local KeybindList = Window:KeybindList({
            Name = 'hot<font color="rgb(84, 0, 255)">keys</font>'
        })
        do
            local function emptyKeybindListObject()
                return {
                    Set = function() end,
                    SetMode = function() end,
                    SetStatus = function() end,
                    SetVis = function() end,
                }
            end
            local function wrapKeybindListObject(object)
                if type(object) ~= "table" then return emptyKeybindListObject() end
                for _, methodName in ipairs({"Set", "SetMode", "SetStatus", "SetVis"}) do
                    local rawMethod = object[methodName]
                    if type(rawMethod) == "function" then
                        object[methodName] = function(self, ...)
                            local patchThreadContext = global.ui and global.ui.patchThreadContext
                            if type(patchThreadContext) == "function" then
                                patchThreadContext()
                            end
                            local ok, result = pcall(rawMethod, self, ...)
                            if not ok then
                                local isCapabilityError = global.ui and global.ui.isCapabilityError
                                if not (type(isCapabilityError) == "function" and isCapabilityError(result)) then
                                    warn(tostring(result))
                                end
                            end
                            return result
                        end
                    end
                end
                return object
            end
            if KeybindList and type(KeybindList.Add) == "function" then
                local rawAdd = KeybindList.Add
                KeybindList.Add = function(self, ...)
                    local patchThreadContext = global.ui and global.ui.patchThreadContext
                    if type(patchThreadContext) == "function" then
                        patchThreadContext()
                    end
                    local ok, object = pcall(rawAdd, self, ...)
                    if ok then return wrapKeybindListObject(object) end
                    local isCapabilityError = global.ui and global.ui.isCapabilityError
                    if not (type(isCapabilityError) == "function" and isCapabilityError(object)) then
                        warn(tostring(object))
                    end
                    return emptyKeybindListObject()
                end
            end
            if KeybindList and type(KeybindList.AddAlways) == "function" then
                global.ui.espKeybindListObject = KeybindList:AddAlways("ESP", "always on")
            end
        end
        local function sanitizeFlagPart(value)
            value = tostring(value or ""):lower()
            value = value:gsub("<.->", "")
            value = value:gsub("[^%w]+", "_")
            value = value:gsub("^_+", "")
            value = value:gsub("_+$", "")
            return value
        end

        local function makeLegacyFlag(prefix, name)
            local value = sanitizeFlagPart(("%s_%s"):format(tostring(prefix or ""), tostring(name or "")))
            return value ~= "" and value or "legacy_control"
        end

        local function makeFlag(prefix, name)
            local prefixValue = sanitizeFlagPart(prefix)
            local nameValue = sanitizeFlagPart(name)

            if prefixValue == "" then return nameValue ~= "" and nameValue or "legacy_control" end
            if nameValue == "" or prefixValue == nameValue then return prefixValue end

            return ("%s_%s"):format(prefixValue, nameValue)
        end

        local flagCounts = {}
        local flagAliases = {
            walkspeed_walk_speed = "walk_speed",
            walk_speed_walk_speed_broken = "walk_speed",
            jumppower_jump_power = "jump_power",
        }

        local function makeUniqueFlag(prefix, name)
            local base = makeFlag(prefix, name)
            local legacyBase = makeLegacyFlag(prefix, name)
            local count = (flagCounts[base] or 0) + 1
            flagCounts[base] = count
            local flag = count == 1 and base or ("%s_%d"):format(base, count)

            if legacyBase ~= base then flagAliases[legacyBase] = flag end

            return flag
        end

        local function stripConfigSuffix(flag)
            for _, suffix in ipairs({"ModeDropdown", "ShowInKeybindsList", "Sync"}) do
                if flag:sub(-#suffix) == suffix then return flag:sub(1, #flag - #suffix), suffix end
            end
            return flag, ""
        end

        local function collapseRepeatedFlag(flag)
            local base, suffix = stripConfigSuffix(tostring(flag))
            local keybindSuffix = ""

            if base:sub(-8) == "_keybind" then
                base = base:sub(1, #base - 8)
                keybindSuffix = "_keybind"
            end

            local parts = {}
            for part in base:gmatch("[^_]+") do table.insert(parts, part) end

            if #parts > 0 and #parts % 2 == 0 then
                local half = #parts / 2
                local repeated = true

                for i = 1, half do
                    if parts[i] ~= parts[i + half] then
                        repeated = false
                        break
                    end
                end

                if repeated then
                    local collapsed = {}
                    for i = 1, half do collapsed[i] = parts[i] end
                    return table.concat(collapsed, "_") .. keybindSuffix .. suffix
                end
            end

            return tostring(flag)
        end

        local function normalizeFlagName(flag)
            flag = tostring(flag)

            if flagAliases[flag] then return flagAliases[flag] end

            for legacy, current in next, flagAliases do
                if flag:sub(1, #legacy) == legacy then
                    local suffix = flag:sub(#legacy + 1)
                    if suffix ~= "" then return current .. suffix end
                end
            end

            local collapsed = collapseRepeatedFlag(flag)
            return flagAliases[collapsed] or collapsed
        end

        local function normalizeConfigTable(decoded)
            if type(decoded) ~= "table" then return decoded end

            local normalized = {}
            for flag, value in next, decoded do
                local normalizedFlag = normalizeFlagName(flag)
                if normalizedFlag == flag or decoded[normalizedFlag] == nil then normalized[normalizedFlag] = value end
            end

            return normalized
        end

        local function isConfigFlagIgnored(flag)
            flag = normalizeFlagName(flag)
            local ignored = Library and Library.IgnoredFlags
            local noSaveFlags = global.ui and global.ui.noSaveFlags
            return (type(ignored) == "table" and ignored[flag]) or (type(noSaveFlags) == "table" and noSaveFlags[flag])
        end

        local function stripIgnoredConfigFlags(decoded)
            decoded = normalizeConfigTable(decoded)
            if type(decoded) ~= "table" then return decoded end

            local stripped = {}
            for flag, value in next, decoded do
                if not isConfigFlagIgnored(flag) then stripped[flag] = value end
            end

            return stripped
        end

        local function callMethod(object, methodName, ...)
            if type(object) ~= "table" and type(object) ~= "userdata" then return nil end
            local method = object[methodName]
            if type(method) ~= "function" then return nil end
            local ok, result = pcall(method, object, ...)
            if ok then return result end
            return nil
        end

        local function runCallback(callback, value)
            if type(callback) ~= "function" then return end
            local ok, err = pcall(callback, value)
            if not ok then warn(("[crewbattler merge] UI callback failed: %s"):format(tostring(err))) end
        end

        local function colorToConfig(value)
            if typeof and typeof(value) == "Color3" then
                return {
                    R = math.floor(value.R * 255 + 0.5),
                    G = math.floor(value.G * 255 + 0.5),
                    B = math.floor(value.B * 255 + 0.5),
                }
            end

            return value
        end

        local function colorFromConfig(value, fallback)
            if typeof and typeof(value) == "Color3" then return value end

            -- hex string saved by the library colorpicker, e.g. "#7778ff"
            if type(value) == "string" then
                local hex = value:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1, 2), 16)
                    local g = tonumber(hex:sub(3, 4), 16)
                    local b = tonumber(hex:sub(5, 6), 16)
                    if r and g and b then return Color3.fromRGB(r, g, b) end
                end
            end

            if type(value) == "table" then
                -- library colorpicker config format: { Color = "#hex"/Color3, Alpha = n }
                local color = value.Color or value.color
                if color ~= nil then return colorFromConfig(color, fallback) end

                local r = value.R or value.r or value[1]
                local g = value.G or value.g or value[2]
                local b = value.B or value.b or value[3]
                if r and g and b then
                    if r <= 1 and g <= 1 and b <= 1 then return Color3.new(r, g, b) end

                    return Color3.fromRGB(r, g, b)
                end
            end

            return fallback or Color3.fromRGB(255, 255, 255)
        end

        local function alphaFromConfig(value)
            if type(value) == "table" then
                if type(value.Alpha) == "number" then return value.Alpha end
                if type(value.alpha) == "number" then return value.alpha end
                if type(value.Transparency) == "number" then return 1 - value.Transparency end
            end
            return nil
        end

        local registerFlagControl

        local function makeControlAdapter(rawControl, defaultValue, callback, callbackValue, rawValue)
            local state = defaultValue
            local adapter = {
                Raw = rawControl,
                Children = {},
                Visible = true,
                list = nil,
            }

            adapter.Get = function()
                return state
            end

            adapter.SetState = function(value)
                state = value
            end

            adapter.Set = function(value)
                state = value
                local controlValue = rawValue and rawValue(value) or value
                local hasRawSet = rawControl and type(rawControl.Set) == "function"

                if hasRawSet then
                    callMethod(rawControl, "Set", controlValue)
                elseif callbackValue then
                    runCallback(callback, callbackValue(value))
                else
                    runCallback(callback, value)
                end
            end

            adapter.reload = function(list)
                adapter.list = list or {}
                callMethod(rawControl, "Refresh", adapter.list)
            end

            adapter.setChild = function(child)
                table.insert(adapter.Children, child)
                return child
            end

            adapter.Keybind = function(_, payload)
                payload = payload or {}
                payload.Flag = payload.Flag or makeUniqueFlag("keybind", payload.Name or "Keybind")
                payload.Mode = payload.Mode or "Toggle"
                local callback = payload.Callback
                local keyAdapter
                payload.Callback = function(value)
                    if Library and Library.IsLoadingConfig then return end
                    value = value == true
                    if keyAdapter then keyAdapter.SetState(value) end
                    runCallback(callback, value)
                end
                local keyRaw = callMethod(rawControl, "Keybind", payload)
                keyAdapter = makeControlAdapter(keyRaw, false, callback)
                keyAdapter.Name = payload.Name
                return registerFlagControl(payload.Flag, keyAdapter, payload.Save)
            end

            adapter.SetColor = function(color)
                pcall(function()
                    local textItem = rawControl and rawControl.Items and rawControl.Items.Text
                    local textInstance = textItem and textItem.Instance
                    if textInstance then textInstance.TextColor3 = color end
                end)
            end

            adapter.Colorpicker = function(_, payload)
                payload = payload or {}
                payload.Flag = payload.Flag or makeUniqueFlag("color", payload.Name or "Color")
                local default = colorFromConfig(payload.Default, Color3.fromRGB(255, 255, 255))
                local state = default
                local callback = payload.Callback
                payload.Default = default
                payload.Callback = function(value)
                    state = colorFromConfig(value, default)
                    runCallback(callback, state)
                end

                local colorRaw = callMethod(rawControl, "Colorpicker", payload)
                local colorAdapter = makeControlAdapter(colorRaw, colorToConfig(default), callback, function(value)
                    return colorFromConfig(value, default)
                end, function(value)
                    return colorFromConfig(value, default)
                end)

                colorAdapter.Get = function()
                    return colorToConfig(state)
                end

                colorAdapter.Set = function(value)
                    state = colorFromConfig(value, default)
                    local alpha = alphaFromConfig(value)
                    if alpha ~= nil then
                        callMethod(colorRaw, "Set", state, alpha)
                    else
                        callMethod(colorRaw, "Set", state)
                    end
                    runCallback(callback, state)
                end

                colorAdapter.Name = payload.Name
                return registerFlagControl(payload.Flag, colorAdapter, payload.Save)
            end

            return setmetatable(adapter, {
                __index = function(_, key)
                    if rawControl then return rawControl[key] end
                    return nil
                end,
                __newindex = function(t, key, value)
                    rawset(t, key, value)
                    if key == "Visible" then callMethod(rawControl, "SetVisibility", value) end
                end,
            })
        end
        global.ui.makeControlAdapter = makeControlAdapter

        local function makeProxyTable(onSet)
            local values = {}
            return setmetatable({}, {
                __index = function(_, key)
                    return values[key]
                end,
                __newindex = function(_, key, value)
                    values[key] = value
                    onSet(key, value)
                end,
                __pairs = function()
                    return pairs(values)
                end,
            })
        end

        local uiStore = {}
        local ui = global.ui
        setmetatable(ui, {
            __index = function(_, key)
                return uiStore[key]
            end,
            __newindex = function(_, key, value)
                if key == "statusRobberies" then
                    value = makeProxyTable(function(statusKey, statusValue)
                        local controls = rawget(ui, "statusControls") or uiStore.statusControls
                        local control = controls and controls[statusKey]
                        if control and control.Set then control.Set(statusValue) end
                    end)
                elseif key == "colorForcing" then
                    value = makeProxyTable(function(colorKey, colorValue)
                        local controls = rawget(ui, "colorControls") or uiStore.colorControls
                        local control = controls and controls[colorKey]
                        if control and control.SetColor then control.SetColor(colorValue) end
                    end)
                end
                uiStore[key] = value
            end,
            __pairs = function()
                return pairs(uiStore)
            end,
        })

        global.ui.statusControls = global.ui.statusControls or {}
        global.ui.colorControls = global.ui.colorControls or {}
        global.ui.colorToConfig = colorToConfig
        global.ui.colorFromConfig = colorFromConfig

        local function applyControlConfigValue(control, value)
            if not control or type(control.Set) ~= "function" then return end

            local ok, err = pcall(function()
                control.Set(value)
            end)

            if not ok then warn(("[crewbattler merge] failed syncing config control %s: %s"):format(tostring(control.Flag or control.Name), tostring(err))) end
        end

        local function syncConfigToControls(decoded)
            decoded = stripIgnoredConfigFlags(decoded)
            if type(decoded) ~= "table" then return end

            global.ui.pendingControlConfig = decoded

            local controls = global.ui.flagControls
            if type(controls) ~= "table" then return end

            local ignored = Library and Library.IgnoredFlags or {}
            for flag, value in next, decoded do
                if not ignored[flag] and not isConfigFlagIgnored(flag) then applyControlConfigValue(controls[flag], value) end
            end
        end

        registerFlagControl = function(flag, adapter, shouldSave)
            if not flag or not adapter then return adapter end

            flag = normalizeFlagName(flag)
            adapter.Flag = flag

            if shouldSave == false then
                global.ui.noSaveFlags[flag] = true
                if Library then
                    Library.IgnoredFlags = Library.IgnoredFlags or {}
                    Library.IgnoredFlags[flag] = true
                    if Library.SetFlags then Library.SetFlags[flag] = nil end
                    if Library.Flags then Library.Flags[flag] = nil end
                    if Library.PendingConfig then Library.PendingConfig[flag] = nil end
                end
                return adapter
            end

            global.ui.flagControls[flag] = adapter

            local pending = global.ui.pendingControlConfig
            if type(pending) == "table" and pending[flag] ~= nil then
                local value = pending[flag]
                if task and type(task.defer) == "function" then
                    task.defer(function()
                        applyControlConfigValue(adapter, value)
                    end)
                else
                    applyControlConfigValue(adapter, value)
                end
            end

            return adapter
        end

        global.ui.syncConfigToControls = syncConfigToControls
        global.ui.registerFlagControl = registerFlagControl

        if Library then
            local rawLoadConfigForControlSync = Library.LoadConfig
            if type(rawLoadConfigForControlSync) == "function" then
                Library.LoadConfig = function(self, config)
                    local decoded
                    local normalizedConfig = config
                    local decodeOk = pcall(function()
                        decoded = stripIgnoredConfigFlags(httpservice:JSONDecode(config))
                        normalizedConfig = httpservice:JSONEncode(decoded)
                    end)

                    if not decodeOk then
                        decoded = nil
                        normalizedConfig = config
                    end

                    local ok, result, extra = pcall(rawLoadConfigForControlSync, self, normalizedConfig)
                    if not ok then return false, result end

                    if decoded then
                        if task and type(task.defer) == "function" then
                            task.defer(function()
                                syncConfigToControls(decoded)
                            end)
                        else
                            syncConfigToControls(decoded)
                        end
                    end

                    return result, extra
                end
            end

            local rawGetConfigForCleanup = Library.GetConfig
            if type(rawGetConfigForCleanup) == "function" then
                Library.GetConfig = function(self)
                    local ok, encoded = pcall(rawGetConfigForCleanup, self)
                    if not ok or type(encoded) ~= "string" then return encoded end

                    local decodeOk, decoded = pcall(function()
                        return stripIgnoredConfigFlags(httpservice:JSONDecode(encoded))
                    end)

                    if not decodeOk or type(decoded) ~= "table" then return encoded end

                    local ignored = Library.IgnoredFlags or {}
                    for flag in next, ignored do decoded[flag] = nil end
                    for flag in next, global.ui.noSaveFlags do decoded[flag] = nil end

                    return httpservice:JSONEncode(decoded)
                end
            end
        end

        local function createControl(section, methodName, payload)
            local method = section.Raw and section.Raw[methodName]
            if type(method) ~= "function" then return nil end
            local ok, result = pcall(method, section.Raw, payload)
            if ok then return result end
            warn(("[crewbattler merge] failed creating %s: %s"):format(tostring(payload and payload.Name), tostring(result)))
            return nil
        end

        local masterKeybindToggles = {
            ["Walk Speed"] = true,
            ["Jump Power"] = true,
            ["Car Modifications"] = true,
            ["Heli Modifications"] = true,
            ["Plane Modifications"] = true,
            ["Bike Modifications"] = true,
            ["Boat Modifications"] = true,
            ["Break Nearby Vehicles"] = true,
            ["Eject Aura"] = true,
            ["Breakout Aura"] = true,
            ["Kill Aura"] = true,
            ["Silent Aim"] = true,
            ["Arrest Aura"] = true,
            ["Markers"] = true,
        }

        local function makeSectionAdapter(rawSection, pageName, sectionName)
            local sectionAdapter = {
                Raw = rawSection,
                PageName = pageName,
                SectionName = sectionName,
                Visible = true,
            }

            function sectionAdapter:Toggle(name, callback, isMasterSwitch, defaultValue)
                local flag = makeUniqueFlag(self.SectionName, name)
                local adapter
                local rawControl = createControl(self, "Toggle", {
                    Name = name,
                    Flag = flag,
                    Default = defaultValue == true,
                    Callback = function(value)
                        value = value == true
                        if adapter then adapter.SetState(value) end
                        runCallback(callback, value)
                    end,
                })
                adapter = makeControlAdapter(rawControl, defaultValue == true, callback)
                adapter.Name = name
                registerFlagControl(flag, adapter, true)

                -- Toggle:Settings() returns a collapsible settings container under the toggle;
                -- wrap it as a section adapter so child controls nest under the master toggle.
                -- SectionName is inherited so nested controls keep their existing config flags.
                adapter.Settings = function()
                    if adapter._settings ~= nil then return adapter._settings or nil end
                    local ok, raw = pcall(function() return callMethod(rawControl, "Settings") end)
                    if ok and raw then
                        adapter._settings = makeSectionAdapter(raw, self.PageName, self.SectionName)
                    else
                        adapter._settings = false
                    end
                    return adapter._settings or nil
                end

                if isMasterSwitch and masterKeybindToggles[name] then
                    local keybindName = ("%s Keybind"):format(name)
                    local keybindKey = ("%s_keybind"):format(flag)
                    local keybindControl = adapter:Keybind({
                        Name = keybindName,
                        Flag = keybindKey,
                        Mode = "Toggle",
                        Default = Enum.KeyCode.Unknown,
                        Callback = function(value)
                            adapter.Set(value == true)
                        end,
                    })
                    adapter.MasterKeybind = keybindControl
                    adapter.setChild(keybindControl)
                    if global.ui and global.ui.controls then global.ui.controls[keybindKey] = keybindControl end
                end

                return adapter
            end

            function sectionAdapter:Slider(name, min, max, callback, defaultValue, suffix)
                local default = tonumber(defaultValue) or min or 0
                local flag = makeUniqueFlag(self.SectionName, name)
                local adapter
                local rawControl = createControl(self, "Slider", {
                    Name = name,
                    Flag = flag,
                    Min = min or 0,
                    Max = max or 100,
                    Default = default,
                    Decimals = 1,
                    Suffix = suffix or "",
                    Callback = function(value)
                        value = tonumber(value) or default
                        if adapter then adapter.SetState(value) end
                        runCallback(callback, value)
                    end,
                })
                adapter = makeControlAdapter(rawControl, default, callback, nil, function(value)
                    return tonumber(value) or default
                end)
                adapter.Name = name
                return registerFlagControl(flag, adapter, true)
            end

            function sectionAdapter:Button(name, callback)
                local rawControl = createControl(self, "Button", {
                    Name = name,
                    Callback = function()
                        runCallback(callback)
                    end,
                })
                return makeControlAdapter(rawControl, false, nil)
            end

            function sectionAdapter:TextBox(name, nametext, callback, options)
                options = options or {}
                local default = tostring(options.Default or "")
                local flag = makeUniqueFlag(self.SectionName, name)
                local adapter
                local rawControl = createControl(self, "Textbox", {
                    Name = name,
                    Flag = flag,
                    Numeric = false,
                    Finished = true,
                    Placeholder = nametext or "",
                    Default = default,
                    Save = options.Save,
                    LoadCallback = options.LoadCallback,
                    Callback = function(value)
                        value = tostring(value or "")
                        if adapter then adapter.SetState(value) end
                        runCallback(callback, value)
                    end,
                })
                adapter = makeControlAdapter(rawControl, default, callback, nil, function(value)
                    return tostring(value or "")
                end)
                adapter.Name = name
                return registerFlagControl(flag, adapter, options.Save ~= false)
            end

            function sectionAdapter:DropDown(name, list, callback, defaultValue)
                local items = list or {}
                if #items == 0 then items = {"None"} end
                local default = defaultValue
                if default == nil or not table.find(items, default) then default = items[1] end
                local flag = makeUniqueFlag(self.SectionName, name)
                local adapter
                local rawControl = createControl(self, "Dropdown", {
                    Name = name,
                    Flag = flag,
                    Items = items,
                    Multi = false,
                    Default = default,
                    Callback = function(value)
                        if adapter then adapter.SetState(value) end
                        runCallback(callback, value)
                    end,
                })
                adapter = makeControlAdapter(rawControl, default, callback)
                adapter.Name = name
                adapter.list = items
                return registerFlagControl(flag, adapter, true)
            end

            function sectionAdapter:Selector(name, list, callback) return self:DropDown(name, list, callback) end

            function sectionAdapter:KeyBind(name, defaultKey, callback)
                local flag = makeUniqueFlag(self.SectionName, name)
                local labelRaw = createControl(self, "Label", {
                    Name = name,
                })
                if not labelRaw then
                    warn(("[crewbattler merge] failed creating keybind row %s: library label method unavailable"):format(tostring(name)))
                    return makeControlAdapter(nil, false, callback)
                end

                local adapter
                local payload = {
                    Name = name,
                    Flag = flag,
                    Mode = "Toggle",
                    Default = defaultKey,
                    Callback = function(value)
                        if Library and Library.IsLoadingConfig then return end
                        value = value == true
                        if adapter then adapter.SetState(value) end
                        runCallback(callback, value)
                    end,
                }
                local rawControl = callMethod(labelRaw, "Keybind", payload)
                if not rawControl then warn(("[crewbattler merge] failed creating keybind %s: library keybind method unavailable"):format(tostring(name))) end
                adapter = makeControlAdapter(rawControl, false, callback)
                adapter.Name = name
                return registerFlagControl(flag, adapter, true)
            end

            function sectionAdapter:Label(text, forceColor, forceLeft)
                local rawControl = createControl(self, "Label", {
                    Name = text,
                })
                local labelState = tostring(text)
                local adapter = makeControlAdapter(rawControl, tostring(text), nil, nil, function(value)
                    return tostring(value or "")
                end)
                adapter.Get = function()
                    return labelState
                end
                adapter.Set = function(value)
                    labelState = tostring(value or "")
                    callMethod(rawControl, "SetText", labelState)
                    callMethod(rawControl, "Set", labelState)
                end
                global.ui.statusControls[text] = adapter
                global.ui.colorControls[text] = adapter
                adapter.Set(tostring(global.ui.statusRobberies[text] or text))
                if forceColor then adapter.SetColor(forceColor) end
                return adapter
            end

            function sectionAdapter:Credit(name) return self:Label(name) end

            return setmetatable(sectionAdapter, {
                __index = function(_, key)
                    if rawSection then return rawSection[key] end
                    return nil
                end,
                __newindex = function(t, key, value)
                    rawset(t, key, value)
                    if key == "Visible" then callMethod(rawSection, "SetVisibility", value) end
                end,
            })
        end

        local function makePageAdapter(rawPage, pageName)
            local pageAdapter = {
                Raw = rawPage,
                PageName = pageName,
                NextSide = 1,
            }

            function pageAdapter:Section(name)
                local side = self.NextSide
                self.NextSide = side == 1 and 2 or 1
                local rawSection = self.Raw:Section({
                    Name = name,
                    Side = side,
                })
                local sectionAdapter = makeSectionAdapter(rawSection, self.PageName, name)
                return sectionAdapter, sectionAdapter
            end

            -- MultiSection: a single section box on the page holding tabbed sub-sections.
            -- :Add(tabName, flagName) returns a section adapter whose SectionName is flagName
            -- (so controls keep their existing config flags when moved into sub-tabs).
            -- Falls back to plain Sections if the loaded library has no MultiSection.
            function pageAdapter:MultiSection(side)
                side = side or self.NextSide
                self.NextSide = side == 1 and 2 or 1
                local pageRaw, pageName = self.Raw, self.PageName
                local ok, rawMulti = pcall(function() return pageRaw:MultiSection({ Side = side }) end)
                if ok and rawMulti and type(rawMulti.Add) == "function" then
                    return {
                        Add = function(_, tabName, flagName)
                            local subOk, rawSub = pcall(function() return rawMulti:Add(tabName) end)
                            if not subOk or not rawSub then
                                rawSub = pageRaw:Section({ Name = tabName, Side = side })
                            end
                            return makeSectionAdapter(rawSub, pageName, flagName or tabName)
                        end,
                    }
                end
                -- no MultiSection support: degrade to separate plain sections
                return {
                    Add = function(_, tabName, flagName)
                        local rawSub = pageRaw:Section({ Name = tabName, Side = side })
                        return makeSectionAdapter(rawSub, pageName, flagName or tabName)
                    end,
                }
            end

            return pageAdapter
        end

        global.ui.window = {tab = Window}
        global.ui.combat = {tab = makePageAdapter(Window:Page({Name = "combat"}), "combat")}
        global.ui.markers = {tab = makePageAdapter(Window:Page({Name = "visuals"}), "visuals")}
        global.ui.player = {tab = makePageAdapter(Window:Page({Name = "player"}), "player")}
        global.ui.vehicle = {tab = makePageAdapter(Window:Page({Name = "vehicle"}), "vehicle")}
        global.ui.robbery = {tab = makePageAdapter(Window:Page({Name = "robbery"}), "robbery")}
        global.ui.misc = {tab = makePageAdapter(Window:Page({Name = "misc"}), "misc")}
        global.ui.info = {tab = makePageAdapter(Window:Page({Name = "info"}), "info")}

        local initialized = false
        global.ui.initWindow = function()
            if initialized then return end
            initialized = true
            Window:InitWindow()
            pcall(function()
                local coreGui = CloneRef(game:GetService("CoreGui"))
                if not coreGui:FindFirstChild("crewbattler.club") then
                    local marker = Instance.new("ScreenGui")
                    marker.Name = "crewbattler.club"
                    marker.ResetOnSpawn = false
                    marker.Parent = coreGui
                end
            end)
        end
        return true
        end
    end
    ON_SERVER_CONNECT()
    local function executionIdentifier()
        local executor = identifyexecutor()
        global.getExecutor = executor
        global.exploit = Electron and "electron" or global.getExecutor == "Krampus" and "krampus/ro-exec" or "???"
        global.version = _version
    end
    executionIdentifier()
    global.ui.controls = {}
    global.ui_status = {
    }
    global.ui.buildSections = function()
        if global.ui.sectionsBuilt then return true end
        if not (global.ui.window and global.ui.window.tab) then return false end
        global.ui.sectionsBuilt = true
        global.ui.statusRobberies = {}
        global.ui.colorForcing = {}
        local function ui()
        local function ui()
            local window = global.ui.window.tab
            local plr = global.ui.player.tab
            local vehicle = global.ui.vehicle.tab
            local misc = global.ui.misc.tab
            local combat = global.ui.combat.tab
            local markers = global.ui.markers.tab
            local robbery = global.ui.robbery.tab
            local info = global.ui.info.tab
            local uiMarker = markers:Section("Marker")
            local uiTeams, teamsSection = markers:Section("Teams")
            local uiObj, objSection = markers:Section("Objects")
            local uiSettings, settingsSection = markers:Section("Settings")
            local uiEsp = markers:Section("ESP")
            -- Silent Aim split into a tabbed MultiSection (main aim + fov circle). Both
            -- sub-tabs use flag-section "Silent Aim" so existing saved configs still load.
            local silentMulti = combat:MultiSection()
            local silentMain = silentMulti:Add("silent aim", "Silent Aim")
            local silentFov = silentMulti:Add("fov circle", "Silent Aim")
            local sections = {
                WalkSpeed = plr:Section("Walk Speed");
                JumpPower = plr:Section("Jump Power");
                PlayerUtils = plr:Section("Utils");
                PlayerMisc = plr:Section("Misc");
                Marker = uiMarker;
                Teams = uiTeams;
                Objects = uiObj;
                Settings = uiSettings;
                ESP = uiEsp;
                Crosshair = markers:Section("Crosshair");
                AuraEffects = markers:Section("Aura Effects");
                BulletTracers = markers:Section("Bullet Tracers");
                Gunmods = combat:Section("Gun Mods");
                GunmodsMisc = combat:Section("Misc");
                Gunstore = combat:Section("Gun Store");
                BreakExperience = combat:Section("Break Experience");
                Killaura = combat:Section("Kill Aura");
                Silentaim = silentMain;
                SilentaimFov = silentFov;
                Arrestaura = combat:Section("Arrest Aura");
                Misc = misc:Section("Misc");
                Disablers = misc:Section("Disablers");
                BreakVehicles = misc:Section("Break Nearby Vehicles");
                Auras = misc:Section("Auras");
                PlaySounds = misc:Section("Play Sounds");
                RocketFun = misc:Section("Rocket Fun");
                C4Fun = misc:Section("C4 Fun");
                CarModify = vehicle:Section("Car Modifications");
                HeliModify = vehicle:Section("Heli Modifications");
                PlaneModify = vehicle:Section("Plane Modifications");
                BikeModify = vehicle:Section("Bike Modifications");
                BoatModify = vehicle:Section("Boat Modifications");
                VehicleMisc = vehicle:Section("Misc");
                Bank = robbery:Section("Bank");
                BankTruck = robbery:Section("Money Truck");
                Jewelry = robbery:Section("Jewelry");
                Museum = robbery:Section("Museum");
                Casino = robbery:Section("Casino");
                Airdrop = robbery:Section("Airdrop");
                Cargoplane = robbery:Section("Cargo Plane");
                Mansion = robbery:Section("Mansion");
                Trains = robbery:Section("Trains");
                Powerplant = robbery:Section("Powerplant");
                Tomb = robbery:Section("Tomb");
                Cargoship = robbery:Section("Cargoship");
                SmallStores = robbery:Section("Small Stores");
                OilRig = robbery:Section("Oil Rig");
                Info = info:Section("Info");
                LightingTechnology = info:Section("Lighting Technology");
            }
            global.ui.sections = sections
            local function slider(section, name, min, max, callback, defaultValue, suffix)
                local section = sections[section]
                return section:Slider(name, min, max, callback, defaultValue, suffix)
            end
            local function toggle(section, name, callback, isMasterSwitch, defaultValue)
                if not isMasterSwitch then isMasterSwitch = false end
                local section = sections[section]
                return section:Toggle(name, callback, isMasterSwitch, defaultValue)
            end
            local function label(section, text, forceColor, forceLeft)
                local section = sections[section]
                global.ui.statusRobberies[text] = text
                global.ui.colorForcing[text] = forceColor
                return section:Label(text, forceColor, forceLeft)
            end
            local function button(section, name, callback)
                local section = sections[section]
                return section:Button(name, callback)
            end
            local function textbox(section, name, nametext, callback, options)
                local section = sections[section]
                return section:TextBox(name, nametext, callback, options)
            end
            local function selector(section, name, list, callback)
                local section = sections[section]
                return section:Selector(name, list, callback)
            end
            local function dropdown(section, name, list, callback, defaultValue)
                local section = sections[section]
                return section:DropDown(name, list, callback, defaultValue)
            end
            local function invokeRegistryAction(name)
                local action = global.registry and global.registry[name]
                if type(action) ~= "function" then return false end
                local ok, err = pcall(action)
                if not ok then warn(("[crewbattler merge] keybind action %s failed: %s"):format(tostring(name), tostring(err))) end
                return ok
            end
            local function attachedKeybind(control, name, flag, defaultKey, callback, mode)
                if not control or type(control.Keybind) ~= "function" then
                    warn(("[crewbattler merge] failed creating keybind %s: parent control is missing Keybind"):format(tostring(name)))
                    local makeAdapter = global.ui and global.ui.makeControlAdapter
                    if type(makeAdapter) == "function" then
                        return makeAdapter(nil, false, callback)
                    end
                    return {Set = function() end, Get = function() return false end, setChild = function(_, child) return child end}
                end
                local keybindControl = control:Keybind({
                    Name = name,
                    Flag = flag,
                    Mode = mode or "Toggle",
                    Default = defaultKey,
                    Callback = callback,
                })
                return keybindControl
            end
            local function credit(section, name)
                local section = sections[section]
                return section:Credit(name)
            end
            local callback = {}
            local function sections()
                local controls = global.ui.controls
                local function addChild(parent, control)
                    if control and parent and parent.setChild then parent.setChild(control) end
                    return control
                end
                -- if the parent toggle exposes a Settings() container, child controls are
                -- created inside it (collapsible nesting); otherwise fall back to the flat
                -- section + setChild. Applied via the option* helpers so it covers every tab.
                local function settingsFor(parent)
                    if parent and type(parent.Settings) == "function" then
                        local ok, s = pcall(parent.Settings, parent)
                        if ok and s then return s end
                    end
                    return nil
                end
                local function statusCallback(key)
                    callback[key] = function(value)
                        global.ui_status[key] = value
                    end
                    return callback[key]
                end
                local function colorCallback(key)
                    callback[key] = function(color)
                        global.ui_status[key] = color
                    end
                    return callback[key]
                end
                local function optionToggle(sectionName, name, key, parent, defaultValue)
                    local s = settingsFor(parent)
                    local control
                    if s then control = s:Toggle(name, statusCallback(key), false, defaultValue)
                    else control = addChild(parent, toggle(sectionName, name, statusCallback(key), false, defaultValue)) end
                    controls[key] = control
                    return control
                end
                local function optionSlider(sectionName, name, min, max, key, defaultValue, parent, suffix)
                    local s = settingsFor(parent)
                    local control
                    if s then control = s:Slider(name, min, max, statusCallback(key), defaultValue, suffix)
                    else control = addChild(parent, slider(sectionName, name, min, max, statusCallback(key), defaultValue, suffix)) end
                    controls[key] = control
                    return control
                end
                local function optionDropdown(sectionName, name, items, key, defaultValue, parent)
                    local s = settingsFor(parent)
                    local control
                    if s then control = s:DropDown(name, items, statusCallback(key), defaultValue)
                    else control = addChild(parent, dropdown(sectionName, name, items, statusCallback(key), defaultValue)) end
                    controls[key] = control
                    return control
                end
                local function optionTextbox(sectionName, name, placeholder, key, parent, options)
                    local s = settingsFor(parent)
                    local control
                    if s then control = s:TextBox(name, placeholder, statusCallback(key), options)
                    else control = addChild(parent, textbox(sectionName, name, placeholder, statusCallback(key), options)) end
                    controls[key] = control
                    return control
                end
                local function optionColor(parent, key, name, defaultColor)
                    if not parent or type(parent.Colorpicker) ~= "function" then return nil end
                    local control = parent:Colorpicker({
                        Name = name,
                        Flag = key,
                        Default = defaultColor,
                        Callback = colorCallback(key),
                    })
                    controls[key] = control
                    return addChild(parent, control)
                end
                local easingStyles = {"Linear", "Sine", "Quad", "Cubic", "Quart", "Quint", "Back", "Bounce", "Elastic", "Exponential", "Circular"}
                local circleModes = {"center", "mouse", "custom"}
                local circlePositionSources = {"Local Character", "Silent Aim Target", "Forced Target"}
                local auraOptions = {"starlight", "heavenly", "ribbon", "lightning", "sakura", "angel", "wind", "flow", "star", "angel wing", "blue heat", "heal aura", "ambient", "nimb", "tornado"}
                local function player()
                    function callback.master_switch_walkspeed(bool) global.ui_status.master_switch_walkspeed = bool end
                    function callback.master_switch_jumppower(bool) global.ui_status.master_switch_jumppower = bool end
                    function callback.walkspeed(num) global.ui_status.walkspeed = num end
                    function callback.ws_disable_if_handcuffed(bool) global.ui_status.ws_disable_if_handcuffed = bool end
                    function callback.jp_disable_if_handcuffed(bool) global.ui_status.jp_disable_if_handcuffed = bool end
                    function callback.jumppower(num) global.ui_status.jumppower = num end
                    function callback.antiragdoll(bool) global.ui_status.antiragdoll = bool end
                    function callback.antifalldamage(bool) global.ui_status.antifalldamage = bool end
                    function callback.antiskydive(bool) global.ui_status.antiskydive = bool end
                    function callback.antitaze(bool) global.ui_status.antitaze = bool end
                    function callback.allow_equip_on_duck(bool) global.ui_status.allow_equip_on_duck = bool end
                    function callback.infduck(bool) global.ui_status.infduck = bool end
                    function callback.infpunch(bool) global.ui_status.infpunch = bool end
                    function callback.alwaysjump(bool) global.ui_status.alwaysjump = bool end
                    function callback.allow_equip_with_items(bool) global.ui_status.allow_equip_with_items = bool end
                    function callback.allow_equip_while_flying(bool) global.ui_status.allow_equip_while_flying = bool end
                    function callback.automatic_respawn_on_taze(bool) global.ui_status.automatic_respawn_on_taze = bool end
                    function callback.alwayssprint(bool) global.ui_status.alwayssprint = bool end
                    function callback.jesus(bool) global.ui_status.jesus = bool end
                    function callback.automatic_punch(bool) global.ui_status.automatic_punch = bool end
                    function callback.always_duck(bool) global.ui_status.always_duck = bool end
                    function callback.respawn()
                        local dieOfFalldamage = global.registry.dieOfFalldamage
                        if dieOfFalldamage then dieOfFalldamage() end
                    end
                    function callback.antiparachute(bool) global.ui_status.antiparachute = bool end
                    function callback.fov(num) global.ui_status.fov = num or 70 end
                    function callback.parachute_on_key(bool) global.ui_status.parachute_on_key = bool end
                    function callback.glider_on_key(bool) global.ui_status.glider_on_key = bool end
                    function callback.one_way_noclip(bool) global.ui_status.one_way_noclip = bool end
                    function callback.infinite_roll(bool) global.ui_status.infinite_roll = bool end
                    function callback.roll_duration(num) global.ui_status.roll_duration = num end
                    function callback.always_roll(bool) global.ui_status.always_roll = bool end
                    function callback.break_physics(bool) global.ui_status.break_physics = bool end
                    function callback.frozen_roll(bool) global.ui_status.frozen_roll = bool end
                    function callback.always_juiced(bool) global.ui_status.always_juiced = bool end
                    function callback.fortnite_mode(bool) global.ui_status.fortnite_mode = bool end
                    function callback.fortnite_mode_speed(num) global.ui_status.fortnite_mode_speed = num end
                    function callback.automatic_equip_after_death(bool) global.ui_status.automatic_equip_after_death = bool end
                    local master_switch_walkspeed = toggle("WalkSpeed", "Walk Speed", callback.master_switch_walkspeed, true)
                    local ws = slider("WalkSpeed", "Value", 16, 100, callback.walkspeed, 30)
                    master_switch_walkspeed.setChild(ws)
                    local ws_disable_if_handcuffed = toggle("WalkSpeed", "Disable If Handcuffed", callback.ws_disable_if_handcuffed)
                    master_switch_walkspeed.setChild(ws_disable_if_handcuffed)
                    local master_switch_jumppower = toggle("JumpPower", "Jump Power", callback.master_switch_jumppower, true)
                    local jp = slider("JumpPower", "Value", 50, 300, callback.jumppower)
                    master_switch_jumppower.setChild(jp)
                    local jp_disable_if_handcuffed = toggle("JumpPower", "Disable If Handcuffed", callback.jp_disable_if_handcuffed)
                    master_switch_jumppower.setChild(jp_disable_if_handcuffed)
                    local respawn = button("PlayerUtils", "Choose Respawn", callback.respawn)
                    local antiragdoll = toggle("PlayerUtils", "Anti Ragdoll", callback.antiragdoll)
                    local antiskydive = toggle("PlayerUtils", "Anti Skydive", callback.antiskydive)
                    local antiparachute = toggle("PlayerUtils", "Anti Parachute", callback.antiparachute)
                    local antifalldamage = toggle("PlayerUtils", "Anti Falldamage", callback.antifalldamage)
                    local antitaze = toggle("PlayerUtils", "Anti Taze", callback.antitaze)
                    local jesus = toggle("PlayerUtils", "Jesus", callback.jesus)
                    function callback.flight() global.notify("Feature not implemented", 5) end
                    local automatic_equip_after_death = toggle("PlayerUtils", "Automatic Equip After Death", callback.automatic_equip_after_death)
                    controls.automatic_equip_after_death = automatic_equip_after_death
                    local allow_equip_on_duck = toggle("PlayerUtils", "Allow Equip On Duck", callback.allow_equip_on_duck)
                    local allow_equip_while_flying = toggle("PlayerUtils", "Allow Equip While Flying", callback.allow_equip_while_flying)
                    local allow_equip_with_items = toggle("PlayerUtils", "Allow Equip With Items", callback.allow_equip_with_items)
                    local fov = slider("PlayerMisc", "FOV", 70, 150, callback.fov)
                    local glider_on_key = toggle("PlayerMisc", "Glider On Key", callback.glider_on_key, true)
                    local parachute_on_key = toggle("PlayerMisc", "Parachute On Key", callback.parachute_on_key, true)
                    local one_way_noclip = toggle("PlayerMisc", "1 Way Noclip", callback.one_way_noclip, true)
                    local glider_key = attachedKeybind(glider_on_key, "Glider Key", "glider_key", Enum.KeyCode.J, function(pressed)
                        if pressed then invokeRegistryAction("toggle_glider") end
                    end, "Hold")
                    local parachute_key = attachedKeybind(parachute_on_key, "Parachute Key", "parachute_key", Enum.KeyCode.Z, function(pressed)
                        if pressed then invokeRegistryAction("toggle_parachute") end
                    end, "Hold")
                    local noclip_attempt_key = attachedKeybind(one_way_noclip, "Noclip Attempt Key", "noclip_attempt_key", Enum.KeyCode.N, function(pressed)
                        if pressed then invokeRegistryAction("activate_one_way_noclip") end
                    end, "Hold")
                    local infduck = toggle("PlayerMisc", "Infinite Duck", callback.infduck)
                    local infpunch = toggle("PlayerMisc", "Infinite Punch", callback.infpunch)
                    local alwaysjump = toggle("PlayerMisc", "Infinite Jump", callback.alwaysjump)
                    local alwaysjump_key = attachedKeybind(alwaysjump, "Infinite Jump Key", "alwaysjump_key", Enum.KeyCode.Space, function(pressed)
                        if pressed then invokeRegistryAction("request_infinite_jump") end
                    end, "Hold")
                    local infinite_roll = toggle("PlayerMisc", "Infinite Roll", callback.infinite_roll)
                    local break_physics = toggle("PlayerMisc", "Break Roll Physics", callback.break_physics)
                    local frozen_roll = toggle("PlayerMisc", "Frozen Roll", callback.frozen_roll)
                    local roll_duration = slider("PlayerMisc", "Roll Duration", 3, 50, callback.roll_duration)
                    local always_roll = toggle("PlayerMisc", "Always Roll", callback.always_roll)
                    local alwayssprint = toggle("PlayerMisc", "Always Sprint", callback.alwayssprint)
                    local automatic_punch = toggle("PlayerMisc", "Always Punch", callback.automatic_punch)
                    local always_duck = toggle("PlayerMisc", "Always Duck", callback.always_duck)
                    local always_juiced = toggle("PlayerMisc", "Always Juiced", callback.always_juiced)
                    local fortnite_mode = toggle("PlayerMisc", "Fortnite Mode", callback.fortnite_mode, true)
                    local fortnite_mode_speed = slider("PlayerMisc", "Animation Speed", 1, 10, callback.fortnite_mode_speed)
                    fortnite_mode.setChild(fortnite_mode_speed)
                    function callback.spinbot(bool) global.ui_status.spinbot = bool end
                    function callback.spinbot_speed(num) global.ui_status.spinbot_speed = num end
                    local spinbot = toggle("PlayerMisc", "Spinbot", callback.spinbot, true)
                    local spinbot_speed = slider("PlayerMisc", "Spin Speed", 1, 15, callback.spinbot_speed)
                    spinbot.setChild(spinbot_speed)
                    controls.spinbot = spinbot
                    controls.spinbot_speed = spinbot_speed
                    function callback.hide_character() global.registry.hide_character_function() end
                    local hide_character = button("PlayerMisc", "Hide Character", callback.hide_character)
                    local automatic_respawn_on_taze = toggle("PlayerMisc", "Automatic Respawn On Stunned", callback.automatic_respawn_on_taze)
                    controls.master_switch_walkspeed = master_switch_walkspeed
                    controls.walkspeed = ws
                    controls.always_juiced = always_juiced
                    controls.infinite_roll = infinite_roll
                    controls.fortnite_mode = fortnite_mode
                    controls.fortnite_mode_speed = fortnite_mode_speed
                    controls.always_roll = always_roll
                    controls.frozen_roll = frozen_roll
                    controls.break_physics = break_physics
                    controls.roll_duration = roll_duration
                    controls.alwaysjump_key = alwaysjump_key
                    controls.ws_disable_if_handcuffed = ws_disable_if_handcuffed
                    controls.master_switch_jumppower = master_switch_jumppower
                    controls.jumppower = jp
                    controls.jp_disable_if_handcuffed = jp_disable_if_handcuffed
                    controls.antiragdoll = antiragdoll
                    controls.one_way_noclip = one_way_noclip
                    controls.antiskydive = antiskydive
                    controls.antiparachute = antiparachute
                    controls.antifalldamage = antifalldamage
                    controls.parachute_on_key = parachute_on_key
                    controls.parachute_key = parachute_key
                    controls.glider_on_key = glider_on_key
                    controls.glider_key = glider_key
                    controls.noclip_attempt_key = noclip_attempt_key
                    controls.fov = fov
                    controls.antitaze = antitaze
                    controls.jesus = jesus
                    controls.automatic_punch = automatic_punch
                    controls.automatic_respawn_on_taze = automatic_respawn_on_taze
                    controls.infduck = infduck
                    controls.infpunch = infpunch
                    controls.alwaysjump = alwaysjump
                    controls.always_duck = always_duck
                    controls.alwayssprint = alwayssprint
                    controls.allow_equip_on_duck = allow_equip_on_duck
                    controls.allow_equip_while_flying = allow_equip_while_flying
                    controls.allow_equip_with_items = allow_equip_with_items
                end
                local function vehicle()
                    function callback.master_switch_carmodify(bool) global.ui_status.master_switch_carmodify = bool end
                    function callback.car_speed(num) global.ui_status.car_speed = num end
                    function callback.car_brakes(num) global.ui_status.car_brakes = num end
                    function callback.car_turnspeed(num) global.ui_status.car_turnspeed = num end
                    function callback.car_height(num) global.ui_status.car_height = num end
                    function callback.master_switch_heli_speed(bool) global.ui_status.master_switch_heli_speed = bool end
                    function callback.heli_speed(num) global.ui_status.heli_speed = num end
                    function callback.infinite_heli_height(bool) global.ui_status.infinite_heli_height = bool end
                    function callback.infinite_drone_height(bool) global.ui_status.infinite_drone_height = bool end
                    function callback.infinite_nitro(bool) global.ui_status.infinite_nitro = bool end
                    function callback.antitirepop(bool) global.ui_status.antitirepop = bool end
                    function callback.allow_equip_in_vehicle(bool) global.ui_status.allow_equip_in_vehicle = bool end
                    function callback.show_hotbar_in_vehicle(bool) global.ui_status.show_hotbar_in_vehicle = bool end
                    function callback.destroy_all_destructibles(bool) global.ui_status.destroy_all_destructibles = bool end
                    function callback.automatic_flip_vehicle(bool) global.ui_status.automatic_flip_vehicle = bool end
                    function callback.spam_headlights(bool) global.ui_status.spam_headlights = bool end
                    function callback.spam_jeep_roof(bool) global.ui_status.spam_jeep_roof = bool end
                    function callback.always_drift(bool) global.ui_status.always_drift = bool end
                    function callback.automatic_hijack_vehicles(bool) global.ui_status.automatic_hijack_vehicles = bool end
                    function callback.instant_rope(bool) global.ui_status.instant_rope = bool end
                    function callback.rope_aura(bool) global.ui_status.rope_aura = bool end
                    function callback.automatic_eject_vehicle_player(bool) global.ui_status.automatic_eject_vehicle_player = bool end
                    function callback.automatic_lock_vehicle(bool) global.ui_status.automatic_lock_vehicle = bool end
                    function callback.master_switch_carmodify(bool) global.ui_status.master_switch_carmodify = bool end
                    function callback.destruct_delay(num) global.ui_status.destruct_delay = num end
                    function callback.no_trailer(bool) global.ui_status.no_trailer = bool end
                    function callback.vehicle_jump(bool) global.ui_status.vehicle_jump = bool end
                    function callback.master_switch_plane(bool) global.ui_status.master_switch_plane = bool end
                    function callback.anti_max_height(bool) global.ui_status.anti_max_height = bool end
                    function callback.plane_speed(num) global.ui_status.plane_speed = num end
                    function callback.automatic_jet_heat_seek(bool) global.ui_status.automatic_jet_heat_seek = bool end
                    function callback.master_switch_boat(bool) global.ui_status.master_switch_boat = bool end
                    function callback.boat_speed(num) global.ui_status.boat_speed = num end
                    function callback.boat_on_land(bool) global.ui_status.boat_on_land = bool end
                    function callback.master_switch_bike(bool) global.ui_status.master_switch_bike = bool end
                    function callback.bike_speed(num) global.ui_status.bike_speed = num end
                    function callback.dirt_bike_height(bool) global.ui_status.dirt_bike_height = bool end
                    function callback.bike_height_value(num) global.ui_status.bike_height_value = num end
                    function callback.rope_length(num) global.ui_status.rope_length = num end
                    local master_switch_carmodify = toggle("CarModify", "Car Modifications", callback.master_switch_carmodify, true)
                    local car_speed = slider("CarModify", "Speed", 1, 50, callback.car_speed)
                    local car_brakes = slider("CarModify", "Brakes", 1, 50, callback.car_brakes)
                    local car_turnspeed = slider("CarModify", "Turn Speed", 1, 5, callback.car_turnspeed)
                    local car_height = slider("CarModify", "Height", 3, 125, callback.car_height)
                    master_switch_carmodify.setChild(car_speed)
                    master_switch_carmodify.setChild(car_brakes)
                    master_switch_carmodify.setChild(car_turnspeed)
                    master_switch_carmodify.setChild(car_height)
                    local infinite_nitro = toggle("CarModify", "Infinite Nitro", callback.infinite_nitro)
                    local automatic_flip_vehicle = toggle("CarModify", "Automatic Flip Vehicle", callback.automatic_flip_vehicle)
                    local spam_headlights = toggle("CarModify", "Spam Headlights", callback.spam_headlights)
                    local spam_jeep_roof = toggle("CarModify", "Spam Jeep Roof", callback.spam_jeep_roof)
                    local always_drift = toggle("CarModify", "Always Drift", callback.always_drift)
                    master_switch_carmodify.setChild(infinite_nitro)
                    master_switch_carmodify.setChild(automatic_flip_vehicle)
                    master_switch_carmodify.setChild(spam_headlights)
                    master_switch_carmodify.setChild(spam_jeep_roof)
                    master_switch_carmodify.setChild(always_drift)
                    local master_switch_heli_speed = toggle("HeliModify", "Heli Modifications", callback.master_switch_heli_speed, true)
                    local heli_speed = slider("HeliModify", "Speed", 1, 5, callback.heli_speed)
                    local rope_length = slider("HeliModify", "Rope Length", 50, 200, callback.rope_length)
                    local infinite_heli_height = toggle("HeliModify", "Infinite Heli Height", callback.infinite_heli_height)
                    local infinite_drone_height = toggle("HeliModify", "Infinite Drone Height", callback.infinite_drone_height)
                    local instant_rope = toggle("HeliModify", "Instant Rope", callback.instant_rope, true)
                    local rope_aura = toggle("HeliModify", "Extended Rope", callback.rope_aura)
                    master_switch_heli_speed.setChild(heli_speed)
                    master_switch_heli_speed.setChild(rope_length)
                    master_switch_heli_speed.setChild(infinite_heli_height)
                    master_switch_heli_speed.setChild(infinite_drone_height)
                    master_switch_heli_speed.setChild(instant_rope)
                    master_switch_heli_speed.setChild(rope_aura)
                    instant_rope.setChild(rope_aura)
                    local master_switch_plane = toggle("PlaneModify", "Plane Modifications", callback.master_switch_plane, true)
                    local plane_speed = slider("PlaneModify", "Speed", 1, 5, callback.plane_speed)
                    local anti_max_height = toggle("PlaneModify", "Anti Max Height", callback.anti_max_height)
                    local automatic_jet_heat_seek = toggle("PlaneModify", "Automatic Jet Heat Seek", callback.automatic_jet_heat_seek)
                    master_switch_plane.setChild(plane_speed)
                    master_switch_plane.setChild(anti_max_height)
                    master_switch_plane.setChild(automatic_jet_heat_seek)
                    local master_switch_bike = toggle("BikeModify", "Bike Modifications", callback.master_switch_bike, true)
                    local bike_speed = slider("BikeModify", "Speed", 1, 5, callback.bike_speed)
                    local dirt_bike_height = toggle("BikeModify", "Dirt Bike Height", callback.dirt_bike_height, true)
                    local bike_height_value = slider("BikeModify", "Value", 1, 15, callback.bike_height_value)
                    dirt_bike_height.setChild(bike_height_value)
                    master_switch_bike.setChild(bike_speed)
                    master_switch_bike.setChild(dirt_bike_height)
                    local master_switch_boat = toggle("BoatModify", "Boat Modifications", callback.master_switch_boat, true)
                    local boat_speed = slider("BoatModify", "Speed", 1, 5, callback.boat_speed)
                    local boat_on_land = toggle("BoatModify", "Boat On Land", callback.boat_on_land)
                    master_switch_boat.setChild(boat_speed)
                    master_switch_boat.setChild(boat_on_land)
                    local antitirepop = toggle("VehicleMisc", "Anti Break Vehicle", callback.antitirepop)
                    local no_trailer = toggle("VehicleMisc", "No Semitruck Trailer", callback.no_trailer)
                    local instant_tow = optionToggle("VehicleMisc", "Instant Tow", "instant_tow", nil, false)
                    local pro_garage = optionToggle("VehicleMisc", "Pro Garage", "pro_garage", nil, false)
                    local vehicle_jump = toggle("VehicleMisc", "Vehicle Jump", callback.vehicle_jump, true)
                    local vehicle_jump_key = attachedKeybind(vehicle_jump, "Vehicle Jump Key", "vehicle_jump_key", Enum.KeyCode.X, function(pressed)
                        if pressed then invokeRegistryAction("jump_vehicle") end
                    end, "Hold")
                    local automatic_hijack_vehicles = toggle("VehicleMisc", "Automatic Hijack Vehicles", callback.automatic_hijack_vehicles)
                    local automatic_lock_vehicle = toggle("VehicleMisc", "Automatic Lock Vehicle", callback.automatic_lock_vehicle)
                    local automatic_eject_vehicle_player = toggle("VehicleMisc", "Automatic Eject Passengers", callback.automatic_eject_vehicle_player)
                    local destroy_all_destructibles = toggle("VehicleMisc", "Destroy All Destructibles", callback.destroy_all_destructibles, true)
                    local destruct_delay = slider("VehicleMisc", "Destruct Delay", 0, 10, callback.destruct_delay)
                    destroy_all_destructibles.setChild(destruct_delay)
                    local show_hotbar_in_vehicle = toggle("VehicleMisc", "Show Hotbar In Vehicle", callback.show_hotbar_in_vehicle)
                    controls.master_switch_boat = master_switch_boat
                    controls.boat_speed = boat_speed
                    controls.boat_on_land = boat_on_land
                    controls.master_switch_plane = master_switch_plane
                    controls.plane_speed = plane_speed
                    controls.anti_max_height = anti_max_height
                    controls.automatic_jet_heat_seek = automatic_jet_heat_seek
                    controls.master_switch_bike = master_switch_bike
                    controls.bike_speed = bike_speed
                    controls.dirt_bike_height = dirt_bike_height
                    controls.bike_height_value = bike_height_value
                    controls.master_switch_carmodify = master_switch_carmodify
                    controls.car_speed = car_speed
                    controls.vehicle_jump = vehicle_jump
                    controls.car_brakes = car_brakes
                    controls.no_trailer = no_trailer
                    controls.car_turnspeed = car_turnspeed
                    controls.rope_length = rope_length
                    controls.car_height = car_height
                    controls.master_switch_heli_speed = master_switch_heli_speed
                    controls.destruct_delay = destruct_delay
                    controls.heli_speed = heli_speed
                    controls.automatic_flip_vehicle = automatic_flip_vehicle
                    controls.spam_headlights = spam_headlights
                    controls.spam_jeep_roof = spam_jeep_roof
                    controls.always_drift = always_drift
                    controls.automatic_lock_vehicle = automatic_lock_vehicle
                    controls.vehicle_jump_key = vehicle_jump_key
                    controls.automatic_eject_vehicle_player = automatic_eject_vehicle_player
                    controls.infinite_heli_height = infinite_heli_height
                    controls.instant_rope = instant_rope
                    controls.rope_aura = rope_aura
                    controls.infinite_drone_height = infinite_drone_height
                    controls.infinite_nitro = infinite_nitro
                    controls.destroy_all_destructibles = destroy_all_destructibles
                    controls.automatic_hijack_vehicles = automatic_hijack_vehicles
                    controls.antitirepop = antitirepop
                    controls.allow_equip_in_vehicle = allow_equip_in_vehicle
                    controls.show_hotbar_in_vehicle = show_hotbar_in_vehicle
                end
                local function misc()
                    function callback.always_keycard(bool) global.ui_status.always_keycard = bool end
                    function callback.no_equip_conditions(bool) global.ui_status.no_equip_conditions = bool end
                    function callback.never_unload_world(bool) global.ui_status.never_unload_world = bool end
                    function callback.remove_clothing()
                        if global._loaded then
                            local hitbox = workspace.ClothingRacks.ClothingRack.Hitbox
                            fireclickdetector(hitbox.ClickDetector)
                        end
                    end
                    function callback.give_police_clothing()
                        if global._loaded then
                            local client = global.registry.client
                            for i,v in next, client.descendants.givers do
                                if v.Name == "Station" then
                                    if v.Item.Value == "ShirtPolice" then fireclickdetector(v.ClickDetector) end
                                    if v.Item.Value == "PantsPolice" then fireclickdetector(v.ClickDetector) end
                                end
                                task.wait()
                            end
                        end
                    end
                    function callback.give_police_hat()
                        if global._loaded then
                            local client = global.registry.client
                            for i,v in next, client.descendants.givers do
                                if v.Name == "Station" then
                                    if v.Item.Value == "HatPolice" then fireclickdetector(v.ClickDetector) end
                                end
                            end
                        end
                    end
                    function callback.pickpocketaura(bool) global.ui_status.pickpocketaura = bool end
                    function callback.range_pickpocketaura(num) global.ui_status.range_pickpocketaura = num end
                    function callback.droppedcashaura(bool) global.ui_status.droppedcashaura = bool end
                    function callback.droppedcashrange(num) global.ui_status.droppedcashrange = num end
                    function callback.range_pickpocketaura(num) global.ui_status.range_pickpocketaura = num end
                    function callback.disable_lasers(bool) global.ui_status.disable_lasers = bool end
                    function callback.disable_cameras(bool) global.ui_status.disable_cameras = bool end
                    function callback.master_switch_no_circle_delay(bool) global.ui_status.master_switch_no_circle_delay = bool end
                    function callback.master_switch_open_doors(bool) global.ui_status.master_switch_open_doors = bool end
                    function callback.disable_military_turrets(bool) global.ui_status.disable_military_turrets = bool end
                    function callback.disable_smoke_grenade_effect(bool) global.ui_status.disable_smoke_grenade_effect = bool end
                    function callback.open_security_cameras()
                        if global._loaded then        
                            local client = global.registry.client
                            for i,v in next, client.modules.ui.CircleAction.Specs do
                                if v.Name == "Open Security Cameras" then
                                    v:Callback(true)
                                    break
                                end
                            end 
                        end
                    end
                    function callback.rainbowbullets(bool) global.ui_status.rainbowbullets = bool end
                    function callback.disable_anti_flight_zones(bool) global.ui_status.disable_anti_flight_zones = bool end
                    function callback.infinite_jetpack_fuel(bool) global.ui_status.infinite_jetpack_fuel = bool end
                    function callback.break_vehicles(bool) global.ui_status.break_vehicles = bool end
                    function callback.master_switch_eject_aura(bool) global.ui_status.master_switch_eject_aura = bool end
                    function callback.range_ejectaura(num) global.ui_status.range_ejectaura = num end
                    function callback.master_switch_tase_aura(bool) global.ui_status.master_switch_tase_aura = bool end
                    function callback.master_switch_breakout_aura(bool) global.ui_status.master_switch_breakout_aura = bool end
                    function callback.range_breakoutaura(num) global.ui_status.range_breakoutaura = num end
                    function callback.disable_home_turrets(bool) global.ui_status.disable_home_turrets = bool end
                    function callback.open_secretbases(bool) global.ui_status.open_secretbases = bool end
                    function callback.wrap_value(value) global.ui_status.wrap_value = value end
                    function callback.apply_wrap()
                        if global._loaded then
                            local applyWrap = global.registry.applyWrap
                            if applyWrap then applyWrap(global.ui_status.wrap_value) end
                        end
                    end
                    function callback.playsounds(tip)
                        local registry = global.registry
                        local client = registry and registry.client
                        local playsounds = registry and registry.playSounds
                        if type(playsounds) ~= "function" or not (client and client.playerCharacter) then return end
                        playsounds(tip, {
                            Source = client.playerCharacter;
                            MaxTime = 7;
                            Volume = math.huge;
                        })
                    end
                    function callback.annoyserver(bool) global.ui_status.annoyserver = bool end
                    function callback.clicklightning(bool) global.ui_status.clicklightning = bool end
                    function callback.only_on_weapon_equipped(bool) global.ui_status.only_on_weapon_equipped = bool end
                    function callback.instant_break(bool) global.ui_status.instant_break = bool end
                    function callback.target_enemy_team_only(bool) global.ui_status.target_enemy_team_only = bool end
                    function callback.disable_automatic_unparachute(bool) global.ui_status.disable_automatic_unparachute = bool end
                    function callback.clicknuke(bool) global.ui_status.clicknuke = bool end
                    function callback.disable_minimap_flash(bool) global.ui_status.disable_minimap_flash = bool end
                    function callback.pit_aura(bool) global.ui_status.pit_aura = bool end
                    function callback.pit_aura_range(num) global.ui_status.pit_aura_range = num end
                    function callback.auto_accept_battle(bool) global.ui_status.auto_accept_battle = bool end
                    function callback.auto_start_matchmaking(bool) global.ui_status.auto_start_matchmaking = bool end
                    function callback.open_all_safes(bool) global.ui_status.open_all_safes = bool end
                    function callback.c4dick_masterswitch(bool) global.ui_status.c4dick_masterswitch = bool end
                    function callback.dick_player(key)
                        if not tostring(key or ""):find("%S") then return end

                        if global._loaded then
                            local dick_player = global.registry.dick_player
                            if dick_player then dick_player(key) end
                        end
                    end
                    function callback.spawn_dick()
                        if global._loaded then
                            local dick_player = global.registry.dick_player
                            if dick_player then dick_player(players.LocalPlayer.Name) end
                        end
                    end
                    function callback.disable_fireworks(bool) global.ui_status.disable_fireworks = bool end
                    function callback.always_reequip_c4(bool) global.ui_status.always_reequip_c4 = bool end
                    function callback.disable_spotlight_tracking(bool) global.ui_status.disable_spotlight_tracking = bool end
                    function callback.override_length(bool) global.ui_status.override_length = bool end
                    function callback.dick_length(num) global.ui_status.dick_length = num end
                    function callback.chatspy(bool) global.ui_status.chatspy = bool end
                    local always_keycard = toggle("Misc", "Always Keycard", callback.always_keycard)
                    local master_switch_open_doors = toggle("Misc", "Open Nearby Doors", callback.master_switch_open_doors)
                    local master_switch_no_circle_delay = toggle("Misc", "No Circle Delay", callback.master_switch_no_circle_delay)
                    local rainbowbullets = toggle("Misc", "Colorful Bullets", callback.rainbowbullets)
                    do
                        local function soundOptionsFor(folder)
                            local data = global.getSoundAssets and global.getSoundAssets(folder) or {names = {}}
                            local options = {}
                            for _, name in ipairs(data.names) do options[#options + 1] = name end
                            if #options == 0 then options = {"none"} end
                            return options
                        end
                        local bulletOptions = soundOptionsFor("bullet sounds")
                        local hitOptions = soundOptionsFor("hit sounds")
                        local gunCategories = {"pistol", "shotgun", "sniper", "rifle", "smg", "revolver", "flintlock"}
                        local local_bullet_sound = optionToggle("Misc", "Custom Bullet Sound", "local_bullet_sound", nil, false)
                        -- per-category bullet sounds: each gun category keeps its own sound,
                        -- persisted to file so the choice survives rejoins. The "Bullet Sound"
                        -- dropdown is a view of the currently-selected category's sound.
                        global.bullet_sound_map = global.bullet_sound_map or {}
                        -- file read is deferred to feature init: the UI is built before
                        -- global.functions exists, so reading it here crashes loadup
                        global.loadBulletSoundMap = function()
                            local fns = global.functions
                            if not fns then return end
                            local readfile, isfile = fns.readfile, fns.isfile
                            if type(isfile) == "function" and type(readfile) == "function" and isfile("crewbattler/bullet_sounds.json") then
                                local ok, data = pcall(function() return httpservice:JSONDecode(readfile("crewbattler/bullet_sounds.json")) end)
                                if ok and type(data) == "table" then global.bullet_sound_map = data end
                            end
                        end
                        local function saveBulletSoundMap()
                            local fns = global.functions
                            local writefile = fns and fns.writefile
                            if type(writefile) == "function" then
                                pcall(function() writefile("crewbattler/bullet_sounds.json", httpservice:JSONEncode(global.bullet_sound_map)) end)
                            end
                        end
                        local applyingCategory = false
                        local bulletValueControl
                        local function currentCategory()
                            local cat = global.ui_status.bullet_sound_category
                            if type(cat) == "table" then cat = cat[1] end
                            return cat or "pistol"
                        end
                        callback.bullet_sound_category = function(value)
                            if type(value) == "table" then value = value[1] end
                            global.ui_status.bullet_sound_category = value
                            -- reflect this category's stored sound in the value dropdown
                            applyingCategory = true
                            local stored = global.bullet_sound_map[value or "pistol"]
                            if bulletValueControl and type(bulletValueControl.Set) == "function" then
                                pcall(bulletValueControl.Set, stored or "none")
                            end
                            applyingCategory = false
                        end
                        callback.bullet_sound_value = function(value)
                            if type(value) == "table" then value = value[1] end
                            global.ui_status.bullet_sound_value = value
                            -- only a real user change should write the map; ignore the
                            -- callbacks fired during UI build / config load / category sync
                            if applyingCategory or not global.bulletSoundReady then return end
                            global.bullet_sound_map[currentCategory()] = value
                            saveBulletSoundMap()
                        end
                        global.syncBulletSoundView = function()
                            if callback.bullet_sound_category then callback.bullet_sound_category(currentCategory()) end
                            global.bulletSoundReady = true
                        end
                        local categoryControl = dropdown("Misc", "Gun Category", gunCategories, callback.bullet_sound_category, "pistol")
                        controls.bullet_sound_category = categoryControl
                        addChild(local_bullet_sound, categoryControl)
                        bulletValueControl = dropdown("Misc", "Bullet Sound", bulletOptions, callback.bullet_sound_value, bulletOptions[1])
                        controls.bullet_sound_value = bulletValueControl
                        addChild(local_bullet_sound, bulletValueControl)
                        -- the per-category map (file) owns the bullet sound value, so keep the
                        -- library config from saving/restoring this single dropdown and clobbering it
                        if global.ui.registerFlagControl and bulletValueControl.Flag then
                            global.ui.registerFlagControl(bulletValueControl.Flag, bulletValueControl, false)
                        end
                        optionSlider("Misc", "Bullet Sound Volume", 0, 300, "bullet_sound_volume", 100, local_bullet_sound, "%")
                        local hit_sound = optionToggle("Misc", "Hit Sound", "hit_sound", nil, false)
                        optionDropdown("Misc", "Hit Sound", hitOptions, "hit_sound_value", hitOptions[1], hit_sound)
                        optionSlider("Misc", "Hit Sound Volume", 0, 500, "hit_sound_volume", 100, hit_sound, "%")
                    end
                    local infinite_jetpack_fuel = toggle("Misc", "Infinite Jetpack Fuel", callback.infinite_jetpack_fuel)
                    local unlock_customizations = optionToggle("Misc", "Unlock All Customizations", "unlock_customizations", nil, false)
                    local wrap_value = dropdown("Misc", "Vehicle Wrap", {"none"}, callback.wrap_value, "none")
                    controls.wrap_value = wrap_value
                    button("Misc", "Apply Wrap To Vehicle", callback.apply_wrap)
                    local never_unload_world = toggle("Misc", "Never Unload World", callback.never_unload_world)
                    local open_secretbases = toggle("Misc", "Open Secretbases", callback.open_secretbases)
                    local auto_accept_battle = toggle("Misc", "Automatic Accept Battle", callback.auto_accept_battle)
                    local auto_start_matchmaking = toggle("Misc", "Automatic Start Matchmaking", callback.auto_start_matchmaking)
                    local clicklightning = toggle("Misc", "Click Lightning", callback.clicklightning)
                    local clicknuke = toggle("Misc", "Click Nuke", callback.clicknuke)
                    local chatspy = toggle("Misc", "Chat Spy", callback.chatspy)
                    local open_security_cameras = button("Misc", "Open Security Cameras", callback.open_security_cameras)
                    local remove_clothing = button("Misc", "Remove Clothing", callback.remove_clothing)
                    local give_police_clothing = button("Misc", "Give Police Clothing", callback.give_police_clothing)
                    local give_police_hat = button("Misc", "Give Police Hat", callback.give_police_hat)
                    local break_vehicles = toggle("BreakVehicles", "Break Nearby Vehicles", callback.break_vehicles, true)
                    local only_on_weapon_equipped = toggle("BreakVehicles", "Only On Weapon Equipped", callback.only_on_weapon_equipped)
                    local instant_break = toggle("BreakVehicles", "Instant Break", callback.instant_break)
                    local target_enemy_team_only = toggle("BreakVehicles", "Ignore Teammates", callback.target_enemy_team_only)
                    break_vehicles.setChild(only_on_weapon_equipped)
                    break_vehicles.setChild(instant_break)
                    break_vehicles.setChild(target_enemy_team_only)
                    local pickpocketaura = toggle("Auras", "Pickpocket Aura", callback.pickpocketaura, true)
                    local range_pickpocketaura = slider("Auras", "Range", 1, 50, callback.range_pickpocketaura)
                    pickpocketaura.setChild(range_pickpocketaura)
                    local master_switch_eject_aura = toggle("Auras", "Eject Aura", callback.master_switch_eject_aura, true)
                    local range_ejectaura = slider("Auras", "Range", 1, 80, callback.range_ejectaura)
                    master_switch_eject_aura.setChild(range_ejectaura)
                    local master_switch_breakout_aura = toggle("Auras", "Breakout Aura", callback.master_switch_breakout_aura, true)
                    local range_breakoutaura = slider("Auras", "Range", 1, 20, callback.range_breakoutaura)
                    master_switch_breakout_aura.setChild(range_breakoutaura)
                    local pit_aura = toggle("Auras", "Pit Aura", callback.pit_aura, true)
                    local pit_aura_range = slider("Auras", "Range", 10, 100, callback.pit_aura_range)
                    pit_aura.setChild(pit_aura_range)
                    local droppedcashaura = toggle("Auras", "Dropped Cash Aura", callback.droppedcashaura, true)
                    local droppedcashrange = slider("Auras", "Range", 1, 25, callback.droppedcashrange)
                    droppedcashaura.setChild(droppedcashrange)
                    local playsounds = dropdown("PlaySounds", "Sounds", {}, callback.playsounds)
                    local annoyserver = toggle("PlaySounds", "Annoy Server", callback.annoyserver)
                    function callback.rocket_trail(bool) global.ui_status.rocket_trail = bool end
                    function callback.spawn_rocket()
                        if global._loaded then global.registry.spawn_rocket(players.LocalPlayer.Name) end
                    end
                    function callback.spawn_rocket_on(name)
                        if not tostring(name or ""):find("%S") then return end

                        if global._loaded then global.registry.spawn_rocket(name) end
                    end
                    function callback.rocket_explosion(bool) global.ui_status.rocket_explosion = bool end
                    function callback.spawn_explosion()
                        if global._loaded then global.registry.spawn_rocket(players.LocalPlayer.Name, true) end
                    end
                    function callback.spawn_explosion_on(name)
                        if not tostring(name or ""):find("%S") then return end

                        if global._loaded then global.registry.spawn_rocket(name, true) end
                    end
                    function callback.explosion_size(num) global.ui_status.explosion_size = num end
                    local rocket_trail = toggle("RocketFun", "Rocket Trail", callback.rocket_trail, true)
                    local spawn_rocket = button("RocketFun", "Spawn Rocket", callback.spawn_rocket)
                    local spawn_rocket_on = textbox("RocketFun", "Spawn Rocket On", "Player Name", callback.spawn_rocket_on, {Save = false})
                    rocket_trail.setChild(spawn_rocket)
                    rocket_trail.setChild(spawn_rocket_on)
                    local rocket_explosion = toggle("RocketFun", "Rocket Explosion", callback.rocket_explosion, true)
                    local spawn_explosion = button("RocketFun", "Spawn Explosion", callback.spawn_explosion)
                    local spawn_explosion_on = textbox("RocketFun", "Spawn Explosion On", "Player Name", callback.spawn_explosion_on, {Save = false})
                    local explosion_size = slider("RocketFun", "Explosion Size", 1, 100, callback.explosion_size)
                    rocket_explosion.setChild(spawn_explosion)
                    rocket_explosion.setChild(spawn_explosion_on)
                    rocket_explosion.setChild(explosion_size)
                    controls.rocket_explosion = rocket_explosion
                    controls.rocket_trail = rocket_trail
                    controls.spawn_rocket = spawn_rocket
                    controls.extend_duration = extend_duration
                    controls.explosion_size = explosion_size
                    function callback.bomb_vest(bool) global.ui_status.bomb_vest = bool end
                    function callback.spawn_vest()   end
                    function callback.spawn_vest_player()
                    end
                    function callback.ammo_purchase_limit(num) global.ui_status.ammo_purchase_limit = num end
                    local c4dick_masterswitch = toggle("C4Fun", "C4 Dick", callback.c4dick_masterswitch, true)
                    local spawn_dick = button("C4Fun", "Spawn Dick", callback.spawn_dick)
                    local override_length = toggle("C4Fun", "Override Length", callback.override_length, true)
                    local dick_length = slider("C4Fun", "Dick Length", 1, 6, callback.dick_length)
                    local dick_player = textbox("C4Fun", "Spawn Dick On", "Player Name", callback.dick_player, {Save = false})
                    local spawn_vest = button("C4Fun", "Spawn Vest", callback.spawn_vest)
                    local spawn_vest_player = textbox("C4Fun", "Spawn Vest On", "Player Name", callback.spawn_vest_player, {Save = false})
                    local ammo_purchase_limit = slider("C4Fun", "Ammo Purchase Limit", 1, 10, callback.ammo_purchase_limit)
                    c4dick_masterswitch.setChild(spawn_dick)
                    c4dick_masterswitch.setChild(dick_player)
                    c4dick_masterswitch.setChild(override_length)
                    override_length.setChild(dick_length)
                    controls.override_length = override_length
                    controls.dick_length = dick_length
                    controls.dick_player = dick_player
                    function callback.disable_radio_keybind(bool) global.ui_status.disable_radio_keybind = bool end
                    local disable_lasers = toggle("Disablers", "Disable Lasers", callback.disable_lasers)
                    local disable_cameras = toggle("Disablers", "Disable Cameras", callback.disable_cameras)
                    local disable_radio_keybind = toggle("Disablers", "Disable Radio Keybind", callback.disable_radio_keybind)
                    local disable_spotlight_tracking = toggle("Disablers", "Disable Spotlight Tracking", callback.disable_spotlight_tracking)
                    local disable_minimap_flash = toggle("Disablers", "Disable Minimap Flash", callback.disable_minimap_flash)
                    local disable_automatic_unparachute = toggle("Disablers", "Disable Automatic Unparachute", callback.disable_automatic_unparachute)
                    local disable_military_turrets = toggle("Disablers", "Disable Military Turrets", callback.disable_military_turrets)
                    local disable_home_turrets = toggle("Disablers", "Disable Home Turrets", callback.disable_home_turrets)
                    local disable_smoke_grenade_effect = toggle("Disablers", "Disable Smoke Grenade Effect", callback.disable_smoke_grenade_effect)
                    controls.disable_radio_keybind = disable_radio_keybind
                    controls.c4dick_masterswitch = c4dick_masterswitch
                    controls.disable_spotlight_tracking = disable_spotlight_tracking
                    controls.always_reequip_c4 = always_reequip_c4
                    controls.clicklightning = clicklightning
                    controls.pit_aura = pit_aura
                    controls.pit_aura_range = pit_aura_range
                    controls.disable_minimap_flash = disable_minimap_flash
                    controls.clicknuke = clicknuke
                    controls.auto_accept_battle = auto_accept_battle
                    controls.auto_start_matchmaking = auto_start_matchmaking
                    controls.only_on_weapon_equipped = only_on_weapon_equipped
                    controls.instant_break = instant_break
                    controls.target_enemy_team_only = target_enemy_team_only
                    controls.chatspy = chatspy
                    controls.playsounds = playsounds
                    controls.always_keycard = always_keycard
                    controls.annoyserver = annoyserver
                    controls.master_switch_open_doors = master_switch_open_doors
                    controls.disable_automatic_unparachute = disable_automatic_unparachute
                    controls.break_vehicles = break_vehicles
                    controls.no_equip_conditions = no_equip_conditions
                    controls.master_switch_no_circle_delay = master_switch_no_circle_delay
                    controls.never_unload_world = never_unload_world
                    controls.rainbowbullets = rainbowbullets
                    controls.infinite_jetpack_fuel = infinite_jetpack_fuel
                    controls.pickpocketaura = pickpocketaura
                    controls.master_switch_breakout_aura = master_switch_breakout_aura
                    controls.range_breakoutaura = range_breakoutaura
                    controls.open_secretbases = open_secretbases
                    controls.range_pickpocketaura = range_pickpocketaura
                    controls.master_switch_eject_aura = master_switch_eject_aura
                    controls.range_ejectaura = range_ejectaura
                    controls.droppedcashaura = droppedcashaura
                    controls.droppedcashrange = droppedcashrange
                    controls.disable_lasers = disable_lasers
                    controls.disable_cameras = disable_cameras
                    controls.disable_home_turrets = disable_home_turrets
                    controls.disable_military_turrets = disable_military_turrets
                    controls.disable_smoke_grenade_effect = disable_smoke_grenade_effect
                end
                local function combat()
                    function callback.open_gunstore_ui(bool) global.ui_status.open_gunstore_ui = bool end
                    function callback.equip_owned_guns()
                        local isProjectile = global.registry.isProjectile
                        if global._loaded then
                            local client = global.registry.client
                            local equipOwnedItem = global.registry.equipOwnedItem
                            if equipOwnedItem then
                                for i,v in next, client.reg.resolveOwnedItems do
                                    if not isProjectile(v) then equipOwnedItem(v) end
                                end
                            end
                        end
                    end
                    function callback.always_equip_owned_guns(bool) global.ui_status.always_equip_owned_guns = bool end
                    function callback.spam_drop_guns(bool) global.ui_status.spam_drop_guns = bool end
                    function callback.automatic_fire(bool) global.ui_status.automatic_fire = bool end
                    function callback.no_recoil(bool) global.ui_status.no_recoil = bool end
                    function callback.master_switch_silentaim(bool) global.ui_status.master_switch_silentaim = bool end
                    function callback.target_closest_crosshair(bool) global.ui_status.target_closest_crosshair = bool end
                    function callback.always_predict(bool) global.ui_status.always_predict = bool end
                    function callback.master_switch_arrestaura(bool) global.ui_status.master_switch_arrestaura = bool end
                    function callback.range_arrestaura(num) global.ui_status.range_arrestaura = num end
                    function callback.allow_target_prisoner(bool) global.ui_status.allow_target_prisoner = bool end
                    function callback.fov_silentaim(num) global.ui_status.fov_silentaim = num end
                    function callback.force_hit(bool) global.ui_status.force_hit = bool end
                    function callback.force_hit_headshot(bool) global.ui_status.force_hit_headshot = bool end
                    function callback.force_hit_aimspoof(bool) global.ui_status.force_hit_aimspoof = bool end
                    function callback.force_hit_single(bool) global.ui_status.force_hit_single = bool end
                    function callback.fov_circle(bool) global.ui_status.fov_circle = bool end
                    function callback.automatic_equip_handcuffs(bool) global.ui_status.automatic_equip_handcuffs = bool end
                    function callback.automatic_eject_player(bool) global.ui_status.automatic_eject_player = bool end
                    function callback.talk_on_arrest(bool) global.ui_status.talk_on_arrest = bool end
                    function callback.no_wall_penetration(bool) global.ui_status.no_wall_penetration = bool end
                    function callback.allow_target_npcs(bool) global.ui_status.allow_target_npcs = bool end
                    function callback.allow_tase_target(bool) global.ui_status.allow_tase_target = bool end
                    function callback.through_walls(bool) global.ui_status.through_walls = bool end
                    function callback.anti_flintlock_knockback(bool) global.ui_status.anti_flintlock_knockback = bool end
                    function callback.allow_target_boss(bool) global.ui_status.allow_target_boss = bool end
                    function callback.always_target_boss_head(bool) global.ui_status.always_target_boss_head = bool end
                    function callback.instant_reload(bool) global.ui_status.instant_reload = bool end
                    function callback.anti_scope_ui(bool) global.ui_status.anti_scope_ui = bool end
                    function callback.allow_taser_aimbot(bool) global.ui_status.allow_taser_aimbot = bool end
                    function callback.ignore_while_driving(bool) global.ui_status.ignore_while_driving = bool end
                    function callback.automatic_fix_robbery_bag(bool) global.ui_status.automatic_fix_robbery_bag = bool end
                    function callback.instant_seek(bool) global.ui_status.instant_seek = bool end
                    function callback.equip_guns(value)
                        if global._loaded then
                            local client = global.registry.client
                            local equipOwnedItem = global.registry.equipOwnedItem
                            if equipOwnedItem then
                                if not table.find(client.reg.resolveEquippedItems, value) then equipOwnedItem(value) end
                            end
                        end
                    end
                    function callback.extended_aimbot_range(bool) global.ui_status.extended_aimbot_range = bool end
                    function callback.range_taseaura(num) global.ui_status.range_taseaura = num end
                    function callback.wallbang(bool) global.ui_status.wallbang = bool end
                    function callback.move_camera_killall(bool) global.ui_status.move_camera_killall = bool end
                    function callback.ignoreteam_killall(bool) global.ui_status.ignoreteam_killall = bool end
                    function callback.max_distance(num) global.ui_status.max_distance = num end
                    function callback.automatic_shoot(bool) global.ui_status.automatic_shoot = bool end
                    function callback.no_spread(bool) global.ui_status.no_spread = bool end
                    function callback.kill_player(name)
                        if not tostring(name or ""):find("%S") then return end

                        if global._loaded then global.registry.kill_player(name) end
                    end
                    function callback.anti_smoke_throw_limit(bool) global.ui_status.anti_smoke_throw_limit = bool end
                    function callback.quickfire(bool) global.ui_status.quickfire = bool end
                    function callback.kill_all_in_vehicle(bool) global.ui_status.kill_all_in_vehicle = bool end
                    function callback.teleport_locations(key)
                        if global._loaded then global.teleports.setLocation(key) end
                    end
                    local automatic_fire = toggle("Gunmods", "Automatic Fire", callback.automatic_fire)
                    local no_recoil = toggle("Gunmods", "No Recoil", callback.no_recoil)
                    local no_spread = toggle("Gunmods", "No Spread", callback.no_spread)
                    local wallbang = toggle("Gunmods", "Wallbang", callback.wallbang)
                    local rapid_fire = optionToggle("Gunmods", "Rapid Fire", "rapid_fire", nil, false)
                    optionSlider("Gunmods", "Rapid Fire Rate", 1, 20, "rapid_fire_multiplier", 3, rapid_fire, "x")
                    local instant_reload = toggle("Gunmods", "Instant Reload", callback.instant_reload)
                    local instant_seek = toggle("Gunmods", "Instant Seek", callback.instant_seek)
                    local quickfire = toggle("GunmodsMisc", "Quick Fire", callback.quickfire)
                    local quickfire_key = attachedKeybind(quickfire, "Quick Fire Key", "quickfire_key", Enum.UserInputType.MouseButton1, function(pressed)
                        global.inputs = global.inputs or {}
                        global.inputs.mouse1 = pressed == true
                    end, "Hold")
                    local anti_flintlock_knockback = toggle("GunmodsMisc", "Anti Knockback", callback.anti_flintlock_knockback)
                    local swat_pistol = optionToggle("GunmodsMisc", "Free SWAT Pistol", "swat_pistol", nil, false)
                    local hit_notifications = optionToggle("GunmodsMisc", "Hit Notifications", "hit_notifications", nil, false)
                    local anti_smoke_throw_limit = toggle("GunmodsMisc", "Anti Smoke Throw Limit", callback.anti_smoke_throw_limit)
                    local anti_scope_ui = toggle("GunmodsMisc", "Anti Scope UI", callback.anti_scope_ui)
                    local sniper_no_zoom = optionToggle("GunmodsMisc", "No Sniper Zoom", "sniper_no_zoom", nil, false)
                    local extend_range = optionToggle("GunmodsMisc", "Extend Weapon Range", "extend_range", nil, false)
                    optionSlider("GunmodsMisc", "Range Multiplier", 1, 20, "extend_range_mult", 3, extend_range, "x")
                    controls.quickfire = quickfire
                    controls.quickfire_key = quickfire_key
                    local open_gunstore_ui = toggle("Gunstore", "Open Gunstore UI", callback.open_gunstore_ui)
                    local equip_owned_guns = button("Gunstore", "Equip Owned Guns", callback.equip_owned_guns)
                    local equip_guns = dropdown("Gunstore", "Equip Guns", {}, callback.equip_guns)
                    local always_equip_owned_guns = toggle("Gunstore", "Always Equip Owned Guns", callback.always_equip_owned_guns)
                    local spam_drop_guns = toggle("Gunstore", "Spam Drop Items", callback.spam_drop_guns, true)
                    function callback.kill_all_in_vehicle(bool) global.ui_status.kill_all_in_vehicle = bool end
                    function callback.kill_all_vehicle_ignore_teammates(bool) global.ui_status.kill_all_vehicle_ignore_teammates = bool end
                    local kill_player = textbox("BreakExperience", "Attempt Kill Player", "Player Name", callback.kill_player, {Save = false})
                    function callback.teleport_player(name)
                        if not tostring(name or ""):find("%S") then return end

                        if global._loaded then global.teleports.teleport_player(name) end
                    end
                    function callback.force_target(name)
                        if not tostring(name or ""):find("%S") then return end

                        if global._loaded then
                            if global.aimbot then global.aimbot.setTarget(name) end
                        end
                    end
                    function callback.killaura_masterswitch(bool) global.ui_status.killaura_masterswitch = bool end
                    function callback.killaura_range(num) global.ui_status.killaura_range = num end
                    local teleport_locations = dropdown("BreakExperience", "Teleport Locations", {"Casino", "Diamonds", "Lava", "Bossroom", "Powerplant", "Bank", "Computer", "Museum", "Jewelry"}, callback.teleport_locations)
                    local teleport_current_location = label("BreakExperience", "SELECTED_LOCATION", Color3.fromRGB(200, 200, 200))
                    local teleport_player = textbox("BreakExperience", "Teleport Player", "Player Name", callback.teleport_player, {Save = false})
                    local kill_all_in_vehicle = toggle("BreakExperience", "Kill All In Vehicle", callback.kill_all_in_vehicle, true)
                    local kill_all_vehicle_ignore_teammates = toggle("BreakExperience", "Ignore Teammates", callback.kill_all_vehicle_ignore_teammates)
                    controls.kill_all_vehicle_ignore_teammates = kill_all_vehicle_ignore_teammates
                    kill_all_in_vehicle.setChild(kill_all_vehicle_ignore_teammates)
                    local killaura_masterswitch = toggle("Killaura", "Kill Aura", callback.killaura_masterswitch, true)
                    local killaura_range = slider("Killaura", "Range", 50, 100, callback.killaura_range)
                    killaura_masterswitch.setChild(killaura_range)
                    controls.killaura_masterswitch = killaura_masterswitch
                    controls.killaura_range = killaura_range
                    local master_switch_silentaim = toggle("Silentaim", "Silent Aim", callback.master_switch_silentaim, true)
                    local fov_silentaim = slider("Silentaim", "FOV", 1, 600, callback.fov_silentaim)
                    local max_distance = slider("Silentaim", "Max Distance", 500, 5000, callback.max_distance)
                    local force_target = textbox("Silentaim", "Force Target", "Player Name", callback.force_target, {Save = false, LoadCallback = false})
                    local selected_target = label("Silentaim", "FORCED_TARGET_NAME", Color3.fromRGB(200, 200, 200))
                    master_switch_silentaim.setChild(force_target)
                    master_switch_silentaim.setChild(selected_target)
                    local automatic_shoot = toggle("Silentaim", "Automatic Shoot", callback.automatic_shoot)
                    local force_hit = toggle("Silentaim", "Force Hit (forge)", callback.force_hit, true)
                    local force_hit_headshot = toggle("Silentaim", "Force Hit Headshot", callback.force_hit_headshot, false, true)
                    local force_hit_aimspoof = toggle("Silentaim", "Force Hit Aim Spoof", callback.force_hit_aimspoof, false, true)
                    local force_hit_single = toggle("Silentaim", "Force Hit 1:1 (drop real)", callback.force_hit_single, false, false)
                    force_hit.setChild(force_hit_headshot)
                    force_hit.setChild(force_hit_aimspoof)
                    force_hit.setChild(force_hit_single)
                    local fov_circle = toggle("SilentaimFov", "FOV Circle", callback.fov_circle)
                    local fov_circle_mode = optionDropdown("SilentaimFov", "FOV Circle Mode", circleModes, "fov_circle_mode", "mouse", fov_circle)
                    local fov_circle_follow_target = optionToggle("SilentaimFov", "FOV Follow Target", "fov_circle_follow_target", fov_circle, false)
                    local fov_circle_position = optionDropdown("SilentaimFov", "FOV Circle Position", circlePositionSources, "fov_circle_position", "Silent Aim Target", fov_circle_follow_target)
                    local fov_circle_custom_hide_offscreen = optionToggle("SilentaimFov", "FOV Hide Offscreen", "fov_circle_custom_hide_offscreen", fov_circle, true)
                    -- FOV circle radius is linked to the silent-aim FOV size (no separate slider)
                    local fov_circle_thickness = optionSlider("SilentaimFov", "FOV Thickness", 1, 10, "fov_circle_thickness", 2.5, fov_circle)
                    local fov_circle_opacity = optionSlider("SilentaimFov", "FOV Opacity", 0, 1, "fov_circle_opacity", 1, fov_circle)
                    optionColor(fov_circle, "fov_circle_color", "FOV Color", Color3.fromRGB(66, 84, 245))
                    local fov_circle_filled = optionToggle("SilentaimFov", "FOV Filled", "fov_circle_filled", fov_circle, true)
                    optionColor(fov_circle, "fov_circle_fill_color", "FOV Fill Color", Color3.fromRGB(66, 84, 245))
                    local fov_circle_fill_opacity = optionSlider("SilentaimFov", "FOV Fill Opacity", 0, 1, "fov_circle_fill_opacity", 0.25, fov_circle)
                    local fov_circle_gradient_circle_filled = optionToggle("SilentaimFov", "FOV Fill Gradient", "fov_circle_gradient_circle_filled", fov_circle, true)
                    optionColor(fov_circle, "fov_circle_gradient_circle_filled_rgb1", "FOV Fill Gradient 1", Color3.fromRGB(255, 255, 255))
                    optionColor(fov_circle, "fov_circle_gradient_circle_filled_rgb2", "FOV Fill Gradient 2", Color3.fromRGB(0, 0, 0))
                    local fov_circle_gradient_circle_filled_animate = optionToggle("SilentaimFov", "FOV Fill Gradient Animate", "fov_circle_gradient_circle_filled_animate", fov_circle, true)
                    local fov_circle_gradient_circle_filled_speed = optionSlider("SilentaimFov", "FOV Fill Gradient Speed", 0, 5, "fov_circle_gradient_circle_filled_speed", 0.75, fov_circle)
                    local fov_circle_gradient_circle_filled_rotation = optionSlider("SilentaimFov", "FOV Fill Gradient Rotation", 0, 360, "fov_circle_gradient_circle_filled_rotation", 90, fov_circle)
                    local fov_circle_outline = optionToggle("SilentaimFov", "FOV Outline", "fov_circle_outline", fov_circle, true)
                    optionColor(fov_circle, "fov_circle_outline_color", "FOV Outline Color", Color3.fromRGB(0, 0, 0))
                    local fov_circle_outline_thickness = optionSlider("SilentaimFov", "FOV Outline Thickness", 0, 10, "fov_circle_outline_thickness", 1.5, fov_circle)
                    local fov_circle_outline_gradient = optionToggle("SilentaimFov", "FOV Outline Gradient", "fov_circle_outline_gradient", fov_circle)
                    optionColor(fov_circle, "fov_circle_outline_gradient_rgb1", "FOV Outline Gradient 1", Color3.fromRGB(0, 0, 0))
                    optionColor(fov_circle, "fov_circle_outline_gradient_rgb2", "FOV Outline Gradient 2", Color3.fromRGB(0, 0, 0))
                    local fov_circle_outline_gradient_animate = optionToggle("SilentaimFov", "FOV Outline Gradient Animate", "fov_circle_outline_gradient_animate", fov_circle, true)
                    local fov_circle_outline_gradient_speed = optionSlider("SilentaimFov", "FOV Outline Gradient Speed", 0, 5, "fov_circle_outline_gradient_speed", 0.75, fov_circle)
                    local fov_circle_outline_gradient_rotation = optionSlider("SilentaimFov", "FOV Outline Gradient Rotation", 0, 360, "fov_circle_outline_gradient_rotation", 90, fov_circle)
                    local fov_circle_gradient_circle = optionToggle("SilentaimFov", "FOV Ring Gradient", "fov_circle_gradient_circle", fov_circle, true)
                    optionColor(fov_circle, "fov_circle_gradient_circle_rgb1", "FOV Ring Gradient 1", Color3.fromRGB(255, 255, 255))
                    -- (removed the redundant black "FOV Ring Gradient 2" swatch — ring gradient ends at its black default)
                    local fov_circle_gradient_circle_animate = optionToggle("SilentaimFov", "FOV Ring Gradient Animate", "fov_circle_gradient_circle_animate", fov_circle, true)
                    local fov_circle_gradient_circle_speed = optionSlider("SilentaimFov", "FOV Ring Gradient Speed", 0, 5, "fov_circle_gradient_circle_speed", 0.75, fov_circle)
                    local fov_circle_gradient_circle_rotation = optionSlider("SilentaimFov", "FOV Ring Gradient Rotation", 0, 360, "fov_circle_gradient_circle_rotation", 90, fov_circle)
                    local fov_circle_spin = optionToggle("SilentaimFov", "FOV Spin", "fov_circle_spin", fov_circle, true)
                    local fov_circle_spin_speed = optionSlider("SilentaimFov", "FOV Spin Speed", 0, 720, "fov_circle_spin_speed", 150, fov_circle)
                    local fov_circle_spin_max = optionSlider("SilentaimFov", "FOV Spin Max", 1, 720, "fov_circle_spin_max", 360, fov_circle)
                    local fov_circle_spin_style = optionDropdown("SilentaimFov", "FOV Spin Style", easingStyles, "fov_circle_spin_style", "Linear", fov_circle)
                    local always_predict = toggle("Silentaim", "Movement Prediction", callback.always_predict, true)
                    local extended_aimbot_range = toggle("Silentaim", "Extended Aimbot Range", callback.extended_aimbot_range)
                    local allow_taser_aimbot = toggle("Silentaim", "Allow Taser Aimbot", callback.allow_taser_aimbot)
                    local allow_target_prisoner = toggle("Silentaim", "Allow Target Prisoner", callback.allow_target_prisoner)
                    local allow_target_npcs = toggle("Silentaim", "Allow Target NPCs", callback.allow_target_npcs)
                    local allow_target_boss = toggle("Silentaim", "Allow Target Boss", callback.allow_target_boss, true)
                    local always_target_boss_head = toggle("Silentaim", "Head Only", callback.always_target_boss_head)
                    local no_wall_penetration = toggle("Silentaim", "No Wall Penetration", callback.no_wall_penetration)
                    local silentaim_include_plasma = optionToggle("Silentaim", "Include Plasma", "silentaim_include_plasma", master_switch_silentaim, false)
                    local target_hud = optionToggle("Silentaim", "Target HUD", "target_hud", nil, false)
                    master_switch_silentaim.setChild(fov_silentaim)
                    master_switch_silentaim.setChild(fov_circle)
                    master_switch_silentaim.setChild(always_predict)
                    master_switch_silentaim.setChild(automatic_shoot)
                    controls.automatic_shoot = automatic_shoot
                    controls.instant_seek = instant_seek
                    controls.kill_all_in_vehicle = kill_all_in_vehicle
                    controls.kill_all_vehicle_ignore_teammates = kill_all_vehicle_ignore_teammates
                    master_switch_silentaim.setChild(extended_aimbot_range)
                    master_switch_silentaim.setChild(max_distance)
                    master_switch_silentaim.setChild(allow_taser_aimbot)
                    master_switch_silentaim.setChild(allow_target_prisoner)
                    master_switch_silentaim.setChild(allow_target_npcs)
                    master_switch_silentaim.setChild(allow_target_boss)
                    allow_target_boss.setChild(always_target_boss_head)
                    master_switch_silentaim.setChild(no_wall_penetration)
                    local master_switch_arrestaura = toggle("Arrestaura", "Arrest Aura", callback.master_switch_arrestaura, true)
                    local range_arrestaura = slider("Arrestaura", "Range", 1, 20, callback.range_arrestaura)
                    local ignore_while_driving = toggle("Arrestaura", "Ignore while driving", callback.ignore_while_driving)
                    local automatic_equip_handcuffs = toggle("Arrestaura", "Automatic Equip Handcuffs", callback.automatic_equip_handcuffs)
                    local automatic_eject_player = toggle("Arrestaura", "Automatic Eject Player", callback.automatic_eject_player)
                    local allow_tase_target = toggle("Arrestaura", "Allow Tase Target", callback.allow_tase_target, true)
                    local through_walls = toggle("Arrestaura", "Allow Through Walls", callback.through_walls)
                    local talk_on_arrest = toggle("Arrestaura", "Talk on Arrest", callback.talk_on_arrest)
                    master_switch_arrestaura.setChild(range_arrestaura)
                    master_switch_arrestaura.setChild(automatic_equip_handcuffs)
                    master_switch_arrestaura.setChild(automatic_eject_player)
                    master_switch_arrestaura.setChild(allow_tase_target)
                    master_switch_arrestaura.setChild(ignore_while_driving)
                    master_switch_arrestaura.setChild(through_walls)
                    master_switch_arrestaura.setChild(talk_on_arrest)
                    controls.anti_scope_ui = anti_scope_ui
                    controls.allow_target_boss = allow_target_boss
                    controls.wallbang = wallbang
                    controls.instant_reload = instant_reload
                    controls.always_target_boss_head = always_target_boss_head
                    controls.automatic_fire = automatic_fire
                    controls.no_recoil = no_recoil
                    controls.no_spread = no_spread
                    controls.equip_guns = equip_guns
                    controls.ignoreteam_killall = ignoreteam_killall
                    controls.ignorevehicles_killall = ignorevehicles_killall
                    controls.max_distance = max_distance
                    controls.master_switch_silentaim = master_switch_silentaim
                    controls.fov_silentaim = fov_silentaim
                    controls.fov_circle = fov_circle
                    controls.move_camera_killall = move_camera_killall
                    controls.always_predict = always_predict
                    controls.extended_aimbot_range = extended_aimbot_range
                    controls.always_equip_owned_guns = always_equip_owned_guns
                    controls.spam_drop_guns = spam_drop_guns
                    controls.anti_smoke_throw_limit = anti_smoke_throw_limit
                    controls.allow_target_npcs = allow_target_npcs
                    controls.no_wall_penetration = no_wall_penetration
                    controls.allow_target_prisoner = allow_target_prisoner
                    controls.anti_flintlock_knockback = anti_flintlock_knockback
                    controls.master_switch_arrestaura = master_switch_arrestaura
                    controls.allow_taser_aimbot = allow_taser_aimbot
                    controls.range_arrestaura = range_arrestaura
                    controls.automatic_equip_handcuffs = automatic_equip_handcuffs
                    controls.allow_tase_target = allow_tase_target
                    controls.attempt_fling = attempt_fling
                    controls.through_walls = through_walls
                    controls.automatic_eject_player = automatic_eject_player
                    controls.talk_on_arrest = talk_on_arrest
                    controls.ignore_while_driving = ignore_while_driving
                end
                local function markers()
                    function callback.master_switch_marker(bool) global.ui_status.master_switch_marker = bool end
                    function callback.police_marker(bool) global.ui_status.allow_police_marker = bool end
                    function callback.criminal_marker(bool) global.ui_status.allow_criminal_marker = bool end
                    function callback.prisoner_marker(bool) global.ui_status.allow_prisoner_marker = bool end
                    function callback.airdrop_marker(bool) global.ui_status.allow_airdrop_marker = bool end
                    function callback.allow_football_marker(bool) global.ui_status.allow_football_marker = bool end
                    function callback.allow_hackable_computer_marker(bool) global.ui_status.allow_hackable_computer_marker = bool end
                    function callback.no_robberymarker_delay(bool) global.ui_status.no_robberymarker_delay = bool end
                    function callback.allow_npcs_marker(bool) global.ui_status.allow_npcs_marker = bool end
                    function callback.mark_bounty_criminals(bool) global.ui_status.mark_bounty_criminals = bool end
                    function callback.mark_forced_target(bool) global.ui_status.mark_forced_target = bool end
                    function callback.esp_enabled(bool) global.ui_status.esp_enabled = bool end
                    function callback.esp_team_check(bool) global.ui_status.esp_team_check = bool end
                    function callback.esp_friend_check(bool) global.ui_status.esp_friend_check = bool end
                    function callback.esp_names(bool) global.ui_status.esp_names = bool end
                    function callback.esp_distances(bool) global.ui_status.esp_distances = bool end
                    function callback.esp_boxes(bool) global.ui_status.esp_boxes = bool end
                    function callback.esp_healthbar(bool) global.ui_status.esp_healthbar = bool end
                    function callback.esp_chams(bool) global.ui_status.esp_chams = bool end
                    function callback.esp_weapons(bool) global.ui_status.esp_weapons = bool end
                    function callback.esp_gradient(bool) global.ui_status.esp_gradient = bool end
                    function callback.esp_max_distance(num) global.ui_status.esp_max_distance = num end
                    local master_switch_marker = toggle("Marker", "Markers", callback.master_switch_marker, true)
                    local allow_criminal_marker = toggle("Teams", "Allow Criminal Marker", callback.criminal_marker)
                    local allow_prisoner_marker = toggle("Teams", "Allow Prisoner Marker", callback.prisoner_marker)
                    local allow_police_marker = toggle("Teams", "Allow Police Marker", callback.police_marker)
                    local allow_airdrop_marker = toggle("Objects", "Allow Airdrop Marker", callback.airdrop_marker)
                    local allow_football_marker = toggle("Objects", "Allow Football Marker", callback.allow_football_marker)
                    local allow_npcs_marker = toggle("Objects", "Allow NPCs Marker", callback.allow_npcs_marker)
                    local no_robberymarker_delay = toggle("Settings", "No Robbery Marker Delay", callback.no_robberymarker_delay)
                    local mark_bounty_criminals = toggle("Settings", "Mark Bounty Criminals", callback.mark_bounty_criminals)
                    local mark_forced_target = toggle("Settings", "Mark Forced Target", callback.mark_forced_target)
                    local esp_enabled = toggle("ESP", "Enable ESP", callback.esp_enabled, false, true)
                    local esp_team_check = toggle("ESP", "Team Check", callback.esp_team_check)
                    local esp_friend_check = toggle("ESP", "Friend Check", callback.esp_friend_check)
                    local esp_names = toggle("ESP", "Names", callback.esp_names)
                    local esp_use_displayname = optionToggle("ESP", "Use Display Name", "esp_use_displayname", esp_names, false)
                    local esp_distances = toggle("ESP", "Distances", callback.esp_distances)
                    local esp_boxes = toggle("ESP", "Boxes", callback.esp_boxes)
                    local esp_healthbar = toggle("ESP", "Healthbar", callback.esp_healthbar)
                    local esp_chams = toggle("ESP", "Chams", callback.esp_chams)
                    local esp_weapons = toggle("ESP", "Weapons", callback.esp_weapons)
                    local esp_gradient = toggle("ESP", "Gradient", callback.esp_gradient)
                    local esp_max_distance = slider("ESP", "Max Distance", 500, 10000, callback.esp_max_distance)
                    local crosshair_enabled = optionToggle("Crosshair", "Crosshair", "crosshair_enabled", nil, false)
                    optionDropdown("Crosshair", "Mode", circleModes, "crosshair_mode", "mouse", crosshair_enabled)
                    local crosshair_follow_target = optionToggle("Crosshair", "Follow Target", "crosshair_follow_target", crosshair_enabled, false)
                    optionDropdown("Crosshair", "Custom Position", circlePositionSources, "crosshair_position", "Silent Aim Target", crosshair_follow_target)
                    optionToggle("Crosshair", "Hide Offscreen", "crosshair_custom_hide_offscreen", crosshair_enabled, true)
                    optionSlider("Crosshair", "Width", 1, 10, "crosshair_width", 2.5, crosshair_enabled)
                    optionSlider("Crosshair", "Length", 1, 40, "crosshair_length", 10, crosshair_enabled)
                    optionSlider("Crosshair", "Radius", 0, 100, "crosshair_radius", 11, crosshair_enabled)
                    optionColor(crosshair_enabled, "crosshair_color", "Color", Color3.fromRGB(66, 84, 245))
                    local crosshair_outline = optionToggle("Crosshair", "Outline", "crosshair_outline", crosshair_enabled, true)
                    optionColor(crosshair_outline, "crosshair_outline_color", "Outline Color", Color3.fromRGB(0, 0, 0))
                    local crosshair_outline_gradient = optionToggle("Crosshair", "Outline Gradient", "crosshair_outline_gradient", crosshair_outline, false)
                    optionColor(crosshair_outline_gradient, "crosshair_outline_gradient_rgb1", "Outline Gradient 1", Color3.fromRGB(0, 0, 0))
                    optionColor(crosshair_outline_gradient, "crosshair_outline_gradient_rgb2", "Outline Gradient 2", Color3.fromRGB(66, 84, 245))
                    optionToggle("Crosshair", "Outline Gradient Animate", "crosshair_outline_gradient_animate", crosshair_outline_gradient, true)
                    optionSlider("Crosshair", "Outline Gradient Speed", 0, 5, "crosshair_outline_gradient_speed", 0.75, crosshair_outline_gradient)
                    local crosshair_spin = optionToggle("Crosshair", "Spin", "crosshair_spin", crosshair_enabled, true)
                    optionSlider("Crosshair", "Spin Speed", 0, 720, "crosshair_spin_speed", 150, crosshair_spin)
                    optionSlider("Crosshair", "Spin Max", 1, 720, "crosshair_spin_max", 360, crosshair_spin)
                    optionDropdown("Crosshair", "Spin Style", easingStyles, "crosshair_spin_style", "Linear", crosshair_spin)
                    local crosshair_resize = optionToggle("Crosshair", "Resize", "crosshair_resize", crosshair_enabled, true)
                    optionSlider("Crosshair", "Resize Speed", 0, 720, "crosshair_resize_speed", 150, crosshair_resize)
                    optionSlider("Crosshair", "Resize Min", 0, 40, "crosshair_resize_min", 5, crosshair_resize)
                    optionSlider("Crosshair", "Resize Max", 1, 60, "crosshair_resize_max", 22, crosshair_resize)
                    local crosshair_gradient_lines = optionToggle("Crosshair", "Gradient Lines", "crosshair_gradient_lines", crosshair_enabled, true)
                    optionColor(crosshair_gradient_lines, "crosshair_gradient_lines_rgb1", "Line Gradient 1", Color3.fromRGB(255, 255, 255))
                    optionColor(crosshair_gradient_lines, "crosshair_gradient_lines_rgb2", "Line Gradient 2", Color3.fromRGB(66, 84, 245))
                    optionSlider("Crosshair", "Line Segments", 2, 64, "crosshair_gradient_lines_segments", 18, crosshair_gradient_lines)
                    optionToggle("Crosshair", "Line Gradient Animate", "crosshair_gradient_lines_animate", crosshair_gradient_lines, true)
                    optionSlider("Crosshair", "Line Gradient Speed", 0, 5, "crosshair_gradient_lines_speed", 0.75, crosshair_gradient_lines)
                    local crosshair_text = optionToggle("Crosshair", "Text", "crosshair_text", crosshair_enabled, true)
                    optionTextbox("Crosshair", "Text 1", "Text", "crosshair_text_1", crosshair_text, {Save = true, Default = "crewbattler"})
                    optionTextbox("Crosshair", "Text 2", "Text", "crosshair_text_2", crosshair_text, {Save = true, Default = ".club"})
                    optionSlider("Crosshair", "Text Size", 6, 40, "crosshair_text_size", 13, crosshair_text)
                    optionSlider("Crosshair", "Text Font", 0, 4, "crosshair_text_font", 2, crosshair_text)
                    optionColor(crosshair_text, "crosshair_text_color", "Text Color", Color3.fromRGB(255, 255, 255))
                    optionColor(crosshair_text, "crosshair_text_accent_color", "Text Accent", Color3.fromRGB(66, 84, 245))
                    local crosshair_text_outline = optionToggle("Crosshair", "Text Outline", "crosshair_text_outline", crosshair_text, true)
                    optionColor(crosshair_text_outline, "crosshair_text_outline_color", "Text Outline Color", Color3.fromRGB(0, 0, 0))
                    local crosshair_gradient_text = optionToggle("Crosshair", "Gradient Text", "crosshair_gradient_text", crosshair_text, true)
                    optionToggle("Crosshair", "Text Gradient Animate", "crosshair_gradient_text_animate", crosshair_gradient_text, true)
                    optionSlider("Crosshair", "Text Gradient Speed", 0, 5, "crosshair_gradient_text_speed", 1, crosshair_gradient_text)
                    optionColor(crosshair_gradient_text, "crosshair_gradient_text_rgb1", "Text Gradient 1", Color3.fromRGB(255, 255, 255))
                    optionColor(crosshair_gradient_text, "crosshair_gradient_text_rgb2", "Text Gradient 2", Color3.fromRGB(66, 84, 245))
                    local crosshair_gradient_text_1 = optionToggle("Crosshair", "Text 1 Gradient", "crosshair_gradient_text_1", crosshair_gradient_text, true)
                    optionSlider("Crosshair", "Text 1 From", 1, 32, "crosshair_gradient_text_1_from", 1, crosshair_gradient_text_1)
                    optionSlider("Crosshair", "Text 1 To", 0, 32, "crosshair_gradient_text_1_to", 0, crosshair_gradient_text_1)
                    optionColor(crosshair_gradient_text_1, "crosshair_gradient_text_1_rgb1", "Text 1 Gradient 1", Color3.fromRGB(255, 255, 255))
                    optionColor(crosshair_gradient_text_1, "crosshair_gradient_text_1_rgb2", "Text 1 Gradient 2", Color3.fromRGB(66, 84, 245))
                    local crosshair_gradient_text_2 = optionToggle("Crosshair", "Text 2 Gradient", "crosshair_gradient_text_2", crosshair_gradient_text, true)
                    optionSlider("Crosshair", "Text 2 From", 1, 32, "crosshair_gradient_text_2_from", 1, crosshair_gradient_text_2)
                    optionSlider("Crosshair", "Text 2 To", 0, 32, "crosshair_gradient_text_2_to", 0, crosshair_gradient_text_2)
                    optionColor(crosshair_gradient_text_2, "crosshair_gradient_text_2_rgb1", "Text 2 Gradient 1", Color3.fromRGB(255, 255, 255))
                    optionColor(crosshair_gradient_text_2, "crosshair_gradient_text_2_rgb2", "Text 2 Gradient 2", Color3.fromRGB(66, 84, 245))
                    local aura_effects = optionToggle("AuraEffects", "Aura Effects", "aura_effects_enabled", nil, false)
                    optionDropdown("AuraEffects", "Aura", auraOptions, "aura_effects_selected", "lightning", aura_effects)
                    optionColor(aura_effects, "aura_effects_color", "Aura Color", Color3.fromRGB(133, 220, 255))
                    optionToggle("AuraEffects", "Force Color", "aura_effects_force_color", aura_effects, true)
                    optionToggle("AuraEffects", "Load Asset Auras", "aura_effects_load_assets", aura_effects, true)
                    local tracerTypes = {"beam", "line"}
                    local tracerStyles = {"laser", "light", "flow"}
                    local bullet_tracers = optionToggle("BulletTracers", "Bullet Tracers (Local)", "bullet_tracers_enabled", nil, false)
                    optionDropdown("BulletTracers", "Type", tracerTypes, "bullet_tracers_type", "beam", bullet_tracers)
                    optionDropdown("BulletTracers", "Beam Style", tracerStyles, "bullet_tracers_style", "flow", bullet_tracers)
                    optionToggle("BulletTracers", "Rainbow", "bullet_tracers_rainbow", bullet_tracers, false)
                    optionColor(bullet_tracers, "bullet_tracers_color", "Color", Color3.fromRGB(255, 50, 50))
                    optionColor(bullet_tracers, "bullet_tracers_gradient_color", "Gradient Color", Color3.fromRGB(255, 150, 50))
                    optionColor(bullet_tracers, "bullet_tracers_outline_color", "Outline Color (line)", Color3.fromRGB(255, 255, 255))
                    optionSlider("BulletTracers", "Transparency", 0, 1, "bullet_tracers_transparency", 0, bullet_tracers)
                    optionSlider("BulletTracers", "Gradient Transparency", 0, 1, "bullet_tracers_gradient_transparency", 0.6, bullet_tracers)
                    optionSlider("BulletTracers", "Outline Transparency", 0, 1, "bullet_tracers_outline_transparency", 0.5, bullet_tracers)
                    optionSlider("BulletTracers", "Lifetime", 0, 2, "bullet_tracers_lifetime", 0.3, bullet_tracers)
                    optionSlider("BulletTracers", "Thickness", 1, 8, "bullet_tracers_thickness", 1, bullet_tracers)
                    optionSlider("BulletTracers", "Outline Thickness", 1, 10, "bullet_tracers_outline_thickness", 3, bullet_tracers)
                    local bullet_tracers_enemy = optionToggle("BulletTracers", "Bullet Tracers (Enemy)", "bullet_tracers_enemy_enabled", nil, false)
                    optionDropdown("BulletTracers", "Enemy Type", tracerTypes, "bullet_tracers_enemy_type", "beam", bullet_tracers_enemy)
                    optionDropdown("BulletTracers", "Enemy Beam Style", tracerStyles, "bullet_tracers_enemy_style", "light", bullet_tracers_enemy)
                    optionToggle("BulletTracers", "Enemy Rainbow", "bullet_tracers_enemy_rainbow", bullet_tracers_enemy, false)
                    optionColor(bullet_tracers_enemy, "bullet_tracers_enemy_color", "Enemy Color", Color3.fromRGB(50, 150, 255))
                    optionColor(bullet_tracers_enemy, "bullet_tracers_enemy_gradient_color", "Enemy Gradient Color", Color3.fromRGB(150, 50, 255))
                    optionColor(bullet_tracers_enemy, "bullet_tracers_enemy_outline_color", "Enemy Outline Color (line)", Color3.fromRGB(200, 200, 255))
                    optionSlider("BulletTracers", "Enemy Transparency", 0, 1, "bullet_tracers_enemy_transparency", 0, bullet_tracers_enemy)
                    optionSlider("BulletTracers", "Enemy Gradient Transparency", 0, 1, "bullet_tracers_enemy_gradient_transparency", 0.6, bullet_tracers_enemy)
                    optionSlider("BulletTracers", "Enemy Outline Transparency", 0, 1, "bullet_tracers_enemy_outline_transparency", 0.5, bullet_tracers_enemy)
                    optionSlider("BulletTracers", "Enemy Lifetime", 0, 2, "bullet_tracers_enemy_lifetime", 0.4, bullet_tracers_enemy)
                    optionSlider("BulletTracers", "Enemy Thickness", 1, 8, "bullet_tracers_enemy_thickness", 1, bullet_tracers_enemy)
                    optionSlider("BulletTracers", "Enemy Outline Thickness", 1, 10, "bullet_tracers_enemy_outline_thickness", 3, bullet_tracers_enemy)
                    local function addEspChild(parent, control)
                        if control and parent and parent.setChild then parent.setChild(control) end
                        return control
                    end
                    local function setEspColor(name, color)
                        local toConfig = global.ui and global.ui.colorToConfig
                        global.ui_status[name] = toConfig and toConfig(color) or color
                    end
                    local function espColor(parent, name, labelText, default)
                        callback[name] = function(color)
                            setEspColor(name, color)
                        end
                        local colorControl = parent:Colorpicker({
                            Name = labelText,
                            Flag = name,
                            Default = default,
                            Callback = callback[name],
                        })
                        addEspChild(parent, colorControl)
                        controls[name] = colorControl
                        colorControl.Set(default)
                        return colorControl
                    end
                    esp_team_check.Set(true)
                    esp_friend_check.Set(true)
                    esp_names.Set(true)
                    esp_distances.Set(true)
                    esp_boxes.Set(true)
                    esp_healthbar.Set(true)
                    esp_gradient.Set(true)
                    esp_max_distance.Set(5000)
                    addEspChild(esp_enabled, esp_team_check)
                    addEspChild(esp_enabled, esp_friend_check)
                    addEspChild(esp_enabled, esp_names)
                    addEspChild(esp_enabled, esp_distances)
                    addEspChild(esp_enabled, esp_boxes)
                    addEspChild(esp_enabled, esp_healthbar)
                    addEspChild(esp_enabled, esp_chams)
                    addEspChild(esp_enabled, esp_weapons)
                    addEspChild(esp_enabled, esp_gradient)
                    addEspChild(esp_enabled, esp_max_distance)
                    espColor(esp_team_check, "esp_team_check_color", "Team Check Color", Color3.fromRGB(0, 255, 0))
                    espColor(esp_friend_check, "esp_friend_check_color", "Friend Check Color", Color3.fromRGB(0, 255, 0))
                    espColor(esp_chams, "esp_highlight_color", "Highlight Color", Color3.fromRGB(255, 0, 0))
                    espColor(esp_names, "esp_names_color", "Name Color", Color3.fromRGB(255, 255, 255))
                    espColor(esp_distances, "esp_distance_color", "Distance Color", Color3.fromRGB(255, 255, 255))
                    espColor(esp_weapons, "esp_weapon_color", "Weapon Text Color", Color3.fromRGB(119, 120, 255))
                    espColor(esp_weapons, "esp_weapon_gradient_1", "Weapon Gradient 1", Color3.fromRGB(255, 255, 255))
                    espColor(esp_weapons, "esp_weapon_gradient_2", "Weapon Gradient 2", Color3.fromRGB(119, 120, 255))
                    espColor(esp_healthbar, "esp_health_text_color", "Health Text Color", Color3.fromRGB(119, 120, 255))
                    espColor(esp_healthbar, "esp_health_gradient_1", "Health Gradient 1", Color3.fromRGB(200, 0, 0))
                    espColor(esp_healthbar, "esp_health_gradient_2", "Health Gradient 2", Color3.fromRGB(60, 60, 125))
                    espColor(esp_healthbar, "esp_health_gradient_3", "Health Gradient 3", Color3.fromRGB(119, 120, 255))
                    espColor(esp_boxes, "esp_box_color", "Box Full Color", Color3.fromRGB(255, 255, 255))
                    espColor(esp_boxes, "esp_box_corner_color", "Box Corner Color", Color3.fromRGB(255, 255, 255))
                    espColor(esp_boxes, "esp_box_gradient_1", "Box Gradient 1", Color3.fromRGB(119, 120, 255))
                    espColor(esp_boxes, "esp_box_gradient_2", "Box Gradient 2", Color3.fromRGB(0, 0, 0))
                    espColor(esp_boxes, "esp_box_fill_color", "Box Fill Color", Color3.fromRGB(0, 0, 0))
                    espColor(esp_boxes, "esp_box_fill_gradient_1", "Box Fill Gradient 1", Color3.fromRGB(119, 120, 255))
                    espColor(esp_boxes, "esp_box_fill_gradient_2", "Box Fill Gradient 2", Color3.fromRGB(0, 0, 0))
                    espColor(esp_chams, "esp_chams_fill_color", "Chams Fill Color", Color3.fromRGB(119, 120, 255))
                    espColor(esp_chams, "esp_chams_outline_color", "Chams Outline Color", Color3.fromRGB(119, 120, 255))
                    controls.esp_enabled = esp_enabled
                    controls.esp_team_check = esp_team_check
                    controls.esp_friend_check = esp_friend_check
                    controls.esp_names = esp_names
                    controls.esp_distances = esp_distances
                    controls.esp_boxes = esp_boxes
                    controls.esp_healthbar = esp_healthbar
                    controls.esp_chams = esp_chams
                    controls.esp_weapons = esp_weapons
                    controls.esp_gradient = esp_gradient
                    controls.esp_max_distance = esp_max_distance
                    controls.aura_effects = aura_effects
                    controls.bullet_tracers = bullet_tracers
                    controls.mark_forced_target = mark_forced_target
                    controls.master_switch_marker = master_switch_marker
                    controls.allow_criminal_marker = allow_criminal_marker
                    controls.allow_prisoner_marker = allow_prisoner_marker
                    controls.allow_police_marker = allow_police_marker
                    controls.allow_airdrop_marker = allow_airdrop_marker
                    controls.allow_football_marker = allow_football_marker
                    controls.allow_npcs_marker = allow_npcs_marker
                    controls.no_robberymarker_delay = no_robberymarker_delay
                    controls.mark_bounty_criminals = mark_bounty_criminals
                end
                local function robbery()
                    local function bank()
                        function callback.auto_touch_vault(bool) global.ui_status.auto_touch_vault = bool end
                        function callback.auto_place_dynamite(bool) global.ui_status.auto_place_dynamite = bool end
                        function callback.open_entrance_doors(bool)
                            if global._loaded then
                                local openBankEntrances = global.registry.openBankEntrances
                                if openBankEntrances then
                                    openBankEntrances()
                                else
                                    global.notify("Feature not implemented.", 5)
                                end
                            end
                        end
                        local status = label("Bank", "Bank Status", Color3.fromRGB(0, 0, 0))
                        local auto_touch_vault = toggle("Bank", "Automatic Touch Vault", callback.auto_touch_vault)
                        local auto_place_dynamite = toggle("Bank", "Automatic Place Dynamite", callback.auto_place_dynamite)
                        local open_entrance_doors = button("Bank", "Open Entrance Doors", callback.open_entrance_doors)
                        controls.auto_touch_vault = auto_touch_vault
                        controls.auto_place_dynamite = auto_place_dynamite
                        controls.open_entrance_doors = open_entrance_doors
                    end
                    bank()
                    local function banktruck()
                        function callback.automatic_explode_truck(bool) global.ui_status.automatic_explode_truck = bool end
                        local status = label("BankTruck", "Banktruck Status", Color3.fromRGB(0, 0, 0))
                        local automatic_explode_truck = toggle("BankTruck", "Automatic Explode Truck", callback.automatic_explode_truck)
                        controls.automatic_explode_truck = automatic_explode_truck
                    end
                    banktruck()
                    local function smallstores()
                        local donut = label("SmallStores", "Donut Shop", Color3.fromRGB(0, 0, 0))
                        local gas = label("SmallStores", "Gas Station", Color3.fromRGB(0, 0, 0))
                        local grocery = label("SmallStores", "Grocery Store", Color3.fromRGB(0, 0, 0))
                    end
                    smallstores()
                    local function jewelry()
                        function callback.automatic_grab_nearby_jewels(bool) global.ui_status.automatic_grab_nearby_jewels = bool end
                        function callback.automatic_punch_jewelry_boxes(bool) global.ui_status.automatic_punch_jewelry_boxes = bool end
                        local status = label("Jewelry", "Jewelry Status", Color3.fromRGB(0, 0, 0))
                        local automatic_punch_jewelry_boxes = toggle("Jewelry", "Automatic Punch Boxes", callback.automatic_punch_jewelry_boxes)
                        local automatic_grab_nearby_jewels = toggle("Jewelry", "Automatic Grab Nearby Jewels", callback.automatic_grab_nearby_jewels)
                        controls.automatic_grab_nearby_jewels = automatic_grab_nearby_jewels
                        controls.automatic_punch_jewelry_boxes = automatic_punch_jewelry_boxes
                    end
                    jewelry()
                    local function museum()
                        function callback.automatic_place_dynamite(bool) global.ui_status.automatic_place_dynamite = bool end
                        function callback.auto_fill_bag(bool) global.ui_status.auto_fill_bag = bool end
                        function callback.break_museum_puzzle(bool) global.ui_status.break_museum_puzzle = bool end
                        function callback.automatic_resolve_museum_puzzle(bool) global.ui_status.automatic_resolve_museum_puzzle = bool end
                        local status = label("Museum", "Museum Status", Color3.fromRGB(0, 0, 0))
                        local automatic_resolve_museum_puzzle = toggle("Museum", "Automatic Resolve Puzzle", callback.automatic_resolve_museum_puzzle)
                        local automatic_place_dynamite = toggle("Museum", "Automatic Place Dynamite", callback.automatic_place_dynamite)
                        local auto_fill_bag = toggle("Museum", "Automatic Fill Bag", callback.auto_fill_bag)
                        local break_museum_puzzle = toggle("Museum", "Break Museum Puzzle", callback.break_museum_puzzle)
                        controls.auto_fill_bag = auto_fill_bag
                        controls.automatic_resolve_museum_puzzle = automatic_resolve_museum_puzzle
                        controls.break_museum_puzzle = break_museum_puzzle
                        controls.automatic_place_dynamite = automatic_place_dynamite
                    end
                    museum()
                    local function casino()
                        function callback.auto_crack_vault(bool) global.ui_status.auto_crack_vault = bool end
                        function callback.auto_collect_cash(bool) global.ui_status.auto_collect_cash = bool end
                        function callback.auto_open_door(bool) global.ui_status.auto_open_door = bool end
                        function callback.auto_open_keycode_door(bool) global.ui_status.auto_open_keycode_door = bool end
                        function callback.break_elevator(bool) global.ui_status.break_elevator = bool end
                        function callback.hack_nearby_computers(bool) global.ui_status.hack_nearby_computers = bool end
                        function callback.reveal_casino_keycode()
                            local getKeycode = global.registry.getKeycode
                            if getKeycode then
                                local keycode = getKeycode()
                                if keycode ~= "" then global.notify(keycode, 10) end
                            end
                        end
                        function callback.call_elevator_to_floor(cb)
                            local registry = global.registry
                            local call_elevator_to_floor = registry and registry.call_elevator_to_floor
                            if call_elevator_to_floor then call_elevator_to_floor(cb) end
                        end
                        local status = label("Casino", "Casino Status", Color3.fromRGB(0, 0, 0))
                        local auto_crack_vault = toggle("Casino", "Automatic Crack Vault", callback.auto_crack_vault)
                        local auto_collect_cash = toggle("Casino", "Automatic Collect Loot", callback.auto_collect_cash)
                        local auto_open_door = toggle("Casino", "Automatic Open Door", callback.auto_open_door)
                        local break_elevator = toggle("Casino", "Break Elevator", callback.break_elevator)
                        local hack_nearby_computers = toggle("Casino", "Hack Nearby Computers", callback.hack_nearby_computers)
                        local reveal_casino_keycode = button("Casino", "Reveal Keycode", callback.reveal_casino_keycode)
                        local call_elevator_to_floor = dropdown("Casino", "Call Elevator To Floor", {"The Roof", "Security", "Ground", "Vaults"}, callback.call_elevator_to_floor)
                        controls.auto_crack_vault = auto_crack_vault
                        controls.auto_collect_cash = auto_collect_cash
                        controls.auto_open_door = auto_open_door
                        controls.break_elevator = break_elevator
                        controls.hack_nearby_computers = hack_nearby_computers
                        controls.reveal_casino_keycode = reveal_casino_keycode
                    end
                    casino()
                    local function mansion()
                        function callback.disable_traps(bool) global.ui_status.disable_traps = bool end
                        function callback.anti_boss_attack(bool) global.ui_status.anti_boss_attack = bool end
                        function callback.anti_boss_ragdoll(bool) global.ui_status.anti_boss_ragdoll = bool end
                        function callback.break_mansion_npcs(bool) global.ui_status.break_mansion_npcs = bool end
                        function callback.automatic_elevator_entry(bool) global.ui_status.automatic_elevator_entry = bool end
                        function callback.allow_on_police_team(bool) global.ui_status.allow_on_police_team = bool end
                        function callback.entry_only_near_elevator(bool) global.ui_status.entry_only_near_elevator = bool end
                        local status = label("Mansion", "Mansion Status", Color3.fromRGB(0, 0, 0))
                        local automatic_elevator_entry = toggle("Mansion", "Automatic Elevator Entry", callback.automatic_elevator_entry, true)
                        local allow_on_police_team = toggle("Mansion", "Allow On Police Team", callback.allow_on_police_team)
                        automatic_elevator_entry.setChild(allow_on_police_team)
                        local anti_boss_attack = toggle("Mansion", "Anti Boss Attack", callback.anti_boss_attack)
                        local anti_boss_ragdoll = toggle("Mansion", "Anti Boss Ragdoll", callback.anti_boss_ragdoll)
                        local break_mansion_npcs = toggle("Mansion", "Break NPCs", callback.break_mansion_npcs)
                        local disable_traps = toggle("Mansion", "Disable Traps", callback.disable_traps)
                        controls.break_mansion_npcs = break_mansion_npcs
                        controls.disable_traps = disable_traps
                        controls.anti_boss_attack = anti_boss_attack
                        controls.allow_on_police_team = allow_on_police_team
                        controls.anti_boss_ragdoll = anti_boss_ragdoll
                        controls.automatic_elevator_entry = automatic_elevator_entry
                    end
                    mansion()
                    local function powerplant()
                        function callback.puzzle_resolver(bool) global.ui_status.puzzle_resolver = bool end
                        function callback.disable_piston_damage(bool) global.ui_status.disable_piston_damage = bool end
                        function callback.disable_powerwire_damage(bool) global.ui_status.disable_powerwire_damage = bool end
                        local status = label("Powerplant", "Powerplant Status", Color3.fromRGB(0, 0, 0))
                        local puzzle_resolver = toggle("Powerplant", "Auto Solve Puzzle", callback.puzzle_resolver)
                        local disable_piston_damage = toggle("Powerplant", "Disable Piston Damage", callback.disable_piston_damage)
                        local disable_powerwire_damage = toggle("Powerplant", "Disable Powerwire Damage", callback.disable_powerwire_damage)
                        controls.puzzle_resolver = puzzle_resolver
                        controls.disable_piston_damage = disable_piston_damage
                        controls.disable_powerwire_damage = disable_powerwire_damage
                    end
                    powerplant()
                    local function oilrig()
                        function callback.oil_disable_turret(bool) global.ui_status.oil_disable_turret = bool end
                        function callback.oil_disable_self_destruct(bool) global.ui_status.oil_disable_self_destruct = bool end
                        local oil_disable_turret = toggle("OilRig", "Disable Turret", callback.oil_disable_turret)
                        local oil_disable_self_destruct = toggle("OilRig", "Disable Self Destruct", callback.oil_disable_self_destruct)
                        controls.oil_disable_turret = oil_disable_turret
                        controls.oil_disable_self_destruct = oil_disable_self_destruct
                    end
                    oilrig()
                    local function airdrop()
                        function callback.break_npcs(bool) global.ui_status.break_npcs = bool end
                        function callback.automatic_hold(bool) global.ui_status.automatic_hold = bool end
                        local status = label("Airdrop", "Airdrop Status", Color3.fromRGB(0, 0, 0))
                        local automatic_hold = toggle("Airdrop", "Automatic Hold E", callback.automatic_hold)
                        local break_npcs = toggle("Airdrop", "Break NPCs", callback.break_npcs)
                        controls.automatic_hold = automatic_hold
                        controls.break_npcs = break_npcs
                    end
                    airdrop()
                    local function cargoplane()
                        function callback.automatic_inspect_crate(bool) global.ui_status.automatic_inspect_crate = bool end
                        function callback.automatic_open_cargoplane_door(bool) global.ui_status.automatic_open_cargoplane_door = bool end
                        function callback.call_cargoplane()
                            local callplane = global.registry.callplane
                            if callplane then callplane() end
                        end
                        local status = label("Cargoplane", "Cargoplane Status", Color3.fromRGB(0, 0, 0))
                        local automatic_inspect_crate = toggle("Cargoplane", "Automatic Inspect Crate", callback.automatic_inspect_crate)
                        local automatic_open_cargoplane_door = toggle("Cargoplane", "Automatic Open Door", callback.automatic_open_cargoplane_door)
                        local call_cargoplane = button("Cargoplane", "Call Cargoplane", callback.call_cargoplane)
                        controls.automatic_inspect_crate = automatic_inspect_crate
                        controls.automatic_open_cargoplane_door = automatic_open_cargoplane_door
                    end
                    cargoplane()
                    local function trains()
                        function callback.automatic_train_fillbag(bool) global.ui_status.automatic_train_fillbag = bool end
                        function callback.automatic_breach_vault(bool) global.ui_status.automatic_breach_vault = bool end
                        function callback.automatic_delivery(bool) global.ui_status.automatic_delivery = bool end
                        function callback.anti_station_stop(bool) global.ui_status.anti_station_stop = bool end
                        local status = label("Trains", "Trains Status", Color3.fromRGB(0, 0, 0))
                        local automatic_train_fillbag = toggle("Trains", "Automatic Fill Bag", callback.automatic_train_fillbag)
                        local automatic_delivery = toggle("Trains", "Automatic Delivery", callback.automatic_delivery)
                        local automatic_breach_vault = toggle("Trains", "Automatic Breach Vault", callback.automatic_breach_vault)
                        local anti_station_stop = toggle("Trains", "Anti Station Stop", callback.anti_station_stop)
                        controls.automatic_train_fillbag = automatic_train_fillbag
                        controls.automatic_delivery = automatic_delivery
                        controls.automatic_breach_vault = automatic_breach_vault
                        controls.anti_station_stop = anti_station_stop
                    end
                    trains()
                    local function tomb()
                        function callback.disable_darts(bool) global.ui_status.disable_darts = bool end
                        function callback.disable_spikes(bool) global.ui_status.disable_spikes = bool end
                        function callback.disable_lava(bool) global.ui_status.disable_lava = bool end
                        function callback.disable_wood(bool) global.ui_status.disable_wood = bool end
                        function callback.automatic_resolve_dart_room(bool) global.ui_status.automatic_resolve_dart_room = bool end
                        local status = label("Tomb", "Tomb Status", Color3.fromRGB(0, 0, 0))
                        local automatic_resolve_dart_room = toggle("Tomb", "Automatic Resolve Dart Room", callback.automatic_resolve_dart_room)
                        local disable_darts = toggle("Tomb", "Disable Darts", callback.disable_darts)
                        local disable_wood = toggle("Tomb", "Disable Wood Damage", callback.disable_wood)
                        local disable_spikes = toggle("Tomb", "Disable Spike Damage", callback.disable_spikes)
                        local disable_lava = toggle("Tomb", "Disable Lava Damage", callback.disable_lava)
                        controls.automatic_resolve_dart_room = automatic_resolve_dart_room
                        controls.disable_darts = disable_darts
                        controls.disable_wood = disable_wood
                        controls.disable_spikes = disable_spikes
                        controls.disable_lava = disable_lava
                    end
                    tomb()
                    local function cargoship()
                        function callback.disable_cargoship_turrets(bool) global.ui_status.disable_cargoship_turrets = bool end
                        function callback.destroy_all_crates(bool) global.ui_status.destroy_all_crates = bool end
                        local status = label("Cargoship", "Cargoship Status", Color3.fromRGB(0, 0, 0))
                        local disable_cargoship_turrets = toggle("Cargoship", "Disable Turrets", callback.disable_cargoship_turrets)
                        controls.disable_cargoship_turrets = disable_cargoship_turrets
                    end
                    cargoship()
                end
                local function info()
                    function callback.goto_trade_world()
                        local generateJobId = global.registry.generateJobId
                        if not generateJobId then return global.notify("Server generator is not loaded yet.", 5) end
                        local jobId = generateJobId(true)
                        if jobId and jobId ~= "" then
                            pcall(function() teleportservice:TeleportToPlaceInstance(9780994092, jobId, players.LocalPlayer) end)
                        else
                            global.notify("No trade world server found. Try again.", 5)
                        end
                    end
                    function callback.join_random_server()
                        local generateJobId = global.registry.generateJobId
                        if not generateJobId then return global.notify("Server generator is not loaded yet.", 5) end
                        local jobId = generateJobId()
                        -- teleport back into the SAME place we pulled job ids for (Jailbreak has
                        -- several place ids); a place/instance mismatch is what triggers error 771
                        if jobId and jobId ~= "" then
                            pcall(function() teleportservice:TeleportToPlaceInstance(game.PlaceId, jobId, players.LocalPlayer) end)
                        else
                            global.notify("No available server found. Try again.", 5)
                        end
                    end
                    function callback.rejoin()
                        local jobId = game.JobId
                        if jobId and jobId ~= "" then
                            pcall(function() teleportservice:TeleportToPlaceInstance(game.PlaceId, jobId, players.LocalPlayer) end)
                        else
                            pcall(function() teleportservice:Teleport(game.PlaceId, players.LocalPlayer) end)
                        end
                    end
                    function callback.lighting_technology(val) global.ui_status.world_lighting_mode_mode = tostring(val or "future"):lower() end
                    local infolabel = credit("Info", "_fivee. (350409812066041856)")
                    local infoversion = label("Info", ("Version: v%s-%s"):format(global.version, global.exploit))
                    local goto_trade_world = button("Info", "Teleport To Trade World brokken", callback.goto_trade_world)
                    local join_random_server = button("Info", "Join Random Server", callback.join_random_server)
                    local rejoin = button("Info", "Rejoin", callback.rejoin)
                    local soundOptions = {"windy winter", "thunderstorm", "light rain", "night", "day", "raindrop", "space"}
                    local lightingOptions = {"compatibility", "shadowmap", "unified", "future", "legacy", "voxel"}
                    local weatherOptions = {"light rain", "rain", "snow", "custom rain"}
                    local skyboxOptions = {"black storm", "blue space", "realistic", "stormy", "pink", "minecraft", "purple day", "red night", "trollge", "night", "space", "vibe morning", "vibe night", "purple splash", "green space", "snowy", "spongebob", "pink day", "alien red", "walls of autumn", "cold wintriness", "oblivion", "hell sky", "starry night", "sunset", "anime", "cartoon sky", "omori", "clear day", "desert", "crimson", "pumpkin hill", "earth space", "blue abyss", "green aurora", "underwater", "orange fog", "purple fog", "fade night", "summer day", "green nebula"}
                    local background_noise = optionToggle("LightingTechnology", "Background Noise", "world_background_noise_enabled", nil, false)
                    optionDropdown("LightingTechnology", "Background Sound", soundOptions, "world_background_noise_sound", "raindrop", background_noise)
                    optionSlider("LightingTechnology", "Background Volume", 0, 100, "world_background_noise_volume", 25, background_noise)
                    local lighting_mode = optionToggle("LightingTechnology", "Lighting Mode", "world_lighting_mode_enabled", nil, false)
                    optionDropdown("LightingTechnology", "Technology", lightingOptions, "world_lighting_mode_mode", "future", lighting_mode)
                    local world_time = optionToggle("LightingTechnology", "World Time", "world_time_enabled", nil, false)
                    optionSlider("LightingTechnology", "Hour", 0, 24, "world_time_hour", 4.5, world_time)
                    local atmosphere = optionToggle("LightingTechnology", "Atmosphere", "world_atmosphere_enabled", nil, false)
                    optionColor(atmosphere, "world_atmosphere_color", "Atmosphere Color", Color3.fromRGB(255, 255, 255))
                    optionColor(atmosphere, "world_atmosphere_decay", "Atmosphere Decay", Color3.fromRGB(120, 120, 120))
                    optionSlider("LightingTechnology", "Atmosphere Haze", 0, 10, "world_atmosphere_haze", 1, atmosphere)
                    optionSlider("LightingTechnology", "Atmosphere Glare", 0, 10, "world_atmosphere_glare", 10, atmosphere)
                    optionSlider("LightingTechnology", "Atmosphere Offset", 0, 1, "world_atmosphere_offset", 0, atmosphere)
                    optionSlider("LightingTechnology", "Atmosphere Density", 0, 1, "world_atmosphere_density", 0.35, atmosphere)
                    local saturation = optionToggle("LightingTechnology", "Saturation", "world_saturation_enabled", nil, false)
                    optionSlider("LightingTechnology", "Saturation Value", -1, 1, "world_saturation_value", 0, saturation)
                    local contrast = optionToggle("LightingTechnology", "Contrast", "world_contrast_enabled", nil, false)
                    optionSlider("LightingTechnology", "Contrast Value", -1, 1, "world_contrast_value", 0, contrast)
                    local tint = optionToggle("LightingTechnology", "Tint", "world_tint_enabled", nil, false)
                    optionColor(tint, "world_tint_color", "Tint Color", Color3.fromRGB(255, 255, 255))
                    local textures = optionToggle("LightingTechnology", "Textures", "world_textures_enabled", nil, false)
                    optionDropdown("LightingTechnology", "Texture Pack", {"minecraft"}, "world_textures_pack", "minecraft", textures)
                    local ambient = optionToggle("LightingTechnology", "Ambient", "world_ambient_enabled", nil, false)
                    optionColor(ambient, "world_ambient_color", "Ambient Color", Color3.fromRGB(70, 70, 70))
                    optionColor(ambient, "world_ambient_outdoor_color", "Outdoor Ambient", Color3.fromRGB(128, 128, 128))
                    local weather = optionToggle("LightingTechnology", "Weather", "world_weather_enabled", nil, false)
                    optionDropdown("LightingTechnology", "Weather Type", weatherOptions, "world_weather_type", "rain", weather)
                    optionColor(weather, "world_weather_color", "Weather Color", Color3.fromRGB(255, 255, 255))
                    optionSlider("LightingTechnology", "Weather Rate", 1, 100, "world_weather_rate", 100, weather)
                    optionSlider("LightingTechnology", "Weather Intensity", 0, 100, "world_weather_intensity", 100, weather)
                    optionSlider("LightingTechnology", "Weather Speed", 0, 100, "world_weather_speed", 100, weather)
                    local skybox = optionToggle("LightingTechnology", "Skybox", "world_skybox_enabled", nil, false)
                    optionDropdown("LightingTechnology", "Skybox", skyboxOptions, "world_skybox_sky", "black storm", skybox)
                    controls.world_background_noise = background_noise
                    controls.world_lighting_mode = lighting_mode
                    controls.world_time = world_time
                    controls.world_atmosphere = atmosphere
                    controls.world_saturation = saturation
                    controls.world_contrast = contrast
                    controls.world_tint = tint
                    controls.world_textures = textures
                    controls.world_ambient = ambient
                    controls.world_weather = weather
                    controls.world_skybox = skybox
                end
                player()
                vehicle()
                misc()
                combat()
                markers()
                robbery()
                info()
                global.ui_callbacks = callback
            end
            sections()
            global.ui.markerSection = {
                teamsSection = teamsSection;
                objSection = objSection;
                settingsSection = settingsSection;
            }
        end
        ui()
        global.features_loaded = true
    end
    ui()
        return true
    end
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end
ON_LOADUP()
if global and global.ui and global.ui.loadLibrary then global.ui.loadLibrary() end
if global and global.ui and global.ui.buildSections then global.ui.buildSections() end
if global and global.ui and global.ui.initWindow then global.ui.initWindow() end

-- print("after startup now")

getrenv().env = getrenv()
env.crewbattler = global
-- mthooks.lua reads the shared state from the global named `icetray`; keep that
-- alias alongside the branded name so the metatable hook keeps working
env.crewbattler = global
env.IS_WORKING = true
env.CONNECTIONS = 1
env.request = request or syn and syn.request
env.discord_code = "5Eqt6QBfYY"
env.coregui = CloneRef(game:GetService("CoreGui"))
env.players = players
env.player = player
env.runservice = runservice
env.repl = repl
env.textService = textService
env.httpservice = httpservice
env.teleportservice = teleportservice
env.uis = uis
env.lighting = lighting
env.teams = teams
env.tweenservice = tweenservice
env.collectionservice = collectionservice

while true do
    if coregui:FindFirstChild("crewbattler.club") then
        getrenv().uistatus = false
        break
    end
    getrenv().uistatus = true
    task.wait()
end

global.USER_INPUT_TYPE_SWITCH = false
global.IS_IN_NOCLIP = false
local client = {}
local meta = {
    __index = function(t, k)
        warn(("Could not find key `%s`"):format(k))
    end;
}
setmetatable(client, meta)

local function crewbattlerload()
    local function createRegistry()
        -- Each module is loaded behind pcall so a single moved/renamed module after a
        -- game update degrades gracefully (that feature breaks) instead of throwing and
        -- killing the entire script. Anything that fails is collected and reported at
        -- load so it's obvious what the update changed.
        client.modules = {}
        local moduleFailures = {}
        local moduleSpecs = {
            {"math", function() return require(repl.Module.Math) end};
            {"roact", function() return require(repl.Roact) end};
            {"rayCast", function() return require(repl.Module.RayCast) end};
            {"bulletEmitter", function() return require(repl.Game.ItemSystem.BulletEmitter) end};
            {"notify", function() return require(repl.Game.Notification).new end};
            {"contextMsg", function() return require(repl.Game.ContextMessage.ContextMessageUI) end};
            {"worldMarker", function() return require(repl.Game.WorldMarker.WorldMarker) end};
            {"system", function() return require(repl.Game.WorldMarker.WorldMarkerSystem) end};
            {"group", function() return require(repl.Game.WorldMarker.WorldMarkerGroup) end};
            {"cmdr", function() return require(repl.CmdrClient) end};
            {"crawlButton", function() return require(repl.Game.DefaultActions).crawlButton end};
            {"fallingInit", function() return require(repl.Game.Falling).Init end};
            {"falling", function() return require(repl.Game.Falling) end};
            {"playerMarkerSystem", function() return require(repl.Game.PlayerMarkerSystem) end};
            {"vehicle", function() return require(repl.Vehicle.VehicleUtils) end};
            {"settings", function() return require(repl.Resource.Settings) end};
            {"itemSystem", function() return require(repl.Game.ItemSystem.ItemSystem) end};
            {"inventoryItemSystem", function() return require(repl.Inventory.InventoryItemSystem) end};
            {"gun", function() return require(repl.Game.Item.Gun) end};
            {"taser", function() return require(repl.Game.Item.Taser) end};
            {"robberyConsts", function() return require(repl.Robbery.RobberyConsts) end};
            {"puzzleFlow", function() return require(repl.Game.Robbery.PuzzleFlow) end};
            {"ui", function() return require(repl.Module.UI) end};
            {"playerUtils", function() return require(repl.Game.PlayerUtils) end};
            {"tagUtils", function() return require(repl.Tag.TagUtils) end};
            {"smoke", function() return require(repl.Game.SmokeGrenade.SmokeGrenade) end};
            {"localization", function() return require(repl.Module.Localization) end};
            {"characterAnim", function() return require(repl.Game.CharacterAnim) end};
            {"characterUtil", function() return require(repl.Game.CharacterUtil) end};
            {"paraglide", function() return require(repl.Game.Paraglide) end};
            {"region", function() return require(repl.Std.Region) end};
            {"defaultActions", function() return require(repl.Game.DefaultActions) end};
            {"actionButtonService", function() return require(repl.ActionButton.ActionButtonService) end};
            {"inventoryItemUtils", function() return require(repl.Inventory.InventoryItemUtils) end};
            {"jetpack", function() return require(repl.Game.JetPack.JetPack) end};
            {"guardNPCshared", function() return require(repl.GuardNPC.GuardNPCShared) end};
            {"humanoidUnloadConsts", function() return require(repl.HumanoidUnload.HumanoidUnloadConsts) end};
            {"gamepassSystem", function() return require(repl.Gamepass.GamepassSystem) end};
            {"piston", function() return require(repl.Game.Robbery.PowerPlant.Piston) end};
            {"dartDispenser", function() return require(repl.Game.DartDispenser.DartDispenser) end};
            {"itemCamera", function() return require(repl.Game.ItemSystem.ItemCamera) end};
            {"sniper", function() return require(repl.Game.Item.Sniper) end};
            {"militaryTurret", function() return require(repl.Game.MilitaryTurret.MilitaryTurret) end};
            {"bossNpcBinder", function() return require(repl.MansionRobbery.BossNPCBinder) end};
            {"lightningSystem", function() return require(repl.Game.LightningSystem) end};
            {"confirmation", function() return require(repl.Module.Confirmation) end};
            {"hotbarItemSystem", function() return require(repl.Hotbar.HotbarItemSystem) end};
            {"hotbarItemUtils", function() return require(repl.Hotbar.HotbarItemUtils) end};
            {"party", function() return require(repl.Game.Party) end};
            {"geomUtils", function() return require(repl.Std.GeomUtils) end};
            {"vehicleLinkUtils", function() return require(repl.VehicleLink.VehicleLinkUtils) end};
            {"loadingBar", function() return require(repl.Game.LoadingBar) end};
            {"mansionRobberyUtils", function() return require(repl.MansionRobbery.MansionRobberyUtils) end};
            {"regionUtils", function() return require(repl.Std.Region.RegionUtils) end};
            {"displayDamage", function() return require(repl.Game.DisplayDamage) end};
            {"minimapService", function() return require(repl.App.MinimapService) end};
            {"jet", function() return require(repl.Game.Plane.Jet) end};
            {"stunt", function() return require(repl.Game.Plane.Stunt) end};
            {"boat", function() return require(repl.Game.Boat.Boat) end};
            {"seekingMissileUtils", function() return require(repl.SeekingMissile.SeekingMissileUtils) end};
            {"volt", function() return require(repl.Game.Vehicle.Volt) end};
            {"alexChassis2", function() return require(repl.Module.AlexChassis2) end};
            {"charBinder", function() return require(repl.App.CharacterBinder) end};
            {"trainSystem", function() return require(repl.Game.TrainSystem) end};
            {"tableUtils", function() return require(repl.Std.TableUtils) end};
            {"levenshtein", function() return require(repl.Module.Levenshtein) end};
            {"c4", function() return require(repl.Game.Item.C4) end};
            {"simulatedPhysicsProjectile", function() return require(repl.Module.SimulatedPhysicsProjectile) end};
            {"roll", function() return require(repl.MovementRoll.MovementRollService) end};
            {"gameUtil", function() return require(repl.Game.GameUtil) end};
            {"trackingSpotlight", function() return require(repl.TrackingSpotlight.TrackingSpotlightBinder) end};
            {"rocketLauncherConsts", function() return require(repl.RocketLauncher.RocketLauncherConsts) end};
            {"seekingMissileShared", function() return require(repl.SeekingMissile.SeekingMissileShared) end};
            {"netObjPool", function() return require(repl.NetObjPool.NetObjPoolBinder) end};
            {"smokeGrenade", function() return require(repl.Game.Item.SmokeGrenade) end};
            {"turret", function() return require(repl.Turret2.Turret) end};
        }
        for i = 1, #moduleSpecs do
            local key, loader = moduleSpecs[i][1], moduleSpecs[i][2]
            local ok, mod = pcall(loader)
            if ok and mod ~= nil then
                client.modules[key] = mod
            else
                moduleFailures[#moduleFailures + 1] = key
            end
        end
        global.moduleFailures = moduleFailures
        if #moduleFailures > 0 then
            warn(("[crewbattler] %d module(s) failed to load (game updated?): %s"):format(#moduleFailures, table.concat(moduleFailures, ", ")))
        end
        client.confirmation = {
            confirmed = {};
        }
        client.players = {}
        local function safeGet(getter, fallback)
            local ok, value = pcall(getter)
            if ok and value ~= nil then return value end
            return fallback
        end
        client.descendants = {
            givers = safeGet(function() return workspace.Givers:GetChildren() end, {});
            vehicles = safeGet(function() return workspace.Vehicles end, nil);
        }
        client.onWorkspaceSpawnRun = {}
        client.onWorkspaceRemovedRun = {}
        client.reg = {}
        client.state = {}
        client.rayHooks = {}
        client.onGetEq = {}
        client.gamelocations = {
            criminal_base_city = Vector3.new(-241.04759216308594, 18.26566505432129, 1603.2467041015625);
            cargo_port = Vector3.new(-346.10906982421875, 21.265666961669922, 2051.884521484375);
            powerplant = Vector3.new(73.05872344970703, 21.26565933227539, 2330.603271484375);
            bounty_bay_airport = Vector3.new(-1280.7972412109375, 41.57174301147461, 2862.231689453125);
            museum = Vector3.new(1039.164306640625, 101.80693054199219, 1220.47412109375);
            gun_store_city = Vector3.new(387.13153076171875, 18.565671920776367, 519.4755859375);
            bank = Vector3.new(-11.083830833435059, 18.56781768798828, 785.1068115234375);
            jewelry = Vector3.new(90.18016815185547, 18.265535354614258, 1360.61181640625);
            gas_station = Vector3.new(-1563.6400146484375, 18.398113250732422, 709.526123046875);
            prison = Vector3.new(-1178.06005859375, 18.359729766845703, -1408.713134765625);
            donut_store = Vector3.new(93.99942016601562, 19.21782684326172, -1520.624755859375);
            dog_store = Vector3.new(254.4175567626953, 19.61784553527832, -1625.93212890625);
            gun_store_mountainside = Vector3.new(-9.677970886230469, 19.21782684326172, -1771.1429443359375);
            tomb = Vector3.new(557.5381469726562, 25.799976348876953, -490.9645080566406);
            military_base = Vector3.new(673.5711669921875, 19.318540573120117, -3615.018310546875);
            casino = Vector3.new(-301.520751953125, 19.817184448242188, -4661.919921875);
            crater_city_airport = Vector3.new(-854.0402221679688, 19.67174530029297, -4898.408203125);
            gun_store_cratercity = Vector3.new(-482.135986328125, 19.853652954101562, -5663.77197265625);
            fire_station = Vector3.new(-317.110107421875, 19.904991149902344, -5394.2763671875);
            mansion = Vector3.new(3087.748779296875, 62.8889274597168, -4604.91748046875);
            criminal_base_volcano = Vector3.new(2204.335205078125, 19.55750274658203, -2654.022216796875);
            rail_track1 = Vector3.new(512, 18, 1789);
            rail_track2 = Vector3.new(1517, 18, -176);
            crater_city_bank = Vector3.new(-668, 19, -6087);
            oil_rig = Vector3.new(-2374, 108, -4042);
        }
        local function loadRobberies()
            local robberies = {
                "bank";
                "museum";
                "jewelry";
                "mansion";
                "casino";
                "tomb";
                "powerplant";
                "crater_city_bank";
                "oil_rig";
            }
            for i,v in next, robberies do
                local location = client.gamelocations[v]
                player:RequestStreamAroundAsync(location)
            end
        end
        loadRobberies()
        client.run_on_player_connect = {}
        client.run_on_player_disconnect = {}
        local function addPlayersToTable()
            local playersService = players or CloneRef(game:GetService("Players"))
            if not playersService or type(playersService.GetPlayers) ~= "function" then return end
            for i,v in next, playersService:GetPlayers() do
                if v ~= player then table.insert(client.players, v) end
            end
        end
        addPlayersToTable()
        local function onPlayerAdded(player)
            for i,v in next, client.run_on_player_connect do v._fn(player) end
            table.insert(client.players, player)
        end
        if players and players.PlayerAdded then players.PlayerAdded:connect(onPlayerAdded) end
        local function onPlayerRemoving(player)
            for i,v in next, client.run_on_player_disconnect do v._fn(player) end
            for i=1, #client.players do
                local v = client.players[i]
                if v == player then
                    table.remove(client.players, i)
                    break
                end
            end
        end
        if players and players.PlayerRemoving then players.PlayerRemoving:connect(onPlayerRemoving) end
        function client.confirmation.new(text)
            local confirmation = client.modules.confirmation.new(text)
            return confirmation
        end
        function client.confirmation.onYes(confirmation, onYes) confirmation.OnYes:Connect(onYes) end
        function client.confirmation.onNo(confirmation, onNo) confirmation.OnNo:Connect(onNo) end
        global.registry = global.registry or {}
        global.registry.client = client
        global.registry.doors = global.registry.doors or {}
        global.registry.sounds = global.registry.sounds or {}
        global.LocalMouse = player:GetMouse()
        global.ignorelist = {}
        local function notify(text, duration)
            return client.modules.notify({
                Text = tostring(text);
                Duration = tonumber(duration) or 0;
            })
        end
        global.notify = notify
        local contextMessageModule = client.modules.contextMsg
        client.contextModule = {
            open = contextMessageModule.open;
            close = contextMessageModule.close;
            setmsg = contextMessageModule.setMessage;
            status = contextMessageModule.isOpen;
        }
    end
    createRegistry()
    local function send_console_developer(text)
        local Cmdr = client.modules.cmdr
        if not Cmdr then
            force_destroy_coregui(true)
            return false
        end
        return Cmdr.Events.AddLine(("crewbattler : %s"):format(tostring(text)))
    end
    send_console_developer("beginning crewbattlerload")
    local function keepRobberiesLoaded() 
        local locations = client.gamelocations
        while true do
            for i,v in next, locations do player:RequestStreamAroundAsync(v) end
            task.wait(5)
        end
    end
    task.spawn(keepRobberiesLoaded)--?
    local function synfunction()
        local function unsupported(func, isDebugLibrary)
            local msg = ("Tried to run %s but this function is not supported by your exploit")
            if func == "Drawing" then
                warn(msg:format("Drawing"))
                return {
                    new = function(...)
                    end;
                }
            end
            if isDebugLibrary then
                warn(msg:format("debug."..tostring(func)))
                return function() end
            end
            warn(msg:format(tostring(func)))
            return function() end
        end
        global.functions = {
            getreg = debug.getregistry or getreg or unsupported("getregistry", true);
            getupvalues = debug.getupvalues or unsupported("getupvalues", true);
            getconstants = debug.getconstants or unsupported("getconstants", true);
            setconstant = debug.setconstant or unsupported("setconstant", true);
            getupvalue = debug.getupvalue or unsupported("getupvalue", true);
            setupvalue = debug.setupvalue or unsupported("setupvalue", true);
            getgc = getgc or unsupported("getgc");
            getrawmetatable = getrawmetatable or unsupported("getrawmetatable");
            setreadonly = setreadonly or make_writeable or unsupported("make_writeable");
            newcclosure = newcclosure or unsupported("newcclosure");
            setclipboard = setclipboard or unsupported("setclipboard");
            islclosure = islclosure or unsupported("islclosure");
            setscriptable = setscriptable or unsupported("setscriptable");
            is_synapse_function = is_synapse_function or is_oxygen_function or iskrnlclosure or isexecutorclosure or checkclosure or unsupported("is_synapse_function");
            firetouchinterest = firetouchinterest or unsupported("firetouchinterest");
            fireclickdetector = fireclickdetector or unsupported("fireclickdetector");
            getconnections = getconnections or unsupported("getconnections");
            sethiddenproperty = sethiddenproperty or unsupported("sethiddenproperty");
            getsynasset = getsynasset or getcustomasset or unsupported("getsynasset");
            writefile = writefile or unsupported("writefile");
            readfile = readfile or unsupported("readfile");
            appendfile = appendfile or unsupported("appendfile");
            makefolder = makefolder or unsupported("makefolder");
            isfile = isfile or unsupported("isfile");
            isfolder = isfolder or unsupported("isfolder");
            decompile = decompile or function() return "nu exista decompiler pe acest executor" end;
            listfiles = listfiles or unsupported("listfiles");
            set_thread_identity = syn and syn.set_thread_identity or set_thread_identity or setthreadidentity or unsupported("set_thread_identity");
            drawing = Drawing or unsupported("Drawing");
        }
    end
    local function tagService()
        local function tagStorage()
            local inst = Instance.new("Folder")
            inst.Name = "tagService"
            if IS_NOT_OBFUSCATED then
                inst.Parent = repl
                warn("tagService folder is in ReplicatedStorage")
            end
            return inst
        end
        local tags = {}
        tags.storage = tagStorage()
        tags.tags = {
            BoolValue = 0;
            NumberValue = 1;
            StringValue = 2;
            BrickColorValue = 3;
            CFrameValue = 4;
            Color3Value = 5;
            IntValue = 6;
            ObjectValue = 7;
            RayValue = 8;
            Vector3Value = 9;
        }
        local tags_module = {}
        function tags_module.getTag(num)
            num = tonumber(num)
            for i,v in next, client.tags.tags do
                if v == num then return i end
            end
            return false
        end
        tags.module = tags_module
        tags.cache = {}
        function tags.new(name, tip, defaultValue, callback)
            name = tostring(name)
            local getTag = client.tags.module.getTag(tip)
            if not getTag then error(("cannot make tag `%s`"):format(name)) end
            local cache = {}
            local inst = Instance.new(getTag)
            inst.Name = name
            inst.Parent = client.tags.storage
            inst.Value = defaultValue
            inst.Changed:connect(function()
                cache.obj = inst
                cache.value = inst.Value
                return callback(inst.Value)
            end)
            cache.name = name
            cache.obj = inst
            cache.value = inst.Value
            table.insert(tags.cache, cache)
            return cache
        end
        function tags.getTagByName(self, name)
            local cache = self.cache
            for i,v in next, cache do
                if v and v.name == name then return v end
            end
            return false
        end
        client.tags = tags
    end
    local function warningBar()
        local warning = {}
        local gui = {}
        function warning.new(typ, props)
            local inst = Instance.new(typ)
            for i,v in next, props do
                if i ~= "Parent" then
                    if typeof(v) == "Instance" then
                        v.Parent = inst
                    else
                        inst[i] = v
                    end
                end
            end
            inst.Parent = props.Parent
            return inst
        end
        function warning.start(self)
            local ui = self.new("ScreenGui", {
                Name = "warnings";
                Parent = player.PlayerGui;
                Enabled = false;
                self.new("Frame", {
                    Active = true;
                    Draggable = true;
                    AnchorPoint = Vector2.new(0.5, 1);
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0.49, 0, 0.35, 0);
                    Size = UDim2.new(0, 377, 0, 208);
                    ZIndex = 3;
                    self.new("TextLabel", {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0.104065098, 0, 0.247999325, 0);
                        Size = UDim2.new(0, 94, 0, 102);
                        Text = "⚠️";
                        TextSize = 75.000;
                        BorderSizePixel = 2;
                        TextWrapped = true;
                        Font = Enum.Font.SourceSans;
                    });
                    self.new("TextLabel", {
                        Name = "State";
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0.33129105, 0, 0.377007276, 0);
                        Size = UDim2.new(0, 212, 0, 26);
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        Font = Enum.Font.Ubuntu;
                        Text = "State";
                        TextSize = 15;
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0);
                        TextStrokeTransparency = 0.5;
                    });
                    self.new("Frame", {
                        Name = "Uncolored";
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                        BackgroundTransparency = 0.6;
                        BorderSizePixel = 0;
                        Position = UDim2.new(0.330542207, 0, 0.502994716, 0);
                        Size = UDim2.new(0, 213, 0, 7);
                        self.new("Frame", {
                            Name = "Colored";
                            BorderSizePixel = 0;
                            Size = UDim2.new(0, 1, 0, 7);
                            self.new("UIGradient", {
                                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 200, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 0))};
                            });
                        });
                    });
                });
            });
            local new = {}
            new.ui = ui
            new.percentage = 0
            function new.getEnabled(self) return self.ui.Enabled end
            function new.setEnabled(self, value) self.ui.Enabled = value end
            function new.setText(self, text)
                text = tostring(text)
                self.ui.Frame.State.Text = text
            end
            function new.cleanup(self)
                self.ui.Enabled = false
                self.ui.Frame.Uncolored.Colored.Size = UDim2.new(0, 1, 0, 7)
                self.percentage = 0
                self.time = nil
            end
            function new.tween(self)
                local tween = tweenservice:Create(self.ui.Frame.Uncolored.Colored, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(self.percentage/100, 1, 0, 7)})
                tween:Play()
            end
            function new.play(self)
                assert(not self.hb, "hb already in process...")
                self.time = tick()
                self.hb = runservice.Heartbeat:connect(function()
                    if self.percentage >= 101 then
                        self.hb:disconnect()
                        self.hb = nil
                        task.delay(0.1, function()
                            self:cleanup()
                        end)
                        return false
                    end
                    if tick() - self.time > 0.02 then
                        self.percentage += 1 
                        self:tween()
                        self.time = tick()
                    end
                end)
            end
            return new
        end
        client.warningBar = warning:start()
    end
    warningBar()
    -- every-frame loops (createloop(0, ...)) all share ONE Heartbeat connection and a
    -- single Lua dispatch loop, instead of one Heartbeat:Connect each. 70+ separate
    -- Heartbeat slots was a real FPS sink (each is its own C->Lua dispatch per frame).
    local hbList = {}
    local hbConn = nil
    -- hottest function in the script (runs every frame), so JIT it
    local pumpHeartbeat = LPH_JIT_MAX(function(dt)
        local list = hbList
        local i = 1
        while i <= #list do
            local entry = list[i]
            if entry.active then
                pcall(entry.cb, dt) -- isolate errors so one bad loop can't kill the rest
                i = i + 1
            else
                -- swap-remove from the true end so the sequence never gets a hole
                local last = #list
                list[i] = list[last]
                list[last] = nil
            end
        end
    end)
    function global.createloop(seconds, callback)
        if seconds == 0 then
            local entry = { active = true, cb = callback }
            hbList[#hbList + 1] = entry
            if not hbConn then hbConn = runservice.Heartbeat:Connect(pumpHeartbeat) end
            return {
                disconnect = function() entry.active = false end,
                Disconnect = function() entry.active = false end,
            }
        end
        -- interval loops keep their own task.wait driver
        local active = true
        local function loop()
            while active do
                task.wait(seconds)
                if active then callback() end
            end
        end
        task.spawn(loop)
        return {
            disconnect = function() active = false end,
            Disconnect = function() active = false end,
        }
    end
    -- loads custom audio (.ogg/.mp3/.wav) from a Radiance/Assets subfolder into a
    -- name -> assetId map for the bullet sound and hit sound features; memoized per folder
    global.getSoundAssets = function(subfolder)
        subfolder = subfolder or ""
        global.soundAssets = global.soundAssets or {}
        -- only treat a populated scan as cached, so an early empty call (before file
        -- APIs are ready / folder is mounted) is retried later instead of stuck on none
        local cached = global.soundAssets[subfolder]
        if cached and #cached.names > 0 then return cached end
        local result = {map = {}, names = {}}
        local listfiles = global.functions.listfiles
        local getcustomasset = global.functions.getsynasset or global.functions.getcustomasset
        if type(listfiles) ~= "function" or type(getcustomasset) ~= "function" then
            return result
        end
        local folder = subfolder ~= "" and ("Radiance/Assets/" .. subfolder) or "Radiance/Assets"
        local ok, files = pcall(listfiles, folder)
        if not ok or type(files) ~= "table" then return result end
        for _, path in ipairs(files) do
            local lower = tostring(path):lower()
            if lower:match("%.ogg$") or lower:match("%.mp3$") or lower:match("%.wav$") then
                local name = tostring(path):match("[^/\\]+$") or tostring(path)
                name = name:gsub("%.%w+$", "")
                local okAsset, asset = pcall(getcustomasset, path)
                if okAsset and type(asset) == "string" then
                    if result.map[name] == nil then result.names[#result.names + 1] = name end
                    result.map[name] = asset
                end
            end
        end
        table.sort(result.names)
        if #result.names > 0 then global.soundAssets[subfolder] = result end
        return result
    end
    -- shared flat-key status readers (used by the visual feature blocks)
    global.makeStatusReaders = function(status, colorFromConfig)
        local function read(key, fallback)
            local value = status[key]
            if value == nil then return fallback end
            return value
        end
        local function readBool(key, fallback)
            local value = read(key, nil)
            if value == nil then return fallback == true end
            return value == true
        end
        local function readNumber(key, fallback) return tonumber(read(key, fallback)) or fallback end
        local function readColor(key, fallback)
            local value = read(key, nil)
            if colorFromConfig then return colorFromConfig(value, fallback) end
            return typeof(value) == "Color3" and value or fallback
        end
        local function readString(key, fallback)
            local value = read(key, nil)
            return type(value) == "string" and value or fallback
        end
        return read, readBool, readNumber, readColor, readString
    end
    -- mirrors a ui_status flag into its tag's value every frame (very common boilerplate)
    -- All tag value-syncs used to be ~32 separate every-frame loops. They only need to
    -- mirror a ui_status flag into a tag value, which changes on user input, so drive
    -- them all from ONE ~20Hz loop over a shared list instead.
    local tagSyncList = {}
    global.syncTagValue = function(cache, flag)
        if cache then tagSyncList[#tagSyncList + 1] = { cache, flag } end
    end
    global.createloop(0.05, LPH_JIT_MAX(function()
        local status = global.ui_status
        if not status then return end
        for i = 1, #tagSyncList do
            local pair = tagSyncList[i]
            local cache = pair[1]
            local obj = cache and cache.obj
            if obj then
                local v = status[pair[2]]
                if obj.Value ~= v then obj.Value = v end
            end
        end
    end))
    -- ( Hawkeye anticheat bypass runs at the very top of the script now )
    local function createfiles()
        local writefile = global.functions.writefile
        local appendfile = global.functions.appendfile
        local makefolder = global.functions.makefolder
        local isfile = global.functions.isfile
        local isfolder = global.functions.isfolder
        local iscrewbattlerFolder = isfolder("crewbattler")
        if not iscrewbattlerFolder then makefolder("crewbattler") end
        local isResourceFolder = isfolder("Radiance/resource")
        if not isResourceFolder then makefolder("Radiance/resource") end
        local isAssetsFolder = isfolder("Radiance/Assets")
        if not isAssetsFolder then makefolder("Radiance/Assets") end
        local isBulletSounds = isfolder("Radiance/Assets/bullet sounds")
        if not isBulletSounds then makefolder("Radiance/Assets/bullet sounds") end
        local isHitSounds = isfolder("Radiance/Assets/hit sounds")
        if not isHitSounds then makefolder("Radiance/Assets/hit sounds") end

        local function files()
            send_console_developer("loading resource")
            local isfile = global.functions.isfile

            local function makeResources()
                local function httpGet(url) return game:HttpGet(url) end

                -- images
                if not isfile("Radiance/resource/airdrop.png")then writefile("Radiance/resource/airdrop.png",httpGet("https://img001.prntscr.com/file/img001/CxPl0JU6SyyrHhMyL5NEhw.png"))end
                if not isfile("Radiance/resource/football.png")then writefile("Radiance/resource/football.png",httpGet("https://img001.prntscr.com/file/img001/RAhMFSwkRyCglvAtWrJbVQ.png"))end
                if not isfile("Radiance/resource/robot.png")then writefile("Radiance/resource/robot.png",httpGet("https://img001.prntscr.com/file/img001/HDrYpapySqKS52X3BIMdHA.png"))end

                -- sounds manifest
                local hitsounds, bulletsounds = {}, {}
                local okManifest, response = pcall(httpGet, "https://crewbattler.club/sounds")
                if okManifest and type(response) == "string" then
                    local hitsLine = response:match("hitsounds:%s*{(.-)}") or ""
                    local bulletsLine = response:match("bulletsounds:%s*{(.-)}") or ""

                    for name in hitsLine:gmatch("([^,%s]+)") do
                        table.insert(hitsounds, name)
                    end
                    for name in bulletsLine:gmatch("([^,%s]+)") do
                        table.insert(bulletsounds, name)
                    end
                end

                for _, v in ipairs(hitsounds) do
                    local path = "Radiance/Assets/hit sounds/" .. v
                    if not isfile(path) then
                        local url = "https://crewbattler.club/sounds/hitsounds/" .. v
                        local ok, data = pcall(httpGet, url)
                        if ok and data then
                            writefile(path, data)
                        end
                    end
                end

                for _, v in ipairs(bulletsounds) do
                    local path = "Radiance/Assets/bullet sounds/" .. v
                    if not isfile(path) then
                        local url = "https://crewbattler.club/sounds/bulletsounds/" .. v
                        local ok, data = pcall(httpGet, url)
                        if ok and data then
                            writefile(path, data)
                        end
                    end
                end
            end

            makeResources()
        end

        files()
    end
    function Find(tbl, options)
        assert(#options~=0)
        local c = 1
        local f = {}
        for i, v in next, tbl do
            local str = options[c]
            if str and v == str then
                c += 1 
                table.insert(f, i)
            end
        end
        return f
    end
    synfunction()
    createfiles()
    tagService()
    send_console_developer("ended crewbattlerload")
    global.Find = Find
    global.registry.log = send_console_developer
end
crewbattlerload()

local createloop = global.createloop
local getreg = global.functions.getreg
local getupvalues = global.functions.getupvalues
local getconstants = global.functions.getconstants
local setconstant = global.functions.setconstant
local getupvalue = global.functions.getupvalue
local setupvalue = global.functions.setupvalue
local setreadonly = global.functions.setreadonly
local newcclosure = global.functions.newcclosure
local setclipboard = global.functions.setclipboard
local islclosure = global.functions.islclosure
local setscriptable = global.functions.setscriptable
local is_synapse_function = global.functions.is_synapse_function
-- objects can be missing right after a server hop, so ignore nil targets instead of erroring
local _firetouchinterest = global.functions.firetouchinterest
local function firetouchinterest(part, ...)
    if part == nil then return end
    return _firetouchinterest(part, ...)
end
local _fireclickdetector = global.functions.fireclickdetector
local function fireclickdetector(detector, ...)
    if detector == nil then return end
    return _fireclickdetector(detector, ...)
end
local getconnections = global.functions.getconnections
local set_thread_identity = global.functions.set_thread_identity
local sethiddenproperty = global.functions.sethiddenproperty
local getgc = global.functions.getgc
local getsynasset = global.functions.getsynasset

local function loadup()
    local log = global.registry.log
    if not log then error("Configuration failure") end
    log("starting loadup")
    local function noVirtualization()
        -- the metatable hook (mthooks.lua) reads the shared state from the global
        -- `icetray`; make sure both names point at our state before it runs so a
        -- rename can't silently feed it an empty table
        local genv = (getgenv and getgenv()) or (getrenv and getrenv())
        if genv then
            genv.icetray = global
            genv.crewbattler = global
        end
        -- try our own hosted copy first, then the upstream one; never let a bad
        -- fetch / parse / runtime error take down loadup
        local sources = {
            "https://crewbattler.club/mthooks.lua",
            "https://raw.githubusercontent.com/piglex9/icetray4/main/src/mthooks.lua",
        }
        for _, url in ipairs(sources) do
            if global.mthooks then break end
            local ok, src = pcall(function() return game:HttpGet(url) end)
            if ok and type(src) == "string" and #src > 0 then
                local chunk = loadstring(src)
                if chunk then pcall(chunk) end
            end
            if not global.mthooks then log(("mthooks source failed: %s"):format(url)) end
        end
        -- bounded wait: a hook that never sets the flag must not hang the loader forever
        local deadline = tick() + 10
        while not global.mthooks do
            if tick() > deadline then
                log("mthooks unavailable; continuing without metatable hooks")
                break
            end
            task.wait()
        end
    end
    noVirtualization()
    local function playerCharacter()
        local function onCharacterAdded(char) client.playerCharacter = player.Character end
        player.CharacterAdded:connect(onCharacterAdded)
        if player.Character then
            client.playerCharacter = player.Character
        else
            client.playerCharacter = player:WaitForChild("Character")
        end
    end
    playerCharacter()
    local function registry()
        local function funcs()
            local _equipConditions = client.modules.inventoryItemSystem._equipConditions
            local _unequipConditions = client.modules.inventoryItemSystem._unequipConditions
            for i,v in next, _equipConditions do
                local upvs, con = getupvalues(v), getconstants(v)
                if #upvs == 2 then global.registry.antiEquip = upvs end
                if table.find(con, "IsCrawling") then global.registry.iscrawling = v end
            end
            table.insert(_equipConditions, function()
                if global.is_instant_reloading then return false end
                return true
            end)
            table.insert(_unequipConditions, function()
                if global.is_instant_reloading then return false end
                return true
            end)
            local onPressed = getupvalue(client.modules.crawlButton.onPressed, 1)
            if onPressed then
                global.registry.buttons = onPressed

                if type(onPressed.attemptToggleCrawling) == "function" then
                    local lastDuckTick = getupvalue(onPressed.attemptToggleCrawling, 9)
                    if lastDuckTick then
                        global.registry.lastDuckTick = lastDuckTick
                    else
                        log("Wrong upvalue index for lastDuckTick")
                    end
                else
                    log("attemptToggleCrawling not found on onPressed")
                end
            else
                log("Failed to get onPressed from crawlButton.onPressed")
            end
            local falling = getupvalue(client.modules.falling.Init, 15)
            if falling then
                global.registry.falling = falling
            else
                log("Wrong upvalue for falling")
            end
            local trainSystem = client.modules.trainSystem
            local em = getupvalue(trainSystem.Init, 2)
            if em and type(em) == "table" then
                for i,v in next, em do
                    if type(v) == "function" then
                        if islclosure(v) then
                            local con = getconstants(v)
                            if table.find(con, "Stunned") then global.registry.stunnedFunc = v end
                            if table.find(con, "assert", 1) and table.find(con, "Nuke", 3) and table.find(con, "Shockwave", 3) then global.registry.nukecontrol = v end
                        end
                        for i2,v2 in next, getupvalues(v) do
                            if type(v2) == "function" and islclosure(v2) then
                                local con = getconstants(v2)
                                if table.find(con, "error") == 1 then global.registry.isInMuseumRobbery = v2 end
                            end
                        end
                    end
                end
            else
                log("Wrong upvalue for em")
            end
            local function hasKey()
                local inventoryItemSystem = client.modules.inventoryItemSystem
                local gameUtil = client.modules.gameUtil
                local settings = client.modules.settings
                if gameUtil.Team == settings.EnumTeam.Police then return true end
                return inventoryItemSystem.playerHasItem(player, "Key")
            end
            global.registry.hasKey = hasKey
            local getreg = getreg()
            for i,v in next, getreg do
                if type(v) == "function" then
                    for i2,v2 in next, getupvalues(v) do
                        if type(v2) == "table" then
                            if rawget(v2, "Nitro") and rawget(v2, "NitroLastMax") then global.registry.nitro = v2 end
                            for i3,v3 in next, v2 do
                                if type(v3) == "table" and rawget(v3, "Tag") and rawget(v3, "Part") and type(rawget(v3, "Fun")) == "function" then
                                    table.insert(global.registry.doors, v3.Fun)
                                end
                            end
                        end
                        if type(v2) == "function" then
                            if islclosure(v2) then
                                local con = getconstants(v2)
                                if table.find(con, "ShouldEject") then global.registry.shouldEject = v2 end
                            end
                            for i3,v3 in next, getupvalues(v2) do
                                if type(v3) == "function" and islclosure(v3) then
                                    local con = getconstants(v3)
                                    if table.find(con, "Source") and table.find(con, "Play") then global.registry.playSounds = v3 end
                                end
                            end
                        end
                    end
                    if islclosure(v) then
                        if not is_synapse_function(v) then
                            for i2,v2 in next, getupvalues(v) do
                                if type(v2) == "table" and type(rawget(v2, "Fireworks")) == "function" then
                                    global.registry.fireworks = v2
                                end
                            end
                        end
                    end
                end
            end
            for i,v in next, global.registry.doors do
                if type(v) == "function" and #getupvalues(v) >= 4 then
                    local o = getupvalue(v, 4)
                    setupvalue(v, 4, function(...)
                        if global.ui_status.master_switch_open_doors then return true end
                        return o(...)
                    end)
                end
            end
            return true
        end
        local funcs = funcs()
        while true do
            if funcs then break end
            task.wait()
        end
        local function shouldFuncs()
            local charBinder = client.modules.charBinder
            local _fn = getupvalue(getupvalue(charBinder:GetClassAddedSignal()._handlerListHead._fn,1),2)
            -- _fn is the CircleAction Callback (u820); pickpocket/breakout dispatch through
            -- it via a flag object, so those stay as _fn. Arrest calls the inner handcuffs
            -- function directly. In CH4 that moved from upvalue 1 -> 3 (UseHandcuffs/u812,
            -- which reads p.PlayerName). Confirmed against the CH4 LocalScript source.
            global.registry.shouldPickpocket = _fn
            global.registry.shouldBreakout = _fn
            local arrest = getupvalue(_fn, 3)
            if type(arrest) ~= "function" then
                -- layout shifted again: fall back to the first function upvalue
                local ok, ups = pcall(getupvalues, _fn)
                if ok and type(ups) == "table" then
                    for _, v in next, ups do
                        if type(v) == "function" then arrest = v break end
                    end
                end
            end
            if type(arrest) == "function" then global.registry.shouldArrest = arrest end
        end
        shouldFuncs()
        local function generateJobId(isTradeWorld)
            local placeId
            if isTradeWorld then
                placeId = "9780994092"
            elseif table.find({606849621, 6898041828, 17190407811, 108098425719662}, game.PlaceId) then
                placeId = tostring(game.PlaceId)
            else
                return ""
            end

            local jobids = {}
            local currentJob = tostring(game.JobId)
            -- roblox.com blocks game:HttpGet, so prefer the executor's request fn for it
            local function httpGet(url, preferRequest)
                local requestFn = request or (syn and syn.request) or (http and http.request)
                if preferRequest and requestFn then
                    local ok, result = pcall(requestFn, {Url = url, Method = "GET"})
                    if ok and result then return result.Body or result.body end
                end
                local ok, body = pcall(function()
                    if game.HttpGetAsync then return game:HttpGetAsync(url) end
                    if game.HttpGet then return game:HttpGet(url) end
                end)
                if ok and body then return body end
                if requestFn then
                    local ok2, result = pcall(requestFn, {Url = url, Method = "GET"})
                    if ok2 and result then return result.Body or result.body end
                end
                return nil
            end
            -- primary: roblox's own live public-server list (never stale)
            local cursor = ""
            for _ = 1, 5 do
                local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100"):format(placeId)
                if cursor ~= "" then url = url .. "&cursor=" .. cursor end
                local body = httpGet(url, true)
                if not body then break end
                local ok, data = pcall(function() return httpservice:JSONDecode(body) end)
                if not ok or type(data) ~= "table" or type(data.data) ~= "table" then break end
                for _, srv in next, data.data do
                    if type(srv) == "table" and srv.id and tostring(srv.id) ~= currentJob
                        and tonumber(srv.playing) and tonumber(srv.maxPlayers)
                        and tonumber(srv.playing) < tonumber(srv.maxPlayers) then
                        table.insert(jobids, srv.id)
                    end
                end
                cursor = type(data.nextPageCursor) == "string" and data.nextPageCursor or ""
                if cursor == "" or #jobids > 60 then break end
            end
            -- fallback: third-party aggregator
            if #jobids < 1 then
                local body = httpGet(("https://apiroblox.pages.dev/api/roblox/%s?type=all"):format(placeId))
                if body then
                    local ok, api = pcall(function() return httpservice:JSONDecode(body) end)
                    if ok and type(api) == "table" and api.Success and type(api.Data) == "table" then
                        for _, v in next, api.Data do
                            if v.playing ~= nil and v.playing < 29 and tostring(v.id) ~= currentJob then
                                table.insert(jobids, v.id)
                            end
                        end
                    end
                end
            end
            if #jobids < 1 then
                log("No JobId could be found. Try generating again!")
                return ""
            end
            return jobids[math.random(1, #jobids)]
        end
        local markerColors = {
            Prisoner = Color3.fromRGB(253, 148, 81);
            Police = Color3.fromRGB(84, 215, 253);
            Criminal = Color3.fromRGB(253, 100, 30);
            Airdrop = Color3.fromRGB(148, 0, 211);
            Football = Color3.fromRGB(68, 186, 13);
            NPCs = Color3.fromRGB(140, 182, 210);
            Bounty = Color3.fromRGB(255, 255, 50);
            Target = Color3.fromRGB(179, 182, 255);
        }
        local markerSystem = client.modules.playerMarkerSystem
        local function constructMarker(player) return markerSystem._constructMarker(player) end
        local function setColor(player, color) return markerSystem._setColor(player, color) end
        local function destructMarker(player) return markerSystem._destructMarker(player) end
        local function doesMarkerExist(player) return markerSystem._doesMarkerExist(player) end
        local function getLocalVehicle()
            local module = client.modules.vehicle.GetLocalVehiclePacket()
            if module and module.IsPassenger then return false end
            return module
        end
        local function getHeliRope(getLocalVehicle)
            if getLocalVehicle then
                if getLocalVehicle.Model:FindFirstChild("Preset") and getLocalVehicle.Model.Preset:FindFirstChild("RopePull") then return getLocalVehicle.Model.Preset.RopePull end
            end
            return false
        end
        local function canLockVehicle() return client.modules.vehicle.canLocalLock() end
        local function toggleLock() return client.modules.vehicle.toggleLocalLocked() end
        local function passengerKick(player) client.modules.vehicle.attemptPassengerEject(player) end
        local function getPlayerVehicle(player, isArresting)
            for i,v in next, client.descendants.vehicles:GetChildren() do
                local seat = v:FindFirstChild("Seat")
                local passenger = v:FindFirstChild("Passenger")
                local sname = seat and seat:FindFirstChild("PlayerName")
                if sname and sname.Value == player.Name then
                    if isArresting then return v.Seat end
                    return v
                end
                local pname = passenger and passenger:FindFirstChild("PlayerName")
                if pname and pname.Value == player.Name then
                    if isArresting then return v.Passenger end
                    return v
                end
            end
            return false
        end
        local function getPartsInRegion(posX, posY, posZ, minX, minY, minZ, maxX, maxY, maxZ)
            if posX < maxX and posX > minX then
                if posZ < maxZ and posZ > minZ then
                    if posY < maxY and posY > minY then return true  end
                end
            end
            return false
        end
        local function isVulnerable(p1, p2, settings)
            p1 = tostring(p1)
            p2 = tostring(p2)
            if p1 and p2 then
                if p1 == "Police" then
                    if p2 == "Criminal" then return true end
                    if p2 == "Prisoner" then
                        if settings and settings.prisonerTarget then return global.ui_status.allow_target_prisoner end
                        return false
                    end
                end
                if p1 == "Prisoner" then
                    if p2 == "Criminal" then return false end
                    if p2 == "Police" then return true end
                end
                if p1 == "Criminal" then
                    if p2 == "Prisoner" then return false end
                    if p2 == "Police" then return true end
                end
            end
        end
        local function sounds()
            for i,v in next, client.modules.settings.Sounds do table.insert(global.registry.sounds, i) end
        end
        task.spawn(sounds)
        local function hasItemEquipped(item)
            local isItemEquipped = client.modules.itemSystem.GetLocalEquipped()
            return isItemEquipped and isItemEquipped.inventoryItemValue.name == item
        end
        local function getEquippedItem() return client.modules.itemSystem.GetLocalEquipped() end
        local function unequipAll() return client.modules.inventoryItemSystem.unequipAll() end
        local function getInventoryItemsFor(player)
            if not player then return false end
            local inventoryItemSystem = client.modules.inventoryItemSystem
            return inventoryItemSystem.getInventoryItemsFor(player)
        end
        local function equip(item)
            if not client.playerCharacter then return false end
            local success, err = pcall(function()
                local hasItemEquipped = global.registry.hasItemEquipped
                for i,v in next, client.reg.getInventoryItemsFor do
                    if v.obj.name == item and not hasItemEquipped(item) and v.AttemptSetEquipped then
                        v:AttemptSetEquipped(true)
                    end 
                end
            end)
            if not success then
                warn(("Something errored when trying to equip item `%s`"):format(item))
                log(("Something errored when trying to equip item `%s`"):format(item))
            end
        end
        local function neverDropItems() return {"Taser", "Handcuffs", "RoadSpike", "Bag", "Crate", "Gem", "MansionInvite"} end
        local function dropGun()
            local hasItemEquipped = global.registry.hasItemEquipped
            local neverDropItems = global.registry.neverDropItems()
            for i,v in next, client.reg.getInventoryItemsFor do
                if hasItemEquipped(v.obj.name) then
                    if not table.find(neverDropItems, v.obj.name) then v:AttemptDrop() end
                end
            end
        end
        local function call_elevator_to_floor(floor)
            local casino = workspace:FindFirstChild("Casino")
            if not casino then return false end
            local elevatorCar = casino.Elevator.Car:GetDescendants()
            if not elevatorCar then return false end
            local elevatorFloors = casino.Elevator.Floors:GetDescendants()
            if not elevatorFloors then return false end
            floor = tostring(floor)
            local function clickDetector(floor)
                if floor == 4 then
                    for i,v in next, elevatorCar do
                        if v.Name == "4" and v:FindFirstChild("ClickDetector") then fireclickdetector(v.ClickDetector) end
                    end
                    return true
                end
                for i,v in next, elevatorFloors do
                    if v.Name == "Call" and v.Parent.Name == tostring(floor) then fireclickdetector(v.ClickDetector) end
                end
            end
            if floor == "The Roof" then clickDetector(4) end
            if floor == "Security" then clickDetector(3) end
            if floor == "Ground" then clickDetector(2) end
            
            if floor == "Vaults" then clickDetector(1) end
        end
        local function checkWallBeforePenetration(target)
            if not target then return false end
            if workspace:FindFirstChild("Drop") then
                if target:IsDescendantOf(workspace.Drop) then return true end
            end
            if workspace:FindFirstChild("MansionRobbery") then
                if target:IsDescendantOf(workspace.MansionRobbery) then return true end
            end
            local localChar = client.playerCharacter
            local ignorelist = global.ignorelist
            local camera = workspace.CurrentCamera
            local char = target.Character
            if not char or not localChar then return false end
            local function rayCheck(target)
                local result = true
                local dist = (camera.CFrame.Position - target.Head.Position).magnitude
                local unit = (target.Head.Position - camera.CFrame.Position).unit
                local list = {camera, client.playerCharacter, global.LocalMouse.TargetFilter}
                for i,v in next, ignorelist do table.insert(list, v) end
                local ray = Ray.new(camera.CFrame.Position, unit * dist)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, list) -- @ asta am furat o de undeva dar nu mai tin minte de unde
                if hit and not hit:IsDescendantOf(target) then
                    result = false
                    if not hit.CanCollide and hit.ClassName ~= Terrain or hit:IsDescendantOf(client.descendants.vehicles) then ignorelist[#ignorelist + 1] = hit end
                end
                return result
            end
            return rayCheck(char)
        end
        local isAnchored = false
        local last_used_shoot = tick()
        local function shootGun()
            if global.ui_status.spam_drop_guns then return false end
            if global.is_instant_reloading then return false end
            if global.is_registering_item then return false end
            local function attemptShoot(gun)
                if not gun.ShootCheckConditions then
                    return function() end
                end
                pcall(function()
                    client.modules.gun._attemptShoot(gun)
                end)
            end
            local getEquippedItem = client.reg.getEquippedItem
            if not getEquippedItem then return false end
            if not getEquippedItem.BulletEmitter then return false end
            if tick() - last_used_shoot < 0.2 and getEquippedItem.__ClassName == "Sniper" then return false end
            last_used_shoot = tick()
            attemptShoot(getEquippedItem)
        end
        local function canUseTaser(taser)
            local utils = client.modules.inventoryItemUtils
            return utils.getAttr(taser.inventoryItemValue, "NextUse") > 0
        end
        local function useTaser()
            local function tase(taser)
                global.AI_TASER_USE = true
                task.delay(0.5, function()
                    global.AI_TASER_USE = false
                end)
                return client.modules.taser.Tase(taser, taser) --@nu inteleg de ce trebuie `taser` pus de 2 ori. 
            end
            local getEquippedItem = client.reg.getEquippedItem
            if not getEquippedItem then return false end
            tase(getEquippedItem)
        end
        local function getRobberyStatus(robbery)
            local enums = {
                "OPENED";
                "STARTED";
                "CLOSED";
            }
            
            local consts = client.modules.robberyConsts
            local robberystate = repl:FindFirstChild("RobberyState")
            if not consts or not consts.ENUM_ROBBERY or not robberystate then return "?" end
            local wanted = tostring(robbery):lower()
            local function read(enum)
                if enum == nil then return nil end
                local state = robberystate:FindFirstChild(tostring(enum))
                if state then return enums[state.Value] end
                return nil
            end
            local direct = read(consts.ENUM_ROBBERY[robbery] or consts.ENUM_ROBBERY[tostring(robbery):upper()] or robbery)
            if direct then return direct end
            if consts.DATA_ROBBERY then
                for enum, data in next, consts.DATA_ROBBERY do
                    if tostring(enum):lower() == wanted or type(data) == "table" and (tostring(data.key):lower() == wanted or tostring(data.Name):lower() == wanted or tostring(data.name):lower() == wanted) then
                        local status = read(enum)
                        if status then return status end
                    end
                end
            end
            if consts.LIST_ROBBERY then
                for i,v in next, consts.LIST_ROBBERY do
                    local enum = consts.ENUM_ROBBERY[v]
                    if enum and (tostring(v):lower() == wanted or tostring(enum):lower() == wanted) then
                        local status = read(enum)
                        if status then return status end
                    end
                end
            end
            return "?"
        end
        local function getClosestCrate()
            local char = client.playerCharacter
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local plane = workspace:FindFirstChild("Plane")
            if not plane then return false end
            local crates = plane:FindFirstChild("Crates")
            if not crates then return false end
            local target, dist = nil, math.huge
            for i,v in next, crates:GetDescendants() do
                if v:IsA("BasePart") then
                    local magnitude = (root.Position - v.Position).magnitude
                    if magnitude < dist then
                        dist = magnitude
                        target = v
                    end
                end
            end
            return target
        end
        local function hasMansioninvite() return table.find(client.reg.resolveEquippedItems, "MansionInvite") end
        local function getKeycode()
            local casino = workspace:FindFirstChild("Casino")
            if not casino then return "" end
            local parts = {}
            local codes = casino.RobberyDoor.Codes
            local code = ""
            for i,v in next, codes:GetDescendants() do
                if v:IsA("TextLabel") and #v.Text ~= 0 then
                    table.insert(parts, {
                        textLabel = v;
                        part = v.Parent.Parent;
                    })
                end
            end
            table.sort(parts, function(x, y)
                return x.part.Position.z > y.part.Position.z
            end)
            for i,v in next, parts do code = code .. v.textLabel.Text end
            return code or ""
        end
        local function getCasinoDoor()
            local char = client.playerCharacter
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local casino = workspace:FindFirstChild("Casino")
            if not casino then return false end
            local robberyDoor = casino.RobberyDoor:GetDescendants()
            for i,v in next, robberyDoor do
                if v.Name == "Region" then
                    if (v.Position - root.Position).magnitude < 15 then return true end
                end
            end
            return false
        end
        local mostWanted = workspace:FindFirstChild("BountyBoard")
        local function getPlayersWithBounty()
            local plrs = {}
            if not mostWanted then return plrs end

            local board = mostWanted:FindFirstChild("Board")
            if not board then return plrs end

            local mw = board:FindFirstChild("MostWanted")
            if not mw then return plrs end

            local innerBoard = mw:FindFirstChild("Board")
            if not innerBoard then return plrs end

            local playerFrame = innerBoard:FindFirstChild("PlayerFrame")
            if not playerFrame then return plrs end

            -- Extract user ID from the ImageLabel thumbnail URL
            local imageLabel = playerFrame:FindFirstChild("ImageLabel")
            if not imageLabel then return plrs end

            local image = imageLabel.Image
            local userId = image:match("id=(%d+)")
            if not userId then return plrs end

            userId = tonumber(userId)

            -- Match by user ID against connected players
            for _, v2 in next, client.players do
                if v2.UserId == userId and not table.find(plrs, v2) then table.insert(plrs, v2) end
            end

            return plrs
        end
        local function hasInVehicleTag(char)
            if char and char:FindFirstChild("InVehicle") then return true end
            return false
        end
        local function getSeats()
            local vehicle = client.modules.vehicle
            local plrs = {}
            local getVehicle = client.reg.getLocalVehicle
            if getVehicle then
                local getSeats = vehicle.getSeats(getVehicle.Model)
                for i,v in next, getSeats do
                    if v.Player ~= player then table.insert(plrs, v) end
                end
            else
                return nil
            end
            return plrs
        end
        local function getClosestPlayer(range, settings)
            local char = client.playerCharacter
            if not char then return false end
            local rootplr = char.PrimaryPart
            if not rootplr then
                return false
            end 
            local isVulnerable = global.registry.isVulnerable
            local target, dist = nil, range
            for i,v in next, client.players do
                local char = v.Character
                if char and isVulnerable(player.Team, v.Team, {
                    prisonerTarget = global.ui_status.allow_target_prisoner
                }) then
                    local hum = char:FindFirstChild("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root and hum and hum.Health > 0 then
                        local magnitude = (root.Position - rootplr.Position).magnitude
                        if magnitude < dist then
                            target = v
                            dist = magnitude
                        end
                    end
                end
            end
            return target
        end
        local function getAllClosePlayers(range)
            local char = client.playerCharacter
            if not char then return false end
            local rootplr = char.PrimaryPart
            if not rootplr then
                return false
            end 
            local isVulnerable = global.registry.isVulnerable
            local targets = {}
            for i,v in next, client.players do
                local char = v.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local distance = (root.Position - rootplr.Position).magnitude
                        if distance < range then table.insert(targets, v) end
                    end
                end
            end
            return targets
        end
        local function getClosestPlayerWithVehicleTag(range)
            local char = client.playerCharacter
            if not char then return false end
            local rootplr = char:FindFirstChild("HumanoidRootPart")
            if not rootplr then return false end
            local target = {}
            for i,v in next, client.players do
                if v ~= player then
                    local char = v.Character
                    if char and hasInVehicleTag(char) then
                        local hum = char:FindFirstChild("Humanoid")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if hum and root and hum.Health > 0 then
                            local distance = player:DistanceFromCharacter(root.Position) -- (root.Position - rootplr.Position).magnitude
                            if distance < range then table.insert(target, v) end
                        end
                    end
                end
            end
            return target
        end
        local function getClosestPlayerForBreakouts(range)
            if tostring(player.Team) == "Police" then return false end
            local char = client.playerCharacter
            if not char then return false end
            local rootplr = char:FindFirstChild("HumanoidRootPart")
            if not rootplr then return false end
            local target, dist = nil, 0
            for i,v in next, client.players do
                if v ~= player then
                    if tostring(v.Team) ~= "Police" then
                        local char = v.Character
                        if char and v.Folder:FindFirstChild("Cuffed") then
                            local hum = char:FindFirstChild("Humanoid")
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if hum and root and hum.Health > 0 then
                                local distance = player:DistanceFromCharacter(root.Position) -- (root.Position - rootplr.Position).magnitude
                                if distance < range then target = v end
                            end
                        end
                    end 
                end
            end
            return target
        end
        local function getClosestVulnerablePlayer(range)
            local char = client.playerCharacter
            if not char then return false end
            local root = char.PrimaryPart
            if not root then return false end
            local isVulnerable = global.registry.isVulnerable
            local target, dist = nil, range
            for i,v in next, client.players do
                if v ~= player then
                    local char = v.Character
                    if char and not v.Folder:FindFirstChild("Cuffed") then
                        local hum = char:FindFirstChild("Humanoid")
                        local primaryPart = char.PrimaryPart
                        if hum and hum.Health > 0 and primaryPart then
                            if isVulnerable(player.Team, v.Team) then
                                local distance = (root.Position - primaryPart.Position).magnitude
                                if distance < dist then
                                    dist = distance
                                    target = v
                                end
                            end
                        end
                    end
                end
            end
            return target
        end
        local function getClosestPlayerByFov(range, isJetSearch)
            local char = client.playerCharacter
            if char then
                local rootplr = char:FindFirstChild("HumanoidRootPart")
                if rootplr then
                    local camera = workspace.CurrentCamera
                    local mouse = global.LocalMouse
                    local mousepos = Vector2.new(mouse.X, mouse.Y)
                    local gml = uis:GetMouseLocation()
                    local target, dist = nil, math.huge
                    local allow_target_boss = global.ui_status.allow_target_boss
                    local allow_target_npcs = global.ui_status.allow_target_npcs
                    local allow_target_prisoner = global.ui_status.allow_target_prisoner
                    local force_target = global.aimbot.force_target
                    if force_target then
                        local max_dist = global.ui_status.max_distance or 500
                        local char = force_target.Character
                        if char then
                            if char:IsDescendantOf(workspace) then
                                local hum = char:FindFirstChild("Humanoid")
                                local root = char.PrimaryPart
                                if hum and root and hum.Health > 0 then
                                    if (root.Position - rootplr.Position).magnitude < 3500 then return force_target end
                                end
                            end
                        end
                    end 
                    local mansionRobbery = workspace:FindFirstChild("MansionRobbery")
                    if allow_target_boss then
                        if mansionRobbery then
                            local boss = mansionRobbery:FindFirstChild("ActiveBoss")
                            if boss then
                                local hum = boss:FindFirstChild("Humanoid")
                                local root = boss:FindFirstChild("HumanoidRootPart")
                                if hum and root and hum.Health > 0 then
                                    if (root.Position - rootplr.Position).magnitude < 300 then return boss end
                                end
                            end
                        end
                    end
                    if allow_target_npcs then
                        local drop = workspace:FindFirstChild("Drop")
                        if drop then
                            if #workspace.GuardNPCPlayers:GetChildren() > 0 then
                                for i,v in next, workspace.GuardNPCPlayers:GetChildren() do
                                    if v and v.Value then
                                        local hum = v.Value:FindFirstChild("Humanoid")
                                        local root = v.Value:FindFirstChild("HumanoidRootPart")
                                        if hum and root and hum.Health > 0 then
                                            local _, onscreen = camera:WorldToScreenPoint(root.Position)
                                            if onscreen then
                                                local dis = (Vector2.new(gml.X, gml.Y) - Vector2.new(_.X, _.Y)).magnitude
                                                if dis < dist and dis < range*1.5 and (root.Position - rootplr.Position).magnitude < 300 then
                                                    dist = dis
                                                    target = v.Value
                                                end
                                            end
                                        end
                                    end
                                end
                                if target then return target end
                            end
                        end
                        if mansionRobbery then
                            local guardsFolder = mansionRobbery.GuardsFolder
                            if #guardsFolder:GetChildren() > 0 then
                                for i,v in next, guardsFolder:GetChildren() do
                                    local hum = v:FindFirstChild("Humanoid")
                                    local root = v:FindFirstChild("HumanoidRootPart")
                                    if hum and root and hum.Health > 0 then
                                        local _, onscreen = camera:WorldToScreenPoint(root.Position)
                                        if onscreen then
                                            local dis = (Vector2.new(gml.X, gml.Y) - Vector2.new(_.X, _.Y)).magnitude
                                            if dis < dist and dis < range*1.5 and (root.Position - rootplr.Position).magnitude < 300 then
                                                dist = dis
                                                target = v
                                            end
                                        end
                                    end
                                end
                                if target then return target end
                            end
                        end
                    end
                    local max_dist = global.ui_status.max_distance or 500
                    for i,v in next, client.players do
                        if v ~= player then
                            if not isJetSearch and isVulnerable(player.Team, v.Team, {
                                prisonerTarget = global.ui_status.allow_target_prisoner
                            }) or isJetSearch and true then
                                local char = v.Character
                                if char and char:IsDescendantOf(workspace) then
                                    local hum = char:FindFirstChild("Humanoid")
                                    local root = char:FindFirstChild("HumanoidRootPart")
                                    if hum and root and hum.Health > 0 then
                                        local _, onscreen = camera:WorldToScreenPoint(root.Position)
                                        if onscreen then
                                            local dis = (Vector2.new(gml.X, gml.Y) - Vector2.new(_.X, _.Y)).magnitude
                                            local dis_ = (root.Position - rootplr.Position).magnitude
                                            if dis < dist and dis_ < max_dist then 
                                                dist = dis
                                                target = v
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return target
                end
            end
        end
        local function getClosestHeliPickup(part, range)
            local char = client.playerCharacter
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local getLocalVehicle = client.reg.getLocalVehicle
                    if getLocalVehicle then
                        local getHeliRope = global.registry.getHeliRope(getLocalVehicle)
                        if getHeliRope then
                            local target
                            local vehicleLinkUtils = client.modules.vehicleLinkUtils
                            local geomUtils = client.modules.geomUtils
                            for i,v in next, collectionservice:GetTagged("HeliPickup") do
                                if v ~= getLocalVehicle.Model then
                                    local getPrimaryPart = vehicleLinkUtils.getPrimaryPart(v)
                                    if getPrimaryPart then
                                        local mag = (part.Position - geomUtils.closestPointInPart(getPrimaryPart, part.Position)).magnitude
                                        if mag < range then
                                            range = mag
                                            target = v
                                        end
                                    end
                                end
                            end
                            return target
                        end 
                    end
                end
            end
            return false
        end
        local function getClosestPlayerWithNoHandcuffs(range, bool)
            local char = client.playerCharacter
            if char then
                local rootplr = char:FindFirstChild("HumanoidRootPart")
                if rootplr then
                    local target
                    for i,v in next, client.players do
                        if v ~= player then
                            if tostring(v.Team) ~= tostring(player.Team) and tostring(v.Team) ~= "Prisoner" then
                                local char = v.Character
                                if char then
                                    local hum = char:FindFirstChild("Humanoid")
                                    local root = char:FindFirstChild("HumanoidRootPart")
                                    if hum and root and hum.Health > 0 then
                                        if (root.Position - rootplr.Position).magnitude < range then
                                            if bool and v.Folder:FindFirstChild("Cuffed") then return v end
                                            if not v.Folder:FindFirstChild("Cuffed") then target = v end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return target
                end
            end
        end
        local function getClosestPlayerWithTagPolice(range)
            local char = client.playerCharacter
            if not char then return false end
            local rootplr = char:FindFirstChild("HumanoidRootPart")
            if not rootplr then return false end
            local closest, dist = nil, range
            for i,v in next, client.players do
                if v ~= player then
                    if tostring(v.Team) == "Police" and tostring(player.Team) ~= tostring(v.Team) then
                        local char = v.Character
                        if char then
                            local hum = char:FindFirstChild("Humanoid")
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if hum and root and hum.Health > 0 then
                                local magnitude = (root.Position - rootplr.Position).magnitude
                                if magnitude < range then
                                    closest = v
                                    dist = magnitude
                                end
                            end
                        end
                    end
                end
            end
            return closest
        end
        local function getClosestDroppedCash(range)
            local char = client.playerCharacter
            if not char then return false end
            local root = char.PrimaryPart
            if not root then return false end
            local cash = collectionservice:GetTagged("CashDrop")
            local closest, dist = nil, range
            for i,v in next, cash do
                if v and v.PrimaryPart then
                    local magnitude = (root.Position - v.PrimaryPart.Position).magnitude
                    if magnitude < range then
                        closest = v.PrimaryPart
                        dist = magnitude
                    end
                end
            end
            return closest
        end
        local function getBattleInvites()
            local invites = {}
            for i,v in next, player.CrewBattleInvitesFolder:GetChildren() do table.insert(invites, v.Name) end
            return invites
        end
        local function getBattleResponseRemote() return repl.BattleResponseRemote end
        local function getBattleReadyUpRemote() return repl.ReadyUpRemote end
        local function getClanId(self) return player:GetAttribute("CurrentClanId") end
        local function isClanAdmin() return player:GetAttribute("IsPlayerClanAdminCached") end
        local function getClanPlayersOnlineId(self)
            local getClanId = self:getClanId()
            if getClanId then
                local numClanPlayersOnline = repl:FindFirstChild("ClanPlayersOnline")
                if numClanPlayersOnline then
                    local key = numClanPlayersOnline:FindFirstChild(getClanId)
                    if key then return key end
                end
            end
        end
        local function isProjectile(item, settings)
            local settings = settings or {}
            local includeAdditionals = settings.includeAdditionals
            local projectiles = {"C4", "RocketLauncher", "SmokeGrenade", "Grenade", "C4Ammo", "RocketAmmo", includeAdditionals and "Flashlight" or nil, includeAdditionals and "Binoculars" or nil}
            if table.find(projectiles, item) then return true end
            return false
        end
        local function equipOwnedItem(item, unequip)
            global.hideshopui = true
            global.open_shop = true
            local shouldUnequip = unequip or false
            local gunshopgui = player.PlayerGui.GunShopGui
            local container = gunshopgui.Container.Container
            local mainContainer = container.Main.Container
            while true do
                if mainContainer:FindFirstChild("Slider") then break end
                task.wait()
            end
            local resolveOwnedItems = client.reg.resolveOwnedItems
            if isProjectile(item) then
                local sidebar = container.Sidebar
                local projectile = sidebar:FindFirstChild("Projectile")
                if projectile then
                    if table.find(resolveOwnedItems, item) or item == "RocketAmmo" or item == "C4Ammo" then
                        set_thread_identity(2)
                        for _, connection in next, getconnections(projectile.MouseButton1Down) do connection.Function() end
                        set_thread_identity(7)
                        while true do
                            if mainContainer.Slider:FindFirstChild("C4") then break end
                            task.wait()
                        end
                        local slider = mainContainer:FindFirstChild("Slider")
                        if slider then
                            local item = slider:FindFirstChild(item)
                            if item then
                                local action = item.Bottom.Action
                                if action and (shouldUnequip and action.Text == "UNEQUIP") or not shouldUnequip and action and action.Text ~= "UNEQUIP" or item == "RocketAmmo" and action.Text == "$1,000" then
                                    for _, connection in next, getconnections(action.MouseButton1Down) do connection.Function() end
                                end
                            end
                        end
                    end
                end
                global.hideshopui = false
                global.open_shop = false
            else
                local slider = mainContainer:FindFirstChild("Slider")
                if slider then
                    if not table.find(resolveOwnedItems, "Pistol") then
                        local pistol = slider:FindFirstChild("Pistol")
                        if pistol then
                            local action = pistol.Bottom.Action
                            if action and action.Text == "FREE" then
                                for _, connection in next, getconnections(action.MouseButton1Down) do connection.Function() end
                            end
                        end
                    end
                    if table.find(resolveOwnedItems, item) then
                        local weapon = slider:FindFirstChild(item)
                        if weapon then
                            local action = weapon.Bottom.Action
                            if action and (shouldUnequip and action.Text == "UNEQUIP") or not shouldUnequip and action and action.Text ~= "UNEQUIP" then
                                for _, connection in next, getconnections(action.MouseButton1Down) do connection.Function() end
                            end
                        end
                    end
                end
                global.hideshopui = false
                global.open_shop = false
            end
        end
        local function getClanPlayersOnline(self)
            local getClanPlayersOnlineId = self:getClanPlayersOnlineId()
            if getClanPlayersOnlineId then return #getClanPlayersOnlineId:GetChildren() end
            return false
        end
        local function getNextShotPossible() return player:GetAttribute("NextShotPossibleTime") or os.time() end
        local function getClosestCasinoLoot(range)
            local char = client.playerCharacter
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local casino = workspace:FindFirstChild("Casino")
            if not casino then return false end
            for i,v in next, casino.Loots:GetChildren() do
                if (v.Position - root.Position).magnitude < range then return v end
            end
            return false
        end
        local function getClosestComputer(range)
            local char = client.playerCharacter
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local casino = workspace:FindFirstChild("Casino")
            if not casino then return false end
            local closest, dist = nil, range
            for i,v in next, casino.Computers:GetDescendants() do
                if v.Name == "Computer" then
                    local display = v:FindFirstChild("Display")
                    if tostring(display.BrickColor) == "Really black" or tostring(display.BrickColor) == "Really red" then
                        local magnitude = (root.Position - display.Position).magnitude
                        if magnitude < range then
                            closest = v
                            dist = magnitude
                        end
                    end
                end
            end
            return closest
        end
        local function getClosestBankDoor(range)
            local char = client.playerCharacter
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local banks = workspace:FindFirstChild("Banks")
            if not banks then return false end
            for i,v in next, banks:GetDescendants() do
                if v:IsA("Part") and v.Name == "BankDoor" then
                    if (v.Position - root.Position).magnitude < range then return v end
                end
            end
        end
        local function getClosestTriggerDoor(range)
            local char = client.playerCharacter
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local banks = workspace:FindFirstChild("Banks")
            if not banks then return false end
            for i,v in next, banks:GetDescendants() do
                if v.Name == "TriggerDoor" then
                    if (v.Position - root.Position).magnitude < range then return v end
                end
            end
            return false
        end
        local function resolvePowerplant(flow)
            local function shiftGrid(delta)
                for _, grid in ipairs(flow.Grid) do
                    for n = 1, #grid do grid[n] = grid[n] + delta end
                end
            end
            local function add1() shiftGrid(1) end
            local function remove1() shiftGrid(-1) end
            -- numberlink solver host (see powerplant-solver/ in the repo)
            local SOLVER_URL = "https://amessage.fly.dev/"
            local function resolveRequest()
                local requestFn = request or (syn and syn.request) or (http and http.request)
                if type(requestFn) ~= "function" then return nil end
                local ok, response = pcall(requestFn, {
                    Url = SOLVER_URL,
                    Method = "POST",
                    Body = httpservice:JSONEncode({ Matrix = flow.Grid }),
                    Headers = { ["Content-Type"] = "application/json" },
                })
                if ok then return response end
                return nil
            end
            local function resolver()
                -- the solver works in +1 space (so 0/empty stays positive); shift, solve,
                -- apply the returned Solution, then shift back for OnConnection
                add1()
                local response = resolveRequest()
                if not response or not response.Body then
                    remove1()
                    return false
                end
                local solved = false
                pcall(function()
                    local body = httpservice:JSONDecode(response.Body)
                    if body and body.Solution then
                        flow.Grid = body.Solution
                        solved = true
                    end
                end)
                remove1()
                -- OnConnection runs our powerwire hook; pcall so a hook error can't abort
                -- the instant solve (this is what forced manual one-by-one solving before)
                if solved then pcall(flow.OnConnection) end
            end
            resolver()
            return true
        end
        local function resolveOwnedItems()
            local tbl = {}
            local items = player:FindFirstChild("Items")
            if not items then return tbl end
            for i,v in next, items:GetChildren() do table.insert(tbl, v.Name) end
            return tbl
        end
        local function resolveEquippedItems()
            local tbl = {}
            local folder = player:FindFirstChild("Folder")
            if not folder then return tbl end
            for i,v in next, folder:GetChildren() do
                if v.Name ~= "SmokeGrenade" then table.insert(tbl, v.Name) end
            end
            return tbl
        end
        local function isInMuseum() return getupvalue(global.registry.isInMuseumRobbery, 1) end
        local function callplane()
            for i,v in next, client.modules.ui.CircleAction.Specs do
                if v.Name == "Call Cargo Plane" then v:Callback(true) end
            end
        end
        local function dieOfFalldamage()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.Health = 0 end
            end
        end
        local function lighting_technology(val)
            pcall(function()
                val = tostring(val)
                global.ui_status.technology = val
                sethiddenproperty(lighting, "Technology", global.ui_status.technology)
            end)
        end
        -- > ( force hit : forge the per-gun "Damage" packet )
        -- A real hit is gun.inventoryItemValue.Damage:FireServer(humanoid, <12 numbers>,
        -- {isHeadshot}). The 12 numbers are a fixed rotation matrix R applied to the shot's
        -- direction (unit), hit position, and the ray's prior-step position, plus three
        -- scalars that pack (bulletLifespanRemaining, GetServerTimeNow) through R as an
        -- anti-replay timestamp. (Reversed from BulletEmitter.lua:326-344 + Gun.lua:393 and
        -- verified by decoding a live Cobalt capture.) We rebuild a valid hit on the
        -- silent-aim target and fire it ourselves; the namecall/FireServer hook piggybacks
        -- this on the real "Shoot" packet (so ammo/rate/timing stay legit) and drops the
        -- game's own Damage packet while force hit is on, so the server sees one hit/shot.
        local FH_R = {
            {0.7483072263887747, -0.6609848067581097, -0.055994465523689876},
            {0.2852117920578111, 0.3968011188544949, -0.8724695443091369},
            {0.5989077797169704, 0.6369049829533174, 0.485449805936436},
        }
        local function normalizeForceHitTarget(target)
            if not target then return nil end
            local char = (typeof(target) == "Instance" and target:IsA("Player")) and target.Character or target
            if typeof(char) ~= "Instance" or not char:IsDescendantOf(workspace) then return nil end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then return nil end
            return char, hum
        end
        local function forceHitResolveTarget()
            -- prefer the explicitly forced target (Silent Aim "Force Target" textbox):
            -- it works regardless of whether the target is on-screen or behind a wall,
            -- which is what "force hit from any point / through walls" needs. The FOV
            -- selector is screen/LOS-based, so it's only the fallback.
            local char, hum = normalizeForceHitTarget(global.aimbot and global.aimbot.force_target)
            if char then return char, hum end
            local resolver = global.registry.getClosestPlayerByFov
            if type(resolver) ~= "function" then return nil end
            local fov = global.ui_status.force_hit_fov or global.ui_status.fov_silentaim or 300
            local ok, target = pcall(resolver, fov)
            if not ok then return nil end
            return normalizeForceHitTarget(target)
        end
        local function forceHitOnShoot(shootRemote)
            if not global.ui_status.force_hit then return end
            if typeof(shootRemote) ~= "Instance" then return end
            local inv = shootRemote.Parent
            if not inv then return end
            -- the firing remote's own parent is the inventory value; don't require it to
            -- match getEquippedItem exactly (that reference can differ). gun is optional,
            -- used only for muzzle origin + bullet speed.
            local gun = client.reg.getEquippedItem
            local dmg = inv:FindFirstChild("Damage")
            if not dmg then return end
            local char, hum = forceHitResolveTarget()
            if not char then return end
            local head = char:FindFirstChild("Head")
            local headshot = global.ui_status.force_hit_headshot ~= false and head ~= nil
            local hitPart = (headshot and head) or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if not hitPart then return end
            local hitPos = hitPart.Position
            local origin
            if gun and gun.Tip and typeof(gun.Tip) == "Instance" then
                origin = gun.Tip.Position
            else
                local cam = workspace.CurrentCamera
                origin = cam and cam.CFrame.Position or hitPos
            end
            local delta = hitPos - origin
            local distance = delta.Magnitude
            if distance < 0.05 then return end
            local dir = delta / distance
            local speed = (gun and gun.Config and gun.Config.BulletSpeed) or 2400
            if speed <= 0 then speed = 2400 end
            -- prior bullet-step position along the ray (the value BulletEmitter encodes)
            local step = math.min(speed / 60, distance)
            local sx, sy, sz = hitPos.X - dir.X * step, hitPos.Y - dir.Y * step, hitPos.Z - dir.Z * step
            local life = 1 - distance / speed
            if life < 0 then life = 0 end
            local now = workspace:GetServerTimeNow()
            local dx, dy, dz = dir.X, dir.Y, dir.Z
            local hx, hy, hz = hitPos.X, hitPos.Y, hitPos.Z
            local r1, r2, r3 = FH_R[1], FH_R[2], FH_R[3]
            -- send through the unhooked FireServer copy so our forged hit isn't dropped
            -- by the Damage branch of the request hook; fall back to namecall if absent.
            local raw = getgenv and getgenv().__cb_rawFireServer
            local send = raw and function(...) return raw(dmg, ...) end
                or function(...) return dmg:FireServer(...) end
            -- mark that we forged a hit this shot so the hook dedupes the game's real
            -- Damage packet (it only drops real hits inside this window, so a shot with
            -- no target still lets a genuine hit through).
            global.__cb_lastForge = tick()
            pcall(function()
                send(
                    hum,
                    r1[1] * sx + r1[2] * sy + r1[3] * sz,   -- v100 = R1.(prior pos)
                    r2[1] * dx + r2[2] * dy + r2[3] * dz,   -- v101 = R2.(dir)
                    r1[1] * hx + r1[2] * hy + r1[3] * hz,   -- v102 = R1.(hit pos)
                    r1[1] * life + r1[2] * now,             -- v103 stamp (R1)
                    r2[1] * sx + r2[2] * sy + r2[3] * sz,   -- v104 = R2.(prior pos)
                    r3[1] * sx + r3[2] * sy + r3[3] * sz,   -- v105 = R3.(prior pos)
                    r2[1] * life + r2[2] * now,             -- v106 stamp (R2)
                    r3[1] * dx + r3[2] * dy + r3[3] * dz,   -- v107 = R3.(dir)
                    r1[1] * dx + r1[2] * dy + r1[3] * dz,   -- v108 = R1.(dir)
                    r3[1] * hx + r3[2] * hy + r3[3] * hz,   -- v109 = R3.(hit pos)
                    r2[1] * hx + r2[2] * hy + r2[3] * hz,   -- v110 = R2.(hit pos)
                    r3[1] * life + r3[2] * now,             -- v111 stamp (R3)
                    {isHeadshot = headshot}
                )
            end)
        end
        global.registry.forceHitOnShoot = forceHitOnShoot
        -- aim spoof: the gun replicates where it's aiming via
        -- ItemSystemGunMouseMovement:FireServer(worldPos); the server relays it and (very
        -- likely) cross-checks it against incoming hits. We return the current force-hit
        -- target's head so the request hook can rewrite that outgoing aim to match the
        -- forged hit, making the hit consistent with our reported aim.
        local function forceHitAimPos()
            if not global.ui_status.force_hit then return nil end
            if global.ui_status.force_hit_aimspoof == false then return nil end
            local char = forceHitResolveTarget()
            if not char then return nil end
            local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            return part and part.Position or nil
        end
        global.registry.forceHitAimPos = forceHitAimPos
        local function getSpeedometer() return player.PlayerGui.AppUI:FindFirstChild("Speedometer") or nil end
        local function isUnderRoof(root)
            local ign
            if workspace:FindFirstChild("Rain") then
                ign = {root.Parent, client.descendants.vehicles, workspace.Rain}
            else
                ign = {root.Parent, client.descendants.vehicles}
            end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = ign
            local ray = workspace:Raycast(root.Position, Vector3.new(0, 1, 0) * 100, params)
            if ray then return true end
            return false
        end
        local function findTarget(name)
            name = tostring(name)
            name = name:lower()
            for i,v in next, client.players do
                local displayName = v.DisplayName:lower()
                local _name = v.Name:lower()
                if displayName == name or _name == name or (_name):find(name) or (displayName):find(name) then return v end
            end
            return false
        end
        global.registry.isUnderRoof = isUnderRoof
        global.registry.resolveKeycode = resolveKeycode
        global.registry.isProjectile = isProjectile
        global.registry.equipOwnedItem = equipOwnedItem
        global.registry.hasInVehicleTag = hasInVehicleTag
        global.registry.getSpeedometer = getSpeedometer
        global.registry.getClanId = getClanId
        global.registry.isClanAdmin = isClanAdmin
        global.registry.getBattleReadyUpRemote = getBattleReadyUpRemote
        global.registry.getClanPlayersOnlineId = getClanPlayersOnlineId
        global.registry.getClanPlayersOnline = getClanPlayersOnline
        global.registry.getNextShotPossible = getNextShotPossible
        global.registry.getBattleResponseRemote = getBattleResponseRemote
        global.registry.getBattleInvites = getBattleInvites
        global.registry.hasMansioninvite = hasMansioninvite
        global.registry.lighting_technology = lighting_technology
        global.registry.generateJobId = generateJobId
        global.registry.getLocalVehicle = getLocalVehicle
        global.registry.getClosestHeliPickup = getClosestHeliPickup
        global.registry.getPlayerVehicle = getPlayerVehicle
        global.registry.getCasinoDoor = getCasinoDoor
        global.registry.getClosestPlayer = getClosestPlayer
        global.registry.getClosestPlayerByFov = getClosestPlayerByFov
        global.registry.getClosestPlayerWithNoHandcuffs = getClosestPlayerWithNoHandcuffs
        global.registry.getClosestPlayerWithTagPolice = getClosestPlayerWithTagPolice
        global.registry.getClosestDroppedCash = getClosestDroppedCash
        global.registry.isVulnerable = isVulnerable
        global.registry.getClosestBankDoor = getClosestBankDoor
        global.registry.getClosestCasinoLoot = getClosestCasinoLoot
        global.registry.getClosestPlayerForBreakouts = getClosestPlayerForBreakouts
        global.registry.getClosestComputer = getClosestComputer
        global.registry.getAllClosePlayers = getAllClosePlayers
        global.registry.getClosestTriggerDoor = getClosestTriggerDoor
        global.registry.constructMarker = constructMarker
        global.registry.getPartsInRegion = getPartsInRegion
        global.registry.setColor = setColor
        global.registry.getPlayersWithBounty = getPlayersWithBounty
        global.registry.getClosestPlayerWithVehicleTag = getClosestPlayerWithVehicleTag
        global.registry.getInventoryItemsFor = getInventoryItemsFor
        global.registry.dropGun = dropGun
        global.registry.canUseTaser = canUseTaser
        global.registry.getSeats = getSeats
        global.registry.getClosestCrate = getClosestCrate
        global.registry.destructMarker = destructMarker
        global.registry.doesMarkerExist = doesMarkerExist
        global.registry.neverDropItems = neverDropItems
        global.registry.checkWallBeforePenetration = checkWallBeforePenetration
        global.registry.hasItemEquipped = hasItemEquipped
        global.registry.unequipAll = unequipAll
        global.registry.markerColors = markerColors
        global.registry.call_elevator_to_floor = call_elevator_to_floor
        global.registry.getEquippedItem = getEquippedItem
        global.registry.getKeycode = getKeycode
        global.registry.shootGun = shootGun
        global.registry.useTaser = useTaser
        global.registry.equip = equip
        global.registry.getHeliRope = getHeliRope
        global.registry.getClosestVulnerablePlayer = getClosestVulnerablePlayer
        global.registry.isInMuseum = isInMuseum
        global.registry.resolveOwnedItems = resolveOwnedItems
        global.registry.resolveEquippedItems = resolveEquippedItems
        global.registry.resolvePowerplant = resolvePowerplant
        global.registry.callplane = callplane
        global.registry.getRobberyStatus = getRobberyStatus
        global.registry.dieOfFalldamage = dieOfFalldamage
        global.registry.findTarget = findTarget
    end
    registry()
    local function client_reg()
        local function loop()
            if global.registry.getEquippedItem then client.reg.getEquippedItem = global.registry.getEquippedItem() end
            if global.registry.getLocalVehicle then
                client.reg.getLocalVehicle = global.registry.getLocalVehicle()
                if client.reg.getLocalVehicle then
                    client.state.isLocalInVehicle = true
                else
                    client.state.isLocalInVehicle = false
                end
            end
            if global.registry.resolveOwnedItems then client.reg.resolveOwnedItems = global.registry.resolveOwnedItems() end
            if global.registry.resolveEquippedItems then client.reg.resolveEquippedItems = global.registry.resolveEquippedItems() end
            if global.registry.getInventoryItemsFor then client.reg.getInventoryItemsFor = global.registry.getInventoryItemsFor(player) end
            if global.registry.getClosestVulnerablePlayer then client.reg.getClosestVulnerablePlayer = global.registry.getClosestVulnerablePlayer(global.ui_status.killaura_range or 50) end
            if global.registry.getClosestPlayerByFov then
                local getClosestPlayerByFov = global.registry.getClosestPlayerByFov
                local getClosestPlayer = global.registry.getClosestPlayer
                local getEquippedItem = client.reg.getEquippedItem
                if getEquippedItem then
                    if getEquippedItem.__ClassName == "Taser" then
                        if global.ui_status.master_switch_silentaim or global.ui_status.allow_tase_target then
                            local fov = global.ui_status.fov_silentaim or 0
                            client.reg.getClosestPlayerByFov = getClosestPlayer(85)
                        end
                    else
                        if global.ui_status.master_switch_silentaim then
                            local fov = global.ui_status.fov_silentaim or 0
                            client.reg.getClosestPlayerByFov = getClosestPlayerByFov(fov)
                        end
                    end
                end
                local getLocalVehicle = client.reg.getLocalVehicle
                if getLocalVehicle then
                    if tostring(getLocalVehicle.Make) == "Jet" then
                        if global.ui_status.master_switch_plane then
                            if global.ui_status.automatic_jet_heat_seek then
                                if not getEquippedItem then client.reg.getClosestPlayerByFov = getClosestPlayerByFov(2000, true) end
                            end
                        end
                    end
                end
            end
        end
        createloop(0, loop)
        local function tagServiceForVehicles()
            local cache
            cache = client.tags.new("isLocalInVehicle", 0, false, function(val)
                if global.ui_status.spinbot then
                    local char = client.playerCharacter
                    if char then
                        local root = char.PrimaryPart
                        if root then
                            if val then
                                if root:FindFirstChild("IsLocalSpinning") then root.IsLocalSpinning.MaxTorque = Vector3.new() end
                            else
                                if root:FindFirstChild("IsLocalSpinning") then root.IsLocalSpinning.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) end
                            end
                        end
                    end
                end
            end)
            local function loop()
                local bool = client.state.isLocalInVehicle
                if cache then cache.obj.Value = bool end
            end
            createloop(0, loop)
        end
        tagServiceForVehicles()
    end
    client_reg()
    while true do
        if client.reg.resolveOwnedItems then break end
        task.wait()
    end
    local function removeSettings()
        local settings = player.PlayerGui.AppUI.DevPanel.Container.SETTINGS.SETTINGS
        local playerMarkers = settings:FindFirstChild("playerMarkers")
        if playerMarkers then playerMarkers.Visible = false end
    end
    removeSettings()
    local workspaceChildren = {}
    local function workspaceChildAdded(obj) table.insert(workspaceChildren, obj) end
    for i,v in next, workspace:GetChildren() do table.insert(workspaceChildren, v) end
    table.insert(client.onWorkspaceSpawnRun, {
        _fn = workspaceChildAdded
    })
    local function findEmptyFolder() -- @ n are sens folderu asta
        for i,v in next, workspaceChildren do
            if v:IsA("Folder") and v.Name == "Folder" and #v:GetChildren() ~= 0 then client.NonEmptyFolder = v end
        end
    end
    findEmptyFolder()
    local function onewayNoclip()
        local isUnderRoof = global.registry.isUnderRoof
        local function onPressed()
            if global.IS_IN_NOCLIP then return false end
            local char = client.playerCharacter
            if char then
                local hasInVehicleTag = global.registry.hasInVehicleTag
                if not hasInVehicleTag(char) then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if not isUnderRoof(root) then
                            global.IS_IN_NOCLIP = true -- @activeaza anti falldmg automat si pune walkspeedul la 0
                            local velocity = root.Velocity
                            local oldCframe = root.CFrame
                            local lookVector = root.CFrame.LookVector
                            local currentCamera = workspace.CurrentCamera
                            local cameraType = currentCamera.CameraType
                            currentCamera.CameraType = "Scriptable"
                            root.Velocity = Vector3.new(0, 100000, 0)
                            root.CFrame = oldCframe + Vector3.new(0, 1000000, 0)
                            task.wait(0.5)
                            root.CFrame = root.CFrame + root.CFrame.LookVector * 5
                            root.Velocity = velocity
                            root.CFrame = oldCframe + lookVector * 10
                            currentCamera.CameraType = cameraType
                            task.wait(0.5)
                            global.IS_IN_NOCLIP = false
                        else
                            global.notify("There is something above your head", 5)
                        end
                    end
                end
            end
        end
        local lastPressed = tick()
        global.registry.activate_one_way_noclip = function()
            if global.ui_status and global.ui_status.one_way_noclip then
                if tick() - lastPressed > 0.7 and not global.IS_IN_NOCLIP then
                    onPressed()
                    lastPressed = tick()
                end
            end
        end
    end
    onewayNoclip()
    local function forceTarget()
        global.aimbot = {
            junk = {};
            connections = {};
        }
        local warningBar = client.warningBar
        local isVulnerable = global.registry.isVulnerable
        local doesMarkerExist = global.registry.doesMarkerExist
        local constructMarker = global.registry.constructMarker
        local destructMarker = global.registry.destructMarker
        local setColor = global.registry.setColor
        local markerColors = global.registry.markerColors
        local statusRobberies = global.ui.statusRobberies
        local findTarget = global.registry.findTarget
        statusRobberies["FORCED_TARGET_NAME"] = ("Forcing target selection on: None")
        local function onTargetRespawned(target)
            if not isVulnerable(player.Team, target.Team) then
                if doesMarkerExist(target) then destructMarker(target) end
                global.notify("Target is no longer vulnerable", 5)
                global.aimbot.force_target = nil
                global.aimbot.connections[target.UserId]:disconnect()
                global.aimbot.connections[target.UserId] = nil
                statusRobberies["FORCED_TARGET_NAME"] = ("Forcing target selection on: None")
                return false
            end
            task.spawn(function()
                local char = target:WaitForChild("Character")
                if char then
                    local root = char:WaitForChild("HumanoidRootPart")
                    if root then player:RequestStreamAroundAsync(root.Position) end
                end
            end)
            if global.ui_status.mark_forced_target then
                if not doesMarkerExist(target) then
                    constructMarker(target)
                    setColor(target, markerColors.Target)
                end
            end
            warningBar:setEnabled(true)
            warningBar:setText("Target has respawned")
            pcall(function()
                warningBar:play()
            end)
        end
        global.aimbot.junk.onTargetRespawned = onTargetRespawned
        local old_target
        local function setTarget(name)
            local target = findTarget(name)
            if target then
                if isVulnerable(player.Team, target.Team, {prisonerTarget = true}) then
                    task.spawn(function() -- @ hack
                        for i,v in next, global.aimbot.connections do
                            v:disconnect()
                            v = nil
                        end
                        global.aimbot.connections[target.UserId] = target.CharacterAdded:connect(function()
                            onTargetRespawned(target)
                        end)
                    end)
                    if global.ui_status.mark_forced_target then
                        if not doesMarkerExist(target) then
                            constructMarker(target)
                            setColor(target, markerColors.Target)
                        else
                            destructMarker(target)
                        end
                        if old_target ~= nil and doesMarkerExist(old_target) then destructMarker(old_target) end
                    end
                    global.aimbot.force_target = target
                    old_target = target
                    statusRobberies["FORCED_TARGET_NAME"] = ("Forcing target selection on: %s"):format(target.DisplayName)
                    return global.notify(("Target selection will now prioritze player %s"):format(target.DisplayName), 5)
                else
                    return global.notify("Target has to be a enemy", 5)
                end
            else
                return global.notify(("Couldn't find target with name `%s`"):format(name), 5)
            end
        end
        global.aimbot.setTarget = setTarget
        local function onCharacterAdded()
            local target = global.aimbot.force_target
            if target then
                if not isVulnerable(player.Team, target.Team) then
                    if doesMarkerExist(target) then destructMarker(target) end
                    global.aimbot.force_target = nil
                    global.aimbot.connections[target.UserId]:disconnect()
                    global.aimbot.connections[target.UserId] = nil
                    statusRobberies["FORCED_TARGET_NAME"] = ("Forcing target selection on: None")
                    global.notify(("Target %s is no longer vulnerable"):format(target.DisplayName), 5)
                    warningBar:setEnabled(true)
                    warningBar:setText("Target is no longer vulnerable")
                    warningBar:play()
                end
            end
        end
        player.CharacterAdded:connect(onCharacterAdded)
        local function onPlayerRemoving(target)
            if global.aimbot.force_target == target then
                global.aimbot.force_target = nil
                global.aimbot.connections[target.UserId]:disconnect()
                global.aimbot.connections[target.UserId] = nil
                statusRobberies["FORCED_TARGET_NAME"] = ("Forcing target selection on: None")
                global.notify(("Target %s has left the game"):format(target.DisplayName), 5)
                warningBar:setEnabled(true)
                warningBar:setText("Target left the game")
                warningBar:play()
            end
        end
        table.insert(client.run_on_player_disconnect, {
            _fn = onPlayerRemoving;
        })
    end
    forceTarget()
    local function Corrections()
        local function battleInvitesAccept()
            local battleInvitesFolder = player:FindFirstChild("CrewBattleInvitesFolder")
            if not battleInvitesFolder then
                log("LocalPlayer is in battle.. Automatic Accept is not available.")
                return false
            end
            local battleInvites
            local function tagService()
                battleInvites = client.tags.new("battleInvites", 0, false, function(val)
                    if val then
                        local getBattleInvites = global.registry.getBattleInvites()
                        if getBattleInvites and #getBattleInvites ~= 0 then
                            for i,v in next, getBattleInvites do
                                local getBattleResponseRemote = global.registry.getBattleResponseRemote()
                                getBattleResponseRemote:FireServer(v, true)
                            end
                        end
                    end
                end)
            end
            tagService()
            local function onBattleInvitesFolderChildAdded(obj)
                local bool = global.ui_status.auto_accept_battle
                if bool then
                    local getBattleResponseRemote = global.registry.getBattleResponseRemote()
                    getBattleResponseRemote:FireServer(obj.Name, true)
                end
            end
            player.CrewBattleInvitesFolder.ChildAdded:connect(onBattleInvitesFolderChildAdded)
            local function loop()
                local bool = global.ui_status.auto_accept_battle
                if battleInvites then battleInvites.obj.Value = bool end
            end
            createloop(0, loop)
        end
        battleInvitesAccept()
        local function battleStart()
            local battleInvitesFolder = player:FindFirstChild("CrewBattleInvitesFolder")
            if not battleInvitesFolder then
                log("LocalPlayer is in battle.. Automatic Battle Start is not available.")
                return false
            end
            local battleStartObj
            local function tagService()
                battleStartObj = client.tags.new("battleStart", 0, false, function(val)
                    if val then
                        local getClanPlayersOnline = global.registry:getClanPlayersOnline()
                        if getClanPlayersOnline and getClanPlayersOnline >= 3 then
                            local isClanAdmin = global.registry.isClanAdmin()
                            if isClanAdmin then
                                local getBattleReadyUpRemote = global.registry.getBattleReadyUpRemote()
                                if getBattleReadyUpRemote then getBattleReadyUpRemote:FireServer() end
                            end
                        end
                    end
                end)
            end
            tagService()
            local function onOnlineValueChanged(num)
                local bool = global.ui_status.auto_start_matchmaking
                if bool then
                    local getClanPlayersOnline = global.registry:getClanPlayersOnline()
                    if getClanPlayersOnline and getClanPlayersOnline >= 3 then
                        local isClanAdmin = global.registry.isClanAdmin()
                        if isClanAdmin then
                            local getBattleReadyUpRemote = global.registry.getBattleReadyUpRemote()
                            if getBattleReadyUpRemote then getBattleReadyUpRemote:FireServer() end
                        end
                    end
                end
            end
            local getClanPlayersOnlineId = global.registry:getClanPlayersOnlineId()
            if getClanPlayersOnlineId then
                getClanPlayersOnlineId.Changed:connect(onOnlineValueChanged)
            else
                log("Not in clan")
                local cache
                cache = createloop(1, function()
                    local getClanPlayersOnlineId = global.registry:getClanPlayersOnlineId()
                    if getClanPlayersOnlineId then
                        getClanPlayersOnlineId.Changed:connect(onOnlineValueChanged)
                        cache:disconnect()
                        cache = nil
                    end
                end)
            end
            local function loop()
                local bool = global.ui_status.auto_start_matchmaking
                if battleStartObj then battleStartObj.obj.Value = bool end
            end
            createloop(0, loop)
        end
        battleStart()
        local function onWorkspaceSpawnRun()
            local function onSpawnRun(obj)
                for i,v in next, client.onWorkspaceSpawnRun do v._fn(obj) end
            end
            workspace.ChildAdded:connect(onSpawnRun)
        end
        onWorkspaceSpawnRun()
        local function onWorkspaceRemovedRun()
            local function onRemovedRun(obj)
                for i,v in next, client.onWorkspaceRemovedRun do v._fn(obj) end
            end
            workspace.ChildRemoved:connect(onRemovedRun)
        end
        onWorkspaceRemovedRun()
        local function playerStateCorrection()
            local function requestJump()
                local hum = client.playerCharacter and client.playerCharacter:FindFirstChild("Humanoid")
                if global.ui_status and global.ui_status.alwaysjump and hum and hum.ChangeState then hum:ChangeState("Jumping") end
            end
            global.registry.request_infinite_jump = requestJump
            -- fire a jump on every jump request (e.g. tapping space mid-air) so the
            -- toggle alone gives infinite jump without needing the keybind held
            uis.JumpRequest:Connect(function()
                requestJump()
            end)
        end
        playerStateCorrection()
        local function fortnitedance()
            local is_dancing = false
            local party = client.modules.party.Init
            local model
            local function discoModel()
                local m = Instance.new("Model")
                m.Name = "samibagpulanunguri"
                m.Parent = workspace
                model = m
            end
            discoModel()
            local cache_switch
            local cache_speed
            -- party.Init upvalue indices (5/6 = start/stop dance, 4->8 = dance anim) are
            -- not verified against the CH4 dump yet, so guard every call so a shifted
            -- index degrades the feature instead of crashing when fortnite mode is toggled
            local stopDancing = getupvalue(party,6)
            local startDancing = getupvalue(party,5)
            local function safeStart() if type(startDancing) == "function" then pcall(startDancing, model) end end
            local function safeStop() if type(stopDancing) == "function" then pcall(stopDancing) end end
            local function adjustDanceSpeed(speed)
                pcall(function()
                    local danceAnim = getupvalue(getupvalue(party, 4), 8)
                    if danceAnim then danceAnim:AdjustSpeed(tonumber(speed)) end
                end)
            end
            local function onCharacterAdded()
                if not is_dancing and global.ui_status.fortnite_mode then
                    safeStart()
                else
                    is_dancing = false
                end
            end
            local function onCharacterRemoving()
                if is_dancing then
                    safeStop()
                    is_dancing = false
                end
            end
            player.CharacterAdded:connect(onCharacterAdded)
            player.CharacterRemoving:connect(onCharacterRemoving)
            local function tagService()
                cache_switch = client.tags.new("fortnite", 0, false, function(val)
                    if val then
                        is_dancing = true
                        safeStart()
                    else
                        is_dancing = false
                        safeStop()
                    end
                    if is_dancing and cache_speed.obj.Value then adjustDanceSpeed(cache_speed.obj.Value) end
                end)
                cache_speed = client.tags.new("fortniteSpeed", 1, 0, function(val)
                    if not is_dancing then return false end
                    adjustDanceSpeed(val)
                end)
            end
            tagService()
            local function loop()
                local bool = global.ui_status.fortnite_mode
                local speed = global.ui_status.fortnite_mode_speed
                if cache_switch then
                    cache_switch.obj.Value = bool
                    if bool then cache_speed.obj.Value = speed or 1 end
                end
            end
            createloop(0, loop)
        end
        fortnitedance()
        local function duckCorrection()
            local function automatic()
                local function loop()
                    local bool = global.ui_status.always_duck
                    local buttons = global.registry.buttons
                    if bool and buttons then
                        pcall(function()
                            buttons.attemptToggleCrawling()
                        end)
                    end
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("alwaysduck", 0, false, function(val)
                        if val then
                            loopf = createloop(0.3, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            else
                                warn("no loopf")
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "always_duck")
            end
            automatic()
            local loopf
            local cache
            local function loop()
                local bool = global.ui_status.infduck
                if bool then
                    local lastDuckTick = global.registry.lastDuckTick
                    table.clear(lastDuckTick)
                    table.insert(lastDuckTick, 1, 0)
                end
            end
            local function tagService()
                cache = client.tags.new("infiniteduck", 0, false, function(val)
                    if val then
                        loopf = createloop(0, loop)
                    else
                        if loopf then
                            loopf:disconnect()
                            loopf = nil
                        end
                    end
                end)
            end
            tagService()
            global.syncTagValue(cache, "infduck")
        end
        duckCorrection()
        local function ispointintagCorrection()
            local module = client.modules.tagUtils.isPointInTag
            local function hook(pos, str, ...)
                if global.IS_IN_NOCLIP then return true end
                if string.find(debug.traceback(), "Falling") then
                    if str == "NoFallDamage" then
                        if global.ui_status.antifalldamage then return true end
                    end
                    if str == "NoRagdoll" then
                        if global.ui_status.antiragdoll then return true end
                    end
                end
                return module(pos, str, ...)
            end
            client.modules.tagUtils.isPointInTag = hook
        end
        ispointintagCorrection()
        local function humanoidCorrection()
            local function hideCharacter()
                local fakeCharacter = Instance.new("Model")
                local fakeHumanoid = Instance.new("Humanoid")
                local boolVal = Instance.new("BoolValue")
                fakeCharacter.Parent = workspace
                fakeCharacter.Name = "FakeCharacter"
                fakeHumanoid.Parent = fakeCharacter
                boolVal.Name = "isLocalFakeCharacter"
                boolVal.Parent = fakeCharacter
                local animator
                local isInProcess = false
                local firstTime = true
                local buttons = global.registry.buttons
                local function hide_character_function()
                    if isInProcess then return false end
                    local char = client.playerCharacter
                    if not char then return false end
                    local hum = char:FindFirstChild("Humanoid")
                    if not hum then return false end
                    isInProcess = true
                    player.Character = fakeCharacter
                    task.wait()
                    animator = hum.Animator
                    animator.Parent = nil
                    hum:Destroy()
                    task.wait()
                    player.Character = char
                    local newFakeHumanoid = Instance.new("Humanoid")
                    newFakeHumanoid.Parent = char
                    hum = char:FindFirstChild("Humanoid")
                    if not hum then return false end
                    animator.Parent = hum
                    animator = nil
                    char.Animate.Disabled = true
                    task.wait()
                    char.Animate.Disabled = false
                    task.wait()
                    isInProcess = false
                    if not char:FindFirstChild("Ball") then buttons.attemptToggleCrawling() end
                    if firstTime then
                        global.notify('Stay in crouch and your character should be "hidden" for others. If you jump they may see you!', 8)
                        firstTime = false
                    end
                end
                global.registry.hide_character_function = hide_character_function
            end
            hideCharacter()
            local function spinbot()
                local function doSpin(speed)
                    local char = client.playerCharacter
                    if char then
                        local root = char.PrimaryPart
                        if root then
                            if root:FindFirstChild("IsLocalSpinning") then root.IsLocalSpinning:Destroy() end
                            local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
                            bodyAngularVelocity.Name = "IsLocalSpinning"
                            bodyAngularVelocity.Parent = root
                            bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            bodyAngularVelocity.AngularVelocity = Vector3.new(0, speed or 1, 0)
                        end
                    end
                end
                local function changeSpeed(newSpeed)
                    local char = client.playerCharacter
                    if char then
                        local root = char.PrimaryPart
                        if root then
                            if root:FindFirstChild("IsLocalSpinning") then root.IsLocalSpinning.AngularVelocity = Vector3.new(0, newSpeed, 0) end
                        end
                    end
                end
                local spin_cache, speed_cache
                local function onCharacterAdded()
                    if global.ui_status.spinbot then
                        local char = player.Character
                        if char then
                            local root = char:WaitForChild("HumanoidRootPart")
                            if root then doSpin(speed_cache.obj.Value or 1)     end
                        end
                    end
                end
                player.CharacterAdded:connect(onCharacterAdded)
                local loopf
                local function tagService()
                    spin_cache = client.tags.new("spinbot", 0, false, function(val)
                        if val then
                            doSpin(speed_cache.obj.Value or 1)
                        else
                            local char = client.playerCharacter
                            if char then
                                local root = char.PrimaryPart
                                if root then
                                    if root:FindFirstChild("IsLocalSpinning") then root.IsLocalSpinning:Destroy() end
                                end
                            end
                        end
                    end)
                    speed_cache = client.tags.new("spinbot_speed", 1, 1, function(val)
                        changeSpeed(val)
                    end)
                end
                tagService()
                local function loop()
                    local bool = global.ui_status.spinbot
                    local speed = global.ui_status.spinbot_speed
                    if spin_cache then
                        spin_cache.obj.Value = bool
                    end 
                    if speed_cache then speed_cache.obj.Value = speed end
                end
                createloop(0, loop)
            end
            spinbot()
            local function flight()   end
            flight()
            local function keycardCorrection()
                local sys = client.modules.inventoryItemSystem
                local function hook()
                    local bool = global.ui_status.always_keycard
                    if tostring(player.Team) == "Police" then return true end
                    if sys.playerHasItem(player, "Key") then return true end
                    if bool then return true end
                    return false
                end
                client.modules.playerUtils.hasKey = hook
            end
            keycardCorrection()
            local function juicedCorrection()
                local charUtil = client.modules.characterUtil
                local l
                local function loop()
                    local bool = global.ui_status.always_juiced
                    charUtil.IsJuiced = bool
                end
                local cache
                local function tagService()
                    cache = client.tags.new("always_juiced", 0, false, function(val)
                        if not val then
                            if l then
                                l:disconnect()
                                l = nil
                            end
                        else
                            l = createloop(0, loop)
                        end
                    end)
                end
                tagService()
                local function loop()
                    local always_juiced = global.ui_status.always_juiced
                    if cache then cache.obj.Value = always_juiced end
                end
                createloop(0, loop)
            end
            juicedCorrection()
            local function rollMechanics()
                local actionButtonService = client.modules.actionButtonService
                local roll = client.modules.roll
                local function onInfRoll(num)
                    for i,v in next, actionButtonService.active do
                        if table.find(v.keyCodes, Enum.KeyCode.LeftControl) then
                            v.useEvery = num
                            break
                        end
                    end
                end
                local function rollDuration(num)
                    if num == 0 then num = 0.3 end
                    -- CH4: roll duration constant moved 84 -> 69 (the 0.3 task.delay value)
                    setconstant(roll.attemptRoll, 69, tonumber(num))
                end
                local breakAnimt = tick()
                local function breakAnimations()
                    if tick() - breakAnimt > 0.2 then
                        local char = player.Character
                        if char then
                            local primaryPart = char.PrimaryPart
                            if primaryPart then
                                roll.attemptRoll()
                                breakAnimt = tick()
                            end
                        end
                    end
                end
                local cache = {}
                local is_always_roll
                local function tagService()
                    cache.infroll = client.tags.new("infinite_roll", 0, false, function(val)
                        if val then
                            onInfRoll(0)
                        else
                            onInfRoll(5)
                        end
                    end)
                    cache.roll_duration = client.tags.new("roll_duration", 1, 3, function(val)
                        if val then rollDuration(val/10) end
                    end)
                    cache.always_roll = client.tags.new("always_roll", 0, false, function(val)
                        if val then
                            is_always_roll = createloop(0, breakAnimations)
                        else
                            if is_always_roll then
                                is_always_roll:disconnect()
                                is_always_roll = nil
                            end
                        end
                    end)
                    cache.break_physics = client.tags.new("break_physics", 0, false, function(val)
                        -- CH4: "Physics" state-name constant moved 72 -> 57
                        if val then
                            setconstant(roll.attemptRoll, 57, "None")
                        else
                            setconstant(roll.attemptRoll, 57, "Physics")
                        end
                    end)
                    cache.frozen_roll = client.tags.new("frozen_roll", 0, false, function(val)
                        -- CH4: roll MaxForce magnitude (500) constant moved 45 -> 41
                        if val then
                            setconstant(roll.attemptRoll, 41, 0)
                        else
                            setconstant(roll.attemptRoll, 41, 500)
                        end
                    end)
                end
                tagService()
                local function loop()
                    local bool = global.ui_status.infinite_roll
                    if cache.infroll then cache.infroll.obj.Value = bool end
                    local roll_duration = global.ui_status.roll_duration
                    if cache.roll_duration then cache.roll_duration.obj.Value = roll_duration end
                    local always_roll = global.ui_status.always_roll
                    if cache.always_roll then cache.always_roll.obj.Value = always_roll end
                    local break_physics = global.ui_status.break_physics
                    if cache.break_physics then cache.break_physics.obj.Value = break_physics end
                    local frozen_roll = global.ui_status.frozen_roll
                    if cache.frozen_roll then cache.frozen_roll.obj.Value = frozen_roll end
                end
                createloop(0, loop)
            end
            rollMechanics()
            local function equipAfterDeath()
                local connection
                local cache
                local loopf
                local weaponName
                local equip = global.registry.equip
                local unequipAll = global.registry.unequipAll
                local equipOwnedItem = global.registry.equipOwnedItem
                local function onDied()
                    if not cache.obj.Value then
                        connection:disconnect()
                        connection = nil
                        return false
                    end
                    local gun = client.reg.getEquippedItem
                    if gun then
                        weaponName = gun.__ClassName
                        unequipAll()
                    end
                end
                local function onCharacterAdded(char)
                    if weaponName then
                        global._weaponName = weaponName
                        while true do
                            if not global.is_instant_reloading and not global.is_registering_item then break end
                            task.wait()
                        end
                        task.delay(1, function()
                            while true do
                                if table.find(client.reg.resolveEquippedItems, weaponName) then break end
                                equipOwnedItem(weaponName)
                                task.wait(0.2)
                            end
                            while true do
                                if client.reg.getEquippedItem then break end
                                equip(weaponName)
                                task.wait(0.2)
                            end
                            weaponName = nil
                            connection:disconnect()
                            connection = nil
                        end)
                    end
                end
                player.CharacterAdded:connect(onCharacterAdded)
                local function loop()
                    if connection then
                        if not global.CONNECTED_TO:IsDescendantOf(workspace) then
                            connection:disconnect()
                            connection = nil
                        end
                    end
                    if not connection then
                        local char = client.playerCharacter
                        if char then
                            local hum = char:FindFirstChild("Humanoid")
                            if hum then
                                global.CONNECTED_TO = char
                                connection = hum.Died:connect(onDied)
                            end
                        end
                    end
                end
                local function tagService()
                    cache = client.tags.new("automatic_equip_after_death", 0, false, function(val)
                        if val then
                            loopf = createloop(0, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                            if connection then
                                connection:disconnect()
                                connection = nil
                                weaponName = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "automatic_equip_after_death")
            end
            equipAfterDeath()
            local NORMAL_WALK_SPEED = 16
            local NORMAL_JUMP_POWER = 50
            local function isWalkSpeedBlocked(char)
                if global.IS_IN_NOCLIP then return true end
                if client.state and client.state.isLocalInVehicle then return true end
                if char and char:FindFirstChild("InVehicle") then return true end
                local folder = player:FindFirstChild("Folder")
                if global.ui_status.ws_disable_if_handcuffed and folder and folder:FindFirstChild("Cuffed") then return true end
                return false
            end
            local function setHorizontalVelocity(root, direction, speed)
                if not root or not direction or direction.Magnitude <= 0 then return end
                local current = root.AssemblyLinearVelocity or root.Velocity
                local wanted = direction.Unit * speed
                local velocity = Vector3.new(wanted.X, current.Y, wanted.Z)
                if root.AssemblyLinearVelocity ~= nil then
                    root.AssemblyLinearVelocity = velocity
                else
                    root.Velocity = velocity
                end
            end
            local function applyWalkSpeed(char, hum)
                if isWalkSpeedBlocked(char) then
                    hum.WalkSpeed = NORMAL_WALK_SPEED
                    return
                end
                local enabled = global.ui_status.master_switch_walkspeed == true
                local speed = tonumber(global.ui_status.walkspeed) or 30
                if not enabled then
                    hum.WalkSpeed = NORMAL_WALK_SPEED
                    return
                end
                speed = math.clamp(speed, NORMAL_WALK_SPEED, 100)
                hum.WalkSpeed = speed
                if speed > NORMAL_WALK_SPEED then
                    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                    setHorizontalVelocity(root, hum.MoveDirection, speed)
                end
            end
            local function loop()
                local char = client.playerCharacter
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        if global.IS_IN_NOCLIP then
                            hum.WalkSpeed = 0
                            return true
                        end
                        applyWalkSpeed(char, hum)
                        if global.ui_status.master_switch_jumppower then
                            local folder = player:FindFirstChild("Folder")
                            if global.ui_status.jp_disable_if_handcuffed and folder and folder:FindFirstChild("Cuffed") then
                                hum.JumpPower = NORMAL_JUMP_POWER
                                return true
                            end
                            hum.JumpPower = global.ui_status.jumppower or NORMAL_JUMP_POWER
                        else
                            hum.JumpPower = NORMAL_JUMP_POWER
                        end
                    end
                end
            end
            createloop(0, loop)
        end
        humanoidCorrection()
        local function smokeGrenadeCorrection()
            local smoke = client.modules.smoke
            local smokeGrenade = client.modules.smokeGrenade
            local function playExplosionFxCorrection()
                local _playExplosionFx = smoke._playExplosionFx
                local function hook(...)
                    local bool = global.ui_status.disable_smoke_grenade_effect
                    if bool then return task.wait(9e9) end
                    return _playExplosionFx(...)
                end
                client.modules.smoke._playExplosionFx = hook
            end
            playExplosionFxCorrection()
            local shootBegin = smokeGrenade.ShootBegin
            local function hook(...) return global.ui_status.anti_smoke_throw_limit and 0 or shootBegin(...) end
            setupvalue(shootBegin, 1, hook)
        end
        smokeGrenadeCorrection()
        local function waterPartsCorrection()
            local function instance()
                local function makePart()
                    local part = Instance.new("Part")
                    part.Name = "JESUS"
                    part.Parent = workspace
                    part.Anchored = true
                    part.Transparency = 1
                    part.Size = Vector3.new(200, 3, 200)
                end
                makePart()
                local function loop()
                    local bool = global.ui_status.jesus
                    if bool then
                        if not workspace:FindFirstChild("JESUS") then makePart() end
                    else
                        if workspace:FindFirstChild("JESUS") then workspace.JESUS.Position = Vector3.new(0, -5, 0) end
                    end
                end
                createloop(0, loop)
            end
            instance()
            local function isInWater()
                local char = client.playerCharacter
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local params = RaycastParams.new()
                        local ray = workspace:Raycast(root.Position, Vector3.new(0, -5, 0) + root.CFrame.LookVector * 5, params)
                        if ray then
                            if ray.Material == Enum.Material.Water then return ray end
                            if ray.Instance.Name == "JESUS" then return ray end
                        end
                    end
                end
                return false
            end
            local function isPartInWater(part)
                if not part or typeof(part) ~= "Instance" or not part:IsA("BasePart") then return false end
                local ok, ray = pcall(function()
                    local params = RaycastParams.new()
                    return workspace:Raycast(part.Position, Vector3.new(0, -5, 0) + part.CFrame.LookVector * 5, params)
                end)
                if ok and ray and ray.Material == Enum.Material.Water then return ray end
                return false
            end
            local hasInVehicleTag = global.registry.hasInVehicleTag
            local function loop()
                if not client.playerCharacter then return false end
                local inst = workspace:FindFirstChild("JESUS")
                if not inst then return false end
                local char = client.playerCharacter
                if not char then return false end
                local jesusPart
                if hasInVehicleTag(char) then
                    local regVehicle = client.reg.getLocalVehicle
                    local model = regVehicle and regVehicle.Model
                    if model and model:FindFirstChild("Engine") then jesusPart = model.Engine end
                else
                    jesusPart = char:FindFirstChild("HumanoidRootPart")
                end
                if not jesusPart then return false end
                local water = isPartInWater(jesusPart)
                if water then
                    -- at/above the surface: keep the walk-on-water platform engaged
                    inst.Position = water.Position - Vector3.new(0, 3, 0)
                    inst.Anchored = true
                    inst.Transparency = 1
                    inst.Size = Vector3.new(2000, 4, 2000)
                else
                    -- the down-ray only misses water when on land or fully submerged;
                    -- if we've plunged under (swimming) drop the platform so we don't get
                    -- trapped beneath it — it re-engages above once we reach the surface
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming then inst.Position = Vector3.new(inst.Position.X, -1000, inst.Position.Z) end
                end
            end
            local cache
            local loopf
            local function tagService()
                cache = client.tags.new("jesus", 0, false, function(val)
                    if val then
                        loopf = createloop(0, loop)
                    else
                        if loopf then
                            loopf:disconnect()
                            loopf = nil
                        end
                    end
                end)
            end
            tagService()
            global.syncTagValue(cache, "jesus")
        end
        waterPartsCorrection()
        local function circleActions()
            local cache
            local module_ui = client.modules.ui.CircleAction
            local excluded = {
                ["Rob"] = true,
                ["Hack"] = true,
                ["Open Crate"] = true,
                ["Break In"] = true,
            }

            local function isEnabled() return global.ui_status.master_switch_no_circle_delay == true end

            -- The CircleAction binder re-reads Duration from the instance attribute
            -- inside PreUpdateFun every update cycle, so a one-shot Duration = 0 gets
            -- overwritten. Wrap PreUpdateFun to reassert it each cycle instead.
            local function patchSpec(spec)
                if not spec or type(spec) ~= "table" or spec.crewbattlerCirclePatched then return end
                spec.crewbattlerCirclePatched = true
                local originalPre = spec.PreUpdateFun
                if originalPre then
                    spec.PreUpdateFun = function(self, ...)
                        local result = originalPre(self, ...)
                        if isEnabled() and not excluded[self.Name] then
                            self.Duration = 0
                            self.Timed = false
                        end
                        return result
                    end
                end
                if isEnabled() and not excluded[spec.Name] and spec.Duration then
                    if spec.Duration > 0.001 then spec.oldVal = spec.Duration end
                    spec.Duration = 0
                    spec.Timed = false
                end
            end

            local function restoreSpec(spec)
                if spec and type(spec) == "table" and spec.oldVal then
                    spec.Duration = spec.oldVal
                    spec.Timed = spec.Duration > 0.001
                end
            end

            -- hook Add so specs created later (as you approach objects) are patched too
            local add = module_ui.Add
            module_ui.Add = function(spec, ...)
                patchSpec(spec)
                return add(spec, ...)
            end
            for i, v in next, module_ui.Specs do patchSpec(v) end

            local function tagService()
                cache = client.tags.new("no_circle_delay", 0, false, function(val)
                    for i, v in next, module_ui.Specs do
                        patchSpec(v)
                        if not v.PreUpdateFun and not excluded[v.Name] then
                            if val then
                                if v.Duration and v.Duration > 0.001 then v.oldVal = v.Duration end
                                v.Duration = 0
                                v.Timed = false
                            else
                                restoreSpec(v)
                            end
                        end
                    end
                end)
            end
            tagService()

            -- arrest/hold progress circle lives on a Heartbeat connection with its own
            -- timer thread; guard the introspection so a game update can't break the rest.
            local function arrestCircleUpdate()
                pcall(function()
                    for i, v in next, getconnections(runservice.Heartbeat) do
                        local func = v.Function
                        if func and type(func) == "function" and not is_synapse_function(func) then
                            local con = getconstants(func)
                            if table.find(con, "tick", 1) and table.find(con, "Value", 3) then
                                local f = getupvalue(func, 1)
                                if type(f) == "function" then
                                    local old = getupvalue(f, 4)
                                    if type(old) == "function" then
                                        setupvalue(f, 4, function(action)
                                            local bool = global.ui_status.master_switch_no_circle_delay
                                            local o = old(action)
                                            if bool then action.Duration = 0 end
                                            return o
                                        end)
                                    end
                                end
                            end
                            if table.find(con, "Thread Loop", 7) then
                                local t = getupvalue(func, 2)
                                if type(t) == "table" then
                                    for i2, v2 in next, t do
                                        if v2.i == 1 and type(v2.c) == "function" then
                                            v2.t = 0
                                            v2.i = math.huge
                                            v2.c = function()
                                                return task.wait(9e9)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            arrestCircleUpdate()

            global.syncTagValue(cache, "master_switch_no_circle_delay")
        end
        circleActions()
        local function punchCorrection()
            local function automatic()
                local lastPunch = tick()
                local function loop()
                    local bool = global.ui_status.automatic_punch
                    if not bool then return false end
                    local buttons = global.registry.buttons
                    if not buttons then return false end
                    local punchFreq = getconstant(buttons.attemptPunch, 3)
                    if tick() - lastPunch < punchFreq then return false end
                    buttons.attemptPunch()
                end
                createloop(0, loop)
            end
            automatic()
            local function loop()
                local bool = global.ui_status.infpunch
                local buttons = global.registry.buttons
                if buttons then
                    local c = bool and 0 or 0.5
                    setconstant(buttons.attemptPunch, 3, c)
                end
            end
            createloop(0, loop)
        end
        punchCorrection()
        local function gliderCorrection()
            global.registry.toggle_glider = function()
                local paraglide = client.modules and client.modules.paraglide
                if global.ui_status and global.ui_status.glider_on_key and paraglide then
                    local isFlying = type(paraglide.IsFlying) == "function" and paraglide.IsFlying()
                    if isFlying then
                        if type(paraglide.GliderStop) == "function" then
                            paraglide.GliderStop()
                        end
                    elseif type(paraglide.Glider) == "function" then
                        paraglide.Glider()
                    end
                end
            end
        end
        gliderCorrection()
        local function parachuteCorrection()
            global.registry.toggle_parachute = function()
                local paraglide = client.modules and client.modules.paraglide
                if global.ui_status and global.ui_status.parachute_on_key and paraglide then
                    local isFlying = type(paraglide.IsFlying) == "function" and paraglide.IsFlying()
                    if isFlying then
                        if type(paraglide.ParachuteStop) == "function" then
                            paraglide.ParachuteStop()
                        end
                    elseif type(paraglide.Parachute) == "function" then
                        paraglide.Parachute()
                    end
                end
            end
            local parachute = client.modules.paraglide.Parachute
            -- CH4 added a wrapper layer (Parachute -> Parachute -> RawParachute), so the
            -- auto-unparachute hook (UpdateParachute, up[3]) is one upvalue hop deeper now
            local function up(fn, i) return type(fn) == "function" and getupvalue(fn, i) or nil end
            local upv = up(up(up(parachute, 1), 1), 6)
            local function hook_parachute()
                local bool = global.ui_status.antiparachute
                if bool then return task.wait(9e9) end
                return parachute()
            end
            client.modules.paraglide.Parachute = hook_parachute
            local function antizones()
                if type(upv) ~= "function" then return end
                local upv3 = getupvalue(upv, 3)
                if type(upv3) ~= "function" then return end
                local function hook(...)
                    local bool = global.ui_status.disable_automatic_unparachute
                    if bool then return false end
                    return upv3(...)
                end
                setupvalue(upv, 3, hook)
            end
            antizones()
        end
        parachuteCorrection()
        local function skydivingCorrection()
            local getSkydiveTrack = client.modules.characterAnim.getSkydiveTrack
            local function hook()
                local bool = global.ui_status.antiskydive
                if bool then
                    return task.wait(9e9)
                end 
                return getSkydiveTrack()
            end
            client.modules.characterAnim.getSkydiveTrack = hook
            local upv = getupvalue(client.modules.fallingInit, 19)
            local function loop()
                local bool = global.ui_status.antiskydive
                if bool and type(upv) == "function" then
                    local ok, value = pcall(getupvalue, upv, 14)
                    if ok and value ~= false then pcall(setupvalue, upv, 14, false) end
                end
            end
            createloop(0, loop)
        end
        skydivingCorrection()
        local function gunStoreCorrection()
            local region = client.modules.region.Update
            local vals = {
                Condition = nil;
            }
            local function hook(tbl, ...)
                if not string.find(debug.traceback(), "GunShopSystem") then return region(tbl, ...) end
                if global.hideshopui or global.is_instant_reloading then
                    player.PlayerGui.GunShopGui.Enabled = false
                    player.PlayerGui.GunShopGui.Container.Visible = false
                else
                    player.PlayerGui.GunShopGui.Container.Visible = true
                end
                local bool = global.ui_status.open_gunstore_ui
                local open_shop = global.open_shop
                local is_instant_reloading = global.is_instant_reloading
                local function condition_hook(...)
                    if is_instant_reloading then
                        player.PlayerGui.GunShopGui.Container.Close.Visible = not is_instant_reloading
                        return is_instant_reloading
                    end
                    if bool then
                        player.PlayerGui.GunShopGui.Container.Close.Visible = not bool
                        return bool
                    end
                    if open_shop then
                        player.PlayerGui.GunShopGui.Container.Close.Visible = not open_shop
                        return open_shop
                    end
                    return vals.Condition ~= nil and vals.Condition(...)
                end
                if not vals.Condition then vals.Condition = tbl.Condition end
                tbl.Condition = condition_hook
                return region(tbl, ...)
            end
            client.modules.region.Update = hook
        end
        gunStoreCorrection()
        local function unlockCustomizationsCorrection()
            -- ItemOwnershipUtils gates every garage wrap/color/texture (and vehicle) by
            -- store:getState().garageOwned. Hook the ownership checks so the garage treats
            -- everything as owned, letting you select/preview (spoof) any customization.
            local ok, own = pcall(function() return require(repl.App.ItemOwnershipUtils) end)
            if not ok or type(own) ~= "table" then
                log("unlockCustomizations: ItemOwnershipUtils not found (game updated?)")
                return
            end
            for _, name in ipairs({"isVehicleOwned", "isVehicleCustomizationOwned", "isHomeItemOwned"}) do
                local original = own[name]
                if type(original) == "function" and not rawget(own, "__cbUnlockHooked_" .. name) then
                    own["__cbUnlockHooked_" .. name] = true
                    own[name] = function(...)
                        if global.ui_status.unlock_customizations then return true end
                        return original(...)
                    end
                end
            end
        end
        unlockCustomizationsCorrection()
        local function wrapChangerCorrection()
            -- Apply any vehicle wrap (texture) to your current vehicle using the same
            -- path the garage preview uses: Customize.ApplyAll(map, {Model,Make,Type}, sel)
            local okC, Customize = pcall(function() return require(repl.Game.Garage.Customize) end)
            local okS, StoreData = pcall(function() return require(repl.Game.Garage.StoreData) end)
            local okT, TextureData = pcall(function() return require(repl.Game.Garage.TextureData) end)
            if not (okC and okS and okT) or type(Customize) ~= "table" or type(Customize.ApplyAll) ~= "function"
                or type(StoreData) ~= "table" or type(StoreData.GetMapFromSelection) ~= "function" then
                log("wrapChanger: garage modules not found (game updated?)")
                return
            end
            -- populate the wrap dropdown from the live wrap list
            local names = {}
            if type(TextureData) == "table" then for k in pairs(TextureData) do names[#names + 1] = tostring(k) end end
            table.sort(names)
            local control = global.ui and global.ui.controls and global.ui.controls.wrap_value
            if control and type(control.reload) == "function" and #names > 0 then pcall(control.reload, names) end
            global.registry.applyWrap = function(wrapName)
                if type(wrapName) == "table" then wrapName = wrapName[1] end
                if not wrapName or wrapName == "none" or wrapName == "" then return end
                local packet = client.modules.vehicle and client.modules.vehicle.GetLocalVehiclePacket()
                if type(packet) ~= "table" or not packet.Model then
                    return global.notify and global.notify("Get in a vehicle first.", 4)
                end
                local ok, err = pcall(function()
                    local selection = { Texture = wrapName }
                    local map = StoreData.GetMapFromSelection(selection)
                    Customize.ApplyAll(map, { Model = packet.Model, Make = packet.Make, Type = packet.Type }, selection)
                end)
                if not ok then log("wrapChanger apply failed: " .. tostring(err)) end
            end
        end
        wrapChangerCorrection()
        local function stunnedCorrection()
            local function respawnOnTazed()
                local module = client.modules.falling.StartRagdolling
                local function fireTeamSwitch()
                    local teamSwitch = player.PlayerGui.AppUI.Buttons.Sidebar.TeamSwitch.TeamSwitch
                    if not teamSwitch then
                        log("ERROR occured while trying to respawn (TeamSwitch)")
                        return false
                    end
                    for i,v in next, getconnections(teamSwitch.MouseButton1Down) do
                        v.Function()
                        break
                    end
                end
                local function pressYes()
                    local confirm = player.PlayerGui.ConfirmationGui.Confirmation.Background.ContainerButtons.ContainerYes
                    if not confirm then
                        log("ERROR occured while trying to respawn (yes pressing)")
                        return false
                    end
                    for i,v in next, getconnections(confirm.Button.MouseButton1Down) do
                        v.Function()
                        break
                    end
                end
                local function goPrisoner()
                    local prisonerButton = player.PlayerGui.TeamGui.Container.ContainerTeam:FindFirstChild("Prisoner")
                    if not prisonerButton then
                        log("ERROR occured while trying to respawn (prisoner)")
                        return false
                    end
                    for i,v in next, getconnections(prisonerButton.MouseButton1Down) do
                        v.Function()
                        break
                    end
                end
                local function goPolice()
                    local policeButton = player.PlayerGui.TeamGui.Container.ContainerTeam:FindFirstChild("Police")
                    if not policeButton then
                        log("ERROR occured while trying to respawn (police)")
                        return false
                    end
                    for i,v in next, getconnections(policeButton.MouseButton1Down) do
                        v.Function()
                        break
                    end
                end
                local function goPlay()
                    local playgui = player.PlayerGui.TeamGui.Container.ContainerPlay.Play
                    if not playgui then
                        log("ERROR occured while trying to respawn (play pressing)")
                        return false
                    end
                    for i,v in next, getconnections(playgui.MouseButton1Down) do
                        v.Function()
                        break
                    end
                end
                local equip = global.registry.equip
                local function hook(num)
                    if string.find(debug.traceback(), "OnClientEvent") then
                        local __className
                        if client.reg.getEquippedItem then __className = client.reg.getEquippedItem.__ClassName end
                        local notaze = global.ui_status.antitaze
                        if notaze then
                            setupvalue(global.registry.stunnedFunc,1,false)
                            num = -1
                            if __className then
                                task.delay(0.1, function()
                                    equip(__className)
                                end)
                            end
                        end
                        local team = tostring(player.Team)
                        local bool = global.ui_status.automatic_respawn_on_taze
                        if bool then
                            task.delay(0.1, fireTeamSwitch)
                            task.delay(0.3, pressYes)
                            if team == "Prisoner" or team == "Criminal" then
                                task.delay(0.5, goPrisoner)
                            elseif team == "Police" then task.delay(0.5, goPolice) end
                            task.delay(0.7, goPlay)
                        end
                    end
                    return module(num)
                end
                client.modules.falling.StartRagdolling = hook
            end
            respawnOnTazed()
            local function removeTazeRagdoll()
                local stunned = client.modules.settings.Time.Stunned
                local function loop()
                    local bool = global.ui_status.antitaze
                    if bool then
                        client.modules.settings.Time.Stunned = 0
                    else
                        client.modules.settings.Time.Stunned = stunned
                    end
                end
                createloop(0, loop)
            end
            removeTazeRagdoll()
        end
        stunnedCorrection()
        local function jetpackCorrection()
            local function fuel()
                local init = getupvalue(client.modules.jetpack.Init, 9)
                local cache
                local function tagService()
                    cache = client.tags.new("fuel", 0, false, function(val)
                        if val then
                            init.LocalFuelType = "Rocket"
                            init.LocalMaxFuel = math.huge
                            init.LocalFuel = math.huge
                        else
                            init.LocalFuelType = "Standard"
                            init.LocalMaxFuel = 10
                            init.LocalFuel = 2.5
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "infinite_jetpack_fuel")
            end
            fuel()
        end
        jetpackCorrection()
        local function sprintCorrection()
            local module = client.modules.defaultActions
            local function isSprinting() return module.sprintButton._pressed end
            local function pressSprint()
                if not isSprinting() and module.sprintButton._pressState then module.sprintButton._pressState() end
            end
            local function loop()
                local bool = global.ui_status.alwayssprint
                if bool then pressSprint() end
            end
            createloop(0, loop)
        end
        sprintCorrection()
        local function vehicleCorrection()
            local function force_bodycolor()

            end
            force_bodycolor()
            local function jump()
                global.registry.jump_vehicle = function()
                    if global.ui_status and global.ui_status.vehicle_jump then
                        if client.state and client.state.isLocalInVehicle then
                            local char = client.playerCharacter
                            if char then
                                local hum = char:FindFirstChild("Humanoid")
                                if hum and hum.ChangeState then hum:ChangeState("Jumping") end
                            end
                        end
                    end
                end
            end
            jump()
            local function noTrailer()
                local cache
                local currentTrailer
                local currentVehicle
                local function getVehicleModel(vehicle) return vehicle and vehicle.Model end
                local function getVehiclePreset(vehicle)
                    local model = getVehicleModel(vehicle)
                    return model and model:FindFirstChild("Preset")
                end
                local function getVehicleTrailer(vehicle)
                    local preset = getVehiclePreset(vehicle)
                    return preset and preset:FindFirstChild("Trailer")
                end
                local function reconnectTrailer()
                    if not currentTrailer or not currentVehicle then
                        global.USER_INPUT_TYPE_SWITCH = false
                        currentTrailer = nil
                        currentVehicle = nil
                        return false
                    end
                    local trailer = currentTrailer
                    local vehicle = currentVehicle
                    local model = getVehicleModel(vehicle)
                    local preset = getVehiclePreset(vehicle)
                    if not trailer or not model or not preset then
                        global.USER_INPUT_TYPE_SWITCH = false
                        currentTrailer = nil
                        currentVehicle = nil
                        return false
                    end
                    global.USER_INPUT_TYPE_SWITCH = false
                    pcall(function()
                        trailer.Parent = preset
                    end)
                    local primaryPart = model.PrimaryPart
                    if primaryPart then
                        pcall(function()
                            if trailer.PrimaryPart then
                                trailer:SetPrimaryPartCFrame(primaryPart.CFrame)
                            else
                                trailer:PivotTo(primaryPart.CFrame)
                            end
                        end)
                    end
                    currentTrailer = nil
                    currentVehicle = nil
                    return true
                end
                local function detachTrailer(vehicle)
                    reconnectTrailer()
                    if not vehicle or tostring(vehicle.Make) ~= "Semi" then return false end
                    local trailer = getVehicleTrailer(vehicle)
                    if not trailer then return false end
                    global.USER_INPUT_TYPE_SWITCH = true
                    currentTrailer = trailer
                    currentVehicle = vehicle
                    pcall(function()
                        trailer.Parent = nil
                    end)
                    return true
                end
                local function tagService()
                    cache = client.tags.new("noTrailer", 0, false, function(val)
                        local vehicle = client.reg.getLocalVehicle
                        if val then
                            detachTrailer(vehicle)
                        else
                            reconnectTrailer()
                        end
                    end)
                end
                tagService()
                local function resolveLocalVehicle()
                    local vehicle = client.reg.getLocalVehicle
                    if not vehicle and global.registry.getLocalVehicle then
                        local ok, resolved = pcall(global.registry.getLocalVehicle)
                        if ok then vehicle = resolved end
                    end
                    return vehicle
                end
                local function onVehicleEntered(obj)
                    if obj.Name == "InVehicle" and global.ui_status.no_trailer then detachTrailer(resolveLocalVehicle()) end
                end
                local function onVehicleExit(obj)
                    if obj.Name == "InVehicle" then reconnectTrailer() end
                end
                local function onCharacterAdded()
                    local char = player.Character
                    if not char then return false end
                    char.ChildAdded:connect(onVehicleEntered)
                    char.ChildRemoved:connect(onVehicleExit)
                end
                onCharacterAdded()
                player.CharacterAdded:connect(onCharacterAdded)
                local onJumpPressed = client.modules.defaultActions.onJumpPressed._handlerListHead._fn
                local function onJumpPressedHook(...)
                    if reconnectTrailer() then task.wait(0.2) end
                    return onJumpPressed(...)
                end
                client.modules.defaultActions.onJumpPressed._handlerListHead._fn = onJumpPressedHook
                local onVehicleExited = client.modules.vehicle.OnVehicleExited._handlerListHead._fn
                local function onVehicleExitedHook(...)
                    if reconnectTrailer() then task.wait(0.2) end
                    return onVehicleExited(...)
                end
                client.modules.vehicle.OnVehicleExited._handlerListHead._fn = onVehicleExitedHook
                local function loop()
                    local bool = global.ui_status.no_trailer
                    if cache then cache.obj.Value = bool end
                    if bool then
                        if not currentTrailer then
                            local vehicle = client.reg.getLocalVehicle
                            if vehicle and tostring(vehicle.Make) == "Semi" then detachTrailer(vehicle) end
                        end
                    elseif currentTrailer then reconnectTrailer() end
                end
                createloop(0, loop)
            end
            noTrailer()
            local function instantTow()
                local okBinder, binder = pcall(function()
                    return require(repl.VehicleLink.VehicleLinkBinder)
                end)
                if not okBinder or type(binder) ~= "table" then return false end
                local constructor = binder._constructor
                if type(constructor) ~= "table" then return false end
                local original = constructor._hookNearest
                if type(original) ~= "function" or constructor.CrewbattlerInstantTowHooked then return false end
                local geomUtils = client.modules.geomUtils
                if not geomUtils or type(geomUtils.closestPointInPart) ~= "function" then return false end
                constructor.CrewbattlerInstantTowHooked = true
                constructor._hookNearest = function(...)
                    if global.ui_status.instant_tow then
                        local args = {...}
                        local handled = false
                        pcall(function()
                            local data = args[1]
                            local rope = data and data.obj
                            local obj = data and data.nearestObj
                            local manifest = data and data.manifest
                            local requestLink = manifest and manifest.reqLinkRemote
                            -- MetalHook is the tow-truck rope; fire the link instantly
                            if rope and obj and requestLink and obj.PrimaryPart and rope.Name == "MetalHook" then
                                local closest = geomUtils.closestPointInPart(obj.PrimaryPart, rope.Position)
                                local cf = obj.PrimaryPart.CFrame:PointToObjectSpace(closest)
                                requestLink:FireServer(obj, cf)
                                handled = true
                            end
                        end)
                        if handled then return end
                    end
                    return original(...)
                end
            end
            instantTow()
            local function oilRig()
                local turret = client.modules and client.modules.turret
                local function resolveExplosion()
                    local ok, result = pcall(function()
                        local rig = workspace:FindFirstChild("OilRig")
                        local signal = rig and rig:FindFirstChild("OpenCloseSignal")
                        if not signal then return nil end
                        return signal:FindFirstChild("Explosion") or signal:FindFirstChild("plainrocky123")
                    end)
                    return ok and result or nil
                end
                local lastTurret, lastDestruct
                local function loop()
                    local disableTurret = global.ui_status.oil_disable_turret == true
                    if disableTurret ~= lastTurret then
                        lastTurret = disableTurret
                        if turret and turret.ShootLaser and type(setconstant) == "function" then
                            pcall(function()
                                setconstant(turret.ShootLaser, 31, disableTurret and 9e9 or 0.5)
                            end)
                        end
                    end
                    local disableDestruct = global.ui_status.oil_disable_self_destruct == true
                    if disableDestruct ~= lastDestruct then
                        lastDestruct = disableDestruct
                        local explosion = resolveExplosion()
                        if explosion then
                            pcall(function()
                                explosion.Name = disableDestruct and "plainrocky123" or "Explosion"
                            end)
                        end
                    end
                end
                createloop(0.5, loop)
            end
            oilRig()
            local function headlights()
                local function headlights()
                    for i,v in next, client.modules.actionButtonService.active do
                        if type(v) == "table" and v.keyCodes then
                            if table.find(v.keyCodes, Enum.KeyCode.L) then v.onPressed(true) end
                        end
                    end
                end
                local function loop()
                    local master_switch_carmodify = global.ui_status.master_switch_carmodify
                    if master_switch_carmodify then
                        local bool = global.ui_status.spam_headlights
                        if bool then
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if getLocalVehicle and getLocalVehicle.Type ~= "Heli" then headlights() end
                        end
                    end
                end
                createloop(0.2, loop)
            end
            headlights()
            local function lock()
                local function getVehicle()
                    local getLocalVehicle = client.reg.getLocalVehicle
                    if getLocalVehicle then return getLocalVehicle end
                    return false
                end
                local function getLocked()
                    local getVehicle = getVehicle()
                    if getVehicle then return getVehicle.Model:GetAttribute("Locked") end
                    return false
                end
                local function canLock() return client.modules.vehicle.canLocalLock() end
                local function callLock() return client.modules.vehicle.toggleLocalLocked() end
                local function loop()
                    local bool = global.ui_status.automatic_lock_vehicle
                    if bool then
                        local getVehicle = getVehicle()
                        if getVehicle then
                            local getLocked = getLocked()
                            if not getLocked then
                                local canLock = canLock()
                                if canLock then callLock() end
                            end
                        end
                    end
                end
                createloop(1, loop)
            end
            lock()
            local function eject()
                local vehicle = client.modules.vehicle
                local function getVehicle()
                    local getLocalVehicle = client.reg.getLocalVehicle
                    return getLocalVehicle
                end
                local function canEject() return vehicle.canLocalEject() end
                local function ejectPlayer(player)
                    if canEject() then vehicle.attemptPassengerEject(player.Name) end
                end
                local getSeats = global.registry.getSeats
                local function loop()
                    local bool = global.ui_status.automatic_eject_vehicle_player
                    if bool then
                        local canEject = canEject()
                        if canEject then
                            local getSeats = getSeats()
                            if getSeats then
                                for i,v in next, getSeats do ejectPlayer(v.Player) end
                            end
                        end
                    end
                end
                createloop(1, loop)
            end
            eject()
            local function jeeproof()
                local function roof()
                    for i,v in next, client.modules.actionButtonService.active do
                        if type(v) == "table" and v.keyCodes then
                            if table.find(v.keyCodes, Enum.KeyCode.G) then v.onPressed(true) end
                        end
                    end
                end
                local function loop()
                    local master_switch_carmodify = global.ui_status.master_switch_carmodify
                    if master_switch_carmodify then
                        local bool = global.ui_status.spam_jeep_roof
                        if bool then
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if getLocalVehicle and tostring(getLocalVehicle.Make) == "Jeep" then roof() end
                        end
                    end
                end
                createloop(0.1, loop)
            end
            jeeproof()
            local function drifts()
                local function drift()
                    for i,v in next, client.modules.actionButtonService.active do
                        if type(v) == "table" and v.keyCodes then
                            if table.find(v.keyCodes, Enum.KeyCode.LeftShift) then v.onPressed(true) end
                        end
                    end
                end
                local function loop()
                    local master_switch_carmodify = global.ui_status.master_switch_carmodify
                    if master_switch_carmodify then
                        local bool = global.ui_status.always_drift
                        if bool then
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if getLocalVehicle then drift() end
                        end
                    end
                end
                createloop(0, loop)
            end
            drifts()
            local function hijack()
                local function hijack()
                    local localization = client.modules.localization
                    for i,v in next, client.modules.ui.CircleAction.Specs do
                        if v.Name == localization:FormatByKey("Action.Hijack") then
                            if v.Enabled then v:Callback(true) end
                        end
                    end
                end
                local function loop()
                    local bool = global.ui_status.automatic_hijack_vehicles
                    if bool then hijack() end
                end
                createloop(0.5, loop)
            end
            hijack()
            local function automaticflip()
                local function flip()
                    for i,v in next, client.modules.actionButtonService.active do
                        if type(v) == "table" and v.keyCodes then
                            if table.find(v.keyCodes, Enum.KeyCode.V) then v.onPressed(true) end
                        end
                    end
                end
                local function loop()
                    local master_switch_carmodify = global.ui_status.master_switch_carmodify
                    if master_switch_carmodify then
                        local bool = global.ui_status.automatic_flip_vehicle
                        if bool then
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if getLocalVehicle then flip()     end
                        end
                    end
                end
                createloop(0.5, loop)
            end
            automaticflip()
            local function breakVehicles()
                global._oldItem = nil
                local itemName
                local function onCharacterAdded()
                    if global._oldItem then
                        global._oldItem = nil
                        itemName = nil
                    end
                end
                player.CharacterAdded:connect(onCharacterAdded)
                local function registerEquippedItem()
                    local equip = global.registry.equip
                    local unequipAll = global.registry.unequipAll
                    local equip_only = {"Rifle", "Pistol", "Shotgun", "Revolver", "Flintlock", "AK47", "Uzi", "Sniper"}
                    local function loop()
                        if global._oldItem then return false end
                        if #client.reg.resolveEquippedItems == 0 then return false end
                        local bool = global.ui_status.break_vehicles
                        local instant_break = global.ui_status.instant_break
                        local getEquippedItem = client.reg.getEquippedItem
                        local unequipAfter = false
                        if bool and not global._oldItem and not global.is_registering_item then
                            global.is_registering_item = true
                            local getEquippedItem = client.reg.getEquippedItem
                            if not getEquippedItem then
                                unequipAfter = true
                                for i,v in next, client.reg.resolveEquippedItems do
                                    if table.find(equip_only, v) then
                                        equip(v)
                                        while true do
                                            if getEquippedItem then break end
                                            getEquippedItem = client.reg.getEquippedItem
                                            task.wait()
                                        end
                                        break
                                    end
                                end
                            end
                            if global._oldItem then return false end
                            if getEquippedItem and table.find(equip_only, getEquippedItem.__ClassName) then
                                local className = getEquippedItem.__ClassName
                                if className then
                                    global._oldItem = getEquippedItem.BulletEmitter.OnHitSurface._handlerListHead._signal._handlerListHead._fn
                                    className = getEquippedItem.__ClassName
                                    itemName = className
                                    unequipAll()
                                    if instant_break then
                                        getEquippedItem.__ClassName = "Sniper"
                                        itemName = "Sniper"
                                    else
                                        getEquippedItem.__ClassName = className
                                        itemName = className
                                    end
                                end
                            end
                            task.delay(1, function()
                                if global._weaponName then
                                    while true do
                                        if client.reg.getEquippedItem then break end
                                        equip(global._weaponName)
                                        task.wait()
                                    end
                                    global._weaponName = nil
                                end
                            end)
                            global.is_registering_item = false
                        end
                    end
                    loop()
                    createloop(0.6, loop)
                end
                registerEquippedItem()
                local function popTire(v)
                    if global.ui_status.instant_break and itemName ~= "Sniper" then
                        global._oldItem = nil
                    elseif not global.ui_status.instant_break and itemName == "Sniper" then
                        if not table.find(client.reg.resolveOwnedItems, "Sniper") then global._oldItem = nil end
                    end
                    if not global._oldItem then return false end
                    local getPlayerVehicle = global.registry.getPlayerVehicle(v)
                    if getPlayerVehicle then
                        local engine = getPlayerVehicle:FindFirstChild("Engine") or getPlayerVehicle:FindFirstChild("BoundingBox")
                        if engine then
                            for i=1, 9 do
                                local break_vehicles = global.ui_status.break_vehicles
                                if not break_vehicles then break end
                                pcall(function()
                                    global._oldItem(engine, engine.Position, Vector3.new(), Enum.Material.SmoothPlastic)
                                end)
                                task.wait()
                            end
                        end
                    end
                end
                -- The game now validates that a weapon is equipped when the captured
                -- hit-surface damage remote fires, so equip one only for the break burst.
                local equipWeaponNames = {"Rifle", "Pistol", "Shotgun", "Revolver", "Flintlock", "AK47", "Uzi", "Sniper"}
                local function pickEquipName()
                    for _, v in next, client.reg.resolveEquippedItems do
                        if table.find(equipWeaponNames, v) then return v end
                    end
                    return nil
                end
                local function equipForBurst()
                    if client.reg.getEquippedItem then return false end
                    local name = pickEquipName()
                    if not name then return false end
                    local equip = global.registry.equip
                    if not equip then return false end
                    local deadline = tick() + 1
                    while not client.reg.getEquippedItem and tick() < deadline do
                        equip(name)
                        task.wait()
                    end
                    return client.reg.getEquippedItem ~= nil
                end
                local function loop()
                    local bool = global.ui_status.break_vehicles
                    if not bool then return false end
                    if not global._oldItem then return false end
                    local getClosestPlayerWithVehicleTag = global.registry.getClosestPlayerWithVehicleTag(1280)
                    if not getClosestPlayerWithVehicleTag then return false end
                    local isVulnerable = global.registry.isVulnerable
                    local target_enemy_team_only = global.ui_status.target_enemy_team_only
                    local targets = {}
                    for i, v in next, getClosestPlayerWithVehicleTag do
                        if target_enemy_team_only then
                            if isVulnerable(player.Team, v.Team) then targets[#targets + 1] = v end
                        else
                            targets[#targets + 1] = v
                        end
                    end
                    if #targets == 0 then return false end
                    -- make sure a weapon is out for the burst, then put it away after
                    local equippedByUs = false
                    if not client.reg.getEquippedItem then
                        if global.ui_status.only_on_weapon_equipped then return false end
                        equippedByUs = equipForBurst()
                        if not client.reg.getEquippedItem then return false end
                    end
                    for _, v in ipairs(targets) do popTire(v) end
                    if equippedByUs then
                        local unequipAll = global.registry.unequipAll
                        if unequipAll then unequipAll() end
                    end
                end
                createloop(1, loop)
            end
            breakVehicles()
            local function destroyDestructibles()
                local function destructAll(getLocalVehicle)
                    local folder = client.NonEmptyFolder:GetChildren()
                    for i,v in next, folder do
                        for i2,v2 in next, v:GetDescendants() do
                            if v2:FindFirstChild("TouchInterest") and v2:isA("Part") then
                                firetouchinterest(v2, getLocalVehicle.Model.Engine, 0)
                                firetouchinterest(v2, getLocalVehicle.Model.Engine, 1)
                            end
                        end
                    end
                end
                local delayLoopTick = tick()
                local function loop()
                    local bool = global.ui_status.destroy_all_destructibles
                    if bool then
                        local destruct_delay = global.ui_status.destruct_delay or 0
                        if tick() - delayLoopTick > destruct_delay then
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if getLocalVehicle then
                                destructAll(getLocalVehicle)
                                delayLoopTick = tick()
                            end
                        end
                    end
                end
                createloop(0, loop)
            end
            destroyDestructibles()
            local function pitAura()
                local function loop()
                    if tostring(player.Team) ~= "Police" then return false end
                    local bool = global.ui_status.pit_aura
                    if bool then
                        local range = global.ui_status.pit_aura_range
                        local getLocalVehicle = client.reg.getLocalVehicle
                        if getLocalVehicle then
                            local bumperCollide = getLocalVehicle.Model:FindFirstChild("BumperCollide")
                            if bumperCollide then
                                local getClosestPlayer = global.registry.getClosestPlayer(range)
                                if getClosestPlayer then
                                    local getPlayerVehicle = global.registry.getPlayerVehicle(getClosestPlayer)
                                    if getPlayerVehicle then
                                        firetouchinterest(getPlayerVehicle.BoundingBox, bumperCollide, 0)
                                        firetouchinterest(getPlayerVehicle.BoundingBox, bumperCollide, 1)
                                    end
                                end
                            end
                        end
                    end
                end
                createloop(2, loop)
            end
            pitAura()
            local function heliModify()
                local function rope()
                    local module = client.modules.loadingBar.new
                    local geomUtils = client.modules.geomUtils
                    local function hook(...)
                        if string.find(debug.traceback(), "_hookNearest") then
                            local master_switch = global.ui_status.master_switch_heli_speed
                            if master_switch then
                                local bool = global.ui_status.instant_rope
                                if bool and not global.ui_status.rope_aura then
                                    if not global.ui_status.kill_all_in_vehicle then
                                        local getLocalVehicle = client.reg.getLocalVehicle
                                        if getLocalVehicle then
                                            local getHeliRope = global.registry.getHeliRope(getLocalVehicle)
                                            if getHeliRope then
                                                local getClosestHeliPickup = global.registry.getClosestHeliPickup(getHeliRope, 50)
                                                if getClosestHeliPickup then
                                                    local cf = getClosestHeliPickup.PrimaryPart.CFrame:PointToObjectSpace(geomUtils.closestPointInPart(getClosestHeliPickup.PrimaryPart, getHeliRope.Position))
                                                    getHeliRope.ReqLink:FireServer(getClosestHeliPickup, cf)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        return module(...)
                    end
                    client.modules.loadingBar.new = hook
                    local function setRopeLength(getLocalVehicle, num)
                        local model = getLocalVehicle.Model
                        if model then
                            local winch = model:FindFirstChild("Winch")
                            if winch then
                                local ropeConstraint = winch:FindFirstChild("RopeConstraint")
                                if ropeConstraint then ropeConstraint.Length = num end
                            end
                        end
                    end
                    local function teleportPlayer()
                        local module = client.modules.vehicle
                        local heli = module.Classes.Heli
                        local getPlayerVehicle = global.registry.getPlayerVehicle
                        local getHeliRope = global.registry.getHeliRope
                        local isUnderRoof = global.registry.isUnderRoof
                        local function setHeliY500(getLocalVehicle)
                            local model = getLocalVehicle.Model
                            if model then
                                model.PrimaryPart.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 500, 0)
                                task.wait(0.5)
                            end
                        end
                        local function getRopePull(getLocalVehicle) return getHeliRope(getLocalVehicle) end
                        local function getRopeConstraint(getLocalVehicle)
                            local model = getLocalVehicle.Model
                            if model then
                                local winch = model:FindFirstChild("Winch")
                                if winch then
                                    local ropeConstraint = winch:FindFirstChild("RopeConstraint")
                                    if ropeConstraint then return ropeConstraint end
                                end
                            end
                            return false
                        end
                        local function dropRope() return heli.attemptDropRope() end
                        local function fireReqLink(getLocalVehicle, vehicle)
                            local getRopePull = getRopePull(getLocalVehicle)
                            if getRopePull then getRopePull.ReqLink:FireServer(vehicle, Vector3.new()) end
                        end
                        local findTarget = global.registry.findTarget
                        global.teleports = {}
                        local location = "None"
                        local statusRobberies = global.ui.statusRobberies
                        statusRobberies["SELECTED_LOCATION"] = ("Current teleport location: %s"):format(location)
                        local tp_locations = {
                            Bossroom = Vector3.new(3154, -204, -4538);
                            Casino = Vector3.new(237, -77, -4498);
                            Diamonds = Vector3.new(973, -86, -203);
                            Lava = Vector3.new(1333, -106, -1057);
                            Powerplant = Vector3.new(118, -11, 2109);
                            Bank = Vector3.new(113, 18, 925);
                            Jewelry = Vector3.new(116, 18, 1297);
                            Museum = Vector3.new(1133, 107, 1306);
                            Computer = Vector3.new(-84, 69, -4626);
                        }
                        local function setLocation(key)
                            assert(tp_locations[key], "Location invalid")
                            location = key
                            statusRobberies["SELECTED_LOCATION"] = ("Current teleport location: %s"):format(location)
                        end
                        global.teleports.setLocation = setLocation
                        local function getLocation()
                            if location == "None" then return false end
                            return tp_locations[location] or false
                        end
                        global.teleports.getLocation = getLocation
                        local is_teleporting = false
                        local is_killing_all = false
                        task.spawn(function()
                            for i,v in next, client.players do
                                local char = v.Character
                                if char then
                                    local root = char.PrimaryPart
                                    if root then player:RequestStreamAroundAsync(root.Position) end
                                end
                            end
                        end)
                        local function teleport_player(name, shouldKillall)
                            if is_teleporting then return false end
                            local location = shouldKillall and tp_locations["Lava"] or getLocation()
                            if not location then
                                global.notify("Select a location!", 5)
                                return false
                            end
                            is_teleporting = true
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if not getLocalVehicle or getLocalVehicle and getLocalVehicle.Type ~= "Heli" then
                                is_teleporting = false
                                return global.notify("You have to be in a helicopter", 5)
                            end
                            if getLocalVehicle.Passenger then
                                is_teleporting = false
                                return false
                            end
                            local char = client.playerCharacter
                            if char then
                                local root = char.PrimaryPart
                                if root then
                                    if isUnderRoof(root) then
                                        is_teleporting = false
                                        return global.notify("You have something over you. Get to a open location!", 5)
                                    end
                                    local target = findTarget(name)
                                    if target then
                                        local character = target.Character
                                        if not character or character and not character:FindFirstChild("InVehicle") then
                                            is_teleporting = false
                                            return global.notify("Target has to be in a vehicle!", 5)
                                        end
                                        local primaryPart = character.PrimaryPart
                                        if primaryPart then
                                            local targetVehicle = getPlayerVehicle(target)
                                            if targetVehicle then
                                                if targetVehicle.Name == "BankTruck" then
                                                    is_teleporting = false
                                                    return global.notify(("%s is in Bank Truck. Failed!"):format(target.Name), 5)
                                                end
                                                if getLocalVehicle.Model.PrimaryPart.Position.y < 500 then
                                                    setHeliY500(getLocalVehicle)
                                                end    
                                                local preset = getLocalVehicle.Model.Preset
                                                local winch = getLocalVehicle.Model.Winch
                                                local rope = {
                                                    pull = preset:FindFirstChild("RopePull");
                                                    constraint = winch:FindFirstChild("RopeConstraint");
                                                }
                                                if not rope.pull then
                                                    heli.attemptDropRope()
                                                    local tg = tick()
                                                    while true do
                                                        if preset:FindFirstChild("RopePull") then break end
                                                        if tick() - tg > 3 then
                                                            is_teleporting = false
                                                            break
                                                        end
                                                        task.wait()
                                                    end
                                                    if not is_teleporting then
                                                        global.notify("Failed x3", 5)
                                                        return false
                                                    end
                                                    preset = getLocalVehicle.Model.Preset
                                                    winch = getLocalVehicle.Model.Winch
                                                    rope.pull = preset.RopePull
                                                    rope.constraint = winch.RopeConstraint
                                                end
                                                rope.pull.CanCollide = false
                                                rope.constraint.WinchEnabled = true
                                                local reqLink = rope.pull:FindFirstChild("ReqLink")
                                                if reqLink then
                                                    local hb, clock = nil, tick()
                                                    hb = runservice.Heartbeat:connect(function()
                                                        if tick() - clock > 2 then
                                                            is_teleporting = false
                                                            hb:disconnect()
                                                            hb = nil
                                                            return false
                                                        end
                                                        if not rope.pull or not rope.pull:IsDescendantOf(workspace) then
                                                            is_teleporting = false
                                                            hb:disconnect()
                                                            hb = nil
                                                            return false
                                                        end
                                                        if not root then
                                                            is_teleporting = false
                                                            hb:disconnect()
                                                            hb = nil
                                                            return false
                                                        end
                                                        if rope.pull:FindFirstChild("AttachedTo") and rope.pull.AttachedTo.Value then
                                                            hb:disconnect()
                                                            hb = nil
                                                            return false
                                                        end
                                                        rope.pull.CFrame = targetVehicle.PrimaryPart.CFrame
                                                        reqLink:FireServer(targetVehicle, Vector3.new())
                                                    end)
                                                    while true do
                                                        if not hb then break end
                                                        task.wait()
                                                    end
                                                    if not is_teleporting then
                                                        global.notify("Failed!", 5)
                                                        return false
                                                    else
                                                        local localWeld = root:FindFirstChild("Weld")
                                                        if localWeld then localWeld.Part1 = targetVehicle.Seat end
                                                        hb, clock = nil, tick()
                                                        hb = runservice.Heartbeat:connect(function()
                                                            if tick() - clock > 2 then
                                                                is_teleporting = false
                                                                hb:disconnect()
                                                                hb = nil
                                                                return false
                                                            end
                                                            if not client.reg.getLocalVehicle then
                                                                is_teleporting = false
                                                                hb:disconnect()
                                                                hb = nil
                                                                return false
                                                            end
                                                            if not rope.pull then
                                                                is_teleporting = false
                                                                hb:disconnect()
                                                                hb = nil
                                                                return false
                                                            end
                                                            if not rope.pull:FindFirstChild("AttachedTo") or not rope.pull.AttachedTo.Value then
                                                                hb:disconnect()
                                                                hb = nil
                                                                return false
                                                            end
                                                            if not character:FindFirstChild("InVehicle") then
                                                                hb:disconnect()
                                                                hb = nil
                                                                return false
                                                            end
                                                            character:PivotTo(CFrame.new(location))
                                                        end)
                                                        while true do
                                                            if not hb then break end
                                                            task.wait()
                                                        end
                                                        if not is_teleporting then
                                                            global.notify("Failed x2!", 5)
                                                            return false
                                                        end
                                                        if localWeld then localWeld.Part1 = getLocalVehicle.Seat end
                                                        if rope.pull and rope.pull:FindFirstChild("AttachedTo") and rope.pull.AttachedTo.Value then
                                                            heli.attemptDropRope()
                                                            while true do
                                                                if not rope.pull:IsDescendantOf(workspace) then break end
                                                                task.wait()
                                                            end
                                                        end
                                                        if not shouldKillall then
                                                            if localWeld then -- doar sa fie sigur :)
                                                                localWeld.Part1 = getLocalVehicle.Seat
                                                            end
                                                            global.notify("Done.", 5)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    else
                                        is_teleporting = false
                                        return global.notify(("Couldn't find target with name `%s`"):format(name), 5)
                                    end
                                end
                            end
                            is_teleporting = false
                        end
                        global.teleports.teleport_player = teleport_player
                        local function loop()
                            if is_killing_all then return false end
                            if client.reg.getLocalVehicle and client.reg.getLocalVehicle.Type == "Heli" then
                                is_killing_all = true
                                local kill_all_vehicle_ignore_teammates = global.ui_status.kill_all_vehicle_ignore_teammates
                                for i,v in next, client.players do
                                    if not global.ui_status.kill_all_in_vehicle then break end
                                    if kill_all_vehicle_ignore_teammates then
                                        if tostring(v.Team) == tostring(player.Team) then continue end
                                    end
                                    local char = v.Character
                                    if char then
                                        if char:FindFirstChild("InVehicle") then teleport_player(v.Name, true) end
                                    end
                                    task.wait(0.15)
                                end
                                is_killing_all = false
                            end
                        end
                        local tagCache
                        local loopf
                        local function tagService()
                            tagCache = client.tags.new("kill_all_in_vehicle", 0, false, function(val)
                                if val then
                                    local vehicle = client.reg.getLocalVehicle
                                    if not vehicle or vehicle and vehicle.Type ~= "Heli" then global.notify("You have to be in a helicopter", 5) end
                                    loopf = createloop(0, loop)
                                else
                                    if loopf then
                                        loopf:disconnect()
                                        loopf = nil
                                    end
                                end
                            end)
                        end
                        tagService()
                        local function loop()
                            local bool = global.ui_status.kill_all_in_vehicle
                            if tagCache then tagCache.obj.Value = bool end
                        end
                        createloop(0, loop)
                    end
                    teleportPlayer()
                    local function loop()
                        local master_switch = global.ui_status.master_switch_heli_speed
                        if master_switch then
                            local bool = global.ui_status.rope_aura
                            local getLocalVehicle = client.reg.getLocalVehicle
                            if getLocalVehicle then
                                if bool and global.ui_status.instant_rope and not global.ui_status.kill_all_in_vehicle then
                                    local getHeliRope = global.registry.getHeliRope(getLocalVehicle)
                                    if getHeliRope and getHeliRope.AttachedTo.Value == nil then
                                        local getClosestHeliPickup = global.registry.getClosestHeliPickup(getHeliRope, 150)
                                        if getClosestHeliPickup then
                                            local cf = getClosestHeliPickup.PrimaryPart.CFrame:PointToObjectSpace(geomUtils.closestPointInPart(getClosestHeliPickup.PrimaryPart, getHeliRope.Position))
                                            getHeliRope.ReqLink:FireServer(getClosestHeliPickup, cf)
                                        end
                                    end
                                end
                                local rope_length = global.ui_status.rope_length or 50
                                setRopeLength(getLocalVehicle, rope_length)
                            end
                        end
                    end
                    createloop(0.2, loop)
                end
                rope()
                local function speed()
                    local function loop()
                        local bool = global.ui_status.master_switch_heli_speed
                        local speed = global.ui_status.heli_speed
                        if not bool then return false end
                        if not client.state.isLocalInVehicle then return false end
                        local vehicle = client.reg.getLocalVehicle
                        if not vehicle then return false end
                        if vehicle.Type == "Heli" then
                            if not vehicle.Velocity then return false end
                            if not vehicle.Velocity.Velocity then return false end
                            local calc = vehicle.Velocity.Velocity * speed
                            vehicle.Velocity.Velocity = calc
                        end
                    end
                    createloop(0, loop)
                end
                speed()
                local function height()
                    local function loop()
                        local bool = global.ui_status.infinite_heli_height
                        if not client.state.isLocalInVehicle then return false end
                        local vehicle = client.reg.getLocalVehicle
                        if not vehicle then return false end
                        if not bool then
                            if vehicle.Type == "Heli" then vehicle.MaxHeight = 400 end
                            return false
                        end
                        if vehicle.Type == "Heli" then vehicle.MaxHeight = math.huge end
                    end
                    createloop(0, loop)
                end
                height()
                local function droneHeight() 
                    local module = client.modules.rayCast.RayIgnoreNonCollideWithIgnoreList
                    local function hook(...)
                        if string.find(debug.traceback(), "Heli") then
                            local bool = global.ui_status.infinite_drone_height
                            local args = {...}
                            if bool then
                                for i,v in next, args[4] do
                                    if v == client.descendants.vehicles then return Vector3.new(0, math.huge, 0), ... end
                                end
                            end
                        end
                        return module(...)
                    end
                    table.insert(client.rayHooks, {
                        fn = hook
                    })
                end
                droneHeight()
            end
            heliModify()
            local function bikeModify()
                local bikes = {}
                local volts = {}
                local chassis2 = client.modules.alexChassis2
                local vehicleBikeEnter = chassis2.VehicleEnter
                local vehicleBikeLeave = chassis2.VehicleLeave
                local volt = client.modules.volt
                local vehicleEnter = volt.VehicleEnter
                local vehicleLeave = volt.VehicleLeave
                local function onVoltVehicleEnter(...)
                    if #volts > 0 then table.clear(volts) end
                    local onVehicleEnteredTick = tick()
                    volts[#volts + 1] = createloop(0, function()
                        local vehicle = client.reg.getLocalVehicle
                        if vehicle then
                            local master_switch_bike = global.ui_status.master_switch_bike
                            if master_switch_bike then
                                local bike_speed = global.ui_status.bike_speed or 1
                                vehicle.Force.Force = vehicle.Force.Force * tonumber(bike_speed)
                            end
                        else
                            if tick() - onVehicleEnteredTick > 5 then
                                volts[#volts]:disconnect()
                                table.clear(volts)
                            end
                        end
                    end)
                    return vehicleEnter(...)
                end 
                local function onVoltVehicleLeave(...)
                    if #volts > 0 then
                        volts[#volts]:disconnect()
                        table.clear(volts)
                    end
                    return vehicleLeave(...)
                end
                volt.VehicleEnter = onVoltVehicleEnter
                volt.VehicleLeave = onVoltVehicleLeave
                local function onBikeVehicleEnter(bike)
                    if tostring(bike.Make) == "Dirtbike" then
                        if #bikes > 0 then
                            bikes[#bikes]:disconnect()
                            table.clear(bikes)
                        end
                        global.BIKE_MEMORY = {
                            WHEELS_HEIGHT = bike.Wheels[1].Height;
                        }
                        bikes[#bikes + 1] = createloop(0, function()
                            local BIKE_MEMORY = global.BIKE_MEMORY
                            local master_switch_bike = global.ui_status.master_switch_bike
                            local dirt_bike_height = global.ui_status.dirt_bike_height
                            if master_switch_bike then
                                local bike_speed = global.ui_status.bike_speed or 1
                                bike.GarageEngineSpeed = 1 * tonumber(bike_speed) * 10
                            else
                                bike.GarageEngineSpeed = 0
                                if dirt_bike_height then
                                    if bike.Wheels[1].Height ~= BIKE_MEMORY.WHEELS_HEIGHT then
                                        for i,v in next, bike.Wheels do v.Height = BIKE_MEMORY.WHEELS_HEIGHT end
                                    end
                                end
                            end
                            if dirt_bike_height then
                                if master_switch_bike then
                                    local bike_height_value = global.ui_status.bike_height_value
                                    for i,v in next, bike.Wheels do v.Height = BIKE_MEMORY.WHEELS_HEIGHT * tonumber(bike_height_value) end
                                end
                            else
                                if bike.Wheels[1].Height ~= BIKE_MEMORY.WHEELS_HEIGHT then
                                    for i,v in next, bike.Wheels do v.Height = BIKE_MEMORY.WHEELS_HEIGHT end
                                end
                            end
                        end)
                    end
                    return vehicleBikeEnter(bike)
                end
                local function onBikeVehicleLeave(bike)
                    if tostring(bike.Make) == "Dirtbike" then
                        if #bikes > 0 then
                            bikes[#bikes]:disconnect()
                            table.clear(bikes)
                        end
                    end
                    return vehicleBikeLeave(bike)
                end
                chassis2.VehicleEnter = onBikeVehicleEnter
                chassis2.VehicleLeave = onBikeVehicleLeave
            end
            bikeModify()
            local function boatModify()
                local boat = client.modules.boat
                local mountPlayer = boat.MountPlayer
                local unmountSeat = boat.UnmountSeat
                local destroy = boat.Destroy
                -- key by the boat object itself (Meta.Id may be absent), and remember the
                -- baseline SpeedForward so we can restore it (Config can be shared)
                local boats = setmetatable({}, {__mode = "k"})
                local function startBoat(x)
                    if not x or boats[x] then return end
                    local config = x.Config
                    if not config or config.SpeedForward == nil then return end
                    local base = config.SpeedForward
                    local entry = {base = base}
                    entry.loop = createloop(0, function()
                        if not x.Config then return false end
                        if global.ui_status.master_switch_boat then
                            if global.ui_status.boat_on_land then x.WaterHeight = 20 end
                            x.Config.SpeedForward = base * (tonumber(global.ui_status.boat_speed) or 1)
                        else
                            x.Config.SpeedForward = base
                        end
                    end)
                    boats[x] = entry
                end
                local function stopBoat(x)
                    local entry = x and boats[x]
                    if not entry then return end
                    if entry.loop then entry.loop:disconnect() end
                    if x.Config and entry.base ~= nil then
                        pcall(function()
                            x.Config.SpeedForward = entry.base
                        end)
                    end
                    boats[x] = nil
                end
                local function onBoatMountPlayer(x, y, ...)
                    if y == player then startBoat(x) end
                    return mountPlayer(x, y, ...)
                end
                local function onBoatUnmountSeat(x, y, ...)
                    if y and y.Player == player then stopBoat(x) end
                    return unmountSeat(x, y, ...)
                end
                local function onBoatDestroy(x, ...)
                    stopBoat(x)
                    return destroy(x, ...)
                end
                boat.MountPlayer = onBoatMountPlayer
                boat.UnmountSeat = onBoatUnmountSeat
                boat.Destroy = onBoatDestroy
            end
            boatModify()
            local function planeModify()
                local plane = {}
                local function jet()
                    local jet = client.modules.jet
                    local jetMountPlayer = jet.MountPlayer
                    local jetUnmountSeat = jet.UnmountSeat
                    local jetDestroy = jet.Destroy
                    local seekingMissileUtils = client.modules.seekingMissileUtils
                    local setTargetPos = seekingMissileUtils.setTargetPos
                    local function onSetTargetPos(obj, x)
                        if #plane > 0 then
                            local getClosestPlayer = client.reg.getClosestPlayerByFov
                            if getClosestPlayer then
                                local char = getClosestPlayer.Character
                                if char then
                                    local primaryPart = char.PrimaryPart
                                    if primaryPart then x = primaryPart.Position end
                                end
                            end
                        end
                        return setTargetPos(obj, x)
                    end
                    local function onJetMountPlayer(x, y, ...)
                        if y == player and not plane[x.Plane.Id] then
                            global.PLANE_MEMORY = {
                                HEIGHT_MAX = x.Plane.CONST.HEIGHT_MAX;
                                MAX_THRUST = x.Plane.CONST.MAX_THRUST;
                            }
                            plane[x.Plane.Id] = {
                                LIFE = createloop(0, function()
                                    local master_switch_plane = global.ui_status.master_switch_plane
                                    local plane_speed = global.ui_status.plane_speed or 1
                                    local anti_max_height = global.ui_status.anti_max_height
                                    local automatic_jet_heat_seek = global.ui_status.automatic_jet_heat_seek
                                    local PLANE_MEMORY = global.PLANE_MEMORY
                                    if anti_max_height then
                                        if master_switch_plane then
                                            x.Plane.CONST.HEIGHT_MAX = math.huge
                                        else
                                            x.Plane.CONST.HEIGHT_MAX = PLANE_MEMORY.HEIGHT_MAX 
                                        end
                                    else
                                        x.Plane.CONST.HEIGHT_MAX = PLANE_MEMORY.HEIGHT_MAX
                                    end
                                    if master_switch_plane then
                                        if automatic_jet_heat_seek then
                                            local getClosestPlayer = client.reg.getClosestPlayerByFov
                                            if getClosestPlayer then
                                                local char = getClosestPlayer.Character
                                                if char then
                                                    local primaryPart = char.PrimaryPart
                                                    if primaryPart then
                                                        if x.targetPart ~= primaryPart then
                                                            x.targetPart = primaryPart
                                                            x.targetPartFoundAt = os.clock()
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        x.Plane.CONST.MAX_THRUST = PLANE_MEMORY.MAX_THRUST * tonumber(plane_speed)
                                    else
                                        x.Plane.CONST.MAX_THRUST = PLANE_MEMORY.MAX_THRUST
                                    end
                                end)
                            }
                        end
                        return jetMountPlayer(x, y, ...)
                    end
                    local function onJetUnmountSeat(x, y)
                        if plane[x.Plane.Id] and y.Player == player then
                            global.PLANE_MEMORY = nil
                            plane[x.Plane.Id].LIFE:disconnect()
                            plane[x.Plane.Id] = nil
                        end
                        return jetUnmountSeat(x, y)
                    end
                    local function onJetDestroy(x)
                        if plane[x.Plane.Id] then
                            global.PLANE_MEMORY = nil
                            plane[x.Plane.Id].LIFE:disconnect()
                            plane[x.Plane.Id] = nil
                        end
                        return jetDestroy(x)
                    end
                    seekingMissileUtils.setTargetPos = onSetTargetPos
                    jet.MountPlayer = onJetMountPlayer
                    jet.UnmountSeat = onJetUnmountSeat
                    jet.Destroy = onJetDestroy
                end
                jet()
                local function stunt()
                    local stunt = client.modules.stunt
                    local stuntMountPlayer = stunt.MountPlayer
                    local stuntUnmountSeat = stunt.UnmountSeat
                    local stuntDestroy = stunt.Destroy
                    local function onStuntMountPlayer(x, y, ...)
                        if y == player and not plane[x.Plane.Id] then
                            global.PLANE_MEMORY = {
                                HEIGHT_MAX = x.Plane.CONST.HEIGHT_MAX;
                                MAX_THRUST = x.Plane.CONST.MAX_THRUST;
                            }
                            plane[x.Plane.Id] = {
                                PLANE = global.PLANE_MEMORY;
                                CREATION_TIME = tick();
                                LIFE = createloop(0, function()
                                    local master_switch_plane = global.ui_status.master_switch_plane
                                    local plane_speed = global.ui_status.plane_speed or 1
                                    local anti_max_height = global.ui_status.anti_max_height
                                    local PLANE_MEMORY = global.PLANE_MEMORY
                                    if anti_max_height then
                                        if master_switch_plane then
                                            x.Plane.CONST.HEIGHT_MAX = math.huge
                                        else
                                            x.Plane.CONST.HEIGHT_MAX = PLANE_MEMORY.HEIGHT_MAX 
                                        end
                                    else
                                        x.Plane.CONST.HEIGHT_MAX = PLANE_MEMORY.HEIGHT_MAX
                                    end
                                    if master_switch_plane then
                                        x.Plane.CONST.MAX_THRUST = PLANE_MEMORY.MAX_THRUST * tonumber(plane_speed)
                                    else
                                        x.Plane.CONST.MAX_THRUST = PLANE_MEMORY.MAX_THRUST
                                    end
                                end)
                            }
                        end
                        return stuntMountPlayer(x, y, ...)
                    end
                    local function onStuntUnmountSeat(x, y)
                        if plane[x.Plane.Id] and y.Player == player then
                            global.PLANE_MEMORY = nil
                            plane[x.Plane.Id].LIFE:disconnect()
                            plane[x.Plane.Id] = nil
                        end
                        return stuntUnmountSeat(x, y)
                    end
                    local function onStuntDestroy(x)
                        if plane[x.Plane.Id] then
                            global.PLANE_MEMORY = nil
                            plane[x.Plane.Id].LIFE:disconnect()
                            plane[x.Plane.Id] = nil
                        end
                        return stuntDestroy(x)
                    end
                    stunt.MountPlayer = onStuntMountPlayer
                    stunt.UnmountSeat = onStuntUnmountSeat
                    stunt.Destroy = onStuntDestroy
                end
                stunt()
            end
            planeModify()
            local function carModify()
                local function on_loadup()
                    local function onVehicleEntered(obj)
                        if obj.Name == "InVehicle" then
                            local car
                            while true do
                                task.wait()
                                if car then break end
                                car = client.reg.getLocalVehicle
                            end
                            if car.GarageEngineSpeed ~= nil and tostring(car.Make) ~= "Dirtbike" then
                                local memory = {
                                    speed = car.GarageEngineSpeed or 1;
                                    brakes = car.GarageBrakes or 1;
                                    turnspeed = car.TurnSpeed or 1;
                                    height = car.Height or 3;
                                }
                                global.registry.vehicle_memory = memory
                                local bool = global.ui_status.master_switch_carmodify
                                if not bool then
                                    local memory = global.registry.vehicle_memory
                                    if memory and car.GarageEngineSpeed ~= nil then
                                        car.GarageEngineSpeed = memory.speed
                                        car.GarageBrakes = memory.brakes
                                        car.TurnSpeed = memory.turnspeed
                                        car.Height = memory.height
                                    end
                                    return false
                                end
                                task.delay(0.1, function()
                                    local modifytbl = {
                                        speed = global.ui_status.car_speed or 1;
                                        brakes = global.ui_status.car_brakes or 1;
                                        turnspeed = global.ui_status.car_turnspeed or 1;
                                        height = global.ui_status.car_height or 3;
                                    }
                                    if car then
                                        car.GarageEngineSpeed = modifytbl.speed
                                        car.GarageBrakes = modifytbl.brakes
                                        car.TurnSpeed = modifytbl.turnspeed
                                        car.Height = modifytbl.height
                                    end
                                end)
                            end
                            return true
                        end
                    end
                    local function onVehicleExit(obj)
                        local bool = global.ui_status.master_switch_carmodify
                        if obj.Name == "InVehicle" then
                            if not bool and global.registry.vehicle_memory ~= nil then global.registry.vehicle_memory = nil end
                        end
                    end
                    local function onCharacterAdded()
                        local char = player.Character
                        if char then char.ChildAdded:connect(onVehicleEntered) end
                    end
                    local function onCharacterRemoving()
                        local char = player.Character
                        if char then char.ChildRemoved:connect(onVehicleExit) end
                    end
                    player.CharacterAdded:connect(onCharacterAdded)
                    player.CharacterRemoving:connect(onCharacterAdded)
                end
                on_loadup()
                local function loop()
                    local car = client.reg.getLocalVehicle
                    if not car then return false end
                    local memory = global.registry.vehicle_memory
                    local bool = global.ui_status.master_switch_carmodify
                    if not bool then
                        if memory then
                            if car and car.GarageEngineSpeed ~= nil and tostring(car.Make) ~= "Dirtbike" then
                                car.GarageEngineSpeed = memory.speed or 1
                                car.GarageBrakes = memory.brakes or 1
                                car.TurnSpeed = memory.turnspeed or 1
                                car.Height = memory.height or 3
                            end
                        end
                        return false
                    end
                    if car and not memory then
                        memory = {}
                        memory.speed = car.GarageEngineSpeed or 1
                        memory.brakes = car.GarageBrakes or 1
                        memory.turnspeed = car.TurnSpeed or 1
                        memory.height = car.Height or 3
                        global.registry.vehicle_memory = memory
                    end
                    if memory then
                        local car_speed = global.ui_status.car_speed or 1
                        local car_brakes = global.ui_status.car_brakes or 1
                        local car_turnspeed = global.ui_status.car_turnspeed or 1
                        local car_height = global.ui_status.car_height or 3
                        if car and car.GarageEngineSpeed ~= nil and tostring(car.Make) ~= "Dirtbike" then
                            car.GarageEngineSpeed = car_speed
                            car.GarageBrakes = car_brakes
                            car.TurnSpeed = car_turnspeed
                            car.Height = car_height
                        end
                    end
                end
                createloop(0, loop)
            end
            carModify()
            local function nitroCorrection()
                local function loop()
                    local master_switch_carmodify = global.ui_status.master_switch_carmodify
                    if not master_switch_carmodify then return false end
                    local bool = global.ui_status.infinite_nitro
                    if not bool then return false end
                    local nitro = global.registry.nitro
                    if not nitro then return false end
                    nitro.Nitro = 249
                    nitro.NitroLastMax = 250
                end
                createloop(0, loop)
            end
            nitroCorrection()
            local function hotbarCorrection()
                local hasInVehicleTag = global.registry.hasInVehicleTag
                local function loop()
                local hotbargui = player:FindFirstChild("PlayerGui")
                    and player.PlayerGui:FindFirstChild("HotbarGui")

                if not hotbargui then return end
                if client.playerCharacter and hasInVehicleTag(client.playerCharacter) then
                    hotbargui.Enabled = global.ui_status.show_hotbar_in_vehicle
                else
                    hotbargui.Enabled = true
                end
            end
                createloop(0, loop)
            end
            hotbarCorrection()
            local function tirePopCorrection()
                local cache
                local function tagService()
                    cache = client.tags.new("antibreakvehicle", 0, false, function(val)
                        local vehicle = client.reg.getLocalVehicle
                        if val then
                            if vehicle and vehicle.Type == "Heli" then
                                vehicle.FallOutOfSkyDuration = 0
                                vehicle.DisableDuration = 0
                            elseif vehicle and vehicle.Type == "Chassis" then
                                vehicle.TirePopDuration = 0
                                vehicle.DisableDuration = 0
                                vehicle.TirePopProportion = 0
                            end
                        else
                            if vehicle and vehicle.Type == "Heli" then
                                vehicle.FallOutOfSkyDuration = 10
                                vehicle.DisableDuration = 10
                            elseif vehicle and vehicle.Type == "Chassis" then
                                vehicle.TirePopDuration = 7.5
                                vehicle.DisableDuration = 7.5
                                vehicle.TirePopProportion = 0.5
                            end
                        end
                    end)
                end
                tagService()
                local function onVehicleEntered(obj)
                    if obj.Name == "InVehicle" then
                        if global.ui_status.antitirepop then
                            local vehicle
                            while true do
                                if vehicle then break end
                                vehicle = client.reg.getLocalVehicle
                                task.wait()
                            end
                            if vehicle.Type == "Heli" then
                                vehicle.FallOutOfSkyDuration = 0
                                vehicle.DisableDuration = 0
                            end
                            if vehicle.Type == "Chassis" then
                                vehicle.TirePopDuration = 0
                                vehicle.DisableDuration = 0
                                vehicle.TirePopProportion = 0
                            end
                        end
                    end
                end
                local function onCharacterAdded()
                    local char = player.Character
                    if char then char.ChildAdded:connect(onVehicleEntered) end
                end
                onCharacterAdded()
                player.CharacterAdded:connect(onCharacterAdded)
                global.syncTagValue(cache, "antitirepop")
            end
            tirePopCorrection()
        end
        vehicleCorrection()
        local function equipCorrection()
            local function onDuck()
                local crawl = getupvalue(global.registry.iscrawling, 1)
                local function loop()
                    local bool = global.ui_status.allow_equip_on_duck
                    if bool then
                        if crawl.IsCrawling then crawl.IsCrawling = false end
                    end
                end
                createloop(0, loop)
            end
            onDuck()
            local function hasItems()
                local function loop()
                    local bool = global.ui_status.allow_equip_with_items
                    local gem = player.Folder:FindFirstChild("Gem")
                    local bag = player.Folder:FindFirstChild("Bag")
                    local crate = player.Folder:FindFirstChild("Crate")
                    local inventoryUtils = client.modules.inventoryItemUtils
                    if gem then inventoryUtils.setLocked(gem, not bool) end
                    if crate then inventoryUtils.setLocked(crate, not bool) end
                    if bag then inventoryUtils.setLocked(bag, not bool) end
                end
                createloop(1, loop)
            end
            hasItems()
            local function isFlying()
                local module = client.modules.jetpack.IsFlying
                local function hook(...)
                    local bool = global.ui_status.allow_equip_while_flying
                    if bool then return false end
                    return module(...)
                end
                client.modules.jetpack.IsFlying = hook
            end
            isFlying()
        end
        equipCorrection()
        local function soundCorrection()
            local function assignsounds()
                local controls = global.ui.controls
                local cfg = controls.playsounds
                local sounds = global.registry.sounds
                cfg.list = sounds
                task.delay(0.2, function()
                    cfg.reload(cfg.list)
                end)
            end
            assignsounds()
            local function playsounds()
                local callback = global.callback
                local playsounds = global.registry.playSounds
                local function loop()
                    local bool = global.ui_status.annoyserver
                    if not bool then return false end
                    playsounds("Horn", {
                        Source = client.playerCharacter;
                        MaxTime = 1;
                        Volume = math.huge;
                    })
                end
                createloop(1, loop)
            end
            playsounds()
        end
        soundCorrection()
        local function gunCorrection()
            local function cacheForGetEq()
                local cache
                local function tagService()
                    cache = client.tags.new("getEquippedItem", 0, false, function(val)
                        if val then
                            for i,v in next, client.onGetEq do v._fn() end
                        else
                            local playerGui = player.PlayerGui
                            local crosshairs = {}
                            for i,v in next, playerGui:GetChildren() do
                                if v.Name == "CrossHairGui" then table.insert(crosshairs, v) end
                            end
                            task.delay(0.2, function()
                                for i,v in next, crosshairs do v:Destroy() end
                            end)
                        end
                    end)
                end
                tagService()
                local function loop()
                    local getEquippedItem = client.reg.getEquippedItem and true or false
                    if cache then cache.obj.Value = getEquippedItem end
                end
                createloop(0, loop)
            end
            cacheForGetEq()
            local function wallbang()
                local cache
                -- Plasma uses a direct raycast in ShootOther, so excluding workspace from
                -- its IgnoreList makes it hit nothing. Plasma wallbang is handled in the
                -- plasma ShootOther hook instead; skip it here.
                local function canWallbangViaIgnore(getEquippedItem) return getEquippedItem and getEquippedItem.IgnoreList and getEquippedItem.__ClassName ~= "PlasmaGun" end
                local function addWorkspaceIgnore(ignoreList)
                    if not table.find(ignoreList, workspace) then table.insert(ignoreList, workspace) end
                end
                local function removeWorkspaceIgnore(ignoreList)
                    for i = #ignoreList, 1, -1 do
                        if ignoreList[i] == workspace then table.remove(ignoreList, i) end
                    end
                end
                local function tagService()
                    cache = client.tags.new("wallbang", 0, false, function(val)
                        local getEquippedItem = client.reg.getEquippedItem
                        if canWallbangViaIgnore(getEquippedItem) then
                            local ignoreList = getEquippedItem.IgnoreList
                            if val then
                                addWorkspaceIgnore(ignoreList)
                            else
                                removeWorkspaceIgnore(ignoreList)
                            end
                        end
                    end)
                end
                tagService()
                local function _fn()
                    local bool = global.ui_status.wallbang
                    if bool then
                        local getEquippedItem = client.reg.getEquippedItem
                        if canWallbangViaIgnore(getEquippedItem) then addWorkspaceIgnore(getEquippedItem.IgnoreList) end
                    end
                end
                table.insert(client.onGetEq, {
                    _fn = _fn;
                })
                global.syncTagValue(cache, "wallbang")
            end
            wallbang()
            local function scopegui()
                -- Keep scoping from reducing camera sensitivity. The old version captured
                -- itemCamera.getSensitivity() and re-applied it every frame -- but that value
                -- is the LIVE sensitivity, so enabling/re-equipping while already scoped locked
                -- in the slow scoped value and made the camera randomly slow. Instead, hook
                -- setSensitivity (which the game calls to reduce sensitivity on scope) and
                -- no-op it while the feature is on, so sensitivity simply never drops.
                local ok, itemCamera = pcall(function() return require(repl.Game.ItemSystem.ItemCamera) end)
                if ok and type(itemCamera) == "table" and type(itemCamera.setSensitivity) == "function" and not itemCamera.CrewbattlerSensHooked then
                    itemCamera.CrewbattlerSensHooked = true
                    local originalSet = itemCamera.setSensitivity
                    itemCamera.setSensitivity = function(value, ...)
                        if global.ui_status.anti_scope_ui then return function() end end
                        return originalSet(value, ...)
                    end
                end
                local function loop()
                    if not global.ui_status.anti_scope_ui then return false end
                    local equippedItem = client.reg.getEquippedItem
                    if not equippedItem then return false end
                    local scopegui = equippedItem.ScopeGui
                    if scopegui then scopegui.Enabled = false end
                end
                createloop(0, loop)
            end
            scopegui()
            local function noSniperZoom()
                -- ScopeBegin calls ItemCamera.Zoom(scopeFOV) to zoom in; ignore that
                -- call so scoping never changes the camera FOV (no first-person zoom)
                local ok, itemCamera = pcall(function()
                    return require(repl.Game.ItemSystem.ItemCamera)
                end)
                if not ok or type(itemCamera) ~= "table" or type(itemCamera.Zoom) ~= "function" or itemCamera.CrewbattlerNoZoomHooked then return false end
                itemCamera.CrewbattlerNoZoomHooked = true
                local originalZoom = itemCamera.Zoom
                itemCamera.Zoom = function(...)
                    if global.ui_status.sniper_no_zoom then return end
                    return originalZoom(...)
                end
            end
            noSniperZoom()
            local function extendRange()
                -- plasma is hitscan via Config.Range; bullet guns travel BulletSpeed *
                -- BulletEmitter.LifeSpan, so extend LifeSpan. Save originals to restore.
                local saved = setmetatable({}, {__mode = "k"})
                local function loop()
                    local bool = global.ui_status.extend_range
                    local item = client.reg.getEquippedItem
                    if not item then return false end
                    local mult = tonumber(global.ui_status.extend_range_mult) or 3
                    if mult < 1 then mult = 1 end
                    local config = item.Config
                    if config and type(config.Range) == "number" then
                        if saved[config] == nil then saved[config] = config.Range end
                        config.Range = bool and saved[config] * mult or saved[config]
                    end
                    local emitter = item.BulletEmitter
                    if emitter and type(emitter.LifeSpan) == "number" then
                        if saved[emitter] == nil then saved[emitter] = emitter.LifeSpan end
                        emitter.LifeSpan = bool and saved[emitter] * mult or saved[emitter]
                    end
                end
                createloop(0.2, loop)
            end
            extendRange()
            local function instantSeek()
                local rocketLauncherConsts = client.modules.rocketLauncherConsts
                setreadonly(rocketLauncherConsts, false)
                local cache
                local function tagService()
                    cache = client.tags.new("instantSeek", 0, false, function(val)
                        if val then
                            rocketLauncherConsts.SEEKING_LOCK_MIN_DURATION = 0
                        else
                            rocketLauncherConsts.SEEKING_LOCK_MIN_DURATION = 2
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "instant_seek")
            end
            instantSeek()
            local function instantReload()
                local function getCurrentGun()
                    local gun = client.reg.getEquippedItem
                    if gun then return gun end
                    return false
                end
                local function getCurrentGunClassName()
                    local getCurrentGun = getCurrentGun()
                    if getCurrentGun and getCurrentGun.BulletEmitter then return getCurrentGun.__ClassName end
                    return "unknown"
                end
                local function hasPlayerEquippedClassNameGun(name)
                    if table.find(client.reg.resolveEquippedItems, name) then return true end
                    return false
                end
                local function isWeaponFlagOutOfAmmo(gun)
                    local getCurrentGun = gun
                    if getCurrentGun then
                        if getCurrentGun.IsReloading then return true end
                        if getCurrentGun.AmmoGui and getCurrentGun.AmmoGui.FlagOutOfAmmo then return true end
                    end
                    return false
                end
                local function getHotbarItems() return client.modules.hotbarItemSystem.getSortedHotbarItemsFor(player) end
                local function setDisplayOrder(obj, num) return client.modules.hotbarItemUtils.setDisplayOrder(obj, num) end
                local isReloading = false
                local onLastReload = tick()
                local function loop()
                    if isReloading and global.is_instant_reloading then return false end
                    local dropGun = global.registry.dropGun
                    local equipOwnedItem = global.registry.equipOwnedItem
                    local equip = global.registry.equip
                    local currentGun = getCurrentGun()
                    if currentGun and currentGun.BulletEmitter and isWeaponFlagOutOfAmmo(currentGun) then
                        global.is_instant_reloading = true
                        onLastReload = tick()
                        isReloading = true
                        local __ClassName = getCurrentGunClassName()
                        if __ClassName == "unknown" or __ClassName == "C4" or __ClassName == "RocketLauncher" or __ClassName == "Grenade" or __ClassName == "SmokeGrenade" then
                            isReloading = false
                            global.is_instant_reloading = false
                            return false
                        end
                        if __ClassName == "Flintlock" or __ClassName == "Sniper" then task.wait(0.2) end
                        local reload_timeout
                        reload_timeout = createloop(0, function()
                            if not client.playerCharacter or client.playerCharacter and not client.playerCharacter.PrimaryPart then 
                                isReloading = false
                                global.is_instant_reloading = false
                                reload_timeout:disconnect()
                                reload_timeout = nil
                                return false
                            end
                            if not isReloading then
                                reload_timeout:disconnect()
                                reload_timeout = nil
                            else
                                if tick() - onLastReload > 3 then
                                    log("RELOAD TIMEOUT")
                                    isReloading = false
                                    global.is_instant_reloading = false
                                    reload_timeout:disconnect()
                                    reload_timeout = nil
                                end
                            end
                        end)
                        local hotbar1 = getHotbarItems()
                        local oldPosition
                        for i,v in next, hotbar1 do
                            if v.obj and tostring(v.obj) == tostring(__ClassName) then
                                oldPosition = i
                                break
                            end
                        end
                        if not global.is_instant_reloading then
                            isReloading = false
                            global.is_instant_reloading = false
                            return false
                        end
                        equipOwnedItem(__ClassName, true)
                        while true do
                            if not getCurrentGun() then
                                equipOwnedItem(__ClassName)
                                break
                            end
                            if getCurrentGun() then equipOwnedItem(__ClassName, true) end
                            task.wait()
                        end
                        while true do
                            if hasPlayerEquippedClassNameGun(__ClassName) then
                                equip(__ClassName)
                                break
                            end
                            if not hasPlayerEquippedClassNameGun(__ClassName) then equipOwnedItem(__ClassName) end
                            task.wait()
                        end
                        while true do
                            if hasPlayerEquippedClassNameGun(__ClassName) then
                                if getCurrentGun() then break end
                                equip(__ClassName)
                            else
                                equipOwnedItem(__ClassName)
                                while true do
                                    if hasPlayerEquippedClassNameGun(__ClassName) then
                                        equip(__ClassName)
                                        break
                                    end
                                    if not hasPlayerEquippedClassNameGun(__ClassName) then equipOwnedItem(__ClassName) end
                                    task.wait()
                                end
                                if not getCurrentGun() then equip(__ClassName) end
                            end
                            if not getCurrentGun() then
                                equip(__ClassName)
                                if getCurrentGun() then
                                    break
                                else
                                    equip(__ClassName)
                                end
                            end
                            task.wait()
                        end
                        local hotbar2 = getHotbarItems()
                        for i,v in next, hotbar2 do
                            if v.obj and tostring(v.obj) == tostring(__ClassName) then
                                setDisplayOrder(v.obj, oldPosition)
                                break
                            end
                        end
                        global.is_instant_reloading = false
                        isReloading = false
                    end
                end
                local loopf
                local cache
                local function tagService()
                    cache = client.tags.new("instantReload", 0, false, function(val)
                        if val then
                            loopf = createloop(0, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "instant_reload")
            end
            instantReload()
            local function weaponHooks()
                local rocketAccelerate
                local flintlockAccelerate
                local function rocketHook(...)
                    local bool = global.ui_status.no_recoil
                    if bool then return true end
                    return rocketAccelerate(...)
                end
                local function knockbackHook(...)
                    local bool = global.ui_status.anti_flintlock_knockback
                    if bool then return task.wait(9e9) end
                    return flintlockAccelerate(...)
                end
                local function knockback()
                    local getEquippedItem = client.reg.getEquippedItem
                    if getEquippedItem and getEquippedItem.__ClassName == "Flintlock" then
                        if not flintlockAccelerate then
                            flintlockAccelerate = getEquippedItem.SpringKnockback.Accelerate
                            getEquippedItem.SpringKnockback.Accelerate = knockbackHook
                        end
                    else
                        flintlockAccelerate = nil
                    end
                end
                local function recoil()
                    local getEquippedItem = client.reg.getEquippedItem
                    if getEquippedItem and getEquippedItem.__ClassName == "RocketLauncher" then
                        if not rocketAccelerate then
                            rocketAccelerate = getEquippedItem.SpringCamera.Accelerate
                            getEquippedItem.SpringCamera.Accelerate = rocketHook
                        end
                    else
                        rocketAccelerate = nil
                    end
                end
                local kbcache, kbloop
                local recoilcache, recoilloop
                local function tagService()
                    kbcache = client.tags.new("knockback", 0, false, function(val)
                        if val then
                            kbloop = createloop(0, knockback)
                        else
                            if kbloop then
                                kbloop:disconnect()
                                kbloop = nil
                            end
                        end
                    end)
                    recoilcache = client.tags.new("recoil", 0, false, function(val)
                        if val then
                            recoilloop = createloop(0, recoil)
                        else
                            if recoilloop then
                                recoilloop:disconnect()
                                recoilloop = nil
                            end
                        end
                    end)
                end
                tagService()
                local function loop()
                    local bool = global.ui_status.no_recoil
                    if recoilcache then recoilcache.obj.Value = bool end
                    local kbbool = global.ui_status.anti_flintlock_knockback
                    if kbcache then kbcache.obj.Value = kbbool end
                end
                createloop(0, loop)
            end
            weaponHooks()
            local function killaura()
                local validGuns = {
                    "Rifle";
                    "Pistol";
                    "Shotgun";
                    "Revolver";
                    "Flintlock";
                    "AK47";
                    "Uzi";
                    "PlasmaPistol";
                    "Sniper";
                }
                local function isHoldingWeapon() return client.reg.getEquippedItem end
                local function hasPistolInInventory() return table.find(client.reg.resolveEquippedItems, "Pistol") end
                local equipOwnedItem = global.registry.equipOwnedItem
                local shootGun = global.registry.shootGun
                local unequipAll = global.registry.unequipAll
                local equip = global.registry.equip
                local last_shot_at = tick()
                local oldTarget
                local isScanning = false
                local weapon_used
                local function loop()
                    if global.is_instant_reloading then return false end
                    if global.is_registering_item then return false end
                    if client.state.isLocalInVehicle then return false end
                    if isScanning then return false end
                    isScanning = true
                    if weapon_used then
                        if weapon_used == "Sniper" or weapon_used == "Flintlock" then task.wait(0.2) end
                    end
                    local hasPistolEquipped = false
                    local getClosestVulnerablePlayer = client.reg.getClosestVulnerablePlayer
                    if getClosestVulnerablePlayer then
                        local isHolding = isHoldingWeapon()
                        if not isHolding then
                            hasPistolEquipped = false
                            local hasPistol = hasPistolInInventory()
                            if not hasPistol then
                                while true do
                                    if hasPistol then break end
                                    equipOwnedItem("Pistol")
                                    hasPistol = hasPistolInInventory()
                                    task.wait(0.2)
                                end
                            end
                            while true do
                                if isHolding then break end
                                equip("Pistol")
                                isHolding = hasPistolInInventory()
                                task.wait(0.2)
                            end
                        else
                            if not table.find(validGuns, isHolding.__ClassName) then
                                unequipAll()
                                isScanning = false
                                return false
                            end
                            weapon_used = isHolding.__ClassName
                            hasPistolEquipped = true
                        end
                        if oldTarget ~= getClosestVulnerablePlayer then
                            oldTarget = getClosestVulnerablePlayer
                            local char = getClosestVulnerablePlayer.Character
                            if char then
                                local hum = char:FindFirstChild("Humanoid")
                                if hum then
                                    local connection
                                    connection = hum.Died:connect(function()
                                        connection:disconnect()
                                        print("closest player died")
                                        connection = nil
                                        oldTarget = nil
                                        if not hasPistolEquipped then unequipAll() end
                                    end)
                                end
                            end
                        end
                        shootGun()
                    end
                    isScanning = false
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("killaura", 0, false, function(val)
                        if val then
                            loopf = createloop(0, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "killaura_masterswitch")
            end
            killaura()
            local function autoShoot()
                local lastUsedShoot = tick()
                local checkWallBeforePenetration = global.registry.checkWallBeforePenetration
                local function loop()
                    local master_switch = global.ui_status.master_switch_silentaim
                    if master_switch and global._loaded then
                        local bool = global.ui_status.automatic_shoot
                        if bool then
                            local getEquippedItem = client.reg.getEquippedItem 
                            if getEquippedItem then
                                local getClosestPlayerByFov = client.reg.getClosestPlayerByFov
                                if getClosestPlayerByFov then
                                    if global.ui_status.no_wall_penetration then
                                        if not checkWallBeforePenetration(getClosestPlayerByFov) then return false end
                                    end
                                    if getEquippedItem.__ClassName == "RocketLauncher" or getEquippedItem.__ClassName == "C4" or getEquippedItem.__ClassName == "SmokeGrenade" then return false end
                                    if getEquippedItem.__ClassName == "Sniper" or getEquippedItem.__ClassName == "Flintlock" then
                                        if tick() - lastUsedShoot < 1 then return false end
                                        lastUsedShoot = tick()
                                        task.wait(0.2)
                                    end
                                    local shootGun = global.registry.shootGun
                                    if shootGun then return shootGun() end
                                end
                            end
                        end
                    end
                end
                createloop(0, loop)
            end
            autoShoot()
            local function automatic_fire()
                local automaticweapons = {
                    Flintlock = true;
                    NerfPistol = true;
                    NerfResolver = true;
                    Pistol = true;
                    PlasmaPistol = true;
                    Revolver = true;
                    Shotgun = true;
                    Sniper = true;
                }
                local function loop()
                    local bool = global.ui_status.automatic_fire
                    local getEquippedItem = client.reg.getEquippedItem
                    if getEquippedItem then
                        if automaticweapons[getEquippedItem.__ClassName] then getEquippedItem.Config.FireAuto = bool end
                    end
                end
                createloop(0, loop)
            end
            automatic_fire()
            -- original rapid fire: just scale Config.FireFreq. Works on the plasma
            -- pistol (it fires continuously); semi-auto guns simply don't benefit.
            -- No FireAuto forcing / no class gate (that combo broke it on plasma).
            local function rapidFire()
                -- weak keys so unequipped guns' Config tables can be collected
                local savedFreq = setmetatable({}, {__mode = "k"})
                local function restoreAll()
                    for config, freq in pairs(savedFreq) do
                        pcall(function()
                            config.FireFreq = freq
                        end)
                        savedFreq[config] = nil
                    end
                end
                local function loop()
                    local bool = global.ui_status.rapid_fire
                    if not bool then
                        if next(savedFreq) then restoreAll() end
                        return false
                    end
                    local getEquippedItem = client.reg.getEquippedItem
                    if not getEquippedItem then return false end
                    local config = getEquippedItem.Config
                    if not config or config.FireFreq == nil then return false end
                    if savedFreq[config] == nil then savedFreq[config] = config.FireFreq end
                    local base = savedFreq[config]
                    if not base then return false end
                    local mult = tonumber(global.ui_status.rapid_fire_multiplier) or 3
                    if mult < 1 then mult = 1 end
                    config.FireFreq = base * mult
                end
                createloop(0, loop)
            end
            rapidFire()
            local function no_recoil()
                local camShake = {
                    AK47 = 10;
                    Flintlock = 150;
                    NerfPistol = 10;
                    NerfResolver = 100;
                    Pistol = 10;
                    PlasmaPistol = 15;
                    Revolver = 100;
                    Rifle = 10;
                    Shotgun = 80;
                    Sniper = 80;
                    Uzi = 15;
                }
                local function loop()
                    local bool = global.ui_status.no_recoil
                    local getEquippedItem = client.reg.getEquippedItem
                    if getEquippedItem then
                        if not bool then
                            if camShake[getEquippedItem.__ClassName] then getEquippedItem.Config.CamShakeMagnitude = camShake[getEquippedItem.__ClassName] end
                        else
                            if getEquippedItem.Config.CamShakeMagnitude ~= nil then getEquippedItem.Config.CamShakeMagnitude = 0 end
                        end
                    end
                end
                createloop(0, loop)
            end
            no_recoil()
            local function no_spread()
                local function loop()
                    local bool = global.ui_status.no_spread
                    local getEquippedItem = client.reg.getEquippedItem
                    if getEquippedItem then
                        local cfg = getEquippedItem.Config
                        if not cfg.DefaultSpread then
                            cfg.DefaultSpread = cfg.BulletSpread
                        else
                            if not bool then
                                cfg.BulletSpread = cfg.DefaultSpread
                            else
                                cfg.BulletSpread = 0
                            end
                        end
                    end
                end
                createloop(0, loop)
            end
            no_spread()
            local function quickfire()
                local shootGun = global.registry.shootGun
                global.inputs = {
                    mouse1 = false; 
                }
                local function _fn()
                    if global.ui_status.quickfire and global._loaded then
                        local loop
                        local lastTimeShot = tick()
                        loop = createloop(0, function()
                            if not global.ui_status.quickfire then
                                loop:disconnect()
                                loop = nil
                                return false
                            end
                            local gun = client.reg.getEquippedItem
                            if not gun then
                                loop:disconnect()
                                loop = nil
                                return false
                            end
                            if not gun or gun and not gun.CheckNextShotPossible then return false end
                            if gun.CheckNextShotPossible and not gun:CheckNextShotPossible() then return false end
                            if gun.__ClassName == "Sniper" or gun.__ClassName == "Flintlock" then
                                if tick() - lastTimeShot < 0.4 then return false end
                                lastTimeShot = tick()
                            end
                            if global.inputs.mouse1 then shootGun() end
                        end)
                    end
                end
                local tagCache
                local function tagService()
                    tagCache = client.tags.new("quickfire", 0, false, function(val)
                        if val then _fn() end
                    end)
                end
                tagService()
                table.insert(client.onGetEq, {
                    _fn = _fn;
                })
                local function loop()
                    local bool = global.ui_status.quickfire
                    if tagCache then tagCache.obj.Value = bool end
                end
                createloop(0, loop)
            end
            quickfire()
        end
        gunCorrection()
        local function npcCorrection()
            local function isAirdrop()
                local module = client.modules.guardNPCshared.canSeeTarget
                local function hook(x, y)
                    local bool = global.ui_status.break_npcs
                    if bool or global.ui_status.break_mansion_npcs then return false end
                    return module(x, y)
                end
                client.modules.guardNPCshared.canSeeTarget = hook
            end
            isAirdrop()
        end
        npcCorrection()
        local function airdropCorrection()
            local actionButtonService = client.modules.actionButtonService
            -- the airdrop hold-E button only exists in active while you're near a drop,
            -- so find it lazily each time instead of once at init (that was the bug)
            local function findHoldEAction()
                for i, v in next, actionButtonService.active do
                    if type(v) == "table" and v.image == "rbxassetid://10770151584" then return v end
                end
                return nil
            end
            local function isNearAirdrop()
                local char = client.playerCharacter
                if not char then return false end
                local root = char.PrimaryPart
                if not root then return false end
                local airdrops_on_map = global.airdrops_on_map
                if not airdrops_on_map or #airdrops_on_map == 0 then return false end
                for i,v in next, airdrops_on_map do
                    if (root.Position - v.Position).magnitude < 10 then return true end
                end
                return false
            end
            local isPlayerNearAirdrop
            local cache
            local function loop()
                if not isPlayerNearAirdrop.obj.Value then
                    cache:disconnect()
                    cache = nil
                    return false
                end
                local holdEAction = findHoldEAction()
                if holdEAction and not holdEAction._pressed then holdEAction._pressState() end
            end
            local function tagService()
                isPlayerNearAirdrop = client.tags.new("isPlayerNearAirdrop", 0, false, function(val)
                    if val then
                        cache = createloop(0, loop)
                    else
                        local holdEAction = findHoldEAction()
                        if holdEAction then holdEAction._pressed = false end
                        if cache then
                            cache:disconnect()
                            cache = nil
                        end
                    end
                end)
            end
            tagService()
            local function loop()
                local bool = global.ui_status.automatic_hold
                if isPlayerNearAirdrop then
                    if bool then
                        isPlayerNearAirdrop.obj.Value = isNearAirdrop()
                    else
                        isPlayerNearAirdrop.obj.Value = false
                    end
                end
            end
            createloop(0, loop)
        end
        airdropCorrection()
        local function museumCorrection()
            local function puzzleCorrection()
                local museum = workspace:FindFirstChild("Museum")
                local function loop()
                    if not museum then
                        museum = workspace:FindFirstChild("Museum")
                        if not museum then return false end
                    end
                    local puzzle1 = museum.Puzzle1:GetDescendants()
                    local puzzle2 = museum.Puzzle2:GetDescendants()
                    for i,v in next, puzzle1 do
                        if v:FindFirstChild("ClickDetector") then
                            for i=1, math.random(1, 5) do
                                task.wait()
                                fireclickdetector(v.ClickDetector)
                            end
                        end
                    end
                    for i,v in next, puzzle2 do
                        if v:FindFirstChild("ClickDetector") then
                            for i=1, math.random(1, 5) do
                                task.wait()
                                fireclickdetector(v.ClickDetector)
                            end
                        end
                    end
                end
                local loopf
                local cache
                local function tagService()
                    cache = client.tags.new("puzzle", 0, false, function(val)
                        if val then
                            loopf = createloop(1, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "break_museum_puzzle")
            end
            puzzleCorrection()
            local function mouseClickCorrection()
                local mouse = global.LocalMouse
                local function onPressedMouse()
                    if global.ui_status.clicklightning then
                        local lightningSystem = client.modules.lightningSystem
                        lightningSystem.StrikePosition(mouse.Hit.p + Vector3.new(0, 100, 0), mouse.Hit.p)
                    end
                    if global.ui_status.clicknuke then
                        local settings = {
                            Nuke = {
                                Speed = global.ui_status.nuke_speed or 650;
                                Duration = global.ui_status.nuke_duration or 10;
                                TimeDilation = global.ui_status.nuke_timedilation or 1.5;
                            };
                            Shockwave = {
                                MaxRadius = global.ui_status.nuke_shockwave_maxradius or 10000;
                                Duration = global.ui_status.nuke_shockwave_duration or 10;
                            };
                        }
                        local nukecontrol = global.registry.nukecontrol
                        settings.Nuke.Target = mouse.Hit.p
                        settings.Nuke.Origin = mouse.Hit.p
                        nukecontrol(settings)
                    end
                end
                mouse.Button1Down:connect(onPressedMouse)
            end
            mouseClickCorrection()
            local function museumResolverCorrection()
                local function puzzle1()
                    local museum = workspace:FindFirstChild("Museum")
                    if not museum then return false end
                    if museum.Puzzle2Door.Closed.CanCollide then return false end
                    local spinners = museum.Puzzle1.Spinners
                    local connections = museum.Puzzle1.Connections
                    for i,v in next, spinners:GetChildren() do
                        local name = connections:FindFirstChild(v.Name)
                        if name and name.Color == Color3.fromRGB(89, 144, 255) then fireclickdetector(v.ClickDetector) end
                    end
                end
                -- target orientation each numbered piece must reach
                local puzzle2Targets = {
                    [2] = Vector3.new(0, -38, 0),
                    [3] = Vector3.new(0, -38, 0),
                    [10] = Vector3.new(0, -38, 180),
                    [11] = Vector3.new(0, -38, 180),
                    [12] = Vector3.new(0, -38, 0),
                    [19] = Vector3.new(0, -38, 180),
                    [20] = Vector3.new(0, -38, -90),
                    [13] = Vector3.new(0, -38, 90),
                    [14] = Vector3.new(0, -38, 0),
                }
                local function puzzle2()
                    local museum = workspace:FindFirstChild("Museum")
                    if not museum then return false end
                    local door = museum:FindFirstChild("Puzzle1Door")
                    local closed = door and door:FindFirstChild("Closed")
                    if closed and closed.CanCollide then return false end
                    local puzzle = museum:FindFirstChild("Puzzle2")
                    local pieces = puzzle and puzzle:FindFirstChild("Pieces")
                    if not pieces then return false end
                    -- single non-blocking pass: nudge each misaligned piece once; the
                    -- outer createloop repeats so pieces rotate toward their target
                    for num, target in next, puzzle2Targets do
                        local piece = pieces:FindFirstChild(tostring(num))
                        if piece and piece.Orientation ~= target then fireclickdetector(piece.ClickDetector) end
                    end
                end
                local loopf
                local cache
                local function loop()
                    local break_museum_puzzle = global.ui_status.break_museum_puzzle
                    if break_museum_puzzle then return false end
                    local isInMuseum = global.registry.isInMuseum()
                    if isInMuseum then
                        -- pcall so an error in one pass can't kill the repeating loop
                        pcall(puzzle1)
                        pcall(puzzle2)
                    end
                end
                local function tagService()
                    cache = client.tags.new("museumPuzzle", 0, false, function(val)
                        if val then
                            loopf = createloop(0.3, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "automatic_resolve_museum_puzzle")
            end
            museumResolverCorrection()
            local function dynamiteCorrection()
                local dynamite = collectionservice:GetTagged("Museum_DynamiteNode")
                local function isDetonatorDown()
                    local museum = workspace.Museum
                    if museum.Roof.Hole.RoofPart.Transparency == 1 then return false end
                    for i,v in next, museum.Roof:GetDescendants() do
                        if v.Name == "Arm" then
                            if v.Transparency == 1 then
                                if v.Parent.Name == "Detonator0" then
                                    for i2,v2 in next, client.modules.ui.CircleAction.Specs do
                                        if v2.Name == "Place Dynamite" and v2.Part:IsDescendantOf(workspace.Museum) then v2:Callback(true) end
                                    end
                                end
                                if v.Parent.Name == "Detonator1" then
                                    for i2,v2 in next, client.modules.ui.CircleAction.Specs do
                                        if v2.Name == "Place Dynamite" and v2.Part:IsDescendantOf(workspace.Museum) then v2:Callback(true) end
                                    end
                                end
                            end
                        end
                    end
                end
                local getRobberyStatus = global.registry.getRobberyStatus
                local function getMuseumStatus()
                    local getMuseumStatus = getRobberyStatus("MUSEUM")
                    if getMuseumStatus then
                        return true
                    elseif getMuseumStatus == 0 then
                        return 0
                    elseif not getMuseumStatus then return false end
                    return false
                end
                local function loop()
                    if tostring(player.Team) ~= "Criminal" then return false end
                    if getMuseumStatus() == true then isDetonatorDown() end
                end
                local loopf
                local cache
                local function tagService()
                    cache = client.tags.new("placeDynamite", 0, false, function(val)
                        if val then
                            loopf = createloop(1, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "automatic_place_dynamite")
            end
            dynamiteCorrection()
        end
        museumCorrection()
        local function robberyMarkerDelayCorrection()
            local doesPlayerOwn = client.modules.gamepassSystem.DoesPlayerOwn
            local function hook(num)
                if num == 5 then
                    local bool = global.ui_status.no_robberymarker_delay
                    if not bool then return doesPlayerOwn(num) end
                    return true
                end
                return doesPlayerOwn(num)
            end
            client.modules.gamepassSystem.DoesPlayerOwn = hook
        end
        robberyMarkerDelayCorrection()
        local function gamepassExploits()
            local gamepassSystem = client.modules.gamepassSystem
            if not gamepassSystem then return false end
            local okUtils, gamepassUtils = pcall(function()
                return require(repl.Gamepass.GamepassUtils)
            end)
            local enum = okUtils and type(gamepassUtils) == "table" and gamepassUtils.EnumGamepass
            local enumSwat = enum and enum.SWAT
            local enumGarage = enum and enum.PremiumGarage

            -- Pro garage: GarageUtils gates premium tuning on DoesPlayerOwn(PremiumGarage)
            if enumGarage ~= nil and not gamepassSystem.CrewbattlerProGarageHooked then
                gamepassSystem.CrewbattlerProGarageHooked = true
                local originalDoesOwn = gamepassSystem.DoesPlayerOwn
                gamepassSystem.DoesPlayerOwn = function(num, ...)
                    if num == enumGarage and global.ui_status.pro_garage then return true end
                    return originalDoesOwn(num, ...)
                end
            end

            -- SWAT pistol: Pistol setup checks doesPlayerOwnCached(player, SWAT) -> PistolSWAT
            -- Pro garage: some garage paths check doesPlayerOwnCached(player, PremiumGarage)
            if type(gamepassSystem.doesPlayerOwnCached) == "function" and not gamepassSystem.CrewbattlerCachedHooked then
                gamepassSystem.CrewbattlerCachedHooked = true
                local originalCached = gamepassSystem.doesPlayerOwnCached
                gamepassSystem.doesPlayerOwnCached = function(plr, pass, ...)
                    if plr == player then
                        if enumSwat ~= nil and pass == enumSwat and global.ui_status.swat_pistol then return true end
                        if enumGarage ~= nil and pass == enumGarage and global.ui_status.pro_garage then return true end
                    end
                    return originalCached(plr, pass, ...)
                end
            end

            -- The app caches its premium-garage flag at startup and only refreshes it
            -- on the gamepass-owned signal, so nudge that signal so spawn perks re-check.
            if enumGarage ~= nil and type(gamepassSystem.GetGamepassOwnedSignal) == "function" then
                task.spawn(function()
                    local lastState = nil
                    while true do
                        local state = global.ui_status.pro_garage == true
                        if state ~= lastState then
                            lastState = state
                            pcall(function()
                                local signal = gamepassSystem.GetGamepassOwnedSignal(enumGarage)
                                if signal and type(signal.Fire) == "function" then
                                    signal:Fire()
                                end
                            end)
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
        gamepassExploits()
        local function c4Exploits()
            local c4s = {}
            local function onAddedWorkspace(obj)
                if obj.Name == "C4" then
                    if obj:FindFirstChild("CreatorId") then
                        local creator = tonumber(obj.CreatorId.Value)
                        if creator == player.UserId then table.insert(c4s, obj) end
                    end
                end
            end
            table.insert(client.onWorkspaceSpawnRun, {
                _fn = onAddedWorkspace
            })
            local function onRemovedWorkspace(obj)
                if obj.Name == "C4" then
                    for i,v in next, c4s do
                        if v == obj then table.remove(c4s, i) end
                    end
                end
            end
            table.insert(client.onWorkspaceRemovedRun, {
                _fn = onRemovedWorkspace
            })
            local function getC4s() return c4s end
            local function setC4Pos(target, idx, c4)
                -- "Dick Length" controls the spacing per C4 so the slider visibly
                -- lengthens/shortens the stack (default 2 studs, as before)
                local spacing = 2
                if global.ui_status.override_length then spacing = tonumber(global.ui_status.dick_length) or 2 end
                if c4 and c4:FindFirstChild("StickRemote") then
                    local lowerTorso = target.Character:FindFirstChild("LowerTorso")
                    if lowerTorso then c4.StickRemote:FireServer(lowerTorso, CFrame.new(0, -spacing * idx, 0) * CFrame.Angles(math.rad(80), 0, 0)) end
                end
            end
            local hasItemEquipped = global.registry.hasItemEquipped
            local function isHoldingC4()
                if hasItemEquipped("C4") then return true end
                return false
            end
            local function hasC4InInventory() return table.find(client.reg.resolveEquippedItems, "C4") end
            local function equipC4()
                local equip = global.registry.equip
                if equip then equip("C4") end
            end
            local function ownsC4() return table.find(client.reg.resolveOwnedItems, "C4") end
            local findTarget = global.registry.findTarget
            local function getC4AmmoCurrent()
                local c4 = player.Folder:FindFirstChild("C4")
                if c4 then return c4:GetAttribute("AmmoCurrent") end
                return "_n"
            end
            local equipOwnedItem = global.registry.equipOwnedItem
            local unequipAll = global.registry.unequipAll
            local getPlayerVehicle = global.registry.getPlayerVehicle
            local function explodeTruck()
                local isInProcess = false
                local function throw_c4_on_truck(truck)
                    if not ownsC4() then
                        return global.notify("You do not own C4.", 5)
                    end
                    if client.reg.getLocalVehicle then return global.notify("Get out of the vehicle.", 5) end
                    if isInProcess then return global.notify("Already in process.", 3) end
                    isInProcess = true
                    local hasC4 = hasC4InInventory()
                    if not hasC4 then
                        local c4
                        while true do
                            c4 = hasC4InInventory()
                            if c4 then break end
                            equipOwnedItem("C4")
                            task.wait(0.4)
                        end
                        hasC4 = c4
                    end
                    local ammoCurrent = getC4AmmoCurrent()
                    if ammoCurrent == "_n" then
                        isInProcess = false
                        return global.notify("Failed throwing c4 on truck!", 5)
                    else
                        if ammoCurrent < 1 then
                            local ammo
                            while true do
                                ammo = getC4AmmoCurrent()
                                if ammo >= 1 then break end
                                equipOwnedItem("C4Ammo")
                                task.wait(0.4)
                            end
                            ammoCurrent = ammo
                        end
                    end
                    if hasC4 then
                        if not isHoldingC4() then
                            equipC4()
                            task.wait(0.2)
                        end
                        if truck then
                            local backDoorRight = truck:FindFirstChild("BackDoorRight")
                            if backDoorRight and not truck:FindFirstChild("LockMovement") then
                                local decal = backDoorRight.Decal
                                if decal then
                                    local c4s = getC4s()
                                    while #c4s == 0 do
                                        c4s = getC4s()
                                        task.wait()
                                    end
                                    local c4 = c4s[1] or c4s[#c4s]
                                    if c4 and c4:FindFirstChild("StickRemote") and not c4.Stuck.Value then
                                        c4.PrimaryPart.CFrame = decal.CFrame
                                        c4.StickRemote:FireServer(decal, c4.PrimaryPart.CFrame:ToObjectSpace(decal.CFrame))
                                        local stuck_at, detonated = tick(), false
                                        while true do
                                            if detonated then break end
                                            if tick() - stuck_at > 3 then
                                                detonated = false
                                                break
                                            end
                                            if c4:FindFirstChild("DetonateRemote") then
                                                if tick() - stuck_at > 0.4 then
                                                    detonated = true
                                                    break
                                                end
                                            end
                                            task.wait()
                                        end
                                        if detonated then 
                                            c4.DetonateRemote:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end
                    unequipAll()
                    isInProcess = false
                end
                global.registry.throw_c4_on_truck = throw_c4_on_truck
                local tagCache
                local loopf
                local function getRobberyStatus(key)
                    key = key:upper()
                    local getRobberyStatus = global.registry.getRobberyStatus
                    local status = getRobberyStatus(key)
                    if status == "OPENED" then return true end
                    if status == "STARTED" then return 0 end
                    return false
                end
                local loopInProcess = false
                local function loop()
                    if tostring(player.Team) == "Police" then return false end
                    if loopInProcess then return false end
                    if isInProcess then return false end
                    if not ownsC4() then return false end
                    if not getRobberyStatus("money_truck") then return false end
                    loopInProcess = true
                    local char = client.playerCharacter
                    if char then
                        local root = char.PrimaryPart
                        if root then
                            local bankTruck = client.descendants.vehicles:FindFirstChild("BankTruck")
                            if bankTruck then
                                if not bankTruck:FindFirstChild("BackDoorLeft") or not bankTruck:FindFirstChild("BackDoorRight") then
                                    loopInProcess = false
                                    return false
                                end
                                if bankTruck:FindFirstChild("LockMovement") then
                                    loopInProcess = false
                                    return false
                                end
                                local primaryPart = bankTruck.PrimaryPart
                                if primaryPart then
                                    if (root.Position - primaryPart.Position).magnitude < 80 then throw_c4_on_truck(bankTruck) end
                                end
                            end
                        end
                    end
                    loopInProcess = false
                end
                local function tagService()
                    tagCache = client.tags.new("automatic_explode_truck", 0, false, function(val)
                        if val then
                            loopf = createloop(0.5, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                local function loop()
                    local bool = global.ui_status.automatic_explode_truck
                    if tagCache then tagCache.obj.Value = bool end
                end
                createloop(0, loop)
            end
            explodeTruck()
            local function bombVest()
                local isInProcess = false
                local function spawn_vest(name)
                    if not ownsC4() then
                        return global.notify("You do not own C4.", 5)
                    end
                    if client.reg.getLocalVehicle then return global.notify("Get out of the vehicle.", 5) end
                    if isInProcess then return global.notify("Bomb vest spawning is already in process. Wait!", 5) end
                    isInProcess = true
                    local hasC4 = hasC4InInventory()
                    if not hasC4 then
                        local c4
                        while true do
                            c4 = hasC4InInventory()
                            if c4 then break end
                            equipOwnedItem("C4")
                            task.wait(0.2)
                        end
                        hasC4 = c4
                    end
                end
            end
            bombVest()
            local function kill()
                local isInProcess, kill_started_at = false, tick()
                local function kill_player(name)
                    if not ownsC4() then
                        return global.notify("You do not own C4.", 5)
                    end
                    if client.reg.getLocalVehicle then return global.notify("Get out of the vehicle.", 5) end
                    if isInProcess then
                        if tick() - kill_started_at > 10 then isInProcess = false end
                        return global.notify("Killing already in process. Wait!", 5)
                    end
                    isInProcess = true
                    kill_started_at = tick()
                    local hasC4 = hasC4InInventory()
                    if not hasC4 then
                        local c4
                        while true do
                            c4 = hasC4InInventory()
                            if c4 then break end
                            equipOwnedItem("C4")
                            task.wait(0.2)
                        end
                        hasC4 = c4
                    end
                    if hasC4 then
                        local target = findTarget(name)
                        if target then
                            if target.Name == player.Name then
                                isInProcess = false
                                return global.notify("hey, don't kill yourself. :)", 5)
                            end
                            local char = target.Character
                            if not char then
                                isInProcess = false
                                return global.notify("Target has no character.", 5)
                            end
                            local torso = char:FindFirstChild("LowerTorso")
                            if not torso then
                                isInProcess = false
                                return global.notify("Target has no torso. Get closer to the target!", 5)
                            end
                            local limit = 0
                            local function spawnAndStickC4()
                                if limit > 5 then
                                    isInProcess = false
                                    unequipAll()
                                    return false
                                end
                                local c4s = getC4s()
                                while #c4s == 0 do
                                    task.wait()
                                    c4s = getC4s()
                                end
                                for i, obj in next, c4s do
                                    if obj and obj:FindFirstChild("StickRemote") and not obj.Stuck.Value then
                                        local rate = i == 1 and 0.2 or 3.2 * i
                                        obj.PrimaryPart.CFrame = torso.CFrame * CFrame.new(rate, -1.5 * rate, rate)
                                        obj.StickRemote:FireServer(torso, obj.PrimaryPart.CFrame:ToObjectSpace(torso.CFrame))
                                    end
                                end
                                task.delay(0.1, function()
                                    unequipAll()
                                    limit += 1
                                    if limit < 3 then
                                        task.delay(0.1, function()
                                            equipC4()
                                            task.delay(0.2, function()
                                                spawnAndStickC4()
                                            end)
                                        end)
                                    else
                                        global.notify("Great! Do not detonate the C4's if you want to kill them. Might take some time!", 5)
                                        local loop
                                        loop = createloop(0, function()
                                            if not target.Character then
                                                loop:disconnect()
                                                loop = nil
                                                for i, obj in next, c4s do
                                                    if obj and obj:FindFirstChild("DetonateRemote")  then obj.DetonateRemote:FireServer() end
                                                end
                                            end
                                            if target.Character and target.Character.Humanoid and target.Character.Humanoid.Health < 1 then
                                                loop:disconnect()
                                                loop = nil
                                                for i, obj in next, c4s do
                                                    if obj and obj:FindFirstChild("DetonateRemote") then obj.DetonateRemote:FireServer() end
                                                end
                                            end
                                        end)
                                    end
                                end)
                            end
                            if isHoldingC4() then
                                spawnAndStickC4()
                            else
                                equipC4()
                                task.wait(0.2)
                                spawnAndStickC4()
                            end
                        else
                            global.notify(("Couldn't find player with name `%s`"):format(name), 10)
                        end
                    end
                    isInProcess = false
                end
                global.registry.kill_player = kill_player
            end
            kill()
            local function dick()
                local function dick_player(name)
                    if not ownsC4() then
                        return global.notify("You do not own C4.", 5)
                    end
                    --creds to Nexus42 and Snipehype200
                    if global.ui_status.c4dick_masterswitch then
                        local hasC4 = hasC4InInventory()
                        if not hasC4 then
                            local c4
                            while true do
                                c4 = hasC4InInventory()
                                if c4 then break end
                                warn("Waiting to equipOwnItem C4 X2")
                                equipOwnedItem("C4")
                                task.wait(0.2)
                            end
                            hasC4 = c4
                        end
                        if hasC4 then
                            if name == player.Name then
                                local target = player
                                if isHoldingC4() then
                                    unequipAll()
                                    task.wait(0.4)
                                    equipC4()
                                    task.wait(0.4)
                                else
                                    equipC4()
                                    task.wait(0.4)
                                end
                                local c4s = getC4s()
                                while #c4s == 0 do
                                    task.wait()
                                    c4s = getC4s()
                                end
                                for i,v in next, c4s do
                                    setC4Pos(target, i, v)
                                    v.PrimaryPart.Anchored = false
                                    task.wait()
                                end
                                table.clear(c4s)
                            else
                                local target = findTarget(name)
                                if target then
                                    if isHoldingC4() then
                                        unequipAll()
                                        task.wait(0.4)
                                        equipC4()
                                        task.wait(0.4)
                                    else
                                        equipC4()
                                        task.wait(0.4)
                                    end
                                    local c4s = getC4s()
                                    while #c4s == 0 do
                                        task.wait()
                                        c4s = getC4s()
                                    end
                                    for i,v in next, c4s do
                                        setC4Pos(target, i, v)
                                        v.PrimaryPart.Anchored = false
                                        task.wait()
                                    end
                                    table.clear(c4s)
                                else
                                    global.notify(("Couldn't find player with name `%s`"):format(name), 10)
                                end
                            end
                            task.wait(1)
                            global.registry.unequipAll()
                        end
                    end
                end
                global.registry.dick_player = dick_player
            end
            dick()
        end
        c4Exploits()
        local function rocketLauncherExploits()
            local hasItemEquipped = global.registry.hasItemEquipped
            local unequipAll = global.registry.unequipAll
            local equip = global.registry.equip
            local equipOwnedItem = global.registry.equipOwnedItem
            local sh = client.modules.seekingMissileShared
            local run = sh._run
            local explode = sh._explode
            local netObjPool = client.modules.netObjPool._constructor
            local get = netObjPool.Get
            local cf = CFrame.new()
            local function ownsItem() return table.find(client.reg.resolveOwnedItems, "RocketLauncher") end
            local function isInInventory() return table.find(client.reg.resolveEquippedItems, "RocketLauncher") end
            local function isEquipped() return hasItemEquipped("RocketLauncher") end
            local function getMissileHolderPool()
                local rL = player.Folder:FindFirstChild("RocketLauncher")
                if rL then
                    local poolHolder = rL:FindFirstChild("RocketLauncherHolderMissilePool")
                    if poolHolder then return poolHolder end
                end
                return false
            end
            local findTarget = global.registry.findTarget
            local function hasRocketAmmo()
                local getEquippedItem = client.reg.getEquippedItem
                return getEquippedItem and getEquippedItem.__ClassName == "RocketLauncher" and getEquippedItem.inventoryItemValue:GetAttribute("AmmoCurrentLocal") or 0
            end
            local function canPurchaseAmmo() return player.leaderstats.Money.Value >= 1000 end
            local function getObjInPool()
                local holder = getMissileHolderPool()
                local obj
                local noPoolError = pcall(function()
                    obj = get({obj = holder}) or nil
                end)
                if not noPoolError then obj = nil end
                return obj
            end
            local function launchRocket()
                local getEquippedItem = client.reg.getEquippedItem
                if getEquippedItem and getEquippedItem.__ClassName == "RocketLauncher" then
                    local currentAmmo = getEquippedItem.inventoryItemValue:GetAttribute("AmmoCurrentLocal")
                    getEquippedItem:LaunchRocket(cf, cf.LookVector, 0)
                    task.delay(0.1, function()
                        getEquippedItem.inventoryItemValue:SetAttribute("AmmoCurrentLocal", currentAmmo - 1)
                    end)
                end
            end
            local is_spawning = false
            local target
            local function spawnRocket(_target, shouldInstantExplode)
                assert(_target, "Target is missing")
                if is_spawning then
                    global.notify("Killing is already in process", 3)
                    return false
                end
                if not ownsItem() then return global.notify("You have to own a Rocket Launcher to spawn a rocket", 5) end
                is_spawning = true
                if not isInInventory() then
                    while true do
                        if isInInventory() then break end
                        equipOwnedItem("RocketLauncher")
                        task.wait()
                    end
                end
                local objects
                if not isEquipped() then
                    while true do
                        if client.reg.getEquippedItem and client.reg.getEquippedItem.__ClassName == "RocketLauncher" then break end
                        equip("RocketLauncher")
                        task.wait()
                    end
                end
                local tic, reset = tick(), false
                while true do
                    if objects then
                        task.wait()
                        break
                    end
                    objects = getObjInPool()
                    if tick() - tic > 0.2 and not objects then
                        reset = true
                        break
                    end
                    task.wait()
                end
                if reset then
                    unequipAll()
                    while true do
                        if not client.reg.getEquippedItem then break end
                        task.wait()
                    end
                    is_spawning = false
                    spawnRocket(_target, shouldInstantExplode or false)
                    return false
                end
                local getObjInPool = objects
                if not getObjInPool or getObjInPool and not getObjInPool.obj then
                    unequipAll()
                    while true do
                        if not client.reg.getEquippedItem then break end
                        task.wait()
                    end
                    task.wait()
                    while true do
                        if client.reg.getEquippedItem then break end
                        equip("RocketLauncher")
                        task.wait()
                    end
                    task.wait()
                end
                if getObjInPool then
                    local getEquippedItem = client.reg.getEquippedItem
                    target = _target
                    local ammo
                    if shouldInstantExplode then
                        local bool = Instance.new("BoolValue")
                        bool.Name = "ShouldInstantExplode"
                        bool.Parent = getObjInPool.obj
                    else
                        ammo = hasRocketAmmo()
                        if ammo == 0 then
                            if not canPurchaseAmmo() then
                                global.notify("You need at least $1,000 to spawn a rocket.", 5)
                                is_spawning = false
                                return false
                            end
                            equipOwnedItem("RocketAmmo")
                            while true do
                                if ammo > 0 then break end
                                ammo = hasRocketAmmo()
                                task.wait()
                            end
                        end
                        local bool = Instance.new("BoolValue")
                        bool.Name = "ShouldTrail"
                        bool.Parent = getObjInPool.obj
                    end
                    pcall(launchRocket)
                    -- launching makes the camera ride the missile; keep it on us
                    task.spawn(function()
                        local camera = workspace.CurrentCamera
                        local char = player.Character
                        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                        if not camera or not humanoid then return end
                        local deadline = tick() + 3
                        while tick() < deadline do
                            if camera.CameraSubject ~= humanoid or camera.CameraType ~= Enum.CameraType.Custom then
                                pcall(function()
                                    camera.CameraSubject = humanoid
                                    camera.CameraType = Enum.CameraType.Custom
                                end)
                            end
                            runservice.RenderStepped:Wait()
                        end
                    end)
                    is_spawning = false
                else
                    is_spawning = false
                end
            end
            local function spawn_rocket(name, spawnExplosion)
                if not spawnExplosion then
                    if not ownsItem() then return global.notify("You have to own a Rocket Launcher to spawn a rocket", 5) end
                    if hasRocketAmmo() == 0 then
                        if not canPurchaseAmmo() then
                            global.notify("You need at least $1,000 to spawn a rocket.", 5)
                            return false
                        end
                    end
                end
                local target
                local isSelf = false
                if player.Name == name then
                    target = player
                    isSelf = true
                else
                    target = findTarget(name)
                end
                if target then
                    local char = target.Character
                    if char then
                        local primaryPart = char.PrimaryPart
                        local explosion_size = global.ui_status.explosion_size or 1
                        if spawnExplosion then
                            for i=1, explosion_size do spawnRocket(primaryPart, true) end
                        else
                            if not isSelf then
                                local cr = player.Character
                                if cr then
                                    local pp = cr.PrimaryPart
                                    if pp then
                                        if (pp.Position - primaryPart.Position).magnitude > 500 then --@scoate asta mai incolo, nu prea are sens.
                                            return global.notify("Target is too far away! Cannot render Missile", 10)
                                        end
                                    end
                                end
                            end
                            spawnRocket(primaryPart)
                        end
                    else
                        global.notify("Couldn't find target's character.", 10)
                    end
                else
                    global.notify(("Couldn't find player with name `%s`"):format(name), 10)
                end
            end
            global.registry.spawn_rocket = spawn_rocket
            local function explode_hook(missile)
                if missile.obj:FindFirstChild("ShouldInstantExplode") then
                    missile.obj.CFrame = target.CFrame + Vector3.new(math.random(0, 10), 0, math.random(0, 10))
                    return explode(missile)
                end
                if missile.obj:FindFirstChild("ShouldTrail") then return false end
                return explode(missile)
            end
            local function run_hook(missile)
                if missile.obj:FindFirstChild("ShouldInstantExplode") then
                    missile.obj.CFrame = target.CFrame + Vector3.new(math.random(0, 10), 0, math.random(0, 10))
                    return explode(missile)
                end
                if missile.obj:FindFirstChild("ShouldTrail") and global.ui_status.rocket_trail then
                    local run_at = tick()
                    local _loop
                    local is_new_connected = false
                    local target = target
                    _loop = createloop(0, function()
                        if is_new_connected then
                            _loop:disconnect()
                            _loop = nil
                            return false
                        end
                        if tick() - run_at > 1.2 then
                            _loop:disconnect()
                            _loop = nil
                            return false
                        end
                        local _tasks = missile.runMaid._tasks
                        _tasks[1] = runservice.Heartbeat:connect(function()
                            if not is_new_connected then is_new_connected = true end
                            if _loop then
                                _loop:disconnect()
                                _loop = nil
                                return false
                            end
                            missile.obj.CFrame = target.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(math.rad(180), 0, 0)
                        end)
                    end)
                end
                return run(missile)
            end
            sh._run = run_hook
            sh._explode = explode_hook
        end
        rocketLauncherExploits()
        local function placeDynamite()
            local function place_dynamite()
                for i,v in next, client.modules.ui.CircleAction.Specs do
                    if v.Name == "Place Dynamite" and v.Part.Name == "BankDoor" then
                        if v.Enabled then v:Callback(true) end
                    end
                end
            end
            local function loop()
                local getClosestBankDoor = global.registry.getClosestBankDoor
                if getClosestBankDoor(300) then place_dynamite() end
            end
            local loopf
            local cache
            local function tagService()
                cache = client.tags.new("placeBankDynamite", 0, false, function(val)
                    if val then
                        loopf = createloop(3, loop)
                    else
                        if loopf then
                            loopf:disconnect()
                            loopf = nil
                        end
                    end
                end)
            end
            tagService()
            global.syncTagValue(cache, "auto_place_dynamite")
        end
        placeDynamite()
        local function touchClosestVault()
            --@aici se fute performanta, sa dai recode candva (9.12.2022)
            local function touchVault(part)
                local char = client.playerCharacter
                if not char then return false end
                local PrimaryPart = char.PrimaryPart
                if not PrimaryPart then return false end
                if char and PrimaryPart then
                    firetouchinterest(PrimaryPart, part, 0)
                    task.wait(0.5)
                    firetouchinterest(PrimaryPart, part, 1)
                end
            end
            local door
            local function loop()
                local getClosestTriggerDoor = global.registry.getClosestTriggerDoor(400)
                if not getClosestTriggerDoor then
                    door = nil
                    return false
                end
                if door ~= getClosestTriggerDoor then door = getClosestTriggerDoor end
                if not door then return false end
                touchVault(door)
            end
            local loopf
            local cache
            local function tagService()
                cache = client.tags.new("touchVault", 0, false, function(val)
                    if val then
                        loopf = createloop(2, loop)
                    else
                        if loopf then
                            loopf:disconnect()
                            loopf = nil
                            door = nil
                        end
                    end
                end)
            end
            tagService()
            global.syncTagValue(cache, "auto_touch_vault")
        end
        touchClosestVault()
        local function resolvePuzzle()
            local flow = client.modules.puzzleFlow and getupvalue(client.modules.puzzleFlow.Init, 3)
            if type(flow) ~= "table" then return end -- powerplant flow moved in update
            local resolvePowerplant = global.registry.resolvePowerplant
            local cache
            local upv
            local function tagService()
                cache = client.tags.new("puzzle_resolver", 0, false, function(val)
                    if flow.IsOpen and val then resolvePowerplant(flow) end
                end)
                upv = client.tags.new("flow_IsOpen", 0, false, function(val)
                    if cache.obj.Value and val then resolvePowerplant(flow) end
                end)
            end
            tagService()
            local function loop()
                local isOpen = flow.IsOpen
                if upv then upv.obj.Value = isOpen end
                local bool = global.ui_status.puzzle_resolver
                if cache then cache.obj.Value = bool end
            end
            createloop(0, loop)
        end
        resolvePuzzle()
        local function museumFillBag()
            local cashLeftBeforeMax = global.registry.cashLeftBeforeMax
            local function grab(player)
                local char = client.playerCharacter
                if not char then return false end
                local primarypart = char.PrimaryPart
                if not primarypart then return false end
                for i,v in next, client.modules.ui.CircleAction.Specs do
                    if string.find(v.Name, "Grab") then
                        if v.Part:IsDescendantOf(workspace.Museum) and (v.Part.Position - primarypart.Position).magnitude < 10 then v:Callback(true) end
                    end
                end
            end
            local function loop()
                if tostring(player.Team) == "Police" then return false end
                local isInMuseum = global.registry.isInMuseum()
                if isInMuseum then
                    grab(player)
                    return true
                end
                return false
            end
            local cache
            local loopf
            local function tagService()
                cache = client.tags.new("fillbag", 0, false, function(val)
                    if val then
                        loopf = createloop(1, loop)
                    else
                        if loopf then
                            loopf:disconnect()
                            loopf = nil
                        end
                    end
                end)
            end
            tagService()
            global.syncTagValue(cache, "auto_fill_bag")
        end
        museumFillBag()
        local function hackClosestComputer()
            local function hackComputer()
                for i,v in next, client.modules.ui.CircleAction.Specs do
                    if v.Name == "Hack" or v.Name == "Disable Vault Security" then v:Callback(true) end
                end
            end
            local function loop()
                local bool = global.ui_status.hack_nearby_computers
                if bool then
                    local getClosestComputer = global.registry.getClosestComputer
                    if getClosestComputer(20) then hackComputer() end
                end
            end
            createloop(0.5, loop)
        end
        hackClosestComputer()
        local function cargoPlaneCorrection()
            local function autoCollectPlaneCrate()
                local function collectCrate(crate)
                    for i,v in next, client.modules.ui.CircleAction.Specs do
                        if v.Name == "Inspect Crate" and v.Part == crate then v:Callback(true) end
                    end
                end
                local function loop()
                    local bool = global.ui_status.automatic_inspect_crate
                    if bool then
                        local getClosestCrate = global.registry.getClosestCrate()
                        if getClosestCrate then collectCrate(getClosestCrate) end
                    end
                end
                createloop(1, loop)
            end
            autoCollectPlaneCrate()
            local function automaticOpenPlaneDoor()
                local function openDoor()
                    for i,v in next, client.modules.ui.CircleAction.Specs do
                        if v.Name == "Open Door" then
                            if v.Part.Name == "Lever" then
                                v:Callback(true)
                                break
                            end
                        end
                    end
                end
                local function doorLogic()
                    local getEquippedItem = client.reg.getEquippedItem
                    if getEquippedItem then
                        if getEquippedItem.__ClassName == "Crate" then openDoor() end
                    end
                end
                local function loop()
                    local bool = global.ui_status.automatic_open_cargoplane_door
                    if bool then doorLogic() end
                end
                createloop(1, loop)
            end
            automaticOpenPlaneDoor()
        end
        cargoPlaneCorrection()
        local function autoCollectCasinoLoot()
            local cashLeftBeforeMax = global.registry.cashLeftBeforeMax
            local function collectCash()
                for i,v in next, client.modules.ui.CircleAction.Specs do
                    if string.find(v.Name, "Collect") then v:Callback(true) end
                end
            end
            local function loop()
                if tostring(player.Team) == "Police" then return false end
                local bool = global.ui_status.auto_collect_cash
                if bool then
                    local getClosestCasinoLoot = global.registry.getClosestCasinoLoot
                    if getClosestCasinoLoot(20) then collectCash() end
                end
            end
            createloop(1, loop)
        end
        autoCollectCasinoLoot()
        local function collectClosestCash()
            local function collectCash(droppedcash)
                for i,v in next, client.modules.ui.CircleAction.Specs do
                    if string.find(v.Name, "Collect") and string.find(v.Name, "from") and v.Part == droppedcash then
                        v:Callback(droppedcash, true)
                        break
                    end
                end
            end
            local function loop()
                local bool = global.ui_status.droppedcashaura
                if bool then
                    local range = global.ui_status.droppedcashrange
                    local getClosestDroppedCash = global.registry.getClosestDroppedCash
                    if getClosestDroppedCash then
                        local droppedCash = getClosestDroppedCash(range)
                        if droppedCash then collectCash(droppedCash) end
                    end
                end
            end
            createloop(0.2, loop)
        end
        collectClosestCash()
        local function damageDealersCorrection()
            --@doamne ajuta functiuna asta ca e cea mai proasta pe care am scris o vreo data.
            local function lasers()
                local function hookForBank(bool)
                    for i,v in next, collectionservice:GetAllTags() do
                        for i2,v2 in next, collectionservice:GetTagged(v) do
                            if workspace:FindFirstChild("Banks") and v2:IsDescendantOf(workspace.Banks) and v2:FindFirstChild("TouchInterest") then v2.CanTouch = not bool end
                        end
                    end
                end
                local function hookForTrain(bool)
                    for i,v in next, collectionservice:GetAllTags() do
                        for i2,v2 in next, collectionservice:GetTagged(v) do
                            if v2:IsDescendantOf(workspace.Trains) and v2:FindFirstChild("TouchInterest") then v2.CanTouch = not bool end
                        end
                    end
                end
                local function hookForJewelry(bool)
                    for i,v in next, collectionservice:GetAllTags() do
                        for i2,v2 in next, collectionservice:GetTagged(v) do
                            if workspace:FindFirstChild("Jewelrys") and v2:IsDescendantOf(workspace.Jewelrys) and v2:FindFirstChild("TouchInterest") and v2.Name ~= "LaserTouch" then v2.CanTouch = not bool end
                        end
                    end
                end
                local function hookForMansion(bool)
                    local mansion = workspace:FindFirstChild("MansionRobbery")
                    local lasers = mansion and mansion:FindFirstChild("Lasers")
                    if not lasers then return false end
                    for i,v in next, lasers:GetDescendants() do
                        if v.Name == "Laser" then v.CanTouch = not bool end
                    end
                end
                local function breakCasinoLasers(bool)
                    local casino = workspace:FindFirstChild("Casino")
                    if casino then
                        local vaultLaserControl = casino:FindFirstChild("VaultLaserControl")
                        if vaultLaserControl then
                            for i,v in next, vaultLaserControl:GetDescendants() do
                                if v:FindFirstChild("TouchInterest") then v.CanTouch = not bool end
                            end
                        end
                        local lasersMoving = casino:FindFirstChild("LasersMoving")
                        if lasersMoving then
                            for i,v in next, lasersMoving:GetDescendants() do
                                if v:FindFirstChild("TouchInterest") then v.CanTouch = not bool end
                            end
                        end
                        local laserCarousel = casino:FindFirstChild("LaserCarousel")
                        if laserCarousel then
                            for i,v in next, laserCarousel:GetDescendants() do
                                if v:FindFirstChild("TouchInterest") then v.CanTouch = not bool end
                            end
                        end
                        local lasers = casino:FindFirstChild("Lasers")
                        if lasers then
                            for i,v in next, lasers:GetDescendants() do
                                if v:FindFirstChild("TouchInterest") then v.CanTouch = not bool end
                            end
                        end
                    end
                end
                global.registry.breakCasinoLasers = breakCasinoLasers
                local function breakLasers(bool)
                    for i,v in next, workspace:GetDescendants() do
                        if v.Name == "BarbedWire" then v.CanTouch = not bool end
                    end
                end
                local cache
                local function bank()
                    hookForBank(not cache.obj.Value)
                    task.wait(1)
                    hookForBank(cache.obj.Value)
                end
                local function jewelry()
                    hookForJewelry(not cache.obj.Value)
                    task.wait(1)
                    hookForJewelry(cache.obj.Value)
                end
                local function mansion()
                    hookForMansion(not cache.obj.Value)
                    task.wait(1)
                    hookForMansion(cache.obj.Value)
                end
                local function train(child)
                    for i,v in next, child:GetDescendants() do
                        if v:FindFirstChild("TouchInterest") then
                            hookForTrain(not cache.obj.Value)
                            task.wait(1)
                            hookForTrain(cache.obj.Value)
                        end
                    end
                end
                local function onCasinoSpawned()
                    breakLasers(not cache.obj.Value)
                    task.wait(1)
                    breakLasers(cache.obj.Value)
                end
                local function mansionRobberyLasers(bool)
                    local mansion = workspace:FindFirstChild("MansionRobbery")
                    local inRobbery = mansion and mansion:FindFirstChild("InRobberyFolder")
                    local lasers = mansion and mansion:FindFirstChild("Lasers")
                    if not inRobbery or not lasers then return false end
                    if inRobbery:FindFirstChild(player.UserId) then
                        for i,v in next, lasers:GetDescendants() do
                            if v:IsA("BasePart") then v.CanTouch = not global.ui_status.disable_lasers end
                        end
                    end
                end
                local loopf
                local function tagService()
                    cache = client.tags.new("lasers", 0, false, function(val)
                        breakLasers(val)
                        hookForBank(val)
                        hookForJewelry(val)
                        hookForTrain(val)
                        hookForMansion(val)
                        if loopf then
                            loopf:disconnect()
                            loopf = nil
                        else
                            loopf = createloop(0.5, function()
                                mansionRobberyLasers(val)
                            end)
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "disable_lasers")
                local function workspaceChildAdded(obj)
                    local barbedWire = obj:FindFirstChild("BarbedWire", true)
                    if barbedWire then
                        barbedWire.CanTouch = cache.obj.Value
                        task.delay(0.1, function()
                            barbedWire.CanTouch = not cache.obj.Value
                        end)
                    end
                    if obj.Name == "BarbedWire" then
                        obj.CanTouch = cache.obj.Value
                        task.delay(0.1, function()
                            obj.CanTouch = not cache.obj.Value
                        end)
                    end
                    if obj:IsA("Model") then
                        for i,v in next, obj:GetDescendants() do
                            if v.Name == "BarbedWire" then v.CanTouch = not cache.obj.Value end
                        end
                    end
                    local Model = obj:FindFirstChild("Model", true)
                    if Model then
                        local barbedWire = Model:FindFirstChild("BarbedWire", true)
                        if barbedWire then
                            for i2,v2 in next, Model:GetChildren() do
                                if v2:IsA("Part") then v2.CanTouch = not cache.obj.Value end
                            end
                        end
                    end
                    if obj.Name == "Banks" then
                        workspace.Banks.ChildAdded:connect(function(obj)
                            -- Bank2 was removed in the CH4 update; only Bank remains
                            local bank1 = workspace.Banks:FindFirstChild("Bank")
                            local layout = bank1 and bank1:FindFirstChild("Layout")
                            if layout then layout.ChildAdded:connect(bank) end
                        end)
                    end
                    if obj.Name == "Jewelrys" then
                        workspace.Jewelrys.ChildAdded:connect(function(obj)
                            local firstJewelry = workspace.Jewelrys:GetChildren()[1]
                            local floors = firstJewelry and firstJewelry:FindFirstChild("Floors")
                            if floors then floors.ChildAdded:connect(jewelry) end
                        end)
                    end
                    if obj.Name == "Casino" then
                        onCasinoSpawned()
                        breakCasinoLasers(cache.obj.Value)
                    end
                    if obj.Name == "MansionRobbery" then
                        mansion()
                        workspace.MansionRobbery.Lasers.Changed:connect(mansion)
                    end
                end
                if workspace:FindFirstChild("Banks") then
                    local bank1 = workspace.Banks:FindFirstChild("Bank")
                    local layout = bank1 and bank1:FindFirstChild("Layout")
                    if layout then layout.ChildAdded:connect(bank) end
                end
                if workspace:FindFirstChild("Jewelrys") then
                    local getFirstChild = workspace.Jewelrys:GetChildren()[1]
                    local floors = getFirstChild and getFirstChild:FindFirstChild("Floors")
                    if floors then floors.ChildAdded:connect(jewelry) end
                end
                if workspace:FindFirstChild("Casino") then
                    onCasinoSpawned()
                    breakCasinoLasers(cache.obj.Value)
                end
                if workspace:FindFirstChild("MansionRobbery") then workspace.MansionRobbery.Lasers.Changed:connect(mansion) end
                table.insert(client.onWorkspaceSpawnRun, {
                    _fn = workspaceChildAdded
                })
                workspace.Trains.ChildAdded:connect(train)
            end
            lasers()
            local function powerplant()
                local function powerplant_piston()
                    local piston = client.modules.piston.SlamPlayer
                    local function hook(...)
                        local bool = global.ui_status.disable_piston_damage
                        if bool then return task.wait(9e9) end
                        return piston(...)
                    end
                    client.modules.piston.SlamPlayer = hook
                end
                powerplant_piston()
                local function powerplant_powerwire()
                    local function breakPowerwire(bool)
                        local pp = workspace:FindFirstChild("PowerPlant")
                        if not pp then return end
                        for i,v in next, pp:GetDescendants() do
                            if v.Name == "PowerWire" then v.CanTouch = not bool end
                        end
                    end
                    local cache
                    local function tagService()
                        cache = client.tags.new("powerwire", 0, false, function(val)
                            breakPowerwire(val)
                        end)
                    end
                    tagService()
                    local function forceChange()
                        breakPowerwire(not cache.obj.Value)
                        task.wait(0.1)
                        breakPowerwire(cache.obj.Value)
                    end
                    local function onConnection()
                        local flow = client.modules.puzzleFlow and getupvalue(client.modules.puzzleFlow.Init, 3)
                        if type(flow) ~= "table" or type(flow.OnConnection) ~= "function" then return end
                        local onConnection = flow.OnConnection
                        local isFirstTime = true
                        local function hook(...)
                            if isFirstTime then
                                local getTagByName = client.tags:getTagByName("lasers")
                                for i,v in next, workspaceChildren do
                                    local Model = v:FindFirstChild("Model", true)
                                    if Model then
                                        local barbedWire = Model:FindFirstChild("BarbedWire", true)
                                        if barbedWire then
                                            -- only BaseParts have CanTouch; a child Model (CH4 added nested models) would error
                                            for i2,v2 in next, Model:GetChildren() do if v2:IsA("BasePart") then v2.CanTouch = not getTagByName.obj.Value end end
                                            isFirstTime = false
                                            break
                                        end
                                    end
                                end
                            end
                            return onConnection(...)
                        end
                        flow.OnConnection = hook
                    end
                    onConnection()
                    local function onPowerPlantAdded(obj)
                        if obj.Name == "PowerPlant" then forceChange() end
                    end
                    table.insert(client.onWorkspaceSpawnRun, {
                        _fn = onPowerPlantAdded
                    })
                    global.syncTagValue(cache, "disable_powerwire_damage")
                end
                powerplant_powerwire()
            end
            powerplant()
            local function tomb()
                local function resolver()
                    local function isLocalNearbyTeleporter()
                        local robberyTomb = workspace:FindFirstChild("RobberyTomb")
                        if not robberyTomb then return false end
                        local Top = robberyTomb.DartRoom.Teleporter:FindFirstChild("Top")
                        if Top then
                            local char = client.playerCharacter
                            if char then
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if root then
                                    if (Top.Position - root.Position).magnitude < 10 then
                                        root.CFrame = Top.CFrame
                                        return true
                                    elseif (Top.Position - root.Position).magnitude < 30 then global.notify("Automatically resolving Dart Room... Do not move!", 5) end
                                end 
                            end
                        end
                        return false
                    end
                    local isTeleporting = false
                    local function teleportToEveryPillar()
                        if isTeleporting then return false end
                        if not isLocalNearbyTeleporter() then return false end
                        local char = client.playerCharacter
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                isTeleporting = true
                                for i=1, 27 do
                                    task.wait(0.2)
                                    if i == 27 then
                                        isTeleporting = false
                                        break
                                    end
                                    local pos = workspace.RobberyTomb.DartRoom.Pillars:FindFirstChild(tostring(i)).InnerModel.Platform.CFrame
                                    root.CFrame = pos + Vector3.new(0, 1, 0)
                                end
                            end
                        end
                    end
                    local function loop()
                        if not isTeleporting and isLocalNearbyTeleporter() then teleportToEveryPillar() end
                    end
                    local cache
                    local loopf
                    local function tagService()
                        cache = client.tags.new("automaticresolvedart", 0, false, function(val)
                            if val then
                                loopf = createloop(0.1, loop)
                            else
                                if loopf then
                                    loopf:disconnect()
                                    loopf = nil
                                end
                            end
                        end)
                    end
                    tagService()
                    global.syncTagValue(cache, "automatic_resolve_dart_room")
                end
                resolver()
                local function darts()
                    local dartFire = client.modules.dartDispenser._fire
                    local function hook(...)
                        local bool = global.ui_status.disable_darts
                        if bool then return task.wait(9e9) end
                        return dartFire(...)
                    end
                    client.modules.dartDispenser._fire = hook
                end
                darts()
                local function wood()
                    local function breakWoods(bool)
                        for i,v in next, workspace.RobberyTomb.Cart.Planks:GetDescendants() do
                            if v.Name == "Wood" then v.CanTouch = not bool end
                        end
                    end
                    local cache
                    local function tagService()
                        cache = client.tags.new("wood", 0, false, function(val)
                            breakWoods(val)
                        end)
                    end
                    tagService()
                    local function forceChange()
                        breakWoods(not cache.obj.Value)
                        task.wait(0.1)
                        breakWoods(cache.obj.Value)
                    end
                    local function robberyTombAdded(obj)
                        if obj.Name == "RobberyTomb" then forceChange() end
                    end
                    table.insert(client.onWorkspaceSpawnRun, {
                        _fn = robberyTombAdded
                    })
                    global.syncTagValue(cache, "disable_wood")
                end
                wood()
                local function spikes()
                    local function breakSpikes(bool)
                        for i,v in next, workspace.RobberyTomb.SpikeRoom:GetDescendants() do
                            if v.Name == "Door" then v.CanTouch = not bool end
                        end
                    end
                    local cache
                    local function tagService()
                        cache = client.tags.new("spikes", 0, false, function(val)
                            breakSpikes(val)
                        end)
                    end
                    tagService()
                    local function forceChange()
                        breakSpikes(not cache.obj.Value)
                        task.wait(0.1)
                        breakSpikes(cache.obj.Value)
                    end
                    local function robberyTombAdded(obj)
                        if obj.Name == "RobberyTomb" then forceChange() end
                    end
                    table.insert(client.onWorkspaceSpawnRun, {
                        _fn = robberyTombAdded
                    })
                    global.syncTagValue(cache, "disable_spikes")
                end
                spikes()
                local function lava()
                    local function breakLava(bool)
                        for i,v in next, workspace.RobberyTomb.Kill:GetDescendants() do
                            if v.Name == "LavaKill" then v.CanTouch = not bool end
                        end
                    end
                    local cache
                    local function tagService()
                        cache = client.tags.new("lava", 0, false, function(val)
                            breakLava(val)
                        end)
                    end
                    tagService()
                    local function forceChange()
                        breakLava(not cache.obj.Value)
                        task.wait(0.1)
                        breakLava(cache.obj.Value)
                    end
                    local function robberyTombAdded(obj)
                        if obj.Name == "RobberyTomb" then forceChange() end
                    end
                    table.insert(client.onWorkspaceSpawnRun, {
                        _fn = robberyTombAdded
                    })
                    global.syncTagValue(cache, "disable_lava")
                end
                lava()
            end
            tomb()
            local function cameras()
                local function breakLights(bool)
                    local museum = workspace:FindFirstChild("Museum")
                    if museum then
                        local lights = museum.Lights
                        if lights then
                            for i,v in next, lights:GetDescendants() do
                                if v.Name == "Light" then v.CanTouch = not bool end
                            end
                        end
                    end
                    local casino = workspace:FindFirstChild("Casino")
                    if casino then
                        local camerasMoving = casino.CamerasMoving
                        if camerasMoving then
                            for i,v in next, camerasMoving:GetDescendants() do
                                if v.Name == "Part" then v.CanTouch = not bool end
                            end
                        end
                    end
                    local jewelrys = workspace:FindFirstChild("Jewelrys")
                    if jewelrys then
                        if #jewelrys:GetChildren() > 0 then 
                            local floors = jewelrys:GetChildren()[1].Floors
                            if floors then
                                for i,v in next, floors:GetDescendants() do
                                    if v.Name == "Part" then v.CanTouch = not bool end
                                end
                            end
                        end
                    end
                end
                local cache
                local function tagService()
                    cache = client.tags.new("cameras", 0, false, function(val)
                        breakLights(val)
                    end)
                end
                tagService()
                local function changeOnChildAdded()
                    task.wait(0.1)
                    breakLights(not cache.obj.Value)
                    task.wait(0.1)
                    breakLights(cache.obj.Value)
                end
                local function onAddedWorkspace(obj)
                    if obj.Name == "Jewelrys" then
                        changeOnChildAdded()
                        local firstJewelry = workspace.Jewelrys:GetChildren()[1]
                        local floors = firstJewelry and firstJewelry:FindFirstChild("Floors")
                        if floors then floors.ChildAdded:connect(changeOnChildAdded) end
                    end
                    if obj.Name == "Museum" then changeOnChildAdded() end
                    if obj.Name == "Casino" then changeOnChildAdded() end
                end
                table.insert(client.onWorkspaceSpawnRun, {
                    _fn = onAddedWorkspace
                })
                if workspace:FindFirstChild("Jewelrys") then
                    local findFirstChild = workspace.Jewelrys:GetChildren()[1]
                    local floors = findFirstChild and findFirstChild:FindFirstChild("Floors")
                    if floors then floors.ChildAdded:connect(changeOnChildAdded) end
                end
                global.syncTagValue(cache, "disable_cameras")
            end
            cameras()
        end
        damageDealersCorrection()
        local function robberyStatusCorrection()
            local cache
            local function tagService()
                cache = client.tags.new("casino_status", 0, false, function(val)
                    local breakCasinoLasers = global.registry.breakCasinoLasers
                    if breakCasinoLasers then breakCasinoLasers(val) end
                end)
            end
            tagService()
            local openColor = Color3.fromRGB(178, 255, 104)
            local startedColor = Color3.fromRGB(255, 178, 102)
            local closedColor = Color3.fromRGB(255, 102, 102)
            local function getRobberyState() return repl:FindFirstChild("RobberyState") end
            local function enumForName(name)
                local consts = client.modules.robberyConsts
                if not consts or not consts.ENUM_ROBBERY then return nil end
                return consts.ENUM_ROBBERY[name] or consts.ENUM_ROBBERY[tostring(name):upper()]
            end
            local function enumForKey(key)
                local consts = client.modules.robberyConsts
                if not consts then return nil end
                local wanted = tostring(key):lower()
                if consts.DATA_ROBBERY then
                    for enum, data in next, consts.DATA_ROBBERY do
                        if tostring(enum):lower() == wanted or type(data) == "table" and (tostring(data.key):lower() == wanted or tostring(data.Name):lower() == wanted or tostring(data.name):lower() == wanted) then return enum end
                    end
                end
                if consts.LIST_ROBBERY and consts.ENUM_ROBBERY then
                    for i, name in next, consts.LIST_ROBBERY do
                        if tostring(name):lower() == wanted then return consts.ENUM_ROBBERY[name] end
                    end
                end
                return enumForName(key)
            end
            local function readRobberyState(enumValue)
                local robberyState = getRobberyState()
                if not robberyState or enumValue == nil then return nil end
                local stateVal = robberyState:FindFirstChild(tostring(enumValue))
                if not stateVal then return nil end
                if stateVal.Value == 1 then return true end
                if stateVal.Value == 2 then return 0 end
                return false
            end
            local function statusByName(name) return readRobberyState(enumForName(name)) end
            local function statusByKey(key) return readRobberyState(enumForKey(key)) end
            local function mergeStatus(...)
                local started = false
                for i = 1, select("#", ...) do
                    local value = select(i, ...)
                    if value == true then return true end
                    if value == 0 then started = true end
                end
                if started then return 0 end
                return false
            end
            local statusDefinitions = {
                {
                    Label = "Bank Status";
                    Open = "Rising City: Open";
                    Started = "Rising City: Started";
                    Closed = "Rising City: Closed";
                    Read = function()
                        return statusByName("BANK")
                    end;
                };
                {
                    Label = "BANK2_ROBBERY_STATUS";
                    Open = "Crater City: Open";
                    Started = "Crater City: Started";
                    Closed = "Crater City: Closed";
                    Read = function()
                        return statusByName("BANK2")
                    end;
                };
                {
                    Label = "Museum Status";
                    Read = function()
                        return statusByName("MUSEUM")
                    end;
                };
                {
                    Label = "Jewelry Status";
                    Read = function()
                        return statusByName("JEWELRY")
                    end;
                };
                {
                    Label = "Casino Status";
                    Read = function()
                        return statusByName("CROWN_JEWEL")
                    end;
                };
                {
                    Label = "Trains Status";
                    Read = function()
                        return mergeStatus(statusByName("TRAIN_PASSENGER"), statusByName("TRAIN_CARGO"))
                    end;
                };
                {
                    Label = "Airdrop Status";
                    Read = function()
                        return workspace:FindFirstChild("Drop") ~= nil
                    end;
                };
                {
                    Label = "Tomb Status";
                    Read = function()
                        return statusByName("TOMB")
                    end;
                };
                {
                    Label = "Cargoplane Status";
                    Read = function()
                        return statusByName("CARGO_PLANE")
                    end;
                };
                {
                    Label = "Banktruck Status";
                    Read = function()
                        return statusByName("MONEY_TRUCK")
                    end;
                };
                {
                    Label = "Powerplant Status";
                    Read = function()
                        return statusByName("POWER_PLANT")
                    end;
                };
                {
                    Label = "Cargoship Status";
                    Read = function()
                        return statusByName("CARGO_SHIP")
                    end;
                };
                {
                    Label = "Mansion Status";
                    Read = function()
                        return statusByName("MANSION")
                    end;
                };
                {
                    Label = "Donut Shop";
                    Open = "Donut Shop: Opened";
                    Started = "Donut Shop: Started";
                    Closed = "Donut Shop: Closed";
                    Read = function()
                        return statusByName("STORE_DONUT")
                    end;
                };
                {
                    Label = "Gas Station";
                    Open = "Gas Station: Opened";
                    Started = "Gas Station: Started";
                    Closed = "Gas Station: Closed";
                    Read = function()
                        return statusByName("STORE_GAS")
                    end;
                };
                {
                    Label = "Grocery Store";
                    Open = "Grocery Store: Opened";
                    Started = "Grocery Store: Started";
                    Closed = "Grocery Store: Closed";
                    Read = function()
                        return statusByName("STORE_GROCERY")
                    end;
                };
            }
            local function applyStatus(definition, value)
                local statusRobberies = global.ui.statusRobberies
                local colorForcing = global.ui.colorForcing
                if statusRobberies[definition.Label] == nil then return end
                if value == 0 then
                    statusRobberies[definition.Label] = definition.Started or "Status: Started"
                    colorForcing[definition.Label] = startedColor
                elseif value then
                    statusRobberies[definition.Label] = definition.Open or "Status: Open"
                    colorForcing[definition.Label] = openColor
                else
                    statusRobberies[definition.Label] = definition.Closed or "Status: Closed"
                    colorForcing[definition.Label] = closedColor
                end
            end
            local function update()
                local casinoStatus = statusByName("CROWN_JEWEL")
                if cache then
                    local casinoActive = casinoStatus == true or casinoStatus == 0
                    cache.obj.Value = global.ui_status.disable_lasers and casinoActive or false
                end
                for i, definition in ipairs(statusDefinitions) do
                    local ok, value = pcall(definition.Read)
                    if ok then applyStatus(definition, value) end
                end
            end
            local function connectSignal(signal, callback)
                if not signal then return end
                local ok = pcall(function()
                    signal:Connect(callback)
                end)
                if not ok then
                    pcall(function()
                        signal:connect(callback)
                    end)
                end
            end
            local function connectStateValue(stateValue)
                if stateValue and stateValue.Changed then connectSignal(stateValue.Changed, update) end
            end
            local robberyState = getRobberyState()
            if robberyState then
                for i, stateValue in next, robberyState:GetChildren() do connectStateValue(stateValue) end
                connectSignal(robberyState.ChildAdded, function(stateValue)
                    connectStateValue(stateValue)
                    update()
                end)
            end
            connectSignal(workspace.ChildAdded, function(obj)
                if obj.Name == "Drop" then update() end
            end)
            connectSignal(workspace.ChildRemoved, function(obj)
                if obj.Name == "Drop" then update() end
            end)
            update()
            createloop(1, update)
        end
        robberyStatusCorrection()
        local function minimapCorrection()
            local function noFlash()
                local minimapService = client.modules.minimapService
                local store = getupvalue(minimapService.add, 1) -- u6 = the store
                local isVulnerable = global.registry.isVulnerable
                local function loop()
                    if not store then return end
                    local state = store:getState()
                    local points = state and state.minimap and state.minimap.points
                    if not points then return end
                    local bool = global.ui_status.disable_minimap_flash
                    for i, v in next, points do
                        local plr = players:FindFirstChild(v.name)
                        if plr then
                            if isVulnerable(player.Team, plr.Team) then v.flash = not bool end
                        end
                    end
                end
                createloop(1, loop)
            end
            noFlash()
        end
        minimapCorrection()
        local function radioCorrection()
            local actionButtonService = client.modules.actionButtonService
            task.spawn(function()
                for i,v in next, actionButtonService.active do
                    if table.find(v.keyCodes, Enum.KeyCode.R) and v._groupKey == "outer" then
                        local onPressed = v.onPressed   
                        v.onPressed = function(...)
                            if global.ui_status.disable_radio_keybind then return task.wait(9e9) end
                            return onPressed(...)
                        end
                    end
                end
            end)
        end
        radioCorrection()
        local function givingCorrection()
            local isProjectile = global.registry.isProjectile
            local function always_equip()
                local equipOwnedItem = global.registry.equipOwnedItem
                local function loop()
                    local bool = global.ui_status.always_equip_owned_guns
                    if bool then
                        if not client.playerCharacter then return false end
                        if global.is_instant_reloading then return false end
                        if global.ui_status.spam_drop_guns then return false end
                        local resolveOwnedItems = client.reg.resolveOwnedItems
                        local resolveEquippedItems = client.reg.resolveEquippedItems
                        for i,v in next, resolveOwnedItems do
                            if not table.find(resolveEquippedItems, v) and not isProjectile(v) then equipOwnedItem(v) end
                        end
                    end
                end
                createloop(0.5, loop)
            end
            always_equip()
            local function dropdown()
                local isProjectile = global.registry.isProjectile
                local controls = global.ui.controls
                local function assignGuns()
                    local cfg = controls.equip_guns
                    local list = {}
                    for i,v in next, client.reg.resolveOwnedItems do
                        if not isProjectile(v) then table.insert(list, v) end
                    end
                    cfg.list = list
                    task.delay(0.2, function()
                        cfg.reload(cfg.list)
                    end)
                end
                assignGuns()
                local function onNewItem(obj)
                    if isProjectile(obj.Name) then return false end
                    local cfg = controls.equip_guns
                    cfg.list = {obj.Name}
                    task.delay(0.2, function()
                        cfg.reload(cfg.list)
                    end)
                end
                local items = player.Items or player:WaitForChild("Items")
                items.ChildAdded:connect(onNewItem)
            end
            dropdown()
        end
        givingCorrection()
        local function jewelryCorrection()
            local function isInJewelry()
                local getPartsInRegion = global.registry.getPartsInRegion
                local char = client.playerCharacter
                if char then
                    local primarypart = char.PrimaryPart
                    if primarypart then
                        local tbl = {
                            x = {
                                max = 156;
                                min = 103;
                            };
                            y = {
                                max = 70;
                                min = 15;
                            };
                            z = {
                                max = 1350;
                                min = 1265;
                            };
                        }
                        local pos = {
                            x = primarypart.Position.x;
                            y = primarypart.Position.y;
                            z = primarypart.Position.z;
                        }
                        local getPartsInRegion = getPartsInRegion(pos.x, pos.y, pos.z, tbl.x.min, tbl.y.min, tbl.z.min, tbl.x.max, tbl.y.max, tbl.z.max)
                        if getPartsInRegion then return true end
                    end
                end
                return false
            end
            local function grabGems()
                local function loop()
                    if tostring(player.Team) == "Police" then return false end
                    local bool = global.ui_status.automatic_grab_nearby_jewels
                    if bool then
                        local isInJewelry = isInJewelry()
                        if isInJewelry then
                            if workspace:FindFirstChild("Jewelrys") then
                                for i,v in next, client.modules.ui.CircleAction.Specs do
                                    if v.Name == "Grab Jewel" and v.Part:IsDescendantOf(workspace.Jewelrys) then v:Callback(true) end
                                end
                            end
                        end
                    end
                end
                createloop(0.2, loop)
            end
            grabGems()
            local function automaticPunch()
                local getPartsInRegion = global.registry.getPartsInRegion
                local parts = {}
                local function scanParts()
                    local scan = {"Head", "RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm"}
                    local function onCharacterAdded(char)
                        for i=1, #scan do
                            local v = scan[i]
                            local part = char:WaitForChild(v)
                            if part then table.insert(parts, part) end
                        end
                    end
                    player.CharacterAdded:connect(onCharacterAdded)
                    local function onCharacterRemoving(char)
                        for i=1, #parts do table.remove(parts, i) end
                    end
                    player.CharacterRemoving:connect(onCharacterRemoving)
                    local char = client.playerCharacter
                    if char then
                        for i,v in next, char:GetChildren() do
                            if table.find(scan, v.Name) then table.insert(parts, v) end
                        end
                    end
                end
                scanParts()
                local function getJewelrys() return workspace:FindFirstChild("Jewelrys") end
                local function getJewelryModel()
                    local getJewelrys = getJewelrys()
                    if not getJewelrys then return false end
                    return getJewelrys:GetChildren()[1]
                end
                local function getBoxes() return getJewelryModel().Boxes:GetChildren() end
                local function getJewelryFloor() return getJewelryModel().Floors:GetChildren()[1] end
                local function getJewelryFloorPart() return getJewelryFloor().PrimaryPart end
                local function isBoxBroken(box) return box.Transparency ~= -2 end
                local function isFacingBox(box, part)
                    local u = ((box.Position - part.Position) * Vector3.new(1,0,1)).unit
                    local lookvec = part.CFrame.LookVector * Vector3.new(1, 0, 1)
                    return lookvec:Dot(u) > 0.78
                end
                local function isPlayerNearbyBox(box, part)
                    local mag = (box.Position - part.Position).magnitude
                    if mag < 5 then return true end
                    return false
                end
                local lastPunch = tick()
                local function canPunch()
                    if tick() - lastPunch > 0.2 then return true end
                    return false
                end
                local function attemptPunch()
                    local buttons = global.registry.buttons
                    if canPunch() then
                        buttons.attemptPunch()
                        lastPunch = tick()
                    end
                end
                local function getJewelryStatus()
                    local getJewelryStatus = global.registry.getRobberyStatus("jewelry")
                    return getJewelryStatus
                end
                local function loop()
                    if tostring(player.Team) == "Police" then return false end
                    local bool = global.ui_status.automatic_punch_jewelry_boxes
                    if bool then
                        if client.reg.getEquippedItem then return false end
                        if not canPunch() then return false end
                        local getJewelryStatus = getJewelryStatus()
                        if getJewelryStatus or getJewelryStatus == 0 then
                            local isInJewelry = isInJewelry()
                            if isInJewelry then
                                local getBoxes = getBoxes()
                                if getBoxes then
                                    local partsindex = #parts
                                    if partsindex > 0 then
                                        for i=1, partsindex do
                                            local v = parts[i]
                                            for i2=1, #getBoxes do
                                                local v2 = getBoxes[i2]
                                                local isBoxBroken = isBoxBroken(v2)
                                                if not isBoxBroken then
                                                    local isPlayerNearbyBox = isPlayerNearbyBox(v2, v)
                                                    if isPlayerNearbyBox then
                                                        local isFacingBox = isFacingBox(v2, v)
                                                        if isFacingBox then attemptPunch() end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                createloop(0, loop)
                --@NU LE STERGE!!!!!!!!! 
                global.registry.scannedParts = parts
                global.registry.getBoxes = getBoxes
                global.registry.getJewelryFloorPart = getJewelryFloorPart
                global.registry.isJewelryBoxBroken = isJewelryBoxBroken
                global.registry.getJewelryFloor = getJewelryFloor
                global.registry.getJewelryModel = getJewelryModel
                global.registry.isFacingPart = isFacingBox
                global.registry.isNearbyJewelryBox = isPlayerNearbyJewelryBox
                global.registry.isInJewelry = isInJewelry
                global.registry.lastUsedPunchingForJewelry = lastPunch
            end
            automaticPunch()
        end
        jewelryCorrection()
        local function casinoCorrection()
            local function elevator()
                local call_elevator_to_floor = global.registry.call_elevator_to_floor
                local function loop()
                    local bool = global.ui_status.break_elevator
                    if bool then
                        call_elevator_to_floor("Vaults")
                        return true
                    end
                    return false
                end
                createloop(1, loop)
            end
            elevator()
            local function vault()
                local ui = client.modules.ui
                local specs = ui.CircleAction.Specs
                local vaults = {}
                local actions = {}
                local registeredVaults = {}
                local vaultPuzzle = collectionservice:GetTagged("VaultDoorPuzzle")
                local function getCasino() return workspace:FindFirstChild("Casino") end
                local function getCasinoVault(puzzle)
                    local casino = getCasino()
                    if not casino or not puzzle or not puzzle:IsDescendantOf(casino) then return nil end
                    local innerModel = puzzle.Parent
                    local door = innerModel and innerModel.Parent
                    if not door or door.Name ~= "VaultDoorMain" and door.Name ~= "VaultDoorSlider" then return nil end
                    local model = innerModel:FindFirstChild("Model")
                    local specPart = puzzle:FindFirstChild("Part")
                    if not model or not specPart then return nil end
                    return door, model, specPart
                end
                local function onLEDChange(obj, v2, v, model)
                    if v.puzzle:GetAttribute("VaultHackerId") ~= nil and v.puzzle:GetAttribute("VaultHackerId") ~= player.UserId then return false end
                    if string.find(obj, "BrickColor") then
                        local led = model:FindFirstChild("UnlockedLED")
                        if led and led.BrickColor == BrickColor.new("Lime green") then v2:Callback(true) end
                    end
                end
                local function onLightChange(obj, v2, v, model)
                    if v.puzzle:GetAttribute("VaultHackerId") ~= nil and v.puzzle:GetAttribute("VaultHackerId") ~= player.UserId then return false end
                    if string.find(obj, "BrickColor") then
                        local light = model:FindFirstChild("Light")
                        if light and light.BrickColor == BrickColor.new("Lime green") then v2:Callback(true) end
                    end
                end
                local function registerVaultPuzzle(obj)
                    if registeredVaults[obj] then return end
                    local door, model, specPart = getCasinoVault(obj)
                    if not door then return end
                    registeredVaults[obj] = true
                    table.insert(vaults, {
                        puzzle = obj;
                        doorName = door.Name;
                        specPart = specPart;
                        model = model;
                    })
                    local vaultIndex = #vaults
                    local vault = vaults[vaultIndex]
                    specs = ui.CircleAction.Specs
                    for i2,v2 in next, specs do
                        if v2.Part == vault.specPart then
                            if vault.doorName == "VaultDoorMain" then
                                local unlockedLed = model:FindFirstChild("UnlockedLED")
                                if unlockedLed then
                                    unlockedLed.Changed:connect(function(obj)
                                        onLEDChange(obj, v2, vault, model) 
                                    end)
                                end
                            elseif vault.doorName == "VaultDoorSlider" then
                                local light = model:FindFirstChild("Light")
                                if light then
                                    light.Changed:connect(function(obj)
                                        onLightChange(obj, v2, vault, model)
                                    end)
                                end
                            end
                            v2.vaultIdx = vaultIndex
                            v2.vaultType = vault.doorName
                            v2.puzzle = vault.puzzle
                            v2.vaultDoor = door
                            table.insert(actions, v2)
                        end
                    end
                end
                local function onInstanceAdded(obj) registerVaultPuzzle(obj) end
                collectionservice:GetInstanceAddedSignal("VaultDoorPuzzle"):connect(onInstanceAdded)
                for i,v in next, vaultPuzzle do registerVaultPuzzle(v) end
                local function getClosestVault()
                    local char = client.playerCharacter
                    if not char then return false end
                    local root = char.PrimaryPart
                    if not root then return false end
                    local closest, dist = nil, 10
                    for i,v in next, actions do
                        if v.Part then
                            local magnitude = (root.Position - v.Part.Position).magnitude
                            if magnitude < dist then
                                closest = v
                                dist = magnitude
                            end
                        end
                    end
                    return closest
                end
                global.registry.getClosestVault = getClosestVault
                local function loop()
                    if tostring(player.Team) ~= "Criminal" then return false end
                    local getClosestVault = getClosestVault()
                    local vaultDoor = getClosestVault and getClosestVault.vaultDoor
                    if not getClosestVault or not vaultDoor or vaultDoor:GetAttribute("DoorOpen") == true then return false end
                    if getClosestVault and getClosestVault.puzzle:GetAttribute("VaultHackerId") == nil then getClosestVault:Callback(true) end
                end
                local loopf
                local tagCache
                local function tagService()
                    tagCache = client.tags.new("auto_crack_vault", 0, false, function(val)
                        if val then
                            loopf = createloop(0.2, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                local function loop()
                    local bool = global.ui_status.auto_crack_vault
                    if tagCache then tagCache.obj.Value = bool end
                end
                createloop(0, loop)
            end
            vault()
        end
        casinoCorrection()
        local function trainCorrection()
            local function switches()
                local click_switch1
                local rail1
                local function switch1()
                    local switches = workspace:FindFirstChild("Switches")
                    if not switches then 
                        return false
                    end
                    local branchBack = switches:FindFirstChild("BranchBack")
                    if not branchBack then return false end
                    for i,v in next, branchBack:GetDescendants() do
                        if v.Name == "Click" then click_switch1 = v.ClickDetector end
                        if v.Name == "Rail" then rail1 = v end
                    end
                end
                switch1()
                local click_switch2
                local rail2
                local function switch2()
                    local switches = workspace:FindFirstChild("Switches")
                    if not switches then 
                        return false
                    end
                    local branchForward = switches:FindFirstChild("BranchForward")
                    if not branchForward then return false end
                    for i,v in next, branchForward:GetDescendants() do
                        if v.Name == "Click" then click_switch2 = v.ClickDetector end
                        if v.Name == "Rail" then rail2 = v end
                    end
                end
                switch2()
                local function loop()
                    if not rail1 then return false end
                    if not rail2 then return false end
                    if rail1.Transparency ~= 1 then fireclickdetector(click_switch1) end
                    if rail2.Transparency ~= 0 then fireclickdetector(click_switch2) end
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("anti_station_stop", 0, false, function(val)
                        if val then
                            loopf = createloop(0.1, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "anti_station_stop")
            end
            switches()
            local function isTrainClose()
                local trains = workspace.Trains
                if #trains:GetChildren() == 0 then return false end
                local char = client.playerCharacter
                if not char then return false end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return false end
                local cart = trains:GetChildren()[1]:FindFirstChildWhichIsA("Part")
                if (cart.Position - root.Position).magnitude < 35 then return true end
            end
            local function passenger()
                local function grab()
                    local grabber = {"computer", "documents", "briefcase", "phone", "Cash", "spyglasses"}
                    for i,v in next, client.modules.ui.CircleAction.Specs do
                        for i2,v2 in next, grabber do
                            if string.find(v.Name, ("Grab %s"):format(v2)) then
                                if v.Part:IsDescendantOf(workspace.Trains) and v.Enabled then
                                    v:Callback(true)
                                    task.wait(2)
                                end
                            end
                        end
                    end
                end
                local function loop()
                    local trains = workspace.Trains
                    if #trains:GetChildren() == 0 then return false end
                    local automatic_delivery = global.ui_status.automatic_delivery
                    if automatic_delivery then
                        if tostring(player.Team) ~= "Police" then return false end
                        local isTrainClose = isTrainClose()
                        if isTrainClose then grab() end
                        return true 
                    end
                    local bool = global.ui_status.automatic_train_fillbag
                    if bool then
                        if tostring(player.Team) == "Police" then return false end
                        local isTrainClose = isTrainClose()
                        if isTradeClose then grab() end
                    end
                end
                createloop(3, loop)
            end
            passenger()
            local function cargo()
                local function openDoor()
                    for i,v in next, client.modules.ui.CircleAction.Specs do
                        if v.Name == "Open Door" and v.Part:IsDescendantOf(workspace.Trains) then
                            if v.Enabled then v:Callback(true) end
                        end
                    end  
                end
                local function breachVault()
                    for i,v in next, client.modules.ui.CircleAction.Specs do
                        if v.Name == "Breach Vault" and v.Part:IsDescendantOf(workspace.Trains) then
                            if v.Enabled then v:Callback(true) end
                        end
                    end
                end
                local function loop()
                    local bool = global.ui_status.automatic_breach_vault
                    if bool then
                        local isTrainClose = isTrainClose()
                        if isTrainClose then
                            openDoor()
                            breachVault()
                        end
                    end
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("automatic_breach_vault", 0, false, function(val)
                        if val then
                            loopf = createloop(1, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "automatic_breach_vault")
            end
            cargo()
        end
        trainCorrection()
        local function spotlightCorrection()
            local trackingSpotlight = client.modules.trackingSpotlight and client.modules.trackingSpotlight._constructor
            if not trackingSpotlight or not trackingSpotlight.TrackPlayer then return false end
            local trackPlayer = trackingSpotlight.TrackPlayer
            local function hook(...)
                local bool = global.ui_status.disable_spotlight_tracking
                if bool then return false end
                return trackPlayer(...)
            end
            trackingSpotlight.TrackPlayer = hook
        end
        spotlightCorrection()
        local function bulletCorrection()
            local function prediction(target)
                local function predict(part) return part.Position + part.Velocity * 0.13 end
                local predict = predict(target)
                if predict then return predict end
                return false
            end
            local a = 0
            local hsv --culoarea normal din jailbreak: Color3.fromHSV(1, 0.921569, 0.552941)
            local function createColorfulTable()
                --@nu mai stiu de unde am furat asta dar mersi! 
                while true do
                    for i=0, 1, 1/300 do
                        hsv = Color3.fromHSV(i, 1, 1)
                        task.wait()
                    end
                end
            end
            task.spawn(createColorfulTable)
            local function colorBullet()
                local update = client.modules.bulletEmitter.Update
                -- Update runs for every player's emitter every frame; JIT it and only
                -- recolor the local player's bullets (self.Local) so we don't paint
                -- everyone else's shots across the map.
                client.modules.bulletEmitter.Update = LPH_JIT_MAX(function(self, ...)
                    if global.ui_status.rainbowbullets and self and self.Local == true then self.Color = hsv end
                    return update(self, ...)
                end)
            end
            colorBullet()
            local function getSilentAimTargetPart(target)
                if not target or typeof(target) ~= "Instance" then return false end
                if target:IsA("Player") then
                    local char = target.Character
                    return char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
                end
                if target:IsA("Model") then return target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart end
                if target:IsA("BasePart") then return target end
                return false
            end
            local function silentaim()
                local loop = LPH_JIT_MAX(function()
                    local bool = global.ui_status.master_switch_silentaim
                    if not bool then return false end
                    local getEquippedItem = client.reg.getEquippedItem
                    if not getEquippedItem then return false end
                    local bulletEmitter = getEquippedItem.BulletEmitter
                    local bullets = bulletEmitter and bulletEmitter.Bullets
                    if not bullets then return false end
                    local char = client.playerCharacter
                    local origin = char and (char:FindFirstChild("Head") or char.PrimaryPart)
                    if not origin then return false end
                    local target = client.reg.getClosestPlayerByFov
                    local targetPart = getSilentAimTargetPart(target)
                    if not targetPart then return false end
                    if global.ui_status.no_wall_penetration then
                        local checkWallBeforePenetration = global.registry.checkWallBeforePenetration
                        if checkWallBeforePenetration and not checkWallBeforePenetration(target) then return false end
                    end
                    local aimPosition = targetPart.Position
                    if global.ui_status.always_predict then
                        local predictedPosition = prediction(targetPart)
                        if predictedPosition then aimPosition = predictedPosition end
                    end
                    local delta = aimPosition - origin.Position
                    if delta.magnitude <= 0 then return false end
                    local direction = delta.unit
                    for i = 1, #bullets do
                        local bullet = bullets[i]
                        if bullet then bullet[2] = direction end
                    end
                end)
                createloop(0, loop)
            end
            silentaim()
            local function plasmaHooks()
                local ok, plasmaGun = pcall(function()
                    return require(repl.Game.Item.PlasmaGun)
                end)
                if not ok or type(plasmaGun) ~= "table" then return false end
                local originalShootOther = plasmaGun.ShootOther
                if type(originalShootOther) ~= "function" or plasmaGun.CrewbattlerPlasmaHooked then return false end

                local okChar, charUtils = pcall(function()
                    return require(repl.Std.CharacterUtils)
                end)
                if not okChar then charUtils = nil end
                local damageRemoteName = "Damage"
                pcall(function()
                    local consts = require(repl.Game.ItemSystem.GunSystemConsts)
                    if type(consts) == "table" and type(consts.DAMAGE_REMOTE_NAME) == "string" then damageRemoteName = consts.DAMAGE_REMOTE_NAME end
                end)

                local function targetHumanoid(part)
                    if charUtils and type(charUtils.getAncestorPartHumanoid) == "function" then
                        return charUtils.getAncestorPartHumanoid(part)
                    end
                    local model = part and part:FindFirstAncestorWhichIsA("Model")
                    return model and model:FindFirstChildOfClass("Humanoid")
                end

                -- The plasma raycast in ShootOther is blocked by walls (CanCollide), so a
                -- wallbang can't be done by editing the ignore list. Instead deal the damage
                -- straight to the target through the same Damage remote the game uses.
                local function wallbangDamage(self, targetPart)
                    local humanoid = targetHumanoid(targetPart)
                    if not humanoid then return false end
                    local itemValue = self.inventoryItemValue
                    local remote = itemValue and itemValue:FindFirstChild(damageRemoteName)
                    if not remote then return false end
                    remote:FireServer(targetPart.Position, humanoid)
                    return true
                end

                plasmaGun.CrewbattlerPlasmaHooked = true
                plasmaGun.ShootOther = function(self, a)
                    local includePlasma = global.ui_status.master_switch_silentaim and global.ui_status.silentaim_include_plasma
                    local targetPart
                    if includePlasma then
                        pcall(function()
                            local target = client.reg.getClosestPlayerByFov
                            targetPart = getSilentAimTargetPart(target)
                            if targetPart and self.Tip then self.TipDirection = (targetPart.Position - self.Tip.Position).Unit end
                        end)
                    end

                    if global.ui_status.wallbang and targetPart and (self.Local or self.SimulateLocal) then
                        local dealt = false
                        pcall(function()
                            dealt = wallbangDamage(self, targetPart)
                        end)
                        if dealt then
                            -- run the original only for recoil/visuals, with its raycast
                            -- forced to miss so it can't double-damage on line of sight
                            local oldIgnore = self.IgnoreList
                            self.IgnoreList = {workspace}
                            pcall(originalShootOther, self, a)
                            self.IgnoreList = oldIgnore
                            return
                        end
                    end

                    return originalShootOther(self, a)
                end
            end
            plasmaHooks()
            local function rayIgnoreNonCollideHooks()
                local module = client.modules.rayCast.RayIgnoreNonCollideWithIgnoreList
                local function selectTaserTarget()
                    local getTarget = client.reg.getClosestPlayerByFov
                    if not getTarget or typeof(getTarget) ~= "Instance" then return false end
                    return getSilentAimTargetPart(getTarget)
                end
                local function selectTarget(...)
                    local getTarget = client.reg.getClosestPlayerByFov
                    if not getTarget then return false end
                    if getTarget:FindFirstChild("DefenseObjValueName") then
                        local root = getTarget.HumanoidRootPart
                        if root then return root end
                    end
                    local mansion = workspace:FindFirstChild("MansionRobbery")
                    if mansion and getTarget:IsDescendantOf(mansion) then
                        local always_head = global.ui_status.always_target_boss_head
                        if getTarget.Name == "ActiveBoss" then
                            local head = getTarget:FindFirstChild("Head")
                            if head then return head end
                        end
                        if getTarget.Parent and getTarget.Parent.Name == "GuardsFolder" then return getTarget.PrimaryPart end
                    end
                    return getSilentAimTargetPart(getTarget)
                end
                local traceback = debug.traceback
                local function hook(...)
                    if not client.playerCharacter or client.playerCharacter and not client.playerCharacter.PrimaryPart then return module(...) end
                    local getEquippedItem = client.reg.getEquippedItem
                    if not getEquippedItem then return module(...) end
                    if global.ui_status.killaura_masterswitch then
                        if traceback():find("BulletEmitter") then
                            local target = client.reg.getClosestVulnerablePlayer
                            if target then
                                local char = target.Character
                                if char then
                                    local primaryPart = char.PrimaryPart
                                    if primaryPart then return primaryPart, primaryPart.Position, ... end
                                end
                            end
                        end
                    end
                    if global.ui_status.master_switch_silentaim and not global.ui_status.no_wall_penetration then
                        if traceback():find("BulletEmitter") then
                            if not getEquippedItem.BulletEmitter or getEquippedItem.__ClassName == "RocketLauncher" then return module(...) end
                            local target = selectTarget()
                            if not target then return module(...) end
                            local position = target.Position
                            local always_predict = global.ui_status.always_predict
                            if not always_predict then return target, position, ... end
                            local prediction = prediction(target)
                            if prediction then return target, prediction, ... end
                            return target, position, ...
                        end
                    end
                    if traceback():find("Taser") then
                        if global.ui_status.master_switch_silentaim and global.ui_status.allow_taser_aimbot then
                            local target = selectTaserTarget()
                            if not target then return module(...) end
                            local position = target.Position
                            return target, position, ...
                        elseif global.ui_status.allow_tase_target and global.AI_TASER_USE then
                            local target = selectTaserTarget()
                            if not target then return module(...) end
                            return target, target.Position, ...
                        end
                    end
                    return module(...)
                end
                table.insert(client.rayHooks, {
                    silent = true;
                    fn = hook;
                })
                local function rayHooks(...)
                    if traceback():find("Taser") or traceback():find("BulletEmitter") then
                        for i,v in next, client.rayHooks do
                            if v.silent then return v.fn(...) end
                        end
                    else
                        for i,v in next, client.rayHooks do
                            if not v.silent then return v.fn(...) end
                        end
                    end
                end
                client.modules.rayCast.RayIgnoreNonCollideWithIgnoreList = rayHooks
            end
            rayIgnoreNonCollideHooks()
        end
        bulletCorrection()
        local function itemCameraCorrection()
            local onItemEquipped = client.modules.itemCamera.OnItemEquipped
            local onItemUnequipped = client.modules.itemCamera.OnItemUnequipped
            local scopebegin = client.modules.sniper.ScopeBegin
            local scopeend = client.modules.sniper.ScopeEnd
            local function hook(...)
                if global.ui_status.spam_drop_guns then return onItemUnequipped() end
                return onItemEquipped(...)
            end
            client.modules.itemCamera.OnItemEquipped = hook
            local function hook2(...)
                if global.ui_status.spam_drop_guns then return scopeend(...) end
                return scopebegin(...)
            end
            client.modules.sniper.ScopeBegin = hook2
        end
        itemCameraCorrection()
        local function fovCorrection()
            local function loop()
                local camera = workspace.CurrentCamera
                if not camera then return end

                camera.FieldOfView = global.ui_status.fov or 70
            end
            createloop(0, loop)
        end
        fovCorrection()
        local function arrestCorrection()
            local function ejectPlayer(vehicle)
                if not vehicle then return false end
                local shouldEject = global.registry.shouldEject
                shouldEject({
                    ShouldEject = true;
                    Part = vehicle;
                }, true)
            end
            local function arrestPlayer(target)
                if not target or not target.Name then return false end
                local shouldArrest = global.registry.shouldArrest
                if type(shouldArrest) ~= "function" then return false end
                shouldArrest({
                    PlayerName = target.Name
                })
            end
            local function tasePlayer()
                local hasItemEquipped = global.registry.hasItemEquipped
                if hasItemEquipped("Taser") then
                    local useTaser = global.registry.useTaser
                    if useTaser then useTaser() end
                end
            end
            local function equipTaser()
                local equip = global.registry.equip
                equip("Taser")
            end
            local function equipHandcuffs()
                local equip = global.registry.equip
                equip("Handcuffs")
            end
            local function taserLogic()
                local unequipAll = global.registry.unequipAll
                local bool = global.ui_status.allow_tase_target
                if bool then
                    local getEquippedItem = client.reg.getEquippedItem
                    local hasItemEquipped = global.registry.hasItemEquipped
                    if getEquippedItem and hasItemEquipped("Taser") then
                        equipTaser()
                        local canUseTaser = global.registry.canUseTaser(getEquippedItem)
                        if canUseTaser then
                            tasePlayer()
                        else
                            unequipAll()
                        end
                    elseif getEquippedItem and not hasItemEquipped("Taser") then
                        local unequipAll = global.registry.unequipAll
                        unequipAll()
                        if not client.reg.getEquippedItem then
                            local equip = global.registry.equip
                            equipTaser()
                            if hasItemEquipped("Taser") then
                                getEquippedItem = client.reg.getEquippedItem
                                if getEquippedItem then
                                    local canUseTaser = global.registry.canUseTaser(getEquippedItem)
                                    if canUseTaser then
                                        tasePlayer()
                                    else
                                        unequipAll()
                                    end
                                end
                            end
                        end
                    elseif not getEquippedItem then
                        equipTaser()
                        local unequipAll = global.registry.unequipAll
                        local getEquippedItem = client.reg.getEquippedItem
                        local hasItemEquipped = global.registry.hasItemEquipped
                        if getEquippedItem and hasItemEquipped("Taser") then
                            local canUseTaser = global.registry.canUseTaser(getEquippedItem)
                            if canUseTaser then
                                tasePlayer()
                            else
                                unequipAll()
                            end
                        end
                    end
                end
                local a = true
                task.delay(0.1, function()
                    a = false
                end)
                while true do
                    if not a then break end
                    task.wait()
                end
                unequipAll()
                task.delay(0.1, function()
                    a = true
                end)
                while true do
                    if a then break end
                    task.wait()
                end
                equipHandcuffs()
            end
            local function getVehicle(target)
                local getPlayerVehicle = global.registry.getPlayerVehicle
                local vehicle = getPlayerVehicle(target, true)
                if vehicle then return getPlayerVehicle(target, true) end
                return false
            end
            local function hasHandcuffs()
                local hasItemEquipped = global.registry.hasItemEquipped
                if hasItemEquipped("Handcuffs") then return true end
                return false
            end
            local last_time_trashtalked = tick()
            local isTrashtalking = false
            local function trashtalk()
                local talk_on_arrest = global.ui_status.talk_on_arrest
                if not talk_on_arrest then return false end
                if tick() - last_time_trashtalked < 1.5 then return false end
                last_time_trashtalked = tick()
                local phrase2 = {
                    [1] = {
                        "e prea usor cu crewbattler";
                        "crewbattler.lua > all";
                    };
                    [2] = {
                        "all dogs say reported but me BLESSED by crewbattler 😈";
                    };
                    [3] = {
                        "loool";
                        "that was so easy";
                        "why you so bad XD";
                    };
                    [4] = {
                        "ez noob";
                        "get better";
                    };
                    [5] = {
                        "l2p noob";
                        "please dont cry XD";
                    };
                    [6] = {
                        "hahahah";
                        "that was so easy";
                        "you're so bad";
                        "XD";
                    };
                }
                local event = textService.TextChannels.RBXGeneral
                if not isTrashtalking then
                    isTrashtalking = true
                    for i,v in next, phrase2[math.random(1, #phrase2)] do
                        event:SendAsync(v)
                        task.wait(1.5)
                    end
                    isTrashtalking = false
                end
            end
            local lastEquippedCuffs = tick()
            local lastUsedTaser = tick()
            local function aura()
                local getClosestPlayerWithNoHandcuffs = global.registry.getClosestPlayerWithNoHandcuffs
                local equip = global.registry.equip
                local unequipAll = global.registry.unequipAll
                local checkWallBeforePenetration = global.registry.checkWallBeforePenetration
                local hasInVehicleTag = global.registry.hasInVehicleTag
                local hasItemEquipped = global.registry.hasItemEquipped
                local function loop()
                    if player.Team ~= teams.Police then return false end
                    if global.ui_status.ignore_while_driving and client.reg.getLocalVehicle then return false end
                    local automatic_equip_handcuffs = global.ui_status.automatic_equip_handcuffs
                    local automatic_eject_player = global.ui_status.automatic_eject_player
                    local allow_tase_target = global.ui_status.allow_tase_target
                    local through_walls = global.ui_status.through_walls
                    local talk_on_arrest = global.ui_status.talk_on_arrest
                    local range = global.ui_status.range_arrestaura
                    local target = getClosestPlayerWithNoHandcuffs(range)
                    if target then
                        if tostring(target.Team) == "Prisoner" then return false end
                        if target.Character and target.Folder:FindFirstChild("Cuffed") then return false end
                        if not hasHandcuffs() and not automatic_equip_handcuffs then return false end
                        if not through_walls then
                            if not checkWallBeforePenetration(target) then return false end
                        end
                        if allow_tase_target then
                            if tick() - lastUsedTaser > 10 then
                                taserLogic()
                                lastUsedTaser = tick()
                            end
                        end
                        if hasHandcuffs() and automatic_equip_handcuffs then
                            if tick() - lastEquippedCuffs > 5 then unequipAll() end
                        end
                        while true do
                            if hasHandcuffs() then break end
                            if target and target.Folder:FindFirstChild("Cuffed") then break end
                            if automatic_equip_handcuffs then equipHandcuffs() end
                            task.wait()
                        end
                        local succees = false
                        if not succees then
                            if not target.Character then --@nu fa var-ul "char" pentru ca o sa se futa toata functiunea :D
                                return false
                            end
                            if hasInVehicleTag(target.Character) then
                                local targetVehicle = getVehicle(target)
                                if targetVehicle and automatic_eject_player then
                                    ejectPlayer(targetVehicle)
                                    task.delay(0.1, function()
                                        arrestPlayer(target)
                                    end)
                                end
                            end
                            if target and target.Folder:FindFirstChild("Cuffed") then succees = true end
                            if not succees then
                                if hasInVehicleTag(target.Character) then
                                    if targetVehicle and automatic_eject_player then ejectPlayer(targetVehicle) end
                                end
                                if hasHandcuffs() and automatic_equip_handcuffs then
                                    if tick() - lastEquippedCuffs > 2 then
                                        lastEquippedCuffs = tick()
                                        unequipAll()
                                        task.delay(0.1, function()
                                            equipHandcuffs()
                                        end)
                                        while true do
                                            if hasHandcuffs() then break end
                                            task.wait()
                                        end
                                    end
                                end
                                local attempts = 0
                                while true do
                                    if not global.ui_status.master_switch_arrestaura then break end
                                    if not hasHandcuffs() then break end
                                    if not target then break end
                                    if target and not target.Character then break end
                                    if target and target.Folder:FindFirstChild("Cuffed") then
                                        succees = true
                                        break
                                    end
                                    if attempts == 3 then
                                        if target and target.Folder:FindFirstChild("Cuffed") then succees = true  end
                                        attempts = 0
                                        break
                                    end
                                    arrestPlayer(target)
                                    attempts += 1
                                    task.wait(0.6)
                                end
                            end
                        end
                        if succees then
                            if talk_on_arrest then
                                if target and target.Folder:FindFirstChild("Cuffed") then trashtalk() end
                            end
                        end
                    end
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("master_switch_arrestaura", 0, false, function(val)
                        if val then
                            loopf = createloop(0, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "master_switch_arrestaura")
            end
            aura()
        end
        arrestCorrection()
        local function ejectCorrection()
            local function ejectPlayer(vehicle)
                if not vehicle then return false end
                local shouldEject = global.registry.shouldEject
                shouldEject({
                    ShouldEject = true;
                    Part = vehicle;
                }, true)
            end
            local hasInVehicleTag = global.registry.hasInVehicleTag
            local function loop()
                if tostring(player.Team) ~= "Police" then return false end
                local bool = global.ui_status.master_switch_eject_aura
                if bool then
                    local range = global.ui_status.range_ejectaura
                    local target = global.registry.getClosestPlayerWithNoHandcuffs(range)
                    if target then
                        local char = target.Character
                        if char then
                            local inVehicle = hasInVehicleTag(char)
                            if inVehicle then
                                local getPlayerVehicle = global.registry.getPlayerVehicle(target, true)
                                if getPlayerVehicle then ejectPlayer(getPlayerVehicle) end
                            end
                        end
                    end
                end
            end
            createloop(0, loop)
        end
        ejectCorrection()
        local function breakoutCorrection()
            local function breakoutPlayer(player)
                local shouldBreakout = global.registry.shouldBreakout
                shouldBreakout({
                    ShouldBreakout = true;
                    PlayerName = player.Name;
                }, true)
            end
            local getClosestPlayerForBreakouts = global.registry.getClosestPlayerForBreakouts
            local lastTimeBreakout = tick()
            local function loop()
                if tick() - lastTimeBreakout < 20 then return false end
                local bool = global.ui_status.master_switch_breakout_aura
                if bool then
                    local range = global.ui_status.range_breakoutaura
                    local target = getClosestPlayerForBreakouts(range)
                    if target and target.Folder:FindFirstChild("Cuffed") then
                        lastTimeBreakout = tick()
                        breakoutPlayer(target)
                    end
                end
            end
            createloop(0, loop)
        end
        breakoutCorrection()
        local function pickpocketCorrection()
            local function pickpocketPlayer(player)
                local shouldPickpocket = global.registry.shouldPickpocket
                shouldPickpocket({
                    ShouldPickpocket = true;
                    PlayerName = player.Name;
                }, true)
            end
            local getClosestPlayerWithTagPolice = global.registry.getClosestPlayerWithTagPolice
            local function loop()
                local bool = global.ui_status.pickpocketaura
                if tostring(player.Team) == "Police" then return false end
                if not bool then return false end
                local range = global.ui_status.range_pickpocketaura
                local target = getClosestPlayerWithTagPolice(range)
                if target then pickpocketPlayer(target) end
            end
            createloop(1, loop)
        end
        pickpocketCorrection()
        local function dropCorrection()
            local function spam_drop_guns()
                local isSpamming = false
                local neverDropItems = global.registry.neverDropItems()
                local equipOwnedItem = global.registry.equipOwnedItem
                local equip = global.registry.equip
                local dropGun = global.registry.dropGun
                local isProjectile = global.registry.isProjectile
                local function loop()
                    local bool = global.ui_status.spam_drop_guns
                    if bool and not isSpamming then
                        isSpamming = true
                        for i,v in next, client.reg.resolveOwnedItems do
                            if not isProjectile(v) then equipOwnedItem(v) end
                        end
                        for i,v in next, client.reg.resolveEquippedItems do
                            if bool and not table.find(neverDropItems, v) then
                                while true do
                                    if client.reg.getEquippedItem then
                                        dropGun()
                                        break
                                    end
                                    equip(v)
                                    task.wait()
                                end
                                while true do
                                    if not client.reg.getEquippedItem then break end
                                    dropGun()
                                    task.wait()
                                end
                            end
                        end
                        isSpamming = false
                    end
                end
                createloop(0.1, loop)
            end
            spam_drop_guns()
        end
        dropCorrection()
        local function chatCorrection()
            local function color3_to_hex(color) --@ puuuuuup ;3 https://devforum.roblox.com/t/converting-a-color-to-a-hex-string/793018/3
                return string.format("#%02X%02X%02X", color.R * 0xFF, color.G * 0xFF, color.B * 0xFF)
            end
            local function onChat(player, message)
                if not global.ui_status.chatspy then return false end
                local color = player.Team.TeamColor.Color
                message = ("<font color='#F5CD30'>CHAT SPY: </font><font color='%s'>%s</font>: %s"):format(color3_to_hex(color), player.DisplayName, message)
                textService.TextChannels["RBXSystem"]:DisplaySystemMessage(message)
            end
            task.spawn(function()
                for i,v in next, client.players do
                    v.Chatted:connect(function(msg)
                        onChat(v, msg)
                    end)
                end
            end)
            local function fn(player)
                player.Chatted:connect(function(msg)
                    onChat(player, msg)
                end)
            end
            table.insert(client.run_on_player_connect, {
                _fn = fn
            })
        end
        chatCorrection()
        local function turretCorrection()
            local function home()
                local module = client.modules.playerUtils.getRootPart
                local function hook(...)
                    local bool = global.ui_status.disable_home_turrets
                    if bool then
                        if string.find(debug.traceback(), "Fabricate.Turret") then return task.wait(9e9) end
                    end
                    return module(...)
                end
                client.modules.playerUtils.getRootPart = hook
            end
            home()
            local function military()
                local _fire = client.modules.militaryTurret._fire
                local function hook(x, y)
                    local bool = global.ui_status.disable_military_turrets
                    local turretmilitary = global.registry.turretmilitary
                    if bool then return task.wait(9e9) end
                    return _fire(x, y)
                end
                client.modules.militaryTurret._fire = hook
            end
            military()
            local function mansionCorrection()
                local function getMansionStatus()
                    local getRobberyStatus = global.registry.getRobberyStatus
                    local status = getRobberyStatus("MANSION")
                    if status == "OPENED" then return true end
                    if status == "STARTED" then return 0 end
                    return false
                end
                local function autoentry()
                    local mansionRobbery = workspace.MansionRobbery
                    local function hasMansioninvite() return global.registry.hasMansioninvite() end
                    local getPartsInRegion = global.registry.getPartsInRegion
                    local function isInMansion()
                        local char = client.playerCharacter
                        if char then
                            local primarypart = char.PrimaryPart
                            if primarypart then
                                local tbl = {
                                    x = {
                                        max = 3225;
                                        min = 3103;
                                    };
                                    y = {
                                        max = 104;
                                        min = 56;
                                    };
                                    z = {
                                        max = -4520;
                                        min = -4691;
                                    };
                                }
                                local pos = {
                                    x = primarypart.Position.x;
                                    y = primarypart.Position.y;
                                    z = primarypart.Position.z;
                                }
                                local getPartsInRegion = getPartsInRegion(pos.x, pos.y, pos.z, tbl.x.min, tbl.y.min, tbl.z.min, tbl.x.max, tbl.y.max, tbl.z.max)
                                if getPartsInRegion then return true end
                            end
                        end
                        return false
                    end
                    local utils = client.modules.mansionRobberyUtils
                    local function getNumPlayersInElevator() return utils.getNumPlayersInElevator(mansionRobbery) end
                    local function isPlayerInElevator(player) return utils.isPlayerInElevator(mansionRobbery, player) end
                    local function loop()
                        local bool = global.ui_status.automatic_elevator_entry
                        if bool then
                            if not global.ui_status.allow_on_police_team and tostring(player.Team) == "Police" then return false end
                            if not hasMansioninvite() then return false end
                            local char = client.playerCharacter
                            if not char then return false end
                            local primarypart = char.PrimaryPart
                            if not primarypart then return false end
                            if not isInMansion() then return false end
                            local status = getMansionStatus()
                            if status then
                                local getNumPlayersInElevator = getNumPlayersInElevator()
                                if getNumPlayersInElevator < 3 then
                                    local isPlayerInElevator = isPlayerInElevator(player)
                                    if not isPlayerInElevator then
                                        firetouchinterest(mansionRobbery.Lobby.EntranceElevator.TouchToEnter, primarypart, 0)
                                        firetouchinterest(mansionRobbery.Lobby.EntranceElevator.TouchToEnter, primarypart, 1)
                                    end
                                end
                            end
                        end
                    end
                    createloop(0, loop)
                end
                autoentry()
                local function noTraps(bool)
                    local function laserTraps(bool)
                        local mansion = workspace:FindFirstChild("MansionRobbery")
                        local inRobbery = mansion and mansion:FindFirstChild("InRobberyFolder")
                        local laserTrapsFolder = mansion and mansion:FindFirstChild("LaserTraps")
                        if not inRobbery or not laserTrapsFolder then return false end
                        if inRobbery:FindFirstChild(player.UserId) then
                            for i,v in next, laserTrapsFolder:GetDescendants() do
                                if v:IsA("BasePart") and v.CanTouch ~= not bool then v.CanTouch = not bool end
                            end
                        end
                    end
                    local function loop()
                        local bool = global.ui_status.disable_traps
                        laserTraps(bool)
                    end
                    createloop(0, loop)
                end
                noTraps()
                local function noRagdoll()
                    local module = client.modules.falling.StartRagdolling
                    local function hook(...)
                        local bool = global.ui_status.anti_boss_ragdoll
                        if string.find(debug.traceback(), "BossNPCBinder") then return not bool end
                        return module(...)
                    end
                    client.modules.falling.StartRagdolling = hook
                end
                noRagdoll()
                local function noDamage()
                    local playLaserSweepVisual = client.modules.bossNpcBinder._constructor.PlayLaserSweepVisual
                    local playArmGrab = client.modules.bossNpcBinder._constructor.PlayArmGrab
                    local function hookLaserSweep(...)
                        local bool = global.ui_status.anti_boss_attack
                        if bool then return false end
                        return playLaserSweepVisual(...)
                    end
                    local function hookArmGrab(...)
                        local bool = global.ui_status.anti_boss_attack
                        if bool then return false end
                        return playArmGrab(...)
                    end
                    client.modules.bossNpcBinder._constructor.PlayLaserSweepVisual = hookLaserSweep
                    client.modules.bossNpcBinder._constructor.PlayArmGrab = hookArmGrab
                end
                noDamage()
            end
            mansionCorrection()
            local function cargoShip()
                local turret = client.modules.turret
                local shoot = turret.ShootRocket
                local function hook(...)
                    if global.ui_status.disable_cargoship_turrets then
                        if string.find(debug.traceback(), "CargoShip") then
                            print("cargo ship")
                            return task.wait(9e9)
                        end
                    end
                    return shoot(...)
                end
                client.modules.turret.ShootRocket = hook
            end
            cargoShip()
        end
        turretCorrection()
        local function doorCorrection()
            local function secretBases()
                local function getDoors(bool)
                    local secretBasePolice = workspace.SecretBasePolice:GetDescendants()
                    local secretBaseCriminal = workspace.SecretBaseCriminal:GetDescendants()
                    
                    for i,v in next, secretBasePolice do
                        if v:IsA("Part") then
                            v.CanCollide = not bool
                            if bool then
                                v.Transparency = 1
                            else
                                v.Transparency = 0
                            end
                        end
                    end
                    for i,v in next, secretBaseCriminal do
                        if v:IsA("Part") and v.Name ~= "Region" then
                            v.CanCollide = not bool
                            if bool then
                                v.Transparency = 1
                            else
                                v.Transparency = 0
                            end
                        end
                    end
                    
                end
                local cache
                local function tagService()
                    cache = client.tags.new("secretbases", 0, false, function(val)
                        getDoors(val)
                    end)
                end
                tagService()
                local function onWorkspaceSpawnRun(obj)
                    if obj.Name == "SecretBasePolice" then getDoors(cache.obj.Value) end
                    if obj.Name == "SecretBaseCriminal" then getDoors(cache.obj.Value) end
                    if obj.Name == "PoliceSecretBase2" then getDoors(cache.obj.Value) end
                end
                table.insert(client.onWorkspaceSpawnRun, {
                    _fn = onWorkspaceSpawnRun
                })
                global.syncTagValue(cache, "open_secretbases")
            end
            secretBases()
            local function casino()
                local function loop()
                    local bool = global.ui_status.auto_open_door
                    if bool then
                        local getCasinoDoor = global.registry.getCasinoDoor()
                        if getCasinoDoor then
                            local getKeycode = global.registry.getKeycode()
                            if getKeycode ~= "" then
                                local pad = collectionservice:GetTagged("CasinoKeypadPrompt")[1]
                                local casinoKeypadSubmit = pad and pad:FindFirstChild("CasinoKeypadSubmit")
                                if casinoKeypadSubmit then
                                    casinoKeypadSubmit:FireServer(getKeycode)
                                    casinoKeypadSubmit:FireServer(getKeycode:reverse())
                                end
                            end
                        end
                    end
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("auto_open_door", 0, false, function(val)
                        if val then
                            loopf = createloop(1, loop)
                        else
                            if loopf then
                                loopf:disconnect()
                                loopf = nil
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "auto_open_door")
            end
            casino()
            local function loop()
                local bool = global.ui_status.master_switch_open_doors
                if not bool then return false end
                local success, err = pcall(function()
                    for i,v in next, global.registry.doors do v() end
                end)
            end
            createloop(2.5, loop)
        end
        doorCorrection()
        local function markerCorrection()
            local function playerMarkers()
                local teams = {}
                local function addTeam(team) table.insert(teams, tostring(team)) end
                local function removeTeam(team)
                    for num, name in next, teams do
                        if name == team then table.remove(teams, num) end
                    end
                end
                local function isTeamAllowed(team)
                    if table.find(teams, tostring(team)) then return true end
                    return false
                end
                local function teamCheck()
                    local function loop()
                        local allow_police_marker = global.ui_status.allow_police_marker
                        local allow_criminal_marker = global.ui_status.allow_criminal_marker
                        local allow_prisoner_marker = global.ui_status.allow_prisoner_marker
                        local function getTeams()
                            local findPrisoner = table.find(teams, "Prisoner")
                            local findPolice = table.find(teams, "Police")
                            local findCriminal = table.find(teams, "Criminal")
                            if allow_prisoner_marker and not findPrisoner then
                                addTeam("Prisoner")
                            elseif not allow_prisoner_marker and findPrisoner then removeTeam("Prisoner") end
                            if allow_criminal_marker and not findCriminal then
                                addTeam("Criminal")
                            elseif not allow_criminal_marker and findCriminal then removeTeam("Criminal") end
                            if allow_police_marker and not findPolice then
                                addTeam("Police")
                            elseif not allow_police_marker and findPolice then removeTeam("Police") end
                        end
                        getTeams()
                    end
                    createloop(0, loop)
                end
                teamCheck()
                local function playerMarkerLogic()
                    local doesMarkerExist = global.registry.doesMarkerExist
                    local constructMarker = global.registry.constructMarker
                    local destructMarker = global.registry.destructMarker
                    local setColor = global.registry.setColor
                    local markerColors = global.registry.markerColors
                    local function destructMarkers()
                        for i,v in next, client.players do
                            if doesMarkerExist(v) then destructMarker(v) end
                        end
                        return true
                    end
                    task.spawn(destructMarkers)
                    local bounties = {}
                    local function loop()
                        local master_switch = global.ui_status.master_switch_marker
                        if not master_switch then return destructMarkers() end
                        local mark_forced_target = global.ui_status.mark_forced_target
                        local mark_bounty_criminals = global.ui_status.mark_bounty_criminals
                        local getPlayersWithBounty = global.registry.getPlayersWithBounty()
                        local force_target = global.aimbot.force_target
                        for i,v in next, client.players do
                            if mark_forced_target and force_target and force_target == v then
                                local char = v.Character
                                if char then
                                    local hum = char:FindFirstChild("Humanoid")
                                    if hum then
                                        if hum.Health < 1 then
                                            if doesMarkerExist(v) then destructMarker(v) end
                                        else    
                                            if not doesMarkerExist(v) then
                                                constructMarker(v)
                                                setColor(v, markerColors.Target)
                                            end
                                        end
                                    end
                                end
                                continue
                            end
                            if mark_forced_target then
                                if force_target == v then
                                    if doesMarkerExist(v) then
                                        destructMarker(v)
                                        continue
                                    end
                                end
                            end
                            if not table.find(getPlayersWithBounty, v) or not mark_bounty_criminals then
                                if table.find(bounties, v) and mark_bounty_criminals then
                                    if doesMarkerExist(v) then destructMarker(v) end
                                    for _, bounty in next, bounties do
                                        if bounty == v then table.remove(bounties, _) end
                                    end
                                    return true
                                end
                                if mark_forced_target then
                                    if force_target == v then
                                        if doesMarkerExist(v) then
                                            destructMarker(v)
                                            continue
                                        end
                                    end
                                end
                                if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                                    local team, teamString = v.Team, tostring(v.Team)
                                    local isTeamAllowed = isTeamAllowed(team)
                                    local color
                                    if isTeamAllowed then
                                        if markerColors[teamString] then color = markerColors[teamString] end
                                        if not doesMarkerExist(v) then
                                            if not color then return false end
                                            constructMarker(v)
                                            setColor(v, color)
                                        end
                                    else
                                        local doesMarkerExist = doesMarkerExist(v)
                                        if master_switch and not doesMarkerExist then
                                            if teamString == tostring(player.Team) then
                                                color = markerColors[teamString]
                                                if color then
                                                    constructMarker(v)
                                                    setColor(v, color)
                                                    return true
                                                end
                                                return false
                                            end
                                        end
                                        if doesMarkerExist then
                                            if teamString ~= tostring(player.Team) then destructMarker(v) end
                                        end
                                    end
                                end
                                if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health == 0 and doesMarkerExist(v) then destructMarker(v) end
                                if v.Character and v.Folder:FindFirstChild("Cuffed") and doesMarkerExist(v) then destructMarker(v) end
                            elseif table.find(getPlayersWithBounty, v) then
                                if mark_bounty_criminals then
                                    if mark_forced_target then
                                        if force_target == v then
                                            if doesMarkerExist(v) then
                                                destructMarker(v)
                                                continue
                                            end
                                        end
                                    end
                                    if not table.find(bounties, v) then
                                        table.insert(bounties, v)
                                        if doesMarkerExist(v) then destructMarker(v) end
                                        return true
                                    end
                                    if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                                        local team, teamString = v.Team, tostring(v.Team)
                                        local isTeamAllowed = isTeamAllowed(team)
                                        local color
                                        if isTeamAllowed then
                                            if markerColors.Bounty then color = markerColors.Bounty end
                                            if not doesMarkerExist(v) then
                                                if not color then return false end
                                                constructMarker(v)
                                                setColor(v, color)
                                            end
                                        else
                                            local doesMarkerExist = doesMarkerExist(v)
                                            if master_switch and not doesMarkerExist then
                                                if teamString == tostring(player.Team) then
                                                    color = markerColors.Bounty
                                                    if color then
                                                        constructMarker(v)
                                                        setColor(v, color)
                                                        return true
                                                    end
                                                    return false
                                                end
                                            end
                                            if doesMarkerExist then
                                                if teamString ~= tostring(player.Team) then destructMarker(v) end
                                            end
                                        end
                                    end
                                    if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health == 0 and doesMarkerExist(v) then destructMarker(v) end
                                    if v.Character and v.Folder:FindFirstChild("Cuffed") then destructMarker(v) end
                                end
                            end
                        end
                    end
                    local loopf
                    local cache
                    local function tagService()
                        cache = client.tags.new("markers", 0, false, function(val)
                            if val then
                                loopf = createloop(0, loop)
                            else
                                if loopf then
                                    destructMarkers()
                                    loopf:disconnect()
                                    loopf = nil
                                else
                                    warn("no loopf")
                                end
                            end
                        end)
                    end
                    tagService()
                    global.syncTagValue(cache, "master_switch_marker")
                end
                playerMarkerLogic()
            end
            playerMarkers()
            local function airdropMarkers()
                local image = getsynasset("Radiance/resource/airdrop.png")
                if not image then error("error while trying to get synapse asset `airdrop.png`") end
                local markerColors = global.registry.markerColors
                local worldmarker = client.modules.worldMarker
                local system = client.modules.system
                local group = client.modules.group
                local airdrop = {}
                local function markerCreate(part)
                    local function makeAirdropGroups(drop, group)
                        table.insert(airdrop, {
                            part = part;
                            drop = drop;
                            group = group;
                        })
                    end
                    local function makeMarker()
                        local group = group.new()
                        system.addGroup(group)
                        group:SetEnabled(true)
                        local new = worldmarker.new()
                        new:SetAdornee(part)
                        new:SetScreenGui(system.gui)
                        new:SetSizes({8, {24, 0}, {math.huge, 8}})
                        local function createImageLabel()
                            local imagelabel = Instance.new("ImageLabel")
                            imagelabel.BorderSizePixel = 0
                            imagelabel.BackgroundTransparency = 1
                            imagelabel.Size = UDim2.new(1.2, 0, 1.2, 0)
                            imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                            imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                            imagelabel.ZIndex = 3
                            imagelabel.Parent = new.FrameInner
                            imagelabel.Image = image
                        end
                        createImageLabel()
                        local function walls()
                            local walls = part.Parent:FindFirstChild("Walls")
                            if not walls then
                                new.FrameInner.ImageColor3 = markerColors.Airdrop
                                return
                            end
                            local wall = walls:FindFirstChild("Wall")
                            if not wall then
                                new.FrameInner.ImageColor3 = markerColors.Airdrop
                                return
                            end
                            new.FrameInner.ImageColor3 = wall.Color
                        end
                        walls()
                        group:Add(new)
                        makeAirdropGroups(new, group)
                    end
                    makeMarker()
                end
                local function markerRemove(root)
                    if not root then
                        for i,v in next, airdrop do
                            if not v.part:IsDescendantOf(workspace) then
                                v.group:Remove(v.drop)
                                v.drop:Destroy()
                                v.drop = nil
                                table.remove(airdrop, i)
                                return true
                            end
                            if v.part ~= nil then
                                if v.drop and v.group then
                                    v.group:Remove(v.drop)
                                    v.drop:Destroy()
                                    v.drop = nil
                                end
                                table.remove(airdrop, i)
                            end
                        end
                        return false
                    end
                    for i,v in next, airdrop do
                        if not v.part:IsDescendantOf(workspace) then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(airdrop, i)
                            return true
                        end
                        if v.part == root then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(airdrop, i)
                        end
                    end
                end
                local function doesMarkerExist(root)
                    local result = false
                    if not root then
                        for i,v in next, airdrop do result = v.drop ~= nil end
                        return result
                    end
                    for i,v in next, airdrop do
                        if v.part == root then result = v.drop ~= nil end
                    end
                    return result
                end
                global.airdrops_on_map = {}
                local function onChildAdded(part)
                    local bool = global.ui_status.master_switch_marker
                    if not bool then return false end
                    local allow_airdrop_marker = global.ui_status.allow_airdrop_marker
                    if not allow_airdrop_marker then return false end
                    if part.Name == "Drop" then
                        table.insert(global.airdrops_on_map, part.PrimaryPart)
                        local root = part:FindFirstChild("Root")
                        if root then
                            if not doesMarkerExist(root) then markerCreate(root) end
                        end
                    end
                end
                local function onChildRemoved(part)
                    if part.Name == "Drop" then
                        task.spawn(function()
                            for i,v in next, global.airdrops_on_map do
                                if not v:IsDescendantOf(workspace) then -- @ ar trebui sa stearga toate airdropurile din table care nu mai sunt in workspace
                                    table.remove(global.airdrops_on_map, i)
                                    break
                                end
                            end
                        end)
                        local root = part:FindFirstChild("Root")
                        if root then
                            if doesMarkerExist(root) then markerRemove(root)     end
                        end
                    end
                end
                table.insert(client.onWorkspaceSpawnRun, {
                    _fn = onChildAdded
                })
                table.insert(client.onWorkspaceRemovedRun, {
                    _fn = onChildRemoved
                })
                local function loop()
                    local master_switch = global.ui_status.master_switch_marker
                    if not master_switch then
                        if doesMarkerExist() then markerRemove() end
                        return false
                    end
                    local bool = global.ui_status.allow_airdrop_marker
                    if bool then
                        for i,v in next, workspaceChildren do
                            if v.Name == "Drop" then
                                if v:FindFirstChild("Root") then
                                    if not doesMarkerExist(v.Root) then markerCreate(v.Root) end
                                else
                                    if doesMarkerExist() then markerRemove() end
                                end
                            end
                        end
                    else
                        if doesMarkerExist() then markerRemove() end
                    end
                end
                local cache
                local loopf
                local function tagService()
                    cache = client.tags.new("markersairdrop", 0, false, function(val)
                        if val then
                            loopf = createloop(0.5, loop)
                        else
                            if loopf then
                                if doesMarkerExist() then markerRemove() end
                                loopf:disconnect()
                                loopf = nil
                            else
                                warn("no loopf")
                            end
                        end
                    end)
                end
                tagService()
                createloop(0.5, loop)
            end
            airdropMarkers()
            local function footballMarker()
                local image = getsynasset("Radiance/resource/football.png")
                if not image then error("error while trying to get synapse asset `football.png`") end
                local markerColors = global.registry.markerColors
                local worldmarker = client.modules.worldMarker
                local system = client.modules.system
                local group = client.modules.group
                local football = {}
                local function markerCreate(part)
                    local function makeFootballGroups(drop, group)
                        table.insert(football, {
                            part = part;
                            drop = drop;
                            group = group;
                        })
                    end
                    local function makeMarker()
                        local group = group.new()
                        system.addGroup(group)
                        group:SetEnabled(true)
                        local new = worldmarker.new()
                        new:SetAdornee(part)
                        new:SetScreenGui(system.gui)
                        new:SetSizes({8, {24, 0}, {math.huge, 8}})
                        local function createImageLabel()
                            local imagelabel = Instance.new("ImageLabel")
                            imagelabel.BorderSizePixel = 0
                            imagelabel.BackgroundTransparency = 1
                            imagelabel.Size = UDim2.new(0.7, 0, 0.7, 0)
                            imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                            imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                            imagelabel.ZIndex = 3
                            imagelabel.Parent = new.FrameInner
                            imagelabel.Image = image
                        end
                        createImageLabel()
                        new.FrameInner.ImageColor3 = markerColors.Football
                        group:Add(new)
                        makeFootballGroups(new, group)
                    end
                    makeMarker()
                end
                local function markerRemove(root)
                    if not root then
                        for i,v in next, football do
                            if not v.part:IsDescendantOf(workspace) then
                                v.group:Remove(v.drop)
                                v.drop:Destroy()
                                v.drop = nil
                                table.remove(football, i)
                                return true
                            end
                            if v.part ~= nil then
                                if v.drop and v.group then
                                    v.group:Remove(v.drop)
                                    v.drop:Destroy()
                                    v.drop = nil
                                end
                                table.remove(football, i)
                            end
                        end
                        return false
                    end
                    for i,v in next, football do
                        if not v.part:IsDescendantOf(workspace) then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(football, i)
                            return true
                        end
                        if v.part == root then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(football, i)
                        end
                    end
                end
                local function doesMarkerExist(root)
                    local result = false
                    if not root then
                        for i,v in next, football do result = v.drop ~= nil end
                        return result
                    end
                    for i,v in next, football do
                        if v.part == root then result = v.drop ~= nil end
                    end
                    return result
                end
                local function onChildAdded(part)
                    local bool = global.ui_status.master_switch_marker
                    if not bool then return false end
                    local allow_football_marker = global.ui_status.allow_football_marker
                    if not allow_football_marker then return false end
                    if part.Name == "SoccerBall" then
                        if not doesMarkerExist(part) then markerCreate(part) end
                    end
                end
                local function onChildRemoved(part)
                    if part.Name == "SoccerBall" then
                        if doesMarkerExist(part) then markerRemove(part) end
                    end
                end
                table.insert(client.onWorkspaceSpawnRun, {
                    _fn = onChildAdded
                })
                table.insert(client.onWorkspaceRemovedRun, {
                    _fn = onChildRemoved
                })
                local function loop()
                    local master_switch = global.ui_status.master_switch_marker
                    if not master_switch then
                        if doesMarkerExist() then markerRemove() end
                        return false
                    end
                    local bool = global.ui_status.allow_football_marker
                    if bool then
                        local soccerBall = workspace:FindFirstChild("SoccerBall")
                        if soccerBall then
                            if not doesMarkerExist(soccerBall) then markerCreate(soccerBall) end
                        end
                    else
                        if doesMarkerExist() then markerRemove() end
                    end
                end
                createloop(0.5, loop)
            end
            footballMarker()
            local function npcsMarker()
                local image = getsynasset("Radiance/resource/robot.png")
                if not image then error("error while trying to get synapse asset `robot.png`") end
                local markerColors = global.registry.markerColors
                local worldmarker = client.modules.worldMarker
                local system = client.modules.system
                local group = client.modules.group
                local npcs = {}
                local function markerCreate(part)
                    local function makeNPCsGroups(drop, group)
                        table.insert(npcs, {
                            part = part;
                            drop = drop;
                            group = group;
                        })
                    end
                    local function makeMarker()
                        local group = group.new()
                        system.addGroup(group)
                        group:SetEnabled(true)
                        local new = worldmarker.new()
                        new:SetAdornee(part)
                        new:SetScreenGui(system.gui)
                        new:SetSizes({8, {24, 0}, {math.huge, 8}})
                        local function createImageLabel()
                            local imagelabel = Instance.new("ImageLabel")
                            imagelabel.BorderSizePixel = 0
                            imagelabel.BackgroundTransparency = 1
                            imagelabel.Size = UDim2.new(0.7, 0, 0.7, 0)
                            imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                            imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                            imagelabel.ZIndex = 3
                            imagelabel.Parent = new.FrameInner
                            imagelabel.Image = image
                        end
                        createImageLabel()
                        new.FrameInner.ImageColor3 = markerColors.NPCs
                        group:Add(new)
                        makeNPCsGroups(new, group)
                    end
                    makeMarker()
                end
                local function markerRemove(root)
                    if not root then
                        for i,v in next, npcs do
                            if not v.part:IsDescendantOf(workspace) then
                                v.group:Remove(v.drop)
                                v.drop:Destroy()
                                v.drop = nil
                                table.remove(npcs, i)
                                return true
                            end
                            if v.part ~= nil then
                                if v.drop and v.group then
                                    v.group:Remove(v.drop)
                                    v.drop:Destroy()
                                    v.drop = nil
                                end
                                table.remove(npcs, i)
                            end
                        end
                        return false
                    end
                    for i,v in next, npcs do
                        if not v.part:IsDescendantOf(workspace) then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(npcs, i)
                            return true
                        end
                        if v.part == root then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(npcs, i)
                        end
                    end
                end
                local function doesMarkerExist(root)
                    local result = false
                    if not root then
                        for i,v in next, npcs do result = v.drop ~= nil end
                        return result
                    end
                    for i,v in next, npcs do
                        if v.part == root then result = v.drop ~= nil end
                    end
                    return result
                end
                local function onChildAdded(part)
                    local bool = global.ui_status.master_switch_marker
                    if not bool then return false end
                    local allow_npcs_marker = global.ui_status.allow_npcs_marker
                    if not allow_npcs_marker then return false end
                    if part and part.Value and part.Value.HumanoidRootPart then
                        if not doesMarkerExist(part.Value.HumanoidRootPart) then markerCreate(part.Value.HumanoidRootPart) end
                    end
                end
                local function onChildRemoved(part)
                    if part and part.Value and part.Value.HumanoidRootPart then
                        if doesMarkerExist(part.Value.HumanoidRootPart) then markerRemove(part.Value.HumanoidRootPart) end
                    end
                end
                workspace.GuardNPCPlayers.ChildAdded:connect(onChildAdded)
                workspace.GuardNPCPlayers.ChildRemoved:connect(onChildRemoved)
                local function onChildAdded2(part)
                    local bool = global.ui_status.master_switch_marker
                    if not bool then return false end
                    local allow_npcs_marker = global.ui_status.allow_npcs_marker
                    if not allow_npcs_marker then return false end
                    if not doesMarkerExist(part.HumanoidRootPart) then markerCreate(part.HumanoidRootPart) end
                end
                local function onChildRemoved2(part)
                    if doesMarkerExist(part.HumanoidRootPart) then markerRemove(part.HumanoidRootPart) end
                end
                workspace.MansionRobbery.GuardsFolder.ChildAdded:connect(onChildAdded2)
                workspace.MansionRobbery.GuardsFolder.ChildRemoved:connect(onChildRemoved2)
                local function destroyOnNoNDescendant()
                    for i,v in next, npcs do
                        if not v.part:IsDescendantOf(workspace) then
                            v.group:Remove(v.drop)
                            v.drop:Destroy()
                            v.drop = nil
                            table.remove(npcs, i)
                        end
                        task.wait(1)
                    end
                end
                local function loop()
                    local master_switch = global.ui_status.master_switch_marker
                    if not master_switch then
                        if doesMarkerExist() then destroyOnNoNDescendant() end
                        return false
                    end
                    local bool = global.ui_status.allow_npcs_marker
                    if bool then
                        if #workspace.MansionRobbery.GuardsFolder:GetChildren() > 0 then
                            for i,v in next, workspace.MansionRobbery.GuardsFolder:GetChildren() do
                                local root = v:FindFirstChild("HumanoidRootPart")
                                if root then
                                    if not doesMarkerExist(root) then markerCreate(root) end
                                end
                            end
                        end
                        if #workspace.GuardNPCPlayers:GetChildren() > 0 then
                            for i,v in next, workspace.GuardNPCPlayers:GetChildren() do
                                if v and v.Value then
                                    local root = v.Value:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        if not doesMarkerExist(root) then markerCreate(root) end
                                    end
                                end
                            end
                        end
                    else
                        if doesMarkerExist() then markerRemove() end
                    end
                end
                local loopf
                local cache
                local function tagService()
                    cache = client.tags.new("markersnpcs", 0, false, function(val)
                        if val then
                            loopf = createloop(0, loop)
                        else
                            if loopf then
                                markerRemove()
                                loopf:disconnect()
                                loopf = nil
                            else
                                warn("no loopf")
                            end
                        end
                    end)
                end
                tagService()
                global.syncTagValue(cache, "allow_npcs_marker")
            end
            npcsMarker()
        end
        markerCorrection()
        local function crewbattlerPlayerEsp()
            local Workspace, RunService, Players, CoreGui, Lighting = CloneRef(game:GetService("Workspace")), runservice, players, coregui, lighting

            local ESP = {
                Enabled = false,
                TeamCheck = true,
                MaxDistance = 5000,
                FontSize = 11,
                FadeOut = {
                    OnDistance = false,
                    OnDeath = true,
                    OnLeave = true,
                },
                Options = {
                    Teamcheck = true, TeamcheckRGB = Color3.fromRGB(0, 255, 0),
                    Friendcheck = true, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
                    Highlight = false, HighlightRGB = Color3.fromRGB(255, 0, 0),
                },
                Drawing = {
                    Chams = {
                        Enabled = false,
                        Thermal = true,
                        FillRGB = Color3.fromRGB(119, 120, 255),
                        Fill_Transparency = 100,
                        OutlineRGB = Color3.fromRGB(119, 120, 255),
                        Outline_Transparency = 100,
                        VisibleCheck = false,
                    },
                    Names = {
                        Enabled = true,
                        RGB = Color3.fromRGB(255, 255, 255),
                        UseDisplayName = false,
                    },
                    Flags = {
                        Enabled = true,
                    },
                    Distances = {
                        Enabled = true,
                        Position = "Bottom", --Bottom, Text
                        RGB = Color3.fromRGB(255, 255, 255),
                    },
                    Weapons = {
                        Enabled = false, WeaponTextRGB = Color3.fromRGB(119, 120, 255),
                        Outlined = false,
                        Gradient = false,
                        GradientRGB1 = Color3.fromRGB(255, 255, 255), GradientRGB2 = Color3.fromRGB(119, 120, 255),
                    },
                    Healthbar = {
                        Enabled = true,
                        HealthText = true, Lerp = false, HealthTextRGB = Color3.fromRGB(119, 120, 255),
                        Width = 2.5,
                        Gradient = true, GradientRGB1 = Color3.fromRGB(200, 0, 0), GradientRGB2 = Color3.fromRGB(60, 60, 125), GradientRGB3 = Color3.fromRGB(119, 120, 255),
                    },
                    Boxes = {
                        Animate = true,
                        RotationSpeed = 300,
                        Gradient = true, GradientRGB1 = Color3.fromRGB(119, 120, 255), GradientRGB2 = Color3.fromRGB(0, 0, 0),
                        GradientFill = true, GradientFillRGB1 = Color3.fromRGB(119, 120, 255), GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
                        Filled = {
                            Enabled = true,
                            Transparency = 0.75,
                            RGB = Color3.fromRGB(0, 0, 0),
                        },
                        Full = {
                            Enabled = true,
                            RGB = Color3.fromRGB(255, 255, 255),
                        },
                        Corner = {
                            Enabled = true,
                            RGB = Color3.fromRGB(255, 255, 255),
                        },
                    };
                };
                Connections = {
                    RunService = RunService;
                };
                Fonts = {};
            }

            local HttpService = httpservice

            local CustomFont = {}
            do
                function CustomFont:New(Name, Weight, Style, Data)
                    if not isfile(Data.Id) then writefile(Data.Id, game:HttpGet(Data.Url)) end
                    local FontData = {
                        name = Name,
                        faces = {{
                            name = Name,
                            weight = Weight,
                            style = Style,
                            assetId = getcustomasset(Data.Id)
                        }}
                    }
                    local FontPath = Name .. ".font"
                    writefile(FontPath, HttpService:JSONEncode(FontData))
                    return Font.new(getcustomasset(FontPath))
                end
            end

            local function defaultEspFont()
                if Font and Font.fromEnum then return Font.fromEnum(Enum.Font.SourceSans) end

                return nil
            end

            local fontOk, fontResult = pcall(function()
                if not (isfile and writefile and getcustomasset) then return defaultEspFont() end

                return CustomFont:New("PoppinsMedium", 400, "Regular", {
                    Id = "PoppinsMedium.ttf",
                    Url = "https://st.1001fonts.net/download/font/poppins.medium.ttf"
                })
            end)

            ESP.Font = fontOk and fontResult or defaultEspFont()

            local Euphoria  = ESP.Connections
            local lplayer   = Players.LocalPlayer
            local Cam       = Workspace.CurrentCamera
            local RotationAngle, Tick = -45, tick()
            local White     = Color3.fromRGB(255, 255, 255)
            if not Players or type(Players.GetPlayers) ~= "function" or not lplayer then return end

            local function espStatusBool(name, default)
                local status = global.ui_status or {}
                local value = status[name]
                if value == nil then return default end

                return value == true
            end

            local function espStatusColor(name, default)
                local status = global.ui_status or {}
                local fromConfig = global.ui and global.ui.colorFromConfig
                if fromConfig then return fromConfig(status[name], default) end

                return default
            end

            local function SyncESPSettings()
                local status = global.ui_status or {}
                local gradient = espStatusBool("esp_gradient", true)
                ESP.Enabled = espStatusBool("esp_enabled", true)
                ESP.TeamCheck = espStatusBool("esp_team_check", true)
                ESP.MaxDistance = tonumber(status.esp_max_distance) or 5000
                ESP.Options.Friendcheck = espStatusBool("esp_friend_check", true)
                ESP.Options.TeamcheckRGB = espStatusColor("esp_team_check_color", ESP.Options.TeamcheckRGB)
                ESP.Options.FriendcheckRGB = espStatusColor("esp_friend_check_color", ESP.Options.FriendcheckRGB)
                ESP.Options.HighlightRGB = espStatusColor("esp_highlight_color", ESP.Options.HighlightRGB)
                ESP.Drawing.Names.Enabled = espStatusBool("esp_names", true)
                ESP.Drawing.Names.RGB = espStatusColor("esp_names_color", ESP.Drawing.Names.RGB)
                ESP.Drawing.Names.UseDisplayName = espStatusBool("esp_use_displayname", false)
                ESP.Drawing.Distances.Enabled = espStatusBool("esp_distances", true)
                ESP.Drawing.Distances.RGB = espStatusColor("esp_distance_color", ESP.Drawing.Distances.RGB)
                ESP.Drawing.Weapons.Enabled = espStatusBool("esp_weapons", false)
                ESP.Drawing.Weapons.WeaponTextRGB = espStatusColor("esp_weapon_color", ESP.Drawing.Weapons.WeaponTextRGB)
                ESP.Drawing.Weapons.Gradient = gradient
                ESP.Drawing.Weapons.GradientRGB1 = espStatusColor("esp_weapon_gradient_1", ESP.Drawing.Weapons.GradientRGB1)
                ESP.Drawing.Weapons.GradientRGB2 = espStatusColor("esp_weapon_gradient_2", ESP.Drawing.Weapons.GradientRGB2)
                ESP.Drawing.Boxes.Full.Enabled = espStatusBool("esp_boxes", true)
                ESP.Drawing.Boxes.Corner.Enabled = espStatusBool("esp_boxes", true)
                ESP.Drawing.Boxes.Filled.Enabled = espStatusBool("esp_boxes", true)
                ESP.Drawing.Boxes.Gradient = gradient
                ESP.Drawing.Boxes.GradientFill = gradient
                ESP.Drawing.Boxes.Full.RGB = espStatusColor("esp_box_color", ESP.Drawing.Boxes.Full.RGB)
                ESP.Drawing.Boxes.Corner.RGB = espStatusColor("esp_box_corner_color", ESP.Drawing.Boxes.Corner.RGB)
                ESP.Drawing.Boxes.GradientRGB1 = espStatusColor("esp_box_gradient_1", ESP.Drawing.Boxes.GradientRGB1)
                ESP.Drawing.Boxes.GradientRGB2 = espStatusColor("esp_box_gradient_2", ESP.Drawing.Boxes.GradientRGB2)
                ESP.Drawing.Boxes.Filled.RGB = espStatusColor("esp_box_fill_color", ESP.Drawing.Boxes.Filled.RGB)
                ESP.Drawing.Boxes.GradientFillRGB1 = espStatusColor("esp_box_fill_gradient_1", ESP.Drawing.Boxes.GradientFillRGB1)
                ESP.Drawing.Boxes.GradientFillRGB2 = espStatusColor("esp_box_fill_gradient_2", ESP.Drawing.Boxes.GradientFillRGB2)
                ESP.Drawing.Healthbar.Enabled = espStatusBool("esp_healthbar", true)
                ESP.Drawing.Healthbar.Gradient = gradient
                ESP.Drawing.Healthbar.HealthTextRGB = espStatusColor("esp_health_text_color", ESP.Drawing.Healthbar.HealthTextRGB)
                ESP.Drawing.Healthbar.GradientRGB1 = espStatusColor("esp_health_gradient_1", ESP.Drawing.Healthbar.GradientRGB1)
                ESP.Drawing.Healthbar.GradientRGB2 = espStatusColor("esp_health_gradient_2", ESP.Drawing.Healthbar.GradientRGB2)
                ESP.Drawing.Healthbar.GradientRGB3 = espStatusColor("esp_health_gradient_3", ESP.Drawing.Healthbar.GradientRGB3)
                ESP.Drawing.Chams.Enabled = espStatusBool("esp_chams", false)
                ESP.Drawing.Chams.FillRGB = espStatusColor("esp_chams_fill_color", ESP.Drawing.Chams.FillRGB)
                ESP.Drawing.Chams.OutlineRGB = espStatusColor("esp_chams_outline_color", ESP.Drawing.Chams.OutlineRGB)
                -- Build the gradient ColorSequences here (this runs at ~15Hz) instead of
                -- allocating fresh ColorSequence + keypoints per player every frame in the
                -- draw loop, which was the ESP GC sink. The draw loop just assigns these.
                local boxes = ESP.Drawing.Boxes
                boxes.GradientFillSeq = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, boxes.GradientFillRGB1),
                    ColorSequenceKeypoint.new(1, boxes.GradientFillRGB2),
                }
                boxes.GradientSeq = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, boxes.GradientRGB1),
                    ColorSequenceKeypoint.new(1, boxes.GradientRGB2),
                }
                local hb = ESP.Drawing.Healthbar
                hb.GradientSeq = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, hb.GradientRGB1),
                    ColorSequenceKeypoint.new(0.5, hb.GradientRGB2),
                    ColorSequenceKeypoint.new(1, hb.GradientRGB3),
                }
                local wd = ESP.Drawing.Weapons
                wd.GradientSeq = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, wd.GradientRGB1),
                    ColorSequenceKeypoint.new(1, wd.GradientRGB2),
                }
                -- bump each sync (~15Hz); the per-player draw applies static colors only
                -- when this changes instead of re-writing every color every frame
                ESP.StyleRev = (ESP.StyleRev or 0) + 1
            end

            local Weapon_Icons = {
                ["Wooden Bow"]          = "http://www.roblox.com/asset/?id=17677465400",
                ["Crossbow"]            = "http://www.roblox.com/asset/?id=17677473017",
                ["Salvaged SMG"]        = "http://www.roblox.com/asset/?id=17677463033",
                ["Salvaged AK47"]       = "http://www.roblox.com/asset/?id=17677455113",
                ["Salvaged AK74u"]      = "http://www.roblox.com/asset/?id=17677442346",
                ["Salvaged M14"]        = "http://www.roblox.com/asset/?id=17677444642",
                ["Salvaged Python"]     = "http://www.roblox.com/asset/?id=17677451737",
                ["Military PKM"]        = "http://www.roblox.com/asset/?id=17677449448",
                ["Military M4A1"]       = "http://www.roblox.com/asset/?id=17677479536",
                ["Bruno's M4A1"]        = "http://www.roblox.com/asset/?id=17677471185",
                ["Military Barrett"]    = "http://www.roblox.com/asset/?id=17677482998",
                ["Salvaged Skorpion"]   = "http://www.roblox.com/asset/?id=17677459658",
                ["Salvaged Pump Action"]= "http://www.roblox.com/asset/?id=17677457186",
                ["Military AA12"]       = "http://www.roblox.com/asset/?id=17677475227",
                ["Salvaged Break Action"]="http://www.roblox.com/asset/?id=17677468751",
                ["Salvaged Pipe Rifle"] = "http://www.roblox.com/asset/?id=17677468751",
                ["Salvaged P250"]       = "http://www.roblox.com/asset/?id=17677447257",
                ["Nail Gun"]            = "http://www.roblox.com/asset/?id=17677484756",
            }

            local Functions = {}
            do
                function Functions:Create(Class, Properties)
                    local _Instance = Class
                    if typeof(Class) == "string" then
                        local ok, result = pcall(Instance.new, Class)
                        if not ok then
                            warn(("[crewbattler merge] ESP failed creating %s: %s"):format(tostring(Class), tostring(result)))
                            return nil
                        end
                        _Instance = result
                    end
                    if not _Instance then return nil end
                    for Property, Value in pairs(Properties or {}) do
                        pcall(function()
                            _Instance[Property] = Value
                        end)
                    end
                    return _Instance
                end
            end

            do
                -- Parent the ESP GUI under gethui() (like the FOV ScreenGui), NOT CoreGui.
                -- In CH4 a CoreGui-parented ESP ScreenGui doesn't render (the corners, drawn
                -- via DrawingImmediate, still showed, which is why only they appeared), so the
                -- whole GUI ESP (box/name/healthbar) was invisible. gethui() renders reliably.
                local function espGuiParent()
                    if gethui then
                        local ok, hui = pcall(gethui)
                        if ok and hui then return hui end
                    end
                    return CoreGui
                end
                local guiHolder = espGuiParent()
                pcall(function()
                    local oldHolder = guiHolder:FindFirstChild("ESPHolder") or CoreGui:FindFirstChild("ESPHolder")
                    if oldHolder then oldHolder:Destroy() end
                end)

                local ScreenGui = Functions:Create("ScreenGui", {
                    Parent = guiHolder,
                    Name   = "ESPHolder",
                })
                if not ScreenGui then
                    warn("[crewbattler merge] ESP disabled because ScreenGui creation failed")
                    return false
                end

                -- Flat sequential table: every active Cache entry is stored here so
                -- RenderStepped iterates a plain array with numeric for — no pairs(),
                -- no hash-table overhead, no GC pressure from the iterator closure.
                local ActiveCache  = {}   -- array  [i] = Cache
                local ActiveCount  = 0

                -- Hash table only used for O(1) add/remove by player key.
                local PlayerCache  = {}   -- [plr]  = Cache

                -- DrawingImmediate-based corner brackets: the 8 GUI corner Frames per
                -- player were a big instance cost, so draw them as immediate-mode lines
                -- in a GetPaint event instead. The RenderStepped Update stashes the
                -- bracket geometry on each Cache; this draws it. (Boxes/text/healthbar
                -- stay GUI for now — gradient fills can't be done in DrawingImmediate.)
                local DrawImm = DrawingImmediate
                local v2 = Vector2.new
                local function diLine(a, b, color, op) pcall(DrawImm.Line, a, b, color, op or 1, 1) end
                -- the ESP GUI ScreenGui sits below the topbar inset, but DrawingImmediate
                -- draws in absolute screen pixels, so shift DI draws down by the inset to
                -- line the corner brackets up with the (GUI) box
                local guiInsetX, guiInsetY = 0, 0
                pcall(function()
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    guiInsetX, guiInsetY = inset.X, inset.Y
                end)

                local function safeValue(fn)
                    local ok, result = pcall(fn)
                    if ok then return result end
                    return nil
                end
                -- non-allocating accessors for the per-frame Update: pcall ONE shared
                -- function with args instead of allocating a fresh closure on every
                -- property read (closure churn here was the main ESP GC/FPS sink)
                local function rawIndex(o, k) return o[k] end
                local function safeIndex(o, k)
                    if o == nil then return nil end
                    local ok, v = pcall(rawIndex, o, k)
                    if ok then return v end
                    return nil
                end
                local function rawMethod(o, m, a) return o[m](o, a) end
                local function safeMethod(o, m, a)
                    if o == nil then return nil end
                    local ok, v = pcall(rawMethod, o, m, a)
                    if ok then return v end
                    return nil
                end
                local function rawSetProp(o, k, v) o[k] = v end -- pcall this instead of a fresh closure

                -- ── Cleanup ──────────────────────────────────────────────────────────
                local function Cleanup(plr)
                    if not plr then return end
                    local Cached = rawget(PlayerCache, plr)
                    if not Cached then return end
                    PlayerCache[plr] = nil          -- clear first so re-entry is a no-op
                    Cached.Disabled = true          -- main loop + corner drawer skip disabled
                    local cd = rawget(Cached, "CornerData")
                    if cd then cd.show = false end  -- stop the DrawingImmediate corners immediately

                    -- Remove from the flat array by swap-with-last, guarded against desync:
                    -- only touch index idx if the entry there is really this Cache, and never
                    -- index a nil "last" (the previous code crashed on last.ArrayIndex = idx).
                    local idx = rawget(Cached, "ArrayIndex")
                    if idx and ActiveCache[idx] == Cached and ActiveCount > 0 then
                        local last = ActiveCache[ActiveCount]
                        if last and last ~= Cached then
                            ActiveCache[idx] = last
                            last.ArrayIndex  = idx
                        else
                            ActiveCache[idx] = nil
                        end
                        ActiveCache[ActiveCount] = nil
                        ActiveCount = ActiveCount - 1
                    end
                    Cached.ArrayIndex = nil

                    local conn = rawget(Cached, "Connection")
                    if conn then pcall(function() conn:Disconnect() end) end

                    local Objects = rawget(Cached, "Objects") or {}
                    for i = 1, #Objects do
                        local obj = Objects[i]
                        if obj then pcall(function() obj:Destroy() end) end
                        Objects[i] = nil
                    end
                end

                -- ── Per-player ESP builder ────────────────────────────────────────────
                local function BuildESP(plr)
                    Cleanup(plr)   -- dedup guard

                    local NameText                = plr.Name
                    local NameDistanceText        = plr.Name .. " [%d]"
                    local DisplayNameText         = plr.DisplayName
                    local DisplayNameDistanceText = plr.DisplayName .. " [%d]"

                    local Name          = Functions:Create("TextLabel",  {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,-11), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), FontFace=ESP.Font, TextSize=ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true})
                    local Distance      = Functions:Create("TextLabel",  {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,11),  Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), FontFace=ESP.Font, TextSize=ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true})
                    local Weapon        = Functions:Create("TextLabel",  {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,31),  Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), FontFace=ESP.Font, TextSize=ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true, Text="none"})
                    local Box           = Functions:Create("Frame",      {Parent=ScreenGui, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.75, BorderSizePixel=0})
                    local Gradient1     = Functions:Create("UIGradient", {Parent=Box,     Enabled=ESP.Drawing.Boxes.GradientFill, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,ESP.Drawing.Boxes.GradientFillRGB1),ColorSequenceKeypoint.new(1,ESP.Drawing.Boxes.GradientFillRGB2)}})
                    local Outline       = Functions:Create("UIStroke",   {Parent=Box,     Enabled=ESP.Drawing.Boxes.Gradient, Transparency=0, Color=Color3.fromRGB(255,255,255), LineJoinMode=Enum.LineJoinMode.Miter})
                    local Gradient2     = Functions:Create("UIGradient", {Parent=Outline, Enabled=ESP.Drawing.Boxes.Gradient, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,ESP.Drawing.Boxes.GradientRGB1),ColorSequenceKeypoint.new(1,ESP.Drawing.Boxes.GradientRGB2)}})
                    local Healthbar     = Functions:Create("Frame",      {Parent=ScreenGui, BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0})
                    local BehindHB      = Functions:Create("Frame",      {Parent=ScreenGui, ZIndex=0, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0})
                    local _HBGrad       = Functions:Create("UIGradient", {Parent=Healthbar, Enabled=ESP.Drawing.Healthbar.Gradient, Rotation=-90, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,ESP.Drawing.Healthbar.GradientRGB1),ColorSequenceKeypoint.new(0.5,ESP.Drawing.Healthbar.GradientRGB2),ColorSequenceKeypoint.new(1,ESP.Drawing.Healthbar.GradientRGB3)}})
                    local HealthText    = Functions:Create("TextLabel",  {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,31), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), FontFace=ESP.Font, TextSize=ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0)})
                    local Chams         = Functions:Create("Highlight",  {Parent=ScreenGui, FillTransparency=1, OutlineTransparency=0, OutlineColor=Color3.fromRGB(119,120,255), DepthMode=Enum.HighlightDepthMode.AlwaysOnTop})
                    local WeaponIcon    = Functions:Create("ImageLabel", {Parent=ScreenGui, BackgroundTransparency=1, BorderColor3=Color3.fromRGB(0,0,0), BorderSizePixel=0, Size=UDim2.new(0,40,0,40)})
                    local _WepGrad      = Functions:Create("UIGradient", {Parent=WeaponIcon, Rotation=-90, Enabled=ESP.Drawing.Weapons.Gradient, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,ESP.Drawing.Weapons.GradientRGB1),ColorSequenceKeypoint.new(1,ESP.Drawing.Weapons.GradientRGB2)}})

                    -- Pre-built flat Objects array — no table.insert, no pairs on cleanup
                    -- (corner brackets are now drawn via DrawingImmediate, not GUI Frames)
                    local Objects = {
                        Name, Distance, Weapon, Box, Healthbar, BehindHB, HealthText,
                        Chams, WeaponIcon,
                    }

                    -- Register in both the hash map and the flat array
                    ActiveCount = ActiveCount + 1
                    local Cache = {
                        -- book-keeping
                        ArrayIndex           = ActiveCount,
                        Player               = plr,
                        -- per-frame state (all pre-declared so rawget never hits nil keys slowly)
                        Hidden               = false,
                        Errors               = 0,
                        Character            = nil,
                        HRP                  = nil,
                        Humanoid             = nil,
                        LastDistance         = nil,
                        LastDistanceMode     = nil,
                        LastHealthPercentage = nil,
                        NameText             = NameText,
                        NameDistanceText     = NameDistanceText,
                        DisplayNameText         = DisplayNameText,
                        DisplayNameDistanceText = DisplayNameDistanceText,
                        LastUseDisplayName      = nil,
                        Objects              = Objects,
                        -- direct references — avoids repeated rawget(Objects, i) inside Update
                        Name        = Name,
                        Distance    = Distance,
                        Weapon      = Weapon,
                        Box         = Box,
                        Outline     = Outline,
                        Gradient1   = Gradient1,
                        Gradient2   = Gradient2,
                        Healthbar   = Healthbar,
                        BehindHB    = BehindHB,
                        HealthText  = HealthText,
                        Chams       = Chams,
                        WeaponIcon  = WeaponIcon,
                    }
                    ActiveCache[ActiveCount] = Cache
                    PlayerCache[plr]         = Cache

                    -- ── HideESP (inner, upvalue-captured) ────────────────────────────
                    local function HideESP()
                        local parent = safeIndex(plr, "Parent")
                        if not parent then Cleanup(plr) return end
                        if rawget(Cache, "Hidden") then return end

                        local cd = rawget(Cache, "CornerData")
                        if cd then cd.show = false end -- stop the GetPaint corner draw
                        pcall(function()
                            Name.Visible        = false
                            Distance.Visible    = false
                            Weapon.Visible      = false
                            Box.Visible         = false
                            Healthbar.Visible   = false
                            BehindHB.Visible    = false
                            HealthText.Visible  = false
                            WeaponIcon.Visible  = false
                            Chams.Enabled       = false
                        end)
                        Cache.Hidden        = true
                    end
                    -- expose to the main loop so a transient Update error can hide (not destroy)
                    Cache.HideESP = HideESP

                    -- ── Per-frame Update (stored directly on Cache, called by numeric for) ─
                    Cache.Update = function(Now, CameraPosition, ViewportY, LocalTeam)
                        local parent = safeIndex(plr, "Parent")
                        if not parent then Cleanup(plr) return end
                        if not ESP.Enabled then HideESP() return end
                        if ESP.Options.Friendcheck then
                            local userId = safeIndex(plr, "UserId")
                            local isFriend = userId and safeMethod(lplayer, "IsFriendsWith", userId)
                            if isFriend then HideESP() return end
                        end

                        local Character = safeIndex(plr, "Character")
                        if not Character then HideESP() return end

                        -- Character swap detection
                        if rawget(Cache, "Character") ~= Character then
                            Cache.Character  = Character
                            Cache.HRP        = safeMethod(Character, "FindFirstChild", "HumanoidRootPart")
                            Cache.Humanoid   = safeMethod(Character, "FindFirstChild", "Humanoid")
                            pcall(function()
                                Chams.Adornee = ESP.Drawing.Chams.Enabled and Character or nil
                            end)
                        else
                            local hrp = rawget(Cache, "HRP")
                            local hrpParent = hrp and safeIndex(hrp, "Parent")
                            if not hrp or not hrpParent then
                                Cache.HRP = safeMethod(Character, "FindFirstChild", "HumanoidRootPart")
                            end
                            local hum = rawget(Cache, "Humanoid")
                            local humParent = hum and safeIndex(hum, "Parent")
                            if not hum or not humParent then
                                Cache.Humanoid = safeMethod(Character, "FindFirstChild", "Humanoid")
                            end
                        end

                        local HRP      = rawget(Cache, "HRP")
                        local Humanoid = rawget(Cache, "Humanoid")
                        if not HRP or not Humanoid then HideESP() return end

                        local PlayerTeam = safeIndex(plr, "Team")
                        if ESP.TeamCheck and not (plr ~= lplayer
                            and ((LocalTeam ~= PlayerTeam and PlayerTeam)
                              or (not LocalTeam and not PlayerTeam)))
                        then HideESP() return end

                        local HRPPosition = safeIndex(HRP, "Position")
                        if not HRPPosition then HideESP() return end
                        local Dist = (CameraPosition - HRPPosition).Magnitude
                        if Dist > ESP.MaxDistance then HideESP() return end

                        local okScreen, Pos, OnScreen = pcall(rawMethod, Cam, "WorldToScreenPoint", HRPPosition)
                        if not okScreen then HideESP() return end
                        if not OnScreen then HideESP() return end

                        Cache.Hidden = false

                        -- static colors only need re-applying when settings change (~15Hz),
                        -- not every frame; positions/sizes/health still update every frame
                        local applyStatic = rawget(Cache, "StyleRev") ~= ESP.StyleRev
                        if applyStatic then Cache.StyleRev = ESP.StyleRev end

                        -- Pre-compute layout values once per frame per player
                        local SizeY     = safeIndex(safeIndex(HRP, "Size"), "Y")
                        if not SizeY then HideESP() return end
                        local scale     = (SizeY * ViewportY) / (Pos.Z * 2)
                        local w         = 3   * scale
                        local h         = 4.5 * scale
                        local HalfW     = w * 0.5
                        local HalfH     = h * 0.5
                        local PosX      = Pos.X
                        local PosY      = Pos.Y
                        local left      = PosX - HalfW
                        local right     = PosX + HalfW
                        local top       = PosY - HalfH
                        local bot       = PosY + HalfH
                        local cornerW   = w * 0.2   -- w / 5 pre-divided
                        local cornerH   = h * 0.2   -- h / 5 pre-divided

                        -- ── Fade ──────────────────────────────────────────────────────
                        if ESP.FadeOut.OnDistance then
                            local T = 1 - math.max(0.1, 1 - (Dist / ESP.MaxDistance))
                            Box.BackgroundTransparency      = T
                            Outline.Transparency            = T
                            Name.TextTransparency           = T
                            Distance.TextTransparency       = T
                            Weapon.TextTransparency         = T
                            Healthbar.BackgroundTransparency= T
                            BehindHB.BackgroundTransparency = T
                            HealthText.TextTransparency     = T
                            WeaponIcon.ImageTransparency    = T
                            Chams.FillTransparency          = T
                            Chams.OutlineTransparency       = T
                        end

                        -- ── Chams ─────────────────────────────────────────────────────
                        do
                            local CD = ESP.Drawing.Chams
                            pcall(rawSetProp, Chams, "Adornee", CD.Enabled and Character or nil)
                            Chams.Enabled      = CD.Enabled
                            Chams.FillColor    = CD.FillRGB
                            Chams.OutlineColor = CD.OutlineRGB
                            if CD.Thermal then
                                local b = math.atan(math.sin(Now * 2)) * 2 / math.pi
                                Chams.FillTransparency    = CD.Fill_Transparency    * b * 0.01
                                Chams.OutlineTransparency = CD.Outline_Transparency * b * 0.01
                            end
                            Chams.DepthMode = CD.VisibleCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                        end

                        -- ── Corner brackets (drawn via DrawingImmediate in the paint loop) ──
                        do
                            local cd = rawget(Cache, "CornerData")
                            if not cd then cd = {}; Cache.CornerData = cd end
                            cd.show  = ESP.Drawing.Boxes.Corner.Enabled
                            cd.left  = left;  cd.right = right
                            cd.top   = top;   cd.bot   = bot
                            cd.cw    = cornerW; cd.ch  = cornerH
                            cd.color = ESP.Drawing.Boxes.Corner.RGB
                            cd.op    = ESP.FadeOut.OnDistance and math.max(0.1, 1 - (Dist / ESP.MaxDistance)) or 1
                        end

                        -- ── Full box ──────────────────────────────────────────────────
                        do
                            local BD = ESP.Drawing.Boxes
                            if applyStatic then
                                Outline.Color = BD.Full.RGB
                                Gradient1.Enabled = BD.GradientFill
                                Gradient2.Enabled = BD.Gradient
                                if BD.GradientFillSeq then Gradient1.Color = BD.GradientFillSeq end
                                if BD.GradientSeq then Gradient2.Color = BD.GradientSeq end
                            end
                            Box.Position = UDim2.new(0, left, 0, top)
                            Box.Size     = UDim2.new(0, w,    0, h)
                            Box.Visible  = BD.Full.Enabled
                            -- the box border is the UIStroke (Outline); its Enabled was only
                            -- set once at creation, so players built while the gradient state
                            -- was stale never got a visible box. Drive it live every frame.
                            Outline.Enabled = BD.Full.Enabled

                            if BD.Filled.Enabled then
                                Box.BackgroundColor3 = BD.Filled.RGB
                                Box.BackgroundTransparency = BD.GradientFill and BD.Filled.Transparency or 1
                                Box.BorderSizePixel  = 1
                            else
                                Box.BackgroundTransparency = 1
                            end

                            -- Gradient rotation animation
                            if Tick ~= Now then
                                RotationAngle = RotationAngle + (Now - Tick) * BD.RotationSpeed * math.cos(math.pi / 4 * Now - math.pi / 2)
                                Tick = Now
                            end
                            local rot = BD.Animate and RotationAngle or -45
                            Gradient1.Rotation = rot
                            Gradient2.Rotation = rot
                        end

                        -- ── Health bar ────────────────────────────────────────────────
                        do
                            local Health    = safeIndex(Humanoid, "Health")
                            local MaxHealth = safeIndex(Humanoid, "MaxHealth")
                            if not Health or not MaxHealth or MaxHealth <= 0 then
                                HideESP()
                                return
                            end
                            local health    = Health / MaxHealth
                            local hbLeft    = left - 6

                            Healthbar.Visible  = ESP.Drawing.Healthbar.Enabled
                            Healthbar.Position = UDim2.new(0, hbLeft, 0, top + h * (1 - health))
                            Healthbar.Size     = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h * health)
                            Healthbar.BackgroundColor3 = ESP.Drawing.Healthbar.GradientRGB2
                            _HBGrad.Enabled = ESP.Drawing.Healthbar.Gradient
                            if ESP.Drawing.Healthbar.GradientSeq then _HBGrad.Color = ESP.Drawing.Healthbar.GradientSeq end

                            BehindHB.Visible   = ESP.Drawing.Healthbar.Enabled
                            BehindHB.Position  = UDim2.new(0, hbLeft, 0, top)
                            BehindHB.Size      = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h)

                            if ESP.Drawing.Healthbar.HealthText then
                                local pct = math.floor(health * 100)
                                HealthText.Position = UDim2.new(0, hbLeft, 0, top + h * (1 - pct * 0.01) + 3)
                                if rawget(Cache, "LastHealthPercentage") ~= pct then
                                    HealthText.Text          = tostring(pct)
                                    Cache.LastHealthPercentage = pct
                                end
                                HealthText.Visible = Health < MaxHealth
                                if ESP.Drawing.Healthbar.Lerp then
                                    HealthText.TextColor3 = health >= 0.75 and Color3.fromRGB(0,255,0)
                                        or health >= 0.5  and Color3.fromRGB(255,255,0)
                                        or health >= 0.25 and Color3.fromRGB(255,170,0)
                                        or Color3.fromRGB(255,0,0)
                                else
                                    HealthText.TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB
                                end
                            end
                        end

                        -- ── Name ──────────────────────────────────────────────────────
                        Name.Visible   = ESP.Drawing.Names.Enabled
                        Name.Position  = UDim2.new(0, PosX, 0, top - 9)
                        if applyStatic then Name.TextColor3 = ESP.Drawing.Names.RGB end

                        -- ── Distance / name text ──────────────────────────────────────
                        do
                            local DD = ESP.Drawing.Distances
                            if applyStatic then Distance.TextColor3 = DD.RGB end
                            -- default hidden so disabling distance (or non-Bottom modes)
                            -- can't leave a stale label frozen on screen
                            Distance.Visible = false
                            local useDisplay = ESP.Drawing.Names.UseDisplayName == true
                            local nameText = useDisplay and rawget(Cache, "DisplayNameText") or rawget(Cache, "NameText")
                            local nameDistanceText = useDisplay and rawget(Cache, "DisplayNameDistanceText") or rawget(Cache, "NameDistanceText")
                            -- toggling display name must refresh the cached text immediately
                            if rawget(Cache, "LastUseDisplayName") ~= useDisplay then
                                Cache.LastUseDisplayName = useDisplay
                                Cache.LastDistance       = nil
                                Cache.LastDistanceMode   = nil
                            end
                            if DD.Enabled then
                                local dn = math.floor(Dist)
                                if DD.Position == "Bottom" then
                                    Distance.Position  = UDim2.new(0, PosX, 0, bot + 7)
                                    Weapon.Position    = UDim2.new(0, PosX, 0, bot + 18)
                                    WeaponIcon.Position= UDim2.new(0, PosX - 21, 0, bot + 15)
                                    if rawget(Cache, "LastDistance") ~= dn or rawget(Cache, "LastDistanceMode") ~= "Bottom" then
                                        Distance.Text         = "[" .. dn .. "]"
                                        Name.Text             = nameText
                                        Cache.LastDistance     = dn
                                        Cache.LastDistanceMode = "Bottom"
                                    end
                                    Distance.Visible = true
                                elseif DD.Position == "Text" then
                                    Weapon.Position    = UDim2.new(0, PosX, 0, bot + 8)
                                    WeaponIcon.Position= UDim2.new(0, PosX - 21, 0, bot + 5)
                                    if rawget(Cache, "LastDistance") ~= dn or rawget(Cache, "LastDistanceMode") ~= "Text" then
                                        Name.Text             = string.format(nameDistanceText, dn)
                                        Cache.LastDistance     = dn
                                        Cache.LastDistanceMode = "Text"
                                    end
                                    Name.Visible = ESP.Drawing.Names.Enabled
                                elseif rawget(Cache, "LastDistanceMode") ~= "Name" then
                                    Name.Text             = nameText
                                    Cache.LastDistanceMode = "Name"
                                end
                            elseif rawget(Cache, "LastDistanceMode") ~= "Name" then
                                Name.Text             = nameText
                                Cache.LastDistanceMode = "Name"
                            end
                        end

                        do
                            local WD = ESP.Drawing.Weapons
                            if not WD.Enabled then
                                Weapon.Visible = false
                                WeaponIcon.Visible = false
                            else
                                if applyStatic then
                                    Weapon.TextColor3 = WD.WeaponTextRGB
                                    _WepGrad.Enabled = WD.Gradient
                                    if WD.GradientSeq then _WepGrad.Color = WD.GradientSeq end
                                end
                                -- detect the target's equipped weapon from their Folder: the
                                -- true BoolValue whose name is a known gun. Salvaged/Military
                                -- variants ("Salvaged AK47" etc.) map straight to their icon.
                                local current
                                local folder = plr:FindFirstChild("Folder")
                                if folder then
                                    for _, v in ipairs(folder:GetChildren()) do
                                        if Weapon_Icons[v.Name] and v:IsA("BoolValue") and v.Value then current = v.Name break end
                                    end
                                end
                                if rawget(Cache, "LastWeapon") ~= current then
                                    Cache.LastWeapon = current
                                    Weapon.Text = current or "none"
                                    WeaponIcon.Image = current and Weapon_Icons[current] or ""
                                end
                                Weapon.Visible = current ~= nil
                                WeaponIcon.Visible = current ~= nil
                            end
                        end
                    end

                    HideESP()
                end

                -- ── Player lifecycle ──────────────────────────────────────────────────
                local function StartESP(plr)
                    local ok, err = pcall(BuildESP, plr)
                    if not ok then warn(("[crewbattler merge] ESP build failed: %s"):format(tostring(err))) end
                end

                for _, v in ipairs(Players:GetPlayers()) do
                    if v ~= lplayer then StartESP(v) end
                end

                Players.PlayerAdded:Connect(function(v)
                    StartESP(v)
                end)
                Players.PlayerRemoving:Connect(Cleanup)

                local lastEspSync = 0
                Euphoria.RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
                    pcall(set_thread_identity, 7)
                    Cam = Workspace.CurrentCamera
                    if not Cam then return end

                    local Now            = tick()
                    local CameraPosition = Cam.CFrame.Position
                    local ViewportY      = Cam.ViewportSize.Y
                    local LocalTeam      = safeIndex(lplayer, "Team")
                    -- ESP options only change on user input; syncing ~40 flags every frame
                    -- was pure overhead, so refresh them at ~15Hz instead of per-frame
                    if Now - lastEspSync >= 0.066 then
                        SyncESPSettings()
                        lastEspSync = Now
                    end
                    local count          = ActiveCount

                    for i = 1, count do
                        local C = ActiveCache[i]
                        if C and not C.Disabled then
                            local ok, err = pcall(C.Update, Now, CameraPosition, ViewportY, LocalTeam)
                            if ok then
                                if C.Errors ~= 0 then C.Errors = 0 end
                            else
                                -- A respawn briefly leaves the character nil, so the first
                                -- error(s) are transient: hide the visuals (don't freeze on
                                -- screen) and retry. Only tear down after persistent failure
                                -- so respawning players recover instead of vanishing for good.
                                if C.HideESP then pcall(C.HideESP) end
                                C.Errors = (C.Errors or 0) + 1
                                if C.Errors >= 180 then
                                    local message = tostring(err)
                                    if not message:find("cannot access 'Instance'", 1, true) and not message:find("lacking capability", 1, true) then warn(("[crewbattler merge] ESP update failed: %s"):format(message)) end
                                    C.Disabled = true
                                    pcall(Cleanup, C.Player)
                                end
                            end
                        end
                    end
                end))

                -- DrawingImmediate corner-bracket drawer (replaces 8 GUI Frames/player).
                -- Reads the geometry the Update stashes on each Cache.CornerData.
                if DrawImm and type(DrawImm.GetPaint) == "function" then
                    local okPaint, cornerPaint = pcall(DrawImm.GetPaint, 1)
                    if okPaint and cornerPaint and type(cornerPaint.Connect) == "function" then
                        cornerPaint:Connect(LPH_NO_VIRTUALIZE(function()
                            for i = 1, ActiveCount do
                                local C = ActiveCache[i]
                                local cd = C and not C.Disabled and rawget(C, "CornerData")
                                if cd and cd.show then
                                    local col, op = cd.color, cd.op
                                    local l, r = cd.left + guiInsetX, cd.right + guiInsetX
                                    local t, b = cd.top + guiInsetY, cd.bot + guiInsetY
                                    local cw, ch = cd.cw, cd.ch
                                    diLine(v2(l, t), v2(l + cw, t), col, op)   -- top-left
                                    diLine(v2(l, t), v2(l, t + ch), col, op)
                                    diLine(v2(r - cw, t), v2(r, t), col, op)   -- top-right
                                    diLine(v2(r, t), v2(r, t + ch), col, op)
                                    diLine(v2(l, b), v2(l + cw, b), col, op)   -- bottom-left
                                    diLine(v2(l, b - ch), v2(l, b), col, op)
                                    diLine(v2(r - cw, b), v2(r, b), col, op)   -- bottom-right
                                    diLine(v2(r, b - ch), v2(r, b), col, op)
                                end
                            end
                        end))
                    end
                end
            end
        end
        crewbattlerPlayerEsp()
    end
    Corrections()
    local function crewbattlergui()
        local function hideSectionsOnMarkersOff()
            local markerSection = global.ui.markerSection
            local getTeamsSection = markerSection.teamsSection
            local getObjSection = markerSection.objSection
            local getSettingsSection = markerSection.settingsSection
            local cache
            task.spawn(function()
                for i,v in next, markerSection do v.Visible = global.ui_status.master_switch_marker end
            end)
            local function tagService()
                cache = client.tags.new("markers_master_switch", 0, false, function(val)
                    for i,v in next, markerSection do v.Visible = val end
                end)
            end
            tagService()
            global.syncTagValue(cache, "master_switch_marker")
        end
        hideSectionsOnMarkersOff()
    end
    crewbattlergui()
    local function createVisualCircles()
        local old = coregui:FindFirstChild("crewbattler_fov_circle")
        if old then old:Destroy() end
        old = coregui:FindFirstChild("crewbattler_visual_circles")
        if old then old:Destroy() end

        local status = global.ui_status
        local colorFromConfig = global.ui and global.ui.colorFromConfig
        local modes = {center = true, mouse = true, custom = true}
        local visualGuiWarned = false

        local function isCapabilityError(err)
            local message = tostring(err)
            return message:find("cannot access 'Instance'", 1, true) or message:find("lacking capability", 1, true)
        end

        -- shared closure so enterRobloxThread doesn't allocate one every frame
        local function applyThreadEnv()
            local threadEnv = gettenv()
            if type(threadEnv) == "table" then
                threadEnv.global = global
                local rootEnv = getrenv and getrenv() or nil
                if type(rootEnv) == "table" and rawget(rootEnv, "script") ~= nil then threadEnv.script = rootEnv.script end
            end
        end
        local function enterRobloxThread()
            if type(set_thread_identity) == "function" then
                pcall(set_thread_identity, 7)
            end
            if gettenv then
                pcall(applyThreadEnv)
            end
        end

        local function safeGuiStep(fn)
            enterRobloxThread()
            local ok, err = pcall(fn)
            if ok then return true end
            if not visualGuiWarned then
                visualGuiWarned = true
                if isCapabilityError(err) then
                    warn("[crewbattler merge] visual circle GUI update lost Instance access; continuing with protected updates")
                else
                    warn(("[crewbattler merge] visual circle update failed: %s"):format(tostring(err)))
                end
            end
            return false
        end

        local function read(prefix, key, fallback)
            local value = status[("%s_%s"):format(prefix, key)]
            if value == nil then return fallback end
            return value
        end

        local function readBool(prefix, key, fallback)
            local value = read(prefix, key, nil)
            if value == nil then return fallback == true end
            return value == true
        end

        local function readNumber(prefix, key, fallback) return tonumber(read(prefix, key, fallback)) or fallback end

        local function readColor(prefix, key, fallback)
            local value = read(prefix, key, nil)
            if colorFromConfig then return colorFromConfig(value, fallback) end
            return value or fallback
        end

        local function clamp(n, min, max) return math.max(min, math.min(max, n)) end

        local function v2(x, y) return Vector2.new(tonumber(x) or 0, tonumber(y) or 0) end

        local function makeColorSequence(c1, c2)
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(1, c2),
            })
        end

        local function easingStyle(name)
            local ok, value = pcall(function()
                return Enum.EasingStyle[tostring(name or "Linear")]
            end)
            return ok and value or Enum.EasingStyle.Linear
        end

        local function guiParent()
            if gethui then
                local ok, hui = pcall(gethui)
                if ok and hui then return hui end
            end
            return coregui
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "crewbattler_visual_circles"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = guiParent()

        local function circleFrame(name, z)
            local frame = Instance.new("Frame")
            frame.Name = name
            frame.Parent = screenGui
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.BackgroundTransparency = 1
            frame.BorderSizePixel = 0
            frame.Position = UDim2.fromScale(0.5, 0.5)
            frame.Size = UDim2.fromOffset(100, 100)
            frame.ZIndex = z

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = frame

            return frame
        end

        local function makeGuiCircle(name, z)
            local outlineFrame = circleFrame(name .. "Outline", z)
            local fillFrame = circleFrame(name .. "Fill", z + 1)
            local ringFrame = circleFrame(name .. "Ring", z + 2)
            local outlineStroke = Instance.new("UIStroke")
            outlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            outlineStroke.Parent = outlineFrame
            local outlineGradient = Instance.new("UIGradient")
            outlineGradient.Parent = outlineStroke
            local fillGradient = Instance.new("UIGradient")
            fillGradient.Parent = fillFrame
            local ringStroke = Instance.new("UIStroke")
            ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ringStroke.Parent = ringFrame
            local ringGradient = Instance.new("UIGradient")
            ringGradient.Parent = ringStroke

            return {
                OutlineFrame = outlineFrame,
                FillFrame = fillFrame,
                RingFrame = ringFrame,
                OutlineStroke = outlineStroke,
                OutlineGradient = outlineGradient,
                FillGradient = fillGradient,
                RingStroke = ringStroke,
                RingGradient = ringGradient,
            }
        end

        local fovGui = makeGuiCircle("FOV", 1)

        local function setGuiVisible(gui, state)
            gui.OutlineFrame.Visible = state
            gui.FillFrame.Visible = state
            gui.RingFrame.Visible = state
        end

        local function center()
            local camera = workspace.CurrentCamera
            if camera and camera.ViewportSize then return v2(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) end
            return v2(960, 540)
        end

        local function mouse()
            local ok, pos = pcall(function()
                return uis:GetMouseLocation()
            end)
            if ok and pos then return v2(pos.X, pos.Y) end
            return center()
        end

        local function targetPart(target)
            if not target then return nil end
            if typeof(target) == "Instance" then
                if target:IsA("Player") then target = target.Character end
                if target and target:IsA("Model") then return target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart end
                if target and target:IsA("BasePart") then return target end
            end
            return nil
        end

        local function silentAimTarget() return client.reg and client.reg.getClosestPlayerByFov end

        local function forcedTarget() return global.aimbot and global.aimbot.force_target end

        local function localCharacterTarget()
            local char = client.playerCharacter or player.Character
            return char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
        end

        local function worldToScreen(worldPos, hideOffscreen)
            local camera = workspace.CurrentCamera
            if not camera or not worldPos then return nil, false end
            local ok, point, visible = pcall(function()
                local viewportPoint, onScreen = camera:WorldToViewportPoint(worldPos)
                return viewportPoint, onScreen
            end)
            if not ok or not point then return nil, false end
            -- behind the camera the projection mirrors/inverts, so it's never a valid
            -- on-screen point; always hide it (this is the crosshair "inverting" when you
            -- face away from the target). hideOffscreen still controls in-front offscreen.
            if point.Z <= 0 then return nil, false end
            if hideOffscreen and not visible then return nil, false end
            return v2(point.X, point.Y), true
        end

        local function positionFromSource(source, hideOffscreen)
            local target
            if source == "Silent Aim Target" then
                target = silentAimTarget()
            elseif source == "Forced Target" then
                target = forcedTarget()
            else
                target = localCharacterTarget()
            end
            local part = targetPart(target) or target
            if not part then return mouse(), true end
            if typeof(part) == "Instance" and part:IsA("BasePart") then return worldToScreen(part.Position, hideOffscreen) end
            if typeof(part) == "Vector3" then return worldToScreen(part, hideOffscreen) end
            return mouse(), true
        end

        local function resolvePosition(prefix, hideOffscreen)
            local mode = tostring(read(prefix, "mode", "mouse"))
            if not modes[mode] then mode = "mouse" end
            if readBool(prefix, "follow_target", false) then return positionFromSource(read(prefix, "position", "Silent Aim Target"), hideOffscreen) end
            if mode == "center" then return center(), true end
            if mode == "mouse" then return mouse(), true end
            return positionFromSource(read(prefix, "position", "Local Character"), hideOffscreen)
        end

        local function spinRotation(prefix, now)
            if not readBool(prefix, "spin", true) then return 0 end
            local spinSpeed = readNumber(prefix, "spin_speed", 150)
            local spinMax = readNumber(prefix, "spin_max", 360)
            if spinMax <= 0 then spinMax = 360 end
            local raw = (now * spinSpeed) % spinMax
            local alpha = clamp(raw / spinMax, 0, 1)
            local ok, eased = pcall(function()
                return tweenservice:GetValue(alpha, easingStyle(read(prefix, "spin_style", "Linear")), Enum.EasingDirection.InOut)
            end)
            return (ok and eased or alpha) * spinMax
        end

        local function gradientRotation(prefix, now, animateKey, speedKey, rotationKey, spin)
            local staticRotation = readNumber(prefix, rotationKey, 90)
            if not readBool(prefix, animateKey, true) then return staticRotation end
            if readBool(prefix, "spin", true) then return staticRotation + spin end
            return staticRotation + ((now * readNumber(prefix, speedKey, 0.75) * 360) % 360)
        end

        local function updateGui(gui, prefix, pos, radius, now)
            local z = 1
            gui.OutlineFrame.ZIndex = z
            gui.FillFrame.ZIndex = z + 1
            gui.RingFrame.ZIndex = z + 2

            local size = radius * 2
            local udimPos = UDim2.fromOffset(pos.X, pos.Y)
            local udimSize = UDim2.fromOffset(size, size)
            gui.OutlineFrame.Position = udimPos
            gui.FillFrame.Position = udimPos
            gui.RingFrame.Position = udimPos
            gui.OutlineFrame.Size = udimSize
            gui.FillFrame.Size = udimSize
            gui.RingFrame.Size = udimSize

            local spin = spinRotation(prefix, now)
            local opacity = clamp(readNumber(prefix, "opacity", 1), 0, 1)
            local filled = readBool(prefix, "filled", false)
            gui.FillFrame.BackgroundColor3 = readColor(prefix, "fill_color", Color3.fromRGB(66, 84, 245))
            gui.FillFrame.BackgroundTransparency = filled and (1 - clamp(readNumber(prefix, "fill_opacity", 0.25), 0, 1)) or 1
            gui.FillGradient.Enabled = filled and readBool(prefix, "gradient_circle_filled", false)
            gui.FillGradient.Color = makeColorSequence(
                readColor(prefix, "gradient_circle_filled_rgb1", Color3.fromRGB(255, 255, 255)),
                readColor(prefix, "gradient_circle_filled_rgb2", Color3.fromRGB(66, 84, 245))
            )
            gui.FillGradient.Rotation = gradientRotation(prefix, now, "gradient_circle_filled_animate", "gradient_circle_filled_speed", "gradient_circle_filled_rotation", spin)

            local outline = readBool(prefix, "outline", true)
            gui.OutlineStroke.Enabled = outline
            gui.OutlineStroke.Color = readColor(prefix, "outline_color", Color3.fromRGB(0, 0, 0))
            gui.OutlineStroke.Transparency = 1 - opacity
            gui.OutlineStroke.Thickness = readNumber(prefix, "thickness", 2.5) + (readNumber(prefix, "outline_thickness", 1.5) * 2)
            gui.OutlineGradient.Enabled = outline and readBool(prefix, "outline_gradient", false)
            gui.OutlineGradient.Color = makeColorSequence(
                readColor(prefix, "outline_gradient_rgb1", Color3.fromRGB(0, 0, 0)),
                readColor(prefix, "outline_gradient_rgb2", Color3.fromRGB(66, 84, 245))
            )
            gui.OutlineGradient.Rotation = gradientRotation(prefix, now, "outline_gradient_animate", "outline_gradient_speed", "outline_gradient_rotation", spin)

            gui.RingStroke.Enabled = true
            gui.RingStroke.Color = readColor(prefix, "color", Color3.fromRGB(66, 84, 245))
            gui.RingStroke.Transparency = 1 - opacity
            gui.RingStroke.Thickness = readNumber(prefix, "thickness", 2.5)
            gui.RingGradient.Enabled = readBool(prefix, "gradient_circle", true)
            gui.RingGradient.Color = makeColorSequence(
                readColor(prefix, "gradient_circle_rgb1", Color3.fromRGB(255, 255, 255)),
                readColor(prefix, "gradient_circle_rgb2", Color3.fromRGB(66, 84, 245))
            )
            gui.RingGradient.Rotation = gradientRotation(prefix, now, "gradient_circle_animate", "gradient_circle_speed", "gradient_circle_rotation", spin)
        end

        local drawingImmediate = DrawingImmediate
        local crosshairPaint
        if drawingImmediate and type(drawingImmediate.GetPaint) == "function" then
            local ok, paint = pcall(function()
                return drawingImmediate.GetPaint(2)
            end)
            if ok then crosshairPaint = paint end
        end

        local function add(a, b) return v2((a and a.X or 0) + (b and b.X or 0), (a and a.Y or 0) + (b and b.Y or 0)) end

        local function sub(a, b) return v2((a and a.X or 0) - (b and b.X or 0), (a and a.Y or 0) - (b and b.Y or 0)) end

        local function mul(a, n) return v2((a and a.X or 0) * n, (a and a.Y or 0) * n) end

        local function colorLerp(c1, c2, alpha)
            alpha = clamp(alpha, 0, 1)
            return Color3.new(c1.R + ((c2.R - c1.R) * alpha), c1.G + ((c2.G - c1.G) * alpha), c1.B + ((c2.B - c1.B) * alpha))
        end

        local function gradientAlpha(alpha, animated, speed, now)
            alpha = clamp(alpha, 0, 1)
            if animated then return (math.sin((alpha + now * speed) * math.pi * 2) + 1) / 2 end
            return alpha
        end

        local function solve(angle, radius) return v2(math.sin(math.rad(angle)) * radius, math.cos(math.rad(angle)) * radius) end

        local function drawLine(from, to, color, thickness)
            pcall(function()
                drawingImmediate.Line(from, to, color, 1, thickness or 1)
            end)
        end

        local function drawGradientLine(from, to, color1, color2, thickness, segments, animated, speed, now)
            segments = math.floor(tonumber(segments) or 18)
            if segments < 2 then segments = 2 end
            local delta = sub(to, from)
            for i = 0, segments - 1 do
                local a1 = i / segments
                local a2 = (i + 1) / segments
                local alpha = gradientAlpha(i / (segments - 1), animated, speed, now)
                drawLine(add(from, mul(delta, a1)), add(from, mul(delta, a2)), colorLerp(color1, color2, alpha), thickness)
            end
        end

        local function drawText(pos, font, size, color, str)
            if readBool("crosshair", "text_outline", true) then
                pcall(function()
                    drawingImmediate.OutlinedText(pos, font, size, color, 1, readColor("crosshair", "text_outline_color", Color3.fromRGB(0, 0, 0)), 1, tostring(str), false)
                end)
            else
                pcall(function()
                    drawingImmediate.Text(pos, font, size, color, 1, tostring(str), false)
                end)
            end
        end

        local function charWidth(char, size)
            char = tostring(char or "")
            if char == " " then return size * 0.33 end
            if char == "." or char == "," or char == "'" or char == "\"" then return size * 0.28 end
            if char == "i" or char == "l" or char == "I" then return size * 0.3 end
            if char == "m" or char == "w" or char == "M" or char == "W" then return size * 0.75 end
            return size * 0.55
        end

        local function textWidth(str, size)
            str = tostring(str or "")
            local width = 0
            for i = 1, #str do width = width + charWidth(string.sub(str, i, i), size) end
            return width
        end

        local function getGradientRange(str, fromIndex, toIndex)
            str = tostring(str or "")
            local len = #str
            if len <= 0 then return 1, 0 end
            local startIndex = math.floor(tonumber(fromIndex) or 1)
            local endIndex = math.floor(tonumber(toIndex) or 0)
            if endIndex <= 0 then endIndex = len end
            startIndex = clamp(startIndex, 1, len)
            endIndex = clamp(endIndex, 1, len)
            if endIndex < startIndex then endIndex = startIndex end
            return startIndex, endIndex
        end

        local function drawPartialGradientText(pos, font, size, str, baseColor, gradientEnabled, fromIndex, toIndex, color1, color2, animated, speed, now)
            str = tostring(str or "")
            local rangeStart, rangeEnd = getGradientRange(str, fromIndex, toIndex)
            local offset = 0
            local gradientSize = math.max(1, rangeEnd - rangeStart)
            for i = 1, #str do
                local char = string.sub(str, i, i)
                local color = baseColor
                if gradientEnabled and i >= rangeStart and i <= rangeEnd then color = colorLerp(color1, color2, gradientAlpha((i - rangeStart) / gradientSize, animated, speed, now)) end
                drawText(add(pos, v2(offset, 0)), font, size, color, char)
                offset = offset + charWidth(char, size)
            end
        end

        local function crosshairSpinAngle(baseAngle, now)
            if not readBool("crosshair", "spin", true) then return baseAngle end
            local spinMax = readNumber("crosshair", "spin_max", 360)
            if spinMax <= 0 then spinMax = 360 end
            local cycle = ((-now * readNumber("crosshair", "spin_speed", 150)) % spinMax) / spinMax
            local ok, eased = pcall(function()
                return tweenservice:GetValue(clamp(cycle, 0, 1), easingStyle(read("crosshair", "spin_style", "Linear")), Enum.EasingDirection.InOut)
            end)
            return baseAngle + ((ok and eased or cycle) * spinMax)
        end

        local function crosshairLength(now)
            local length = readNumber("crosshair", "length", 10)
            if not readBool("crosshair", "resize", true) then return length end
            local minLength = readNumber("crosshair", "resize_min", 5)
            local maxLength = readNumber("crosshair", "resize_max", 22)
            if maxLength < minLength then minLength, maxLength = maxLength, minLength end
            local wave = (now * readNumber("crosshair", "resize_speed", 150)) % 360
            local alpha = (math.sin(math.rad(wave)) + 1) / 2
            return minLength + ((maxLength - minLength) * alpha)
        end

        local function drawArm(pos, baseAngle, length, now)
            local angle = crosshairSpinAngle(baseAngle, now)
            local radius = readNumber("crosshair", "radius", 11)
            local width = readNumber("crosshair", "width", 2.5)
            local outlineFrom = add(pos, solve(angle, radius - 1))
            local outlineTo = add(pos, solve(angle, radius + length + 1))
            local lineFrom = add(pos, solve(angle, radius))
            local lineTo = add(pos, solve(angle, radius + length))
            if readBool("crosshair", "outline", true) then
                if readBool("crosshair", "outline_gradient", false) then
                    drawGradientLine(outlineFrom, outlineTo, readColor("crosshair", "outline_gradient_rgb1", Color3.fromRGB(0, 0, 0)), readColor("crosshair", "outline_gradient_rgb2", Color3.fromRGB(66, 84, 245)), width + 1.5, readNumber("crosshair", "gradient_lines_segments", 18), readBool("crosshair", "outline_gradient_animate", true), readNumber("crosshair", "outline_gradient_speed", 0.75), now)
                else
                    drawLine(outlineFrom, outlineTo, readColor("crosshair", "outline_color", Color3.fromRGB(0, 0, 0)), width + 1.5)
                end
            end
            if readBool("crosshair", "gradient_lines", true) then
                drawGradientLine(lineFrom, lineTo, readColor("crosshair", "gradient_lines_rgb1", Color3.fromRGB(255, 255, 255)), readColor("crosshair", "gradient_lines_rgb2", Color3.fromRGB(66, 84, 245)), width, readNumber("crosshair", "gradient_lines_segments", 18), readBool("crosshair", "gradient_lines_animate", true), readNumber("crosshair", "gradient_lines_speed", 0.75), now)
            else
                drawLine(lineFrom, lineTo, readColor("crosshair", "color", Color3.fromRGB(66, 84, 245)), width)
            end
        end

        local function drawCrosshair(pos, now)
            local length = crosshairLength(now)
            drawArm(pos, 0, length, now)
            drawArm(pos, 90, length, now)
            drawArm(pos, 180, length, now)
            drawArm(pos, 270, length, now)

            if readBool("crosshair", "text", true) then
                local size = readNumber("crosshair", "text_size", 13)
                local font = math.floor(readNumber("crosshair", "text_font", 2))
                local text1 = tostring(read("crosshair", "text_1", "Misery"))
                local text2 = tostring(read("crosshair", "text_2", ".cc"))
                local w1 = textWidth(text1, size)
                local total = w1 + textWidth(text2, size)
                local y = readNumber("crosshair", "radius", 11) + readNumber("crosshair", "resize_max", 22) + 15
                local start = add(pos, v2(-total / 2, y))
                if readBool("crosshair", "gradient_text", true) then
                    drawPartialGradientText(start, font, size, text1, readColor("crosshair", "text_color", Color3.fromRGB(255, 255, 255)), readBool("crosshair", "gradient_text_1", true), readNumber("crosshair", "gradient_text_1_from", 1), readNumber("crosshair", "gradient_text_1_to", 0), readColor("crosshair", "gradient_text_1_rgb1", readColor("crosshair", "gradient_text_rgb1", Color3.fromRGB(255, 255, 255))), readColor("crosshair", "gradient_text_1_rgb2", readColor("crosshair", "gradient_text_rgb2", Color3.fromRGB(66, 84, 245))), readBool("crosshair", "gradient_text_animate", true), readNumber("crosshair", "gradient_text_speed", 0.75), now)
                    drawPartialGradientText(add(start, v2(w1, 0)), font, size, text2, readColor("crosshair", "text_accent_color", readColor("crosshair", "color", Color3.fromRGB(66, 84, 245))), readBool("crosshair", "gradient_text_2", true), readNumber("crosshair", "gradient_text_2_from", 1), readNumber("crosshair", "gradient_text_2_to", 0), readColor("crosshair", "gradient_text_2_rgb1", readColor("crosshair", "gradient_text_rgb1", Color3.fromRGB(255, 255, 255))), readColor("crosshair", "gradient_text_2_rgb2", readColor("crosshair", "gradient_text_rgb2", Color3.fromRGB(66, 84, 245))), readBool("crosshair", "gradient_text_animate", true), readNumber("crosshair", "gradient_text_speed", 0.75), now)
                else
                    drawText(start, font, size, readColor("crosshair", "text_color", Color3.fromRGB(255, 255, 255)), text1)
                    drawText(add(start, v2(w1, 0)), font, size, readColor("crosshair", "text_accent_color", readColor("crosshair", "color", Color3.fromRGB(66, 84, 245))), text2)
                end
            end
        end

        if crosshairPaint and type(crosshairPaint.Connect) == "function" then
            crosshairPaint:Connect(LPH_NO_VIRTUALIZE(function()
                if not readBool("crosshair", "enabled", false) then return end
                local pos, visible = resolvePosition("crosshair", readBool("crosshair", "custom_hide_offscreen", true))
                if pos and visible ~= false then drawCrosshair(pos, tick()) end
            end))
        end

        runservice.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            safeGuiStep(function()
                local now = tick()
                if status.fov_circle == true then
                    local pos, visible = resolvePosition("fov_circle", readBool("fov_circle", "custom_hide_offscreen", true))
                    if pos and visible ~= false then
                        setGuiVisible(fovGui, true)
                        updateGui(fovGui, "fov_circle", pos, tonumber(status.fov_silentaim) or 80, now)
                    else
                        setGuiVisible(fovGui, false)
                    end
                else
                    setGuiVisible(fovGui, false)
                end

            end)
        end))
    end
    createVisualCircles()
    local function createAuraEffects()
        local status = global.ui_status
        local colorFromConfig = global.ui and global.ui.colorFromConfig
        local connections = {}
        local activeObjects = {}
        local auraModels = {}
        local lastKey = nil

        local assetAuras = {
            starlight = "rbxassetid://134645216613107",
            lightning = "rbxassetid://88833232287502",
            heavenly = "rbxassetid://139300897520961",
            ribbon = "rbxassetid://132069507632161",
            sakura = "rbxassetid://81755778619404",
            angel = "rbxassetid://97658130917593",
            wind = "rbxassetid://80694081850877",
            flow = "rbxassetid://119913533725648",
            star = "rbxassetid://73754563740680",
        }

        task.spawn(function()
            local assetsToPreload = {}
            for _, assetId in pairs(assetAuras) do assetsToPreload[#assetsToPreload + 1] = assetId end
            if type(assetsToPreload) ~= "table" then return end
            pcall(function()
                ContentProvider:PreloadAsync(assetsToPreload)
            end)
        end)

        local read, readBool, _, readColor = global.makeStatusReaders(status, colorFromConfig)

        local function track(object)
            activeObjects[#activeObjects + 1] = object
            return object
        end

        local function cleanupParticles()
            for index = #activeObjects, 1, -1 do
                local object = activeObjects[index]
                if object then
                    pcall(function() object:Destroy() end)
                end
                activeObjects[index] = nil
            end
        end

        local function getCharacterPart(character, fakePartName)
            local direct = character:FindFirstChild(fakePartName)
            if direct and direct:IsA("BasePart") then return direct end

            local fallbacks = {
                UpperTorso = "Torso", LowerTorso = "Torso",
                LeftUpperArm = "Left Arm", LeftLowerArm = "Left Arm", LeftHand = "Left Arm",
                RightUpperArm = "Right Arm", RightLowerArm = "Right Arm", RightHand = "Right Arm",
                LeftUpperLeg = "Left Leg", LeftLowerLeg = "Left Leg", LeftFoot = "Left Leg",
                RightUpperLeg = "Right Leg", RightLowerLeg = "Right Leg", RightFoot = "Right Leg",
            }

            local fallback = fallbacks[fakePartName]
            if fallback then
                local part = character:FindFirstChild(fallback)
                if part and part:IsA("BasePart") then return part end
            end
            return nil
        end

        local function isEffectObject(object)
            return object:IsA("ParticleEmitter")
                or object:IsA("Beam")
                or object:IsA("Trail")
                or object:IsA("PointLight")
                or object:IsA("SpotLight")
                or object:IsA("SurfaceLight")
                or object:IsA("Attachment")
        end

        local function moveEffectToPart(effect, realPart)
            effect.Name = "ParticleAura_" .. effect.ClassName
            effect.Parent = realPart
            track(effect)
            for _, descendant in ipairs(effect:GetDescendants()) do descendant.Name = "ParticleAura_" .. descendant.ClassName end
        end

        local function applyColor(root, color)
            if not readBool("aura_effects_force_color", true) then return end
            local sequence = ColorSequence.new(color)
            local function apply(object)
                if object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") then
                    object.Color = sequence
                elseif object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") then object.Color = color end
            end
            apply(root)
            for _, descendant in ipairs(root:GetDescendants()) do apply(descendant) end
        end

        local function buildLocalAura(name)
            local model = Instance.new("Model")
            model.Name = name

            local root = Instance.new("Part")
            root.Name = name == "nimb" and "Head" or "HumanoidRootPart"
            root.Parent = model

            local attachment = Instance.new("Attachment")
            attachment.CFrame = CFrame.new(0, name == "nimb" and 1.4 or -2.5, 0)
            attachment.Parent = root

            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "AuraParticles"
            emitter.Brightness = 2
            emitter.Color = ColorSequence.new(readColor("aura_effects_color", Color3.fromRGB(133, 220, 255)))
            emitter.LightEmission = 1
            emitter.Lifetime = NumberRange.new(1, 2)
            emitter.LockedToPart = true
            emitter.Rate = name == "blue heat" and 120 or 35
            emitter.Rotation = NumberRange.new(-360, 360)
            emitter.RotSpeed = NumberRange.new(-180, 180)
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, name == "tornado" and 6 or 0.2),
                NumberSequenceKeypoint.new(0.5, name == "tornado" and 8 or 1.25),
                NumberSequenceKeypoint.new(1, 0),
            })
            emitter.Speed = NumberRange.new(name == "blue heat" and 8 or 1, name == "blue heat" and 14 or 4)
            emitter.SpreadAngle = Vector2.new(360, 360)
            emitter.Texture = name == "heal aura" and "rbxassetid://8047533775"
                or name == "ambient" and "rbxassetid://7216849325"
                or name == "nimb" and "rbxassetid://8819682608"
                or name == "tornado" and "rbxassetid://8553497052"
                or "rbxassetid://11448304274"
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0),
                NumberSequenceKeypoint.new(0.8, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            emitter.Parent = attachment

            if name == "angel wing" then
                local left = Instance.new("Attachment")
                left.CFrame = CFrame.new(-4, 1.5, 2)
                left.Parent = root

                local right = Instance.new("Attachment")
                right.CFrame = CFrame.new(4, 1.5, 2)
                right.Parent = root

                local beam = Instance.new("Beam")
                beam.Attachment0 = attachment
                beam.Attachment1 = left
                beam.Color = emitter.Color
                beam.FaceCamera = true
                beam.LightEmission = 1
                beam.Texture = "rbxassetid://9544400688"
                beam.Width0 = 4
                beam.Width1 = 6
                beam.Parent = root

                local beam2 = beam:Clone()
                beam2.Attachment1 = right
                beam2.Parent = root
            end

            return model
        end

        
        task.spawn(function()
            for name, assetId in pairs(assetAuras) do
                if readBool("aura_effects_load_assets", true) then
                    local ok, objects = pcall(function()
                        return game:GetObjects(assetId)
                    end)
                    if ok and objects and objects[1] then
                        auraModels[name] = objects[1]
                    else
                        auraModels[name] = buildLocalAura(name)
                    end
                else
                    auraModels[name] = buildLocalAura(name)
                end
                task.wait() -- yield between each load so the game doesn't hitch
            end
        end)

        local function getAuraModel(auraName)
            auraName = tostring(auraName or "lightning")
            -- If background loading hasn't finished yet, load it now as fallback
            if not auraModels[auraName] then
                local assetId = assetAuras[auraName]
                if assetId and readBool("aura_effects_load_assets", true) then
                    local ok, objects = pcall(function()
                        return game:GetObjects(assetId)
                    end)
                    if ok and objects and objects[1] then auraModels[auraName] = objects[1] end
                end
                if not auraModels[auraName] then auraModels[auraName] = buildLocalAura(auraName) end
            end
            return auraModels[auraName]
        end

        local function selectedAuras()
            local selected = read("aura_effects_selected", "lightning")
            if typeof(selected) == "table" then return selected end
            return {tostring(selected or "lightning")}
        end

        local function applyAuraModel(character, auraModel)
            if not character or not auraModel then return end

            applyColor(auraModel, readColor("aura_effects_color", Color3.fromRGB(133, 220, 255)))

            local cloned = auraModel:Clone()
            local moved = 0
            local fakeParts = {}

            if cloned:IsA("BasePart") then fakeParts[#fakeParts + 1] = cloned end

            for _, descendant in ipairs(cloned:GetDescendants()) do
                if descendant:IsA("BasePart") then fakeParts[#fakeParts + 1] = descendant end
            end

            for _, fakePart in ipairs(fakeParts) do
                local realPart = getCharacterPart(character, fakePart.Name)
                if realPart then
                    for _, child in ipairs(fakePart:GetChildren()) do
                        if not child:IsA("BasePart") then
                            moveEffectToPart(child, realPart)
                            moved += 1
                        end
                    end
                end
            end

            if moved == 0 then
                local targetPart = character:FindFirstChild("HumanoidRootPart")
                    or character:FindFirstChild("UpperTorso")
                    or character:FindFirstChild("Torso")
                    or character:FindFirstChild("Head")

                if targetPart then
                    for _, descendant in ipairs(cloned:GetDescendants()) do
                        if descendant.Parent and isEffectObject(descendant) then
                            moveEffectToPart(descendant, targetPart)
                            moved += 1
                        end
                    end
                end
            end

            cloned:Destroy()
        end

        local function currentKey()
            local color = readColor("aura_effects_color", Color3.fromRGB(133, 220, 255))
            return table.concat({
                tostring(readBool("aura_effects_enabled", false)),
                table.concat(selectedAuras(), ","),
                tostring(readBool("aura_effects_force_color", true)),
                tostring(readBool("aura_effects_load_assets", true)),
                tostring(color.R),
                tostring(color.G),
                tostring(color.B),
            }, "|")
        end

        local function applySelectedAuras()
            cleanupParticles()
            if not readBool("aura_effects_enabled", false) then return end

            local character = player.Character
            if not character then return end

            local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
            if not root then return end

            for _, auraName in ipairs(selectedAuras()) do applyAuraModel(character, getAuraModel(auraName)) end
        end

        global.registry.aura_effects_reload = function()
            lastKey = nil
            applySelectedAuras()
        end

        connections[#connections + 1] = player.CharacterAdded:Connect(function()
            task.wait(1)
            lastKey = nil
            applySelectedAuras()
        end)

        createloop(0.25, function()
            local key = currentKey()
            if key ~= lastKey then
                lastKey = key
                applySelectedAuras()
            end
        end)
    end

    createAuraEffects()
    local function createBulletTracers()
        local status = global.ui_status
        local colorFromConfig = global.ui and global.ui.colorFromConfig

        local read, readBool, readNumber, readColor, readString = global.makeStatusReaders(status, colorFromConfig)

        -- >> ( tracer resources )

        local tracerFolder = Instance.new("Folder")
        tracerFolder.Name = "CrewbattlerTracers"
        tracerFolder.Parent = workspace

        local function makeBeamTemplate(props)
            local beam = Instance.new("Beam")
            for key, value in pairs(props) do beam[key] = value end
            return beam
        end

        local beamTemplates = {
            laser = makeBeamTemplate({
                FaceCamera = true,
                TextureSpeed = 1.5,
                Width0 = 0.25,
                Width1 = 0.25,
                TextureLength = 2,
                LightEmission = 3,
                Brightness = 2.5,
                Texture = "rbxassetid://12781800668",
            }),
            light = makeBeamTemplate({
                FaceCamera = true,
                TextureSpeed = 2,
                Width0 = 0.25,
                Width1 = 0.25,
                LightInfluence = 1,
                LightEmission = 3,
                Segments = 1,
                Texture = "http://www.roblox.com/asset/?id=2382169232",
                TextureLength = 15,
                TextureMode = Enum.TextureMode.Wrap,
            }),
            flow = makeBeamTemplate({
                FaceCamera = true,
                TextureSpeed = 2.5,
                Width0 = 0.2,
                Width1 = 0.2,
                LightEmission = 3,
                Brightness = 5,
                Texture = "rbxassetid://12788927812",
            }),
        }

        -- >> ( endpoint resolver )

        local MAX_DIST = 2000

        local function resolveEndpoint(startPos, direction)
            local endpoint = startPos + direction * MAX_DIST
            pcall(function()
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                local filter = {tracerFolder}
                local char = player and player.Character
                if char then filter[#filter + 1] = char end
                params.FilterDescendantsInstances = filter
                params.IgnoreWater = true
                local result = workspace:Raycast(startPos, direction * MAX_DIST, params)
                if result then endpoint = result.Position end
            end)
            return endpoint
        end

        -- >> ( beam tracer )

        local function fireBeamTracer(startPos, endPos, cfg)
            local template = beamTemplates[cfg.style] or beamTemplates.laser
            local beam = template:Clone()
            beam.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, cfg.color),
                ColorSequenceKeypoint.new(1, cfg.gradient_color),
            })
            beam.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, cfg.transparency),
                NumberSequenceKeypoint.new(1, cfg.gradient_transparency),
            })

            local a0 = Instance.new("Attachment")
            a0.CFrame = CFrame.new(startPos)
            a0.Parent = workspace.Terrain

            local a1 = Instance.new("Attachment")
            a1.CFrame = CFrame.new(endPos)
            a1.Parent = workspace.Terrain

            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Parent = tracerFolder

            local startTransp = cfg.transparency
            local endTransp = cfg.gradient_transparency
            local elapsed = 0
            local fade = 0.2
            local lifetime = cfg.lifetime

            local conn
            conn = runservice.Heartbeat:Connect(function(dt)
                elapsed += dt
                if elapsed > lifetime then
                    local t = math.clamp((elapsed - lifetime) / fade, 0, 1)
                    beam.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, startTransp + (1 - startTransp) * t),
                        NumberSequenceKeypoint.new(1, endTransp + (1 - endTransp) * t),
                    })
                end
                if elapsed >= lifetime + fade then
                    conn:Disconnect()
                    beam:Destroy()
                    a0:Destroy()
                    a1:Destroy()
                end
            end)
        end

        -- >> ( line tracer )

        local function fireLineTracer(startPos, endPos, cfg)
            local ok, line = pcall(function()
                return Drawing.new("Line")
            end)
            if not ok or not line then return fireBeamTracer(startPos, endPos, cfg) end
            local outline = Drawing.new("Line")

            local baseTransp = 1 - cfg.transparency
            outline.Color = cfg.outline_color
            outline.Thickness = cfg.outline_thickness
            outline.Transparency = 1 - cfg.outline_transparency
            outline.Visible = true

            line.Color = cfg.color
            line.Thickness = cfg.thickness
            line.Transparency = baseTransp
            line.Visible = true

            local elapsed = 0
            local fade = 0.3
            local lifetime = cfg.lifetime

            local conn
            conn = runservice.Heartbeat:Connect(function(dt)
                elapsed += dt
                local camera = workspace.CurrentCamera
                if not camera then return end

                local p1, onScreen1 = camera:WorldToViewportPoint(startPos)
                local p2, onScreen2 = camera:WorldToViewportPoint(endPos)

                if not onScreen1 and not onScreen2 then
                    line.Visible = false
                    outline.Visible = false
                else
                    line.Visible = true
                    outline.Visible = true

                    local size = camera.ViewportSize
                    local xHalf = size.X / 2
                    local yHalf = size.Y / 2

                    local function fixBehind(p)
                        if p.Z < 0 then
                            return Vector2.new(
                                math.clamp(xHalf + (xHalf - p.X), 0, size.X),
                                math.clamp(yHalf + (yHalf - p.Y), 0, size.Y)
                            )
                        end
                        return Vector2.new(p.X, p.Y)
                    end

                    local from = fixBehind(p1)
                    local to = fixBehind(p2)

                    if elapsed > lifetime then
                        local t = math.clamp((elapsed - lifetime) / fade, 0, 1)
                        local newTransp = baseTransp + (0 - baseTransp) * t
                        line.Transparency = newTransp
                        outline.Transparency = newTransp
                        from = from + (to - from) * t
                    end

                    line.From = from
                    line.To = to

                    local offset = to - from
                    if offset.Magnitude > 0 then
                        offset = (from - to).Unit
                        outline.From = from + offset
                        outline.To = to - offset
                    else
                        outline.From = from
                        outline.To = to
                    end
                end

                if elapsed >= lifetime + fade then
                    conn:Disconnect()
                    line:Remove()
                    outline:Remove()
                end
            end)
        end

        -- >> ( target resolution )

        local function resolveTargetPart(target)
            if not target or typeof(target) ~= "Instance" then return nil end
            if target:IsA("Player") then target = target.Character end
            if not target then return nil end
            if target:IsA("Model") then return target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart end
            if target:IsA("BasePart") then return target end
            return nil
        end

        -- When silent aim / a forced target is active the local bullet is redirected
        -- after Emit, so trace to that target instead of the mouse direction.
        local function resolveAimTargetPosition()
            local target
            local aimbot = global.aimbot
            if aimbot and aimbot.force_target then
                target = aimbot.force_target
            elseif global.ui_status.master_switch_silentaim then target = client.reg and client.reg.getClosestPlayerByFov end
            local part = resolveTargetPart(target)
            return part and part.Position or nil
        end

        -- >> ( dispatch )

        local function fireTracer(startPos, direction, cfg, targetPos)
            if not startPos then return end
            local endPos = targetPos
            if not endPos then
                if not direction then return end
                endPos = resolveEndpoint(startPos, direction)
            end
            if cfg.type == "line" then
                fireLineTracer(startPos, endPos, cfg)
            else
                fireBeamTracer(startPos, endPos, cfg)
            end
        end

        -- >> ( config builders )

        local function buildConfig(prefix, defaults)
            local color
            if readBool(prefix .. "rainbow", false) then
                color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            else
                color = readColor(prefix .. "color", defaults.color)
            end
            return {
                type = readString(prefix .. "type", defaults.type),
                style = readString(prefix .. "style", defaults.style),
                color = color,
                gradient_color = readColor(prefix .. "gradient_color", defaults.gradient_color),
                outline_color = readColor(prefix .. "outline_color", defaults.outline_color),
                transparency = math.clamp(readNumber(prefix .. "transparency", defaults.transparency), 0, 1),
                gradient_transparency = math.clamp(readNumber(prefix .. "gradient_transparency", defaults.gradient_transparency), 0, 1),
                outline_transparency = math.clamp(readNumber(prefix .. "outline_transparency", defaults.outline_transparency), 0, 1),
                lifetime = math.max(readNumber(prefix .. "lifetime", defaults.lifetime), 0.05),
                thickness = math.clamp(readNumber(prefix .. "thickness", defaults.thickness), 1, 8),
                outline_thickness = math.clamp(readNumber(prefix .. "outline_thickness", defaults.outline_thickness), 1, 10),
            }
        end

        local localDefaults = {
            type = "beam",
            style = "flow",
            color = Color3.fromRGB(255, 50, 50),
            gradient_color = Color3.fromRGB(255, 150, 50),
            outline_color = Color3.fromRGB(255, 255, 255),
            transparency = 0,
            gradient_transparency = 0.6,
            outline_transparency = 0.5,
            lifetime = 0.3,
            thickness = 1,
            outline_thickness = 3,
        }

        local enemyDefaults = {
            type = "beam",
            style = "light",
            color = Color3.fromRGB(50, 150, 255),
            gradient_color = Color3.fromRGB(150, 50, 255),
            outline_color = Color3.fromRGB(200, 200, 255),
            transparency = 0,
            gradient_transparency = 0.6,
            outline_transparency = 0.5,
            lifetime = 0.4,
            thickness = 1,
            outline_thickness = 3,
        }

        -- >> ( emit hook )

        local function patchBulletEmitter()
            local bulletEmitter = client.modules and client.modules.bulletEmitter
            if not bulletEmitter or bulletEmitter.CrewbattlerBulletTracersHooked then return end

            local originalEmit = bulletEmitter.Emit
            if type(originalEmit) ~= "function" then return end

            bulletEmitter.CrewbattlerBulletTracersHooked = true
            bulletEmitter.Emit = function(self, startPos, direction, speed, ...)
                local result = originalEmit(self, startPos, direction, speed, ...)
                pcall(function()
                    if self.Local == true then
                        if readBool("bullet_tracers_enabled", false) then fireTracer(startPos, direction, buildConfig("bullet_tracers_", localDefaults), resolveAimTargetPosition()) end
                    elseif readBool("bullet_tracers_enemy_enabled", false) then fireTracer(startPos, direction, buildConfig("bullet_tracers_enemy_", enemyDefaults)) end
                end)
                return result
            end
        end

        patchBulletEmitter()

        -- >> ( plasma tracers )
        -- Plasma is hitscan and never goes through BulletEmitter.Emit, so hook the plasma
        -- guns' ShootSound (fires on each local plasma shot, exposes self.Tip) and draw a
        -- tracer straight to the current aim target. No movement prediction: it's hitscan.
        local function patchPlasmaGun()
            for _, name in ipairs({"PlasmaPistol", "PlasmaShotgun", "PlasmaGun"}) do
                task.spawn(function()
                    local ok, gunModule = pcall(function() return require(repl.Game.Item[name]) end)
                    if not ok or type(gunModule) ~= "table" or type(gunModule.ShootSound) ~= "function" or rawget(gunModule, "CrewbattlerPlasmaTracerHooked") then return end
                    gunModule.CrewbattlerPlasmaTracerHooked = true
                    local original = gunModule.ShootSound
                    gunModule.ShootSound = function(self, ...)
                        pcall(function()
                            if self and self.Local == true and readBool("bullet_tracers_enabled", false) then
                                local tip = self.Tip
                                local startPos
                                if tip then
                                    if tip:IsA("Attachment") then startPos = tip.WorldPosition
                                    elseif tip:IsA("BasePart") then startPos = tip.Position end
                                end
                                if startPos then
                                    local targetPos = resolveAimTargetPosition()
                                    local direction
                                    if not targetPos then
                                        local cam = workspace.CurrentCamera
                                        direction = cam and cam.CFrame.LookVector or nil
                                    end
                                    fireTracer(startPos, direction, buildConfig("bullet_tracers_", localDefaults), targetPos)
                                end
                            end
                        end)
                        return original(self, ...)
                    end
                end)
            end
        end
        patchPlasmaGun()
    end
    createBulletTracers()
    local function createTargetHud()
        local indicator
        local images
        pcall(function()
            images = require(repl.Resource.Settings).Images
        end)

        -- create lazily so the library/window is fully ready; TargetIndicator is a
        -- Library method (parents to Library.Holder), so call it on the Library object
        local function ensureIndicator()
            if indicator then return indicator end
            local lib = global.ui and global.ui.Library
            if not lib or type(lib.TargetIndicator) ~= "function" then return nil end
            local ok = pcall(function()
                indicator = lib:TargetIndicator({
                    Name = "target<font color=\"rgb(84, 0, 255)\"> info</font>",
                })
            end)
            if not ok or not indicator then
                indicator = nil
                return nil
            end
            pcall(function()
                indicator:SetVisibility(false)
            end)
            return indicator
        end

        local function resolveTargetPlayer()
            local aimbot = global.aimbot
            local forced = aimbot and aimbot.force_target
            if typeof(forced) == "Instance" and forced:IsA("Player") then return forced end
            local t = client.reg and client.reg.getClosestPlayerByFov
            if typeof(t) == "Instance" and t:IsA("Player") then return t end
            return nil
        end

        local lastTarget, lastSig, lastCharacter
        local function hide()
            lastTarget = nil
            lastSig = nil
            lastCharacter = nil
            if indicator then
                pcall(function()
                    indicator:SetVisibility(false)
                end)
            end
        end

        local function loop()
            if not global.ui_status.target_hud then
                hide()
                return false
            end
            local target = resolveTargetPlayer()
            -- SetTarget reads Target.Character.Humanoid, so require a live character
            local character = target and target.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not target or not humanoid then
                hide()
                return false
            end
            local ind = ensureIndicator()
            if not ind then return false end
            indicator = ind
            pcall(function()
                indicator:SetVisibility(true)
            end)
            -- SetTarget caches the target's Humanoid, so re-bind when the player OR their
            -- character changes (respawn) -- otherwise health stays stuck at 0 after death
            if target ~= lastTarget or character ~= lastCharacter then
                lastTarget = target
                lastCharacter = character
                lastSig = nil
                pcall(function()
                    indicator:SetTarget(target)
                end)
            end
            -- rebuild the weapon icons whenever the target's items change
            local names = {}
            local folder = target:FindFirstChild("Folder")
            if folder then
                for _, v in next, folder:GetChildren() do names[#names + 1] = v.Name end
            end
            table.sort(names)
            local sig = table.concat(names, ",")
            if sig ~= lastSig then
                lastSig = sig
                pcall(function()
                    indicator:ClearItems()
                    if images then
                        for _, name in next, names do
                            local icon = images[name]
                            if icon then indicator:AddItem(icon) end
                        end
                    end
                end)
            end
        end
        createloop(0.2, loop)
    end
    createTargetHud()
    local function createHitNotifications()
        -- The server fires DisplayDamageDraw only to the player who dealt the damage
        -- (that's why the damage-number GUI only shows on your screen), so listening to
        -- it guarantees these notifications are for MY damage only.
        task.spawn(function()
            local remote = repl:WaitForChild("DisplayDamageDraw", 60)
            if not remote then return end
            remote.OnClientEvent:Connect(function(target, part, damage, flags)
                if not global.ui_status.hit_notifications then return end
                -- DisplayDamageDraw also fires on target select with no damage; ignore those
                if (tonumber(damage) or 0) <= 0 then return end
                pcall(function()
                    flags = type(flags) == "table" and flags or {}
                    local dmg = math.floor((tonumber(damage) or 0) + 0.5)
                    local model
                    if typeof(part) == "Instance" then model = part:FindFirstAncestorWhichIsA("Model") end
                    if not model and typeof(target) == "Instance" then model = target:FindFirstAncestorWhichIsA("Model") or (target:IsA("Model") and target or nil) end
                    local name = "target"
                    if model then
                        local plr = players:GetPlayerFromCharacter(model)
                        name = plr and plr.DisplayName or model.Name
                    end
                    local suffix = ""
                    if flags.isHeadshot then
                        suffix = " (headshot)"
                    elseif flags.isWallbang then
                        suffix = " (wallbang)"
                    elseif flags.isVehicleDamage then suffix = " (vehicle)" end
                    local lib = global.ui and global.ui.Library
                    if lib and type(lib.Notification) == "function" then
                        lib:Notification({
                            Name = ("Hit %s for %d%s"):format(name, dmg, suffix),
                            Time = 3,
                        })
                    end
                end)
            end)
        end)
    end
    createHitNotifications()
    local function createCustomSounds()
        local soundService = CloneRef(game:GetService("SoundService"))
        local debrisService = CloneRef(game:GetService("Debris"))

        -- the dropdowns are built before the file APIs/folders are ready, so re-scan
        -- and repopulate them now that we're past load
        local function refreshDropdown(flag, folder)
            local data = global.getSoundAssets and global.getSoundAssets(folder)
            local control = global.ui and global.ui.controls and global.ui.controls[flag]
            if data and #data.names > 0 and control and type(control.reload) == "function" then
                control.reload(data.names)
                -- re-apply the saved config selection now that the real options exist
                -- (at config-load time the dropdown only had a "none" placeholder, so the
                -- saved value was rejected and the selection appeared to reset to none)
                local saved
                if control.Flag then
                    local pending = global.ui and global.ui.pendingControlConfig
                    if type(pending) == "table" then saved = pending[control.Flag] end
                    if saved == nil and Library and Library.Flags then saved = Library.Flags[control.Flag] end
                end
                if type(saved) == "table" then saved = saved[1] end
                if type(saved) == "string" and table.find(data.names, saved) and type(control.Set) == "function" then
                    pcall(control.Set, saved)
                end
            end
        end
        refreshDropdown("bullet_sound_value", "bullet sounds")
        refreshDropdown("hit_sound_value", "hit sounds")
        -- load the per-category sounds from disk (file APIs are ready now), then show the
        -- stored sound for the currently-selected gun category in the populated dropdown
        if type(global.loadBulletSoundMap) == "function" then pcall(global.loadBulletSoundMap) end
        if type(global.syncBulletSoundView) == "function" then pcall(global.syncBulletSoundView) end

        local function resolveName(value)
            if type(value) == "table" then value = value[1] end
            return value
        end
        local function resolveAsset(folder, value)
            local data = global.getSoundAssets and global.getSoundAssets(folder) or nil
            local name = resolveName(value)
            return data and name and data.map[name] or nil
        end

        -- >> ( custom bullet sound )
        -- Each gun plays its shoot sound differently (and plasma hardcodes it), so
        -- hook each gun module's ShootSound and play our own for the local player's
        -- gun. Each gun category uses its own sound from bullet_sound_map, so all
        -- configured categories play their own sound simultaneously.
        do
            local moduleCategory = {
                Pistol = "pistol", PlasmaPistol = "pistol", NerfPistol = "pistol",
                Shotgun = "shotgun", PlasmaShotgun = "shotgun",
                Sniper = "sniper",
                Rifle = "rifle", AK47 = "rifle",
                Uzi = "smg",
                Revolver = "revolver", NerfRevolver = "revolver",
                Flintlock = "flintlock",
            }
            for name, category in pairs(moduleCategory) do
                task.spawn(function()
                    local ok, gunModule = pcall(function()
                        return require(repl.Game.Item[name])
                    end)
                    if not ok or type(gunModule) ~= "table" or type(gunModule.ShootSound) ~= "function" or rawget(gunModule, "CrewbattlerShootSoundHooked") then return end
                    gunModule.CrewbattlerShootSoundHooked = true
                    local original = gunModule.ShootSound
                    gunModule.ShootSound = function(self, ...)
                        if global.ui_status.local_bullet_sound and self and self.Local == true then
                            local soundName = global.bullet_sound_map and global.bullet_sound_map[category]
                            local id = soundName and resolveAsset("bullet sounds", soundName)
                            if id and self.Tip then
                                pcall(function()
                                    local sound = Instance.new("Sound")
                                    sound.SoundId = id
                                    sound.Volume = (tonumber(global.ui_status.bullet_sound_volume) or 100) / 100
                                    sound.Name = "\0"
                                    sound.Parent = self.Tip
                                    sound:Play()
                                    debrisService:AddItem(sound, 3)
                                end)
                                return
                            end
                        end
                        return original(self, ...)
                    end
                end)
            end
        end

        -- >> ( hit sound )
        -- DisplayDamageDraw fires only to the player who dealt the damage
        task.spawn(function()
            local remote = repl:WaitForChild("DisplayDamageDraw", 60)
            if not remote then return end
            remote.OnClientEvent:Connect(function(target, part, damage)
                if not global.ui_status.hit_sound then return end
                -- only on real damage; DisplayDamageDraw also fires on target select with
                -- 0/no damage, which was playing the hit sound without a shot landing
                if (tonumber(damage) or 0) <= 0 then return end
                local id = resolveAsset("hit sounds", global.ui_status.hit_sound_value)
                if not id then return end
                pcall(function()
                    local sound = Instance.new("Sound")
                    sound.SoundId = id
                    sound.Volume = (tonumber(global.ui_status.hit_sound_volume) or 100) / 100
                    sound.PlayOnRemove = true
                    sound.Parent = soundService
                    sound:Destroy()
                end)
            end)
        end)
    end
    createCustomSounds()
    local function createWorldVisuals()
        local soundService = CloneRef(game:GetService("SoundService"))
        local materialService = CloneRef(game:GetService("MaterialService"))
        local colorFromConfig = global.ui and global.ui.colorFromConfig
        local status = global.ui_status

        local function findFirstChildOfClass(parent, class)
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA(class) then return child end
            end
            return nil
        end

        local sky = findFirstChildOfClass(lighting, "Sky") or Instance.new("Sky")
        sky.Parent = lighting
        local colorCorrection = findFirstChildOfClass(lighting, "ColorCorrectionEffect")
        local original = {
            ClockTime = lighting.ClockTime,
            Technology = lighting.Technology,
            Ambient = lighting.Ambient,
            OutdoorAmbient = lighting.OutdoorAmbient,
            Saturation = colorCorrection and colorCorrection.Saturation or 0,
            Contrast = colorCorrection and colorCorrection.Contrast or 0,
            TintColor = colorCorrection and colorCorrection.TintColor or Color3.fromRGB(255, 255, 255),
            SkyboxBk = sky.SkyboxBk,
            SkyboxDn = sky.SkyboxDn,
            SkyboxFt = sky.SkyboxFt,
            SkyboxLf = sky.SkyboxLf,
            SkyboxRt = sky.SkyboxRt,
            SkyboxUp = sky.SkyboxUp,
            SunTextureId = sky.SunTextureId,
            MoonTextureId = sky.MoonTextureId,
        }

        local soundIds = {
            ["windy winter"] = "rbxassetid://6046340391",
            ["light rain"] = "rbxassetid://18862087062",
            thunderstorm = "rbxassetid://9112853422",
            raindrop = "rbxassetid://122813811029978",
            night = "rbxassetid://179507208",
            space = "rbxassetid://140533822783920",
            day = "rbxassetid://6189453706",
        }

        local texturePacks = {
            minecraft = {
                Slate = "http://www.roblox.com/asset/?id=8676746437",
                Grass = "http://www.roblox.com/asset/?id=9267183930",
                Sand = "http://www.roblox.com/asset/?id=12624140843",
                Wood = "http://www.roblox.com/asset/?id=3258599312",
                Brick = "http://www.roblox.com/asset/?id=10777285622",
                Concrete = "http://www.roblox.com/asset/?id=15622710576",
                CorrodedMetal = "rbxassetid://78612695839404",
                Metal = "http://www.roblox.com/asset/?id=121650613091353",
                WoodPlanks = "http://www.roblox.com/asset/?id=8676581022",
            },
        }

        local function S(b, d, ft, l, r, u) return {SkyboxBk = b, SkyboxDn = d, SkyboxFt = ft, SkyboxLf = l, SkyboxRt = r, SkyboxUp = u} end

        local skyboxes = {
            ["black storm"] = S("rbxassetid://15502511288", "rbxassetid://15502508460", "rbxassetid://15502510289", "rbxassetid://15502507918", "rbxassetid://15502509398", "rbxassetid://15502511911"),
            ["blue space"] = S("rbxassetid://15536110634", "rbxassetid://15536112543", "rbxassetid://15536116141", "rbxassetid://15536114370", "rbxassetid://15536118762", "rbxassetid://15536117282"),
            realistic = S("rbxassetid://653719502", "rbxassetid://653718790", "rbxassetid://653719067", "rbxassetid://653719190", "rbxassetid://653718931", "rbxassetid://653719321"),
            stormy = S("http://www.roblox.com/asset/?id=18703245834", "http://www.roblox.com/asset/?id=18703243349", "http://www.roblox.com/asset/?id=18703240532", "http://www.roblox.com/asset/?id=18703237556", "http://www.roblox.com/asset/?id=18703235430", "http://www.roblox.com/asset/?id=18703232671"),
            pink = S("rbxassetid://12216109205", "rbxassetid://12216109875", "rbxassetid://12216109489", "rbxassetid://12216110170", "rbxassetid://12216110471", "rbxassetid://12216108877"),
            minecraft = S("rbxassetid://1876545003", "rbxassetid://1876544331", "rbxassetid://1876542941", "rbxassetid://1876543392", "rbxassetid://1876543764", "rbxassetid://1876544642"),
            ["purple day"] = S("rbxassetid://296908715", "rbxassetid://296908724", "rbxassetid://296908740", "rbxassetid://296908755", "rbxassetid://296908764", "rbxassetid://296908769"),
            ["red night"] = S("rbxassetid://401664839", "rbxassetid://401664862", "rbxassetid://401664960", "rbxassetid://401664881", "rbxassetid://401664901", "rbxassetid://401664936"),
            trollge = S("rbxassetid://6155393905", "rbxassetid://6155393905", "rbxassetid://6155393905", "rbxassetid://6155393905", "rbxassetid://6155393905", "rbxassetid://6155393905"),
            night = S("rbxassetid://48020371", "rbxassetid://48020144", "rbxassetid://48020234", "rbxassetid://48020211", "rbxassetid://48020254", "rbxassetid://48020383"),
            space = S("rbxassetid://149397692", "rbxassetid://149397686", "rbxassetid://149397697", "rbxassetid://149397684", "rbxassetid://149397688", "rbxassetid://149397702"),
            ["vibe morning"] = S("rbxassetid://1417494030", "rbxassetid://1417494146", "rbxassetid://1417494253", "rbxassetid://1417494402", "rbxassetid://1417494499", "rbxassetid://1417494643"),
            ["vibe night"] = S("rbxassetid://5084575798", "rbxassetid://5084575916", "rbxassetid://5103949679", "rbxassetid://5103948542", "rbxassetid://5103948784", "rbxassetid://5084576400"),
            ["purple splash"] = S("rbxassetid://8539982183", "rbxassetid://8539981943", "rbxassetid://8539981721", "rbxassetid://8539981424", "rbxassetid://8539980766", "rbxassetid://8539981085"),
            ["green space"] = S("rbxassetid://159248188", "rbxassetid://159248183", "rbxassetid://159248187", "rbxassetid://159248173", "rbxassetid://159248192", "rbxassetid://159248176"),
            snowy = S("rbxassetid://155657655", "rbxassetid://155674246", "rbxassetid://155657609", "rbxassetid://155657671", "rbxassetid://155657619", "rbxassetid://155674931"),
            spongebob = S("rbxassetid://10287764626", "rbxassetid://10287766382", "rbxassetid://10287764626", "rbxassetid://10287763421", "rbxassetid://10287764626", "rbxassetid://10287767597"),
            ["pink day"] = S("rbxassetid://271042516", "rbxassetid://271077243", "rbxassetid://271042556", "rbxassetid://271042310", "rbxassetid://271042467", "rbxassetid://271077958"),
            ["alien red"] = S("rbxassetid://1012890", "rbxassetid://1012891", "rbxassetid://1012887", "rbxassetid://1012889", "rbxassetid://1012888", "rbxassetid://1014449"),
            ["walls of autumn"] = S("rbxassetid://7123244709", "rbxassetid://7123246497", "rbxassetid://7123255895", "rbxassetid://7123257992", "rbxassetid://7123279103", "rbxassetid://7123281828"),
            ["cold wintriness"] = S("rbxassetid://7123754562", "rbxassetid://7123756028", "rbxassetid://7123757422", "rbxassetid://7123758897", "rbxassetid://7123760563", "rbxassetid://7123762364"),
            oblivion = S("rbxassetid://7123654189", "rbxassetid://7123657455", "rbxassetid://7123662047", "rbxassetid://7123664533", "rbxassetid://7123666598", "rbxassetid://7123668994"),
            ["hell sky"] = S("rbxassetid://437430787", "rbxassetid://437430804", "rbxassetid://437430543", "rbxassetid://437430732", "rbxassetid://437430747", "rbxassetid://437430771"),
            ["starry night"] = S("rbxassetid://8291078911", "rbxassetid://8291077403", "rbxassetid://8291081613", "rbxassetid://8291074004", "rbxassetid://8291080353", "rbxassetid://8291075054"),
            sunset = S("rbxassetid://150939022", "rbxassetid://150939038", "rbxassetid://150939047", "rbxassetid://150939056", "rbxassetid://150939063", "rbxassetid://150939082"),
            anime = S("rbxassetid://7643700666", "rbxassetid://7643743687", "rbxassetid://7644304186", "rbxassetid://7644288724", "rbxassetid://7643700819", "rbxassetid://7643757404"),
            ["cartoon sky"] = S("rbxassetid://6778646360", "rbxassetid://6778658683", "rbxassetid://6778648039", "rbxassetid://6778649136", "rbxassetid://6778650519", "rbxassetid://6778658364"),
            omori = S("rbxassetid://8767416629", "rbxassetid://8767416629", "rbxassetid://8767416629", "rbxassetid://8767416629", "rbxassetid://8767416629", "rbxassetid://8767416629"),
            ["clear day"] = S("rbxassetid://591058823", "rbxassetid://591059876", "rbxassetid://591058104", "rbxassetid://591057861", "rbxassetid://591057625", "rbxassetid://591059642"),
            desert = S("rbxassetid://161319957", "rbxassetid://161319965", "rbxassetid://161319970", "rbxassetid://161319983", "rbxassetid://161319989", "rbxassetid://161319996"),
            crimson = S("rbxassetid://15832429892", "rbxassetid://15832430998", "rbxassetid://15832430210", "rbxassetid://15832430671", "rbxassetid://15832431198", "rbxassetid://15832429401"),
            ["pumpkin hill"] = S("rbxassetid://11202510597", "rbxassetid://11202510255", "rbxassetid://11202509993", "rbxassetid://11202510806", "rbxassetid://11202511066", "rbxassetid://11202509704"),
            ["earth space"] = S("rbxassetid://15753305495", "rbxassetid://15753362674", "rbxassetid://15753305823", "rbxassetid://15753310707", "rbxassetid://15753304774", "rbxassetid://15753304473"),
            ["blue abyss"] = S("rbxassetid://16269815885", "rbxassetid://16269839652", "rbxassetid://16269798011", "rbxassetid://16269813852", "rbxassetid://16269814948", "rbxassetid://16269829700"),
            ["green aurora"] = S("http://www.roblox.com/asset/?id=16563478983", "http://www.roblox.com/asset/?id=16563481302", "http://www.roblox.com/asset/?id=16563484084", "http://www.roblox.com/asset/?id=16563485362", "http://www.roblox.com/asset/?id=16563487078", "http://www.roblox.com/asset/?id=16563489821"),
            underwater = S("http://www.roblox.com/asset/?id=227635868", "http://www.roblox.com/asset/?id=227635921", "http://www.roblox.com/asset/?id=227635954", "http://www.roblox.com/asset/?id=227635974", "http://www.roblox.com/asset/?id=227635990", "http://www.roblox.com/asset/?id=227636031"),
            ["orange fog"] = S("http://www.roblox.com/asset/?id=458016711", "http://www.roblox.com/asset/?id=458016826", "http://www.roblox.com/asset/?id=458016532", "http://www.roblox.com/asset/?id=458016655", "http://www.roblox.com/asset/?id=458016782", "http://www.roblox.com/asset/?id=458016792"),
            ["purple fog"] = S("http://www.roblox.com/asset/?id=17279854976", "http://www.roblox.com/asset/?id=17279856318", "http://www.roblox.com/asset/?id=17279858447", "http://www.roblox.com/asset/?id=17279860360", "http://www.roblox.com/asset/?id=17279862234", "http://www.roblox.com/asset/?id=17279864507"),
            ["fade night"] = S("http://www.roblox.com/asset/?id=16888843486", "http://www.roblox.com/asset/?id=16888845693", "http://www.roblox.com/asset/?id=16888848245", "http://www.roblox.com/asset/?id=16888850949", "http://www.roblox.com/asset/?id=16888854243", "http://www.roblox.com/asset/?id=16888857144"),
            ["summer day"] = S("http://www.roblox.com/asset/?version=1&id=135483466", "http://www.roblox.com/asset/?version=1&id=135483484", "http://www.roblox.com/asset/?version=1&id=135483461", "http://www.roblox.com/asset/?version=1&id=135483495", "http://www.roblox.com/asset/?version=1&id=135483499", "http://www.roblox.com/asset/?version=1&id=135483475"),
            ["green nebula"] = S("http://www.roblox.com/asset/?id=47974894", "http://www.roblox.com/asset/?id=47974690", "http://www.roblox.com/asset/?id=47974821", "http://www.roblox.com/asset/?id=47974776", "http://www.roblox.com/asset/?id=47974859", "http://www.roblox.com/asset/?id=47974909"),
        }

        local world = {
            Sound = nil,
            Atmosphere = nil,
            WeatherPart = nil,
            WeatherConnection = nil,
            WeatherKey = nil,
            TextureConnection = nil,
            LockConnection = nil,
            TextureVariants = {},
            TextureColors = {},
            TexturesEnabled = false,
            Last = {},
            ColorCorrectionTouched = false,
            Applying = false,
        }

        local read, readBool, readNumber, readColor = global.makeStatusReaders(status, colorFromConfig)

        local function worldVisualsEnabled()
            return readBool("world_background_noise_enabled", false)
                or readBool("world_lighting_mode_enabled", false)
                or readBool("world_time_enabled", false)
                or readBool("world_atmosphere_enabled", false)
                or readBool("world_saturation_enabled", false)
                or readBool("world_contrast_enabled", false)
                or readBool("world_tint_enabled", false)
                or readBool("world_textures_enabled", false)
                or readBool("world_weather_enabled", false)
                or readBool("world_ambient_enabled", false)
                or readBool("world_skybox_enabled", false)
                or world.Sound ~= nil
                or world.Atmosphere ~= nil
                or world.ColorCorrectionTouched
                or world.TexturesEnabled
                or world.WeatherPart ~= nil
                or world.Last.LightingMode
                or world.Last.WorldTime
                or world.Last.Ambient
                or world.Last.Skybox
        end

        local function ensureSky()
            if sky and sky.Parent then return sky end
            sky = findFirstChildOfClass(lighting, "Sky") or Instance.new("Sky")
            sky.Parent = lighting
            return sky
        end

        local function ensureColorCorrection()
            if colorCorrection and colorCorrection.Parent then return colorCorrection end
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Name = "CrewbattlerWorldColorCorrection"
            colorCorrection.Parent = lighting
            return colorCorrection
        end

        local function applyBackgroundNoise()
            if not readBool("world_background_noise_enabled", false) then
                if world.Sound then
                    world.Sound:Destroy()
                    world.Sound = nil
                end
                return
            end
            if not world.Sound then
                world.Sound = Instance.new("Sound")
                world.Sound.Name = "WorldVisualsBGNoise"
                world.Sound.Looped = true
                world.Sound.Parent = soundService
            end
            world.Sound.SoundId = soundIds[tostring(read("world_background_noise_sound", "raindrop"))] or ""
            world.Sound.Volume = readNumber("world_background_noise_volume", 25) / 65
            if not world.Sound.IsPlaying then world.Sound:Play() end
        end

        local function applyLightingMode()
            if not readBool("world_lighting_mode_enabled", false) then
                if world.Last.LightingMode then
                    pcall(function()
                        lighting.Technology = original.Technology
                    end)
                    world.Last.LightingMode = false
                end
                return
            end
            world.Last.LightingMode = true
            local mode = tostring(read("world_lighting_mode_mode", "future"))
            local enumName = mode == "shadowmap" and "ShadowMap" or (mode:sub(1, 1):upper() .. mode:sub(2))
            pcall(function()
                lighting.Technology = Enum.Technology[enumName]
            end)
        end

        local function applyWorldTime()
            if readBool("world_time_enabled", false) then
                world.Last.WorldTime = true
                lighting.ClockTime = math.clamp(readNumber("world_time_hour", 4.5), 0, 24)
            elseif world.Last.WorldTime then
                lighting.ClockTime = original.ClockTime
                world.Last.WorldTime = false
            end
        end

        local function applyAtmosphere()
            if not readBool("world_atmosphere_enabled", false) then
                if world.Atmosphere then
                    world.Atmosphere:Destroy()
                    world.Atmosphere = nil
                end
                return
            end
            if not world.Atmosphere then
                world.Atmosphere = Instance.new("Atmosphere")
                world.Atmosphere.Name = "CrewbattlerWorldAtmosphere"
                world.Atmosphere.Parent = lighting
            end
            world.Atmosphere.Color = readColor("world_atmosphere_color", Color3.fromRGB(255, 255, 255))
            world.Atmosphere.Decay = readColor("world_atmosphere_decay", Color3.fromRGB(120, 120, 120))
            world.Atmosphere.Haze = readNumber("world_atmosphere_haze", 1)
            world.Atmosphere.Glare = readNumber("world_atmosphere_glare", 10)
            world.Atmosphere.Offset = readNumber("world_atmosphere_offset", 0)
            world.Atmosphere.Density = readNumber("world_atmosphere_density", 0.35)
        end

        local function applyColorCorrection()
            local saturationEnabled = readBool("world_saturation_enabled", false)
            local contrastEnabled = readBool("world_contrast_enabled", false)
            local tintEnabled = readBool("world_tint_enabled", false)
            if not saturationEnabled and not contrastEnabled and not tintEnabled and not world.ColorCorrectionTouched then return end
            local cc = ensureColorCorrection()
            world.ColorCorrectionTouched = saturationEnabled or contrastEnabled or tintEnabled
            cc.Saturation = saturationEnabled and readNumber("world_saturation_value", 0) or original.Saturation
            cc.Contrast = contrastEnabled and readNumber("world_contrast_value", 0) or original.Contrast
            cc.TintColor = tintEnabled and readColor("world_tint_color", Color3.fromRGB(255, 255, 255)) or original.TintColor
        end

        local function clearTextures()
            if world.TextureConnection then
                world.TextureConnection:Disconnect()
                world.TextureConnection = nil
            end
            for _, variant in ipairs(world.TextureVariants) do
                if variant and variant.Parent then variant:Destroy() end
            end
            table.clear(world.TextureVariants)
            for part, color in next, world.TextureColors do
                if part and part.Parent then
                    pcall(function()
                        part.Color = color
                    end)
                end
            end
            table.clear(world.TextureColors)
            world.TexturesEnabled = false
        end

        local function applyTextures()
            if not readBool("world_textures_enabled", false) then
                if world.TexturesEnabled then clearTextures() end
                return
            end
            if world.TexturesEnabled then return end
            world.TexturesEnabled = true
            local pack = texturePacks[tostring(read("world_textures_pack", "minecraft"))] or texturePacks.minecraft
            for materialName, id in next, pack do
                local material = Enum.Material[materialName]
                if material then
                    local variant = Instance.new("MaterialVariant")
                    variant.Name = "Crewbattler_" .. materialName
                    variant.BaseMaterial = material
                    variant.StudsPerTile = 5
                    variant.ColorMap = id
                    variant.MetalnessMap = id
                    variant.NormalMap = id
                    variant.RoughnessMap = id
                    variant.Parent = materialService
                    table.insert(world.TextureVariants, variant)
                end
            end
            local white = Color3.fromRGB(254, 253, 255)
            local function applyPart(part)
                if (part:IsA("Part") or part:IsA("MeshPart")) and pack[part.Material.Name] and part.Transparency < 0.8 then
                    if not world.TextureColors[part] then world.TextureColors[part] = part.Color end
                    part.Color = white
                end
            end
            local map = workspace:FindFirstChild("MAP")
            if map then
                for _, descendant in ipairs(map:GetDescendants()) do pcall(applyPart, descendant) end
                world.TextureConnection = map.DescendantAdded:Connect(function(descendant)
                    pcall(applyPart, descendant)
                end)
            end
        end

        local function clearWeather()
            if world.WeatherConnection then
                world.WeatherConnection:Disconnect()
                world.WeatherConnection = nil
            end
            if world.WeatherPart then
                world.WeatherPart:Destroy()
                world.WeatherPart = nil
            end
            world.WeatherKey = nil
        end

        local function applyWeather()
            if not readBool("world_weather_enabled", false) then
                clearWeather()
                return
            end
            local weatherType = tostring(read("world_weather_type", "rain"))
            local key = table.concat({
                weatherType,
                tostring(read("world_weather_color", "")),
                tostring(readNumber("world_weather_rate", 100)),
                tostring(readNumber("world_weather_intensity", 100)),
                tostring(readNumber("world_weather_speed", 100)),
            }, "|")
            if world.WeatherKey == key and world.WeatherPart then return end
            clearWeather()
            local part = Instance.new("Part")
            part.Name = weatherType == "custom rain" and "RainPart" or "WeatherPart"
            part.Size = Vector3.new(40, 40, 85)
            part.CanCollide = false
            part.Massless = true
            part.CastShadow = false
            part.Transparency = 1
            part.Anchored = true
            part.Parent = workspace

            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "WorldWeatherEmitter"
            emitter.Color = ColorSequence.new(readColor("world_weather_color", Color3.fromRGB(255, 255, 255)))
            emitter.EmissionDirection = Enum.NormalId.Bottom
            emitter.Parent = part

            if weatherType == "snow" then
                emitter.Texture = "http://www.roblox.com/asset/?id=99851851"
                emitter.Rate = 1000 * (readNumber("world_weather_rate", 100) / 100)
                emitter.Speed = NumberRange.new(30, 30)
                emitter.LightEmission = 0.5
                emitter.SpreadAngle = Vector2.new(50, 50)
                emitter.Size = NumberSequence.new(0.35)
            elseif weatherType == "light rain" then
                emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                emitter.Rate = 500 * (readNumber("world_weather_rate", 100) / 100)
                emitter.Speed = NumberRange.new(30, 50)
                emitter.Lifetime = NumberRange.new(9, 9)
                emitter.LightEmission = 0.5
                emitter.Size = NumberSequence.new(0.2)
            else
                local intensity = weatherType == "custom rain" and (readNumber("world_weather_intensity", 100) / 100) or 1
                local speed = weatherType == "custom rain" and (readNumber("world_weather_speed", 100) / 100) or 1
                emitter.Texture = "rbxassetid://1822883048"
                emitter.Rate = 600 * (readNumber("world_weather_rate", 100) / 100) * intensity
                emitter.Speed = NumberRange.new(60 * speed, 60 * speed)
                emitter.Lifetime = NumberRange.new(0.8, 0.8)
                emitter.LightEmission = 0.05
                emitter.LightInfluence = 0.9
                emitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
                emitter.Size = NumberSequence.new(10)
            end

            world.WeatherPart = part
            world.WeatherKey = key
            world.WeatherConnection = runservice.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
                local camera = workspace.CurrentCamera
                if camera and part.Parent then part.CFrame = CFrame.new(camera.CFrame.Position) + Vector3.new(0, 20, 0) end
            end))
        end

        local function applyAmbient()
            if readBool("world_ambient_enabled", false) then
                world.Last.Ambient = true
                lighting.Ambient = readColor("world_ambient_color", Color3.fromRGB(70, 70, 70))
                lighting.OutdoorAmbient = readColor("world_ambient_outdoor_color", Color3.fromRGB(128, 128, 128))
            elseif world.Last.Ambient then
                lighting.Ambient = original.Ambient
                lighting.OutdoorAmbient = original.OutdoorAmbient
                world.Last.Ambient = false
            end
        end

        local function applySkybox()
            local sky = ensureSky()
            if not readBool("world_skybox_enabled", false) then
                if world.Last.Skybox then
                    sky.SkyboxBk = original.SkyboxBk
                    sky.SkyboxDn = original.SkyboxDn
                    sky.SkyboxFt = original.SkyboxFt
                    sky.SkyboxLf = original.SkyboxLf
                    sky.SkyboxRt = original.SkyboxRt
                    sky.SkyboxUp = original.SkyboxUp
                    sky.SunTextureId = original.SunTextureId
                    sky.MoonTextureId = original.MoonTextureId
                    world.Last.Skybox = false
                end
                return
            end
            world.Last.Skybox = true
            local selected = skyboxes[tostring(read("world_skybox_sky", "black storm"))]
            if selected then
                sky.SkyboxBk = selected.SkyboxBk
                sky.SkyboxDn = selected.SkyboxDn
                sky.SkyboxFt = selected.SkyboxFt
                sky.SkyboxLf = selected.SkyboxLf
                sky.SkyboxRt = selected.SkyboxRt
                sky.SkyboxUp = selected.SkyboxUp
                sky.SunTextureId = original.SunTextureId
                sky.MoonTextureId = original.MoonTextureId
            end
        end

        local function applyWorldVisuals()
            world.Applying = true
            pcall(applyBackgroundNoise)
            pcall(applyLightingMode)
            pcall(applyWorldTime)
            pcall(applyAtmosphere)
            pcall(applyColorCorrection)
            pcall(applyTextures)
            pcall(applyAmbient)
            pcall(applyWeather)
            pcall(applySkybox)
            world.Applying = false
        end

        local function queueWorldVisuals()
            if world.Applying then return end
            task.defer(function()
                if not world.Applying then applyWorldVisuals() end
            end)
        end

        for _, property in ipairs({"ClockTime", "Technology", "Ambient", "OutdoorAmbient"}) do
            pcall(function()
                lighting:GetPropertyChangedSignal(property):Connect(queueWorldVisuals)
            end)
        end

        pcall(function()
            lighting.ChildAdded:Connect(queueWorldVisuals)
            lighting.ChildRemoved:Connect(queueWorldVisuals)
        end)

        pcall(function()
            sky:GetPropertyChangedSignal("SkyboxBk"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("SkyboxDn"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("SkyboxFt"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("SkyboxLf"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("SkyboxRt"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("SkyboxUp"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("SunTextureId"):Connect(queueWorldVisuals)
            sky:GetPropertyChangedSignal("MoonTextureId"):Connect(queueWorldVisuals)
        end)

        world.LockConnection = runservice.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            if worldVisualsEnabled() then applyWorldVisuals() end
        end))

        if colorCorrection then
            pcall(function()
                colorCorrection:GetPropertyChangedSignal("Saturation"):Connect(queueWorldVisuals)
                colorCorrection:GetPropertyChangedSignal("Contrast"):Connect(queueWorldVisuals)
                colorCorrection:GetPropertyChangedSignal("TintColor"):Connect(queueWorldVisuals)
            end)
        end

        global.registry.world_visuals_update = applyWorldVisuals
        global.registry.lighting_technology = function(value)
            status.world_lighting_mode_mode = tostring(value or "future"):lower()
            status.world_lighting_mode_enabled = true
            applyWorldVisuals()
        end

        applyWorldVisuals()
        createloop(0.25, applyWorldVisuals)
    end
    createWorldVisuals()
    local function on_loadup()
        local function showContextMessage()
            local contextMessage = client.contextModule
            if contextMessage then
                if contextMessage.status() then
                    contextMessage.close()
                    while true do
                        if contextModule.status() then
                            contextMessage.close()
                            break
                        else
                            break
                        end
                        task.wait()
                    end
                    contextMessage.open()
                else
                    contextMessage.open()
                end
                contextMessage.setmsg("Loaded crewbattler.club")
                task.delay(5, function()
                    if contextMessage.status() then contextMessage.close() end
                end)
            end
        end
        local function doFireworks()
            local fireworks = global.registry.fireworks.Fireworks
            fireworks(5)
        end
        local function on_loadup()
            global.ui_status = global.ui_status or {}
            global.ui_status.mainUI = true
            global._loaded = true
            pcall(showContextMessage)
            doFireworks()
        end
        on_loadup()
    end
    on_loadup()
    global.is_stable_version = not IS_NOT_OBFUSCATED
    log(`Executor: {global.getExecutor}`)
    -- post-load self-check: surface anything the (imminent) game update may have
    -- moved/renamed so it's immediately obvious what broke instead of silent failures
    pcall(function()
        local issues = {}
        for _, k in ipairs(global.moduleFailures or {}) do issues[#issues + 1] = "module:" .. k end
        for _, r in ipairs({"DisplayDamageDraw", "HawkeyeRemoteFunction"}) do
            local found = repl:FindFirstChild(r)
            if not found and type(getnilinstances) == "function" then
                local ok, nils = pcall(getnilinstances)
                if ok then for _, inst in ipairs(nils) do if inst.Name == r then found = true break end end end
            end
            if not found then issues[#issues + 1] = "remote:" .. r end
        end
        local itemFolder = repl:FindFirstChild("Game") and repl.Game:FindFirstChild("Item")
        for _, g in ipairs({"Pistol", "Sniper", "PlasmaGun", "Shotgun", "Revolver", "Rifle", "AK47", "Uzi"}) do
            if not (itemFolder and itemFolder:FindFirstChild(g)) then issues[#issues + 1] = "gun:" .. g end
        end
        for _, f in ipairs({"shouldArrest", "generateJobId", "resolvePowerplant"}) do
            if type(global.registry[f]) ~= "function" then issues[#issues + 1] = "registry:" .. f end
        end
        if #issues > 0 then
            log(("[validate] %d dependency change(s) detected -- GAME UPDATE LIKELY: %s"):format(#issues, table.concat(issues, ", ")))
            warn("[crewbattler][validate] changed since last build: " .. table.concat(issues, ", "))
        else
            log("[validate] all critical dependencies present")
        end
    end)
    log(("Loaded crewbattler.club in %s second(s). Build: %s-%s"):format(tostring(math.floor(tick() - execution_time)), global.version, IS_NOT_OBFUSCATED and "debug" or "stable"))
end
loadup()
