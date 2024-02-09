local M = {}

--- @param msg string
--- @return string
function M.prefix(msg)
    return string.format("[fixme.nvim]: %s", msg)
end

--- @param msg string
function M.warn(msg)
    vim.notify(M.prefix(msg), vim.log.levels.WARN)
end

--- @param msg string
function M.error(msg)
    vim.notify(M.prefix(msg), vim.log.levels.ERROR)
end

return M
