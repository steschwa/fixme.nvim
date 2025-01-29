local LineBuilder = require("fixme.line_builder")

---@class fixme.Manager
---@field config fixme.Config
---@field selector? fixme.Selector
---@field line_builders fixme.LineBuilder[]
local Manager = {}

---@param config fixme.Config
---@return fixme.Manager
function Manager:new(config)
    ---@type fixme.Manager
    local this = {
        config = config,
        selector = nil,
        line_builders = {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

---@param qf_id number
---@return boolean
function Manager:init_selector(qf_id)
    for _, selector in ipairs(self.config.selectors) do
        if selector.use == nil then
            self.selector = selector
            return true
        end

        local ok, should_use = pcall(selector.use, qf_id)
        if ok and should_use then
            self.selector = selector
            return true
        end
    end

    return false
end

---@param items fixme.QuickfixItem[]
function Manager:set_items(items)
    if self.selector == nil then
        return
    end

    ---@type fixme.LineBuilder[]
    local line_builders = {}

    ---@type number[]
    local column_widths = {}

    for _, item in ipairs(items) do
        local line_builder =
            LineBuilder:new(self.config.cell_separator, self.config.column_separator)

        for i, column in ipairs(self.selector.columns) do
            ---@type fixme.FormatResult[]
            local column_res = {}

            for _, cell_formatter in ipairs(column) do
                table.insert(column_res, cell_formatter(item))
            end

            local column_width = line_builder:add(column_res)

            column_widths[i] = math.max(column_widths[i] or 0, column_width)
        end

        table.insert(line_builders, line_builder)
    end

    for _, line_builder in ipairs(line_builders) do
        for i, column_width in ipairs(column_widths) do
            line_builder:apply_column_width(i, column_width)
        end
    end

    self.line_builders = line_builders
end

---@return string[]
function Manager:format()
    ---@type string[]
    local lines = {}

    for _, line_builder in ipairs(self.line_builders) do
        table.insert(lines, line_builder:to_string())
    end

    return lines
end

---@param buf_id number
function Manager:apply_highlights(buf_id)
    if not vim.api.nvim_buf_is_valid(buf_id) then
        return
    end

    local namespace = vim.api.nvim_create_namespace("fixme_qf")
    vim.api.nvim_buf_clear_namespace(buf_id, namespace, 0, -1)

    for i, line_builder in ipairs(self.line_builders) do
        local line_index = i - 1
        local defs = line_builder:get_highlights()
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
