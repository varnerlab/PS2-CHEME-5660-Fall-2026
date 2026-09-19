# PS2 grading rules

Your selected track is graded out of **4**. An accepted Advanced score of 4
also earns **one Magic Point**, once for PS2. Select your track in
[TRACK.txt](TRACK.txt).

The Standard track has **15 checks**: four for parameter estimates, five for
lattice construction, five for the probability calculation, and one that
uses all three functions with the supplied data. The Advanced track adds
seven GBM checks, for **22 total**.

Checks run separately. A check that cannot run counts as failed. Several use
supplied inputs, so an unfinished early function does not block all later
credit. A source file that cannot load receives 0.

| Score | Standard checks passed | Advanced checks passed | Other requirements |
|:--:|:--:|:--:|:--|
| 0 | 0 | 0 | — |
| 1 | 1–7 | 1–11 | — |
| 2 | 8–14 | 12–21 | — |
| 3 | 15 | 22 | At least one requirement below is not met |
| 4 | 15 | 22 | All requirements below are met |

Passing only the 15 shared checks on the Advanced track earns 2. We grade
the selected track. To change tracks, update [TRACK.txt](TRACK.txt), complete
that track's files, and rerun the checker.

## Requirements for a 4

- **Code:** Complete every required function. Use the course package for
  growth rates, lattice estimates, and construction. Add the probabilities
  of sale-day nodes with positive scaled NPV. Advanced also uses the stated
  GBM estimates and normal probability formula. Estimate the model parameters
  from 2025 prices only.
- **Documentation:** Keep the supplied docstrings. Document each helper's
  purpose, inputs, and output. Use short comments for non-obvious steps.
- **Helper files:** Put helpers in separate `.jl` files under [src](src).
  Load them from [Include.jl](Include.jl), keeping its supplied lines.
- **Finished work:** Remove completed TODOs and starter errors. Answer all
  three questions with the requested numbers, units, and explanations,
  including the three comparisons with observed 2026 outcomes.

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
