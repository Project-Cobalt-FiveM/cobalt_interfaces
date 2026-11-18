local nui <const> = require 'client.nui'

local Notify <const> = {}

---@class InterfaceNotifyProps
---@field id? string replaces a visible notification with the same id
---@field title? string
---@field description? string
---@field type? 'success' | 'error' | 'warning' | 'info' | 'inform'
---@field duration? number milliseconds, 5000 by default
---@field icon? string Phosphor icon name
---@field iconColor? string

---@param data InterfaceNotifyProps
function Notify.show(data)
    nui.send('notify', data)
end

function Notify.busy()
    Notify.show({ description = locale('notify.busy'), type = 'error', duration = 2500 })
end

RegisterNetEvent('cobalt_interfaces:notify', Notify.show)

return Notify
