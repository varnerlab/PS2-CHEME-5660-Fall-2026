"""
    load_prices(path::String) -> NamedTuple

Read the supplied price file without changing its values.

### Arguments

- `path`: Price file with the exact header `date,ticker,price`. Dates use
  `YYYY-MM-DD` and must be in chronological order without repeats. The file
  must contain one ticker and at least three prices.

### Returns

A named tuple with a vector of calendar `dates`, a `ticker` string, and
a vector of `prices` in USD/share. Entries keep their order from the file.

### Errors

Raises an error if the file cannot be read or a row fails the format, date,
ticker, or price checks. Prices must be finite and positive.
"""
function load_prices(path::String)::NamedTuple
    # Read the price rows -
    lines = readlines(path);
    first(lines) == "date,ticker,price" || throw(ArgumentError("Expected date,ticker,price columns."));
    dates = Date[];
    tickers = String[];
    prices = Float64[];
    for line in lines[2:end]
        fields = split(line, ',');
        length(fields) == 3 || throw(ArgumentError("Each price row needs three entries."));
        push!(dates, Date(fields[1]));
        push!(tickers, fields[2]);
        push!(prices, parse(Float64, fields[3]));
    end
    # Check the price history -
    length(prices) >= 3 || throw(ArgumentError("At least three prices are required."));
    length(unique(tickers)) == 1 || throw(ArgumentError("Use one ticker per price file."));
    all(diff(dates) .> Day(0)) || throw(ArgumentError("Dates must increase without repeats."));
    all(x -> isfinite(x) && x > 0, prices) || throw(ArgumentError("Prices must be finite and positive."));
    return (dates=dates, ticker=first(tickers), prices=prices);
end

"""
    assignment_terms() -> NamedTuple

Return the fixed inputs used by the PS2 checker and report.

### Returns

A named tuple with these entries:

- `dt`: Time per trading day, `1/252` trading year.
- `benchmark`: Continuously compounded rate, `0.05` per trading year.
- `comparison_benchmark`: Lower rate, `0.01` per trading year, used only in
  the 126-day benchmark comparison in Question 2.
- `comparison_days`: Holding period for the benchmark comparison, 126 trading days.
- `primary_days`: Main holding period, 63 trading days.
- `holding_days`: The three holding periods, `[21, 63, 126]` trading days.
- `illustration`: Assumed GBM parameters for Advanced Question 3. The mean
  growth rate `mu_g` and price drift `mu` are measured in 1/year; the volatility
  parameter `sigma` is measured in 1/sqrt(year). Here, a year means a trading
  year. These values are separate from the AAPL estimates.
"""
function assignment_terms()::NamedTuple
    return (dt=1/252, benchmark=0.05, comparison_benchmark=0.01, primary_days=63,
        comparison_days=126, holding_days=[21, 63, 126],
        illustration=(mu_g=0.035, sigma=0.30, mu=0.08));
end

"""
    gbm_expected_npv(parameters::NamedTuple, days::Int,
        benchmark::Float64, dt::Float64) -> Float64

Calculate the expected scaled NPV under the GBM model.

### Arguments

- `parameters`: A named tuple with the price drift `mu`, measured per trading year.
- `days`: Number of trading days from purchase to sale.
- `benchmark`: Continuously compounded benchmark rate per trading year.
- `dt`: Length of one trading day, measured in trading years.

### Returns

The unitless value `exp((mu - benchmark) * days * dt) - 1`.
A value of `0.01` means that the expected discounted sale proceeds exceed
the purchase cost by 1%.
"""
function gbm_expected_npv(parameters::NamedTuple, days::Int,
    benchmark::Float64, dt::Float64)::Float64
    return expm1((parameters.mu - benchmark) * days * dt); # accurate exp(x) - 1 when x is near zero
end
