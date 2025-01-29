local LineBuilder = require("fixme.line_builder")

---@class fixme.CreateLineBuildersParams
---@field columns fixme.Column[]
---@field items fixme.QuickfixItem[]
---@field column_separator string
---@field cell_separator string

---@param params fixme.CreateLineBuildersParams
---@return fixme.LineBuilder[]
local function create_line_builders(params)
    ---@type fixme.LineBuilder[]
    local line_builders = {}

    ---@type number[]
    local column_widths = {}

    for _, item in ipairs(params.items) do
        local line_builder = LineBuilder:new(params.cell_separator, params.column_separator)

        for i, column in ipairs(params.columns) do
            ---@type fixme.FormatResult[]
            local column_res = {}

            for _, cell_formatter in ipairs(column) do
                table.insert(column_res, cell_formatter(item))
            end

            local column_width = line_builder:set(column_res)

            column_widths[i] = math.max(column_widths[i] or 0, column_width)
        end

        table.insert(line_builders, line_builder)
    end

    for _, line_builder in ipairs(line_builders) do
        for i, column_width in ipairs(column_widths) do
            line_builder:apply_column_width(i, column_width)
        end
    end

    return line_builders
end

---@class fixme.Formatter
---@field line_builders fixme.LineBuilder[]
local Formatter = {}

---@class fixme.CreateFormatterParams
---@field columns fixme.Column[]
---@field items fixme.QuickfixItem[]
---@field column_separator string
---@field cell_separator string

---@param params fixme.CreateFormatterParams
---@return fixme.Formatter
function Formatter:create(params)
    local line_builders = create_line_builders({
        columns = params.columns,
        items = params.items,
        cell_separator = params.cell_separator,
        column_separator = params.column_separator,
    })

    local this = {
        line_builders = line_builders,
    }

    return setmetatable(this, {
        __index = self,
    })
end

---@return string[]
function Formatter:format_lines()
    ---@type string[]
    local lines = {}

    for _, line_builder in ipairs(self.line_builders) do
        table.insert(lines, line_builder:to_string())
    end

    return lines
end

local NS = vim.api.nvim_create_namespace("fixme_qf")

---@param buf_id number
function Formatter:apply_highlights(buf_id)
    if not vim.api.nvim_buf_is_valid(buf_id) then
        return
    end

    vim.api.nvim_buf_clear_namespace(buf_id, NS, 0, -1)

    for i, line_builder in ipairs(self.line_builders) do
        local line_index = i - 1
        local defs = line_builder:get_highlights()

        for _, def in ipairs(defs) do
            vim.highlight.range(
                buf_id,
                NS,
                def.hl,
                { line_index, def.col_start },
                { line_index, def.col_end }
            )
        end
    end
end

return Formatter
