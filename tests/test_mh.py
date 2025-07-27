import importlib.util
import sys
from pathlib import Path

import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "mh",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "mh.py",
)
mh = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mh)

DATA = pd.DataFrame(
    {
        "AMHCC": ["111A"],
        "PAT_PRIVATE_FLAG": [0],
        "PAT_SAMEDAY_FLAG": [0],
        "LOS": [10],
        "STATE": [1],
        "_pat_specpaed": [0],
        "_pat_ind_flag": [0],
        "_pat_remoteness": [0],
        "_treat_remoteness": [0],
        "SC_PAT_PUB": [0],
        "SC_NOPAT_PUB": [0],
    }
)

EXPECTED = 7.0317


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_mh_matches_sas_weights(monkeypatch, year):
    tables = {
        "adm": pd.DataFrame(
            {
                "AMHCC": ["111A"],
                "amhcc_pw_inlier": [EXPECTED],
                "amhcc_inlier_lb": [0],
                "amhcc_inlier_ub": [1],
                "amhcc_pw_sso_base": [0],
                "amhcc_pw_lso_perdiem": [0],
                "amhcc_pw_sso_perdiem": [0],
                "priceCat": [1],
            }
        ),
        "cmty": pd.DataFrame(
            {"AMHCC": ["111A"], "_cmty_sc_pat_pw": [0], "_cmty_sc_nopat_pw": [0]}
        ),
        "ppsa": pd.DataFrame(
            {
                "amhccV1code": ["111A"],
                "state": [1],
                "amhcc_adj_privPat_servNat": [0],
                "amhcc_adj_privPat_serv": [0],
            }
        ),
        "priv_acc": pd.DataFrame(
            {
                "State": [1],
                "state_adj_privpat_accomm_sd": [0],
                "state_adj_privpat_accomm_on": [0],
            }
        ),
        "specpaed": pd.DataFrame({"_pat_specpaed": [0], "adj_specpaed": [1]}),
        "adj_ind": pd.DataFrame({"_pat_ind_flag": [0], "adj_indigenous": [0]}),
        "adj_rem": pd.DataFrame({"_pat_remoteness": [0], "adj_remoteness": [0]}),
        "adj_treat": pd.DataFrame(
            {"_treat_remoteness": [0], "adj_treat_remoteness": [0]}
        ),
    }

    def _load(ref_dir: Path, year: str = "2025") -> dict[str, pd.DataFrame]:
        return tables

    monkeypatch.setattr(mh, "_load_weights", _load)

    result = mh.calculate_mh(
        DATA.copy(),
        mh.MHParams(),
        year=year,
        ref_dir=Path("unused"),
    )
    assert result["NWAU25"].iloc[0] == pytest.approx(EXPECTED, rel=1e-4)

