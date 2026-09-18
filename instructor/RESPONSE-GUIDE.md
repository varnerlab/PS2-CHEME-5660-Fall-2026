# PS2 expected results and answer guide

These notes are for the teaching team. Accept explanations in students' own
words when they give the required values and reasoning. Small displayed
rounding differences are acceptable. Code should use unrounded values.

## Shared results

The file contains 250 prices and 249 price changes. The assumed purchase
price is **272.2992 USD/share**. The benchmark grows at a continuously
compounded rate of 5% per year.

| Quantity | Result |
|:--|--:|
| Up factor, u | 1.01041898 |
| Down factor, d | 0.98852853 |
| Up probability, p | 55.0201% |
| GBM mean growth, mu_g | 10.9686% per year |
| GBM volatility, sigma | 26.4020% per square root of a year |
| GBM price drift, mu | 14.4540% per year |

The lattice replaces all observed increases with one average up factor and
all decreases with one average down factor. The GBM estimates use the full
set of daily growth rates. These operations need not give models with the
same mean growth or spread of future prices.

| Trading days | Sale price to match benchmark (USD/share) | Lattice P(positive NPV) | GBM P(positive NPV) | GBM average scaled NPV |
|--:|--:|--:|--:|--:|
| 21 | 273.4361 | 51.2433% | 52.6016% | 0.7909% |
| 63 | 275.7243 | 61.7141% | 54.4998% | 2.3916% |
| 126 | 279.1925 | 62.9059% | 56.3502% | 4.8405% |

The 2026 file is used only for the observed sale prices. Observation 1 is
January 2, 2026, the first trading day after the assumed purchase. The two
files use the same daily volume-weighted average price definition.

| Trading days | Observed sale date | Observed price (USD/share) | Observed scaled NPV | Beat benchmark? |
|--:|:--|--:|--:|:--|
| 21 | February 2, 2026 | 266.5831 | -2.5063% | No |
| 63 | April 2, 2026 | 254.6924 | -7.6279% | No |
| 126 | July 6, 2026 | 312.0838 | 11.7809% | Yes |

Both models assign a probability above 50% to beating the benchmark at all
three holding periods. That more likely outcome occurred only at 126 days.
A failure when the forecast probability exceeds 50% does not by itself show
that the probability was wrong. For example, a 60% forecast allows failure
40% of the time. The three outcomes share one purchase and overlapping price
changes. They do not provide three independent tests of forecast accuracy.

The 63-day tree has 64 sale-day nodes. The stored node probabilities sum to
one within rounding error. The package rounds node data to ten significant
digits; public checks allow this difference.

## Standard answers

**Question 1.** The scaled NPV is the discounted sale proceeds minus the
purchase cost, divided by the purchase cost. A price increase alone is not
enough because the benchmark also grows. At 63 days, a sale price must be
strictly above 275.7243 USD/share, using the unrounded value in the code.
Equality gives zero NPV and is excluded. The model assigns positive NPV a
probability of about 61.7141%.

**Question 2.** Use the forecast and observed-outcome tables above. The trade
beat the benchmark only at 126 days. This is also the only holding period
where the more likely outcome occurred. The outcomes describe this one price
history; many forecasts and outcomes are needed to judge probability accuracy.

The table shows that 126 days has the highest probability
among the three requested holding periods. Waiting changes both the
distribution of possible sale prices and the benchmark price. These three
results do not prove that the probability always increases. Other parameter
values can give different results, and the lattice's discrete sale prices
can produce jumps as the success cutoff changes.

**Question 3.** Two fixed daily factors allow only two daily growth rates,
so they cannot reproduce the observed frequency of extreme growth rates.
Independent moves with fixed probabilities do not produce periods in which
large daily growth changes become more likely after earlier large changes.
Thus the fitted model can misstate extreme-outcome risk and does not adjust
its uncertainty after a turbulent period. The calculated probability is a
result of the fitted model, not an observed future success rate.

## Advanced answers

**Question 1.** Use the estimates and comparison table above. The same
strict sale-day condition applies to both models. Advanced includes all
Standard calculations, so the lattice results must match. Include the observed
sale dates, prices, scaled NPVs, and success flags. Both models favored success
at all three holding periods, but success occurred only at 126 days.

**Question 2.** The lattice keeps two daily growth values; GBM allows a
continuous normal distribution of growth rates. The two estimation methods
summarize the same history differently. Their agreement would show that these
two fitted models give similar numbers, but would not show that either
predicts future outcomes accurately. Normal growth rates do not reproduce
the frequency of extreme growth seen in the data. Independent changes with
fixed volatility do not reproduce persistent periods of high or low volatility.
Under GBM, large changes remain possible; the issue is their frequency.

The two observed failures do not establish that either forecast probability
was wrong. Both models allowed failure. Students should distinguish whether
the more likely outcome occurred from whether the probabilities are accurate
over many forecasts. This one price history cannot establish which model
gives more accurate probabilities.

**Question 3.** For the separate assumed example, mean growth is:

$$
\mu_g=0.08-\frac{0.30^2}{2}=0.035\ \text{per year}.
$$

At 63 trading days, the probability of positive NPV is **49.0027%**, while
the average scaled NPV is **0.7528%**. The drift is above the benchmark,
so the expected discounted sale price exceeds the purchase price. Mean
growth is below the benchmark, so the probability of beating it is below
one half. Large gains in some outcomes raise the average enough to make it
positive. The mean and the probability answer different questions.

Do not require a particular yes/no trading recommendation. Require an
explanation of why the average alone omits relevant information. Examples
include the size of possible losses, the investor's ability to bear them,
and uncertainty in the fitted parameters. Students need not calculate those
extra quantities.
