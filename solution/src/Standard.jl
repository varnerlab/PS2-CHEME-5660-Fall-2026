# PS2 Standard Track - Reference Solution
#
# These four functions estimate a binomial lattice from the 2025 AAPL prices,
# calculate the probability of beating the benchmark on the sale day, and
# calculate the observed outcome of selling on that day in 2026.
#
# Course examples used:
# - L3b lattice example: log_growth_matrix, RealWorldBinomialProbabilityMeasure,
#   build, and populate.
# - L4a lattice trade-rule example: the scaled NPV of a sale,
#   rho = (S_T/S_0)*exp(-g_y*T) - 1, and the strict success rule rho > 0.
#
# The checker loads the course package and supplied helpers, then calls these
# functions with the supplied data:
# julia --project=. --startup-file=no check_submission.jl

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

    # Compute the daily growth rates, g = (1/dt)*log(S[j]/S[j-1]), in 1/year -
    # Use risk_free_rate = 0.0: the benchmark enters only the NPV calculation.
    growth = log_growth_matrix(prices; Δt = dt, risk_free_rate = 0.0); # 249 rates from 250 prices

    # Estimate the lattice parameters from the signs and sizes of the growth rates (L3b) -
    # u: average price factor on up days, d: average price factor on down days,
    # p: fraction of all daily changes that are up moves.
    (u, d, p) = (RealWorldBinomialProbabilityMeasure())(growth; Δt = dt);

    return (u = u, d = d, p = p);
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

    # Build the lattice model from the fitted daily factors and up-move probability -
    model = build(MyBinomialEquityPriceTree, (
        u = parameters.u, d = parameters.d, p = parameters.p));

    # Add the node prices and probabilities for day 0 (purchase) through day days (sale) -
    # Sₒ is the purchase price (USD/share), and h is the number of daily steps.
    model = populate(model; Sₒ = initial_price, h = days);

    return model;
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

    # Read the purchase price from the single node on day 0 -
    root_index = model.levels[0][1]; # model.levels[0] lists one node number
    initial_price = model.data[root_index].price; # purchase price (USD/share)
    T = days*dt; # holding period (years)

    # Add the probabilities of the sale-day prices that beat the benchmark (L4a) -
    probability = 0.0;
    for node_index ∈ model.levels[days] # node numbers for the possible sale-day prices
        node = model.data[node_index];
        rho = (node.price/initial_price)*exp(-benchmark*T) - 1.0; # scaled NPV of this sale price
        if (rho > 0.0) # strict: a sale that only matches the benchmark is not a success
            probability += node.probability; # includes every path to this node
        end
    end

    return probability;
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

    # Select the sale observation; position 1 is the first trading day after purchase -
    sale_date = observed.dates[days]; # count price observations, not calendar days
    sale_price = observed.prices[days]; # observed sale price (USD/share)

    # Compare the observed sale with the benchmark over the same holding period -
    T = days*dt; # holding period (years)
    benchmark_price = initial_price*exp(benchmark*T); # price for zero scaled NPV (USD/share)
    scaled_npv = (sale_price/initial_price)*exp(-benchmark*T) - 1.0; # same rule as the lattice
    beats_benchmark = (scaled_npv > 0.0); # strict: equality does not beat the benchmark

    return (sale_date = sale_date, sale_price = sale_price, benchmark_price = benchmark_price,
        scaled_npv = scaled_npv, beats_benchmark = beats_benchmark);
end
