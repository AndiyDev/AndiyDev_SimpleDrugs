local activePoint = nil

-----|| OX Lib lib.addkeybinds ||-----
local keybind = lib.addKeybind({
    name = 'AD_SD',
    description = 'AndiyDev_SimpleDrugs',
    defaultKey = Config.KeyBind,
    disabled = true,
    onPressed = function(self)
    if not activePoint then return end
    
    local cfg = Config.CreatedDrug[activePoint.configId]
    local success = false
    
    Bridge.HideText()

    if cfg.progress then
        local cfgpro = cfg.progress

        success = Bridge.Progress(cfgpro.time * 1000, cfgpro.label, {
            dict = cfgpro.anim.dict, 
            clip = cfgpro.anim.clip
        })
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

    -- Refresh TextUI if still in zone
    if a ctivePoint then
        Bridge.ShowText(cfg.label)
    end
end
})

-----|| OX Lib lib.points ||-----
for i = 1, #Config.CreatedDrug do
    local data = Config.CreatedDrug[i]
    
    lib.points.new({
        coords = data.coords,
        distance = data.distance or 5,
        configId = i, 
        label = data.label or '[E]',
    })
end

function lib.points:onEnter()
    activePoint = { configId = self.configId, label = self.label }
    Bridge.ShowText(self.label)
    keybind:disable(false)
end

function lib.points:onExit()
    lib.hideTextUI()
    keybind:disable(true)
    activePoint = nil
end