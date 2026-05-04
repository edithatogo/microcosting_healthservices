import importlib
import sys
import types
from pathlib import Path

import pandas as pd
from click.testing import CliRunner

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest

PYREADSTAT = types.ModuleType("pyreadstat")
PYREADSTAT.ReadstatError = Exception
PYREADSTAT._readstat_parser = types.SimpleNamespace(
    PyreadstatError=Exception,
)


def _missing_sas7bdat(*_args, **_kwargs):
    raise FileNotFoundError("synthetic test stub")


PYREADSTAT.read_sas7bdat = _missing_sas7bdat
sys.modules.setdefault("pyreadstat", PYREADSTAT)

acute = importlib.import_module("nwau_py.calculators.acute")
_ACUTE_ERR = None

try:  # cli may fail to import if optional deps are missing
    from nwau_py.cli.main import cli as _cli
    _CLI_ERR = None
except Exception as exc:  # pragma: no cover - environment dependent
    _cli = None
    _CLI_ERR = exc


@pytest.mark.skipif(
    _cli is None or acute is None,
    reason=(
        f"CLI import failed: {_CLI_ERR} | acute import failed: {_ACUTE_ERR}"
    ),
)
def test_cli_acute_matches_library_output(monkeypatch, tmp_path):
    def _weights(*_args, **_kwargs) -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_aa_price_weights.csv")
        df["DRG"] = df["DRG"].str.strip("b'")
        return df

    monkeypatch.setattr(acute, "_load_price_weights", _weights)

    input_csv = Path("tests/data/acute_input.csv")
    output_csv = tmp_path / "out.csv"

    runner = CliRunner()
    result = runner.invoke(
        _cli,
        [
            "acute",
            str(input_csv),
            "--output",
            str(output_csv),
            "--year",
            "2025",
            "--params",
            "tests/data/2025",
        ],
    )
    assert result.exit_code == 0

    library_input = pd.read_csv(input_csv)
    library_output = acute.calculate_acute(
        library_input,
        acute.AcuteParams(),
        year="2025",
        ref_dir=Path("tests/data/2025"),
    )
    cli_output = pd.read_csv(output_csv)

    pd.testing.assert_frame_equal(
        cli_output,
        library_output,
        check_dtype=False,
        check_exact=False,
        rtol=1e-6,
        atol=1e-6,
    )
