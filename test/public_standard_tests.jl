"""
    standard_public_checks() -> Vector{NamedTuple}

Define the 15 public checks for the three Standard functions.

### Returns

A vector of named tuples. Each has a `name` and an `evaluate` function that
returns `true` when the check passes.

### Notes

Some checks supply their own parameters or lattice, so they can pass even
if another student function is unfinished. The final check uses all three
functions with the supplied AAPL prices.
"""
function standard_public_checks()::Vector{NamedTuple}
    prices = [100.0, 110.0, 99.0, 99.0, 79.2, 95.04];
    fitted = () -> estimate_lattice(copy(prices), 1/252);
    parameters = (u=1.2, d=0.9, p=0.6);
    tree = () -> build_lattice(parameters, 80.0, 3);
    supplied = () -> populate(build(MyBinomialEquityPriceTree, parameters); Sₒ=100.0, h=2);
    probability = (benchmark, dt) -> lattice_probability(supplied(), 2, benchmark, dt);

    return [
        (name="Estimate the average up factor", evaluate=() -> isapprox(fitted().u, 1.15; atol=1e-12)),
        (name="Estimate the average down factor", evaluate=() -> isapprox(fitted().d, 0.85; atol=1e-12)),
        (name="Count unchanged prices when estimating p", evaluate=() -> isapprox(fitted().p, 0.4; atol=1e-12)),
        (name="Use the supplied time between prices", evaluate=() -> begin
            p = estimate_lattice(copy(prices), 0.25);
            isapprox(p.u, 1.15; atol=1e-12) && isapprox(p.d, 0.85; atol=1e-12) && p.p == 0.4;
        end),
        (name="Keep the supplied lattice parameters", evaluate=() -> begin
            m = tree(); m.u == 1.2 && m.d == 0.9 && m.p == 0.6;
        end),
        (name="Include day 0 through the sale day", evaluate=() -> begin
            m = tree(); sort(collect(keys(m.levels))) == collect(0:3) &&
                all(length(m.levels[j]) == j+1 for j in 0:3) &&
                m.data[only(m.levels[0])].price == 80.0;
        end),
        (name="Store the four sale prices after three days", evaluate=() -> begin
            m = tree(); actual = sort([m.data[i].price for i in m.levels[3]]);
            isapprox(actual, sort([80*1.2^k*0.9^(3-k) for k in 0:3]); atol=1e-8);
        end),
        (name="Include all paths in each node probability", evaluate=() -> begin
            m = tree(); actual = [m.data[i].probability for i in m.levels[3]];
            isapprox(actual, [0.216, 0.432, 0.288, 0.064]; atol=1e-10);
        end),
        (name="Each day's probabilities sum to one", evaluate=() -> begin
            m = tree(); all(isapprox(sum(m.data[i].probability for i in m.levels[j]), 1.0; atol=1e-8) for j in 0:3);
        end),
        (name="Add the probabilities of all sale-day outcomes with positive scaled NPV", evaluate=() -> isapprox(probability(0.05, 0.5), 0.84; atol=1e-10)),
        (name="Exclude outcomes exactly equal to the benchmark", evaluate=() -> begin
            m = populate(build(MyBinomialEquityPriceTree, (u=1.25, d=0.8, p=0.6)); Sₒ=100.0, h=2);
            isapprox(lattice_probability(m, 2, 0.0, 1/252), 0.36; atol=1e-10);
        end),
        (name="Return zero when no outcome beats the benchmark", evaluate=() -> probability(2.0, 0.5) == 0.0),
        (name="Return one when every outcome beats the benchmark", evaluate=() -> isapprox(probability(-2.0, 0.5), 1.0; atol=1e-10)),
        (name="Convert trading days to years when discounting", evaluate=() -> isapprox(probability(1.5, 1/252), 0.84; atol=1e-10)),
        (name="Run all three tasks on the supplied AAPL history", evaluate=() -> begin
            data = load_prices(joinpath(_PATH_TO_DATA, "AAPL-2025.csv"));
            terms = assignment_terms();
            params = estimate_lattice(data.prices, terms.dt);
            m = build_lattice(params, last(data.prices), terms.primary_days);
            result = lattice_probability(m, terms.primary_days, terms.benchmark, terms.dt);
            # Check the result using price ratios and binomial probabilities -
            ratios = data.prices[2:end] ./ data.prices[1:end-1];
            u = mean(filter(x -> x > 1, ratios));
            d = mean(filter(x -> x < 1, ratios));
            p = count(x -> x > 1, ratios)/length(ratios);
            n = terms.primary_days;
            expected = sum(Float64(binomial(big(n), k))*p^k*(1-p)^(n-k)
                for k in 0:n if u^k*d^(n-k)*exp(-terms.benchmark*n*terms.dt) > 1);
            isapprox(result, expected; atol=1e-8);
        end),
    ];
end
