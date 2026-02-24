Bridge = {}
local Framework = nil
local FrameworkName = nil

-- DYNAMIC DETECTION
Citizen.CreateThread(function()
    while Framework == nil do
        if GetResourceState('qbx_core') == 'started' then
            Framework = exports.qbx_core
            FrameworkName = 'qbx'
        elseif GetResourceState('qb-core') == 'started' then
            Framework = exports['qb-core']:GetCoreObject()
            FrameworkName = 'qb'
        elseif GetResourceState('es_extended') == 'started' then
            Framework = exports['es_extended']:getSharedObject()
            FrameworkName = 'esx'
        end
        Citizen.Wait(100)
    end
end)

-- NOTIFICATIONS & TEXT UI
function Bridge.Notify(message, msgType)
    if GetResourceState('ox_lib') == 'started' then
        lib.notify({ description = message, type = msgType or 'inform' })
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        exports['qb-core']:DrawText(message, 'left') -- Fallback notify
    elseif FrameworkName == 'esx' then
        ESX.ShowNotification(message)
    end
end

function Bridge.ShowText(message)
    if GetResourceState('ox_lib') == 'started' then
        lib.showTextUI(message)
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        exports['qb-core']:DrawText(message, 'left')
    elseif FrameworkName == 'esx' then
        ESX.ShowHelpNotification(message)
    end
end

function Bridge.HideText()
    if GetResourceState('ox_lib') == 'started' then
        lib.hideTextUI()
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        exports['qb-core']:HideText()
    end
end

-- PROGRESS BAR (Supports Promise for Sync usage)
function Bridge.Progress(duration, label, anim)
    if GetResourceState('ox_lib') == 'started' then
        return lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true },
            anim = anim
        })
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        local p = promise.new()
        Framework.Functions.Progressbar("bridge_action", label, duration, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, anim or {}, {}, {}, function() p:resolve(true) end, function() p:resolve(false) end)
        return Citizen.Await(p)
    end
    Wait(duration)
    return true
end

-- UNIVERSAL KEYBIND (Ox Lib or Native Keymapping)
function Bridge.RegKeybind(name, desc, defaultKey, onPress)
    if GetResourceState('ox_lib') == 'started' then
        return lib.addKeybind({
            name = name,
            description = desc,
            defaultKey = defaultKey,
            onPressed = onPress
        })
    else
        -- FALLBACK: FiveM RegisterKeyMapping (Best performance)
        -- This creates a command that can be seen in Settings -> Key Bindings -> FiveM
        RegisterCommand(name, function()
            -- We call the onPress function passed by the script
            onPress()
        end, false)

        RegisterKeyMapping(name, desc, 'keyboard', defaultKey)
    end
end