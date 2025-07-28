import subprocess
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
ARCHIVE_DIR = BASE_DIR.parent / "archive"

YEARS = [str(y) for y in range(2014, 2026)]


def main() -> None:
    for year in YEARS:
        workbook = (
            ARCHIVE_DIR
            / year
            / f"nwau{year[-2:]}_calculator_for_acute_activity.xlsb"
        )
        if not workbook.exists():
            print(f"Workbook for {year} not found, skipping", file=sys.stderr)
            continue
        subprocess.run(
            [sys.executable, BASE_DIR / "extract_weights.py", "--year", year],
            check=True,
        )
        subprocess.run(
            [sys.executable, BASE_DIR / "extract_formula.py", "--year", year],
            check=True,
        )


if __name__ == "__main__":
    main()
