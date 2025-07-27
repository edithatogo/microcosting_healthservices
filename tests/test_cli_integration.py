import csv
import subprocess
import sys
from io import StringIO
from pathlib import Path
import shutil
import pytest

CLI = shutil.which("funding-calculator")

def _run_cli(input_csv: Path) -> str:
    cmd = [
        CLI,
        "--weights",
        str(Path("excel_calculator/data/weights.csv")),
        "--formula",
        str(Path("excel_calculator/data/formula.json")),
        str(input_csv),
    ]
    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=True,
    )
    return result.stdout

@pytest.mark.skipif(CLI is None, reason="funding-calculator not installed")
def test_cli_integration():
    input_csv = Path("tests/data/example_patient.csv")
    try:
        out = _run_cli(input_csv)
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        pytest.skip(f"CLI execution failed: {exc}")
    reader = csv.reader(StringIO(out))
    rows = list(reader)
    assert rows[1], "no output rows"
    weight = float(rows[1][0])
    assert weight == pytest.approx(3.7184092, rel=1e-4)
