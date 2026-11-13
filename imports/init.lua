local resource <const> = exports.cobalt_interfaces

---@type CobaltInterfacesExports
Interfaces = setmetatable({}, {
    __index = function(self, name)
        local fn <const> = function(...) return resource[name](resource, ...) end

        rawset(self, name, fn)

        return fn
    end,
})
