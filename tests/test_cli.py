import pandas as pd
from click.testing import CliRunner
from pathlib import Path

import pytest
import nwau_py.calculators.acute as acute
from nwau_py.cli.main import cli


def _patch_loaders(monkeypatch):
    def _weights(*_args, **_kwargs) -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_aa_price_weights.csv")
        df["DRG"] = df["DRG"].str.strip("b'")
        return df

    monkeypatch.setattr(acute, "_load_price_weights", _weights)
    monkeypatch.setattr(acute, "load_sas_table", lambda *_a, **_k: pd.DataFrame())


def test_cli_outputs_nwau(tmp_path, monkeypatch):
    _patch_loaders(monkeypatch)

    runner = CliRunner()
    output_csv = tmp_path / "out.csv"
    result = runner.invoke(
        cli,
        [
            "acute",
            "tests/data/acute_input.csv",
            "--output",
            str(output_csv),
            "--year",
            "2025",
        ],
    )
    assert result.exit_code == 0
    df = pd.read_csv(output_csv)
    assert "NWAU25" in df.columns
    assert df["NWAU25"].iloc[1] == pytest.approx(9.2472, rel=1e-4)
