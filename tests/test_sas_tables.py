from pathlib import Path

import pandas as pd
import pytest

import nwau_py.calculators.acute as acute
from nwau_py.calculators import AcuteParams, calculate_acute

DATA_DIR = Path(__file__).resolve().parents[0] / "data"


def test_converted_tables_shapes():
    assert pd.read_csv(DATA_DIR / "drg11_masterlist.csv").shape == (801, 18)
    assert pd.read_csv(DATA_DIR / "nep25_aa_price_weights.csv").shape == (798, 12)
    assert pd.read_csv(DATA_DIR / "p_intercept.csv").shape == (1, 14)


def test_calculate_nwau_from_sas_weights(monkeypatch: pytest.MonkeyPatch) -> None:
    weights = pd.read_csv(DATA_DIR / "nep25_aa_price_weights.csv")
    weights["DRG"] = weights["DRG"].str.strip("b'")

    monkeypatch.setattr(acute, "_load_price_weights", lambda r, year="2025": weights)

    df = pd.DataFrame(
        {
            "DRG": ["801A"],
            "LOS": [10],
            "ICU_HOURS": [0],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [0],
            "PAT_COVID_FLAG": [0],
        }
    )

    result = calculate_acute(
        df,
        AcuteParams(),
        year="2025",
        ref_dir=Path("tests/data/2025"),
    )
    funding = result["NWAU25"].iloc[0] * 7258
    assert funding == pytest.approx(67116.1776, rel=1e-4)
