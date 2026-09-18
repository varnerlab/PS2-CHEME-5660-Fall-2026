"""Build the student ZIP from an explicit list of assignment files."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parents[1]
RELEASE_FILES = [
    "README.md", "RUBRIC.md", "Project.toml", "Manifest.toml", "LICENSE",
    "TRACK.txt", "Include.jl", "check_submission.jl",
    "src/Standard.jl", "src/Advanced.jl", "src/Support.jl",
    "responses/Standard.md", "responses/Advanced.md",
    "data/README.md", "data/AAPL-2025.csv", "data/AAPL-2026.csv", "reports/Finance.jl",
    "test/Rubric.jl", "test/public_standard_tests.jl", "test/public_advanced_tests.jl",
]


def build_release() -> Path:
    """Write and return the student ZIP path under dist; exclude instructor files.

    Read only RELEASE_FILES from ROOT. Require both source files and response
    files to retain their student TODOs. Missing files or completed source files
    stop the build with an exception. Replace an existing ZIP with the same name.
    """
    assert (ROOT / "TRACK.txt").read_text().strip() == "standard"
    for track, functions in (("Standard", 3), ("Advanced", 5)):
        source = (ROOT / f"src/{track}.jl").read_text()
        assert source.count('error("Complete ') == functions, track
        assert (ROOT / f"responses/{track}.md").read_text().count("TODO:") == 3
    destination = ROOT / "dist/PS2-CHEME-5660-Fall-2026-student.zip"
    destination.parent.mkdir(exist_ok=True)
    with ZipFile(destination, "w", compression=ZIP_DEFLATED) as archive:
        for name in RELEASE_FILES:
            archive.write(ROOT / name, f"PS2-CHEME-5660-Fall-2026/{name}")
    with ZipFile(destination) as archive:
        assert len(archive.namelist()) == len(RELEASE_FILES)
        assert not any("/instructor/" in name for name in archive.namelist())
        assert archive.testzip() is None
    return destination


if __name__ == "__main__":
    print(build_release())
