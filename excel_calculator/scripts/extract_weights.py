import argparse
from pathlib import Path

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
SHEET_NAME = 'Parameters'


def build_paths(year: str) -> tuple[Path, Path]:
    """Return the workbook and output CSV paths for ``year``."""
    yy = year[-2:]
    input_file = (
        BASE_DIR
        / "archive"
        / year
        / f"nwau{yy}_calculator_for_acute_activity.xlsb"
    )
    output_path = BASE_DIR / "data" / year / "weights.csv"
    return input_file, output_path

def main(argv: list[str] | None = None) -> None:
    """Extract price weights from the official workbook."""
    parser = argparse.ArgumentParser(description="Extract NWAU weights")
    parser.add_argument(
        "--year", default="2025", help="NEP/NWAU edition year", metavar="YEAR"
    )
    args = parser.parse_args(argv)

    input_file, output_path = build_paths(args.year)
    df = pd.read_excel(input_file, sheet_name=SHEET_NAME, engine="pyxlsb")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)
    print(f"Wrote {len(df)} rows to {output_path}")

if __name__ == '__main__':
    main()
