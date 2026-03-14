Bridge = {}
local Framework = nil
local FrameworkName = nil

-- 1. DYNAMIC DETECTION
local isOxInv = GetResourceState('ox_inventory') == 'started'
local isOxLib = GetResourceState('ox_lib') == 'started'

Citizen.CreateThread(function()
    -- Wait for frameworks to initialize
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

-- 2. PLAYER UTILITY
function Bridge.GetPlayer(source)
    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        return Framework.Functions.GetPlayer(source)
    elseif FrameworkName == 'esx' then
        return Framework.GetPlayerFromId(source)
    end
end

-- 3. INVENTORY LOGIC
function Bridge.GetItemCount(source, itemName)
    if isOxInv then
        return exports.ox_inventory:Search(source, 'count', itemName) or 0
    end
    local Player = Bridge.GetPlayer(source)
    if not Player then return 0 end
    
    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        local item = Player.Functions.GetItemByName(itemName)
        return item and (item.amount or item.count) or 0
    elseif FrameworkName == 'esx' then
        local item = Player.getInventoryItem(itemName)
        return item and item.count or 0
    end
    return 0
end

function Bridge.CanCarryItem(source, itemName, count)
    if isOxInv then
        return exports.ox_inventory:canCarryItem(source, itemName, count)
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        return exports['qb-inventory']:CanAddItem(source, itemName, count)
    elseif FrameworkName == 'esx' then
        local Player = Bridge.GetPlayer(source)
        return Player and (Player.canCarryItem and Player.canCarryItem(itemName, count) or true)
    end
    return true
end

function Bridge.AddItem(source, itemName, count)
    if isOxInv then return exports.ox_inventory:AddItem(source, itemName, count) end
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end

    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        if Player.Functions.AddItem(itemName, count) then
            TriggerClientEvent('inventory:client:ItemBox', source, Framework.Shared.Items[itemName], 'add')
            return true
        end
    elseif FrameworkName == 'esx' then
        Player.addInventoryItem(itemName, count)
        return true
    end
    return false
end

function Bridge.RemoveItem(source, itemName, count)
    if isOxInv then return exports.ox_inventory:RemoveItem(source, itemName, count) end
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end

    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        if Player.Functions.RemoveItem(itemName, count) then
            TriggerClientEvent('inventory:client:ItemBox', source, Framework.Shared.Items[itemName], 'remove')
            return true
        end
    elseif FrameworkName == 'esx' then
        Player.removeInventoryItem(itemName, count)
        return true
    end
    return false
end

-- 5. Money Handling (Example for cash, can be expanded for other types)
function Bridge.AddMoney(source, moneyname, amount, type)
    if Config.Debug then
        print('Bridge: AddMoney', moneyname, amount, type)
    end
    local Player = Bridge.GetPlayer(source)
    if not Player then if Config.Debug then print('Player not found', Player) end return false end

    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        Player.Functions.AddMoney(moneyname, amount, type)
        return true
    elseif FrameworkName == 'esx' then
        Player.addMoney(amount, type)
        return true
    end
    return false
end

function Bridge.RemoveMoney(source, moneyname, amount, type)
    if Config.Debug then
        print('Bridge: RemoveMoney', moneyname, amount, type)
    end
    local Player = Bridge.GetPlayer(source)
    if not Player then if Config.Debug then print('Player not found', Player) end return false end
    

    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        if Config.Debug then
            print('Bridge: RemoveMoney Framework', FrameworkName)
        end
        Player.Functions.RemoveMoney(moneyname, amount)
        return true
    elseif FrameworkName == 'esx' then
        if Config.Debug then
            print('Bridge: RemoveMoney Framework', FrameworkName)
        end
        Player.removeMoney(amount, type)
        return true
    end
    return false
end

function Bridge.GetMoney(source, moneyname)
    local Player = Bridge.GetPlayer(source)
    if not Player then if Config.Debug then print('Player not found', Player) end return 0 end

    if FrameworkName == 'qb' or FrameworkName == 'qbx' then
        if Config.Debug then
            print('Bridge: GetMoney Framework', FrameworkName)
        end
        return Player.Functions.GetMoney(moneyname) or 0
    elseif FrameworkName == 'esx' then
        if Config.Debug then
            print('Bridge: GetMoney Framework', FrameworkName)
        end
        return Player.getMoney(moneyname) or 0
    end
    return 0
end

-- 6. WEIGHT CHECK (Assuming weight is handled via ox_inventory or qb-inventory)
function Bridge.GetInventoryWeight(source)
    if isOxInv then
        return exports.ox_inventory:GetWeight(source) or 0, exports.ox_inventory:GetMaxWeight(source) or 0
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        return exports['qb-inventory']:GetWeight(source) or 0, exports['qb-inventory']:GetMaxWeight(source) or 0
    end
    return 0, 0
end

function Bridge.CheckWeight(src, cfg)
    if not cfg.getitem then return true end
    
    local currentWeight, maxWeight = Bridge.GetInventoryWeight(src)
    local additionalWeight = 0

    for _, item in ipairs(cfg.getitem) do
        local itemInfo = Framework.Shared.Items[item.item]
        if itemInfo and itemInfo.weight then
            additionalWeight = additionalWeight + (itemInfo.weight * item.amount)
        end
    end

    if (currentWeight + additionalWeight) > maxWeight then
        Bridge.Notify(src, "Your inventory is too heavy!", 'error')
        return false
    end
    return true
end

function Bridge.CheckRequirements(src, cfg)
    if not cfg.removeitem then return true end
    
    for _, req in ipairs(cfg.removeitem) do
        local count = Bridge.GetItemCount(src, req.item)
        if count < req.amount then
            Bridge.Notify(src, ("You need %sx %s"):format(req.amount, req.item), 'error')
            return false
        end
    end
    return true
end

-- NOTIFICATIONS
function Bridge.Notify(source, message, msgType)
    if isOxLib then
        TriggerClientEvent('ox_lib:notify', source, { description = message, type = msgType or 'inform' })
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        TriggerClientEvent('QBCore:Notify', source, message, msgType)
    elseif FrameworkName == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    end
end

-- Check Version and changelog on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Bridge.CheckVersion()
    end
end)

-- Version Check
function Bridge.CheckVersion()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    local resourceName = GetCurrentResourceName()
    local githubRepo = "AndiyDev/AndiyDev_SimpleDrugs" 

    PerformHttpRequest(('https://raw.githubusercontent.com/%s/main/version.txt'):format(githubRepo), function(errorCode, result, headers)
        if errorCode ~= 200 then return end

        local latestVersion = result:gsub("%s+", "")
        
        if latestVersion ~= currentVersion then
            print(("^3[%s] A new update is available! (v%s -> v%s)^7"):format(resourceName, currentVersion, latestVersion))
            
            PerformHttpRequest(('https://raw.githubusercontent.com/%s/main/changelog.txt'):format(githubRepo), function(logCode, logResult, logHeaders)
                if logCode == 200 and logResult then
                    print("^5--- CHANGE LOG ---^7")
                    print(logResult)
                    print("^5------------------^7")
                end
                print(("^3Download the update here: https://github.com/%s^7"):format(githubRepo))
            end, 'GET')
        else
            print(("^2[%s] is up to date (v%s)^7"):format(resourceName, currentVersion))
        end
    end, 'GET')
end