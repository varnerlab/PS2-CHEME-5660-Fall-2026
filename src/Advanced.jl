# PS2 Advanced: Complete these three lattice functions and the two GBM functions.
# Keep the function names, arguments, return types, and docstrings.
# The checker supplies valid inputs. You do not need to add input checks.

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
    estimate_gbm(prices::Vector{Float64}, dt::Float64) -> NamedTuple

Estimate the mean growth rate, volatility parameter, and price drift for the GBM model.

### Arguments

- `prices`: At least three positive prices in USD/share, ordered from oldest to newest.
- `dt`: Time between observations in trading years.

Use the same price history and time step as in the lattice model.

### Returns

A named tuple `(mu_g=mu_g, sigma=sigma, mu=mu)` with three entries:

- `mu_g`: Mean growth rate, in 1/year.
- `sigma`: Volatility parameter, in 1/sqrt(year); it controls how widely prices vary.
- `mu`: Price drift, in 1/year; it sets the rate at which the average price grows.

In these units, a year means a trading year.

### Method

Use the method from L4b. Store the result of
`log_growth_matrix(prices; Δt=dt, risk_free_rate=0.0)` in `growth`.
These are daily growth rates expressed per trading year. Then calculate:

- `mu_g = mean(growth)`.
- `sigma = std(growth) * sqrt(dt)`.
- `mu = mu_g + sigma^2 / 2`.

Use `std(growth)` with its default settings. It uses one less than the number
of growth rates in the denominator. The probability calculation uses `mu_g`;
the expected NPV calculation uses `mu`.
"""
function estimate_gbm(prices::Vector{Float64}, dt::Float64)::NamedTuple
    # TODO 9: Use log_growth_matrix with Δt=dt and risk_free_rate=0.0 to get growth.
    # TODO 10: Calculate mu_g = mean(growth), sigma = std(growth) * sqrt(dt),
    # and mu = mu_g + sigma^2 / 2.
    # TODO 11: Return (mu_g=mu_g, sigma=sigma, mu=mu).
    error("Complete estimate_gbm in your selected source file.");
end

"""
    gbm_probability(parameters::NamedTuple, days::Int,
        benchmark::Float64, dt::Float64) -> Float64

Calculate the GBM probability of beating the benchmark on the sale day.

### Arguments

- `parameters`: A named tuple with the mean growth rate `mu_g` in 1/year
  and the volatility parameter `sigma` in 1/sqrt(year). Here, a year means a
  trading year. The volatility parameter must be zero or positive. The `mu`
  entry is not used.
- `days`: Positive whole number of trading days from purchase to sale.
- `benchmark`: Continuously compounded rate; `0.05` means 5% per trading year.
- `dt`: Length of one trading day, measured in trading years.

### Returns

The probability that the scaled NPV is strictly above zero, expressed as a
value from 0 to 1. A value of zero for the scaled NPV does not count as success.

### Method

For `parameters.sigma > 0`, set `T = days * dt` and compute
`z = (benchmark - parameters.mu_g) * sqrt(T) / parameters.sigma`.
Return `ccdf(Normal(), z)`, the standard normal probability above `z`.

For `parameters.sigma == 0`, return `1.0` if `parameters.mu_g > benchmark`
and `0.0` otherwise, including when the mean growth rate equals the
benchmark rate. No price simulation is needed.
"""
function gbm_probability(parameters::NamedTuple, days::Int,
    benchmark::Float64, dt::Float64)::Float64
    # TODO 12: If parameters.sigma is zero, return 1.0 when
    # parameters.mu_g > benchmark and 0.0 otherwise.
    # TODO 13: For positive parameters.sigma, set T = days * dt and calculate
    # z = (benchmark - parameters.mu_g) * sqrt(T) / parameters.sigma.
    # TODO 14: Return ccdf(Normal(), z), the probability above z.
    error("Complete gbm_probability in your selected source file.");
end
