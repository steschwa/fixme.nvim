local Logger = require("fixme.utils.logging")

--- @class Config
--- @field providers FixmeComponentProvider[]
--- @field column_separator string
--- @field hooks FixmeHook[]
local Config = {}

--- @class CreateConfigParams
--- @field providers? FixmeComponentProvider[]
--- @field column_separator? string
--- @field hooks? FixmeHook[]

--- @param params CreateConfigParams
--- @return Config
function Config:create(params)
    --- @type Config
    local this = {
        providers = params.providers or {},
        column_separator = params.column_separator or " ",
        hooks = params.hooks or {},
    }
    setmetatable(this, self)
    self.__index = self

    this:validate()

    return this
end

function Config:validate()
    if type(self.providers) ~= "table" then
        Logger.error("'providers' must be a table, but got " .. type(self.providers))
        return
    end
    if #self.providers == 0 then
        Logger.warn("no 'providers' given. this plugin does not work with zero-config")
        return
    end

    if type(self.column_separator) ~= "string" then
        Logger.error("'column_separator' must be a string, but got " .. type(self.column_separator))
        return
    end

    if type(self.hooks) ~= "table" then
        Logger.error("'hooks' must be a table, but got " .. type(self.hooks))
        return
    end
    for i, hook in ipairs(self.hooks) do
        if type(hook) ~= "function" then
            Logger.error(
                string.format("'hooks.[%d]' must be a function, but got %s", i, type(hook))
            )
            return
        end
    end
end

return Config
