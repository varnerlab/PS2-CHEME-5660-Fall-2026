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
    """Run the checker in folder and save its output under instructor/results.

    label names the saved report. Require a normal exit, the expected pass-count
    text, and a submission record. Return stdout. A failed requirement raises
    AssertionError; a Julia run lasting over three minutes raises TimeoutExpired.
    Julia inherits the caller's package environment and uses folder's project.
    """
    run = subprocess.run(
        ["julia", f"--project={folder}", "--startup-file=no", str(folder / "check_submission.jl")],
        cwd=folder.parent, env=os.environ.copy(), capture_output=True, text=True, timeout=180,
    )
    (ROOT / f"instructor/results/{label}.txt").write_text(run.stdout + run.stderr)
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
    shutil.copy2(ROOT / f"instructor/reference/{track}.jl", folder / f"src/{track}.jl")
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
        run_case(folder, "advanced-changed-observations", "Public tests: 22/22 passed")
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


def main() -> None:
    """Build the ZIP and check nine submission states in a temporary directory.

    Preserve the real student files. Test both untouched starters, both completed
    references, an unfinished estimation task, a source syntax error, and an
    invalid track. Also check unfinished answers and missing docstrings when
    all numerical checks pass, separation of forecast and comparison data,
    and removal of old result files.
    Saved run logs remain under instructor/results; temporary files are removed.
    """
    release = build_release()
    with tempfile.TemporaryDirectory(prefix="PS2 release checks ") as temporary:
        with ZipFile(release) as archive:
            archive.extractall(temporary)
        folder = Path(temporary) / "PS2-CHEME-5660-Fall-2026"
        output = run_case(folder, "standard-starter", "Public tests: 0/15 passed")
        assert "Answers: responses/Standard.md" in output
        for question in range(1, 4):
            assert f"Question {question} still contains TODO" in output
        (folder / "TRACK.txt").write_text("advanced\n")
        output = run_case(folder, "advanced-starter", "Public tests: 0/22 passed")
        assert "Answers: responses/Advanced.md" in output
        install_solution(folder, "Standard")
        output = run_case(folder, "standard-reference", "Public tests: 15/15 passed")
        assert "Docstrings: All required functions have docstrings." in output
        assert "Local rubric feedback: pending completion review" in output
        # Numerical success must not hide an unfinished answer or missing docstring.
        source = folder / "src/Standard.jl"
        source.write_text(re.sub(r'""".*?"""\n', '', source.read_text(), count=1, flags=re.S))
        response = folder / "responses/Standard.md"
        response.write_text(response.read_text().replace(
            "Text used only to check answer-block detection.", "TODO: Write an answer.", 1))
        output = run_case(folder, "standard-unfinished-response", "Public tests: 15/15 passed")
        assert "Docstrings: Restore the supplied documentation for estimate_lattice." in output
        assert "Question 1 still contains TODO" in output
        assert "Local rubric feedback: pending completion review" in output
        install_solution(folder, "Advanced")
        output = run_case(folder, "advanced-reference", "Public tests: 22/22 passed")
        assert "Docstrings: All required functions have docstrings." in output
        assert "All three answer blocks contain text without TODO." in output
        check_results(folder)
        shutil.copy2(folder / "results/advanced-results.csv", ROOT / "instructor/results/advanced-results.csv")
        shutil.copy2(folder / "results/terminal-nodes.csv", ROOT / "instructor/results/terminal-nodes.csv")
        check_observation_separation(folder)
        # Confirm partial credit when only the first task is unfinished -
        (folder / "TRACK.txt").write_text("standard\n")
        solution = (ROOT / "instructor/reference/Standard.jl").read_text()
        partial = solution.replace("growth = log_growth_matrix(prices; Δt=dt, risk_free_rate=0.0);",
                                   'error("unfinished estimation task");')
        (folder / "src/Standard.jl").write_text(partial)
        output = run_case(folder, "standard-partial", "Public tests: 10/15 passed")
        assert "Local rubric feedback: 2" in output
        # A bad source file must clear old results and still write a submission record -
        (folder / "src/Standard.jl").write_text("function broken(\n")
        run_case(folder, "invalid-source", "Public tests: 0/15 passed")
        assert not any((folder / "results").glob("*.csv"))
        (folder / "TRACK.txt").write_text("unknown\n")
        run_case(folder, "invalid-track", "Public tests: 0/0 passed")
    print("RELEASE-CHECKS-OK", flush=True)


if __name__ == "__main__":
    main()
