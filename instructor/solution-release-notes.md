Reference solution for **CHEME 5660 PS2: What Is the Probability of Beating a Benchmark?**, Fall 2026.

Download **CHEME-5660-PS2-Solution-2026.1.zip** under Assets, extract it, and start with `README.md`. This named ZIP contains the completed solution. GitHub's automatic **Source code** downloads contain the repository's starter snapshot.

The solution ZIP includes:

- Completed Standard and Advanced implementations, with the supplied docstrings unchanged.
- Worked answers to all three discussion questions in each track.
- The recorded Julia environment, the 2025 and 2026 AAPL price files, checker, public tests, terminal financial report, and saved reference results: the forecasts and observed outcomes for 21, 63, and 126 trading days, the 126-day benchmark comparison at 5% and 1%, and the 64 possible lattice sale prices after 63 trading days.
- The original assignment instructions (`ASSIGNMENT.md`) and grading rubric.

The lattice functions follow the L3b and L4a examples: `log_growth_matrix` and `RealWorldBinomialProbabilityMeasure` to fit the lattice, `build` and `populate` to construct it, and a sum over the sale-day node probabilities with scaled NPV strictly above zero. The Advanced GBM functions follow the L4b examples.

Verified with **Julia 1.12.7**: Standard **20/20** checks and Advanced **27/27** checks pass from the extracted solution ZIP. The package setup, written numerical answers, unchanged questions and docstrings, and saved CSV results were verified.

Use the reference solution to understand mistakes and debug your own work. The assignment's independent-work and reference-solution policies remain in force. The initial deadline was **October 4, 2026 at 11:59 PM ET**; eligible revisions remain open through **December 19, 2026 at 11:59 PM ET**.
