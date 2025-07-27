import importlib.util
from pathlib import Path
import sys
import numpy as np
import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "ed",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "ed.py",
)
ed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ed)

DATA = pd.DataFrame(
    {
        "AECC": ["E0110A"],
        "Error_Code": [0],
        "COMPENSABLE_STATUS": [2],
        "DVA_STATUS": [2],
        "adj_indigenous": [0.0],
        "adj_remoteness": [0.0],
        "adj_treat_remoteness": [0.0],
    }
)

EXPECTED = 0.2837


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_ed_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({"AECC": ["E0110A"], "AECC_pw": [EXPECTED]})

    def _load(ref_dir: Path, classification_option: int, year: str = "2025") -> pd.DataFrame:
        return weights

    monkeypatch.setattr(ed, "_load_weights", _load)

    result = ed.calculate_ed(
        DATA.copy(),
        ed.EDParams(classification_option=3),
        year=year,
        ref_dir=Path("unused"),
    )
    assert result["NWAU25"].iloc[0] == pytest.approx(EXPECTED, rel=1e-4)

CALC_DIR = Path("archive/sas/NEP25_SAS_NWAU_calculator/calculators")


def test_calculate_ed_aecc_basic():
    weights = pd.read_sas(CALC_DIR / "nep25_edaecc_price_weights.sas7bdat")
    weights["AECC"] = weights["AECC"].str.decode("ascii")
    row = weights[weights["AECC"] == "E0110A"].iloc[0]

    df = pd.DataFrame(
        {
            "AECC": ["E0110A"],
            "COMPENSABLE_STATUS": [2],
            "DVA_STATUS": [2],
            "adj_indigenous": [0.0],
            "adj_remoteness": [0.0],
            "adj_treat_remoteness": [0.03],
        }
    )

    result = ed.calculate_ed(
        df,
        ed.EDParams(classification_option=3),
        year="2025",
        ref_dir=CALC_DIR,
    )

    expected = round(row["AECC_pw"] * 1.03, 8)
    assert result["GWAU25"].iloc[0] == pytest.approx(expected)
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0


def test_calculate_ed_udg_mapping_and_errors():
    weights = pd.read_sas(CALC_DIR / "nep25_edudg_price_weights.sas7bdat")
    weights["UDG"] = weights["UDG"].str.decode("ascii")
    udg_pw = weights[weights["UDG"] == "UDG01"].iloc[0]["udg_pw"]

    df = pd.DataFrame(
        {
            "type_of_visit": [1, 1, 1],
            "triage_category": [1, 1, 1],
            "episode_end_status": [1, 9, 1],
            "COMPENSABLE_STATUS": [2, 2, 1],
            "DVA_STATUS": [2, 2, 2],
            "adj_treat_remoteness": [0.0, 0.0, 0.0],
        }
    )

    result = ed.calculate_ed(
        df,
        ed.EDParams(classification_option=1),
        year="2025",
        ref_dir=CALC_DIR,
    )

    expected = round(udg_pw, 6)
    assert result.loc[0, "GWAU25"] == pytest.approx(expected)
    assert result.loc[0, "Error_Code"] == 0
    assert result.loc[0, "NWAU25"] == pytest.approx(expected)

    assert result.loc[1, "Error_Code"] == 3
    assert result.loc[1, "NWAU25"] == 0

    assert result.loc[2, "Error_Code"] == 2
    assert result.loc[2, "NWAU25"] == 0
