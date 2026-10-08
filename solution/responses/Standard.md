# PS2 Standard questions: worked answers

These are the worked answers for the Standard track, using the completed
[Standard code](../src/Standard.jl) and the report printed by the
[checker](../check_submission.jl). To get the same numbers, set
[TRACK.txt](../TRACK.txt) to `standard` and run the checker as described in the
[solution guide](../README.md).

Each question is shown as it was assigned and is followed by its answer.
Prices are in USD/share, and probabilities and scaled NPVs are percentages
rounded to four decimal places. Your answer can use different words and still
be correct, as long as it gives the same numbers and reasoning.

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
**a. Estimates and prices.**

| Quantity | Value | Units |
|:--|--:|:--|
| Daily up price factor, $u$ | 1.01041898 | unitless |
| Daily down price factor, $d$ | 0.98852853 | unitless |
| Probability of an up move in one trading day, $p$ | 55.0201 | % |
| Purchase price on December 31, 2025, $S_0$ | 272.2992 | USD/share |
| Sale price needed to match the benchmark after 63 trading days | 275.7243 | USD/share |
| Lattice probability of beating the benchmark after 63 trading days | 61.7141 | % |

Each trading day, the lattice price either goes up by about 1.04% or goes
down by about 1.15%. In 2025, 137 of the 249 daily price changes were
increases, so the up probability is $p = 137/249$.

**b. Which sale prices count as success.** Selling above the purchase price
is not enough, because the sale must also beat what the same money would have
earned in the benchmark. The scaled NPV makes this comparison: it is the sale
price discounted at the benchmark rate, minus the purchase price, divided by the
purchase price.

$$
\rho = \left(\frac{S_T}{S_0}\right)e^{-g_yT} - 1.
$$

A 63-day sale has $T = 63/252 = 0.25$ years, and over that time the benchmark
grows the purchase price of 272.2992 USD/share to
$272.2992\,e^{0.05 \times 0.25} = 275.7243$ USD/share. This gives three cases
for the sale price:

- A sale above the benchmark price of about 275.7243 USD/share gives
  $\rho > 0$, so it beats the benchmark.
- A sale between 272.2992 and 275.7243 USD/share makes money, but less than
  the benchmark would have made, so it gives $\rho < 0$. For example,
  selling at 274.00 USD/share gains about 0.62%, but its scaled NPV is
  $-0.6254\%$.
- A sale at exactly the benchmark price gives $\rho = 0$, which ties the
  benchmark, and a tie does not count as beating it.

The code uses the strict tests `rho > 0.0` in `lattice_probability` and
`scaled_npv > 0.0` in `observed_outcome`, so a tie adds nothing to the
probability and returns `beats_benchmark = false`.
<!-- answer-1:end -->

## 2. What happened, and what changes with a lower benchmark?

Use the financial report's observed outcomes and lattice forecasts for
21, 63, and 126 trading days. The checker calls your `observed_outcome`
function for each holding period. All three holding periods begin with
the same purchase on December 31, 2025.

**a. Compare the forecasts with the observed trades.** Make a table with
one row for each holding period: 21, 63, and 126 trading days. Use these columns:

- Holding period in trading days.
- Lattice probability of beating the benchmark (%).
- Sale price needed to match the benchmark (USD/share).
- Observed sale date in 2026.
- Observed sale price (USD/share).
- Observed scaled NPV (%).
- Did the observed trade beat the benchmark? (Yes or no.)

**b. Interpret the observed outcomes.** In one paragraph, identify
which holding periods beat the benchmark. For each holding period, state
whether the observed trade had the more likely outcome under the lattice
model. To identify that outcome, compare the forecast probability with 50%:
a value above 50% favors beating the benchmark, a value below 50% favors not
beating it, and a value of exactly 50% favors neither outcome. Explain why
three outcomes from this one price history are not enough to establish
whether the forecast probabilities are accurate.

**c. Lower the benchmark from 5% to 1%.** Keep the purchase price, 2025
parameter estimates, and 126-day holding period fixed. Change only the
continuously compounded benchmark rate, from 0.05 to 0.01 per trading year.

1. **Predict.** Before reading the comparison results, write one or two
   sentences predicting how the sale price needed to match the benchmark
   and the probability of beating it will change. Explain your reasoning.
   Keep this prediction even if you later revise your explanation.
2. **Read the calculation.** Run the same checker command and find
   **Question 2: benchmark comparison (5% to 1%)**. The supplied report calls
   your existing functions with both rates. You do not need to edit a rate,
   write another function, or run a different command. Copy its two rows
   into a table with the benchmark rate (% per trading year), sale price to
   match it (USD/share), lattice probability (%), and successful lattice
   node count. Subtract the 5% row's probability from the 1% row's probability
   and report the change in **percentage points**. For example, a change
   from 50% to 55% is +5 percentage points.
3. **Explain.** Compare the results with your prediction in one short
   paragraph. The lattice allows only a fixed set of sale-day prices.
   Use the reported node counts to decide whether lowering the benchmark
   added any sale prices to the successful set. Explain how that affects
   the probability sum and why the benchmark change does not change the
   fitted price factors or node probabilities. Do not divide the successful
   node count by the total: the nodes need not be equally likely.

Your prediction need not be correct for full credit. We assess your initial
reasoning and your explanation of the calculated results. If you already
saw the comparison, say so and describe what you would have expected.

<!-- answer-2:start -->
**a. Forecasts and observed trades.**

| Holding period (trading days) | Lattice probability of beating the benchmark (%) | Sale price to match the benchmark (USD/share) | Observed sale date | Observed sale price (USD/share) | Observed scaled NPV (%) | Beat the benchmark? |
|--:|--:|--:|:--|--:|--:|:--|
| 21 | 51.2433 | 273.4361 | February 2, 2026 | 266.5831 | -2.5063 | No |
| 63 | 61.7141 | 275.7243 | April 2, 2026 | 254.6924 | -7.6279 | No |
| 126 | 62.9059 | 279.1925 | July 6, 2026 | 312.0838 | 11.7809 | Yes |

**b. Interpretation.** Only the 126-day trade beat the benchmark. Because the
lattice probability was above 50% at all three holding periods, the more
likely outcome was always to beat the benchmark:

- **21 days:** The forecast was 51.2433%, which is close to a coin flip, and
  the trade lost to the benchmark, so the more likely outcome did not happen.
- **63 days:** The forecast was 61.7141%, but the trade lost to the
  benchmark, so the more likely outcome did not happen.
- **126 days:** The forecast was 62.9059%, and the trade beat the benchmark,
  so the more likely outcome happened.

These three trades cannot tell us whether the probabilities are right, for
two reasons. First, one trade cannot show whether a probability is accurate,
because a 61.7141% chance of success still means a 38.2859% chance of failure,
so one failure does not prove the forecast wrong. Second, the three trades are
not separate tests, because they all start with the same purchase on
December 31, 2025, and follow the same 2026 prices. The 126-day trade includes
every price change in the 21-day and 63-day trades, so we really have only one
price history. To check the probabilities, we would need many more trades that
start on different dates, and then we could compare how often they beat the
benchmark with how often the model said they would.

**c. Lower the benchmark from 5% to 1%.**

1. **Example prediction.** With a lower benchmark, a lower sale price is
   enough to beat it, and the lattice itself does not change, so I expect the
   probability of beating the benchmark to go up or stay the same.
2. **Calculation.** The checker's benchmark comparison gives these results:

   | Benchmark rate (% per trading year) | Sale price to match the benchmark (USD/share) | Lattice probability (%) | Successful lattice nodes |
   |--:|--:|--:|:--|
   | 5.00 | 279.1925 | 62.9059 | 59 of 127 |
   | 1.00 | 273.6641 | 69.4252 | 60 of 127 |

   The change is $69.4252\% - 62.9059\% =$ **+6.5193 percentage points**, or
   +6.5192 percentage points if we use the unrounded probabilities.
3. **Explanation.** The probability went up, as predicted, for these reasons:
   - **The target price fell.** Over $T = 126/252 = 0.5$ years, the price
     needed to match the benchmark fell from
     $272.2992\,e^{0.05 \times 0.5} = 279.1925$ to
     $272.2992\,e^{0.01 \times 0.5} = 273.6641$ USD/share.
   - **The lattice did not change.** Its sale prices come from $S_0$, $u$,
     $d$, and the number of days, and its node probabilities come from $p$
     and the number of paths to each node, so none of them depend on the
     benchmark. Among the lattice functions, only `lattice_probability` uses
     the benchmark, and it uses it only to decide which sale prices count as
     success.
   - **One more sale price counts as success.** The number of successful
     nodes went from 59 to 60, and the new one is the sale price
     276.0641 USD/share, which lies between the new target of 273.6641 and
     the old target of 279.1925. Its probability of 6.5192% is the whole
     increase.
   - **The increase is large because the node is near the middle.** The most
     likely nodes are in the middle of the lattice, each with a probability of
     about 7%. Because the nodes are not equally likely, we add the node
     probabilities instead of dividing 60 by 127.
   - **The lattice probability changes in jumps.** As the benchmark falls, the
     lattice probability goes up only when another sale price passes the
     target, so any benchmark between about 2.75% and 5% gives the same
     62.9059%.
<!-- answer-2:end -->

## 3. What does the lattice leave out?

In L3a, we saw two patterns:

- Unusually large positive or negative growth rates occurred more often than
  a normal model predicts.
- Large changes tended to follow other large changes.

Write one short paragraph that addresses both patterns. Explain why the two
fixed daily growth rates implied by the lattice's price factors, $u$ and $d$,
limit its ability to represent unusually large changes, and why independent
daily moves cannot reproduce the tendency for large changes to follow one
another. How do these limits affect your confidence in using the model's
probability to decide whether to buy? No extra code is needed.

<!-- answer-3:start -->
The lattice misses both of the patterns that we saw in L3a.

**1. It cannot make large daily moves.** Each day, the lattice price either
goes up 1.04% (the factor $u$) or goes down 1.15% (the factor $d$), and
nothing else can happen. Real prices sometimes jump much more: in 2025, AAPL
rose about 5.56% on May 12 and fell about 8.20% on April 3. Heavy tails means
that large moves like these happen more often than a normal distribution
predicts, and the lattice cannot make a move like that in a single day.

**2. The daily moves never change.** The lattice uses the same $u$, $d$, and
$p$ every day, and each day's change is independent of earlier changes, so a
large move today does not make a large move tomorrow more likely. Real prices
behave differently, because large moves tend to come in groups, like the
swings in April 2025. This pattern is called volatility clustering, and the
lattice cannot reproduce it because it never makes large moves more likely
after a period of large moves.

**What this means for the decision.** The 61.7141% probability comes from a
model that leaves out both patterns, so it is not a measured success rate,
and the real chance could be higher or lower. The model may also understate
the chance of a large loss, so I would not buy based on this number alone,
and I would also look at how much money I could lose.
<!-- answer-3:end -->
