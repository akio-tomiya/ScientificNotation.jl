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
    if rounded_error<10
    measurement_str = replace(measurement_str, r"0+$"=>"")
    measurement_str = replace(measurement_str, r"\.$"=>"")
    end
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

end
