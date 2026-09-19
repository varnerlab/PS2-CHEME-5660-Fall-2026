# Supplied price data

Both tracks use the same two AAPL files:

| File | Observations | Dates | Use |
|:--|--:|:--|:--|
| [AAPL-2025.csv](AAPL-2025.csv) | 250 | January 2–December 31, 2025 | Estimate the model parameters. |
| [AAPL-2026.csv](AAPL-2026.csv) | 170 | January 2–September 4, 2026 | Read the observed sale prices. |

Rows are ordered by date. Both files have these columns:

| Column | Meaning |
|:--|:--|
| `date` | Trading date, written as year-month-day |
| `ticker` | Stock symbol, AAPL |
| `price` | Daily average trade price in USD/share, weighted by share count |

The price is a volume-weighted average: each trade contributes in proportion
to its share count. The two files use the same definition.

Use the 250 prices from 2025 to estimate the model parameters from 249 daily
changes. Keep the estimates fixed when checking the 2026 outcomes. The
December 31, 2025 price is the assumed purchase price at day 0.

The first 2026 price observation, on January 2, is day 1. Use observations 21,
63, and 126 as the three sale prices. The header is not an observation.
Complete the observed-outcome function in your selected source file
([Standard](../src/Standard.jl) or [Advanced](../src/Advanced.jl)) to select
those observations and calculate the benchmark price, scaled NPV, and whether
the trade beat the benchmark. When you run
[check_submission.jl](../check_submission.jl), it automatically calls your
function for each holding period and displays the returned values in the
financial report.

The [assignment_terms](../src/Support.jl) function supplies the time step of
1/252 trading year and the benchmark rate of 5% per trading year, compounded
continuously. Advanced Question 3 uses separate assumed inputs, not the
observed 2026 outcomes.

## Data sources

The prices were copied from the course's Polygon.io snapshots without
changing their values. The course download requested prices adjusted for
stock splits. This exercise ignores dividend payments. The
[course data notes](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/code/src/data/MARKET-DATA.md)
describe the downloads.

The 2025 source is
[SP500-Daily-OHLC-1-2-2025-to-12-31-2025.jld2](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/code/src/data/SP500-Daily-OHLC-1-2-2025-to-12-31-2025.jld2).
Its SHA-256 value is:

```text
5526d1cb7eb458697723b756b98fcab2655bb8bfd6686d0e5ea0c65bf9938579
```

The 2026 source is
[SP500-Daily-OHLC-1-2-2026-to-09-04-2026.jld2](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/af75badf5789f497e747173ca2daf783627bc911/code/src/data/SP500-Daily-OHLC-1-2-2026-to-09-04-2026.jld2).
Its SHA-256 value is:

```text
805936bd2ea505020c8f30b860cddbe063a6430dc42189d4c81bb5b05b4e9492
```
