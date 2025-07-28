import argparse
import json
from pathlib import Path

from pyxlsb import open_workbook

BASE_DIR = Path(__file__).resolve().parents[1]
SHEET_NAME = "Formula breakdown"
CELL = (49, 1)  # row 50 in Excel is index 49 here, column B is index 1

VARIABLES = {
    "PW": "Inlier",
    "APaed": "Paediatric Adjustment",
    "AInd": "Adj (Indigenous Status)",
    "ARes": "Adjustment.1 (Patient Remoteness)",
    "ART": "Treatment Remoteness Adjustment",
    "ADia": "Dialysis Adjustment",
    "ATreat": "Private Service Adjustment",
    "AC19": "COVID-19 Treatment Adjustment",
    "AICU": "Bundled ICU",
    "ICU_hours": "ICU Hours",
    "APPS": "Private Service Percentage",
    "LOS": "Length of Stay",
    "AAcc": "Private Patient Accommodation Adjustment",
    "AHAC": "HAC Adjustment",
    "PWAHR": "Readmission weight",
    "RAHR": "Readmission adjustment",
    "NEP": "National Efficient Price",
}

STEPS = [
    "T1 = PW * APaed",
    "T2 = 1 + AInd + ARes + ART + ADia",
    "T3 = 1 + ATreat",
    "T4 = 1 + AC19",
    "T5 = T1 * T2 * T3 * T4",
    "T6 = AICU * ICU_hours",
    "T7 = T5 + T6",
    "T8 = PW + AICU * ICU_hours",
    "T9 = T8 * APPS",
    "T10 = LOS * AAcc",
    "T11 = T7 - (T9 + T10)",
    "T12 = T11 - PW * AHAC",
    "T13 = T12 - PWAHR * RAHR",
]


def build_paths(year: str) -> tuple[Path, Path]:
    yy = year[-2:]
    input_file = (
        BASE_DIR
        / "archive"
        / year
        / f"nwau{yy}_calculator_for_acute_activity.xlsb"
    )
    output_path = BASE_DIR / "data" / year / "formula.json"
    return input_file, output_path


def extract_formula(wb_path: Path) -> str:
    with open_workbook(wb_path) as wb:
        with wb.get_sheet(SHEET_NAME) as sheet:
            for r, row in enumerate(sheet.rows()):
                if r == CELL[0]:
                    return row[CELL[1]].v
    raise ValueError("Formula cell not found")


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Extract NWAU formula")
    parser.add_argument("--year", default="2025", metavar="YEAR", help="Edition year")
    args = parser.parse_args(argv)

    input_file, output_path = build_paths(args.year)
    formula_str = extract_formula(input_file)
    yy = args.year[-2:]
    formula = {
        "variables": VARIABLES,
        "steps": STEPS + [f"NWAU{yy} = T13 * NEP"],
        "excel_formula": formula_str,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as fh:
        json.dump(formula, fh, indent=2)
    print(f"Wrote formula to {output_path}")


if __name__ == "__main__":
    main()
