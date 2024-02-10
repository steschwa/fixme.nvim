--- @class Config
--- @field selectors FixmeSelector[]
--- @field column_separator string
--- @field hooks FixmeHook[]
local Config = {}

--- @class CreateConfigParams
--- @field selectors? FixmeSelector[]
--- @field column_separator? string
--- @field hooks? FixmeHook[]

--- @param params CreateConfigParams
--- @return Config
function Config:create(params)
    --- @type Config
    local this = {
        selectors = params.selectors or {},
        column_separator = params.column_separator or " ",
        hooks = params.hooks or {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

return Config
