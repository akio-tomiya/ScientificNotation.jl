module ScientificNotation

export format_value_with_error

using Printf

function format_value_with_error_bare(value::Number, error::Number)
    if error < 0
        error = abs(error)
        @warn "Error should be positive. Converting error=$error to positive value."
    end
    if error < eps()
        throw(ArgumentError("Error is too small (error = $error)"))
    end
    error_magnitude = -floor(Int, log10(error))
    significant_digits = if rounded_error_first_digit(error) in [1, 2]
        error_magnitude
    else
        error_magnitude + 1
    end

    rounded_value = round(value, sigdigits=significant_digits)
    rounded_error = round(error, sigdigits=significant_digits)
    return rounded_value, rounded_error
end

function rounded_error_first_digit(error::Number)
    error_magnitude = -floor(Int, log10(error))
    significant_error = round(error * 10^error_magnitude)
    return Int(significant_error)
end

"""
    format_value_with_error(value::Number, error::Number)

Formats a given `value` and its associated `error` in scientific notation for easy reading.
The output format is:
- For `value` >= 1 or `value` < 1, with small error, the output is in standard notation: `value(error)`.
- For larger magnitude or small values, scientific notation is used: `value(error) × 10^{-magnitude}`.

#### Arguments
- `value::Number`: The main value to format.
- `error::Number`: The associated error to be formatted.

#### Returns
A `String` representing the formatted value and error.

#### Example
```julia
julia> format_value_with_error(-123.456, 0.789)
"-123(8)"

julia> format_value_with_error(1.23456, 0.01234)
"1.23(12)"

julia> format_value_with_error(0.123456, 0.001234)
"1.23(12) \\times 10^{-1}"
"""
function format_value_with_error(value::Number, error::Number)
    sgn = ifelse(value < 0, "-", "")
    value = abs(value)

    if abs(value) < eps()
        throw(ArgumentError("Value is too small (value = $value)"))
    end

    rounded_value, rounded_error = format_value_with_error_bare(value, error)

    if value >= 1
        return "$sgn$rounded_value($rounded_error)"
    else
        value_magnitude = -floor(Int, log10(value))
        normalized_value = rounded_value * 10^value_magnitude
        return "$sgn$normalized_value($rounded_error) \\times 10^{-$value_magnitude}"
    end
end

end
