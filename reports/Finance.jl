"""
    try_result(label::String, calculation::Function)

Run one report calculation. If it fails, print its error and let the other
calculations continue.

### Arguments

- `label`: Name of the calculation, shown if it fails.
- `calculation`: Function with no arguments that computes the result.

### Returns

The calculation's value, or `nothing` after printing an error.
"""
function try_result(label::String, calculation::Function)
    try
        return calculation();
    catch caught
        println(label, ": UNAVAILABLE — ", sprint(showerror, caught));
        return nothing;
    end
end

"""
    write_terminal_nodes(model, days, benchmark, dt, path) -> Nothing

Save each sale-day node's price, probability, scaled NPV, and whether it beats
the benchmark.

### Arguments

- `model`: Lattice containing the purchase price and sale-day nodes.
- `days`: Number of trading days from purchase to sale.
- `benchmark`: Continuously compounded benchmark rate per trading year.
- `dt`: Length of one trading day, measured in trading years.
- `path`: CSV file to write. Replaces the file if it already exists.

### Returns

`nothing`. Writes prices in USD/share and probabilities and scaled NPVs as
decimal fractions. The `positive_npv` column is `true` only when the scaled
NPV is strictly above zero.

### Errors

Raises an error if the file cannot be written.
"""
function write_terminal_nodes(model::MyBinomialEquityPriceTree, days::Int,
    benchmark::Float64, dt::Float64, path::String)::Nothing
    initial_price = model.data[only(model.levels[0])].price;
    open(path, "w") do io
        println(io, "price,probability,scaled_npv,positive_npv");
        for index in model.levels[days]
            node = model.data[index];
            rho = node.price/initial_price*exp(-benchmark*days*dt) - 1;
            println(io, node.price, ',', node.probability, ',', rho, ',', rho > 0);
        end
    end
    return nothing;
end

"""
    print_finance_report(track::String, root::String) -> Nothing

Run the selected track's functions on the supplied AAPL prices and report
the estimates, forecast probabilities, and observed 2026 trade outcomes.

### Arguments

- `track`: `standard` or `advanced`.
- `root`: Assignment folder.

### Returns

`nothing`. Prints the estimated parameters, purchase price, and probabilities
for 21, 63, and 126 trading days. For each holding period, also reports the
observed sale date, price, scaled NPV, and whether the trade beat the benchmark.
Writes `results/<track>-results.csv` and, when available,
`results/terminal-nodes.csv` for the 63-day lattice.
The Advanced report also includes the expected scaled NPV and the separate
example for Question 3.

### Notes

Model estimates use only `AAPL-2025.csv`. Observed sale prices come from
`AAPL-2026.csv`. Its first price observation is trading day 1 after the
December 31, 2025 purchase; observation `days` gives the sale date and price.

Printed rates, probabilities, and scaled NPVs are percentages; CSV values
are decimal fractions. Time is measured in trading years. A failed forecast
calculation prints `UNAVAILABLE` and leaves an empty CSV field. The observed
outcome can still be reported. The checker reports file errors and invalid
input data.
"""
function print_finance_report(track::String, root::String)::Nothing
    # Read the estimation and comparison prices -
    data = load_prices(joinpath(root, "data", "AAPL-2025.csv"));
    observed = load_prices(joinpath(root, "data", "AAPL-2026.csv"));
    terms = assignment_terms();
    initial_price = last(data.prices);
    observed.ticker == data.ticker || throw(ArgumentError("Use the same ticker for estimation and comparison."));
    first(observed.dates) > last(data.dates) || throw(ArgumentError("Comparison prices must come after the purchase date."));
    length(observed.prices) >= maximum(terms.holding_days) || throw(ArgumentError("The comparison file must cover all three holding periods."));
    output = joinpath(root, "results");
    mkpath(output);
    println("\nPS2 financial results");
    println("Price history: ", data.ticker, ", ", first(data.dates), " to ", last(data.dates));
    println("Price observations: ", length(data.prices), "; price changes: ", length(data.prices)-1);
    println("Use this history to estimate the model parameters. The 2026 prices are used only to check the trade outcomes.");
    println("Day 0: ", last(data.dates), "; first trading day after purchase: ", first(observed.dates));
    @printf("Purchase price: %.4f USD/share\nBenchmark: %.2f%% per trading year, continuously compounded\n", initial_price, 100*terms.benchmark);
    println("Each probability is the chance of selling above the benchmark price on the scheduled sale day.");
    # Estimate the models using only 2025 prices -
    lattice = try_result("Lattice estimates", () -> estimate_lattice(data.prices, terms.dt));
    if lattice !== nothing
        @printf("Lattice: u = %.8f, d = %.8f, p = %.4f%%\n", lattice.u, lattice.d, 100*lattice.p);
    end
    gbm = track == "advanced" ? try_result("GBM estimates", () -> estimate_gbm(data.prices, terms.dt)) : nothing;
    if gbm !== nothing
        @printf("GBM: mean growth rate = %.4f%%/year, volatility = %.4f%%/sqrt(year), price drift = %.4f%%/year\n",
            100*gbm.mu_g, 100*gbm.sigma, 100*gbm.mu);
    end
    # Compare each forecast with the observed sale price -
    open(joinpath(output, "$(track)-results.csv"), "w") do io
        println(io, "trading_days,sale_price_to_match_benchmark,lattice_probability,probability_sum",
            track == "advanced" ? ",gbm_probability,gbm_expected_scaled_npv" : "",
            ",sale_date,observed_sale_price,observed_scaled_npv,observed_beats_benchmark");
        for days in terms.holding_days
            threshold = initial_price*exp(terms.benchmark*days*terms.dt);
            sale_date = observed.dates[days]; # row 1 is the first trading day after purchase
            sale_price = observed.prices[days];
            observed_npv = sale_price/initial_price*exp(-terms.benchmark*days*terms.dt) - 1;
            observed_success = observed_npv > 0; # equality with the benchmark does not count
            model = lattice === nothing ? nothing : try_result("$(days)-day lattice", () -> build_lattice(lattice, initial_price, days));
            probability = model === nothing ? nothing : try_result("$(days)-day lattice probability", () -> lattice_probability(model, days, terms.benchmark, terms.dt));
            mass = model === nothing ? nothing : sum(model.data[i].probability for i in model.levels[days]);
            normal_probability = gbm === nothing ? nothing : try_result("$(days)-day GBM probability", () -> gbm_probability(gbm, days, terms.benchmark, terms.dt));
            expected = gbm === nothing ? nothing : gbm_expected_npv(gbm, days, terms.benchmark, terms.dt);
            @printf("\n%d trading days: sale price to match the benchmark = %.4f USD/share\n", days, threshold);
            probability === nothing || @printf("  Lattice probability of beating the benchmark = %.4f%%\n", 100*probability);
            normal_probability === nothing || @printf("  GBM probability of beating the benchmark = %.4f%%\n", 100*normal_probability);
            expected === nothing || @printf("  GBM expected scaled NPV = %.4f%%\n", 100*expected);
            @printf("  Observed sale on %s: %.4f USD/share\n", string(sale_date), sale_price);
            @printf("  Observed scaled NPV = %.4f%%; beat the benchmark: %s\n", 100*observed_npv, observed_success ? "yes" : "no");
            mass === nothing || @printf("  Check: sale-day probabilities sum to %.10f (should be 1, allowing for rounding).\n", mass);
            values = Any[days, threshold, probability, mass];
            track == "advanced" && append!(values, [normal_probability, expected]);
            append!(values, [sale_date, sale_price, observed_npv, observed_success]);
            println(io, join([value === nothing ? "" : string(value) for value in values], ','));
            if model !== nothing && days == terms.primary_days
                write_terminal_nodes(model, days, terms.benchmark, terms.dt, joinpath(output, "terminal-nodes.csv"));
            end
        end
    end
    println("\nThe three holding periods start with the same purchase and share the same price history.");
    println("These outcomes show what happened to this trade. More forecasts and their observed outcomes are needed to judge how accurate the probabilities are.");
    # Report the separate example for Advanced Question 3 -
    if track == "advanced"
        example = terms.illustration;
        probability = try_result("Advanced Question 3 probability", () -> gbm_probability(example, terms.primary_days, terms.benchmark, terms.dt));
        expected = gbm_expected_npv(example, terms.primary_days, terms.benchmark, terms.dt);
        println("\nAdvanced Question 3: separate example with assumed parameters");
        @printf("Holding period: %d trading days; benchmark: %.2f%% per trading year\n", terms.primary_days, 100*terms.benchmark);
        @printf("Mean growth rate = %.2f%%/year; volatility = %.2f%%/sqrt(year); price drift = %.2f%%/year\n", 100*example.mu_g, 100*example.sigma, 100*example.mu);
        probability === nothing || @printf("Probability of beating the benchmark = %.4f%%\n", 100*probability);
        @printf("Expected scaled NPV = %.4f%%\n", 100*expected);
    end
    println("\nSaved results/$(track)-results.csv.");
    isfile(joinpath(output, "terminal-nodes.csv")) && println("Saved results/terminal-nodes.csv with the 63-day sale prices and probabilities.");
    println("In the CSV files, probabilities and scaled NPVs use decimal fractions; 0.05 means 5%.");
    return nothing;
end
