# Problem Set 2 (PS2): What Is the Probability of Beating a Benchmark?

Suppose you buy [Apple (AAPL) shares](https://finance.yahoo.com/quote/AAPL)
and sell them after a chosen number of trading days. What is the probability
of beating an alternative benchmark investment that grows at 5% per trading
year (252 trading days), compounded continuously?
Let's explore this question.

Choose one track:

- **Standard:** Build a binomial lattice, which allows two possible price
  changes each day, and calculate the probability of beating the benchmark
  on the sale day.
- **Advanced:** Complete the same binomial lattice calculation in the
  Advanced source file, then repeat the probability calculation using a
  geometric Brownian motion (GBM) model. Compare the binomial and GBM models'
  probabilities. Also examine a case where the expected scaled net present
  value (NPV) is positive, but the probability of beating the benchmark is
  below 50%.

__Parameters__: Estimate your model parameters from **2025 prices**, then
compare the forecasts with **what happened in 2026**. Calculate the observed
trade outcomes in your own code using the supplied 2026 prices.
Both tracks also compare the 126-day forecast at benchmark rates of 5% and
1%. The supplied report runs this comparison using your existing functions.

__Lectures__: This problem set covers weeks 3 and 4 of CHEME 4/5660. It uses
the same Julia version, course package, and submission process as PS1.

## Dates and grading

- **Release:** Sunday, September 20, 2026.
- **Due:** Sunday, October 4, 2026 at 11:59 PM ET. Upload your ZIP to Canvas.
- **Revisions:** Until December 19, 2026 at 11:59 PM ET after a qualifying
  initial submission. We keep your highest score, even if you change tracks.
- **Score:** Out of 4. An Advanced score of 4, confirmed by the teaching
  team, also earns one Magic Point.

Submit a readable ZIP with attempted work by the initial deadline, even if
checks fail. A missing, empty, or unreadable submission receives a **Frozen
Zero** and cannot be revised for credit or earn a Magic Point.

See the [grading rubric](RUBRIC.md) for grading, revision, and independent-work rules.

## Getting started

Use Julia `1.12.7`. Both price files are supplied; you do not need to download any
market data.

1. Download the `Source code (zip)` archive from the tagged
   [PS2 GitHub release](https://github.com/varnerlab/PS2-CHEME-5660-Fall-2026/releases/tag/ps2-cheme-5660-2026.1)
   and extract it.
2. In VS Code, open the extracted folder containing
   [Project.toml](Project.toml), [README.md](README.md), and
   [check_submission.jl](check_submission.jl). Open a terminal there and run
   all commands from that folder.
3. Install the recorded package versions. This requires an internet connection
   and may take several minutes:

   ```text
   julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
   ```

4. Set [TRACK.txt](TRACK.txt) to exactly `standard` or `advanced`:

   | Track | Code to complete | Questions to answer |
   |:--|:--|:--|
   | Standard | [src/Standard.jl](src/Standard.jl) | [responses/Standard.md](responses/Standard.md) |
   | Advanced | [src/Advanced.jl](src/Advanced.jl) | [responses/Advanced.md](responses/Advanced.md) |

   Complete only your selected track. Advanced includes its own copies of
   the four Standard functions. Leave the other track's source and response
   files unchanged; their TODOs do not affect your grade.
5. Complete the four Standard functions or six Advanced functions. Each
   function must return the values specified in its docstring. Put any helper
   functions you write in separate `.jl` files under [src](src). For example,
   you could create `src/MyHelperFunctions.jl`. Load your helper files from
   [Include.jl](Include.jl), using the commented example with your own filenames.
   Put all helper `include(...)` calls there.
6. Before reading the benchmark-comparison results, write the short prediction
   requested in Question 2 of your selected response file (Standard part c;
   Advanced part d). Then save your code and run the [check_submission.jl](check_submission.jl)
   script from the root PS2 folder:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   This script loads [Include.jl](Include.jl), which reads
   [TRACK.txt](TRACK.txt) and loads your selected source file, helpers,
   report, and tests. The checker prints the source file it loaded, then
   runs the tests. It calls your functions with the supplied data
   and **automatically prints the financial report**. After the test results,
   look for **PS2 financial results** in the terminal. You do not need to call
   a report function or run a separate report script.

   The report places the three holding periods side by side in a table.
   Units appear in the labels or beside each table. If checks fail, numbers
   in brackets point to the grouped messages under **Check details**.
   Missing financial results appear as `UNAVAILABLE`; their causes are
   listed under **Unavailable calculations**.

   For both tracks, the checker runs the calculations for 21, 63, and 126
   trading days and checks that the lattice's sale-day probabilities sum
   to one, allowing small rounding differences.

   It also prints **Question 2: benchmark comparison (5% to 1%)**. This
   table uses the same fitted parameters and 126-day holding period with
   two benchmark rates. Follow the prediction, calculation, and explanation
   steps in your response file. The report supplies the function calls;
   no additional Julia code or command is needed.

   Run the checker as you work; you do not need to finish all functions or
   answers first. Unfinished calculations are shown as `UNAVAILABLE`. Fix
   errors in your code, save it, and run the same command again to update
   the results.
7. Use the financial results to answer the three questions in your selected
   response file. Include the requested numbers, units, and explanations.
   Save your answers and run the same checker command again before submitting.

Keep the supplied function names, arguments, return types, and docstrings.
Replace the starter errors with your code. Delete each TODO comment once
you finish that part.

If you write any custom helper functions, document each helper's purpose,
inputs, and output. Keep the supplied lines in
[Include.jl](Include.jl) when adding helper files. Leave the other support
code, data, reports, tests, and checker unchanged.

## The investment and its benchmark

The two price files have different roles:

| File | Dates | Use |
|:--|:--|:--|
| [AAPL-2025.csv](data/AAPL-2025.csv) | January 2–December 31, 2025 | Estimate the model parameters from all 250 prices. |
| [AAPL-2026.csv](data/AAPL-2026.csv) | January 2–September 4, 2026 | Read the observed sale prices. |

Each price is a daily average weighted by the shares in each trade. The
[data notes](data/README.md) describe the sources. The 250 prices from 2025
give 249 daily changes. Use 252 trading days per year for time and rate
conversions, even though this file contains 250 prices.
**Use the 2025 parameter estimates for all three
forecasts; do not re-estimate the parameters using 2026 prices.**

Assume you buy at the December 31, 2025 price, the last price in
[AAPL-2025.csv](data/AAPL-2025.csv). This is **day 0**. Calculate forecast
probabilities for **21, 63, and 126 trading days**. January 2 is the first
price observation in the 2026 file, so it is day 1. Read the sale date and
price from the 21st, 63rd, and 126th observations. Count observations, not
calendar days.

Assume you can trade at these supplied prices. Ignore dividends, fees,
taxes, and the bid-ask spread.

The **scaled NPV**, $\rho$, is the sale proceeds discounted at the benchmark
rate, minus the purchase cost, all divided by the purchase cost. The function
docstrings give the formula.

The report's **Sale price to match the benchmark** is the sale price at which
$\rho = 0$. It is the purchase price $S_0$ grown at the continuously compounded
benchmark rate $g_y = 0.05$ per trading year. For a holding time of
$T = \text{trading days}/252$ years, this price is given by:

$$
S_{\text{benchmark}} = S_0 e^{g_y T}.
$$

A sale price above this threshold gives $\rho > 0$ and beats the benchmark;
a price below it gives $\rho < 0$. Selling exactly at the threshold matches
the benchmark and does not count as beating it.

## Standard: build a lattice and calculate the observed outcomes

In the Standard track, you will use a binomial lattice model to calculate
the probability of each possible sale-day price. From these probabilities,
you can calculate the probability of beating the benchmark. The lattice is
built from the purchase price, the estimated up and down factors, and the
probability of an up move.

Complete the following functions. Their docstrings give the package calls
and return values. Use the [lecture examples](#lecture-examples) for the formulas.

| Function | Task |
|:--|:--|
| [estimate_lattice](src/Standard.jl) | Use the course package to estimate the daily up and down price factors and the probability of an up move. |
| [build_lattice](src/Standard.jl) | Use the package to build prices and probabilities from the purchase day through the sale day. |
| [lattice_probability](src/Standard.jl) | Calculate the probability of beating the benchmark on the sale day. |
| [observed_outcome](src/Standard.jl) | Select the observed sale date and price, calculate the benchmark price and scaled NPV, and determine whether the trade beat the benchmark. |

For the Advanced track, use the copies in [src/Advanced.jl](src/Advanced.jl).

When you run [check_submission.jl](check_submission.jl), its financial report
displays the values your functions return. If
[observed_outcome](src/Standard.jl) is unfinished, the observed results and
benchmark prices remain unavailable, even when the forecast functions work.

## Advanced: repeat with geometric Brownian motion (GBM)

In the Advanced track, you will also use a geometric Brownian motion (GBM)
model to calculate the probability of beating the benchmark. Use the same
2025 prices, purchase price, holding periods, and benchmark for both models.

Complete the three lattice functions, the observed-outcome function, and
these two additional functions in [src/Advanced.jl](src/Advanced.jl):

| Function | Task |
|:--|:--|
| [estimate_gbm](src/Advanced.jl) | Estimate the mean growth rate, volatility parameter, and price drift from the daily growth rates. |
| [gbm_probability](src/Advanced.jl) | Calculate the probability of beating the benchmark using the normal distribution. |

For the Advanced track, the report uses a [supplied helper](src/Support.jl)
to compute the expected scaled NPV under the GBM model. In
[Advanced Question 3](responses/Advanced.md#3-can-expected-npv-be-positive-with-less-than-a-50-chance-of-success),
explain how this value can be positive when the probability of beating the
benchmark is below 50%.

## Lecture examples

Use these course examples for the formulas and function calls:

- [L3b: estimate and build a lattice](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-3/L3b/CHEME-5660-L3b-LatticeModelSharePrice-RWPM-Example-Fall-2026.ipynb).
- [L4a: calculate a sale-day target probability](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-4/L4a/CHEME-5660-L4a-Example-CumulativeProbabilityLattice-Fall-2026.ipynb).
- [L4b: estimate GBM parameters](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-4/L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb).
- [L4b: apply the GBM NPV rule](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-4/L4b/CHEME-5660-L4b-Example-GBM-NPV-TradeRule-Fall-2026.ipynb).

## Check and submit your work

Save your code and answers, then rerun the checker command from Step 6. The
same command runs the tests, generates the financial report, identifies
missing answers and docstrings, and writes `MANIFEST.txt` to record the files
checked. It __does not__ upload your work.

Starter functions fail the tests until you complete them; unfinished
calculations show `UNAVAILABLE`.

The checker saves one main results file for your selected track and a
benchmark comparison. It also saves the 63-day lattice nodes when available:

| File | Contents |
|:--|:--|
| `results/standard-results.csv` | Your lattice forecasts and observed-outcome calculations |
| `results/advanced-results.csv` | Your forecasts and observed-outcome calculations, plus expected scaled NPV |
| `results/benchmark-comparison.csv` | The 126-day comparison at 5% and 1%, including successful lattice node counts |
| `results/terminal-nodes.csv` | Each 63-day lattice sale price, probability, and scaled NPV |

Each run replaces the generated results. In the CSV files, an unavailable
calculation leaves an empty field. The report displays the observed outcomes
returned by your code; it does not calculate them for you. Probabilities and
scaled NPVs are decimal fractions in the CSV files: 0.05 means 5%. The
terminal prints percentages.
The main results files, exported lattice nodes, and Advanced Question 3 use
the original 5% benchmark. Only the benchmark-comparison table uses both rates.

Before uploading:

1. Replace all three TODO answers in your selected response file. Put all
   parts of each answer between its matching `<!-- answer-N:start -->` and
   `<!-- answer-N:end -->` markers, keeping the supplied question numbers.
   The markers are visible in the Markdown source editor but hidden in the
   rendered preview.
2. Create a ZIP of the entire PS2 folder, including your code, answers, data,
   project files, checker, tests, and generated `MANIFEST.txt`. If the checker
   cannot run, submit your attempted work without that record.
3. Name it `CHEME-5660-PS2-<your netid>.zip`. For NetID `abc123`, use
   `CHEME-5660-PS2-abc123.zip`. Upload it to the PS2 assignment on Canvas.

Submit attempted work by the initial deadline even if checks fail. For an
eligible revision, use **New Attempt** on the same Canvas assignment.
After you pass every test, the teaching team must review your code,
documentation, and answers before awarding a score of 4.
The team may award 3 for otherwise complete work with a minor, localized
coding error, as described in the [rubric](RUBRIC.md).
