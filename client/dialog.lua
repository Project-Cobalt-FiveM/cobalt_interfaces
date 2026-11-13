local nui <const> = require 'client.nui'
local notify <const> = require 'client.notify'

local Dialog <const> = {}

---@class PendingDialog
---@field promise promise
---@field owner string

---@type PendingDialog?
local pendingInput

---@type PendingDialog?
local pendingAlert

---@class InputRow
---@field type? 'input' | 'number' | 'select' | 'multi-select' | 'slider' | 'checkbox' | 'textarea' | 'date' | 'color'
---@field label string
---@field description? string
---@field placeholder? string
---@field icon? string
---@field prefix? string
---@field required? boolean
---@field disabled? boolean
---@field default? any
---@field checked? boolean
---@field password? boolean
---@field min? number
---@field max? number
---@field step? number
---@field options? { value: any, label?: string, disabled?: boolean }[]
---@field returnString? boolean

---@class InputOptions
---@field allowCancel? boolean
---@field icon? string
---@field description? string
---@field submitText? string
---@field cancelText? string

---@param value any
---@return boolean
local function isList(value)
    if type(value) ~= 'table' then return false end

    local count = 0

    for _ in pairs(value) do count += 1 end

    return count == #value
end

---@param owner? string
---@return PendingDialog
local function pend(owner)
    return { promise = promise.new(), owner = owner or GetInvokingResource() or cache.resource }
end

---@param heading string
---@param rows (string | InputRow)[]
---@param options? InputOptions
---@param owner? string resource the dialog belongs to; it closes when that resource stops
---@return any[]?
function Dialog.input(heading, rows, options, owner)
    if not isList(rows) then error('inputDialog rows must be a list', 2) end

    if pendingInput then
        notify.busy()
        return
    end

    local current <const> = pend(owner)
    pendingInput = current
    nui.send('inputDialogOpen', { heading = heading, rows = rows, options = options })
    nui.focus('inputDialog', 'cursor')

    return Citizen.Await(current.promise)
end

function Dialog.closeInput()
    if not pendingInput then return end

    nui.send('inputDialogClose')
end

---@class AlertProps
---@field header string
---@field content? string
---@field type? 'confirm' | 'danger'
---@field icon? string
---@field cancel? boolean
---@field labels? { confirm?: string, cancel?: string }

---@param data AlertProps
---@param timeout? number milliseconds before the dialog closes as 'cancel'
---@param owner? string resource the dialog belongs to; it closes when that resource stops
---@return 'confirm' | 'cancel'
function Dialog.alert(data, timeout, owner)
    if type(data) ~= 'table' then error('alertDialog data must be a table', 2) end

    if pendingAlert then
        notify.busy()
        return 'cancel'
    end

    local current <const> = pend(owner)
    pendingAlert = current
    nui.send('alertDialogOpen', data)
    nui.focus('alertDialog', 'cursor')

    if timeout then
        SetTimeout(timeout, function()
            if pendingAlert == current then Dialog.closeAlert('cancel') end
        end)
    end

    return Citizen.Await(current.promise)
end

---@param reason? 'confirm' | 'cancel'
function Dialog.closeAlert(reason)
    if not pendingAlert then return end

    nui.send('alertDialogClose', { reason = reason or 'cancel' })
end

---@param values any[]?
local function finishInput(values)
    if not pendingInput then return end

    local result <const> = pendingInput.promise
    pendingInput = nil
    nui.focus('inputDialog', nil)
    result:resolve(values)
end

---@param reason 'confirm' | 'cancel'
local function finishAlert(reason)
    if not pendingAlert then return end

    local result <const> = pendingAlert.promise
    pendingAlert = nil
    nui.focus('alertDialog', nil)
    result:resolve(reason)
end

---@param owner? string only close dialogs this resource opened
function Dialog.release(owner)
    if pendingInput and (not owner or pendingInput.owner == owner) then
        nui.send('inputDialogClose')
        finishInput(nil)
    end

    if pendingAlert and (not owner or pendingAlert.owner == owner) then
        nui.send('alertDialogClose', { reason = 'cancel' })
        finishAlert('cancel')
    end
end

RegisterNUICallback('inputDialogSubmit', function(data, cb)
    cb(1)
    finishInput(type(data) == 'table' and data.values or nil)
end)

RegisterNUICallback('alertDialogSubmit', function(data, cb)
    cb(1)
    finishAlert(type(data) == 'table' and data.result == 'confirm' and 'confirm' or 'cancel')
end)

return Dialog
