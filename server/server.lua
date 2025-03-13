local QBCore = exports['qb-core']:GetCoreObject()

local report_data = {}

local webhookURL = "WEBHOOK URL"


lib.callback.register('nn_report:server:checkPermission', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local roleData = QBCore.Functions.GetPermission(src) 
    local hasAccess = false

    for _, adminRole in ipairs(Config.AdminGroups) do
        if roleData[adminRole] then 
            hasAccess = true
            break
        end
    end

    return hasAccess
end)


RegisterNetEvent('nn_report:server:sendReport', function(data)
    local src = source
    local identifier = QBCore.Functions.GetIdentifier(src, 'steam')
    local discord = QBCore.Functions.GetIdentifier(src, 'discord')
    local player_data = QBCore.Functions.GetPlayer(src).PlayerData
    local player_name = player_data.charinfo.firstname ..' '..player_data.charinfo.lastname
  
    local report_number = #report_data + 1

    report_data[report_number] = { 
        report_number = report_number,
        player_identifier = identifier,
        player_id = src,
        category = data.category,
        description = data.description,
        priority = data.priority,
        status = "Pending",
        player_name = player_name
    }

    TriggerClientEvent('ox_lib:notify', src, 
    {
        title = 'Report System',
        description = 'Berhasil mengirim laporan ',
        type = 'success'
    })

    TriggerClientEvent('nn_report:client:newReportNotify', -1)
    local discordId = string.gsub(discord, "discord:", "")
    local message = "**Player:** " .. "[" .. src .."] ".. player_name ..' | ' .. '<@'..discordId..'>' .. "\n" ..
    "**Category:** " .. data.category .. "\n" ..
    "**Priority:** " .. data.priority .. "\n\n" ..
    "**Message:** " .. data.description

    sendToDiscord("📢 New Report Received!", message, 3447003) 
end)


RegisterNetEvent('nn_report:server:updateReport', function(data)
    local src = source
    local report_id = report_data[data.report_id]

    local player = QBCore.Functions.GetPlayer(report_id.player_id)
    if not player then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Player tidak ditemukan!',
            type = 'error'
        })

        report_data[data.report_id] = nil
        return
    end

    local player_data = QBCore.Functions.GetPlayer(report_id.player_id).PlayerData
    local player_name = player_data.charinfo.firstname ..' '..player_data.charinfo.lastname

    local staff_data = QBCore.Functions.GetPlayer(src).PlayerData
    local staff_name = staff_data.charinfo.firstname ..' '..staff_data.charinfo.lastname
    local staff_discord = QBCore.Functions.GetIdentifier(src, 'discord')



    if report_data[data.report_id] then
        report_data[data.report_id].status = data.status

        local color = data.status == "Resolved" and 65280 or 16711680 
        local discordId = string.gsub(staff_discord, "discord:", "")
        
        local message = "**Player:** " .. "[" .. report_id.player_id .. "] " .. player_name .. "\n" ..
                        "**Staff :** " .. "[" .. src .. "] " .. staff_name .. ' | ' .. '<@'..discordId..'>'
        
        sendToDiscord("📢 Report From " .. player_name .." has been " .. data.status .. "!", message, color)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Report successfully updated to ' .. data.status,
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Report tidak ditemukan.',
            type = 'error'
        })
    end
end)


RegisterNetEvent('nn_report:server:goto', function(target)
    local src = source 
    local targetPlayer = GetPlayerPed(target) 

    if DoesEntityExist(targetPlayer) then
        local coords = GetEntityCoords(targetPlayer) 
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z, false, false, false, false)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Berhasil menarik player!',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Player tidak ditemukan.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('nn_report:server:bring', function(target)
    local src = source 
    local adminPed = GetPlayerPed(src)
    local targetPlayer = GetPlayerPed(target) 

    if DoesEntityExist(targetPlayer) then
        local coords = GetEntityCoords(adminPed)
        SetEntityCoords(targetPlayer, coords.x, coords.y, coords.z, false, false, false, false)
        
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Berhasil menarik player!',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report System',
            description = 'Player tidak ditemukan.',
            type = 'error'
        })
    end
end)


lib.callback.register('nn_report:server:getReportData', function()
    return report_data
end)


function sendToDiscord(title, message, color)
    local embedData = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "Report System - Dhika Nino",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers) end, "POST", json.encode({
        username = "Report Bot",
        embeds = embedData
    }), { ["Content-Type"] = "application/json" })
end



