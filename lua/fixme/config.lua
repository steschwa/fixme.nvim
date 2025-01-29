---@class fixme.Config
---@field selectors fixme.Selector[]
---@field column_separator string
---@field cell_separator string
local Config = {}

---@class fixme.CreateConfigParams
---@field selectors? fixme.Selector[]
---@field column_separator? string
---@field cell_separator? string

---@param params fixme.CreateConfigParams
---@return fixme.Config
function Config.create(params)
    local this = {
        selectors = params.selectors or {},
        column_separator = params.column_separator or " ",
        cell_separator = params.cell_separator or " ",
    }
    setmetatable(this, { __index = Config })

    return this
end

return Config
