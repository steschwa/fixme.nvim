local line_builder = require("fixme.line_builder")

--- @class Builder
--- @field config Config
--- @field items FixmeQFItem[]
local Builder = {}

--- @param config Config
--- @param items FixmeQFItem[]
function Builder:new(config, items)
    --- @type Builder
    local this = {
        config = config,
        items = items,
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

--- @return LineBuilder[]
function Builder:get_line_builders()
    --- @type LineBuilder[]
    local builders = {}

    for _, item in ipairs(self.items) do
        local builder = line_builder:new({
            column_separator = self.config.column_separator,
        })

        for _, provider in ipairs(self.config.providers) do
            builder:add(provider(item))
        end

        table.insert(builders, builder)
    end

    return builders
end

return Builder
