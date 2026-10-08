"""Build and verify the solution archive from the published student tag.

Run from the repository root: python3 instructor/build_solution_release.py
Requires the local solution files under solution/ (ignored by Git):
solution/README.md, solution/src/{Standard,Advanced}.jl, and
solution/responses/{Standard,Advanced}.md.

Writes dist/solution-release/CHEME-5660-PS2-Solution-2026.1.zip, its SHA256,
and both checker reports. This does not create a commit, push a tag, or
publish a GitHub release.
"""

from pathlib import Path
import hashlib
import io
import re
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parent.parent
STUDENT_TAG = "ps2-cheme-5660-2026.1"
ARCHIVE_NAME = "CHEME-5660-PS2-Solution-2026.1"
OUTPUT = ROOT / "dist" / "solution-release"
TRACKS = (("standard", "Standard", 20), ("advanced", "Advanced", 27))

# Values printed by the checker that the worked answers must report -
SHARED_VALUES = ("1.01041898", "0.98852853", "55.0201", "272.2992", "275.7243",
                 "273.4361", "279.1925", "51.2433", "61.7141", "62.9059",
                 "266.5831", "254.6924", "312.0838", "-2.5063", "-7.6279", "11.7809",
                 "273.6641", "69.4252")
ADVANCED_VALUES = ("10.9686", "26.4020", "14.4540", "52.6016", "54.4998", "56.3502",
                   "60.5259", "49.0027", "0.7528")
SAVED_RESULTS = {
    "standard": ("standard-results.csv",),
    "advanced": ("advanced-results.csv", "benchmark-comparison.csv", "terminal-nodes.csv"),
}


def run_julia(folder, *arguments):
    """Run the documented environment and preserve diagnostics for a failed check."""
    result = subprocess.run(
        ["julia", "--project=.", "--startup-file=no", *arguments],
        cwd=folder, capture_output=True, text=True,
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout + result.stderr


def run_checker(folder, track, total):
    """Run one track through the normal student command and check its report."""
    (folder / "TRACK.txt").write_text(track + "\n")
    report = run_julia(folder, "check_submission.jl")
    assert f"Public tests: {total}/{total} passed" in report, report
    assert "Docstrings: All required functions have docstrings." in report, report
    assert "All three answer blocks contain text without TODO." in report, report
    assert "Local rubric feedback: pending completion review" in report, report
    assert "UNAVAILABLE" not in report, report
    return report


def docstrings(text):
    return re.findall(r'"""(.*?)"""', text, re.S)


def questions(text):
    """Return the question text: everything from Question 1 on, without the answers."""
    text = text[text.index("\n## 1."):]
    return re.sub(r"(<!-- answer-(\d):start -->).*?(<!-- answer-\2:end -->)", r"\1\3", text, flags=re.S)


def check_documents(folder, original):
    """Check local links, completed answers, unchanged questions, and unchanged docstrings."""
    paths = [folder / "README.md", *sorted((folder / "responses").glob("*.md"))]
    for path in paths:
        text = path.read_text()
        assert "TODO" not in text, path
        for link in re.findall(r"\]\(([^)]+)\)", text):
            if "://" not in link and not link.startswith("#"):
                assert (path.parent / link.split("#")[0]).exists(), (path, link)
    for _, name, _ in TRACKS:
        answers = (folder / "responses" / f"{name}.md").read_text()
        starter = original[f"responses/{name}.md"].decode()
        assert questions(answers) == questions(starter), name
        for index in range(1, 4):
            start = f"<!-- answer-{index}:start -->"
            end = f"<!-- answer-{index}:end -->"
            assert answers.count(start) == answers.count(end) == 1, name
            assert answers.split(start)[1].split(end)[0].strip(), name
        values = SHARED_VALUES + (ADVANCED_VALUES if name == "Advanced" else ())
        for value in values:
            assert value in answers, (name, value)
        code = (folder / "src" / f"{name}.jl").read_text()
        assert docstrings(code) == docstrings(original[f"src/{name}.jl"].decode()), name
        assert "TODO" not in code and "error(" not in code, name


def write_archive(folder, destination):
    """Write deterministic file contents and timestamps under one archive root."""
    with zipfile.ZipFile(destination, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(folder.rglob("*")):
            if path.is_file():
                name = f"{ARCHIVE_NAME}/{path.relative_to(folder).as_posix()}"
                info = zipfile.ZipInfo(name, date_time=(2026, 10, 8, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                archive.writestr(info, path.read_bytes())


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    student_bytes = subprocess.check_output(
        ["git", "archive", "--format=zip", STUDENT_TAG], cwd=ROOT
    )
    with tempfile.TemporaryDirectory(prefix="ps2 solution review ") as temporary:
        workspace = Path(temporary)
        folder = workspace / ARCHIVE_NAME
        with zipfile.ZipFile(io.BytesIO(student_bytes)) as archive:
            archive.extractall(folder)
            original = {name: archive.read(name) for name in archive.namelist() if not name.endswith("/")}

        # Replace only the completed task files and the archive's opening guide -
        (folder / "ASSIGNMENT.md").write_bytes(original["README.md"])
        shutil.copyfile(ROOT / "solution/README.md", folder / "README.md")
        for _, name, _ in TRACKS:
            shutil.copyfile(ROOT / "solution/src" / f"{name}.jl", folder / "src" / f"{name}.jl")
            shutil.copyfile(ROOT / "solution/responses" / f"{name}.md", folder / "responses" / f"{name}.md")

        manifest = (folder / "Manifest.toml").read_bytes()
        run_julia(folder, "-e", "using Pkg; Pkg.instantiate()")
        assert (folder / "Manifest.toml").read_bytes() == manifest
        print("PASS: documented package setup; recorded versions unchanged", flush=True)

        # Each run clears all generated CSV files, so save each track's files after its run -
        saved = workspace / "saved-results"
        saved.mkdir()
        for track, name, total in TRACKS:
            report = run_checker(folder, track, total)
            (OUTPUT / f"{track}-verification.txt").write_text(report)
            answers = (folder / "responses" / f"{name}.md").read_text()
            values = SHARED_VALUES + (ADVANCED_VALUES if track == "advanced" else ())
            for value in values:
                assert value in report, (track, value)
            for result in SAVED_RESULTS[track]:
                shutil.copyfile(folder / "results" / result, saved / result)
            print(f"PASS: {track}, {total}/{total} checks, completed answers, and numerical report", flush=True)

        shutil.rmtree(folder / "results")
        shutil.copytree(saved, folder / "reference-results")
        (folder / "MANIFEST.txt").unlink()
        (folder / "TRACK.txt").write_bytes(original["TRACK.txt"])
        check_documents(folder, original)

        changed = {"README.md", "src/Standard.jl", "src/Advanced.jl", "responses/Standard.md", "responses/Advanced.md"}
        for name, content in original.items():
            if name not in changed:
                assert (folder / name).read_bytes() == content, name
        added = {"ASSIGNMENT.md", *(f"reference-results/{result}" for results in SAVED_RESULTS.values() for result in results)}
        files = {path.relative_to(folder).as_posix() for path in folder.rglob("*") if path.is_file()}
        assert files == set(original) | added, files ^ (set(original) | added)
        assert all(not name.startswith(("instructor/", "solution/", ".git/", "dist/")) for name in files)
        print("PASS: answer values, unchanged questions and docstrings, local links, and file allowlist", flush=True)

        destination = OUTPUT / f"{ARCHIVE_NAME}.zip"
        write_archive(folder, destination)

        # Test the actual downloadable ZIP in a new path containing spaces -
        extracted = workspace / "fresh extraction"
        with zipfile.ZipFile(destination) as archive:
            assert archive.testzip() is None
            archive.extractall(extracted)
        final = extracted / ARCHIVE_NAME
        for track, _, total in TRACKS:
            run_checker(final, track, total)
            for result in SAVED_RESULTS[track]:
                assert (final / "results" / result).read_bytes() == (folder / "reference-results" / result).read_bytes(), result
        digest = hashlib.sha256(destination.read_bytes()).hexdigest()
        (OUTPUT / f"{ARCHIVE_NAME}.zip.sha256").write_text(f"{digest}  {destination.name}\n")
        print(f"SOLUTION-ARCHIVE-OK: {len(files)} files, both extracted tracks verified", flush=True)
        print(f"SHA256: {digest}", flush=True)
        print(destination, flush=True)


if __name__ == "__main__":
    main()
