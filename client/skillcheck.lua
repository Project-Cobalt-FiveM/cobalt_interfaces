local nui <const> = require 'client.nui'
local notify <const> = require 'client.notify'

local SkillCheck <const> = {}

---@class PendingSkillCheck
---@field promise promise
---@field owner string

---@type PendingSkillCheck?
local pending

---@alias SkillCheckDifficulty 'easy' | 'medium' | 'hard' | { areaSize: number, speedMultiplier: number }

---@param success boolean
local function finish(success)
    if not pending then return end

    local result <const> = pending.promise
    pending = nil
    nui.focus('skillcheck', nil)
    result:resolve(success)
end

---@param difficulty SkillCheckDifficulty | SkillCheckDifficulty[] one round per entry
---@param inputs? string[] keys to pick from each round, 'e' by default
---@param owner? string resource the check belongs to; it closes when that resource stops
---@return boolean
function SkillCheck.start(difficulty, inputs, owner)
    if pending then
        notify.busy()
        return false
    end

    local current <const> = { promise = promise.new(), owner = owner or GetInvokingResource() or cache.resource }
    pending = current
    nui.send('skillCheckStart', { difficulty = difficulty, inputs = inputs })
    nui.focus('skillcheck', 'keys')

    return Citizen.Await(current.promise)
end

---@return boolean
function SkillCheck.isActive()
    return pending ~= nil
end

function SkillCheck.cancel()
    if not pending then error('No skill check is active', 2) end

    nui.send('skillCheckCancel')
end

---@param owner? string only close a check this resource started
function SkillCheck.release(owner)
    if not pending or owner and pending.owner ~= owner then return end

    nui.send('skillCheckCancel')
    finish(false)
end

RegisterNUICallback('skillCheckOver', function(success, cb)
    cb(1)
    finish(success == true)
end)

return SkillCheck
