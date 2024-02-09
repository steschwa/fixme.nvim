local line_builder = require("fixme.line_builder")
local converter = require("fixme.converter")
local config = require("fixme.config")

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

    local items = converter.convert_items(result.items)

    --- @type LineBuilder[]
    local builders = {}
    for _, item in ipairs(items) do
        local builder = line_builder:new({
            buf_id = result.qfbufnr,
            separator = M.config.column_separator,
        })

        for _, component in ipairs(M.config.providers) do
            builder:add(component(item))
        end

        table.insert(builders, builder)
    end

    --- @type string[]
    local lines = {}
    for _, builder in ipairs(builders) do
        table.insert(lines, builder:to_string())
    end

    vim.schedule(function()
        for i, builder in ipairs(builders) do
            builder:apply_highlights(i - 1, line_hl_ns)
        end
    end)

    return lines
end

--- @param params CreateConfigParams
function M.setup(params)
    local c = config:create(params)
    c:validate()

    M.config = c

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
