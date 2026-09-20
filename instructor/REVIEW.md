# PS2 build and review record

Reviewed September 18, 2026.

## Assignment choices

- Release: September 20, 2026.
- Initial deadline: October 4, 2026 at 11:59 PM ET.
- Standard: four functions for lattice estimates, construction, the
  probability of positive scaled NPV, and the observed 2026 trade outcome.
- Advanced: the same work plus two GBM functions and a comparison of average
  NPV with the probability of positive NPV.
- Both tracks: the same 250 AAPL prices from 2025, a 5% continuous annual
  benchmark, and holding periods of 21, 63, and 126 trading days. Compare
  those forecasts with observed sale prices from the 2026 file.
- Grading and revision rules: the PS1 structure, with 20 Standard checks and
  27 Advanced checks. The sections below are a chronological log; counts of
  15 and 22 in earlier sections predate the observed-outcome checks.

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
first trading day after purchase. The observed sale dates and scaled NPVs
are recorded in the local [answer guide](../solution/RESPONSE-GUIDE.md).

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

## Natural-language pass — September 19, 2026

Reviewed all 15 student-facing prose and Julia files, including the Canvas
assignment description. Applied localized wording changes in 14 files and
synchronized the two reference solutions' docstrings with the student
templates. The pass follows the Week 5 natural-language handoff: restore
missing articles and verbs, name quantities clearly, and retain concise
headings, labels, and comments.

Examples include “Complete the lattice calculation” instead of “Complete
Standard,” “the mean growth rate, volatility parameter, and price drift”
instead of “mean growth, volatility, and price drift,” and “before awarding
a score of 4” instead of “before a score of 4.” The model-comparison question
now names the normal distribution of growth rates and the observed trades
that did not beat the benchmark.

The calculations, formulas, supplied prices, package versions, grading rules,
dates, headings, links, and answer markers are preserved. Julia differences
are confined to docstrings, comments, and student-visible message and test
labels. The five Markdown documents render to HTML; their mathematical
expressions, code fragments, lists, and numeric values match the baseline.
The Canvas HTML retains its tags, styles, and link targets. A visual browser
check was unavailable because this session had no connected browser.

All nine release cases pass, including 15/15 for the Standard reference and
22/22 for the Advanced reference. Independent Python calculations agree with
the forecasts, observed outcomes, and exported lattice. The separate feedback
suite passes all 136 checks. The student ZIP was rebuilt and its 20 files
checked against the saved sources. Historical test logs were preserved by
running the release suite in a temporary copy. No commit, push, or Canvas
publication was performed.

## Response-question clarity — September 19, 2026

Revised both response files after the instructor found Advanced Question 1
confusing. Questions now separate tables of results from interpretation and
state the required quantities, table columns, units, and answer parts.
Advanced Question 1 names all six parameters and makes clear that each row
compares two model probabilities with one observed trade. Both tracks explain
how to identify the more likely outcome using the 50% threshold. Advanced
Question 2 separates model differences, forecast accuracy, and missing data
patterns into three short paragraphs. Advanced Question 3 identifies the
separate report example and separates its calculation, interpretation, and
decision questions.

Checked all six questions against the report code and instructor answer
guide. The three question headings and answer blocks in each file are
preserved. Both files render to HTML, local links resolve, and the response
checker detects all three placeholders and accepts filled answer blocks.
The numerical code was not changed or rerun for this question-only revision.
The local student ZIP was refreshed with the revised questions.

## Student calculations for observed outcomes — September 19, 2026

The instructor requested that students calculate the observed outcomes in
their own code. Both tracks now require `observed_outcome`, which selects
the sale observation and returns its date and price, the benchmark price,
the scaled NPV, and whether the trade beat the benchmark. The report displays
those values. An unfinished function produces `UNAVAILABLE` in the terminal
and empty outcome fields in the CSV, including when the forecast functions
are complete. The separate Advanced example also remains unavailable until
the student's probability function returns a result.

Standard now has four required functions and 20 public checks. Advanced has
six functions and 27 checks. The five new checks cover observation indexing,
time units and benchmark growth, positive and negative scaled NPV, and
equality with the benchmark. The rubric thresholds, questions, README, data
notes, Canvas copy, build checks, and ignored local solutions were updated.
These totals replace the earlier counts recorded in this review history.

All 14 release cases pass. The completed solutions pass 20/20 and 27/27,
and the independent Python calculations agree with their reported results.
Both tracks were checked with only the observed-outcome function complete
and with only that function unfinished. A separate check confirms that the
report uses student-returned values without silently recomputing them. All
166 feedback and grading checks pass. The local student ZIP excludes the
ignored solutions, answer guide, and saved logs.

## Checker and report workflow — September 19, 2026

The README now puts running the checker before writing the answers. Both
response files, the source-file comments, data notes, and Canvas copy explain
that `check_submission.jl` automatically calls the student's functions and
prints the financial report. The instructions give the exact command, name
the terminal section `PS2 financial results`, and tell students to save and
rerun after changing code or answers. No separate report call is required.

Checked this sequence against the checker implementation and saved starter
output. Markdown parsing and HTML generation preserve the seven setup steps,
question headings, answer markers, tables, and mathematics; local links and
GitHub heading anchors resolve. Canvas HTML retains balanced tags, link
targets, and command formatting. Only comments changed in Julia source;
the calculations were not changed or rerun. The rebuilt local student ZIP
matches all 20 saved source files and excludes solutions, answers, and logs.

## Central file loading and local solution runs — September 19, 2026

Moved assignment file loading into `Include.jl`, including track selection,
the report, public checks, optional helpers, and the selected source file.
The checker now includes that file once and prints the selected source path.
Optional helpers load before the selected source, so their definitions are
available to it.

The normal command selects `src`. Adding `--solution` selects the ignored
`solution/src` directory; `TRACK.txt` determines Standard or Advanced in
both modes. Solution runs save their reports and record under `solution`,
preserve student outputs, and do not print student submission instructions.
The instructor README gives the exact command. No source copying or path
editing is needed.

All 19 release cases pass, including both local solutions, both unchanged
starters with solutions present, helper loading, and a missing local
solution. Standard passes 20/20 public checks and Advanced passes 27/27;
independent Python calculations agree with the reports. All 166 feedback
checks also pass. The student sources, response files, price data, and local
solutions are unchanged. Markdown renders to HTML, and the local student
ZIP excludes solutions, answer guides, and saved logs.

## Final student-instruction consistency pass — September 19, 2026

Read the complete README, rubric, and both response files against the
selected-track loader, function docstrings, financial report, and grading
code. Confirmed that each requested result is available from the completed
student functions or the explicitly requested hand calculation, with units
matching the report. The rubric's counts and score boundaries match the
20 Standard and 27 Advanced checks.

Clarified that unselected-track TODOs do not affect the grade, that all parts
of an answer belong inside its existing Markdown answer markers, and that
a code-loading failure or failed checks do not make an otherwise qualifying
initial submission a Frozen Zero. The README now uses the same benchmark
symbol as Advanced Question 3 and explains the zero-NPV sale-price threshold.
The questions, grading policy, and required calculations are unchanged.

All 166 feedback checks pass. The actual response templates correctly flag
their three placeholders and accept multipart text placed inside the existing
markers. The four documents render to HTML; headings, tables, local links,
and answer markers are preserved. Executable code, prices, track selection,
and local solutions are unchanged. The local student ZIP was refreshed;
no release was published. This is a document and implementation review,
not a usability trial with students seeing the assignment for the first time.

## Benchmark comparison and minor-error grading — September 19, 2026

Both tracks now include a predict–calculate–explain comparison at benchmark
rates of 5% and 1%, keeping the 63-day holding period and 2025 estimates fixed.
The report calls the existing student functions at both rates and prints an
aligned table with benchmark prices, probabilities, and successful lattice
node counts. It also writes `benchmark-comparison.csv`. Students use the
same checker command and implement no additional functions. The response
instructions explain percentage-point changes, preserve the initial prediction,
and allow full credit for a mistaken prediction followed by a correct
interpretation. Standard Question 2c replaces the former holding-period
paragraph; Advanced adds the comparison as Question 2d.

Independent calculations confirm that the lattice remains at 61.7141%, with
30 of 64 nodes successful at both rates, while GBM rises from 54.4998% to
57.4869%. The existing 5% results and Advanced Question 3 are preserved.
The local answer guide and Canvas description match the revised questions.

The rubric now allows a teaching-team score of 3 for otherwise complete
work with one minor, localized coding error when more than half the checks
pass and the written work shows understanding. Missing functions and incorrect
methods do not qualify. The checker retains automatic test-count feedback
and explains the review; accepting a review never awards 4 with failed checks.

The full release checks pass, including independent calculations, unfinished
student functions, report use of student-returned comparison values, separate
local-solution output, and cleanup after a source error. Both reference
solutions pass their unchanged 20 and 27 public checks. All 313 feedback
and grading assertions pass. After the final table-formatting change, the
Advanced starter and both reference reports were rerun from the rebuilt ZIP.
The Markdown documents render to HTML with their tables, question headings,
and hidden answer markers intact, and local links resolve. The rebuilt
student ZIP excludes solutions and instructor material. No release was published.

## Benchmark comparison moved to 126 days — September 19, 2026

The final benchmark exercise uses 126 trading days, replacing the 63-day
comparison described in the preceding entry. Lowering the rate from 5% to
1% now increases both model probabilities: the lattice moves from 62.9059%
to 69.4252%, and GBM moves from 56.3502% to 60.5259%. The lattice includes
one more successful node, with sale price 276.0641 USD/share and probability
about 6.5192%. The successful-node count rises from 59 to 60 out of 127.

A separate `comparison_days=126` setting controls this exercise. The report,
both response files, README, Canvas copy, instructor instructions, and local
answer guide use the revised horizon. The answer guide accepts the small
rounding difference between subtracting displayed and unrounded probabilities.
The main three-horizon results, 63-day node export, Advanced Question 3,
student function requirements, and minor-error grading policy are preserved.

Both reference solutions pass all 20 and 27 public checks. The full release
checks pass, including independent calculations at both benchmark rates and
the original horizons, incomplete-code feedback, and student-returned report
values. The rendered Markdown keeps the three question blocks and local
links intact. The rebuilt student ZIP matches all release files.

## Student terminal formatting — September 19, 2026

Added shared plain-text formatting in `reports/Terminal.jl` for headings,
78-column wrapping, aligned tables, and diagnostic blocks. The financial
report displays model estimates with units, places the three holding periods
side by side, and uses separate tables for the benchmark comparison and
Advanced Question 3. Numeric columns are right aligned. Missing results
occupy the same table cells as completed results and display `UNAVAILABLE`.
CSV values and numerical calculations are unchanged.

Failed checks refer to numbered diagnostics instead of repeating identical
errors. Unavailable report calculations are grouped by cause. A source-load
failure prints its error once with relative paths and preserves Julia's
source snippet and error pointer. The setup include now finishes before a
separate top-level expression reads its bindings, removing the Julia 1.12
binding warnings previously emitted by failed loads. Submission instructions
use numbered steps and put the ZIP filename on its own line.

The full release suite passes, including both reference solutions at 20/20
and 27/27 public checks, independent numerical calculations, partial work,
missing answers, source errors, and an invalid track. All 313 feedback and
grading assertions pass. Width and column alignment were also checked on
29 tables across 11 submission states. After the final diagnostic wrapping
adjustment, invalid-track, missing-solution, and syntax-error runs pass with
complete words and source pointers preserved. The README documents the new
layout; its local links and the instructor README render correctly. The
rebuilt student ZIP includes the shared formatter and matches the saved files.

## Report no longer states the Question 2b conclusion — September 20, 2026

Removed one sentence from the terminal report that said the three trades
share one purchase and cannot establish forecast accuracy. Question 2b asks
students to explain that point, so the report was supplying the answer.
The checker was rerun on the untouched Standard starter; the observed-trades
table, probability-sum note, and benchmark comparison print as before.
No calculation, test, data, or grading rule changed.
