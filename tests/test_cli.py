import json
import subprocess
import sys
from pathlib import Path

import pandas as pd
import pytest


def test_cli_runs_with_sample_data(tmp_path):
    params_dir = tmp_path / "params"
    params_dir.mkdir()
    (params_dir / "weights.csv").write_text("dummy\n0\n")
    formula = {"variables": {"val": "NWAU25_precalc"}, "steps": ["NWAU25 = val"]}
    (params_dir / "formula.json").write_text(json.dumps(formula))

    patient = pd.read_csv(Path("tests/data/example_patient.csv"))
    patient["NWAU25_precalc"] = patient["NWAU25"]
    input_csv = tmp_path / "patient.csv"
    patient.to_csv(input_csv, index=False)

    output_csv = tmp_path / "out.csv"
    subprocess.run([
        sys.executable,
        "-m",
        "nwau_py.cli.main",
        "acute",
        str(input_csv),
        "--params",
        str(params_dir),
        "--output",
        str(output_csv),
    ], check=True)

    result = pd.read_csv(output_csv)
    assert result.loc[0, "NWAU25"] == pytest.approx(3.7184092)

