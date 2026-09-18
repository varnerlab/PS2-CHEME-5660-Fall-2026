"""
    evaluate_public_checks(checks) -> Vector{NamedTuple}

Run each public check and record its result. An error in one check does not
stop the others.

### Arguments

- `checks`: A vector of named tuples with `name` and `evaluate` fields.
  Each `evaluate` function takes no arguments and returns `true` on success.

### Returns

One record per check, with its `name`, a `passed` value of `true` or `false`,
and an error message in `detail`. An empty message means the check passed.
"""
function evaluate_public_checks(checks::AbstractVector{<:NamedTuple})::Vector{NamedTuple}

    results = NamedTuple[];
    for check ∈ checks
        passed = false;
        detail = "";
        try
            value = check.evaluate();
            passed = value === true;
            passed || (detail = "check returned $(repr(value))");
        catch error
            detail = sprint(showerror, error);
        end
        push!(results, (name = check.name, passed = passed, detail = detail));
    end

    return results;
end


"""
    failed_public_checks(checks, detail) -> Vector{NamedTuple}

Mark every check as failed when the student's source file cannot be loaded.

### Arguments

- `checks`: The selected track's checks, each with a `name` field.
- `detail`: Error message explaining why the source could not be loaded.

### Returns

One failed result per check, each with the supplied error message.
"""
function failed_public_checks(checks::AbstractVector{<:NamedTuple},
    detail::String)::Vector{NamedTuple}
    return [(name = check.name, passed = false, detail = detail) for check ∈ checks];
end


"""
    print_public_test_report(results, title) -> Nothing

Print each check's name, pass/fail result, and any error message, followed
by the number of passed checks.

### Arguments

- `results`: Check records with `name`, `passed`, and `detail` fields.
- `title`: Heading to print above the checks.

### Returns

`nothing`. The report is printed to the terminal.
"""
function print_public_test_report(results::AbstractVector{<:NamedTuple},
    title::String)::Nothing

    println("\n", title);
    println(repeat("=", length(title)));
    for result ∈ results
        status = result.passed ? "PASS" : "FAIL";
        println("[", status, "] ", result.name);
        if !result.passed && !isempty(result.detail)
            println("       ", result.detail);
        end
    end

    passed = count(result -> result.passed, results);
    println("\npassed $(passed) of $(length(results)) public tests");
    return nothing;
end


"""
    missing_docstrings(function_names::Vector{Symbol}) -> Vector{Symbol}

Find required functions that have no Julia docstring.

### Arguments

- `function_names`: Names of the functions required for the selected track.

### Returns

The names that are not defined or have no docstring in `Main`.
"""
function missing_docstrings(function_names::Vector{Symbol})::Vector{Symbol}
    metadata = Base.Docs.meta(Main); # docstrings in the module where student code is loaded
    return filter(function_names) do name
        binding = Base.Docs.Binding(Main, name);
        !isdefined(Main, name) || !haskey(metadata, binding)
    end;
end


"""
    code_is_documented(function_names::Vector{Symbol}) -> Bool

Check whether all required functions have docstrings.

### Arguments

- `function_names`: Names of the functions required for the selected track.

### Returns

`true` when every named function is defined and has a docstring in `Main`.
"""
function code_is_documented(function_names::Vector{Symbol})::Bool
    return isempty(missing_docstrings(function_names));
end


"""
    response_issues(path::String) -> Vector{String}

Find missing or unfinished answers and describe how to fix them.

### Arguments

- `path`: Selected track's Markdown response file.

### Returns

A list of messages for missing files, incorrect answer markers, empty answers,
or answers that contain TODO. An empty list means no issues were found.
The check ignores HTML comments inside answers. It checks for text, not
whether an answer is correct; the teaching team reviews the answers.

### Errors

An unreadable file raises a file-read error.
"""
function response_issues(path::String)::Vector{String}
    isfile(path) || return ["Response file is missing. Restore it from the PS2 ZIP and answer all three questions."];
    text = read(path, String);
    issues = String[];
    for index in 1:3
        start_marker = "<!-- answer-$(index):start -->";
        end_marker = "<!-- answer-$(index):end -->";
        pattern = Regex("<!-- answer-$(index):start -->(.*?)<!-- answer-$(index):end -->", "s");
        blocks = collect(eachmatch(pattern, text));
        if count(start_marker, text) != 1 || count(end_marker, text) != 1 || length(blocks) != 1
            push!(issues, "Question $(index): Keep one $(start_marker) before your answer and one $(end_marker) after it.");
            continue;
        end
        answer = strip(replace(blocks[1].captures[1], r"<!--.*?-->"s => ""));
        if !occursin(r"[\p{L}\p{N}]", answer)
            push!(issues, "Question $(index) has no answer. Write your response between its answer markers.");
        elseif occursin(r"\bTODO\b"i, answer)
            push!(issues, "Question $(index) still contains TODO. Replace the placeholder with your response.");
        end
    end;
    return issues;
end


"""
    response_is_complete(path::String) -> Bool

Check whether all three answer blocks contain text without TODO.

### Arguments

- `path`: Selected track's Markdown response file.

### Returns

`true` when `response_issues` returns an empty list. This checks that answers
are present; the teaching team reviews whether they meet the requirements.

### Errors

An unreadable file raises a file-read error.
"""
function response_is_complete(path::String)::Bool
    return isempty(response_issues(path));
end


"""
    rubric_score(results; tests_ran, completion) -> Int

Calculate the rubric score from the check results and completion review.

### Arguments

- `results`: A vector of check records with Boolean `passed` fields.
- `tests_ran`: Whether the student's source file loaded; `false` gives 0.
- `completion`: Set to `true` only when the teaching team has reviewed the
  code, documentation, and answers and found that all requirements are met.

### Returns

An integer from 0 to 4. No passing checks gives 0. Passing some checks but
at most half gives 1; passing more than half but fewer than all gives 2.
When all checks pass, return 3 if `completion` is `false` and 4 if it is `true`.

### Notes

The local checker prints pending review when all checks pass. It leaves the
choice between 3 and 4 to the teaching team.
"""
function rubric_score(results::AbstractVector{<:NamedTuple};
    tests_ran::Bool, completion::Bool)::Int

    passed = count(result -> result.passed, results);
    total = length(results);

    if !tests_ran || passed == 0
        return 0;
    elseif 2*passed <= total
        return 1;
    elseif passed < total
        return 2;
    elseif !completion
        return 3;
    else
        return 4;
    end
end


# Functions that must have docstrings -
const STANDARD_DOCUMENTED_FUNCTIONS = [
    :estimate_lattice, :build_lattice, :lattice_probability,
];

const ADVANCED_DOCUMENTED_FUNCTIONS = [
    STANDARD_DOCUMENTED_FUNCTIONS..., :estimate_gbm, :gbm_probability,
];
