from __future__ import annotations

import importlib.util
import sys
import types
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import nwau_py.fixtures as fixtures

PYREADSTAT = types.ModuleType("pyreadstat")
PYREADSTAT.ReadstatError = Exception
PYREADSTAT._readstat_parser = types.SimpleNamespace(PyreadstatError=Exception)
sys.modules.setdefault("pyreadstat", PYREADSTAT)

ACUTE_PATH = Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "acute.py"
SPEC = importlib.util.spec_from_file_location("fixture_acute", ACUTE_PATH)
assert SPEC is not None and SPEC.loader is not None
acute = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(acute)


FIXTURE_MANIFEST = (
    Path(__file__).resolve().parent / "fixtures" / "golden" / "acute_2025" / "manifest.json"
)
BASE = Path("tests/data")


def _load_weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
    weights = pd.read_csv(BASE / "nep25_aa_price_weights.csv")
    weights["DRG"] = weights["DRG"].str.strip("b'")
    return weights


def test_acute_fixture_pack_output_parity(monkeypatch):
    pack = fixtures.load_fixture_pack(FIXTURE_MANIFEST)
    input_df = fixtures.read_payload_frame(pack, "input")
    expected_df = fixtures.read_payload_frame(pack, "expected_output")

    monkeypatch.setattr(acute, "_load_price_weights", _load_weights)

    result = acute.calculate_acute(
        input_df,
        acute.AcuteParams(),
        year=pack.manifest.pricing_year,
        ref_dir=BASE / pack.manifest.pricing_year,
    )

    assert np.allclose(
        result["NWAU25"].to_numpy(),
        expected_df["NWAU25"].to_numpy(),
        rtol=pack.manifest.precision.tolerance.relative,
        atol=pack.manifest.precision.tolerance.absolute,
    ), f"fixture={pack.manifest.fixture_id} calculator={pack.manifest.calculator}"


def test_acute_fixture_pack_metadata_matches_expected_shape():
    pack = fixtures.load_fixture_pack(FIXTURE_MANIFEST)
    assert pack.manifest.payloads["input"].row_count == len(
        fixtures.read_payload_frame(pack, "input")
    )
    assert pack.manifest.payloads["expected_output"].row_count == len(
        fixtures.read_payload_frame(pack, "expected_output")
    )
