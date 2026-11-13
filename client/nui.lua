local Nui <const> = {}

---@alias FocusMode 'cursor' | 'keys' | 'game'

---@type table<string, FocusMode>
local focus <const> = {}

---@param action string
---@param data? table
function Nui.send(action, data)
    SendNUIMessage({ action = action, data = data })
end

---@param owner string interface claiming focus; closing one never drops focus another still holds
---@param mode FocusMode?
function Nui.focus(owner, mode)
    focus[owner] = mode

    local cursor = false
    local keepInput = false

    for _, ownerMode in pairs(focus) do
        if ownerMode == 'cursor' or ownerMode == 'game' then cursor = true end
        if ownerMode == 'game' then keepInput = true end
    end

    SetNuiFocus(next(focus) ~= nil, cursor)
    SetNuiFocusKeepInput(keepInput)
end

return Nui
