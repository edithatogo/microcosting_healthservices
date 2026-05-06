from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "docs-site"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_governance_pages_are_mirrored_into_the_docs_site():
    expected_paths = [
        SITE / "src" / "content" / "docs" / "index.md",
        SITE / "src" / "content" / "docs" / "migration" / "legacy-docs.md",
        SITE / "src" / "content" / "docs" / "versions" / "2025.md",
        SITE / "src" / "content" / "versions" / "2025.json",
        SITE / "src" / "content" / "docs" / "governance" / "index.md",
        SITE / "src" / "content" / "docs" / "governance" / "product.md",
        SITE / "src" / "content" / "docs" / "governance" / "tech-stack.md",
        SITE / "src" / "content" / "docs" / "governance" / "workflow.md",
        SITE / "src" / "content" / "docs" / "governance" / "validation-vocabulary.md",
        SITE / "src" / "content" / "docs" / "governance" / "data-governance.md",
        SITE / "src" / "content" / "docs" / "governance" / "source-archive.md",
        SITE / "src" / "content" / "docs" / "governance" / "release-policy.md",
        SITE / "src" / "content" / "docs" / "governance" / "supply-chain-controls.md",
    ]

    for path in expected_paths:
        assert path.exists(), path


def test_docs_site_sidebar_exposes_the_migrated_governance_content():
    config = _read_text(SITE / "astro.config.mjs")

    assert "autogenerate" in config
    assert "governance" in config
    assert "Overview" in config
