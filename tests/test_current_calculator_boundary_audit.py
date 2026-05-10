from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / "docs" / "audits" / "20260510-current-calculator-boundary-audit.md"
INDEX = ROOT / "conductor" / "index.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_boundary_audit_records_current_state_and_contract_scaffolding():
    text = _read(AUDIT)
    lower_text = text.lower()

    assert "Current Boundary Map" in text
    assert (
        "formula logic currently lives in the python calculator modules" in lower_text
    )
    assert "pandas dataframes and series" in lower_text
    assert "AcuteParams" in text
    assert "nwau_py/reference_data.py" in text
    assert "nwau_py/bundles.py" in text
    assert "Arrow/Parquet payloads" in text
    assert "fixture packs" in lower_text
    assert "Rust-first future core" in text


def test_project_index_links_the_boundary_audit():
    text = _read(INDEX)
    audit_link = "[Current Calculator Boundary Audit]"
    audit_link += "(../docs/audits/20260510-current-calculator-boundary-audit.md)"
    assert audit_link in text
