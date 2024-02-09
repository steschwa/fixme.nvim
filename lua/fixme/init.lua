local LineBuilder = require("fixme.line_builder")
local Converter = require("fixme.converter")
local Config = require("fixme.config")

local line_hl_ns = vim.api.nvim_create_namespace("fixme_qf")

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

    vim.api.nvim_buf_clear_namespace(result.qfbufnr, line_hl_ns, 0, -1)

    local items = Converter.convert_items(result.items)

    --- @type LineBuilder[]
    local line_builders = {}
    for _, item in ipairs(items) do
        local line_builder = LineBuilder:new({
            column_separator = M.config.column_separator,
        })

        for _, provider in ipairs(M.config.providers) do
            line_builder:add(provider(item))
        end

        table.insert(line_builders, line_builder)
    end

    if M.config.hooks.layout ~= nil then
        M.config.hooks.layout(line_builders)
    end

    --- @type string[]
    local lines = {}
    for _, line_builder in ipairs(line_builders) do
        table.insert(lines, line_builder:to_string())
    end

    vim.schedule(function()
        for i, line_builder in ipairs(line_builders) do
            line_builder:apply_highlights(result.qfbufnr, i - 1, line_hl_ns)
        end
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
