local line_builder = require("fixme.line_builder")
local converter = require("fixme.converter")

local line_hl_ns = vim.api.nvim_create_namespace("fixme_qf")

--- @class FixmeImpl
--- @field providers FixmeComponentProvider[]
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
        local builder = line_builder:new(result.qfbufnr)

        for _, component in ipairs(M.providers) do
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

--- @param opts FixmeOptions
function M.setup(opts)
    opts = vim.tbl_deep_extend("force", {
        providers = {},
    }, opts or {})

    if #opts.providers == 0 then
        vim.notify_once(
            "you didn't pass any components to fixme.setup(). this plugin has no effect without components",
            vim.log.levels.WARN
        )
        return
    end

    M.providers = opts.providers

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
