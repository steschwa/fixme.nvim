--- @meta

--- @class FixmeComponent
--- @field text string
--- @field hl string?

--- @alias FixmeComponentProvider fun(item: FixmeQFItem): FixmeComponent

--- @class FixmeQFItem
--- @field line_start number
--- @field line_end number
--- @field col_start number
--- @field col_end number
--- @field type string
--- @field text string
--- @field filepath string
--- @field bufnr number

--- @alias FixmeHook fun(line_builders: LineBuilder[])

--- @class FixmeSelector
--- @field providers FixmeComponentProvider[]
--- @field use? fun(qf_id: number): boolean
--- @field hooks? FixmeHook[]

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
