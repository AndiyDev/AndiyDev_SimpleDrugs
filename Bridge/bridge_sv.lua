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

-- 4. NOTIFICATIONS
function Bridge.Notify(source, message, msgType)
    if isOxLib then
        TriggerClientEvent('ox_lib:notify', source, { description = message, type = msgType or 'inform' })
    elseif FrameworkName == 'qb' or FrameworkName == 'qbx' then
        TriggerClientEvent('QBCore:Notify', source, message, msgType)
    elseif FrameworkName == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    end
end