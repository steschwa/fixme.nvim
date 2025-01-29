---@class fixme.Config
---@field selectors fixme.Selector[]
---@field column_separator string
---@field cell_separator string

---@class fixme.Selector
---@field columns fixme.Column[]
---@field use? fun(qf_id: number): boolean

---@alias fixme.Column fixme.CellFormatter[]

---@alias fixme.CellFormatter fun(qf_item: fixme.QuickfixItem): fixme.FormatResult

---@class fixme.FormatResult
---@field text string
---@field hl string?

---@class fixme.QuickfixItem
---@field bufnr number
---@field lnum number
---@field end_lnum number
---@field col number
---@field end_col number
---@field text string
---@field type string
---@field valid number
