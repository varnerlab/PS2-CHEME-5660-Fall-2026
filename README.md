# Problem Set 2: What Is the Probability of Beating a Benchmark?

Suppose you buy [Apple (AAPL) shares](https://finance.yahoo.com/quote/AAPL)
and sell them after 63 trading days. What is the probability of beating a
benchmark that grows at 5% per trading year, compounded continuously?

Estimate the model parameters from **2025 prices**, then compare the forecasts
with **what happened in 2026**. Choose one track:

- **Standard:** Build a binomial lattice, which allows two possible price
  changes each day, and calculate the probability of beating the benchmark.
- **Advanced:** Complete the lattice calculation and repeat it with geometric
  Brownian motion (GBM). Compare the models' probabilities. Also examine a
  case where expected net present value (NPV) is positive, but the probability
  of beating the benchmark is below 50%.

This assignment covers weeks 3 and 4 of CHEME 4/5660. It uses the same Julia
version, course package, and submission process as PS1.

## Dates and grading

- **Release:** Sunday, September 20, 2026.
- **Due:** Sunday, October 4, 2026 at 11:59 PM ET. Upload your ZIP to Canvas.
- **Revisions:** Until December 19, 2026 at 11:59 PM ET after a qualifying
  initial submission. We keep your highest score, including across tracks.
- **Score:** Out of 4. An accepted Advanced score of 4 earns one Magic Point,
  once for PS2.

Submit a readable ZIP with attempted work by the initial deadline, even if
checks fail. A missing, empty, or unreadable submission receives a **Frozen
Zero** and cannot be revised for credit or earn a Magic Point. See
[RUBRIC.md](RUBRIC.md) for grading, revision, and independent-work rules.

## Getting started

Use Julia `1.12.7`. Both price files are supplied; you do not need to download
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
   the three Standard functions.
5. Complete the three Standard functions or five Advanced functions. Put
   helper functions in separate `.jl` files under [src](src). Load those
   files from [Include.jl](Include.jl); put all helper `include(...)` calls there.
6. Answer the three questions in your selected response file. Include the
   requested numbers, units, and explanations.
7. Run [check_submission.jl](check_submission.jl) as you work:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

Keep the supplied function names, arguments, return types, and docstrings.
Replace the starter errors with your code and remove completed TODOs. Document
each helper's purpose, inputs, and output. Keep the supplied lines in
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
give 249 daily changes. **Keep the model estimates fixed when checking 2026.**

Assume you buy at the December 31, 2025 price. This is **day 0**. Calculate
forecast probabilities for **21, 63, and 126 trading days**. January 2 is the first
price observation in the 2026 file, so it is day 1. Use the 21st, 63rd, and
126th observations as the sale prices. Count observations, not calendar days.

Assume you can trade at these prices. Ignore dividends, fees, taxes, and the bid-ask spread.

## Standard: build a lattice

Complete these functions. Their docstrings give the package calls and return
values. Use the [lecture examples](#lecture-examples) for the formulas.

| Function | Task |
|:--|:--|
| [estimate_lattice](src/Standard.jl) | Use the course package to estimate the daily up and down price factors and the probability of an up move. |
| [build_lattice](src/Standard.jl) | Use the package to build prices and probabilities from the purchase day through the sale day. |
| [lattice_probability](src/Standard.jl) | Calculate the probability of beating the benchmark on the sale day. |

For the Advanced track, use the copies in [src/Advanced.jl](src/Advanced.jl).
The checker runs all three holding periods and checks that node probabilities
sum to one, allowing small rounding differences.

## Advanced: repeat with GBM

Use the same 2025 prices, purchase price, holding periods, and benchmark.
Complete the three lattice functions and these two functions in
[src/Advanced.jl](src/Advanced.jl):

| Function | Task |
|:--|:--|
| [estimate_gbm](src/Advanced.jl) | Estimate the mean growth rate, volatility parameter, and price drift from the daily growth rates. |
| [gbm_probability](src/Advanced.jl) | Calculate the probability of beating the benchmark using the normal distribution. |

The report also computes the expected scaled NPV. In
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

Save your code and answers, then run the checker from Step 7. It prints
results, identifies missing answers and docstrings, and writes `MANIFEST.txt`
to record the files checked. It does not upload your work. Starter functions
fail the tests until you complete them; unfinished calculations show
`UNAVAILABLE`.

The checker saves these files when the calculations can run:

| File | Contents |
|:--|:--|
| `results/standard-results.csv` | Lattice forecasts and observed 2026 outcomes |
| `results/advanced-results.csv` | Both forecasts, expected scaled NPV, and observed outcomes |
| `results/terminal-nodes.csv` | Each 63-day lattice sale price, probability, and scaled NPV |

Each run replaces the generated results. An empty field means that a
calculation was unavailable. In the CSV files, 0.05 means 5% for probabilities
and scaled NPVs. The terminal prints percentages.

Before uploading:

1. Replace all three TODO answers in your selected response file. Keep the
   `<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers.
2. Create a ZIP of the entire PS2 folder, including your code, answers, data,
   project files, checker, tests, and generated `MANIFEST.txt`. If the checker
   cannot run, submit your attempted work without that record.
3. Name it `CHEME-5660-PS2-<your netid>.zip`. For NetID `abc123`, use
   `CHEME-5660-PS2-abc123.zip`. Upload it to the PS2 assignment on Canvas.

Submit attempted work by the initial deadline even if checks fail. For an
eligible revision, use **New Attempt** on the same Canvas assignment.
After you pass every test, the teaching team must review your code,
documentation, and answers before awarding a score of 4.
