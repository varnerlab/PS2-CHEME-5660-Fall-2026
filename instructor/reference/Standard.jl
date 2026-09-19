# PS2 Standard reference solution.
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
    # Estimate daily moves from growth rates without subtracting the benchmark -
    growth = log_growth_matrix(prices; Δt=dt, risk_free_rate=0.0);
    u, d, p = (RealWorldBinomialProbabilityMeasure())(growth; Δt=dt);
    return (u=u, d=d, p=p);
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
    # Use the same fitted daily factors and probability at every level -
    model = build(MyBinomialEquityPriceTree, parameters);
    return populate(model; Sₒ=initial_price, h=days);
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
    initial_price = model.data[only(model.levels[0])].price; # purchase price in USD/share
    T = days * dt; # holding time in years
    probability = 0.0;
    for index in model.levels[days]
        node = model.data[index];
        rho = node.price/initial_price*exp(-benchmark*T) - 1;
        if rho > 0
            probability += node.probability; # include every path reaching this sale price
        end
    end
    return probability;
end
