local Formatter = require("fixme.formatter")

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

    local formatter = Formatter:new(M.config)
    if not formatter:init_selector(params.id) then
        return {}
    end

    formatter:set_items(result.items)

    vim.schedule(function()
        formatter:apply_highlights(result.qfbufnr)
    end)

    return formatter:format_lines()
end

---@param opts fixme.Config
function M.setup(opts)
    M.config = opts

    vim.o.quickfixtextfunc = "v:lua.require'fixme'.format"
end

return M
