include(joinpath(@__DIR__, "public_standard_tests.jl"));

"""
    advanced_public_checks() -> Vector{NamedTuple}

Define the 15 Standard checks and seven GBM checks for Advanced.

### Returns

A vector of 22 named tuples, each with a `name` and an `evaluate` function
that returns `true` when the check passes.

### Notes

Some GBM probability checks supply their own parameters, so they can pass
if estimation is unfinished. The checks cover time units, sample standard
deviation, the difference between drift and mean growth, and zero volatility.
"""
function advanced_public_checks()::Vector{NamedTuple}
    prices = [100.0, 100*exp(0.02), 100*exp(0.01), 100*exp(0.04)];
    fitted = () -> estimate_gbm(copy(prices), 0.25);
    parameters = (mu_g=0.035, sigma=0.30, mu=0.08);
    return vcat(standard_public_checks(), [
        (name="Estimate mean growth from price changes", evaluate=() -> isapprox(fitted().mu_g, 0.16/3; atol=1e-12)),
        (name="Scale the sample standard deviation to GBM volatility", evaluate=() -> isapprox(fitted().sigma, sqrt(0.0052/3); atol=1e-12)),
        (name="Add half the variance to obtain price drift", evaluate=() -> isapprox(fitted().mu, 0.16/3 + 0.0052/6; atol=1e-12)),
        (name="Use mean growth and years in the GBM probability", evaluate=() -> isapprox(gbm_probability(parameters, 63, 0.05, 1/252), 0.49002748180476197; atol=1e-12)),
        (name="Return one half when mean growth equals the benchmark", evaluate=() -> isapprox(gbm_probability(parameters, 126, 0.035, 1/252), 0.5; atol=1e-12)),
        (name="Handle zero volatility, including equality", evaluate=() -> begin
            p = (mu_g=0.05, sigma=0.0, mu=0.05);
            gbm_probability(p, 63, 0.04, 1/252) == 1.0 &&
                gbm_probability(p, 63, 0.05, 1/252) == 0.0 &&
                gbm_probability(p, 63, 0.06, 1/252) == 0.0;
        end),
        (name="Use the same AAPL history for the GBM comparison", evaluate=() -> begin
            data = load_prices(joinpath(_PATH_TO_DATA, "AAPL-2025.csv"));
            terms = assignment_terms();
            p = estimate_gbm(data.prices, terms.dt);
            returns = diff(log.(data.prices));
            mean_growth = mean(returns)/terms.dt;
            volatility = std(returns)/sqrt(terms.dt);
            all(isapprox(gbm_probability(p, n, terms.benchmark, terms.dt),
                ccdf(Normal(), (terms.benchmark-mean_growth)*sqrt(n*terms.dt)/volatility); atol=1e-10)
                for n in terms.holding_days);
        end),
    ]);
end
