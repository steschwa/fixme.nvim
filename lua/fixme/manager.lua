local LineBuilder = require("fixme.line_builder")

--- @class Manager
--- @field config Config
--- @field line_builders LineBuilder[]
local Manager = {}

--- @param config Config
--- @return Manager
function Manager:new(config)
    --- @type Manager
    local this = {
        config = config,
        line_builders = {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

--- @param items FixmeQFItem[]
function Manager:set_items(items)
    --- @type LineBuilder[]
    local line_builders = {}

    for _, item in ipairs(items) do
        local line_builder = LineBuilder:new({
            column_separator = self.config.column_separator,
        })

        for _, provider in ipairs(self.config.providers) do
            line_builder:add(provider(item))
        end

        table.insert(line_builders, line_builder)
    end

    self.line_builders = line_builders

    self:_apply_hooks()
end

function Manager:_apply_hooks()
    for _, hook in ipairs(self.config.hooks) do
        hook(self.line_builders)
    end
end

--- @return string[]
function Manager:get_lines()
    --- @type string[]
    local lines = {}

    for _, line_builder in ipairs(self.line_builders) do
        table.insert(lines, line_builder:to_string())
    end

    return lines
end

--- @param buf_id number
function Manager:apply_highlights(buf_id)
    if not vim.api.nvim_buf_is_valid(buf_id) then
        return
    end

    local namespace = vim.api.nvim_create_namespace("fixme_qf")
    vim.api.nvim_buf_clear_namespace(buf_id, namespace, 0, -1)

    for i, line_builder in ipairs(self.line_builders) do
        local line_index = i - 1
        local defs = line_builder:get_hl()
        for _, def in ipairs(defs) do
            vim.highlight.range(
                buf_id,
                namespace,
                def.hl,
                { line_index, def.col_start },
                { line_index, def.col_end }
            )
        end
    end
end

return Manager
