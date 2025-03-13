local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

local isCooldown = false 

CreateThread(function()
    while true do
        Wait(Config.Delay * 1000)
        isCooldown = false
    end
end)

RegisterCommand(Config.Command, function()
  if isCooldown then
    lib.notify({
      title = 'Report System',
      description = 'Sedang cooldown!',
      type = 'warning'
    })
    return
  end
  isCooldown = true
  toggleNuiFrame(true)
  SendReactMessage('getCategories', Config.ReportCategories)
  SendReactMessage('isAdmin', false)
end)


RegisterCommand(Config.AdminCommand, function()

  local haveAccess = lib.callback.await('nn_report:server:checkPermission')
  if haveAccess then
    toggleNuiFrame(true)
    SendReactMessage('isAdmin', true)

    local report_data = lib.callback.await('nn_report:server:getReportData')
    SendReactMessage('getReport', report_data)
  end
end)

RegisterNetEvent('nn_report:client:newReportNotify', function()
  local haveAccess = lib.callback.await('nn_report:server:checkPermission')
  if haveAccess then
    lib.notify({
      title = 'Report System',
      description = 'Kamu menerima laporan baru!',
      type = 'info'
    })
  end
end)


RegisterNUICallback('getCategories', function(data, cb) 
  cb(Config.ReportCategories)
end)

RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  cb({})
end)


RegisterNUICallback('getReportData', function(_, cb) 

  local haveAccess = lib.callback.await('nn_report:server:checkPermission')
  if haveAccess then
    local report_data = lib.callback.await('nn_report:server:getReportData')
    cb({report_data})
  end
end)

RegisterNUICallback('submitReport', function(data, cb) 
  TriggerServerEvent('nn_report:server:sendReport', data)
  cb({})
end)

RegisterNUICallback('updateStatusReport',  function(data, cb) 
  
  local haveAccess = lib.callback.await('nn_report:server:checkPermission')
  if haveAccess then
    TriggerServerEvent('nn_report:server:updateReport', data)
    cb({})
  end

end)


RegisterNUICallback('gotoPlayer', function(data, cb)
  local haveAccess = lib.callback.await('nn_report:server:checkPermission')
  if haveAccess then
    TriggerServerEvent('nn_report:server:goto', data)
    cb({})
  end
end)

RegisterNUICallback('bringPlayer', function(data, cb)
  local haveAccess = lib.callback.await('nn_report:server:checkPermission')
  if haveAccess then
    TriggerServerEvent('nn_report:server:bring', data)
    cb({})
  end
end)
