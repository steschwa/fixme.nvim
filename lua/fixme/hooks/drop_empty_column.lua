local Logger = require("fixme.utils.logging")

--- @param params DropEmptyColumnHookParams
--- @return boolean
local function validate_params(params)
    if type(params.column) ~= "number" then
        Logger.warn("'column' must be a number, but got" .. type(params.column))
        return false
    end
    if params.column <= 0 then
        Logger.warn("'column' must be greater-equal 1, but got " .. params.column)
        return false
    end

    return true
end

--- @param params DropEmptyColumnHookParams
return function(params)
    params = params or {}

    if not validate_params(params) then
        return
    end

    --- @param line_builders LineBuilder[]
    return function(line_builders)
        for _, line_builder in ipairs(line_builders) do
            local component = line_builder.components[params.column]
            if component == nil then
                goto continue
            end

            local text = vim.trim(component.text)
            if #text > 0 then
                return
            end

            ::continue::
        end

        for _, line_builder in ipairs(line_builders) do
            table.remove(line_builder.components, params.column)
        end
    end
end

--- @class DropEmptyColumnHookParams
--- @field column number column index (one-based) that should be dropped if empty
