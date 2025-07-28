import pathlib
import sys

import pandas as pd
import pytest

pkg_root = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(pkg_root / "excel_calculator" / "src"))

from funding_calculator import (  # noqa: E402
    calculate_funding,
    load_formula,
    load_weights,
)


def test_load_weights_normalises_columns(tmp_path):
    csv = tmp_path / "weights.csv"
    csv.write_text('"A\nB"\n1\n')
    df = load_weights(csv)
    assert df.columns.tolist() == ["A B"]


def test_calculate_funding_example():
    formula = load_formula("excel_calculator/data/formula.json")
    df = pd.DataFrame(
        {
            "Inlier": [9.2472],
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
        }
    )
    result = calculate_funding(df, formula)
    assert result.iloc[0] == pytest.approx(67116.1776, rel=1e-4)
