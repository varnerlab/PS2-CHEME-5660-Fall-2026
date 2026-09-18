# PS2 Standard questions

Use the checker's results and explain them in your own words. Replace the
three TODOs, keeping the answer markers. Report prices in USD/share and
probabilities and scaled NPVs as percentages. Four decimal places are enough.

## 1. Which sale prices beat the benchmark?

Report a table with:

- The estimates of $u$, $d$, and $p$.
- The assumed purchase price.
- The 63-day price needed to match the 5% benchmark.
- The 63-day probability of beating it.

In one short paragraph, explain why a price gain can still give negative
scaled NPV. Does equality with the benchmark count as success? Explain
how your code handles it.

<!-- answer-1:start -->
TODO: Add the table and explain which sale prices count as success.
<!-- answer-1:end -->

## 2. Did the trade beat the benchmark in 2026?

Make a table for 21, 63, and 126 trading days with:

- The forecast probability of beating the benchmark.
- The price needed to match it.
- The observed sale date and price.
- The observed scaled NPV and whether it is positive.

Write two short paragraphs:

- **Outcomes:** Which holding periods beat the benchmark? Did the more likely
  outcome occur in each case? Explain why one price history, shared by all
  three sale dates, cannot establish whether the probabilities are accurate.
- **Holding period:** Which had the highest forecast probability? Explain
  how waiting changes both possible sale prices and the benchmark price.
  Does this show that waiting longer always raises the probability of success?

<!-- answer-2:start -->
TODO: Add the comparison table and the two explanations.
<!-- answer-2:end -->

## 3. What does the lattice leave out?

In L3a, we saw two patterns:

- Unusually large positive or negative growth rates occurred more often than
  a normal model predicts.
- Large changes tended to follow other large changes.

In one short paragraph, explain why two fixed daily growth rates and
independent moves cannot reproduce these patterns. Why does that matter
when using the probability to decide whether to buy? No extra code is needed.

<!-- answer-3:start -->
TODO: Explain the missing patterns and why they matter for this decision.
<!-- answer-3:end -->
