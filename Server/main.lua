lib.callback.register('AndiyDev_SimpleDrugs:processItems', function(source, index)
    local src = source
    local cfg = Config.CreatedDrug[index]

    -- Basic Index Check
    if not cfg then return false end

    -- PRE-CHECK: Requirements
    if type(cfg.removeitem) == 'table' and #cfg.removeitem > 0 then
        for _, data in ipairs(cfg.removeitem) do
            if Bridge.GetItemCount(src, data.item) < data.amount then
                Bridge.Notify(src, ("Missing: %sx %s"):format(data.amount, data.item), 'error')
                return false
            end
        end
    end

    -- PRE-CHECK: Weight
    if type(cfg.getitem) == 'table' and #cfg.getitem > 0 then
        for _, data in ipairs(cfg.getitem) do
            if not Bridge.CanCarryItem(src, data.item, data.amount) then
                Bridge.Notify(src, "Your inventory is too heavy!", 'error')
                return false
            end
        end
    end

    -- EXECUTION: Remove
    if type(cfg.removeitem) == 'table' then
        for _, data in ipairs(cfg.removeitem) do
            Bridge.RemoveItem(src, data.item, data.amount)
        end
    end

    -- EXECUTION: Add
    if type(cfg.getitem) == 'table' then
        for _, data in ipairs(cfg.getitem) do
            Bridge.AddItem(src, data.item, data.amount)
        end
    end

    return true
end)

local function CheckVersion()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    local resourceName = GetCurrentResourceName()
    local githubRepo = "AndiyDev/AndiyDev_SimpleDrugs" 

    -- 1. Check Version
    PerformHttpRequest(('https://raw.githubusercontent.com/%s/main/version.txt'):format(githubRepo), function(errorCode, result, headers)
        if errorCode ~= 200 then return end

        local latestVersion = result:gsub("%s+", "")
        
        if latestVersion ~= currentVersion then
            print(("^3[%s] A new update is available! (v%s -> v%s)^7"):format(resourceName, currentVersion, latestVersion))
            
            -- 2. Fetch Change Log if an update is found
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

-- Run the check when the resource starts
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds to ensure console is clear
    CheckVersion()
end)