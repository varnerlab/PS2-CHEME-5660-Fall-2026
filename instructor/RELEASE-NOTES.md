# CHEME 5660 Problem Set 2

This is the Fall 2026 student release of PS2: *What Is the Probability of Beating a Benchmark?*

Download **Source code (zip)** below, extract it, and begin with `README.md`. The release contains the starter code for both tracks, the 2025 and 2026 AAPL price files, public tests, response files, submission checker, terminal financial report, and grading rubric. The reference solutions are not included.

Choose Standard or Advanced in `TRACK.txt`.
* __Standard__ builds a binomial lattice and calculates the probability of beating a 5% continuously compounded benchmark, then calculates the observed 2026 trade outcomes in your own code.
* __Advanced__ adds a geometric Brownian motion (GBM) model and compares the two models.

Both tracks also compare the 126-day forecast at benchmark rates of 5% and 1%; write your prediction before reading the results.

The assignment was built and tested with **Julia 1.12.7**; follow the package setup instructions in the README. Run `check_submission.jl` to check your code and print the financial report; it prints the submission instructions for building your ZIP.

The initial submission is due on Canvas by **11:59 PM ET on Sunday, October 4, 2026**. Eligible revisions are accepted until **December 19, 2026 at 11:59 PM ET**. An accepted Advanced score of 4 earns one Magic Point.
