local isOpen = false

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

function Draw3DText(x, y, z, text, scale)
	local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
	local pX, py, pZ = table.unpack(GetGameplayCamCoords())
	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(true)
	SetTextColour(255, 255, 255,215)
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 700
	DrawRect(_x, _y + 0.0150, 0.06 + factor, 0.03, 41, 11, 41, 100)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k,v in ipairs(Config.Carwashes) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(playerCoords, v.spawn, false)
            if IsPedInAnyVehicle(PlayerPedId(), false) then     
                if distance < Config.DrawDistance then
                    Draw3DText(v.spawn.x, v.spawn.y, v.spawn.z, 'Press ~o~[E]~w~ to open the carwash', 0.4)
                    if IsControlJustPressed(1, 38) then
                        toggleMenu(true)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    for k,v in ipairs(Config.Carwashes) do
        local blip = AddBlipForCoord(v.spawn)

        SetBlipSprite (blip, Config.Blip.Sprite)
        SetBlipDisplay(blip, Config.Blip.Display)
        SetBlipScale  (blip, Config.Blip.Scale)
        SetBlipColour (blip, Config.Blip.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Carwash')
        EndTextCommandSetBlipName(blip)
    end
end)

RegisterNUICallback('wash', function(data, cb)
    ESX.TriggerServerCallback('kn:core:getMoney', function(cash, bank, dirty)
        if cash >= Config.Price then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if GetVehicleDirtLevel(vehicle) == 0 then
                ESX.ShowNotification('Vehicle ~r~already~w~ clean!')
            else
                DoScreenFadeOut(1000)
                TriggerServerEvent('kn:carwash:removeMoney', Config.Price)
                SetVehicleDirtLevel(vehicle, 0)
                toggleMenu(false)
                Wait(4000)
                DoScreenFadeIn(1000)
                ESX.ShowNotification('Vehicle ~g~Washed')
            end
        else
            ESX.ShowNotification('You don\'t have enough ~r~money~w~ on you!')
        end
    end)
end)

function toggleMenu(option)
    if option then
        TransitionToBlurred(1000)
        SetNuiFocus(true, true)
        isOpen = true
        SendNUIMessage({
            action = 'open',
            amount = Config.Price
        })
    elseif not option then
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'close'
        })
        TransitionFromBlurred(1000)
    end
end

--get data back from html (js)
RegisterNUICallback('close', function(data, cb)
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
    isOpen = false
end)