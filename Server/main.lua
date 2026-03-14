local function canUserPerformAction(src, configId)
    local cfg = Config.CreatedDrug[configId]
    if not cfg then return false end
    if Config.Debug then
        print("Checking requirements for configId:", configId)
        print("Requirements:", json.encode(cfg.removeitem))
        print("Rewards:", json.encode(cfg.getitem))
    end
    -- Check both conditions
    if not Bridge.CheckRequirements(src, cfg) then return false end
    if not Bridge.CheckWeight(src, cfg) then return false end

    return true
end

lib.callback.register('AndiyDev_SimpleDrugs:callback:validateItems', function(source, configId)
    return canUserPerformAction(source, configId)
end)

lib.callback.register('AndiyDev_SimpleDrugs:processItems', function(source, configId)
    if not canUserPerformAction(source, configId) then return false end
    
    local cfg = Config.CreatedDrug[configId]
    if Config.Debug then
        print("Processing items for configId:", configId)
    end
    if cfg.removeitem then
        for _, v in ipairs(cfg.removeitem) do 
            if Config.Debug then
                print('Is money ', v.money)
            end
            if v.money then
                if Config.Debug then
                    print("Removing money:", v.amount, "from player:", source, "Money type:", v.money, "Current Money:")
                end
                Bridge.RemoveMoney(source, v.money, v.amount)
            else
                Bridge.RemoveItem(source, v.item, v.amount) 
            end
        end
    end
    
    if cfg.getitem then
        for _, v in ipairs(cfg.getitem) do 
            Bridge.AddItem(source, v.item, v.amount) 
        end
    end

    return true
end)