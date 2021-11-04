QBCore.Functions.CreateCallback('communityservice:server:GetPlayersInfo', function(source, cb, targets)
    local itable = {}
    for _, v in pairs(targets) do
        local player = QBCore.Functions.GetPlayer(v)
        local info = {}
        info.id = v
        info.name = player.PlayerData.charinfo.firstname..' '..player.PlayerData.charinfo.lastname
        table.insert(itable, info)
    end
    cb(itable)
end)

QBCore.Functions.CreateCallback('communityservice:server:GetPlayerDB', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player ~= nil then
        local result = exports.ghmattimysql:executeSync('SELECT * FROM community_service WHERE citizenid= @citizenid AND status = @status',{
            ['@citizenid'] = player.PlayerData.citizenid,
            ['@status'] = 'started'
        })
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback("communityservice:server:GetPlayerSkin", function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = exports.ghmattimysql:executeSync('SELECT * FROM playerskins WHERE citizenid=@citizenid AND active=@active', {['@citizenid'] = player.PlayerData.citizenid, ['@active'] = 1})
    if result[1] ~= nil then
        cb(result[1].model, result[1].skin)
    else
        cb(nil)
    end
end)

RegisterServerEvent('communityservice:server:AddCommunityService', function(target, amount, reason, who)
    local xTarget = QBCore.Functions.GetPlayer(target)
    TriggerClientEvent('communityservice:client:CommunityService', target, amount, reason, who)
end)

RegisterServerEvent('communityservice:server:UploadDB', function(info)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local status = ''
    if info.amount > 0 then
        status = 'started'
    else
        status = 'finished'
    end
    exports.ghmattimysql:execute('UPDATE community_service SET status = @status, amount = @amount, who = @who, reason = @reason, type = @type WHERE citizenid = @citizenid AND status = @find', {
        ['@status'] = status,
        ['@amount'] = info.amount,
        ['@who'] = info.who,
        ['@reason'] = info.reason,
		['@type'] = info.serviceinfo.type,
        ['@citizenid'] = player.PlayerData.citizenid,
        ['@find'] = 'started',
    })
end)

RegisterServerEvent('communityservice:server:InsertDB', function(info)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('INSERT INTO community_service (citizenid, status, amount, who, reason, type) VALUES (@citizenid, @status, @amount, @who, @reason, @type)', {
		['@citizenid'] = player.PlayerData.citizenid,
		['@status'] = 'started',
        ['@amount'] = info.amount,
        ['@who'] = info.who,
        ['@reason'] = info.reason,
		['@type'] = info.serviceinfo.type,
	})
end)