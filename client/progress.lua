local nui <const> = require 'client.nui'
local config <const> = require 'config'

local Progress <const> = {}

local DisableControlAction <const> = DisableControlAction
local DisablePlayerFiring <const> = DisablePlayerFiring
local playerState <const> = LocalPlayer.state

local CANCEL_COMMAND <const> = 'cobaltcancelprogress'
local CANCEL_COMMAND_HASH <const> = `cobaltcancelprogress` | 0x80000000

---@type InterfaceProgressProps | false | nil running bar, false once cancelled, nil when idle
local active

---@class InterfaceProgressProps
---@field label? string
---@field duration number milliseconds
---@field icon? string Phosphor icon name
---@field useWhileDead? boolean
---@field allowRagdoll? boolean
---@field allowCuffed? boolean
---@field allowFalling? boolean
---@field allowSwimming? boolean
---@field canCancel? boolean
---@field anim? { dict?: string, clip: string, flag?: number, blendIn?: number, blendOut?: number, duration?: number, playbackRate?: number, lockX?: boolean, lockY?: boolean, lockZ?: boolean, scenario?: string, playEnter?: boolean }
---@field prop? table same shape as ox_lib's progress props
---@field disable? { move?: boolean, sprint?: boolean, car?: boolean, combat?: boolean, mouse?: boolean }

---@param data InterfaceProgressProps
---@return boolean
local function interrupted(data)
    local ped <const> = cache.ped

    if not data.useWhileDead and IsEntityDead(ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(ped) then return true end
    if not data.allowCuffed and IsPedCuffed(ped) then return true end
    if not data.allowFalling and IsPedFalling(ped) then return true end
    if not data.allowSwimming and IsPedSwimming(ped) then return true end

    return false
end

---@param disable { move?: boolean, sprint?: boolean, car?: boolean, combat?: boolean, mouse?: boolean }
local function disableControls(disable)
    if disable.mouse then
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 106, true)
    end

    if disable.move then
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 36, true)
    elseif disable.sprint then
        DisableControlAction(0, 21, true)
    end

    if disable.car then
        DisableControlAction(0, 63, true)
        DisableControlAction(0, 64, true)
        DisableControlAction(0, 71, true)
        DisableControlAction(0, 72, true)
        DisableControlAction(0, 75, true)
    end

    if disable.combat then
        DisableControlAction(0, 25, true)
        DisablePlayerFiring(cache.playerId, true)
    end
end

---@param anim table
local function playAnim(anim)
    if anim.dict then
        lib.requestAnimDict(anim.dict)
        TaskPlayAnim(
            cache.ped,
            anim.dict,
            anim.clip,
            anim.blendIn or 3.0,
            anim.blendOut or 1.0,
            anim.duration or -1,
            anim.flag or 49,
            anim.playbackRate or 0,
            anim.lockX,
            anim.lockY,
            anim.lockZ
        )
        RemoveAnimDict(anim.dict)
    elseif anim.scenario then
        TaskStartScenarioInPlace(cache.ped, anim.scenario, 0, anim.playEnter ~= false)
    end
end

---@param anim table
local function stopAnim(anim)
    if anim.dict then
        StopAnimTask(cache.ped, anim.dict, anim.clip, 1.0)
    else
        ClearPedTasks(cache.ped)
    end
end

---@return string
local function cancelKeyLabel()
    local button <const> = GetControlInstructionalButton(0, CANCEL_COMMAND_HASH, true)

    return button and button:match('^t_(.+)$') or 'X'
end

---@param busy boolean
local function setBusy(busy)
    playerState:set('invBusy', busy, false)
end

local function blockPauseMenu()
    DisableControlAction(0, 199, true)
    DisableControlAction(0, 200, true)
end

---@param completed boolean
local function playOutcome(completed)
    if not config.sounds.enabled or GetResourceState('cobalt_sound') ~= 'started' then return end

    exports.cobalt_sound:PlayFrontend(completed and 'progress_complete' or 'progress_cancel', config.sounds.volume)
end

---@param data InterfaceProgressProps
---@return boolean completed
local function run(data)
    nui.send('progressStart', {
        label = data.label,
        duration = data.duration,
        icon = data.icon,
        cancelKey = data.canCancel and cancelKeyLabel() or nil,
    })

    if data.anim then playAnim(data.anim) end
    if data.prop then TriggerServerEvent('ox_lib:progressProps', data.prop) end

    if IsPauseMenuActive() then SetFrontendActive(false) end

    local finishAt <const> = GetGameTimer() + data.duration

    while active and GetGameTimer() < finishAt do
        blockPauseMenu()

        if data.disable then disableControls(data.disable) end
        if interrupted(data) then active = false end

        Wait(0)
    end

    return active ~= false
end

---@param data InterfaceProgressProps
---@return boolean completed
function Progress.start(data)
    while active ~= nil do Wait(0) end

    if interrupted(data) then return false end

    active = data
    setBusy(true)

    local ok <const>, completed <const> = pcall(run, data)
    local finished <const> = ok and completed == true
    active = nil

    nui.send('progressStop', { completed = finished })
    playOutcome(finished)

    if data.prop then TriggerServerEvent('ox_lib:progressProps', nil) end

    if data.anim then
        stopAnim(data.anim)
        Wait(0)
    end

    setBusy(false)

    if not ok then error(completed, 0) end

    return completed
end

---@return boolean
function Progress.isActive()
    return active ~= nil
end

function Progress.cancel()
    if active == nil then error('No progress bar is active', 2) end

    active = false
end

RegisterCommand(CANCEL_COMMAND, function()
    if active and active.canCancel then active = false end
end, false)

RegisterKeyMapping(CANCEL_COMMAND, locale('keybind.cancel_progress'), 'keyboard', 'x')

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource or not active then return end

    if active.prop then TriggerServerEvent('ox_lib:progressProps', nil) end
    if active.anim then stopAnim(active.anim) end

    setBusy(false)
end)

return Progress
