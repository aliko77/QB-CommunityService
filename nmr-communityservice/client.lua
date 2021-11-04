local playerInfo = {
    communityservice = false,
    serviceinfo = {},
    amount = 0,
    reason = nil,
    who = nil,
}
local availableActions = {}
local item_net = nil
local disable_actions = false

AddEventHandler('onResourceStart', function(resource)
    if resource == 'nmr-communityservice' then
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('communityservice:server:GetPlayerDB', function(cb)
        local callback = cb
        if callback ~= nil then
            local type = callback.type
            playerInfo.communityservice = true
            playerInfo.amount = callback.amount
            playerInfo.reason = callback.reason
            playerInfo.who = callback.who
            for k, v in pairs(Config.Services) do
                if v.type == callback.type then
                    playerInfo.serviceinfo = v
                    availableActions = v.areas
                    break
                end
            end
            ChangePlayerSkin()
            SendNUIMessage({
                action = 'setupInformationPanel',
                amount = playerInfo.amount
            })
        end
    end)
end)

Citizen.CreateThread(function()
    local shownUi = {}
    while true do
        local sleep = 7
        if playerInfo.communityservice then
            if playerInfo.amount > 0 then
                DrawAvailableActions()
                DisableViolentActions()
                local pCoords = GetEntityCoords(PlayerPedId())
                for k, v in pairs(availableActions) do
                    local distance = GetDistanceBetweenCoords(pCoords, v.x, v.y, v.z, true)
                    if distance < 1.5 then
                        if not shownUi[k] then
                            shownUi[k] = true
                            exports['okokTextUI']:Open('[E] Etkileşime geç', 'darkblue', 'left')
                        end
                        if IsControlJustReleased(1, 54) then
                            exports['okokTextUI']:Close()
                            local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
                            local itemspawn = CreateObject(GetHashKey(playerInfo.serviceinfo.item), cSCoords, 1, 1, 1)
                            item_net = ObjToNet(itemspawn)
                            local animation = playerInfo.serviceinfo.animation
                            local scenario = playerInfo.serviceinfo.scenario
                            if animation ~= nil then
                                RequestAnimDict(animation.child)
                                while not HasAnimDictLoaded(playerInfo.serviceinfo.animation.child) do
                                    Wait(100)
                                end
                                TaskPlayAnim(PlayerPedId(), animation.child, animation.mom, 8.0, -8.0, -1, 0, 0, false, false, false)
                            elseif scenario ~= nil then
                                TaskStartScenarioInPlace(PlayerPedId(), scenario, 0, false)
                            end
                            local itempos = playerInfo.serviceinfo.itempos
                            AttachEntityToEntity(itemspawn, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.005, 0.0, 0.0, itempos.x, itempos.y, itempos.z, 1, 1, 0, 1, 0, 1)
                            SetTimeout(playerInfo.serviceinfo.eventtime, function()
                                RemoveAction(v)
                                disable_actions = true
                                playerInfo.amount = playerInfo.amount - 1
                                disable_actions = false
                                DetachEntity(NetToObj(item_net), 1, 1)
                                DeleteEntity(NetToObj(item_net))
                                item_net = nil
                                ClearPedTasks(PlayerPedId())
                                TriggerEvent('QBCore:Notify', 'Başarıyla bir görevi yerine getirdin.', 'success', 5000)
                                SendNUIMessage({
                                    action = 'setupInformationPanel',
                                    amount = playerInfo.amount
                                })
                                --Upload DB
                                TriggerServerEvent('communityservice:server:UploadDB', playerInfo)
                            end)
                        end
                    else
                        if shownUi[k] then
                            shownUi[k] = false
                            exports['okokTextUI']:Close()
                        end
                    end
                end
            else
                FinishCommunityService()
                sleep = 1000
            end
        else
            sleep = 1000
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        if playerInfo.communityservice then
            if IsPedInAnyVehicle(playerPed, false) then
                ClearPedTasksImmediately(playerPed)
            end
            Wait(10000)
            if playerInfo.communityservice then
                local loc = playerInfo.serviceinfo.servicelocation
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), loc.x, loc.y, loc.z, false) > 60.0 then
                    SetEntityCoords(PlayerPedId(), loc.x, loc.y, loc.z, false, false, false, false)
                    TriggerEvent('QBCore:Notify', 'Kamu cezasını bitirmeden gidemezsin. Bu hata siciline yansıyacaktır.', 'error', 5000)
                end
            end
        else
            Wait(10)
        end
    end
end)

RegisterNetEvent('communityservice:client:AddCommunityService', function()
    local closePlayers = GetClosestPlayers()
    QBCore.Functions.TriggerCallback('communityservice:server:GetPlayersInfo', function(table)
        SendNUIMessage({
            action = 'openPanel',
            targets = table
        })
        SetNuiFocus(true, true)
    end, closePlayers)
end)

RegisterNetEvent('communityservice:client:CommunityService', function(amount, reason, who)
    TriggerEvent('QBCore:Notify', 'Şahsınıza, '..who.name..' Tarafından, '..reason..' sebebiyle, '..amount..' işlik kamu cezası yazıldı.', 'info', 5000)
    playerInfo.communityservice = true
    playerInfo.amount = tonumber(amount)
    playerInfo.reason = reason
    playerInfo.who = who.citizenid
    playerInfo.serviceinfo = Config.Services[math.random(1, #Config.Services)]
    availableActions = playerInfo.serviceinfo.areas
    SetEntityCoords(PlayerPedId(), playerInfo.serviceinfo.servicelocation, false, false, false, false)
    ChangePlayerSkin()
    SendNUIMessage({
        action = 'setupInformationPanel',
        amount = playerInfo.amount
    })
    TriggerServerEvent('communityservice:server:InsertDB', playerInfo)
end)

RegisterNUICallback('action', function(event, cb)
    if event.action == 'notify' then
        local datatime = event.time and event.time or 5000
        local datatype = event.type and event.type or 'info'
        TriggerEvent('QBCore:Notify', event.message, datatype, datatime)
    elseif event.action == 'closePanel' then
        SetNuiFocus(false, false)
    elseif event.action == 'AddCommunityService' then
        SetNuiFocus(false, false)
        if not playerInfo.communityservice then
            TriggerEvent('QBCore:Notify', 'Oyuncuya kamu cezası verildi.', 'success', 5000)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local target = event.target
            local amount = event.amount
            local reason = event.reason
            local who = {
                citizenid = PlayerData.citizenid,
                name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
            }
            TriggerServerEvent('communityservice:server:AddCommunityService', target, amount, reason, who)
        else
            TriggerEvent('QBCore:Notify', 'Bu oyuncunun zaten bir kamu cezası bulunmakta.', 'success', 5000)
        end
    end
end)

function ChangePlayerSkin()
    local gender = QBCore.Functions.GetPlayerData().charinfo.gender
    local playerPed = PlayerPedId()
	if DoesEntityExist(playerPed) then
		Citizen.CreateThread(function()
            if gender == 0 then
                local data = {
                    outfitData = Config.Uniforms['prison_wear'].male
                }
                TriggerEvent('qb-clothing:client:loadOutfit', data)
            else
                local data = {
                    outfitData = Config.Uniforms['prison_wear'].female
                }
                TriggerEvent('qb-clothing:client:loadOutfit', data)
            end
            SetPedArmour(playerPed, 0)
            ClearPedBloodDamage(playerPed)
            ResetPedVisibleDamage(playerPed)
            ClearPedLastWeaponDamage(playerPed)
            ResetPedMovementClipset(playerPed, 0)
		end)
	end
end

function FinishCommunityService()
    TriggerEvent('QBCore:Notify', 'Kamu cezanız bitti. Tekrar yaşanmaması umudu ile elveda.', 'success', 5000)
    QBCore.Functions.TriggerCallback('communityservice:server:GetPlayerSkin', function(model, skin)
        SetEntityCoords(PlayerPedId(), playerInfo.serviceinfo.servicelocation, false, false, false, false)
        if model ~= nil and skin ~= nil then
            TriggerEvent('qb-clothes:loadSkin', false, model, skin)
        end
        playerInfo.communityservice = false
        playerInfo.serviceinfo = {}
        playerInfo.amount = 0
        playerInfo.reason = nil
        playerInfo.who = nil
        availableActions = {}
        item_net = nil
        disable_actions = false
        SendNUIMessage({
            action = 'finishpanel'
        })
    end)
end

function DrawAvailableActions()
	for k, v in pairs(availableActions) do
		DrawMarker(21, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 50, 50, 204, 100, false, true, 2, true, false, false, false)
	end
end

function DisableViolentActions()
	local playerPed = PlayerPedId()
	if disable_actions == true then
		DisableAllControlActions(0)
	end
	RemoveAllPedWeapons(playerPed, true)
	DisableControlAction(2, 37, true)
	DisablePlayerFiring(playerPed,true)
    DisableControlAction(0, 106, true) 
    DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)
	if IsDisabledControlJustPressed(2, 37) then 
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true)
	end
	if IsDisabledControlJustPressed(0, 106) then 
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true)
	end
end

function GetClosestPlayers(coords, distance)
    local players = QBCore.Functions.GetPlayers()
    local closePlayers = {}
    if coords == nil then
		coords = GetEntityCoords(PlayerPedId())
    end
    if distance == nil then
        distance = 3.0
    end
    for _, player in pairs(players) do
		local target = GetPlayerPed(player)
		local targetCoords = GetEntityCoords(target)
		local targetdistance = #(targetCoords - coords)
		if targetdistance <= distance then--and target ~= PlayerPedId() then
			table.insert(closePlayers, GetPlayerServerId(player))
		end
    end
    return closePlayers
end

function RemoveAction(action)
	for k, v in pairs(availableActions) do
		if action.x == v.x and action.y == v.y and action.z == v.z then
			table.remove(availableActions, k)
		end
	end
    if #availableActions == 0 then
        availableActions = {}
        for k, v in pairs(Config.Services) do
            if v.type == playerInfo.serviceinfo.type then
                availableActions = v.areas
                playerInfo.serviceinfo.areas = v.areas
                break
            end
        end
    end
end