--- @class LineBuilder
--- @field buf_id number
--- @field components FixmeComponent[]
local LineBuilder = {}

--- @param buf_id number
--- @return LineBuilder
function LineBuilder:new(buf_id)
    --- @type LineBuilder
    local this = {
        buf_id = buf_id,
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
    local str = ""
    for _, components in ipairs(self.components) do
        str = str .. components.text
    end

    return str
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
        col = next_col
    end
end

return LineBuilder
