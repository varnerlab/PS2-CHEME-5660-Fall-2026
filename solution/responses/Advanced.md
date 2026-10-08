# PS2 Advanced questions: worked answers

These are the worked answers for the Advanced track, using the completed
[Advanced code](../src/Advanced.jl) and the report printed by the
[checker](../check_submission.jl). To get the same numbers, set
[TRACK.txt](../TRACK.txt) to `advanced` and run the checker as described in the
[solution guide](../README.md).

Each question is shown as it was assigned and is followed by its answer.
Prices are in USD/share, probabilities and scaled NPVs are percentages,
$\mu_g$ and $\mu$ are percentages per trading year, and $\sigma$ is a
percentage per square root of a trading year. Most values are rounded to four
decimal places, while $u$ and $d$ are shown with eight. Your answer can use
different words and still be correct, as long as it gives the same numbers and
reasoning.

## 1. What did the models predict, and what happened?

Use the financial report's model estimates, forecast probabilities, and
observed outcomes. The checker calls your functions with the 2025 AAPL prices
to estimate the models and the 2026 prices to calculate the observed outcomes.
Organize your answer into the following three parts.

**a. Report the model estimates.** Make a table with columns for the
parameter name, estimated value, and units. Include all six parameters:

- $u$: the daily up price factor in the lattice.
- $d$: the daily down price factor in the lattice.
- $p$: the probability of an up move in one trading day in the lattice.
- $\mu_g$: the mean growth rate in the GBM model.
- $\sigma$: the volatility parameter in the GBM model.
- $\mu$: the price drift in the GBM model.

**b. Compare the forecasts with the observed trades.** First state the
purchase price and report the sale price needed to match the benchmark for
the 63-day holding period only. Then make a second table with one row for
each holding period: 21, 63, and 126 trading days. Use these columns:

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
**a. Model estimates.**

| Parameter | Estimated value | Units |
|:--|--:|:--|
| Daily up price factor, $u$ | 1.01041898 | unitless |
| Daily down price factor, $d$ | 0.98852853 | unitless |
| Probability of an up move in one trading day, $p$ | 55.0201 | % |
| Mean growth rate, $\mu_g$ | 10.9686 | % per trading year |
| Volatility parameter, $\sigma$ | 26.4020 | % per square root of a trading year |
| Price drift, $\mu$ | 14.4540 | % per trading year |

**b. Forecasts and observed trades.** The purchase price on December 31,
2025, is 272.2992 USD/share, and the sale price needed to match the benchmark
after 63 trading days is 275.7243 USD/share.

| Holding period (trading days) | Lattice probability (%) | GBM probability (%) | Observed sale date | Observed sale price (USD/share) | Observed scaled NPV (%) | Beat the benchmark? |
|--:|--:|--:|:--|--:|--:|:--|
| 21 | 51.2433 | 52.6016 | February 2, 2026 | 266.5831 | -2.5063 | No |
| 63 | 61.7141 | 54.4998 | April 2, 2026 | 254.6924 | -7.6279 | No |
| 126 | 62.9059 | 56.3502 | July 6, 2026 | 312.0838 | 11.7809 | Yes |

**c. The benchmark rule and the outcomes.** Selling above the purchase price
is not enough, because the sale must also beat what the same money would have
earned in the benchmark. The scaled NPV, $\rho = (S_T/S_0)e^{-g_yT} - 1$, is
the sale price discounted at the benchmark rate, minus the purchase price,
divided by the purchase price. A sale beats the benchmark only when
$\rho > 0$, which means the sale price is above $S_0e^{g_yT}$, or about
275.7243 USD/share at 63 days.

- A sale between 272.2992 and 275.7243 USD/share makes money, but less than
  the benchmark would have made, so it gives $\rho < 0$.
- A sale at exactly the benchmark price gives $\rho = 0$, which is a tie, and
  a tie does not count as beating the benchmark.

The code uses strict tests: `lattice_probability` adds a node only when
`rho > 0.0`, and `observed_outcome` sets `beats_benchmark = (scaled_npv > 0.0)`.
When $\sigma > 0$, `gbm_probability` uses `ccdf(Normal(), z)`, which is the
probability of being strictly above `z`, and the chance that a GBM sale price
lands exactly on the benchmark price is zero. When $\sigma = 0$ and $\mu_g$
equals the benchmark, the code returns `0.0`.

Both models gave a probability above 50% at every holding period, so under
both models the more likely outcome was always to beat the benchmark:

- **21 days:** The lattice gave 51.2433% and GBM gave 52.6016%, but the trade
  lost to the benchmark with $\rho = -2.5063\%$, so the more likely outcome
  did not happen under either model.
- **63 days:** The lattice gave 61.7141% and GBM gave 54.4998%, but the trade
  lost to the benchmark with $\rho = -7.6279\%$, so the more likely outcome
  did not happen under either model.
- **126 days:** The lattice gave 62.9059% and GBM gave 56.3502%, and the trade
  beat the benchmark with $\rho = 11.7809\%$, so the more likely outcome
  happened under both models.
<!-- answer-1:end -->

## 2. Why do the models give different probabilities?

Use your results from Question 1 for parts a–c. Write one short paragraph
for each. Part d uses the report's separate benchmark comparison.

**a. Explain the difference between the models.** Why can the lattice and
the GBM model give different probabilities of beating the benchmark even
though both use the same 2025 prices? Refer to the lattice's two possible
daily growth rates, implied by the price factors $u$ and $d$, and the normal
distribution of growth rates in the GBM model.

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

**d. Lower the benchmark from 5% to 1%.** Keep the purchase price, 2025
parameter estimates, and 126-day holding period fixed. Change only the
continuously compounded benchmark rate, from 0.05 to 0.01 per trading year.

1. **Predict.** Before reading the comparison results, write one or two
   sentences predicting how the sale price needed to match the benchmark
   and each model's probability of beating it will change. Explain your
   reasoning. Keep this prediction even if you later revise your explanation.
2. **Read the calculation.** Run the same checker command and find
   **Question 2: benchmark comparison (5% to 1%)**. The supplied report calls
   your existing functions with both rates. You do not need to edit a rate,
   write another function, or run a different command. Copy its two rows
   into a table with the benchmark rate (% per trading year), sale price to
   match it (USD/share), lattice probability (%), successful lattice node
   count, and GBM probability (%). For each model, subtract the 5% row's
   probability from the 1% row's probability and report the change in
   **percentage points**. For example, a change from 50% to 55% is
   +5 percentage points.
3. **Explain.** Compare the results with your prediction in one short
   paragraph. Use the reported node counts to decide whether the lower
   benchmark added any lattice sale prices to the successful set. Explain
   how the lattice's discrete sale prices and the GBM model's continuous
   sale-price distribution account for the two probability changes.
   Why are the fitted parameters unchanged? Do not divide the successful
   node count by the total: the nodes need not be equally likely.

Your prediction need not be correct for full credit. We assess your initial
reasoning and your explanation of the calculated results. If you already
saw the comparison, say so and describe what you would have expected.

<!-- answer-2:start -->
**a. The difference between the models.** Both models start from the same
249 daily growth rates, but they keep different information from them:

- **The lattice** keeps only three numbers: how often the price went up
  ($p$), the average price factor on up days ($u$), and the average price
  factor on down days ($d$). The large real moves still affect these
  averages, but every model day is either a 1.04% rise or a 1.15% fall, so
  the real differences in the size of daily moves are lost.
- **GBM** uses the mean and standard deviation of all 249 growth rates, and
  it assumes that the growth rates follow a normal distribution.

We can compute the lattice's mean growth rate and volatility from $u$, $d$,
and $p$ using $[p\ln u + (1-p)\ln d]/\Delta t$ and
$\sqrt{p(1-p)}\,\ln(u/d)/\sqrt{\Delta t}$, and then compare them with GBM:

| Model | Mean growth rate (% per year) | Volatility (% per square root of a year) |
|:--|--:|--:|
| Lattice | 12.9325 | 17.2970 |
| GBM | 10.9686 | 26.4020 |

The lattice has a higher mean growth rate and a smaller volatility, and these
two differences explain most of why the lattice gives higher probabilities at
63 and 126 days. The lattice's fixed set of possible sale prices explains the
rest of the difference. At 21 days the
lattice is a little lower, because it has only 22 possible sale prices and
the benchmark price of 273.4361 USD/share falls in the gap between two of
them, 271.9286 and 277.9503 USD/share. A lattice trade must therefore reach
277.9503 USD/share to count as success.

**b. What the observed outcomes tell us.**

- **Similar probabilities do not prove that the models are right.** Both
  models use the same 2025 prices, and both assume that the parameters never
  change and that each day's change is independent of earlier changes. If 2026
  behaves differently from 2025, both models can be wrong in the same way.
- **One failure does not prove that a forecast was wrong.** At 63 days, the
  lattice gave failure a 38.2859% chance and GBM gave it a 45.5002% chance,
  so both models expected failures some of the time.
- **Three trades are not enough to pick the better model.** All three trades
  start with the same purchase and follow the same 2026 prices, and the
  126-day trade includes every price change in the shorter trades, so we
  really have one price history rather than three separate tests. To compare
  the models, we would need many more trades that start on different dates,
  and then we could check which model's probabilities better match how often
  the trades actually beat the benchmark.

**c. What both models leave out.** In L3a, we saw that large moves happen
more often than a normal distribution predicts (heavy tails) and that large
moves tend to come in groups (volatility clustering). Neither model
reproduces these two patterns:

- **Large moves.** The lattice cannot make a large one-day move at all,
  because every model day is +1.04% or -1.15%. GBM can make large moves, but
  its normal distribution makes them far too rare. On April 3, 2025, AAPL fell
  about 8.20% in one day, which is a log return of about $-8.55\%$. That log
  return is about 5.2 standard deviations below the mean daily log return, and
  under the fitted normal distribution a move at least this far from the
  mean, up or down, happens only about once in 4 million trading days.
- **Large moves in groups.** Both models use the same parameters every day
  ($u$, $d$, and $p$, or $\mu_g$ and $\sigma$), and each day's change is
  independent of earlier changes. A large move today therefore does not make
  a large move tomorrow more likely, so neither model makes large moves more
  likely after a period of large moves.

Because of these two gaps, both models can be wrong about how likely large
gains and large losses are.

**d. Lower the benchmark from 5% to 1%.**

1. **Example prediction.** With a lower benchmark, a lower sale price is
   enough to beat it, and neither model changes, so I expect both
   probabilities to go up. The GBM probability should go up smoothly, but the
   lattice probability will go up only if one of its sale prices lies between
   the old and new target prices.
2. **Calculation.** The checker's benchmark comparison gives these results:

   | Benchmark rate (% per trading year) | Sale price to match the benchmark (USD/share) | Lattice probability (%) | Successful lattice nodes | GBM probability (%) |
   |--:|--:|--:|:--|--:|
   | 5.00 | 279.1925 | 62.9059 | 59 of 127 | 56.3502 |
   | 1.00 | 273.6641 | 69.4252 | 60 of 127 | 60.5259 |

   The lattice probability changes by $69.4252\% - 62.9059\% =$
   **+6.5193 percentage points**, or +6.5192 if we use the unrounded values,
   and the GBM probability changes by $60.5259\% - 56.3502\% =$
   **+4.1757 percentage points**.
3. **Explanation.** Both probabilities went up, as predicted, for these
   reasons:
   - **The target price fell.** Over $T = 0.5$ years, the price needed to
     match the benchmark fell from 279.1925 to 273.6641 USD/share.
   - **The models did not change.** Both estimation functions use only the
     2025 prices with `risk_free_rate = 0.0`, so the benchmark is used only to
     decide which sale prices count as success.
   - **The lattice gained one sale price.** The number of successful nodes
     went from 59 to 60, and the new one is the sale price
     276.0641 USD/share, which lies between the two target prices. Its
     probability of 6.5192% is the whole increase. As the benchmark falls,
     the lattice probability goes up only when another sale price passes the
     target, so any benchmark between about 2.75% and 5% gives the same
     62.9059%.
   - **GBM increased smoothly.** A GBM sale price can take any positive
     value, so every price between 273.6641 and 279.1925 USD/share now counts
     as success, and the increase is the probability of landing in that range.
   - **The lattice increase is larger.** The newly successful lattice price
     carries 6.5192% probability, while GBM assigns only 4.1757% to the range
     between the two target prices. Part of the reason is that GBM spreads its
     probability over a wider range of prices, because its volatility is
     26.4020% compared with 17.2970% for the lattice.
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

The rate and volatility inputs above are decimal values. Use them as written
in your calculations, then report your results in the percentage units
specified at the top of this file.

**a. Report the three results.** First calculate the mean growth rate by hand
using $\mu_g=\mu-\sigma^2/2$ and show your substitution. Take the 63-day
probability of beating the benchmark and the 63-day expected scaled NPV from
the checker's separate example. That example calls your completed
[gbm_probability](../src/Advanced.jl) function and the supplied helper for the
expected scaled NPV. Then make a table with one row for each of these three
results and columns for the quantity, value, and units.

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
**a. Results.** First, we calculate the mean growth rate by hand:

$$
\mu_g = \mu - \frac{\sigma^2}{2} = 0.08 - \frac{(0.30)^2}{2} = 0.08 - 0.045 = 0.035\ \text{per trading year}.
$$

| Quantity | Value | Units |
|:--|--:|:--|
| Mean growth rate, $\mu_g$ | 3.5000 | % per trading year |
| Probability of beating the benchmark after 63 trading days | 49.0027 | % |
| Expected scaled NPV after 63 trading days | 0.7528 | % |

**b. Why the results can occur together.** The two results use different
parameters:

- **The probability uses $\mu_g$.** Under GBM, the median sale price is
  $S_0e^{\mu_gT}$, which means that half of the outcomes are above it and half
  are below it. Here $\mu_g = 3.5\%$ is below the 5% benchmark, so the median
  sale price is below the benchmark price, and the chance of beating the
  benchmark is just under 50%. With $T = 63/252 = 0.25$ years, we get
  $z = (0.05 - 0.035)\sqrt{0.25}/0.30 = 0.025$ and
  $P(Z > 0.025) = 49.0027\%$.
- **The expected NPV uses $\mu$.** The average sale price is $S_0e^{\mu T}$,
  and here $\mu = 8\%$ is above the 5% benchmark, so the expected scaled NPV
  is positive: $e^{(0.08 - 0.05)(0.25)} - 1 = 0.7528\%$.

The average is above the median because losses and gains are not balanced.
The price cannot fall below zero, so the scaled NPV cannot fall below
$-100\%$, but gains have no upper limit, and a few very large gains pull the
average up. The median scaled NPV is $-0.3743\%$ while the average is
$+0.7528\%$, so slightly more than half of the outcomes lose to the benchmark
even though the average outcome beats it. The gap between $\mu$ and $\mu_g$ is
$\sigma^2/2 = 4.5\%$ per year, so a higher volatility makes this gap larger.

**c. What I would use to make a decision.** I would not decide using the
expected scaled NPV alone, because the average describes many possible
outcomes, but I buy once and get only one outcome, which is slightly more
likely to lose to the benchmark than to beat it. The expected scaled NPV of
0.7528% is also small, while some possible losses are much larger: these
parameters give about a 24.9% chance that the scaled NPV is below $-10\%$.
Before deciding, I would want to know how large my possible losses are, how
likely they are, and whether I could afford them. I would also want to know
how sure we are of $\mu$ and $\sigma$, because in practice we estimate them
from data.
<!-- answer-3:end -->
