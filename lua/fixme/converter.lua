local M = {}

--- @param item QFItem
--- @return FixmeQFItem
function M.convert_item(item)
    local path = vim.fn.bufname(item.bufnr)

    --- @type FixmeQFItem
    local ret = {
        line_start = item.lnum,
        line_end = item.end_lnum,
        col_start = item.col,
        col_end = item.end_col,
        type = item.type,
        text = item.text,
        filepath = path,
        bufnr = item.bufnr,
    }
    return ret
end

--- @param items QFItem[]
--- @return FixmeQFItem[]
function M.convert_items(items)
    --- @type FixmeQFItem[]
    local ret = {}
    for _, item in ipairs(items) do
        table.insert(ret, M.convert_item(item))
    end

    return ret
end

return M
