# PS2 style comparison: CHEME 5660 and CHEME 4800/5800

Reviewed September 18, 2026. The reference is the completed assignment in
`PS2-CHEME-4800-5800-Fall-2026`. The findings below describe the assignment
before the style revision. The user approved that revision, and the proposed
changes have now been applied. See [REVIEW.md](REVIEW.md) for the checks.

## Main finding

The 5800 assignment explains the problem through objects and actions the
student can follow: a location, a door, a card, and a route. It then connects
those objects to the code. The same approach continues through the questions,
docstrings, TODOs, and checker messages.

The 5660 assignment defines its mathematics and units, but often puts several
instructions or distinctions into one paragraph. Students must find the
requested numbers, the explanation to write, and the relevant code within
that paragraph. The earlier plain-language pass improved individual sentences;
the remaining work concerns how the explanations and tasks fit together.

The 5800 reference keeps necessary technical terms, including graph vertex,
predecessor, and breadth-first search. It explains them through the maze.
For 5660, keep NPV, growth rate, volatility, and the course notation, and
explain their roles through the purchase, benchmark, and sale.

## Comparison across student files

| Area | What 5800 does | Current 5660 | Suggested change |
|:--|:--|:--|:--|
| README introduction | Starts with a situation and a clear job: find a route with the fewest moves. Explains how Part 2 changes the problem. | Starts with an investment question, then describes the two tracks and a later expected-NPV example. | Keep the investment question and the recently revised introduction. Connect each track to the same purchase and sale. |
| README explanations | Uses small maps and specific positions to explain movement, route length, and the need to track the CornellID. | Defines scaled NPV and the success inequality, but provides no small numerical price example. | Add one short purchase-and-sale example near the NPV definition. |
| Task order | Explains a map, walks through an example, names the functions, and shows how to test them. | Gives the three Standard tasks before defining the growth rate used in the first task. | Put each definition before the task that needs it. Keep the package calls close to that task. |
| Discussion questions | Uses one central question per numbered item and refers to specific maps or states. Sets a short-paragraph expectation. | Some questions combine estimates, tables, prices, comparisons, and several explanations in one paragraph. | Separate requested results from the explanation. Where numbers are required, ask for a table followed by a short paragraph. |
| Student docstrings | Separates Arguments, Returns, and Errors. Describes types, edge cases, and what the function must do. | Contains the needed details, but mixes inputs, method, package instructions, output fields, and rounding notes. | Use consistent Arguments, Returns, and Method or Notes sections. State units next to each input. |
| Student TODOs | Numbers the steps and often explains why a step matters. | Many steps are already direct; others say to use formulas elsewhere or to populate a model. | Number the steps and name the values or model fields to use. Explain the purpose when it prevents a likely mistake. |
| Checker messages | Names missing questions and tells the student what to fix. Distinguishes passing code from unfinished answers. | Prints Boolean summaries such as `All three answer blocks filled in: false`. | Give an instruction that names the selected response file. More specific question-by-question feedback would require a small checker change. |
| Results | Displays the route the student computed and explains how to read it. | Prints probabilities and parameter values with units, plus diagnostic values such as the probability sum. | Keep the useful numerical report. Add a short explanation of what each probability means and clearly label diagnostics. |
| Rubric | States whether requirements were met and explains who reviews them. | Uses phrases such as “a completion requirement was not accepted.” | Use direct wording such as “at least one requirement below was not met.” Keep the existing grading rules. |
| Data notes | Gives each map's role and size before source details and file hashes. | Clearly identifies the price file, but puts its source hash before the remaining instructions about its use. | Put columns, units, dates, and use first; put source details and the hash last. |
| Supplied source and tests | Uses structured docstrings and comments that explain the reason for a step. | Functions are documented, and most public test names already describe the behavior checked. | Apply the same docstring organization to support and reporting functions. Make only small wording changes to the test names. |

## Examples supporting the comparison

### A concrete example before a general rule

The 5800 README describes returning to the junction at `(2, 4)` with the
CornellID before explaining why the search state needs a third value. The
example gives the student a reason to care about the representation.

The 5660 README can do the same for discounting. A proposed addition is:

> Suppose you buy one share for $100 and sell it after 63 trading days.
> Over that period, the benchmark grows $100 to about $101.26. Selling the
> share for $101 gives you more than you paid, but it does not beat the
> benchmark. Your scaled NPV is negative.

This example uses the assignment's 5% continuously compounded annual rate
and 252 trading days per year. It explains why the success price exceeds the
purchase price without giving away the AAPL results.

### A TODO that names the work

The 5800 source gives a step and its purpose, for example recording a new
position before adding it to the queue so it cannot be added twice.

The current 5660 construction TODO reads:

```julia
# TODO: Populate the model using initial_price and days, then return it.
```

A proposed replacement is:

```julia
# TODO 2: Use populate to add prices and probabilities for days 0 through days.
# Start at initial_price and return the completed model.
```

The current probability TODO is already specific and should keep its meaning:

```julia
# TODO: Add the probabilities of nodes with scaled NPV > 0 and return the sum.
```

### A question with a clear place to start

The 5800 question “Why track your CornellID?” points to two specific states
at the same location. Its follow-up questions all develop that one issue.

The first Advanced question in 5660 asks for six parameters, a comparison
table, two prices, and an explanation of the success condition. Those are
valid requirements, but one paragraph makes them hard to check off.

Keep the requirements and present them in order: parameter estimates in a
small table, the three holding-period probabilities in a comparison table,
then the purchase price, 63-day benchmark price, and a short explanation of
which sale prices count as success. The answer instructions should state
that the tables are followed by a short paragraph.

The second Advanced heading, “What can the comparison tell us?”, could name
its subject more directly: “Why do the two models give different probabilities?”
Its questions about forecast accuracy and the missing patterns in growth
rates can remain below that heading.

### Feedback that names the next action

The 5800 checker reports messages such as:

> Question 2 still has a TODO or answer placeholder. Replace it with your response.

The 5660 checker currently reports:

```text
All three answer blocks filled in: false
```

A proposed message for an unfinished Advanced response file is:

> Some answers in responses/Advanced.md are missing or still contain TODO.
> Complete all three answers, then run the checker again.

This message can use the existing completion result. Naming the exact
unfinished question, as 5800 does, would require the checker to return the
individual question numbers as well.

### Direct grading language

Replace “All 15 passed, but a completion requirement was not accepted” with:

> All 15 tests passed, but at least one requirement below was not met.

The explanation that a person reviews code and answers should remain. The
5660 rules about track selection, Magic Points, dates, and revisions also
remain course requirements; a style revision should preserve them.

## Recommended order for a revision

1. Revise both response files so students can distinguish results to report
   from questions to explain.
2. Reorganize the Standard and Advanced docstrings, and number the TODOs.
   Keep all function names, arguments, units, and required calculations.
3. Adjust the README's order and add the small benchmark example.
4. Revise checker and report messages. Treat question-by-question diagnostics
   as a separate small code change if included.
5. Apply the same wording and documentation conventions to the rubric,
   data notes, support functions, and tests.

The 5660 assignment needs its equations and rate conventions. The package
setup and two-track structure also require instructions that 5800 does not
need. Use the 5800 approach to explain those requirements clearly. Avoid a
fixed word-count reduction or copying its grading thresholds and implementation
requirements into a different assignment.

## Files inspected

For 5800: README, responses, rubric, data notes, all six files under `src`,
Include.jl, runmaze.jl, check_submission.jl, test_support.jl, and both public
test scripts. The inspection included docstrings, comments, error messages,
printed feedback, and the labels written by the drawing code.

For 5660: README, both response files, rubric, data notes, all three files
under `src`, Include.jl, check_submission.jl, reports/Finance.jl, test/Rubric.jl,
and both public test files.

The comparison concerns writing and task presentation. It does not assess
the assignments' relative difficulty. The later revision includes numerical
checks and a rebuilt student ZIP.
