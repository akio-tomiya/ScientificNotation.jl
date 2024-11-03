module ScientificNotation
export format_value_with_error
# Julia code to format a value with its error according to specified rules.
using Printf
# Helper function to convert 201.0 to 201
function final_decimal(x)
    if x == floor(x)
        return Int(x)
    else
        return x
    end
end

# Function to round the error to one significant digit
function round_error(error_value)
    return signif(error_value, 1)  # Round to one significant digit
end

function signif(error_value, n)
    exponent = floor(log10(error_value))
    dig = -Int(exponent)
    return round(error_value, digits = dig)
end

# Function to compute the decimal places based on the rounded error
function compute_decimal_places(rounded_error)
    exponent = floor(log10(rounded_error))
    return -Int(exponent)
end

# Function to round the center value to the appropriate decimal places
function round_center_value(center_value, decimal_places)
    if decimal_places <= 0
        return round(center_value)
    else
        return round(center_value, digits=decimal_places, RoundDown)
    end
end

# Function to extract the error digit for formatting
function extract_error_digit(rounded_error, decimal_places)
    return Int(round(rounded_error * 10.0^decimal_places))
end

# Main function to format the value with its error
function format_value_with_error(center_value, error_value)
    sgn = ""
    if center_value < 0
        sgn = "-"
    end
    center_value = abs(center_value)
    # Step 1: Round the error to one significant digit
    rounded_error = round_error(error_value)
    
    # Step 2: Compute decimal places
    decimal_places = compute_decimal_places(rounded_error)
    
    # Step 3: Round center value
    rounded_center = round_center_value(center_value, decimal_places)
    
    # Step 4: Extract error digit
    error_digit = extract_error_digit(rounded_error, decimal_places)
    
    # Step 5: Format the measurement and error
    rounded_center = final_decimal(rounded_center)
    
    # Format the measurement string
    measurement_str = @sprintf("%.*f", decimal_places, rounded_center)
    # Remove trailing zeros and decimal point if necessary
    measurement_str = replace(measurement_str, r"0+$"=>"")
    measurement_str = replace(measurement_str, r"\.$"=>"")
    
    # Check if integer part is zero for scientific notation
    if abs(rounded_center) != 0 && abs(rounded_center) < 1
        exponent_center = floor(log10(abs(rounded_center)))
        mantissa = rounded_center / 10.0^exponent_center
        mantissa_str = @sprintf("%.*f", decimal_places, mantissa)
        # Remove trailing zeros and decimal point if necessary
        mantissa_str = replace(mantissa_str, r"0+$"=>"")
        mantissa_str = replace(mantissa_str, r"\.$"=>"")
        formatted_str = mantissa_str * "($error_digit) \\times 10^{ $(Int(exponent_center)) }"
    else
        formatted_str = measurement_str * "($error_digit)"
    end
    
    return "$sgn"*formatted_str
end

# Test cases
#=
println(format_value_with_error(1.0733, 0.0631731))   # Expected: 1.07(6)
println(format_value_with_error(1.12072, 0.0649934))  # Expected: 1.12(6)
println(format_value_with_error(1.08849, 0.0665471))  # Expected: 1.08(7)
println(format_value_with_error(0.819554, 0.0608697)) # Expected: 8.19(6) × 10^{-1}
println(format_value_with_error(203.629, 5.48827))    # Expected: 204(5)
=#

# Write your package code here.
#=
using Printf

function final_decimal(x)
    if x == floor(x)
        return Int(x)
    else
        return x
    end
end
function format_value_with_error_bare(value::Number, error::Number; debug=false)
    if debug
        println("Input: $value $error")
    end
    if error < 0
        println("Warning! Error should be positive but error=$error")
    end
    error = abs(error)
    if error < eps()
        println("Warning! Error is too small (error = $error)")
        return value, error
    end
    error_magnitude = -floor(Int, log10(error))
    significant_digits = error_magnitude + 1
    rounded_value = round(value, digits=significant_digits)
    rounded_error = round(error, digits=significant_digits)
    return rounded_value, rounded_error
end

function format_value_with_error_naive(value::Number, error::Number; debug=false)
    if debug
        println("Input: $value $error")
    end
    rounded_value, rounded_error = format_value_with_error_bare(value, error)
    if error < eps()
        println("Warning! Error is too small (error = $error)")
        return value, error
    end
    error_magnitude = -floor(Int, log10(error))
    significant_digits = error_magnitude + 1
    rounded_error = rounded_error * 10^significant_digits
    rounded_error_int = round(Int, rounded_error)
    return rounded_value, rounded_error_int
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
function format_value_with_error(value::Number, error::Number; debug=false)
    if debug
        println("Input: $value $error")
    end
    sgn = ""
    if value < 0
        sgn = "-"
        value = abs(value)
    end
    rounded_value, int_rounded_error = format_value_with_error_naive(value, error)
    value_magnitude = -floor(Int, log10(value))
    if value_magnitude==0
        return "$sgn$rounded_value($int_rounded_error)"
    end
    if value_magnitude<0
        rounded_value_int = final_decimal(rounded_value) #round(Int, rounded_value)
        return "$sgn$rounded_value_int($int_rounded_error)"
    end
    rounded_value, int_rounded_error = format_value_with_error_naive(value, error)
    value_magnitude = -floor(Int, log10(value))
    scaled_value = rounded_value*10^(value_magnitude)
    return "$sgn$scaled_value($int_rounded_error)\\times10^{-$value_magnitude}"
    #return string(sgn, @sprintf("%.*f", significant_digits - 1, rounded_value), "(", int_rounded_error, ") \\times 10^{", -value_magnitude, "}")
    #=
    if abs(value) < eps()
        println("Warning! value is too small (value = $value)")
        return "$value($error)"
    end
    value_magnitude = -floor(Int, log10(value))
    significant_digits = value_magnitude+floor(Int, log10(error)) + 2  # 誤差の有効桁数に基づく丸め桁数
    #println("significant_digits $significant_digits $(typeof(significant_digits))")
    significant_digits = max(2,significant_digits)
    #println("significant_digits $significant_digits $(typeof(significant_digits))")

    # フォーマット文字列を動的に構築
    if value_magnitude <= 0
        if value_magnitude <= -1
            rounded_value_int = round(Int, rounded_value)
            return string(sgn, rounded_value_int, "(", int_rounded_error, ")")
        end
        return string(sgn, @sprintf("%.*f", significant_digits - 1, rounded_value), "(", int_rounded_error, ")")
    else
        rounded_value = rounded_value * 10^value_magnitude
        return string(sgn, @sprintf("%.*f", significant_digits - 1, rounded_value), "(", int_rounded_error, ") \\times 10^{", -value_magnitude, "}")
    end
    =#
end
=#

end
