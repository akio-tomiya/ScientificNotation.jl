module ScientificNotation

# Write your package code here.
export format_value_with_error

function format_value_with_error_bare(value::Number, error::Number)
    if error < 0
        println("Warning! Error should be positive but error=$error")
    end
    error = abs(error)
    if error< eps()
        println("Warning! Error is too small (error = $error)")
        return value,error
    end
    error_magnitude = -floor(Int, log10(error))
    significant_digits = error_magnitude+1
    rounded_value = round(value, digits=significant_digits)
    rounded_error = round(error, digits=significant_digits)
    return rounded_value,rounded_error
end
function format_value_with_error_naive(value::Number, error::Number)
    rounded_value, rounded_error = format_value_with_error_bare(value, error)
    if error<eps()
        println("Warning! Error is too small (error = $error)")
        return value,error
    end
    error_magnitude = -floor(Int, log10(error))
    significant_digits = error_magnitude+1
    rounded_error=rounded_error*10^(significant_digits)
    rounded_error_int = round(Int,rounded_error)
    return rounded_value,rounded_error_int
end

"""
    format_value_with_error(value::Number, error::Number)

Formats a given `value` and its associated `error` in scientific notation for easy reading.
The format is chosen based on the order of magnitude of the `value` and `error`, with a convention that
if the leading digit of the error is `1` or `2`, it is rounded to one significant digit; otherwise, it is rounded
to two significant digits. The output is structured as follows:

- If the magnitude of `value` is negative or zero, the output is returned in standard notation with parentheses for the error:
  `value(error)`.
- If the magnitude of `value` is positive, scientific notation is used, formatted as:
  `value(error) × 10^{-magnitude}`.

#### Arguments
- `value::Number`: The main value to format.
- `error::Number`: The associated error to be formatted alongside `value`.

#### Returns
A `String` representing the formatted value and error.

#### Example
```julia
julia> format_value_with_error(-123.456, 0.789)
"-123(8)"

julia> format_value_with_error(1.23456, 0.01234)
"1.23(12)"

julia> format_value_with_error(0.123456, 0.001234)
"1.23(12)\\times 10^{-1}"
"""
function format_value_with_error(value::Number, error::Number)
    sgn = ""
    if value<0
        sgn = "-"
        value = -value
    end
    rounded_value, int_rounded_error = format_value_with_error_naive(value, error)
    if abs(value)< eps()
        println("Warning! value is too small (value = $value)")
        return "$value$error"
    end
    value_magnitude = -floor(Int, log10(value))
    if value_magnitude<=0
        if value_magnitude<=-1
            rounded_value_int=round(Int,rounded_value)
            return "$sgn$rounded_value_int($int_rounded_error)"
        end
        return "$sgn$rounded_value($int_rounded_error)"
    end
    rounded_value=rounded_value*10^(value_magnitude)
    return "$sgn$rounded_value($int_rounded_error) \\times 10^{-$value_magnitude}"
end

end
