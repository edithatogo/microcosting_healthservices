import subprocess
import sys
from pathlib import Path

import pandas as pd
import pytest
from click.testing import CliRunner

from nwau_py.cli.main import cli


def test_cli_acute_runs(monkeypatch, tmp_path):
    input_csv = Path("tests/data/acute_input.csv")
    output_csv = tmp_path / "out.csv"

    monkeypatch.setattr(
        "nwau_py.calculators.acute._load_price_weights",
        lambda r, year="2025": pd.read_csv("tests/data/2025/nep25_aa_price_weights.csv")
        .assign(DRG=lambda x: x["DRG"].str.strip("b'")),
    )

    runner = CliRunner()
    result = runner.invoke(
        cli,
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
    df = pd.read_csv(output_csv)
    assert df["NWAU25"].iloc[1] == pytest.approx(9.2472, rel=1e-4)
