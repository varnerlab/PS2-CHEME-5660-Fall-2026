# PS2 grading rules

Your selected track is graded out of **4**. An accepted Advanced score of 4
also earns **one Magic Point**, once for PS2. Select your track in
[TRACK.txt](TRACK.txt).

The Standard track has **20 checks**: four for parameter estimates, five for
lattice construction, five for the probability calculation, one that uses
all three lattice functions with the supplied data, and five for observed
trade outcomes. The Advanced track adds seven GBM checks, for **27 total**.

Checks run separately. A check that cannot run counts as failed. Several use
supplied inputs, so an unfinished early function does not block all later
credit. A source file that cannot load receives a score of 0. Failed checks
or a loading error do not cause a **Frozen Zero**: a readable ZIP containing
attempted work submitted by the initial deadline still qualifies for revisions.

| Score | Standard checks passed | Advanced checks passed | Other requirements |
|:--:|:--:|:--:|:--|
| 0 | 0 | 0 | — |
| 1 | 1–10 | 1–13 | — |
| 2 | 11–19 | 14–26 | Unless the minor-error review below supports a 3 |
| 3 | 20 | 27 | At least one completion requirement below is not met |
| 3 | 11–19 | 14–26 | The minor-error criteria below are met after teaching-team review |
| 4 | 20 | 27 | All requirements below are met |

Completing only the 20 shared checks on the Advanced track earns 2;
unfinished GBM functions do not qualify for the minor-error review. We grade
the selected track. To change tracks, update [TRACK.txt](TRACK.txt), complete
that track's files, and rerun the checker.

## A 3 for a minor coding error

When more than half the checks pass, the teaching team may award **3** for
otherwise complete work with a minor, localized coding error. This requires
all of the following:

- Every required function is implemented; none remains a starter error or
  an unfinished task.
- The failed checks can be traced to one small implementation mistake
  that can be corrected locally without replacing the method. One mistake
  may cause several checks to fail.
- The code and written answers show understanding of the required methods,
  time units, benchmark rule, and model interpretation. All requested
  response parts are attempted, and the documentation requirements are met.

For example, an isolated `>=` in a success check that should use `>` may
qualify when the written explanation correctly excludes equality. Missing
functions, hard-coded test answers, or a misunderstanding of discounting
do not qualify. A score of 4 still requires every check to pass and all
completion requirements to be met.

The checker reports the score from the test count; it cannot assess the
cause of a failure. The teaching team applies this review when grading, so
students do not need to request an exception or edit the checker.

## Requirements for a 4

- **Code:** Complete every required function. Use the course package for
  growth rates, lattice estimates, and construction. Add the probabilities
  of sale-day nodes with positive scaled NPV. Advanced also uses the stated
  GBM estimates and normal probability formula. Estimate the model parameters
  from 2025 prices only. In both tracks, implement the observed-outcome
  function to select the 2026 sale observation and calculate the benchmark
  price, scaled NPV, and success flag. The supplied report displays your
  results; it does not perform those calculations for you.
- **Documentation:** Keep the supplied docstrings. Document each helper's
  purpose, inputs, and output. Use short comments for non-obvious steps.
- **Helper files:** Put helpers in separate `.jl` files under [src](src).
  Load them from [Include.jl](Include.jl), keeping its supplied lines.
- **Finished work:** In your selected track's files, remove completed TODOs
  and starter errors. Answer all three questions with the requested numbers,
  units, and explanations, including the three comparisons with observed
  2026 outcomes and the 5%-to-1% benchmark comparison. For the comparison,
  give a reasoned prediction, the reported values and probability changes,
  and an explanation that agrees with the calculated results. An incorrect
  initial prediction does not reduce the score when it is explained and
  reconsidered using the results.

The checker flags missing docstrings and answers; it cannot judge their
quality. When all tests pass, it reports **pending completion review**.
The teaching team then assigns 3 or 4 using the requirements above.

## How we check submissions

We copy your selected source and response files, helper files under
[src](src), [Include.jl](Include.jl), and [TRACK.txt](TRACK.txt) into a clean
release. This preserves the calls that load your helpers.

Grading uses the supplied data, support code, reports, tests, and checker.
Edits to those files are not used, and helpers must not replace them. The
checker's output is feedback; the teaching team assigns the grade.

## Initial submission and revisions

The release date is **September 20, 2026**. Submit a readable ZIP with
attempted work by **October 4, 2026 at 11:59 PM ET**. Incomplete work and failed
checks qualify. A missing, empty, or unreadable submission receives a
**Frozen Zero** and cannot be revised for credit or earn a Magic Point.

After a qualifying initial submission, you may revise until
**December 19, 2026 at 11:59 PM ET**, with no limit on attempts. Use **New
Attempt** on the same Canvas assignment. Eligible revisions have no late
penalty. We keep your highest score, even if you change tracks. An accepted
Advanced score of 4 earned through revision also earns the one-time Magic Point.

## Independent work

You may discuss ideas and use course materials, books, documentation, the
internet, and AI tools. Submit your own work. Do not share code or solutions.

The reference solution will be released after the initial deadline. Use it
to understand errors and debug your own work, but do not copy it. Copying it
results in a locked score of 0 for PS2. These rules also apply to revisions.
