--- @class fixme.Config
local Config = {}

--- @class fixme.CreateConfigParams
--- @field selectors? fixme.Selector[]
--- @field column_separator? string
--- @field cell_separator? string

--- @param params fixme.CreateConfigParams
--- @return fixme.Config
function Config:create(params)
    --- @type fixme.Config
    local this = {
        selectors = params.selectors or {},
        column_separator = params.column_separator or " ",
        cell_separator = params.cell_separator or " ",
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

return Config
