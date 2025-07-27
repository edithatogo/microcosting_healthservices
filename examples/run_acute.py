#!/usr/bin/env python
"""Example script running the acute funding calculator."""

from pathlib import Path
import pandas as pd
import sys
import pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "excel_calculator" / "src"))
from funding_calculator import load_weights, load_formula, calculate_funding


def main():
    weights = load_weights(Path("excel_calculator/data/weights.csv"))
    formula = load_formula(Path("excel_calculator/data/formula.json"))

    # Use the first DRG as a demonstration with no additional adjustments
    row = weights.iloc[0]
    patient = pd.DataFrame({
        "Inlier": [row["Inlier"]],
        "Paediatric Adjustment": [1.0],
        "Adj (Indigenous Status)": [0.0],
        "Adjustment.1 (Patient Remoteness)": [0.0],
        "Treatment Remoteness Adjustment": [0.0],
        "Dialysis Adjustment": [0.0],
        "Private Service Adjustment": [0.0],
        "COVID-19 Treatment Adjustment": [0.0],
        "Bundled ICU": [0.0],
        "ICU Hours": [0.0],
        "Private Service Percentage": [0.0],
        "Length of Stay": [10.0],
        "Private Patient Accommodation Adjustment": [0.0],
        "HAC Adjustment": [0.0],
        "Readmission weight": [0.0],
        "Readmission adjustment": [0.0],
        "National Efficient Price": [7258.0],
    })

    funding = calculate_funding(patient, formula)
    print(f"Calculated funding: {funding.iloc[0]:.4f}")


if __name__ == "__main__":
    main()
