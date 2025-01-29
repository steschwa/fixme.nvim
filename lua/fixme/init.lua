local Config = require("fixme.config")
local Manager = require("fixme.manager")

---@class fixme.Impl
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

    local manager = Manager:new(M.config)
    if not manager:init_selector(params.id) then
        return {}
    end

    manager:set_items(result.items)

    local lines = manager:format()

    vim.schedule(function()
        manager:apply_highlights(result.qfbufnr)
    end)

    return lines
end

---@param params fixme.CreateConfigParams
function M.setup(params)
    M.config = Config.create(params)

    vim.o.quickfixtextfunc = "v:lua.require'fixme'.format"
end

return M
