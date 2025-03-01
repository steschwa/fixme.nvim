local CELL_SEPARATOR_HL = "FixmeCellSeparator"
local COLUMN_SEPARATOR_HL = "FixmeColumnSeparator"

---@class fixme.LineBuilder
---@field cell_separator string
---@field column_separator string
---@field columns fixme.FormatResult[][]
---@field column_widths number[] width of the columns in `LineBuilder.columns`. we store it as a variable to be independent of spacers that may get inserted with `LineBuilder.apply_column_width`
local LineBuilder = {}

---@param cell_separator string
---@param column_separator string
---@return fixme.LineBuilder
function LineBuilder:new(cell_separator, column_separator)
    local this = {
        cell_separator = cell_separator,
        column_separator = column_separator,
        columns = {},
        column_widths = {},
    }

    return setmetatable(this, {
        __index = self,
    })
end

---@param column fixme.FormatResult[]
---@return number column width
function LineBuilder:set(column)
    table.insert(self.columns, column)

    local width = 0
    for _, res in ipairs(column) do
        width = width + vim.api.nvim_strwidth(res.text)
    end

    table.insert(self.column_widths, width)

    return width
end

---@param column_idx number (1-based)
---@param column_width number
function LineBuilder:apply_column_width(column_idx, column_width)
    if column_idx > #self.column_widths then
        return
    end

    local spacer_width = column_width - self.column_widths[column_idx]
    if spacer_width <= 0 then
        return
    end

    local last_cell_index = #self.columns[column_idx]

    local original_text = self.columns[column_idx][last_cell_index].text
    self.columns[column_idx][last_cell_index].text = original_text .. string.rep(" ", spacer_width)
end

---@return fixme.FormatResult[]
function LineBuilder:flatten()
    ---@type fixme.FormatResult[]
    local out = {}

    for i, column in ipairs(self.columns) do
        for j, res in ipairs(column) do
            table.insert(out, res)

            if j >= 1 and j < #column then
                ---@type fixme.FormatResult
                local separator = {
                    text = self.cell_separator,
                    hl = CELL_SEPARATOR_HL,
                }
                table.insert(out, separator)
            end
        end

        if i >= 1 and i < #self.columns then
            ---@type fixme.FormatResult
            local separator = {
                text = self.column_separator,
                hl = COLUMN_SEPARATOR_HL,
            }
            table.insert(out, separator)
        end
    end

    return out
end

---@class fixme.HighlightDef
---@field hl string
---@field col_start number (0-based, bytes)
---@field col_end number (0-based, bytes)

---@return fixme.HighlightDef[]
function LineBuilder:get_highlights()
    ---@type fixme.HighlightDef[]
    local hl = {}
    local col = 0

    for _, res in ipairs(self:flatten()) do
        local col_start = col

        -- NOTE: `string.len(res.text)` (or #res.text) calculates the string width in bytes
        local col_end = col_start + string.len(res.text)

        col = col_end

        if res.hl ~= nil then
            ---@type fixme.HighlightDef
            local def = {
                hl = res.hl,
                col_start = col_start,
                col_end = col_end,
            }
            table.insert(hl, def)
        end
    end

    return hl
end

---@return string
function LineBuilder:to_string()
    local text = ""

    for _, res in ipairs(self:flatten()) do
        text = text .. res.text
    end

    return text
end

return LineBuilder
