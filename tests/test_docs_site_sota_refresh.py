from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS_SITE = ROOT / "docs-site" / "src" / "content" / "docs"
HOME = DOCS_SITE / "index.mdx"
COVERAGE = DOCS_SITE / "governance" / "calculator-coverage.mdx"
SOURCE_ARCHIVE = DOCS_SITE / "governance" / "source-archive.md"
GOVERNANCE_INDEX = DOCS_SITE / "governance" / "index.mdx"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_docs_site_homepage_positions_the_current_public_contract():
    home = _read(HOME)

    for phrase in [
        "Microcosting Health Services docs",
        "Versioned IHACPA calculator docs",
        "Browse 2025 docs",
        "Review coverage",
        "Current contract",
        "Source archive",
        "Implemented surface",
        "Delivery surfaces",
        "GitHub Pages",
        "Power Platform",
    ]:
        assert phrase in home


def test_docs_site_coverage_page_describes_current_implementation_state():
    coverage = _read(COVERAGE)

    for phrase in [
        "Calculator coverage",
        "Acute, ED, MH, subacute, outpatients, and adjustment logic",
        "HAC, AHR, and complexity",
        "2013-14 through 2026-27",
        "currently has 94",
        "92 of which are downloaded",
        "2021-22 SAS Box page",
        "2022-23 SAS Box page",
        "Documented gap",
    ]:
        assert phrase in coverage


def test_docs_site_source_archive_page_records_explicit_gaps():
    source_archive = _read(SOURCE_ARCHIVE)

    assert "Manifest entries: 94" in source_archive
    assert "Downloaded entries: 92" in source_archive
    assert "Explicit gaps: 2" in source_archive
    assert "2021-22" in source_archive
    assert "2022-23" in source_archive
    assert "explicit gap" in source_archive.lower()


def test_docs_site_governance_index_prioritizes_the_curated_paths():
    governance = _read(GOVERNANCE_INDEX)

    assert "Calculator coverage" in governance
    assert "Source archive" in governance
    assert "Rust core architecture" in governance
    assert "Public readiness" in governance
    assert "Reading order" in governance
    assert "Web and Power Platform delivery" in governance
    assert "Streamlit delivery" in governance
    assert "Downstream packaging plans" in governance
