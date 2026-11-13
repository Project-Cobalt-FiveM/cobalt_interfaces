---@class InterfacesConfig
---@field sounds { enabled: boolean, volume: number } volume is 0 to 1

---@type InterfacesConfig
return {
    -- Sounds played when a progress bar completes or is cancelled
    sounds = {
        enabled = true, -- false silences them
        volume = 0.3, -- 0.0 (silent) to 1.0 (full volume)
    },
}
