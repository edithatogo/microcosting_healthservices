from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGING = ROOT / "conductor" / "downstream-packaging-plans.md"
DOCS_SITE_PACKAGING = (
    ROOT
    / "docs-site"
    / "src"
    / "content"
    / "docs"
    / "governance"
    / "downstream-packaging-plans.md"
)
DOCS_SITE_INDEX = (
    ROOT / "docs-site" / "src" / "content" / "docs" / "governance" / "index.mdx"
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_downstream_packaging_documents_exist():
    for path in [PACKAGING, DOCS_SITE_PACKAGING]:
        assert path.exists(), path


def test_downstream_packaging_guidance_is_explicit():
    packaging = _read(PACKAGING)
    docs_site = _read(DOCS_SITE_PACKAGING)

    for phrase in [
        "extendr",
        "jlrs",
        "Julia `ccall` wrapper",
        "stable ABI wrapper or secured service boundary",
        "C ABI wrapper or secured service boundary",
        "custom connector or service boundary",
        "Versioning should remain tied",
        "Release readiness is claimable only after fixture-backed parity",
    ]:
        assert phrase in packaging

    for phrase in [
        "R should evaluate `extendr`",
        "Julia should evaluate `jlrs` or a `ccall` wrapper",
        "Power Platform should use a custom connector or service boundary only",
        "Release readiness depends on shared fixture parity",
    ]:
        assert phrase in docs_site


def test_docs_site_governance_index_links_downstream_packaging():
    text = _read(DOCS_SITE_INDEX)
    assert "Downstream packaging plans" in text
