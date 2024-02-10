--- @class LineBuilder
--- @field components FixmeComponent[]
local LineBuilder = {}

--- @return LineBuilder
function LineBuilder:new()
    --- @type LineBuilder
    local this = {
        components = {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

--- @param component FixmeComponent
--- @return LineBuilder
function LineBuilder:add(component)
    table.insert(self.components, component)
    return self
end

--- @return string
function LineBuilder:to_string()
    --- @type string[]
    local texts = {}
    for _, components in ipairs(self.components) do
        table.insert(texts, components.text)
    end

    return vim.fn.join(texts, "")
end

--- @class HighlightDef
--- @field hl string
--- @field col_start number
--- @field col_end number

--- @return HighlightDef[]
function LineBuilder:get_hl()
    --- @type HighlightDef[]
    local defs = {}
    local col = 0

    for _, component in ipairs(self.components) do
        local next_col = col + #component.text

        if component.hl ~= nil then
            table.insert(defs, {
                hl = component.hl,
                col_start = col,
                col_end = next_col,
            })
        end
        col = next_col
    end

    return defs
end

return LineBuilder
