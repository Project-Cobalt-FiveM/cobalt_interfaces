---@meta

---@class CobaltInterfacesExports
local CobaltInterfacesExports = {}

---**Client.** Shows a notification.
---@param data InterfaceNotifyProps
function CobaltInterfacesExports:notify(data) end

---**Server.** Shows a notification to one player.
---@param source integer server id, or -1 for everyone
---@param data InterfaceNotifyProps
function CobaltInterfacesExports:notify(source, data) end

---**Client.** Yields until the bar fills (true) or is cancelled or interrupted (false).
---@param data InterfaceProgressProps
---@return boolean completed
function CobaltInterfacesExports:progressBar(data) end

---**Client.**
---@return boolean
function CobaltInterfacesExports:progressActive() end

---**Client.** Errors when no bar is running.
function CobaltInterfacesExports:cancelProgress() end

---**Client.** Hides when the owner stops or the character unloads.
---@param text string
---@param options? InterfaceTextUIOptions
---@param owner? string resource the prompt belongs to, the invoking resource by default
function CobaltInterfacesExports:showTextUI(text, options, owner) end

---**Client.** Hides the prompt only when `owner` showed it.
---@param owner? string the invoking resource by default
function CobaltInterfacesExports:hideTextUI(owner) end

---**Client.**
---@return boolean open
---@return string? text
function CobaltInterfacesExports:isTextUIOpen() end

---**Client.** Yields. False when failed, when the owner stops, the character unloads or the player dies,
---and at once with a busy notification when a check is already running.
---@param difficulty SkillCheckDifficulty | SkillCheckDifficulty[]
---@param inputs? string[] keys picked from each round, { 'e' } by default
---@param owner? string resource the check belongs to, the invoking resource by default
---@return boolean
function CobaltInterfacesExports:skillCheck(difficulty, inputs, owner) end

---**Client.**
---@return boolean
function CobaltInterfacesExports:skillCheckActive() end

---**Client.** Errors when no check is running.
function CobaltInterfacesExports:cancelSkillCheck() end

---**Client.** The menus are dropped, and closed if open, when the owner stops.
---@param context ContextMenu | ContextMenu[]
---@param owner? string resource the menus belong to, the invoking resource by default
function CobaltInterfacesExports:registerContext(context, owner) end

---**Client.** Errors on an unknown id, a non-string id or a menu without an options table.
---@param id string
function CobaltInterfacesExports:showContext(id) end

---**Client.**
---@param onExit? boolean run the menu's onExit
function CobaltInterfacesExports:hideContext(onExit) end

---**Client.**
---@return string?
function CobaltInterfacesExports:getOpenContextMenu() end

---**Client.** Yields; one value per row. Nil when cancelled, when the owner stops, the character unloads
---or the player dies, and at once with a busy notification when another input dialog is open.
---Errors when `rows` is not a list.
---@param heading string
---@param rows (string | InputRow)[]
---@param options? InputOptions
---@param owner? string resource the dialog belongs to, the invoking resource by default
---@return any[]?
function CobaltInterfacesExports:inputDialog(heading, rows, options, owner) end

---**Client.**
function CobaltInterfacesExports:closeInputDialog() end

---**Client.** Yields. 'cancel' when dismissed, timed out, when the owner stops, the character unloads
---or the player dies, and at once with a busy notification when another alert is open.
---@param data AlertProps
---@param timeout? number milliseconds before it closes as 'cancel'
---@param owner? string resource the alert belongs to, the invoking resource by default
---@return 'confirm' | 'cancel'
function CobaltInterfacesExports:alertDialog(data, timeout, owner) end

---**Client.**
---@param reason? 'confirm' | 'cancel'
function CobaltInterfacesExports:closeAlertDialog(reason) end

---**Client.** Adds or replaces top-level radial items by id.
---@param items InterfaceRadialItem | InterfaceRadialItem[]
function CobaltInterfacesExports:addRadialItem(items) end

---**Client.**
---@param id string
function CobaltInterfacesExports:removeRadialItem(id) end

---**Client.** Removes the top-level items the calling resource added.
function CobaltInterfacesExports:clearRadialItems() end

---**Client.**
---@param menu RadialMenu
function CobaltInterfacesExports:registerRadial(menu) end

---**Client.**
function CobaltInterfacesExports:hideRadial() end

---**Client.**
---@param state boolean
function CobaltInterfacesExports:disableRadial(state) end

---**Client.** The open menu's id, 'root' for the top level, nil when closed.
---@return string?
function CobaltInterfacesExports:getCurrentRadialId() end

exports.cobalt_interfaces = CobaltInterfacesExports
