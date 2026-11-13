local nui <const> = require 'client.nui'

local Context <const> = {}

---@class ContextOption
---@field title? string
---@field description? string
---@field icon? string Phosphor icon name (common Font Awesome names also resolve)
---@field iconColor? string
---@field progress? number 0 to 100
---@field colorScheme? string hex, or blue, green, yellow, orange, red
---@field arrow? boolean
---@field menu? string id of a submenu to open
---@field disabled? boolean
---@field readOnly? boolean
---@field onSelect? fun(args: any)
---@field event? string
---@field serverEvent? string
---@field args? any

---@class ContextMenu
---@field id string
---@field title string
---@field menu? string id of the parent menu; shows a back button
---@field canClose? boolean
---@field onExit? fun()
---@field onBack? fun()
---@field options { [string]: ContextOption } | ContextOption[]

---@type table<string, { data: ContextMenu, owner: string }>
local menus <const> = {}

---@type string?
local openId

---@type string?
local openOwner

---@param fn function | table | nil
local function call(fn, ...)
    if type(fn) ~= 'function' and type(fn) ~= 'table' then return end

    local ok <const>, err <const> = pcall(fn, ...)

    if not ok then lib.print.error(err) end
end

---@param a string | number
---@param b string | number
---@return boolean
local function sortKeys(a, b)
    if type(a) == type(b) then return a < b end

    return type(a) == 'number'
end

---@param options { [string | number]: ContextOption }
---@return table[]
local function toWire(options)
    local keys <const> = {}

    for key in pairs(options) do keys[#keys + 1] = key end

    table.sort(keys, sortKeys)

    local list <const> = {}

    for i, key in ipairs(keys) do
        local option <const> = options[key]

        list[i] = {
            key = key,
            title = option.title,
            description = option.description,
            icon = type(option.icon) == 'string' and option.icon or nil,
            iconColor = option.iconColor,
            progress = option.progress,
            colorScheme = option.colorScheme,
            arrow = option.arrow ~= false and (option.arrow or option.menu ~= nil),
            disabled = option.disabled,
            readOnly = option.readOnly,
        }
    end

    return list
end

---@param runOnExit boolean
local function close(runOnExit)
    if not openId then return end

    local menu <const> = menus[openId]
    openId = nil
    openOwner = nil

    nui.focus('context', nil)
    nui.send('contextHide')

    if runOnExit and menu then call(menu.data.onExit) end
end

---@param context ContextMenu | ContextMenu[]
---@param owner? string resource the menus belong to; they are dropped when that resource stops
function Context.register(context, owner)
    owner = owner or GetInvokingResource() or cache.resource

    if context.id then
        menus[context.id] = { data = context, owner = owner }
        return
    end

    for _, menu in ipairs(context) do
        menus[menu.id] = { data = menu, owner = owner }
    end
end

---@param id string
function Context.show(id)
    local menu <const> = menus[id]

    if not menu then error(('No context menu registered with id %s'):format(id), 2) end

    local data <const> = menu.data

    if type(id) ~= 'string' then error('Context menu ids must be strings', 2) end
    if type(data.options) ~= 'table' then error(('Context menu %s has no options table'):format(id), 2) end

    nui.send('contextShow', {
        id = id,
        title = data.title,
        canBack = data.menu ~= nil,
        canClose = data.canClose,
        options = toWire(data.options),
    })

    openId = id
    openOwner = menu.owner
    nui.focus('context', 'cursor')
end

---@param onExit? boolean run the menu's onExit
function Context.hide(onExit)
    close(onExit == true)
end

---@return string?
function Context.getOpen()
    return openId
end

---@param owner? string only close a menu this resource registered
function Context.release(owner)
    if owner and openOwner ~= owner then return end

    close(false)
end

---@param id string
---@return ContextMenu?
local function openMenu(id)
    if id ~= openId then return end

    return menus[id]?.data
end

RegisterNUICallback('contextSelect', function(body, cb)
    cb(1)

    local data <const> = openMenu(body.id)

    if not data then return end

    local key <const> = math.type(body.key) == 'float' and math.tointeger(body.key) or body.key
    local option <const> = data.options[key]

    if not option or option.disabled or option.readOnly then return end

    if option.menu then return Context.show(option.menu) end

    if not option.onSelect and not option.event and not option.serverEvent then return end

    close(false)

    call(option.onSelect, option.args)

    if option.event then TriggerEvent(option.event, option.args) end
    if option.serverEvent then TriggerServerEvent(option.serverEvent, option.args) end
end)

RegisterNUICallback('contextBack', function(body, cb)
    cb(1)

    local data <const> = openMenu(body.id)

    if not data or not data.menu then return end

    call(data.onBack)
    Context.show(data.menu)
end)

RegisterNUICallback('contextClose', function(body, cb)
    cb(1)

    local data <const> = openMenu(body.id)

    if not data or data.canClose == false then return end

    close(true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then return end

    for id, menu in pairs(menus) do
        if menu.owner == resource then menus[id] = nil end
    end
end)

return Context
