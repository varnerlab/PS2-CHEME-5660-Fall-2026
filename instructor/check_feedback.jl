using Test # check feedback helpers without changing the student's graded checks
include(joinpath(@__DIR__, "..", "reports", "Terminal.jl"));
include(joinpath(@__DIR__, "..", "test", "Rubric.jl"));

"""
    documented_fixture() -> Nothing

Provide a documented function for the docstring check. Takes no arguments
and returns `nothing`.
"""
function documented_fixture()
    return nothing;
end

"""
    answer_fixture(answers::Vector{String}) -> String

Wrap three supplied answer strings in the markers used by the response
files. Return the joined text for use in temporary test files.
"""
function answer_fixture(answers::Vector{String})::String
    return join(["<!-- answer-$(i):start -->\n$(answer)\n<!-- answer-$(i):end -->"
        for (i, answer) in enumerate(answers)], "\n");
end

@testset "Response feedback" begin
    mktempdir() do folder
        path = joinpath(folder, "responses.md");
        @test occursin("Response file is missing", only(response_issues(path)));
        @test !response_is_complete(path);
        write(path, answer_fixture(["First answer", "0.05", "Third answer"]));
        @test isempty(response_issues(path));
        @test response_is_complete(path);
        write(path, answer_fixture(["TODO: Fill this in", "", "<!-- only a comment -->"]));
        issues = response_issues(path);
        @test length(issues) == 3;
        @test occursin("Question 1 still contains TODO", issues[1]);
        @test occursin("Question 2 has no answer", issues[2]);
        @test occursin("Question 3 has no answer", issues[3]);
        write(path, answer_fixture(["Answer <!-- TODO hidden comment -->", "todo: explain", "---"]));
        issues = response_issues(path);
        @test length(issues) == 2;
        @test occursin("Question 2 still contains TODO", issues[1]);
        @test occursin("Question 3 has no answer", issues[2]);
        complete = answer_fixture(["One", "Two", "Three"]);
        for marker in ("<!-- answer-2:start -->", "<!-- answer-2:end -->")
            write(path, replace(complete, marker => ""));
            @test startswith(only(response_issues(path)), "Question 2: Keep one");
            write(path, complete * "\n" * marker);
            @test startswith(only(response_issues(path)), "Question 2: Keep one");
        end
        write(path, replace(complete, "<!-- answer-2:start -->\nTwo\n<!-- answer-2:end -->" =>
            "<!-- answer-2:end -->\nTwo\n<!-- answer-2:start -->"));
        @test startswith(only(response_issues(path)), "Question 2: Keep one");
    end
end

@testset "Docstring feedback" begin
    # This binding deliberately has no docstring so the missing-docstring case can run.
    Core.eval(Main, :(undocumented_fixture = () -> nothing));
    @test code_is_documented([:documented_fixture]);
    @test missing_docstrings([:documented_fixture, :undocumented_fixture, :undefined_fixture]) ==
        [:undocumented_fixture, :undefined_fixture];
    @test !code_is_documented([:undocumented_fixture]);
end

@testset "Grading thresholds" begin
    for total in (20, 27), passed in 0:total
        results = [(passed=i <= passed,) for i in 1:total];
        expected = passed == 0 ? 0 : 2*passed <= total ? 1 : passed < total ? 2 : 3;
        @test rubric_score(results; tests_ran=true, completion=false) == expected;
        @test rubric_score(results; tests_ran=false, completion=false) == 0;
        @test rubric_score(results; tests_ran=true, completion=true) == (passed == total ? 4 : expected);
        reviewed = 2*passed > total && passed < total ? 3 : expected;
        @test rubric_score(results; tests_ran=true, completion=false, minor_error_review=true) == reviewed;
        @test rubric_score(results; tests_ran=true, completion=true, minor_error_review=true) ==
            (passed == total ? 4 : reviewed);
        @test rubric_score(results; tests_ran=false, completion=false, minor_error_review=true) == 0;
    end
end
