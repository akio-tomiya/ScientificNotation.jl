# ScientificNotation

This is a package to make values and error in the scientific notation.

**This package is a developping package, and 
if you want to use this, please becareful.
There some known bugs.**

# Install and usage
```julia
import Pkg;Pkg.add(path="https://github.com/akio-tomiya/ScientificNotation.jl")
```
and
```julia
using ScientificNotation
```

# Examples

Here are some examples of how to use the package to format values with their associated errors:

```julia
julia> using ScientificNotation

julia> format_value_with_error(0.9123, 0.001)
"9.12(1) \\times 10^{ -1 }"

julia> format_value_with_error(20100, 100)
"201(1)"

julia> format_value_with_error(-0.05678, 0.00012)
"-5.67(1) \\times 10^{ -2 }"

julia> format_value_with_error(123.456, 1.234)
"123(1)"

julia> format_value_with_error(0.000912, 0.000002)
"9.12(2) \\times 10^{ -4 }"
```

# Features

- **Scientific Notation**: Automatically formats values and errors based on the order of magnitude.
- **Sign Handling**: Supports both positive and negative values.
- **Magnitude Formatting**: Adds appropriate powers of 10 notation for readability in cases with very large or small numbers.

# Contributing

Feel free to contribute to this package by opening issues or submitting pull requests. 
Any improvements for handling edge cases or additional features are welcome!
