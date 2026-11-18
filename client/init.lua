local nui <const> = require 'client.nui'
local notify <const> = require 'client.notify'
local progress <const> = require 'client.progress'
local textui <const> = require 'client.textui'
local skillcheck <const> = require 'client.skillcheck'
local context <const> = require 'client.context'
local dialog <const> = require 'client.dialog'
local radial <const> = require 'client.radial'
local card <const> = require 'client.card'

exports('notify', notify.show)

exports('progressBar', progress.start)
exports('progressActive', progress.isActive)
exports('cancelProgress', progress.cancel)

exports('showTextUI', textui.show)
exports('hideTextUI', textui.hide)
exports('isTextUIOpen', textui.isOpen)

exports('skillCheck', skillcheck.start)
exports('skillCheckActive', skillcheck.isActive)
exports('cancelSkillCheck', skillcheck.cancel)

exports('registerContext', context.register)
exports('showContext', context.show)
exports('hideContext', context.hide)
exports('getOpenContextMenu', context.getOpen)

exports('inputDialog', dialog.input)
exports('closeInputDialog', dialog.closeInput)
exports('alertDialog', dialog.alert)
exports('closeAlertDialog', dialog.closeAlert)

exports('addRadialItem', radial.addItem)
exports('removeRadialItem', radial.removeItem)
exports('clearRadialItems', radial.clearItems)
exports('registerRadial', radial.register)
exports('hideRadial', radial.hide)
exports('disableRadial', radial.disable)
exports('getCurrentRadialId', radial.getCurrentId)

AddEventHandler('cobalt_interfaces:client:showCard', card.show)
AddEventHandler('cobalt_interfaces:client:hideCard', card.hide)

---@type table<string, string>
local uiLocales <const> = {}

for key, value in pairs(lib.getLocales()) do
    if key:sub(1, 3) == 'ui.' then uiLocales[key] = value end
end

RegisterNUICallback('ready', function(_, cb)
    cb(1)
    nui.send('setLocales', uiLocales)
end)

---@param owner? string only close what this resource opened; nil closes everything
local function release(owner)
    skillcheck.release(owner)
    dialog.release(owner)
    context.release(owner)
    textui.release(owner)
end

local function closeInteractive()
    skillcheck.release()
    dialog.release()
    context.release()
    radial.hide()
end

local function releaseAll()
    closeInteractive()
    textui.release()
end

LocalPlayer.state:set('interfacesReady', true, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return release(resource) end

    LocalPlayer.state:set('interfacesReady', false, false)
    releaseAll()
end)

RegisterNetEvent('cobalt_core:Client:OnPlayerUnload', function()
    if progress.isActive() then progress.cancel() end

    releaseAll()
end)

AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, dead)
    if dead then closeInteractive() end
end)
