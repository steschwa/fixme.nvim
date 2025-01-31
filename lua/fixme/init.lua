local Formatter = require("fixme.formatter")

---@param opts fixme.Config
---@return fixme.Config
local function create_config(opts)
    opts = opts or {}

    ---@type fixme.Config
    local config = {
        cell_separator = opts.cell_separator or " ",
        column_separator = opts.column_separator or "|",
        columns = opts.columns or function()
            return {}
        end,
    }

    return config
end

---@class fixme.Instance
---@field config fixme.Config
local M = {}

---@class fixme.FormatParams
---@field id number

---@class fixme.GetQuickfixResult
---@field qfbufnr number
---@field items fixme.QuickfixItem[]

---@param params fixme.FormatParams
---@return string[]
function M.format(params)
    ---@type fixme.GetQuickfixResult
    local result = vim.fn.getqflist({
        id = params.id,
        items = true,
        qfbufnr = true,
    })

    local formatter = Formatter:create({
        columns = M.config.columns(params.id),
        items = result.items,
        cell_separator = M.config.cell_separator,
        column_separator = M.config.column_separator,
    })

    vim.schedule(function()
        formatter:apply_highlights(result.qfbufnr)
    end)

    return formatter:format_lines()
end

---@param opts fixme.Config
function M.setup(opts)
    M.config = create_config(opts)

    vim.o.quickfixtextfunc = "v:lua.require'fixme'.format"
end

return M
