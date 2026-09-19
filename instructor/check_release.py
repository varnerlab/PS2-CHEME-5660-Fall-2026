"""Check the student ZIP, completed solutions, partial credit, and failure reports."""

import csv
import io
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from zipfile import ZipFile

from build_release import ROOT, build_release


def run_case(folder: Path, label: str, expected: str) -> str:
    """Run the checker in folder and save its output under solution/results.

    label names the saved report. Require a normal exit, the expected pass-count
    text, and a submission record. Return stdout. A failed requirement raises
    AssertionError; a Julia run lasting over three minutes raises TimeoutExpired.
    Julia inherits the caller's package environment and uses folder's project.
    """
    run = subprocess.run(
        ["julia", f"--project={folder}", "--startup-file=no", str(folder / "check_submission.jl")],
        cwd=folder.parent, env=os.environ.copy(), capture_output=True, text=True, timeout=180,
    )
    results = ROOT / "solution/results"
    results.mkdir(parents=True, exist_ok=True)
    (results / f"{label}.txt").write_text(run.stdout + run.stderr)
    assert run.returncode == 0, (label, run.stderr)
    assert expected in run.stdout, (label, run.stdout)
    assert (folder / "MANIFEST.txt").is_file(), label
    print(f"PASS {label}: {expected}", flush=True)
    return run.stdout


def install_solution(folder: Path, track: str) -> None:
    """Copy a reference solution into a temporary student folder and select it.

    folder is a temporary extracted release; track is Standard or Advanced.
    Fill answer blocks with test-only text so the checker's completion detector
    can be exercised. This text is not a reference answer or an accepted response.
    """
    shutil.copy2(ROOT / f"solution/src/{track}.jl", folder / f"src/{track}.jl")
    (folder / "TRACK.txt").write_text(track.lower() + "\n")
    path = folder / f"responses/{track}.md"
    text = re.sub(r"TODO:.*", "Text used only to check answer-block detection.", path.read_text())
    path.write_text(text)


def check_results(folder: Path) -> None:
    """Compare the completed Advanced CSV with independent Python calculations.

    Read the price file and report in folder. Recompute the lattice tail from
    binomial weights and the GBM probability with math.erfc. Check all three
    holding periods, observed 2026 outcomes, and the 63-day exported nodes.
    Raise AssertionError on a mismatch. The calculation uses Python math only,
    not the Julia functions.
    """
    with (folder / "data/AAPL-2025.csv").open() as source:
        prices = [float(row["price"]) for row in csv.DictReader(source)]
    ratios = [b / a for a, b in zip(prices, prices[1:])]
    up = [r for r in ratios if r > 1]
    down = [r for r in ratios if r < 1]
    u, d, p = sum(up) / len(up), sum(down) / len(down), len(up) / len(ratios)
    returns = [math.log(r) for r in ratios]
    average = sum(returns) / len(returns)
    variance = sum((r - average) ** 2 for r in returns) / (len(returns) - 1)
    mu_g, sigma = average * 252, math.sqrt(variance * 252)
    mu = mu_g + sigma * sigma / 2
    with (folder / "data/AAPL-2026.csv").open() as source:
        observed = list(csv.DictReader(source))
    assert len(observed) == 170
    assert observed[0]["date"] == "2026-01-02"
    expected_dates = {21: "2026-02-02", 63: "2026-04-02", 126: "2026-07-06"}
    rows = list(csv.DictReader(io.StringIO((folder / "results/advanced-results.csv").read_text())))
    assert [int(row["trading_days"]) for row in rows] == [21, 63, 126]
    for row in rows:
        n = int(row["trading_days"])
        time = n / 252
        lattice = sum(math.comb(n, k) * p ** k * (1-p) ** (n-k) for k in range(n+1)
                      if u ** k * d ** (n-k) * math.exp(-0.05*time) > 1)
        gbm = 0.5 * math.erfc((0.05-mu_g)*math.sqrt(time)/(sigma*math.sqrt(2)))
        assert abs(float(row["lattice_probability"]) - lattice) < 1e-8
        assert abs(float(row["gbm_probability"]) - gbm) < 1e-12
        assert abs(float(row["gbm_expected_scaled_npv"]) - math.expm1((mu-0.05)*time)) < 1e-12
        assert abs(float(row["sale_price_to_match_benchmark"]) - prices[-1]*math.exp(0.05*time)) < 1e-10
        sale = observed[n-1]  # observation 1 is the first trading day after purchase
        actual_price = float(sale["price"])
        actual_npv = actual_price/prices[-1]*math.exp(-0.05*time)-1
        assert row["sale_date"] == sale["date"] == expected_dates[n]
        assert float(row["observed_sale_price"]) == actual_price
        assert abs(float(row["observed_scaled_npv"])-actual_npv) < 1e-12
        assert (row["observed_beats_benchmark"] == "true") == (actual_npv > 0)
    nodes = list(csv.DictReader(io.StringIO((folder / "results/terminal-nodes.csv").read_text())))
    assert len(nodes) == 64
    assert abs(sum(float(row["probability"]) for row in nodes)-1) < 1e-8
    for row in nodes:
        rho = float(row["price"])/prices[-1]*math.exp(-0.05*63/252)-1
        assert abs(float(row["scaled_npv"])-rho) < 1e-12
        assert (row["positive_npv"] == "true") == (rho > 0)
    print("PASS independent Python forecasts, observed outcomes, and exported nodes", flush=True)


def check_observation_separation(folder: Path) -> None:
    """Change only 2026 prices and confirm forecasts stay unchanged.

    folder must contain the completed Advanced solution and its report. Raise
    every comparison price by 50%, run the checker, and compare the forecast
    fields and exported lattice with the original values. Observed NPVs must
    change. Restore the original comparison data before returning. This is an
    instructor check and does not add to the student's graded test count.
    """
    path = folder / "data/AAPL-2026.csv"
    original = path.read_bytes()
    report = folder / "results/advanced-results.csv"
    forecasts = list(csv.DictReader(io.StringIO(report.read_text())))
    nodes = (folder / "results/terminal-nodes.csv").read_bytes()
    rows = list(csv.DictReader(io.StringIO(original.decode())))
    try:
        with path.open("w", newline="") as output:
            writer = csv.DictWriter(output, fieldnames=["date", "ticker", "price"])
            writer.writeheader()
            for row in rows:
                writer.writerow({**row, "price": 1.5*float(row["price"])})
        run_case(folder, "advanced-changed-observations", "Public tests: 27/27 passed")
        changed = list(csv.DictReader(io.StringIO(report.read_text())))
        for before, after in zip(forecasts, changed, strict=True):
            for field in ("trading_days", "sale_price_to_match_benchmark", "lattice_probability",
                          "probability_sum", "gbm_probability", "gbm_expected_scaled_npv", "sale_date"):
                assert before[field] == after[field], field
            expected_npv = 1.5*(float(before["observed_scaled_npv"])+1)-1
            assert abs(float(after["observed_scaled_npv"])-expected_npv) < 1e-12
            assert after["observed_beats_benchmark"] == "true"
        assert (folder / "results/terminal-nodes.csv").read_bytes() == nodes
    finally:
        path.write_bytes(original)
    print("PASS changing 2026 observations changes outcomes but leaves forecasts unchanged", flush=True)


def check_missing_outcomes(folder: Path, track: str, output: str) -> None:
    """Require empty outcome fields and no printed answers when student code fails.

    Check the report for all three holding periods. Forecasts may still be
    available from other completed student functions. The report must not
    substitute supplied calculations for the missing observed-outcome result.
    """
    fields = ("sale_price_to_match_benchmark", "sale_date", "observed_sale_price",
              "observed_scaled_npv", "observed_beats_benchmark")
    with (folder / f"results/{track}-results.csv").open() as source:
        rows = list(csv.DictReader(source))
    assert [row["trading_days"] for row in rows] == ["21", "63", "126"]
    assert all(row[field] == "" for row in rows for field in fields)
    assert output.count("observed outcome: UNAVAILABLE") == 3
    for label in ("Observed sale on", "Observed scaled NPV =", "Sale price to match the benchmark ="):
        assert label not in output, label
    print(f"PASS {track}: missing student outcomes are not supplied by the report", flush=True)


def check_student_outcome_reporting(folder: Path) -> None:
    """Check missing, independently completed, and incorrect student outcomes.

    Exercise both tracks without changing their public check totals. Confirm
    that completed forecast functions cannot provide missing observed outcomes,
    that the observed-outcome function can earn credit independently, and that
    the report displays student-returned values rather than recomputing them.
    Restore the completed Advanced solution before returning.
    """
    function_pattern = re.compile(r"^function observed_outcome\(.*?^end$", re.M | re.S)
    stub = (
        "function observed_outcome(initial_price::Float64, observed::NamedTuple, days::Int,\n"
        "    benchmark::Float64, dt::Float64)::NamedTuple\n"
        '    error("unfinished observed outcome");\nend'
    )
    for track, old_checks, total in (("Standard", 15, 20), ("Advanced", 22, 27)):
        install_solution(folder, track)
        path = folder / f"src/{track}.jl"
        solution = path.read_text()
        completed_function = function_pattern.search(solution).group()
        path.write_text(function_pattern.sub(lambda _: stub, solution))
        output = run_case(folder, f"{track.lower()}-missing-outcomes",
                          f"Public tests: {old_checks}/{total} passed")
        check_missing_outcomes(folder, track.lower(), output)
        with (folder / f"results/{track.lower()}-results.csv").open() as source:
            assert all(row["lattice_probability"] for row in csv.DictReader(source))
        starter = (ROOT / f"src/{track}.jl").read_text()
        path.write_text(function_pattern.sub(lambda _: completed_function, starter))
        output = run_case(folder, f"{track.lower()}-outcomes-only", f"Public tests: 5/{total} passed")
        with (folder / f"results/{track.lower()}-results.csv").open() as source:
            rows = list(csv.DictReader(source))
        assert all(row["observed_scaled_npv"] and row["sale_date"] for row in rows)
        assert all(row["lattice_probability"] == "" for row in rows)

    install_solution(folder, "Advanced")
    path = folder / "src/Advanced.jl"
    sentinel = stub.replace('error("unfinished observed outcome");',
        'return (sale_date=Date(2000, 1, 1), sale_price=123.0, benchmark_price=456.0, '
        'scaled_npv=-0.25, beats_benchmark=false);')
    path.write_text(function_pattern.sub(lambda _: sentinel, path.read_text()))
    run_case(folder, "advanced-student-returned-outcomes", "Public tests: 22/27 passed")
    with (folder / "results/advanced-results.csv").open() as source:
        rows = list(csv.DictReader(source))
    for row in rows:
        assert row["sale_date"] == "2000-01-01"
        assert float(row["observed_sale_price"]) == 123.0
        assert float(row["sale_price_to_match_benchmark"]) == 456.0
        assert float(row["observed_scaled_npv"]) == -0.25
        assert row["observed_beats_benchmark"] == "false"
    install_solution(folder, "Advanced")
    print("PASS the report uses student-returned outcomes without recomputing them", flush=True)


def main() -> None:
    """Build the ZIP and check starter, completed, partial, and invalid submissions.

    Preserve the real student files. Test both untouched starters, both completed
    references, an unfinished estimation task, a source syntax error, and an
    invalid track. Also check unfinished answers and missing docstrings when
    all numerical checks pass, separation of forecast and comparison data,
    unfinished observed-outcome functions, use of student-returned outcomes,
    and removal of old result files.
    Saved run logs remain under solution/results; temporary files are removed.
    Require the local Standard and Advanced solutions under solution/src before
    building the release or running any checks.
    """
    for track in ("Standard", "Advanced"):
        path = ROOT / f"solution/src/{track}.jl"
        if not path.is_file():
            raise FileNotFoundError(
                f"Local solution is required for release checks: {path}. "
                "The solution folder is not tracked in Git."
            )
    release = build_release()
    with tempfile.TemporaryDirectory(prefix="PS2 release checks ") as temporary:
        with ZipFile(release) as archive:
            archive.extractall(temporary)
        folder = Path(temporary) / "PS2-CHEME-5660-Fall-2026"
        output = run_case(folder, "standard-starter", "Public tests: 0/20 passed")
        assert "Answers: responses/Standard.md" in output
        check_missing_outcomes(folder, "standard", output)
        for question in range(1, 4):
            assert f"Question {question} still contains TODO" in output
        (folder / "TRACK.txt").write_text("advanced\n")
        output = run_case(folder, "advanced-starter", "Public tests: 0/27 passed")
        assert "Answers: responses/Advanced.md" in output
        check_missing_outcomes(folder, "advanced", output)
        assert "Expected scaled NPV =" not in output
        assert "Mean growth rate =" not in output
        install_solution(folder, "Standard")
        output = run_case(folder, "standard-reference", "Public tests: 20/20 passed")
        assert "Docstrings: All required functions have docstrings." in output
        assert "Local rubric feedback: pending completion review" in output
        # Numerical success must not hide an unfinished answer or missing docstring.
        source = folder / "src/Standard.jl"
        source.write_text(re.sub(r'""".*?"""\n', '', source.read_text(), count=1, flags=re.S))
        response = folder / "responses/Standard.md"
        response.write_text(response.read_text().replace(
            "Text used only to check answer-block detection.", "TODO: Write an answer.", 1))
        output = run_case(folder, "standard-unfinished-response", "Public tests: 20/20 passed")
        assert "Docstrings: Restore the supplied documentation for estimate_lattice." in output
        assert "Question 1 still contains TODO" in output
        assert "Local rubric feedback: pending completion review" in output
        install_solution(folder, "Advanced")
        output = run_case(folder, "advanced-reference", "Public tests: 27/27 passed")
        assert "Docstrings: All required functions have docstrings." in output
        assert "All three answer blocks contain text without TODO." in output
        check_results(folder)
        shutil.copy2(folder / "results/advanced-results.csv", ROOT / "solution/results/advanced-results.csv")
        shutil.copy2(folder / "results/terminal-nodes.csv", ROOT / "solution/results/terminal-nodes.csv")
        check_observation_separation(folder)
        check_student_outcome_reporting(folder)
        # Confirm partial credit when only the first task is unfinished -
        (folder / "TRACK.txt").write_text("standard\n")
        solution = (ROOT / "solution/src/Standard.jl").read_text()
        partial = solution.replace("growth = log_growth_matrix(prices; Δt=dt, risk_free_rate=0.0);",
                                   'error("unfinished estimation task");')
        (folder / "src/Standard.jl").write_text(partial)
        output = run_case(folder, "standard-partial", "Public tests: 15/20 passed")
        assert "Local rubric feedback: 2" in output
        # A bad source file must clear old results and still write a submission record -
        (folder / "src/Standard.jl").write_text("function broken(\n")
        run_case(folder, "invalid-source", "Public tests: 0/20 passed")
        assert not any((folder / "results").glob("*.csv"))
        (folder / "TRACK.txt").write_text("unknown\n")
        run_case(folder, "invalid-track", "Public tests: 0/0 passed")
    print("RELEASE-CHECKS-OK", flush=True)


if __name__ == "__main__":
    main()
