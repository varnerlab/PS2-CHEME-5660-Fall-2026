# PS2 Reference Solution: What Is the Probability of Beating a Benchmark?

This archive contains completed code and worked discussion answers for both
tracks of CHEME 5660 Problem Set 2, Fall 2026. Use it to check your
calculations, understand mistakes, and debug your own work. The assignment's
independent-work and reference-solution policies still apply; see the
[original assignment](ASSIGNMENT.md) and [rubric](RUBRIC.md).

## Run the solution

This solution uses **Julia 1.12.7** and the same recorded package versions as
the student release.

1. Extract **CHEME-5660-PS2-Solution-2026.1.zip** and open the extracted
   folder in VS Code. Open a terminal in the folder containing
   [Project.toml](Project.toml).
2. Install the recorded package versions once:

   ```text
   julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
   ```

3. Set [TRACK.txt](TRACK.txt) to `standard` or `advanced`, then run the
   [checker](check_submission.jl):

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

The archive starts with `standard` selected. Standard passes **20/20** public
checks; Advanced passes **27/27**. To examine the other solution, change the
track and run the command again. Each run starts a new Julia process, which
matters because both track files define functions with the same names.

The checker also writes a submission record and prints its usual submission
steps. Those messages describe the student submission workflow; the worked
answers in this archive are reference material. Compare your own work with
the solution and make your own revisions before submitting.

## Read the code and answers

| Track | Completed code | Worked discussion answers |
|:--|:--|:--|
| Standard | [src/Standard.jl](src/Standard.jl) | [responses/Standard.md](responses/Standard.md) |
| Advanced | [src/Advanced.jl](src/Advanced.jl) | [responses/Advanced.md](responses/Advanced.md) |

The completed functions keep the supplied docstrings and use the calls from
the course examples:

| Function | Method | Course example |
|:--|:--|:--|
| `estimate_lattice` | `log_growth_matrix` with `risk_free_rate = 0.0`, then `RealWorldBinomialProbabilityMeasure` | [L3b lattice example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-3/L3b/CHEME-5660-L3b-LatticeModelSharePrice-RWPM-Example-Fall-2026.ipynb) |
| `build_lattice` | `build` with the fitted `(u, d, p)`, then `populate` from the purchase price | L3b lattice example |
| `lattice_probability` | Loop over the sale-day nodes and add the probabilities of nodes with scaled NPV strictly above zero | [L4a target-probability example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-4/L4a/CHEME-5660-L4a-Example-CumulativeProbabilityLattice-Fall-2026.ipynb) |
| `observed_outcome` | Select observation `days` in the 2026 file and apply the same scaled NPV rule | L4a NPV trade rule |
| `estimate_gbm` (Advanced) | Sample mean and standard deviation of the growth rates, then $\mu = \mu_g + \sigma^2/2$ | [L4b parameter example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-4/L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb) |
| `gbm_probability` (Advanced) | Standard normal probability above $z = (g_y - \mu_g)\sqrt{T}/\sigma$ | [L4b GBM NPV example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/lectures/week-4/L4b/CHEME-5660-L4b-Example-GBM-NPV-TradeRule-Fall-2026.ipynb) |

The Advanced file contains the same four lattice and observed-outcome
functions as the Standard file. The supplied [data reader and expected-NPV
helper](src/Support.jl), [report](reports/Finance.jl), public tests, and
checker are unchanged from the student release.

## Check the financial results

The checker prints the fitted parameters, the forecasts and observed trades
for 21, 63, and 126 trading days, and the 126-day benchmark comparison at 5%
and 1%. The Advanced report adds the GBM results and the separate example for
Advanced Question 3. The checker writes CSV files to a generated `results`
folder. Saved reference copies are included in
[reference-results](reference-results):

- [Standard results](reference-results/standard-results.csv) and
  [Advanced results](reference-results/advanced-results.csv): the forecasts
  and observed outcomes for each holding period.
- [Benchmark comparison](reference-results/benchmark-comparison.csv): the
  126-day forecasts at benchmark rates of 5% and 1%.
- [Terminal nodes](reference-results/terminal-nodes.csv): the 64 possible
  sale prices after 63 trading days, with their probabilities and scaled NPVs.

Both models favored beating the benchmark at all three holding periods, but
the observed trade beat it only at 126 days. The worked answers explain why
these three outcomes cannot establish whether either model's probabilities
are accurate. They also explain why lowering the benchmark from 5% to 1%
raises the lattice probability by one node's probability. In the Advanced
example, the expected scaled NPV is positive while the probability of
beating the benchmark is below 50%. The answers explain how both can be
true.
