---@diagnostic disable: duplicate-set-field

if not lib then error('@cobalt_interfaces/imports/lib.lua must load after @ox_lib/init.lua') end

local RESOURCE <const> = 'cobalt_interfaces'
local interfaces <const> = exports[RESOURCE]

---@return boolean
local function started()
    return GetResourceState(RESOURCE) == 'started'
end

---@param name string name on lib and on the export surface
---@return function
local function routed(name)
    local fallback <const> = lib[name]

    return function(...)
        if started() then return interfaces[name](interfaces, ...) end

        return fallback(...)
    end
end

if IsDuplicityVersion() then
    lib.notify = routed('notify')
    return
end

for _, name in ipairs({
    'notify',
    'progressBar', 'progressActive', 'cancelProgress',
    'showTextUI', 'hideTextUI', 'isTextUIOpen',
    'skillCheck', 'skillCheckActive', 'cancelSkillCheck',
    'inputDialog', 'closeInputDialog',
    'alertDialog', 'closeAlertDialog',
    'addRadialItem', 'removeRadialItem', 'clearRadialItems', 'registerRadial',
    'hideRadial', 'disableRadial', 'getCurrentRadialId',
}) do
    lib[name] = routed(name)
end

---@type table<string, table>
local contexts <const> = {}
local oxRegisterContext <const> = lib.registerContext

---@param context table
local function registerContext(context)
    local list <const> = context.id and { context } or context

    for _, menu in ipairs(list) do contexts[menu.id] = menu end

    oxRegisterContext(context)

    if started() then interfaces:registerContext(context) end
end

lib.registerContext = registerContext
lib.showContext = routed('showContext')
lib.hideContext = routed('hideContext')
lib.getOpenContextMenu = routed('getOpenContextMenu')

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= RESOURCE then return end

    for _, menu in pairs(contexts) do interfaces:registerContext(menu) end
end)
