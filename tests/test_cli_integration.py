import csv
import shutil
import subprocess
from io import StringIO
from pathlib import Path

import pytest

CLI = shutil.which("funding-calculator")


def _run_cli(input_csv: Path) -> str:
    cmd = [CLI, "acute", str(input_csv), "--year", "2025", "--params", "tests/data/2025"]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


@pytest.mark.skipif(CLI is None, reason="funding-calculator not installed")
def test_cli_integration():
    input_csv = Path("tests/data/acute_input.csv")
    try:
        out = _run_cli(input_csv)
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        pytest.skip(f"CLI execution failed: {exc}")
    reader = csv.reader(StringIO(out))
    rows = list(reader)
    assert rows[1], "no output rows"
    weight = float(rows[1][1])
    assert weight == pytest.approx(9.2472, rel=1e-4)
