# Run from the PS2 folder: julia --project=. --startup-file=no check_submission.jl
import Dates # record when this local check ran
using SHA: sha256 # record which files were checked

const _CHECK_ROOT = @__DIR__;

"""
    clear_previous_results(root::String) -> Nothing

Remove the three CSV files written by the PS2 report. Clear them before
running checks or reporting results, even when loading the source failed.

### Arguments

- `root`: Assignment folder, or its local `solution` folder for a solution run.

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

# Include.jl owns all assignment file loading and source-path selection -
const _CHECK_SETUP = let
    detail = "";
    try
        include(joinpath(_CHECK_ROOT, "Include.jl"));
    catch caught
        detail = sprint(showerror, caught);
    end
    # Retain the selected track and checks when a later include fails -
    track = isdefined(Main, :_TRACK) && _TRACK in ("standard", "advanced") ? _TRACK : "unavailable";
    checks = isdefined(Main, :_PUBLIC_CHECKS) ? _PUBLIC_CHECKS : NamedTuple[];
    source_path = isdefined(Main, :_SOURCE_PATH) ? _SOURCE_PATH : "";
    solution = isdefined(Main, :_USE_SOLUTION) ? _USE_SOLUTION : "--solution" in ARGS;
    output_root = isdefined(Main, :_OUTPUT_ROOT) ? _OUTPUT_ROOT :
        solution ? joinpath(_CHECK_ROOT, "solution") : _CHECK_ROOT;
    try
        clear_previous_results(output_root);
    catch caught
        detail = isempty(detail) ? sprint(showerror, caught) : detail * "\n" * sprint(showerror, caught);
    end
    (track=track, checks=checks, tests_ran=isempty(detail), detail=detail,
        source_path=source_path, solution=solution, output_root=output_root);
end;

"""
    write_file_record(io::IO, root::String, track::String, source_path::String) -> Nothing

Record the contents of TRACK.txt, Include.jl, all files under src/, and the
selected response file. Also record the actual selected source, including
when it is a local solution.

### Arguments

- `io`: Open output stream for the submission record.
- `root`: Assignment folder.
- `track`: Selected track, or `unavailable` after a setup error.
- `source_path`: Actual selected source file, or an empty string after an early setup error.

### Returns

`nothing`. Writes a SHA-256 value that identifies each file's contents.
Marks missing required files as MISSING.

### Errors

Raises an error if a file cannot be read or the record cannot be written.
"""
function write_file_record(io::IO, root::String, track::String, source_path::String)::Nothing
    paths = [joinpath(root, "TRACK.txt"), joinpath(root, "Include.jl")];
    isempty(source_path) || push!(paths, source_path);
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

Uses `_CHECK_SETUP` for the selected track, source file, checks, output
folder, and any loading error.

### Returns

`nothing`. Prints results and next steps, and writes `MANIFEST.txt` in the
assignment folder. A local solution run writes under `solution` instead.
After all student checks pass, the teaching team must still review the
code, documentation, and answers.

### Notes

Prints errors from individual checks and report calculations. An error reading
the selected response file or writing the submission record stops the checker.
Does not upload files or edit the student's code or answers.
"""
function main()::Nothing
    # Check the functions, docstrings, and answers -
    track = _CHECK_SETUP.track;
    tests_ran = _CHECK_SETUP.tests_ran;
    source_name = isempty(_CHECK_SETUP.source_path) ? "unavailable" : relpath(_CHECK_SETUP.source_path, _CHECK_ROOT);
    println("Source file: ", source_name);
    if !isdefined(Main, :evaluate_public_checks)
        println("Setup error: ", _CHECK_SETUP.detail);
        println("Fix Include.jl and run the checker again. No submission record was written.");
        return nothing;
    end
    results = tests_ran ? evaluate_public_checks(_CHECK_SETUP.checks) :
        failed_public_checks(_CHECK_SETUP.checks, _CHECK_SETUP.detail);
    print_public_test_report(results, "PS2 $(titlecase(track)) checks");
    tests_ran || println("Setup or source error: ", _CHECK_SETUP.detail);
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
            print_finance_report(track, _CHECK_ROOT;
                output_directory=joinpath(_CHECK_SETUP.output_root, "results"));
        catch caught
            println("Financial report error: ", sprint(showerror, caught));
        end
    end
    # Write the submission record -
    mkpath(_CHECK_SETUP.output_root);
    record_path = joinpath(_CHECK_SETUP.output_root, "MANIFEST.txt");
    open(record_path, "w") do io
        println(io, "PS2 CHEME 4/5660 Fall 2026 submission record");
        println(io, "generated: ", Dates.now());
        println(io, "track: ", track);
        println(io, "source file: ", source_name);
        println(io, "local solution: ", _CHECK_SETUP.solution);
        println(io, "tests ran: ", tests_ran);
        println(io, "public tests passed: $(passed)/$(length(results))");
        println(io, "required function docstrings present: ", documented);
        println(io, "three answer blocks contain text without TODO: ", answers);
        println(io, "local rubric feedback: ", feedback);
        isempty(_CHECK_SETUP.detail) || println(io, "setup/source error: ", _CHECK_SETUP.detail);
        write_file_record(io, _CHECK_ROOT, track, _CHECK_SETUP.source_path);
    end
    # Show what to finish before submitting -
    println(_CHECK_SETUP.solution ? "\nLocal solution check" : "\nSubmission check");
    println("Track: ", track);
    println("Public tests: $(passed)/$(length(results)) passed");
    if !tests_ran
        println("Docstrings were not checked. Fix the setup or source error above, then run the checker again.");
    elseif documented
        println("Docstrings: All required functions have docstrings.");
    else
        println("Docstrings: Restore the supplied documentation for ", join(string.(missing_docs), ", "), ".");
    end
    if _CHECK_SETUP.solution
        println("Wrote ", relpath(record_path, _CHECK_ROOT), ".");
        println("This run used the local solution. Student source files were not changed.");
        return nothing;
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
