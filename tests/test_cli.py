import json
import subprocess
import sys
from pathlib import Path

import pandas as pd
import pytest
from click.testing import CliRunner

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from nwau_py.cli.main import cli


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


CSV_DATA = (
    "Inlier,Paediatric Adjustment,Adj (Indigenous Status),"
    "Adjustment.1 (Patient Remoteness),Treatment Remoteness Adjustment,"
    "Dialysis Adjustment,Private Service Adjustment,COVID-19 Treatment Adjustment,"
    "Bundled ICU,ICU Hours,Private Service Percentage,Length of Stay,"
    "Private Patient Accommodation Adjustment,HAC Adjustment,Readmission weight,"
    "Readmission adjustment,National Efficient Price\n"
    "1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7258\n"
)


def test_cli_outputs_nwau25(tmp_path):
    input_csv = tmp_path / "input.csv"
    input_csv.write_text(CSV_DATA)
    output_csv = tmp_path / "out.csv"
    runner = CliRunner()
    result = runner.invoke(
        cli,
        [
            "acute",
            str(input_csv),
            "--params",
            "excel_calculator/data",
            "--output",
            str(output_csv),
        ],
    )
    assert result.exit_code == 0
    df = pd.read_csv(output_csv)
    assert "NWAU25" in df.columns
    assert df["NWAU25"].iloc[0] == 7258
