--- @param params ColumnSameWidthHookParams 
--- @return boolean
local function validate_params(params)
    if type(params.columns) ~= "table" then
        vim.notify(
            "'columns' must be a table, but got" .. type(params.columns),
            vim.log.levels.WARN
        )
        return false
    end
    if #params.columns == 0 then
        vim.notify(
            "no columns given. this hook requires atleast one column index to have an effect",
            vim.log.levels.WARN
        )
        return false
    end
    if type(params.spacing_char) ~= "string" then
        vim.notify(
            "'spacing_char' must be a string, but got" .. type(params.spacing_char),
            vim.log.levels.WARN
        )
        return false
    end
    if #params.spacing_char ~= 1 then
        vim.notify(
            "'spacing_char' must have a width of exactly 1 to work",
            vim.log.levels.WARN
        )
        return  false
    end

    return true
end

--- @param params ColumnSameWidthHookParams 
return function(params)
    params = params or {}
    params.spacing_char = params.spacing_char or " "

    if not validate_params(params) then
        return
    end

    --- @param line_builders LineBuilder[]
    return function(line_builders)
        --- @type number[]
        local column_widths = {}

        for _, line_builder in ipairs(line_builders) do
            for i, component in ipairs(line_builder.components) do
                local current_max = column_widths[i] or 0
                column_widths[i] = math.max(current_max, #component.text)
            end
        end

        for _, line_builder in ipairs(line_builders) do
            for i, component in ipairs(line_builder.components) do
                if not vim.tbl_contains(params.columns, i) then
                    goto continue
                end

                local padding = column_widths[i] - #component.text
                if padding <= 0 then
                    goto continue
                end

                local spacing = string.rep(params.spacing_char, padding)
                component.text = component.text .. spacing

                ::continue::
            end
        end
    end
end

--- @class ColumnSameWidthHookParams
--- @field columns number[] list of column indices (one-based: 1, 2, 3, ...) that should have the same width
--- @field spacing_char? string
