local nui <const> = require 'client.nui'

local Radial <const> = {}

local COMMAND <const> = 'cobaltradial'
local TAP_MS <const> = 250

---@class InterfaceRadialItem
---@field id string
---@field label string
---@field icon? string Phosphor icon name
---@field menu? string id of a menu from registerRadial, opened in place
---@field onSelect? fun(currentMenu: string?, itemIndex: integer)
---@field event? string
---@field serverEvent? string
---@field args? any
---@field keepOpen? boolean
---@field disabled? boolean | fun(): boolean
---@field canInteract? fun(): boolean

---@class RadialMenu
---@field id string
---@field label? string
---@field items InterfaceRadialItem[]

---@type { item: InterfaceRadialItem, owner: string }[]
local rootItems <const> = {}

---@type table<string, { menu: RadialMenu, owner: string }>
local menus <const> = {}

---@type InterfaceRadialItem[]
local shown = {}

---@type (string | false)[]
local stack = {}

---@type string?
local currentMenu

local isOpen = false
local isDisabled = false
local clickMode = false
local pressedAt = 0

---@return string
local function caller()
    return GetInvokingResource() or cache.resource
end

---@param check boolean | fun(): boolean | nil
---@param default boolean
---@return boolean
local function evaluate(check, default)
    if type(check) == 'boolean' then return check end
    if not check then return default end

    local ok <const>, result <const> = pcall(check)

    return ok and result == true
end

---@param item InterfaceRadialItem
---@return boolean
local function visible(item)
    if item.canInteract == nil then return true end

    return evaluate(item.canInteract, true)
end

---@param id string
---@return integer?
local function rootIndex(id)
    for index, entry in ipairs(rootItems) do
        if entry.item.id == id then return index end
    end
end

---@param item InterfaceRadialItem
---@return table
local function toWire(item)
    local submenu <const> = item.menu and menus[item.menu]

    return {
        id = item.id,
        label = item.label,
        icon = item.icon,
        disabled = evaluate(item.disabled, false),
        submenu = submenu ~= nil,
        count = submenu and #submenu.menu.items or nil,
    }
end

---@param menuId string?
---@return InterfaceRadialItem[]
local function itemsOf(menuId)
    if menuId then
        local entry <const> = menus[menuId]
        return entry and entry.menu.items or {}
    end

    local list <const> = {}

    for _, entry in ipairs(rootItems) do
        list[#list + 1] = entry.item
    end

    return list
end

local function release()
    isOpen = false
    clickMode = false
    shown = {}
    stack = {}
    currentMenu = nil
    nui.focus('radial', nil)
end

function Radial.hide()
    if not isOpen then return end

    release()
    nui.send('radialHide')
end

---@param menuId string?
---@return boolean
local function show(menuId)
    shown = {}

    local wire <const> = {}

    for _, item in ipairs(itemsOf(menuId)) do
        if visible(item) and type(item.label) == 'string' and item.label ~= '' then
            shown[#shown + 1] = item
            wire[#wire + 1] = toWire(item)
        end
    end

    if #shown == 0 then return false end

    currentMenu = menuId

    local parent <const> = stack[#stack]
    local parentMenu <const> = parent and menus[parent]
    local menu <const> = menuId and menus[menuId]

    nui.send('radialShow', {
        menu = menuId or 'root',
        label = menu and menu.menu.label or nil,
        parent = #stack > 0 and (parentMenu and parentMenu.menu.label or locale('radial.menu')) or nil,
        clickMode = clickMode,
        items = wire,
    })

    return true
end

local function open()
    if isOpen or isDisabled or IsPauseMenuActive() or IsNuiFocused() then return end
    if not show(nil) then return end

    isOpen = true
    pressedAt = GetGameTimer()
    nui.focus('radial', 'game')
    SetCursorLocation(0.5, 0.5)

    CreateThread(function()
        while isOpen do
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 68, true)
            DisableControlAction(0, 69, true)
            DisableControlAction(0, 70, true)
            DisableControlAction(0, 91, true)
            DisableControlAction(0, 92, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 199, true)
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisablePlayerFiring(cache.playerId, true)
            Wait(0)
        end
    end)
end

---@param item InterfaceRadialItem
---@param menuId string?
---@param index integer
local function run(item, menuId, index)
    if item.onSelect then
        local ok <const>, err <const> = pcall(item.onSelect, menuId, index)
        if not ok then lib.print.error(('radial item %s failed: %s'):format(item.id, err)) end
    end

    if item.event then TriggerEvent(item.event, item.args) end
    if item.serverEvent then TriggerServerEvent(item.serverEvent, item.args) end
end

---@param index integer
local function choose(index)
    local item <const> = shown[index]
    if not item or evaluate(item.disabled, false) then return end

    if item.menu then
        stack[#stack + 1] = currentMenu or false
        if not show(item.menu) then table.remove(stack) end
        return
    end

    local menuId <const> = currentMenu

    if not item.keepOpen then Radial.hide() end

    run(item, menuId, index)
end

local function back()
    if #stack == 0 then return Radial.hide() end

    local previous <const> = table.remove(stack)

    if not show(previous or nil) then Radial.hide() end
end

---@param items InterfaceRadialItem | InterfaceRadialItem[]
function Radial.addItem(items)
    local owner <const> = caller()

    for _, item in ipairs(items.id and { items } or items) do
        local index <const> = rootIndex(item.id)
        local entry <const> = { item = item, owner = owner }

        if index then
            rootItems[index] = entry
        else
            rootItems[#rootItems + 1] = entry
        end
    end
end

---@param id string
function Radial.removeItem(id)
    local index <const> = rootIndex(id)

    if index then table.remove(rootItems, index) end
end

function Radial.clearItems()
    local owner <const> = caller()

    for index = #rootItems, 1, -1 do
        if rootItems[index].owner == owner then table.remove(rootItems, index) end
    end
end

---@param menu RadialMenu
function Radial.register(menu)
    menus[menu.id] = { menu = menu, owner = caller() }
end

---@param state boolean
function Radial.disable(state)
    isDisabled = state == true

    if isDisabled then Radial.hide() end
end

---@return string?
function Radial.getCurrentId()
    if not isOpen then return end

    return currentMenu or 'root'
end

RegisterCommand('+' .. COMMAND, function()
    if not isOpen then return open() end
    if clickMode then Radial.hide() end
end, false)

RegisterCommand('-' .. COMMAND, function()
    if not isOpen or clickMode then return end

    clickMode = true

    if GetGameTimer() - pressedAt < TAP_MS then
        nui.send('radialClickMode')
        return
    end

    nui.send('radialRelease')
end, false)

RegisterKeyMapping('+' .. COMMAND, locale('keybind.radial'), 'keyboard', 'F1')

RegisterNUICallback('radialSelect', function(data, cb)
    cb(1)

    if not isOpen or type(data) ~= 'table' then return end

    local index <const> = math.tointeger(data.index)
    if index then choose(index) end
end)

RegisterNUICallback('radialBack', function(_, cb)
    cb(1)

    if isOpen then back() end
end)

RegisterNUICallback('radialClose', function(_, cb)
    cb(1)

    Radial.hide()
end)

AddEventHandler('onClientResourceStop', function(resource)
    for index = #rootItems, 1, -1 do
        if rootItems[index].owner == resource then table.remove(rootItems, index) end
    end

    for id, entry in pairs(menus) do
        if entry.owner == resource then menus[id] = nil end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and isOpen then nui.focus('radial', nil) end
end)

return Radial
