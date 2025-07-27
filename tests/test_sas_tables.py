import sys
import pytest
import pandas as pd
from pathlib import Path
import sys
import pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "excel_calculator" / "src"))

from funding_calculator import load_formula, calculate_funding

DATA_DIR = Path(__file__).resolve().parents[0] / "data"


def test_converted_tables_shapes():
    assert pd.read_csv(DATA_DIR / "drg11_masterlist.csv").shape == (801, 18)
    assert pd.read_csv(DATA_DIR / "nep25_aa_price_weights.csv").shape == (798, 12)
    assert pd.read_csv(DATA_DIR / "p_intercept.csv").shape == (1, 14)


def test_calculate_nwau_from_sas_weights():
    weights = pd.read_csv(DATA_DIR / "nep25_aa_price_weights.csv")
    weights["DRG"] = weights["DRG"].str.strip("b'")
    row = weights[weights["DRG"] == "801A"].iloc[0]
    df = pd.DataFrame({
        "Inlier": [row["drg_pw_inlier"]],
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
    formula = load_formula("excel_calculator/data/formula.json")
    result = calculate_funding(df, formula)
    assert result.iloc[0] == pytest.approx(67116.1776, rel=1e-4)
