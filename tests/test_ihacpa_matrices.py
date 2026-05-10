from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE_MATRIX = ROOT / "conductor" / "ihacpa-archive-matrix.md"
TOOL_MATRIX = ROOT / "conductor" / "ihacpa-tool-coverage-matrix.md"
CONDUCTOR_INDEX = ROOT / "conductor" / "index.md"
SOURCE_ARCHIVE = ROOT / "conductor" / "source-archive.md"
CALCULATORS_DOC = ROOT / "nwau_py" / "docs" / "calculators.md"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ihacpa_matrices_exist():
    assert ARCHIVE_MATRIX.exists()
    assert TOOL_MATRIX.exists()


def test_ihacpa_archive_matrix_reflects_downloaded_manifest():
    text = _read_text(ARCHIVE_MATRIX)
    for phrase in [
        "Total manifest entries: 94",
        "Downloaded entries: 92",
        "Explicit archive gaps: 2",
        "2021-22",
        "2022-23",
        "box-html-only",
        "acute, subacute, non-admitted, ED UDG, SAS bundle",
    ]:
        assert phrase in text


def test_ihacpa_tool_matrix_reflects_current_incorporation_state():
    text = _read_text(TOOL_MATRIX)
    for phrase in [
        "implemented, with a 2025 Rust canary",
        "HAC, AHR, and complexity are internal helper outputs",
        "2021-22 and 2022-23",
        "not incorporated",
        "Partial implementation: 1 Rust-backed acute canary",
    ]:
        assert phrase in text


def test_ihacpa_matrices_are_linked_from_project_docs():
    index_text = _read_text(CONDUCTOR_INDEX)
    source_text = _read_text(SOURCE_ARCHIVE)
    calculators_text = _read_text(CALCULATORS_DOC)

    for phrase in [
        "IHACPA Source Archive Matrix",
        "IHACPA Tool Coverage Matrix",
    ]:
        assert phrase in index_text

    for phrase in [
        "IHACPA Source Archive Matrix",
        "IHACPA Tool Coverage Matrix",
    ]:
        assert phrase in source_text

    assert "IHACPA Tool Coverage Matrix" in calculators_text
