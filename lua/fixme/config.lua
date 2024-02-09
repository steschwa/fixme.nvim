--- @class Config
--- @field providers FixmeComponentProvider[]
--- @field column_separator string
--- @field hooks FixmeHooks
local Config = {}

--- @class CreateConfigParams
--- @field providers? FixmeComponentProvider[]
--- @field column_separator? string
--- @field hooks? FixmeHooks

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
        vim.notify(
            "'providers' must be a table, but got " .. type(self.providers),
            vim.log.levels.ERROR
        )
        return
    end
    if #self.providers == 0 then
        vim.notify(
            "no 'providers' given. this plugin does not work with zero-config",
            vim.log.levels.WARN
        )
        return
    end
    if type(self.column_separator) ~= "string" then
        vim.notify(
            "'column_separator' must be a string, but got " .. type(self.column_separator),
            vim.log.levels.ERROR
        )
        return
    end
    if type(self.hooks) ~= "table" then
        vim.notify("'hooks' must be a table, but got " .. type(self.hooks), vim.log.levels.ERROR)
        return
    end

    if self.hooks.layout ~= nil and type(self.hooks.layout) ~= "function" then
        vim.notify(
            "'hooks.layout' must be a function, but got" .. type(self.hooks.layout),
            vim.log.levels.ERROR
        )
        return
    end
end

return Config
