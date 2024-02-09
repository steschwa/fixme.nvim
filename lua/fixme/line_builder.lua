--- @class LineBuilder
--- @field buf_id number
--- @field separator string
--- @field components FixmeComponent[]
local LineBuilder = {}

--- @class NewLineBuilderParams
--- @field buf_id number
--- @field separator? string

--- @param params NewLineBuilderParams
--- @return LineBuilder
function LineBuilder:new(params)
    --- @type LineBuilder
    local this = {
        buf_id = params.buf_id,
        separator = params.separator or "",
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

    return vim.fn.join(texts, self.separator)
end

--- @param line_index number
--- @param ns number
function LineBuilder:apply_highlights(line_index, ns)
    local col = 0

    for _, component in ipairs(self.components) do
        local next_col = col + #component.text

        if component.hl ~= nil then
            vim.highlight.range(
                self.buf_id,
                ns,
                component.hl,
                { line_index, col },
                { line_index, next_col }
            )
        end
        col = next_col + #self.separator
    end
end

return LineBuilder
