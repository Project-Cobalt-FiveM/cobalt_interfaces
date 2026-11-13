local nui <const> = require 'client.nui'

local TextUI <const> = {}

---@type { text: string, owner: string }?
local current

---@class InterfaceTextUIOptions
---@field key? string keycap label; "[E] - Open trunk" also works
---@field icon? string Phosphor icon name, shown when there is no key
---@field position? 'left-center' | 'right-center' | 'top-center' | 'bottom-center'

---@param text string
---@param options? InterfaceTextUIOptions
---@param owner? string resource the prompt belongs to; it hides when that resource stops
function TextUI.show(text, options, owner)
    owner = owner or GetInvokingResource() or cache.resource

    if current?.text == text and current.owner == owner then return end

    options = options or {}
    current = { text = text, owner = owner }

    nui.send('textUiShow', {
        text = text,
        key = options.key,
        icon = options.icon,
        position = options.position,
    })
end

---@param owner? string only hide a prompt this resource showed
function TextUI.release(owner)
    if not current or owner and current.owner ~= owner then return end

    current = nil
    nui.send('textUiHide')
end

---@param owner? string resource hiding its prompt; another resource's prompt stays
function TextUI.hide(owner)
    TextUI.release(owner or GetInvokingResource() or cache.resource)
end

---@return boolean
---@return string?
function TextUI.isOpen()
    return current ~= nil, current?.text
end

return TextUI
