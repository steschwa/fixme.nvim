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
        column_separator = params.column_separator or "  ",
        hooks = params.hooks or {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

function Config:validate()
    if #self.providers == 0 then
        vim.notify(
            "you didn't pass any components to fixme.setup(). this plugin has no effect without components",
            vim.log.levels.WARN
        )
    end
end

return Config
