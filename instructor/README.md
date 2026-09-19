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

- [Standard reference code](../solution/src/Standard.jl)
- [Advanced reference code](../solution/src/Advanced.jl)
- [Expected results and answer guide](../solution/RESPONSE-GUIDE.md)
- [Saved test results](../solution/results)
- [Build and review record](REVIEW.md)

The completed Julia code, answer guide, and saved test results are local files
under [solution](../solution). The [ignore rule](../.gitignore) keeps this
folder out of Git. These links resolve only when the local files are present.
A fresh clone needs local copies of both Julia solutions under
[solution/src](../solution/src) before the reference checks can run.

## Run a local solution

Set [TRACK.txt](../TRACK.txt) to `standard` or `advanced`, then run this
command from the PS2 folder:

```text
julia --project=. --startup-file=no check_submission.jl --solution
```

The checker loads [Include.jl](../Include.jl), which owns all assignment
include calls. Its `_PATH_TO_SRC` selects `src` for the normal student
command and `solution/src` when `--solution` is present. The selected track
then determines whether it loads `Standard.jl` or `Advanced.jl`. No path
editing or copying over student code is needed.

The first output line identifies the actual source file. The local solution
run prints the public checks and financial report, saves CSV files under
[solution/results](../solution/results), and writes `solution/MANIFEST.txt`.
That record includes the actual solution file checked. It does not present
this run as a student submission or change the student source or responses.

Omit `--solution` to return to the student version. Keeping the local
solution folder present does not change the default student run.

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
The checks confirm that unfinished observed-outcome functions leave the report
fields empty, that this function can earn credit independently of the forecasts,
and that the report uses student-returned values. The real student source and
response files stay unchanged. Logs are saved under
[solution/results](../solution/results).

The checks also exercise both local solutions through `--solution`, helper
loading before the selected source, and a missing local solution. They
confirm that the default command still uses the starter when local solutions
are present and that solution runs preserve student outputs.

To check answer detection, docstring detection, and every grading threshold,
run:

```text
julia --project=. --startup-file=no instructor/check_feedback.jl
```

These instructor checks do not add to the 20 or 27 graded checks.

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
| Calculate observed outcomes and compare them with forecasts | Implement the sale-observation selection, benchmark price, scaled NPV, and success rule |
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
