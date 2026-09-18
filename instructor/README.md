# PS2 instructor files

The student assignment is in the parent folder. This instructor folder is
tracked in the [PS2 repository](https://github.com/varnerlab/PS2-CHEME-5660-Fall-2026).
The [archive rule](../.gitattributes) excludes it from the source archives
students download.

The [build script](build_release.py) also creates a student ZIP locally. It
contains the starter code, questions, fixed data, checker, and public tests.
It excludes instructor files, reference answers, completed code, and generated
results.

The assignment is released September 20, 2026 and is due October 4, 2026 at
11:59 PM ET. Revision and Magic Point rules match PS1.

Use the [Canvas assignment description](canvas-assignment-description.html)
for the Canvas page. The HTML includes the gray command boxes and text highlighting.

## Completed solutions and answers

- [Standard reference code](reference/Standard.jl)
- [Advanced reference code](reference/Advanced.jl)
- [Expected results and answer guide](RESPONSE-GUIDE.md)
- [Build and review record](REVIEW.md)

## Rebuild and check

From the PS2 folder, run:

```text
python3 instructor/check_release.py
```

The script builds the ZIP, extracts it into a temporary folder, and runs the
checker with both untouched starters and both completed solutions. It also
checks partial credit, a source error, a bad track selection, and feedback
when the code passes but an answer or docstring is missing. It compares
the forecasts and observed 2026 outcomes with separate calculations in Python.
It also changes only the 2026 prices to confirm that the forecasts stay fixed.
The real student
source and response files stay unchanged. Logs are saved under
[results](results).

To check answer detection, docstring detection, and every grading threshold,
run:

```text
julia --project=. --startup-file=no instructor/check_feedback.jl
```

These instructor checks do not add to the 15 or 22 graded checks.

To rebuild the ZIP without rerunning the checks, run:

```text
python3 instructor/build_release.py
```

The ZIP is written to `dist/PS2-CHEME-5660-Fall-2026-student.zip`.
The script uses an explicit file list and requires both tracks to retain their
starter errors and answer TODOs. It stops if a completed source file is about
to be included.

The Julia package version is pinned to the same course commit used by PS1:
`e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187`. The needed growth-rate and lattice
calls are available there. Lecture links point to the inspected September
course snapshot, `af75badf5789f497e747173ca2daf783627bc911`.

## Course alignment

| Student work | Course material |
|:--|:--|
| Compute daily growth rates | L3a growth-rate definition |
| Estimate up/down factors and up probability | L3b real-world parameter estimation |
| Build the lattice with the package | L3b lattice example |
| Add probabilities of positive scaled NPV | L4a NPV rule and sale-day probability |
| Estimate GBM parameters | L4b sample-mean and volatility estimates |
| Calculate the GBM probability | L4b GBM NPV example |
| Compare forecasts with observed outcomes | Apply the same scaled NPV rule to 2026 sale prices |
| Explain missing patterns in daily growth | L3a observations and L3b/L4b model assumptions |

The L4b parameter example also demonstrates regression. PS2 explicitly chooses
the sample-mean estimate taught in the same lecture, so students do not have
to choose between two methods. The supplied helper computes average GBM NPV;
students interpret it in the final Advanced question.

The price files were copied from the course's 2025 and 2026 AAPL data. The
extraction script is [extract_prices.jl](extract_prices.jl); pass the source
JLD2 path and destination CSV path when running it with the PS2 project.
Both models use the same 250 prices from 2025. The last 2025 price is the
assumed purchase price. The 170 observations from 2026 are used only to find
the observed outcomes at 21, 63, and 126 trading days.
