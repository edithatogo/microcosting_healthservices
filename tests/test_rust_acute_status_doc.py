from __future__ import annotations

# ruff: noqa: I001

from pathlib import Path


DOC = (
    Path(__file__).resolve().parents[1]
    / "docs"
    / "audits"
    / "20260511-rust-acute-poc-status.md"
)


def test_rust_acute_poc_status_doc_exists():
    assert DOC.exists(), DOC


def test_rust_acute_poc_status_doc_covers_validation_performance_and_limitations():
    text = DOC.read_text(encoding="utf-8")

    assert "validation evidence" in text.lower()
    assert "known limitations" in text.lower()
    assert "performance" in text.lower()
    assert "opt-in" in text.lower()
