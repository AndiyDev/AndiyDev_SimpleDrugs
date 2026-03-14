local activePoint = nil
local isBusy = false

-----|| OX Lib lib.addkeybinds ||-----
local keybind = lib.addKeybind({
    name = 'AD_SD',
    description = 'AndiyDev_SimpleDrugs',
    defaultKey = Config.KeyBind,
    disabled = true,
    onPressed = function(self)
        DrugSystemMain()
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

-----|| Functions ||-----
function DrugSystemMain()
    if isBusy or not activePoint then return end
    keybind:disable(true)

    local cfg = Config.CreatedDrug[activePoint.configId]
    isBusy = true

    local canStart = lib.callback.await('AndiyDev_SimpleDrugs:callback:validateItems', false, activePoint.configId)
        
    if not canStart then 
        if Config.Debug then
            print("Validation failed for configId:", activePoint.configId)
        end
        isBusy = false 
        if activePoint then
            keybind:disable(false)
        end
        return 
    end
            
    Bridge.HideText()

    local success = false
    if cfg.progress then
        local pcfg = cfg.progress
        exports['progressbar']:Progress({
            name = 'AndiyDev_SimpleDrugs_progress',
            duration = pcfg.duration,
            label = pcfg.label,
            useWhileDead = false,
            canCancel = pcfg.canCancel,
            controlDisables = {
                disableMovement = pcfg.disable and pcfg.disable.movement or true,
                disableCarMovement = pcfg.disable and pcfg.disable.car or false,
                disableMouse = pcfg.disable and pcfg.disable.mouse or false,
                disableCombat = pcfg.disable and pcfg.disable.combat or false,
            },
            animation = pcfg.anim,
            prop = pcfg.prop,
            propTwo = pcfg.propTwo
        }, function(status)
            print("Progress callback status for configId:", activePoint.configId, "Status:", status)
            if status then
                success = false
            else
                success = true
            end 
        end)
        Wait(pcfg.duration + 100) -- Wait for the progress to complete plus a small buffer
        if Config.Debug then
            print("Progress result for configId:", activePoint.configId, "Success:", success)
        end
    else
        if Config.Debug then
            print("No progress config for configId:", activePoint.configId)
        end
        success = true 
    end

    if success then
        if Config.Debug then
            print("Progress completed for configId:", activePoint.configId)
        end
        local result = lib.callback.await('AndiyDev_SimpleDrugs:processItems', false, activePoint.configId)
        if result then
            if Config.Debug then
                print("Items processed successfully for configId:", activePoint.configId)
            end
            if cfg.donelabel then
                Bridge.Notify(cfg.donelabel)
            end
        end
    end

    isBusy = false

    if activePoint then
        keybind:disable(false)
        Bridge.ShowText(cfg.label)
    end
end

-----|| Blips ||-----
CreateThread(function()
    for i = 1, #Config.CreatedDrug do
        if Config.CreatedDrug[i].blip then 
            local curblip = Config.CreatedDrug[i].blip
            local blip = AddBlipForCoord(curblip)
            SetBlipSprite(blip, curblip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, curblip.scale)
            SetBlipColour(blip, curblip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(tostring(curblip.name))
            EndTextCommandSetBlipName(blip)
        end
    end
end)