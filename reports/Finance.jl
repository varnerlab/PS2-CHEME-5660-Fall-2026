"""
    try_result(label::String, calculation::Function, issues)

Run one report calculation. If it fails, record its error for the report's
diagnostic section and let the other calculations continue.

### Arguments

- `label`: Name of the calculation, shown if it fails.
- `calculation`: Function with no arguments that computes the result.
- `issues`: Vector of label/error pairs to populate when a calculation fails.

### Returns

The calculation's value, or `nothing` after recording an error.
"""
function try_result(label::String, calculation::Function, issues::Vector{Pair{String,String}})
    try
        return calculation();
    catch caught
        push!(issues, label => sprint(showerror, caught));
        return nothing;
    end
end

"""
    terminal_number(value; percent=false, digits=4) -> String

Format a report number with fixed decimal places. Multiply by 100 when
`percent` is true. Return `UNAVAILABLE` for `nothing`. The supplied value
is not changed; CSV output keeps the unrounded value.
"""
function terminal_number(value; percent::Bool=false, digits::Int=4)::String
    value === nothing && return "UNAVAILABLE";
    return @sprintf("%.*f", digits, value * (percent ? 100 : 1));
end

"""
    print_report_issues(issues) -> Nothing

Print each distinct calculation error once, with the labels of all affected
calculations. `issues` contains label/error pairs. Returns `nothing` and
prints nothing when every calculation was available.
"""
function print_report_issues(issues::Vector{Pair{String,String}})::Nothing
    isempty(issues) && return nothing;
    print_terminal_section("Unavailable calculations");
    print_terminal_text("UNAVAILABLE means a required function did not return a result. Fix the listed function, save your code, and rerun the checker.");
    for (index, detail) in enumerate(unique(last.(issues)))
        println();
        println("Calculation error $(index)");
        print_terminal_detail(detail);
        labels = unique([first(issue) for issue in issues if last(issue) == detail]);
        print_terminal_text("Affected: " * join(labels, "; "); prefix="  ");
    end
    return nothing;
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
    print_benchmark_comparison(track, initial_price, observed, terms,
        lattice, gbm, path; issues) -> Nothing

Print and save the 126-day comparison of the original and lower benchmarks.

### Arguments

- `track`: Selected track, `standard` or `advanced`.
- `initial_price`: Purchase price in USD/share.
- `observed`: Supplied comparison dates and prices, passed to `observed_outcome`.
- `terms`: Fixed assignment inputs, including the two benchmark rates.
- `lattice`, `gbm`: Student-estimated parameters, or `nothing` if unavailable.
- `path`: Destination CSV file; replaces the previous comparison.
- `issues`: Shared list of unavailable calculations for the report footer.

### Returns

`nothing`. Reuses the same fitted parameters and lattice for both rates.
Calls the student's functions for the benchmark prices and probabilities.
Counts successful lattice nodes to help students interpret the probabilities;
node counts are not probability weights. Missing calculations print
`UNAVAILABLE` and leave empty CSV fields. File-write errors propagate.
"""
function print_benchmark_comparison(track::String, initial_price::Float64,
    observed::NamedTuple, terms::NamedTuple, lattice, gbm, path::String;
    issues::Vector{Pair{String,String}})::Nothing
    days = terms.comparison_days;
    print_terminal_section("Question 2: benchmark comparison (5% to 1%)");
    print_terminal_text("Holding period: $(days) trading days. Both rows use the same purchase price and fitted parameters.");
    model = lattice === nothing ? nothing : try_result("Comparison lattice",
        () -> build_lattice(lattice, initial_price, days), issues);
    rows = NamedTuple[];

    # Change only the benchmark; keep the fitted price distributions fixed -
    for rate in (terms.benchmark, terms.comparison_benchmark)
        label = @sprintf("Comparison at %.0f%%", 100*rate);
        outcome = try_result(label * " observed outcome",
            () -> observed_outcome(initial_price, observed, days, rate, terms.dt), issues);
        threshold = outcome === nothing ? nothing : outcome.benchmark_price;
        probability = model === nothing ? nothing : try_result(label * " lattice probability",
            () -> lattice_probability(model, days, rate, terms.dt), issues);
        normal_probability = gbm === nothing ? nothing : try_result(label * " GBM probability",
            () -> gbm_probability(gbm, days, rate, terms.dt), issues);
        counts = model === nothing ? nothing : try_result(label * " lattice node counts", () -> begin
            purchase = model.data[only(model.levels[0])].price;
            nodes = model.levels[days];
            successful = count(i -> model.data[i].price/purchase*exp(-rate*days*terms.dt) - 1 > 0, nodes);
            (successful=successful, total=length(nodes));
        end, issues);
        push!(rows, (rate=rate, threshold=threshold, probability=probability,
            normal_probability=normal_probability, counts=counts));
    end

    # Align the two benchmark rows and keep units outside the narrow table -
    headers = ["Rate (%)", "Match price", "Lattice (%)", "Nodes"];
    track == "advanced" && push!(headers, "GBM (%)");
    display_rows = Vector{String}[];
    open(path, "w") do io
        println(io, "benchmark,trading_days,sale_price_to_match_benchmark,lattice_probability,successful_nodes,total_nodes" *
            (track == "advanced" ? ",gbm_probability" : ""));
        for row in rows
            cells = [terminal_number(row.rate; percent=true, digits=2),
                terminal_number(row.threshold),
                terminal_number(row.probability; percent=true),
                row.counts === nothing ? "UNAVAILABLE" : "$(row.counts.successful) of $(row.counts.total)"];
            if track == "advanced"
                push!(cells, terminal_number(row.normal_probability; percent=true));
            end
            push!(display_rows, cells);
            values = Any[row.rate, days, row.threshold, row.probability,
                row.counts === nothing ? nothing : row.counts.successful,
                row.counts === nothing ? nothing : row.counts.total];
            track == "advanced" && push!(values, row.normal_probability);
            println(io, join([value === nothing ? "" : string(value) for value in values], ','));
        end
    end
    println();
    print_terminal_table(headers, display_rows; right_columns=collect(eachindex(headers)));
    println();
    print_terminal_text("Rate: percent per trading year. Match price: USD/share at zero scaled NPV.");
    print_terminal_text("Nodes: successful sale prices out of all sale-day nodes. Nodes need not be equally likely.");
    print_terminal_text("Use these rows with your prediction to answer Question 2.");
    return nothing;
end

"""
    print_finance_report(track::String, root::String;
        output_directory::String=joinpath(root, "results")) -> Nothing

Run the selected track's functions on the supplied AAPL prices and report
the estimates, forecast probabilities, and trade outcomes calculated by the student.

### Arguments

- `track`: `standard` or `advanced`.
- `root`: Assignment folder.
- `output_directory`: Folder for generated CSVs; local solution runs use `solution/results`.

### Returns

`nothing`. Prints the estimated parameters, purchase price, and probabilities
for 21, 63, and 126 trading days. For each holding period, also reports the
observed sale date, price, scaled NPV, and whether the trade beat the benchmark.
Writes `<track>-results.csv` in `output_directory`. Also writes
`terminal-nodes.csv` for the 63-day lattice when available.
Prints the 5%-to-1% benchmark comparison and saves `benchmark-comparison.csv`.
The Advanced report also includes the expected scaled NPV and the separate
example for Question 3.

### Notes

Model estimates use only `AAPL-2025.csv`. Pass `AAPL-2026.csv` to the student's
`observed_outcome` function. That function selects the sale observation and
calculates the benchmark price, scaled NPV, and success flag. The report
displays its returned values without replacing them with supplied calculations.

Printed rates, probabilities, and scaled NPVs are percentages; CSV values
are decimal fractions. Time is measured in trading years. A failed calculation
prints `UNAVAILABLE` and leaves its CSV fields empty. Forecasts and observed
outcomes can be completed independently. The separate Advanced example is
shown when the student's probability function returns a result. The checker
reports file errors and invalid input data.
"""
function print_finance_report(track::String, root::String;
    output_directory::String=joinpath(root, "results"))::Nothing
    # Read the estimation and comparison prices -
    data = load_prices(joinpath(root, "data", "AAPL-2025.csv"));
    observed = load_prices(joinpath(root, "data", "AAPL-2026.csv"));
    terms = assignment_terms();
    initial_price = last(data.prices);
    observed.ticker == data.ticker || throw(ArgumentError("Use the same ticker for estimation and comparison."));
    first(observed.dates) > last(data.dates) || throw(ArgumentError("Comparison prices must come after the purchase date."));
    length(observed.prices) >= maximum(terms.holding_days) || throw(ArgumentError("The comparison file must cover all three holding periods."));
    output = output_directory;
    mkpath(output);
    issues = Pair{String,String}[];
    print_terminal_section("PS2 financial results"; major=true);
    println("Price history: ", data.ticker, ", ", first(data.dates), " to ", last(data.dates));
    println("Price observations: ", length(data.prices), "; price changes: ", length(data.prices)-1);
    print_terminal_text("Model estimates use 2025 prices. Observed trade outcomes use 2026 prices.");
    println("Day 0: ", last(data.dates), "; first trading day after purchase: ", first(observed.dates));
    @printf("Purchase price: %.4f USD/share\nBenchmark: %.2f%% per trading year, continuously compounded\n", initial_price, 100*terms.benchmark);
    print_terminal_text("Success means selling strictly above the benchmark price on the sale day.");
    # Estimate the models using only 2025 prices -
    lattice = try_result("Lattice estimates", () -> estimate_lattice(data.prices, terms.dt), issues);
    gbm = track == "advanced" ? try_result("GBM estimates", () -> estimate_gbm(data.prices, terms.dt), issues) : nothing;
    print_terminal_section("Model estimates from 2025 prices");
    estimates = [
        ["Up factor (u)", terminal_number(lattice === nothing ? nothing : lattice.u; digits=8), "unitless"],
        ["Down factor (d)", terminal_number(lattice === nothing ? nothing : lattice.d; digits=8), "unitless"],
        ["Up probability (p)", terminal_number(lattice === nothing ? nothing : lattice.p; percent=true), "%"],
    ];
    if track == "advanced"
        append!(estimates, [
            ["Mean growth rate (mu_g)", terminal_number(gbm === nothing ? nothing : gbm.mu_g; percent=true), "%/year"],
            ["Volatility (sigma)", terminal_number(gbm === nothing ? nothing : gbm.sigma; percent=true), "%/sqrt(year)"],
            ["Price drift (mu)", terminal_number(gbm === nothing ? nothing : gbm.mu; percent=true), "%/year"],
        ]);
    end
    print_terminal_table(["Parameter", "Value", "Units"], estimates; right_columns=[2]);
    print_terminal_text("A year means 252 trading days.");
    # Compare each forecast with the observed sale price -
    results = NamedTuple[];
    open(joinpath(output, "$(track)-results.csv"), "w") do io
        println(io, "trading_days,sale_price_to_match_benchmark,lattice_probability,probability_sum",
            track == "advanced" ? ",gbm_probability,gbm_expected_scaled_npv" : "",
            ",sale_date,observed_sale_price,observed_scaled_npv,observed_beats_benchmark");
        for days in terms.holding_days
            outcome = try_result("$(days)-day observed outcome", () -> observed_outcome(
                initial_price, observed, days, terms.benchmark, terms.dt), issues);
            threshold = outcome === nothing ? nothing : outcome.benchmark_price;
            sale_date = outcome === nothing ? nothing : outcome.sale_date;
            sale_price = outcome === nothing ? nothing : outcome.sale_price;
            observed_npv = outcome === nothing ? nothing : outcome.scaled_npv;
            observed_success = outcome === nothing ? nothing : outcome.beats_benchmark;
            model = lattice === nothing ? nothing : try_result("$(days)-day lattice", () -> build_lattice(lattice, initial_price, days), issues);
            probability = model === nothing ? nothing : try_result("$(days)-day lattice probability", () -> lattice_probability(model, days, terms.benchmark, terms.dt), issues);
            mass = model === nothing ? nothing : sum(model.data[i].probability for i in model.levels[days]);
            normal_probability = gbm === nothing ? nothing : try_result("$(days)-day GBM probability", () -> gbm_probability(gbm, days, terms.benchmark, terms.dt), issues);
            expected = gbm === nothing ? nothing : gbm_expected_npv(gbm, days, terms.benchmark, terms.dt);
            push!(results, (days=days, threshold=threshold, probability=probability,
                normal_probability=normal_probability, expected=expected, mass=mass,
                sale_date=sale_date, sale_price=sale_price, observed_npv=observed_npv,
                observed_success=observed_success));
            values = Any[days, threshold, probability, mass];
            track == "advanced" && append!(values, [normal_probability, expected]);
            append!(values, [sale_date, sale_price, observed_npv, observed_success]);
            println(io, join([value === nothing ? "" : string(value) for value in values], ','));
            if model !== nothing && days == terms.primary_days
                write_terminal_nodes(model, days, terms.benchmark, terms.dt, joinpath(output, "terminal-nodes.csv"));
            end
        end
    end
    print_terminal_section("Forecasts and observed trades (5% benchmark)");
    print_terminal_text("Prices are USD/share. Probabilities and scaled NPVs are percentages.");
    println();
    headers = ["Quantity"; ["$(row.days) days" for row in results]];
    display_rows = [
        ["Sale price to match benchmark"; [terminal_number(row.threshold) for row in results]],
        ["Lattice probability (%)"; [terminal_number(row.probability; percent=true) for row in results]],
    ];
    if track == "advanced"
        append!(display_rows, [
            ["GBM probability (%)"; [terminal_number(row.normal_probability; percent=true) for row in results]],
            ["GBM expected scaled NPV (%)"; [terminal_number(row.expected; percent=true) for row in results]],
        ]);
    end
    append!(display_rows, [
        ["Observed sale date"; [row.sale_date === nothing ? "UNAVAILABLE" : string(row.sale_date) for row in results]],
        ["Observed sale price"; [terminal_number(row.sale_price) for row in results]],
        ["Observed scaled NPV (%)"; [terminal_number(row.observed_npv; percent=true) for row in results]],
        ["Beat benchmark?"; [row.observed_success === nothing ? "UNAVAILABLE" : row.observed_success ? "Yes" : "No" for row in results]],
        ["Sale-day probability sum"; [terminal_number(row.mass; digits=10) for row in results]],
    ]);
    print_terminal_table(headers, display_rows; right_columns=collect(2:length(headers)));
    println();
    print_terminal_text("The sale-day probabilities should sum to 1, allowing for rounding.");
    print_terminal_text("The three trades share one purchase and overlapping price changes. They do not establish whether the forecast probabilities are accurate.");
    print_benchmark_comparison(track, initial_price, observed, terms, lattice, gbm,
        joinpath(output, "benchmark-comparison.csv"); issues=issues);
    # Report the separate example for Advanced Question 3 -
    if track == "advanced"
        example = terms.illustration;
        print_terminal_section("Advanced Question 3: separate example with assumed parameters");
        probability = try_result("Advanced Question 3 probability", () -> gbm_probability(example, terms.primary_days, terms.benchmark, terms.dt), issues);
        if probability !== nothing
            expected = gbm_expected_npv(example, terms.primary_days, terms.benchmark, terms.dt);
            @printf("Holding period: %d trading days; benchmark: %.2f%% per trading year\n", terms.primary_days, 100*terms.benchmark);
            println();
            print_terminal_table(["Quantity", "Value", "Units"], [
                ["Price drift (mu)", terminal_number(example.mu; percent=true), "%/year"],
                ["Volatility (sigma)", terminal_number(example.sigma; percent=true), "%/sqrt(year)"],
                ["Mean growth rate (mu_g)", terminal_number(example.mu_g; percent=true), "%/year"],
                ["Probability of beating benchmark", terminal_number(probability; percent=true), "%"],
                ["Expected scaled NPV", terminal_number(expected; percent=true), "%"],
            ]; right_columns=[2]);
        else
            print_terminal_text("UNAVAILABLE: complete gbm_probability to display this example.");
        end
    end
    print_report_issues(issues);
    print_terminal_section("Files saved");
    println("Saved ", relpath(joinpath(output, "$(track)-results.csv"), root), ".");
    println("Saved ", relpath(joinpath(output, "benchmark-comparison.csv"), root), ".");
    isfile(joinpath(output, "terminal-nodes.csv")) && print_terminal_text("Saved " *
        relpath(joinpath(output, "terminal-nodes.csv"), root) * " with the 63-day sale prices and probabilities.");
    print_terminal_text("CSV probabilities and scaled NPVs are decimal fractions (0.05 = 5%).");
    return nothing;
end
