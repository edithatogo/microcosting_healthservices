from __future__ import annotations

import importlib.util
import sys
import types
from pathlib import Path

import numpy as np
import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import validation_tooling as validation

PYREADSTAT = types.ModuleType("pyreadstat")
PYREADSTAT.ReadstatError = Exception
PYREADSTAT._readstat_parser = types.SimpleNamespace(PyreadstatError=Exception)
sys.modules.setdefault("pyreadstat", PYREADSTAT)

ACUTE_PATH = Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "acute.py"
SPEC = importlib.util.spec_from_file_location("validation_tooling_acute", ACUTE_PATH)
assert SPEC is not None and SPEC.loader is not None
acute = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(acute)

BASE = Path("tests/data")


def _load_weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
    weights = pd.read_csv(BASE / "nep25_aa_price_weights.csv")
    weights["DRG"] = weights["DRG"].str.strip("b'")
    return weights


def _acute_frame_strategy(hypothesis):
    st = hypothesis.strategies
    row = st.fixed_dictionaries(
        {
            "DRG": st.sampled_from(["801A", "801B", "801C"]),
            "LOS": st.integers(min_value=1, max_value=90),
            "ICU_HOURS": st.integers(min_value=0, max_value=24),
            "ICU_OTHER": st.integers(min_value=0, max_value=24),
            "PAT_SAMEDAY_FLAG": st.integers(min_value=0, max_value=1),
            "PAT_PRIVATE_FLAG": st.integers(min_value=0, max_value=1),
            "PAT_COVID_FLAG": st.integers(min_value=0, max_value=1),
            "COVID_ADJ_FLAG": st.integers(min_value=0, max_value=1),
            "PAT_RADIOTHERAPY_FLAG": st.integers(min_value=0, max_value=1),
            "PAT_DIALYSIS_FLAG": st.integers(min_value=0, max_value=1),
            "EST_ELIGIBLE_ICU_FLAG": st.integers(min_value=0, max_value=1),
            "EST_ELIGIBLE_PAED_FLAG": st.integers(min_value=0, max_value=1),
            "EST_REMOTENESS": st.integers(min_value=0, max_value=5),
            "STATE": st.integers(min_value=1, max_value=8),
        }
    )
    return st.lists(row, min_size=1, max_size=4).map(
        lambda rows: pd.DataFrame(
            rows,
            columns=[
                "DRG",
                "LOS",
                "ICU_HOURS",
                "ICU_OTHER",
                "PAT_SAMEDAY_FLAG",
                "PAT_PRIVATE_FLAG",
                "PAT_COVID_FLAG",
                "COVID_ADJ_FLAG",
                "PAT_RADIOTHERAPY_FLAG",
                "PAT_DIALYSIS_FLAG",
                "EST_ELIGIBLE_ICU_FLAG",
                "EST_ELIGIBLE_PAED_FLAG",
                "EST_REMOTENESS",
                "STATE",
            ],
        )
    )


def _starter_params() -> acute.AcuteParams:
    return acute.AcuteParams(
        icu_paed_option=2,
        covid_option=2,
        covid_adj_option=2,
        radiotherapy_option=2,
        dialysis_option=2,
        ppservadj=2,
        est_remoteness_option=2,
    )


def test_validation_tooling_mutmut_starter_targets_focus_on_pure_modules():
    assert validation.MUTATION_TARGETS == (
        "nwau_py/calculators/adjust.py",
        "nwau_py/calculators/funding_formula.py",
        "nwau_py/utils.py",
    )
    assert all("loader.py" not in target for target in validation.MUTATION_TARGETS)
    assert all("archive/" not in target for target in validation.MUTATION_TARGETS)
    assert all("tests/" not in target for target in validation.MUTATION_TARGETS)


def test_validation_tooling_scalene_reports_stay_under_cache_tree():
    report_path = validation.scalene_report_path("acute starter profile")
    assert report_path == Path(".cache/validation/scalene/acute_starter_profile.txt")
    assert not report_path.is_absolute()
    assert report_path.parts[:3] == (".cache", "validation", "scalene")


def test_validation_tooling_hypothesis_profile_budget_is_small():
    assert validation.hypothesis_settings_kwargs() == {
        "max_examples": 5,
        "deadline": None,
    }


def test_validation_tooling_hypothesis_acute_output_shape_and_finiteness(monkeypatch):
    hypothesis = pytest.importorskip("hypothesis")
    from hypothesis import given, settings

    @given(frame=_acute_frame_strategy(hypothesis))
    @settings(**validation.hypothesis_settings_kwargs())
    def run_case(frame: pd.DataFrame) -> None:
        monkeypatch.setattr(acute, "_load_price_weights", _load_weights)
        result = acute.calculate_acute(
            frame,
            _starter_params(),
            year="2025",
            ref_dir=BASE / "2025",
        )
        assert len(result) == len(frame)
        assert "NWAU25" in result.columns
        assert np.isfinite(result["NWAU25"].astype(float)).all()
        assert result["NWAU25"].ge(0).all()

    run_case()
