# Run from the PS2 folder: julia --project=. --startup-file=no check_submission.jl
import Dates # record when this local check ran
using SHA: sha256 # record which files were checked

const _CHECK_ROOT = @__DIR__;
include(joinpath(_CHECK_ROOT, "test", "Rubric.jl"));

"""
    clear_previous_results(root::String) -> Nothing

Remove the three CSV files written by the PS2 report. Clear them before
loading student code so a failed run cannot leave old results looking current.

### Arguments

- `root`: Assignment folder.

### Returns

`nothing`. Skips files that do not exist.

### Errors

Raises an error if an existing file cannot be removed. The checker reports
this as a setup error.
"""
function clear_previous_results(root::String)::Nothing
    for name in ("standard-results.csv", "advanced-results.csv", "terminal-nodes.csv")
        path = joinpath(root, "results", name);
        isfile(path) && rm(path);
    end
    return nothing;
end

# Load supplied tools and checks before the selected student source file -
const _CHECK_SETUP = let
    try
        clear_previous_results(_CHECK_ROOT);
        track = String(strip(read(joinpath(_CHECK_ROOT, "TRACK.txt"), String)));
        track in ("standard", "advanced") || throw(ArgumentError("TRACK.txt must contain exactly standard or advanced."));
        include(joinpath(_CHECK_ROOT, "Include.jl"));
        include(joinpath(_CHECK_ROOT, "reports", "Finance.jl"));
        include(joinpath(_CHECK_ROOT, "test", "public_$(track)_tests.jl"));
        checks = track == "standard" ? standard_public_checks() : advanced_public_checks();
        (track=track, checks=checks, detail="");
    catch caught
        (track="unavailable", checks=NamedTuple[], detail=sprint(showerror, caught));
    end
end;

# Load the selected student source file -
const _CHECK_SOURCE = let
    if isempty(_CHECK_SETUP.detail)
        try
            include(joinpath(_CHECK_ROOT, "src", titlecase(_CHECK_SETUP.track)*".jl"));
            (tests_ran=true, detail="");
        catch caught
            (tests_ran=false, detail=sprint(showerror, caught));
        end
    else
        (tests_ran=false, detail=_CHECK_SETUP.detail);
    end
end;

"""
    write_file_record(io::IO, root::String, track::String) -> Nothing

Record the contents of TRACK.txt, Include.jl, all files under src/, and the
selected response file.

### Arguments

- `io`: Open output stream for the submission record.
- `root`: Assignment folder.
- `track`: Selected track, or `unavailable` after a setup error.

### Returns

`nothing`. Writes a SHA-256 value that identifies each file's contents.
Marks missing required files as MISSING.

### Errors

Raises an error if a file cannot be read or the record cannot be written.
"""
function write_file_record(io::IO, root::String, track::String)::Nothing
    paths = [joinpath(root, "TRACK.txt"), joinpath(root, "Include.jl")];
    if isdir(joinpath(root, "src"))
        for (folder, _, names) in walkdir(joinpath(root, "src"))
            append!(paths, [joinpath(folder, name) for name in names]);
        end
    end
    if track in ("standard", "advanced")
        push!(paths, joinpath(root, "src", titlecase(track)*".jl"));
        push!(paths, joinpath(root, "responses", titlecase(track)*".md"));
    end
    for path in sort(unique(paths))
        relative = replace(relpath(path, root), '\\' => '/');
        value = isfile(path) ? bytes2hex(open(sha256, path)) : "MISSING";
        println(io, value, "  ", relative);
    end
    return nothing;
end

"""
    main() -> Nothing

Run the public checks, display available calculations, and write the
submission record.

### Inputs

Uses `_CHECK_SETUP` for the selected track and its checks. Uses
`_CHECK_SOURCE` to find whether the student's source file loaded.

### Returns

`nothing`. Prints results and next steps, and writes `MANIFEST.txt` in the
assignment folder. After all checks pass, the teaching team must still
review the code, documentation, and answers.

### Notes

Prints errors from individual checks and report calculations. An error reading
the selected response file or writing the submission record stops the checker.
Does not upload files or edit the student's code or answers.
"""
function main()::Nothing
    # Check the functions, docstrings, and answers -
    track = _CHECK_SETUP.track;
    tests_ran = _CHECK_SOURCE.tests_ran;
    results = tests_ran ? evaluate_public_checks(_CHECK_SETUP.checks) :
        failed_public_checks(_CHECK_SETUP.checks, _CHECK_SOURCE.detail);
    print_public_test_report(results, "PS2 $(titlecase(track)) checks");
    tests_ran || println("Setup or source error: ", _CHECK_SOURCE.detail);
    passed = count(result -> result.passed, results);
    all_passed = tests_ran && !isempty(results) && passed == length(results);
    names = track == "standard" ? STANDARD_DOCUMENTED_FUNCTIONS : ADVANCED_DOCUMENTED_FUNCTIONS;
    missing_docs = tests_ran ? missing_docstrings(names) : Symbol[];
    documented = tests_ran && isempty(missing_docs);
    response_path = joinpath("responses", titlecase(track)*".md");
    answer_issues = track in ("standard", "advanced") ? response_issues(
        joinpath(_CHECK_ROOT, response_path)) : String[];
    answers = track in ("standard", "advanced") && isempty(answer_issues);
    feedback = all_passed ? "pending completion review" : string(
        rubric_score(results; tests_ran=tests_ran, completion=false));

    # Calculate the financial results -
    if tests_ran
        try
            print_finance_report(track, _CHECK_ROOT);
        catch caught
            println("Financial report error: ", sprint(showerror, caught));
        end
    end
    # Write the submission record -
    open(joinpath(_CHECK_ROOT, "MANIFEST.txt"), "w") do io
        println(io, "PS2 CHEME 4/5660 Fall 2026 submission record");
        println(io, "generated: ", Dates.now());
        println(io, "track: ", track);
        println(io, "tests ran: ", tests_ran);
        println(io, "public tests passed: $(passed)/$(length(results))");
        println(io, "required function docstrings present: ", documented);
        println(io, "three answer blocks contain text without TODO: ", answers);
        println(io, "local rubric feedback: ", feedback);
        isempty(_CHECK_SOURCE.detail) || println(io, "setup/source error: ", _CHECK_SOURCE.detail);
        write_file_record(io, _CHECK_ROOT, track);
    end
    # Show what to finish before submitting -
    println("\nSubmission check");
    println("Track: ", track);
    println("Public tests: $(passed)/$(length(results)) passed");
    if !tests_ran
        println("Docstrings were not checked. Fix the setup or source error above, then run the checker again.");
    elseif documented
        println("Docstrings: All required functions have docstrings.");
    else
        println("Docstrings: Restore the supplied documentation for ", join(string.(missing_docs), ", "), ".");
    end
    if track in ("standard", "advanced")
        println("Answers: ", response_path);
        if answers
            println("All three answer blocks contain text without TODO. The teaching team will review the answers.");
        else
            for issue in answer_issues
                println("  ", issue);
            end
            println("Save your answers and run the checker again.");
        end
    else
        println("Answers were not checked. Fix the setup error above and run the checker again.");
    end
    println("Local rubric feedback: ", feedback);
    all_passed && println("The teaching team must still review your code, documentation, and answers.");
    println("Wrote MANIFEST.txt. This script has not uploaded your work.");
    println("\nSave your files, create a ZIP of the whole PS2 folder, and upload it to the PS2 assignment on Canvas.");
    println("Name the ZIP CHEME-5660-PS2-<your netid>.zip, using your own NetID.");
    println("Submit attempted work by the initial deadline even if checks fail or cannot run.");
    println("For eligible revisions, use New Attempt on the same Canvas assignment.");
    return nothing;
end

main();
