# PS2 Standard: Complete the four functions below.
# Keep the function names, arguments, return types, and docstrings.
# The checker supplies valid inputs. You do not need to add input checks.
# Save your code, then run from the PS2 folder:
# julia --project=. --startup-file=no check_submission.jl
# This command runs the tests, calls your functions with the supplied data,
# and prints the financial report. No separate report call is needed.

"""
    estimate_lattice(prices::Vector{Float64}, dt::Float64) -> NamedTuple

Estimate the two daily price factors and the probability of an up move.

### Arguments

- `prices`: Daily prices in USD/share, ordered from oldest to newest. The
  supplied prices are positive and include both increases and decreases.
- `dt`: Time between observations in trading years; daily data use `1/252`.

### Returns

A named tuple `(u=u, d=d, p=p)` with three unitless entries:

- `u`: Average price factor on days when the price rises.
- `d`: Average price factor on days when the price falls.
- `p`: Fraction of daily price changes that are positive.

A price factor is the new price divided by the previous price.

### Method

Store the result of `log_growth_matrix(prices; Δt=dt, risk_free_rate=0.0)`
in `growth`. Then call
`(RealWorldBinomialProbabilityMeasure())(growth; Δt=dt)` to get `(u, d, p)`.

The growth rates are expressed per trading year. Apply the benchmark only
when computing NPV.

Include zero changes in the total number of changes used to compute `p`.
Exclude zero changes when computing `u` and `d`.
"""
function estimate_lattice(prices::Vector{Float64}, dt::Float64)::NamedTuple
    # TODO 1: Use log_growth_matrix with Δt=dt and risk_free_rate=0.0 to get growth.
    # TODO 2: Call RealWorldBinomialProbabilityMeasure as shown in the docstring.
    # TODO 3: Return the three estimates as (u=u, d=d, p=p).
    error("Complete estimate_lattice in your selected source file.");
end

"""
    build_lattice(parameters::NamedTuple, initial_price::Float64, days::Int)
        -> MyBinomialEquityPriceTree

Build a lattice of prices and probabilities from the purchase day through the sale day.

### Arguments

- `parameters`: The unitless entries `u`, `d`, and `p` from `estimate_lattice`.
- `initial_price`: Purchase price in USD/share.
- `days`: Positive whole number of trading days from purchase to sale.

### Returns

A `MyBinomialEquityPriceTree` with one step per trading day. Day 0 has one
purchase node; day `days` has `days + 1` possible sale prices. Each node stores
a `price` in USD/share and the total `probability` of all paths reaching it.

### Method

Set `model = build(MyBinomialEquityPriceTree, parameters)`, then call
`populate(model; Sₒ=initial_price, h=days)`. Return the completed model.
The keyword `Sₒ` ends with a subscript letter o; copy it if needed.

Read node numbers from `model.levels[day]` and each node's values from
`model.data[node_number]`.
"""
function build_lattice(parameters::NamedTuple, initial_price::Float64,
    days::Int)::MyBinomialEquityPriceTree
    # TODO 4: Create the model with build(MyBinomialEquityPriceTree, parameters).
    # TODO 5: Use populate to add prices and probabilities through the sale day.
    # Set Sₒ=initial_price and h=days, then return the completed model.
    error("Complete build_lattice in your selected source file.");
end

"""
    lattice_probability(model::MyBinomialEquityPriceTree, days::Int,
        benchmark::Float64, dt::Float64) -> Float64

Calculate the probability of beating the benchmark on the scheduled sale day.

### Arguments

- `model`: A lattice containing the prices and probabilities through day `days`.
- `days`: Positive whole number of trading days from purchase to sale.
- `benchmark`: Continuously compounded rate; `0.05` means 5% per trading year.
- `dt`: Length of one trading day, measured in trading years.

### Returns

The sum of the probabilities of sale-day nodes with scaled NPV strictly
above zero. Return `0.0` if no sale-day price beats the benchmark. A price
that exactly matches the benchmark does not count as success.

### Method

Read the purchase price from the single node listed in `model.levels[0]` and
store it in `initial_price`. Set `T = days * dt`. For each node number in
`model.levels[days]`, read `node = model.data[node_number]` and compute
`rho = (node.price / initial_price) * exp(-benchmark * T) - 1`.
Add `node.probability` only when `rho > 0`.

### Notes

The package rounds prices and probabilities to ten significant digits.
Use these stored values without rounding them again. The checks allow small
rounding errors in probability sums. Only the scheduled sale-day price counts.
"""
function lattice_probability(model::MyBinomialEquityPriceTree, days::Int,
    benchmark::Float64, dt::Float64)::Float64
    # TODO 6: Store the day-0 price in initial_price and set T = days * dt.
    # TODO 7: Loop over model.levels[days] and read each node from model.data.
    # Compute its scaled NPV with the formula in the docstring.
    # TODO 8: Add the probabilities of nodes with scaled NPV > 0.
    # Return the sum, or 0.0 if no sale-day price beats the benchmark.
    error("Complete lattice_probability in your selected source file.");
end

"""
    observed_outcome(initial_price::Float64, observed::NamedTuple, days::Int,
        benchmark::Float64, dt::Float64) -> NamedTuple

Calculate the outcome of buying at the purchase price and selling after the
specified number of trading days.

### Arguments

- `initial_price`: Positive purchase price in USD/share, supplied separately
  from the later sale observations.
- `observed`: The named tuple returned by `load_prices` for the comparison
  file. Its `dates` and `prices` vectors are ordered from oldest to newest.
  Position 1 is the first trading day after purchase; day 0 is not in this file.
- `days`: Positive whole number of trading days from purchase to sale. The
  comparison file contains at least this many observations.
- `benchmark`: Continuously compounded rate per trading year.
- `dt`: Length of one trading day, measured in trading years.

### Returns

A named tuple with these five entries:

- `sale_date`: The observed sale date, as a `Date`.
- `sale_price`: The observed sale price, in USD/share.
- `benchmark_price`: The sale price needed to match the benchmark, in USD/share.
- `scaled_npv`: The discounted sale proceeds minus the purchase cost, divided
  by the purchase cost. Return a decimal fraction; `0.01` means 1%.
- `beats_benchmark`: A Boolean that is `true` only when `scaled_npv > 0`.
  Equality with the benchmark does not count as success.

### Method

Select observation `days` from the comparison file. Count price observations,
not calendar days. Convert the holding period to trading years using
`T = days * dt`. The benchmark price is `initial_price * exp(benchmark * T)`.
Calculate the scaled NPV using the same discounting rule as in the lattice:
`(sale_price / initial_price) * exp(-benchmark * T) - 1`.

Use unrounded values for the calculations and the success comparison.
"""
function observed_outcome(initial_price::Float64, observed::NamedTuple, days::Int,
    benchmark::Float64, dt::Float64)::NamedTuple
    # TODO 9: Select the sale date and price from observation days.
    # TODO 10: Calculate the benchmark price and scaled NPV using the holding time in years.
    # TODO 11: Return all five named entries described in the docstring.
    error("Complete observed_outcome in your selected source file.");
end
