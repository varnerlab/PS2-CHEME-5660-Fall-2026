# PS2 build and review record

Reviewed September 18, 2026.

## Assignment choices

- Release: September 20, 2026.
- Initial deadline: October 4, 2026 at 11:59 PM ET.
- Standard: three functions for lattice estimates, construction, and the
  probability of positive scaled NPV.
- Advanced: the same work plus two GBM functions and a comparison of average
  NPV with the probability of positive NPV.
- Both tracks: the same 250 AAPL prices from 2025, a 5% continuous annual
  benchmark, and holding periods of 21, 63, and 126 trading days. Compare
  those forecasts with observed sale prices from the 2026 file.
- Grading and revision rules: the PS1 structure, with 15 Standard checks and
  22 Advanced checks.

## Prose and documentation review

A separate prose pass reviewed the README, rubric, questions, data notes,
instructor notes, function docstrings, comments, TODOs, and report messages.
The review checked whether each instruction names an action, whether symbols
and units are defined, and whether a student can tell what to return.

The pass clarified several points:

- The benchmark rate is continuously compounded.
- Daily growth rates come from consecutive prices; 250 prices give 249 changes.
- A fixed daily move means a fixed percentage change, not a fixed dollar change.
- The benchmark is applied when calculating NPV, not when estimating price moves.
- Equality does not count as positive NPV.
- The scheduled sale price determines success, even if prices were higher earlier.
- Large growth changes remain possible under GBM. The model's limitation is
  their frequency compared with observations, not their possibility.
- The probability uses mean growth; average NPV uses price drift.

All named functions in the authored Julia and Python files have docstrings.
Student docstrings identify inputs, units, steps, and outputs. TODOs use direct
instructions and refer to the formulas immediately above them. The reference
solutions keep the same function documentation as the student files.

## Numerical and submission checks

The full release check passed with Julia 1.12.7:

| Check | Result |
|:--|:--|
| Untouched Standard starter | 0/15; feedback and submission record written |
| Untouched Advanced starter | 0/22; feedback and submission record written |
| Standard reference | 15/15 |
| Advanced reference | 22/22 |
| Passing Standard code with missing documentation and an unfinished answer | 15/15; names the function and question; still requires completion review |
| Standard with unfinished estimation | 10/15; later tasks retain credit |
| Source syntax error | 0/15; error and submission record written |
| Invalid track | Clear error and submission record written |
| Old generated results after a source error | Removed before the new check |
| Independent Python calculation | Agrees for all three holding periods |
| Observed 2026 dates, prices, and scaled NPVs | Agree with independent Python calculations |
| Change only 2026 prices | Observed outcomes change; forecasts and exported lattice stay unchanged |
| Exported 63-day lattice | 64 nodes; probabilities and success flags agree |
| Score boundaries | Verified for every pass count in both tracks |

Package setup with `Pkg.instantiate()` succeeded using the available local
package cache. A download into an empty package cache was not tested. The
manifest has no machine-specific package paths. Local links were checked;
the linked lecture files exist at their recorded Git commit.

The student ZIP uses an explicit file list. It contains both unfinished
tracks and all three unanswered prompts for each track. Completed solutions,
answer notes, and instructor test logs are excluded.

## Style revision using the 4800/5800 assignment

The revision applies the comparison in [STYLE-COMPARISON.md](STYLE-COMPARISON.md)
across the README, questions, rubric, data notes, Julia docstrings, TODOs,
checker messages, and printed results.

- The README explains growth rates before listing the functions that use them.
  A 100 USD purchase-and-sale example explains why a price gain can fall short
  of the benchmark.
- The questions separate tables of results from short explanations.
- Docstrings use consistent sections for arguments, returns, methods, and
  errors where needed. Student TODOs are numbered and name the required work.
- Checker messages identify the unfinished question or missing docstring.
  Report messages state what the probability means and label probability sums
  as checks.
- Data notes put the columns and their use before the source details.

A second, sentence-by-sentence pass reviewed the saved student prose,
docstrings, comments, TODOs, test labels, and printed messages. It checked
for concrete instructions, defined terms and units, and agreement between
the instructions and code. Reference solutions use the revised docstrings.

The style revision passed checks for all eight submission states. Separate feedback
checks passed: 16 for answers, 3 for docstrings, and 117 for grading thresholds.
The public check counts and grading rules remain 15 for Standard and 22 for
Advanced. That revision left the model calculations and supplied data unchanged.

## Compare with observed 2026 prices

Both tracks now compare the 21-day, 63-day, and 126-day forecasts with the
observed sale dates and prices. The new file contains 170 AAPL observations
from January 2 through September 4, 2026, copied from the course snapshot.
The data notes record the source and its SHA-256 value.

Model estimation still uses only the 250 prices from 2025. The assumed
purchase is at the final 2025 price. Observation 1 in the 2026 file is the
first trading day after purchase. The sale dates are February 2, April 2,
and July 6, 2026. The observed scaled NPVs are -2.5063%, -7.6279%, and
11.7809%; only the 126-day trade beats the benchmark.

The response questions distinguish whether the more likely outcome occurred
from whether a probability forecast is accurate. They also explain that the
three holding periods share a purchase and price history. The README,
questions, data notes, rubric, report messages, and new documentation received
a separate plain-language review after editing.

All nine release cases pass. The completed solutions remain at 15/15 for
Standard and 22/22 for Advanced. Independent Python calculations confirm the
forecast probabilities, sale dates, observed prices, and scaled NPVs. A test
that raises every 2026 price by 50% changes the observed results while leaving
all forecast columns and the exported lattice unchanged. The student ZIP
contains both data files and excludes the completed solutions and test logs.

## Student readability pass

The README is about 31% shorter and the rubric about 20% shorter. The response
files and data notes are also shorter. The revision removes repeated setup,
grading, and reporting instructions; the rubric now holds the full
independent-work rules. Question prompts group the requested explanations,
and shorter docstrings retain the package calls, units, formulas, and edge cases.

The final text received a separate sentence-by-sentence review. The seven
numbered setup steps, helper-file rule, dates, grading thresholds, equations,
and comparisons with 2026 outcomes remain explicit. Markdown parsing confirms
the numbered lists and tables are retained. Executable Julia code and both
price files are unchanged. The revised references pass 15/15 Standard and
22/22 Advanced checks; independent Python calculations still agree with the
forecasts and observed outcomes. The student ZIP was rebuilt and checked
against all 20 release files.
