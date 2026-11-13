---@param source integer player server id, or -1 for everyone
---@param data InterfaceNotifyProps
local function notify(source, data)
    TriggerClientEvent('cobalt_interfaces:notify', source, data)
end

exports('notify', notify)
