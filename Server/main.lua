local function checkWeight(src, cfg)
    if not cfg.getitem then return true end
    
    for _, data in ipairs(cfg.getitem) do
        if not Bridge.CanCarryItem(src, data.item, data.amount) then
            Bridge.Notify(src, "Your inventory is too heavy!", 'error')
            return false
        end
    end
    return true
end

local function checkRequirements(src, cfg)
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

local function canUserPerformAction(src, configId)
    local cfg = Config.CreatedDrug[configId]
    if not cfg then return false end

    -- Check both conditions
    if not checkRequirements(src, cfg) then return false end
    if not checkWeight(src, cfg) then return false end

    return true
end

lib.callback.register('AndiyDev_SimpleDrugs:callback:validateItems', function(source, configId)
    return canUserPerformAction(source, configId)
end)

lib.callback.register('AndiyDev_SimpleDrugs:processItems', function(source, configId)
    if not canUserPerformAction(source, configId) then return false end
    
    local cfg = Config.CreatedDrug[configId]

    if cfg.removeitem then
        for _, v in ipairs(cfg.removeitem) do 
            Bridge.RemoveItem(source, v.item, v.amount) 
        end
    end
    
    if cfg.getitem then
        for _, v in ipairs(cfg.getitem) do 
            Bridge.AddItem(source, v.item, v.amount) 
        end
    end

    return true
end)

local function CheckVersion()
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

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    CheckVersion()
end)