# PS2 Standard questions

Complete [src/Standard.jl](../src/Standard.jl), then run
[check_submission.jl](../check_submission.jl). Use its printed financial
results to answer the questions, and explain your reasoning in your own
words. Replace each TODO with your answer, keeping the answer markers.

Report $u$ and $d$ as unitless price factors, prices in USD/share, and
probabilities and scaled NPVs as percentages. Four decimal places are enough.

## 1. Which sale prices beat the benchmark?

Use the lattice estimates from the 2025 AAPL prices and the report's results
for a sale after 63 trading days.

**a. Report the estimates and prices.** Make one table with columns for the
quantity, value, and units. Include these six quantities:

- The estimated daily up price factor, $u$.
- The estimated daily down price factor, $d$.
- The estimated probability of an up move in one trading day, $p$.
- The assumed purchase price on December 31, 2025.
- The 63-day sale price needed to match the benchmark, which grows at 5%
  per trading year, compounded continuously.
- The lattice probability of beating the benchmark after 63 trading days.

**b. Explain which sale prices count as success.** In one short paragraph,
answer both questions: Why can selling above the purchase price still give
a negative scaled NPV? Does a sale price that exactly matches the benchmark
count as success, and how does your code handle that case?

<!-- answer-1:start -->
TODO: Add the table and the explanation for parts a–b.
<!-- answer-1:end -->

## 2. Did the trade beat the benchmark in 2026?

Compare the lattice forecasts with the observed 2026 sale prices. All three
holding periods begin with the same purchase on December 31, 2025.

**a. Compare the forecasts with the observed trades.** Make a table with
one row for each holding period: 21, 63, and 126 trading days. Use these columns:

- Holding period in trading days.
- Lattice probability of beating the benchmark (%).
- Sale price needed to match the benchmark (USD/share).
- Observed sale date in 2026.
- Observed sale price (USD/share).
- Observed scaled NPV (%).
- Did the observed trade beat the benchmark? (Yes or no.)

**b. Interpret the observed outcomes.** In one short paragraph, identify
which holding periods beat the benchmark. For each holding period, state
whether the observed trade had the more likely outcome under the lattice
model. To identify that outcome, compare the forecast probability with 50%:
a value above 50% favors beating the benchmark, a value below 50% favors not
beating it, and a value of exactly 50% favors neither outcome. Explain why
three outcomes from this one price history are not enough to establish
whether the forecast probabilities are accurate.

**c. Explain the effect of the holding period.** In a second short paragraph,
identify which of the three holding periods has the highest forecast
probability of beating the benchmark. Explain how the holding period changes
both the possible sale prices and the price needed to match the benchmark.
Do these three results justify a claim that waiting longer always increases
the probability of beating the benchmark?

<!-- answer-2:start -->
TODO: Add the comparison table and the two paragraphs for parts a–c.
<!-- answer-2:end -->

## 3. What does the lattice leave out?

In L3a, we saw two patterns:

- Unusually large positive or negative growth rates occurred more often than
  a normal model predicts.
- Large changes tended to follow other large changes.

Write one short paragraph that addresses both patterns. Explain why the
lattice's two fixed daily growth rates limit its ability to represent
unusually large changes, and why independent daily moves cannot reproduce
the tendency for large changes to follow one another. How do these limits
affect your confidence in using the model's probability to decide whether
to buy? No extra code is needed.

<!-- answer-3:start -->
TODO: Explain the missing patterns and why they matter for this decision.
<!-- answer-3:end -->
