local Config = require("fixme.config")
local Converter = require("fixme.converter")
local Manager = require("fixme.manager")

--- @class FixmeImpl
--- @field config Config
local M = {}

--- @param params QFFormatParams
--- @return string[]
function M.format(params)
    --- @type GetQFResult
    local result = vim.fn.getqflist({
        id = params.id,
        items = true,
        qfbufnr = true,
    })

    local manager = Manager:new(M.config)
    if not manager:init_selector(params.id) then
        return {}
    end

    manager:set_items(Converter.convert_items(result.items))

    local lines = manager:format()

    vim.schedule(function()
        manager:apply_highlights(result.qfbufnr)
    end)

    return lines
end

--- @param params CreateConfigParams
function M.setup(params)
    local config = Config:create(params)

    M.config = config

    vim.o.quickfixtextfunc = "v:lua.require'fixme'.format"

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("reset_syntax_qf", {
            clear = true,
        }),
        pattern = { "qf" },
        command = "syntax clear",
    })
end

return M
