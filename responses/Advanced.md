# PS2 Advanced questions

Complete [src/Advanced.jl](../src/Advanced.jl) and answer these three questions.
You do not need the Standard response file.

Use the checker's results and your own words. Replace the TODOs, keeping the
answer markers. Report prices in USD/share, probabilities and scaled NPVs as
percentages, and estimates with their units. Four decimal places are enough.

## 1. What did the models predict, and what happened?

Report:

- A table of $u$, $d$, $p$, $\mu_g$, $\sigma$, and $\mu$.
- A table for 21, 63, and 126 trading days showing both forecast probabilities,
  observed sale date and price, observed scaled NPV, and whether the trade
  beat the benchmark.
- The purchase price and the 63-day price needed to match the benchmark.

In one short paragraph, explain which prices count as success, including
equality and how your code handles it. For each holding period, did the more
likely outcome occur under each model?

<!-- answer-1:start -->
TODO: Add the results and explain the success rule and observed outcomes.
<!-- answer-1:end -->

## 2. Why do the models give different probabilities?

Write two short paragraphs:

- **Model comparison:** Explain why the models can give different probabilities.
  Refer to the lattice's two growth rates and the GBM normal distribution.
  Does agreement between models show accuracy? Do the observed failures show
  the probabilities were wrong? Can these outcomes establish which model is
  more accurate? All three sale dates share a purchase and price history.
- **Missing patterns:** In L3a, unusually large growth rates occurred more
  often than a normal model predicts, and large changes tended to follow
  other large changes. Why do fixed parameters and independent changes keep
  both models from reproducing these patterns?

<!-- answer-2:start -->
TODO: Explain the model comparison and the missing patterns.
<!-- answer-2:end -->

## 3. Can expected NPV be positive with less than a 50% chance of success?

Use the report's separate example, with these assumed inputs:

| Input | Value |
|:--|:--|
| Price drift, $\mu$ | 0.08 per year |
| Volatility, $\sigma$ | 0.30 per square root of a year |
| Benchmark, $g_y$ | 0.05 per year |
| Holding period | 63 trading days |

Calculate $\mu_g=\mu-\sigma^2/2$. Make a table with this mean growth rate,
probability of beating the benchmark, and expected scaled NPV. Use the
checker for the last two values. These inputs are separate from the AAPL
estimates.

In one short paragraph, explain why expected NPV uses $\mu$ while the
probability uses $\mu_g$. How can large gains raise the average when the
chance of beating the benchmark is below 50%? Would you use expected NPV
alone to decide whether to buy? What else would you want to know?

<!-- answer-3:start -->
TODO: Add the table and explain what expected NPV and probability tell you.
<!-- answer-3:end -->
