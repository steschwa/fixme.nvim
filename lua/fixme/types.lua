--- @meta

--- @class FixmeOptions
--- @field providers FixmeComponentProvider[]

--- @class FixmeComponent
--- @field text string
--- @field hl string?

--- @alias FixmeComponentProvider fun(item: QFItem): FixmeComponent

--- @class QFFormatParams
--- @field id number

--- @class QFItem
--- @field bufnr number
--- @field lnum number
--- @field end_lnum number
--- @field col number
--- @field end_col number
--- @field text string
--- @field type string
--- @field valid number

--- @class GetQFResult
--- @field qfbufnr number
--- @field items QFItem[]
