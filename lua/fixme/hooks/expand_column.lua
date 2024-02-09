local Logger = require("fixme.utils.logging")

--- @param params ExpandColumnHookParams 
--- @return boolean
local function validate_params(params)
    if type(params.column) ~= "number" then
        Logger.warn("'column' must be a number, but got" .. type(params.column))
        return false
    end
    if params.column <= 0 then
        Logger.warn("'column' must be greater-equal 1, but got ".. params.column)
        return false
    end
    if type(params.spacing_char) ~= "string" then
        Logger.warn("'spacing_char' must be a string, but got" .. type(params.spacing_char))
        return false
    end
    if #params.spacing_char ~= 1 then
        Logger.warn("'spacing_char' must have a width of exactly 1 to work")
        return false
    end

    return true
end

--- @param params ExpandColumnHookParams 
return function(params)
    params = params or {}
    params.spacing_char = params.spacing_char or " "

    if not validate_params(params) then
        return
    end

    --- @param line_builders LineBuilder[]
    return function(line_builders)
        local col_width = 0

        for _, line_builder in ipairs(line_builders) do
            local component = line_builder.components[params.column]
            if component == nil then
                goto continue
            end

            col_width = math.max(col_width, #component.text)

            ::continue::
        end

        for _, line_builder in ipairs(line_builders) do
            local component = line_builder.components[params.column]
            if component == nil then
                goto continue
            end

            local padding = col_width - #component.text
            if padding <= 0 then
                goto continue
            end

            local spacing = string.rep(params.spacing_char, padding)
            component.text = component.text .. spacing

            ::continue::
        end
    end
end

--- @class ExpandColumnHookParams
--- @field column number column index (one-based) that should have the same width
--- @field spacing_char? string
