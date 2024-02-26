local LineBuilder = require("fixme.line_builder")

--- @class Manager
--- @field config Config
--- @field selector? FixmeSelector
--- @field line_builders LineBuilder[]
local Manager = {}

--- @param config Config
--- @return Manager
function Manager:new(config)
    --- @type Manager
    local this = {
        config = config,
        selector = nil,
        line_builders = {},
    }
    setmetatable(this, self)
    self.__index = self

    return this
end

--- @param qf_id number
--- @return boolean
function Manager:init_selector(qf_id)
    for _, selector in ipairs(self.config.selectors) do
        if selector.use == nil then
            self.selector = selector
            return true
        end

        local ok, should_use = pcall(selector.use, qf_id)
        if ok and should_use then
            self.selector = selector
            return true
        end
    end

    return false
end

--- @param items FixmeQFItem[]
function Manager:set_items(items)
    if self.selector == nil then
        return
    end

    --- @type LineBuilder[]
    local line_builders = {}

    for _, item in ipairs(items) do
        local line_builder = LineBuilder:new()

        for _, provider in ipairs(self.selector.providers) do
            line_builder:add(provider(item))
        end

        table.insert(line_builders, line_builder)
    end

    self.line_builders = line_builders

    self:_apply_layout()
end

function Manager:_apply_layout()
    if self.selector == nil then
        return
    end
    if self.selector.layout == nil then
        return
    end

    self.selector.layout(self.line_builders)
end

--- @return string[]
function Manager:format()
    --- @type string[]
    local lines = {}

    for _, line_builder in ipairs(self.line_builders) do
        table.insert(lines, line_builder:to_string())
    end

    return lines
end

--- @param buf_id number
function Manager:apply_highlights(buf_id)
    if not vim.api.nvim_buf_is_valid(buf_id) then
        return
    end

    local namespace = vim.api.nvim_create_namespace("fixme_qf")
    vim.api.nvim_buf_clear_namespace(buf_id, namespace, 0, -1)

    for i, line_builder in ipairs(self.line_builders) do
        local line_index = i - 1
        local defs = line_builder:get_hl()
        for _, def in ipairs(defs) do
            vim.highlight.range(
                buf_id,
                namespace,
                def.hl,
                { line_index, def.col_start },
                { line_index, def.col_end }
            )
        end
    end
end

return Manager
