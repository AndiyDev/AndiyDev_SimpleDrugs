local activePoint = nil
local isBusy = false

-----|| OX Lib lib.addkeybinds ||-----
local keybind = lib.addKeybind({
    name = 'AD_SD',
    description = 'AndiyDev_SimpleDrugs',
    defaultKey = Config.KeyBind,
    disabled = true,
    onPressed = function(self)
        if isBusy or not activePoint then return end

        local cfg = Config.CreatedDrug[activePoint.configId]
        isBusy = true

        local canStart = lib.callback.await('AndiyDev_SimpleDrugs:callback:validateItems', false, activePoint.configId)
        
        if not canStart then 
            isBusy = false 
            return 
        end
            
        Bridge.HideText()

        local success = false
        if cfg.progress then
            local cfgpro = cfg.progress

            if cfgpro.anim then
                success = Bridge.Progress(cfgpro.time * 1000, cfgpro.label, cfgpro.anim)
            else
                success = Bridge.Progress(cfgpro.time * 1000, cfgpro.label)
            end
        else
            success = true 
        end

        if success then
            local result = lib.callback.await('AndiyDev_SimpleDrugs:processItems', false, activePoint.configId)
            if result then
                if cfg.donelabel then
                    Bridge.Notify(cfg.donelabel)
                end
            end
        end

        isBusy = false

        if activePoint then
            Bridge.ShowText(cfg.label)
        end
    end
})

-----|| OX Lib lib.points ||-----
local allpoints = {}
for i = 1, #Config.CreatedDrug do
    local data = Config.CreatedDrug[i]
    
    allpoints[i] = lib.points.new({
        coords = data.coords,
        distance = data.distance or 5,
        configId = i, 
        label = data.label or '[E]',
    })
end
CreateThread(function()
    for _, v in pairs(allpoints) do
        function v:onEnter()
            activePoint = {configId = self.configId}
            Bridge.ShowText(self.label)
            keybind:disable(false)
        end

        function v:onExit()
            lib.hideTextUI()
            keybind:disable(true)
            activePoint = nil
        end
    end
end)