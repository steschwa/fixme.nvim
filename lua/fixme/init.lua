local Config = require("fixme.config")
local Manager = require("fixme.manager")

--- @class fixme.Impl
--- @field config fixme.Config
local M = {}

--- @class fixme.FormatParams
--- @field id number

--- @class fixme.GetQuickfixResult
--- @field qfbufnr number
--- @field items fixme.QuickfixItem[]

--- @param params fixme.FormatParams
--- @return string[]
function M.format(params)
    --- @type fixme.GetQuickfixResult
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

--- @param qf_id number
--- @return fixme.Selector | nil
function M.find_selector(qf_id)
    for _, selector in ipairs(M.config.selectors) do
        if selector.use == nil then
            return selector
        end

        local ok, should_use = pcall(selector.use, qf_id)
        if ok and should_use then
            return selector
        end
    end
end

--- @param params fixme.CreateConfigParams
function M.setup(params)
    local config = Config:create(params)

    M.config = config

    vim.o.quickfixtextfunc = "v:lua.require'fixme'.format"
end

return M
