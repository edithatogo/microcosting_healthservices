import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pandas as pd
from click.testing import CliRunner
from nwau_py.cli.main import cli

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
