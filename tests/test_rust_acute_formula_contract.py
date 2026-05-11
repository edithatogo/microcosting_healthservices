from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUST_FORMULA_TEST = (
    ROOT / "rust" / "crates" / "nwau-core" / "tests" / "acute_2025_contract.rs"
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rust_acute_formula_contract_test_file_exists():
    assert RUST_FORMULA_TEST.exists(), RUST_FORMULA_TEST


def test_rust_acute_formula_contract_covers_fixture_rows_and_edge_cases():
    text = _read(RUST_FORMULA_TEST)

    assert "acute_2025" in text.lower()
    assert "801A" in text
    assert "T63A" in text
    assert "PAT_COVID_FLAG" in text
    assert "PAT_PRIVATE_FLAG" in text
    assert "fixture" in text.lower()


def test_rust_acute_formula_contract_records_precision_and_provenance():
    text = _read(RUST_FORMULA_TEST)

    assert "6.8772" in text
    assert "9.2472" in text
    assert "provenance" in text.lower()
    assert "numeric precision" in text.lower()
