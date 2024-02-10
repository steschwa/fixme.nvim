--- @class LineBuilder
--- @field column_separator string
--- @field components FixmeComponent[]
local LineBuilder = {}

--- @class NewLineBuilderParams
--- @field column_separator? string

--- @param params NewLineBuilderParams
--- @return LineBuilder
function LineBuilder:new(params)
    --- @type LineBuilder
    local this = {
        column_separator = params.column_separator or "",
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

    return vim.fn.join(texts, self.column_separator)
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
        col = next_col + #self.column_separator
    end

    return defs
end

--- @param buf_id number
--- @param line_index number zero based line index
--- @param ns number
function LineBuilder:apply_highlights(buf_id, line_index, ns)
    local col = 0

    for _, component in ipairs(self.components) do
        local next_col = col + #component.text

        if component.hl ~= nil then
            vim.highlight.range(
                buf_id,
                ns,
                component.hl,
                { line_index, col },
                { line_index, next_col }
            )
        end
        col = next_col + #self.column_separator
    end
end

return LineBuilder
