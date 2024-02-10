--- @class Config
--- @field selectors FixmeSelector[]
local Config = {}

--- @class CreateConfigParams
--- @field selectors? FixmeSelector[]

--- @param params CreateConfigParams
--- @return Config
function Config:create(params)
    --- @type Config
    local this = {
        selectors = params.selectors or {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

return Config
