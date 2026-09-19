# PS2 Advanced questions

Complete [src/Advanced.jl](../src/Advanced.jl) and answer these three questions.
You do not need to complete the Standard response file.

Run [check_submission.jl](../check_submission.jl) after completing your functions.
Use its printed financial results to answer the questions, and explain your
reasoning in your own words. Replace each TODO with your answer, keeping the
answer markers.

Report prices in USD/share and probabilities and scaled NPVs as percentages.
Report $u$ and $d$ as unitless price factors, $\mu_g$ and $\mu$ as percentages
per trading year, and $\sigma$ as a percentage per square root of a trading
year. Four decimal places are enough.

## 1. What did the models predict, and what happened?

Use the parameters estimated from the 2025 AAPL prices and the observed
2026 sale prices. Organize your answer into the following three parts.

**a. Report the model estimates.** Make a table with columns for the
parameter name, estimated value, and units. Include all six parameters:

- $u$: the daily up price factor in the lattice.
- $d$: the daily down price factor in the lattice.
- $p$: the probability of an up move in one trading day in the lattice.
- $\mu_g$: the mean growth rate in the GBM model.
- $\sigma$: the volatility parameter in the GBM model.
- $\mu$: the price drift in the GBM model.

**b. Compare the forecasts with the observed trades.** First state the
purchase price and the 63-day sale price needed to match the benchmark.
Then make a second table with one row for each holding period: 21, 63, and
126 trading days. Use these columns:

- Holding period in trading days.
- Lattice probability of beating the benchmark (%).
- GBM probability of beating the benchmark (%).
- Observed sale date in 2026.
- Observed sale price (USD/share).
- Observed scaled NPV (%).
- Did the observed trade beat the benchmark? (Yes or no.)

Each row compares two model probabilities with the same observed trade.

**c. Explain the benchmark rule and the outcomes.** In one short paragraph,
explain which sale prices count as beating the benchmark and how your code
handles a sale price that exactly matches it.

Then write one sentence for each holding period stating whether the observed
trade had the more likely outcome under each model. To identify that outcome,
compare each model's forecast probability with 50%: a value above 50% favors
beating the benchmark, a value below 50% favors not beating it, and a value
of exactly 50% favors neither outcome.

<!-- answer-1:start -->
TODO: Add the parameter table, purchase and benchmark prices, comparison table, and explanations for parts a–c.
<!-- answer-1:end -->

## 2. Why do the models give different probabilities?

Use your results from Question 1. Write one short paragraph for each part.

**a. Explain the difference between the models.** Why can the lattice and
the GBM model give different probabilities of beating the benchmark even
though both use the same 2025 prices? Refer to the lattice's two possible
daily growth rates and the normal distribution of growth rates in the GBM
model.

**b. Explain what the observed outcomes tell you.** If the models give similar
probabilities, does that show that their probabilities are accurate? If a
trade fails to beat the benchmark despite a forecast probability above 50%,
does that show that the forecast probability was wrong? Explain whether
these three observed trades are enough to establish which model gives more
accurate probabilities. Account for the fact that all three holding periods
start with the same purchase and share the same price history.

**c. Explain what both models leave out.** In L3a, unusually large positive
or negative growth rates occurred more often than a normal model predicts,
and large changes tended to follow other large changes. Explain how the
models' growth-rate distributions, fixed parameters, and independent daily
changes limit their ability to reproduce these two patterns.

<!-- answer-2:start -->
TODO: Write the three paragraphs for parts a–c.
<!-- answer-2:end -->

## 3. Can expected NPV be positive with less than a 50% chance of success?

Use the section of the checker's report labeled **Advanced Question 3:
separate example with assumed parameters**. This example uses the following
inputs in place of the parameters estimated from the AAPL prices:

| Input | Value |
|:--|:--|
| Price drift, $\mu$ | 0.08 per trading year |
| Volatility parameter, $\sigma$ | 0.30 per square root of a trading year |
| Benchmark rate, $g_y$ | 0.05 per trading year |
| Holding period | 63 trading days |

**a. Report the three results.** Calculate the mean growth rate using
$\mu_g=\mu-\sigma^2/2$ and show your substitution. Make a table with columns
for the quantity, value, and units. Include the mean growth rate, the 63-day
probability of beating the benchmark, and the 63-day expected scaled NPV.
Use the checker's separate example for the last two values.

**b. Explain why the results can occur together.** In one short paragraph,
explain why the expected scaled NPV can be positive even though the
probability of beating the benchmark is below 50%. Explain the roles of
$\mu$ and $\mu_g$ in the two calculations and how large gains in some
outcomes can affect the average.

**c. Explain what you would use to make a decision.** Would you use the
expected scaled NPV alone to decide whether to buy? Give your reason and
name one other piece of information you would want before deciding. You
do not need to calculate that extra quantity or write additional code.

<!-- answer-3:start -->
TODO: Add the mean-growth calculation, results table, and explanations for parts a–c.
<!-- answer-3:end -->
