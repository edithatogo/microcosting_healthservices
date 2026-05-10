from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "docs-site"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_governance_pages_are_mirrored_into_the_docs_site():
    expected_paths = [
        SITE / "src" / "content" / "docs" / "index.mdx",
        SITE / "src" / "content" / "docs" / "migration" / "legacy-docs.md",
        SITE / "src" / "content" / "docs" / "versions" / "2025.md",
        SITE / "src" / "content" / "versions" / "2025.json",
        SITE / "src" / "content" / "docs" / "governance" / "index.mdx",
        SITE / "src" / "content" / "docs" / "governance" / "calculator-coverage.mdx",
        SITE / "src" / "content" / "docs" / "governance" / "product.md",
        SITE / "src" / "content" / "docs" / "governance" / "tech-stack.md",
        SITE / "src" / "content" / "docs" / "governance" / "workflow.md",
        SITE / "src" / "content" / "docs" / "governance" / "validation-vocabulary.md",
        SITE / "src" / "content" / "docs" / "governance" / "data-governance.md",
        SITE / "src" / "content" / "docs" / "governance" / "public-readiness.md",
        SITE / "src" / "content" / "docs" / "governance" / "reference-generation.md",
        SITE / "src" / "content" / "docs" / "governance" / "rust-core-architecture.md",
        SITE / "src" / "content" / "docs" / "governance" / "source-archive.md",
        SITE / "src" / "content" / "docs" / "governance" / "release-policy.md",
        SITE / "src" / "content" / "docs" / "governance" / "supply-chain-controls.md",
    ]

    for path in expected_paths:
        assert path.exists(), path


def test_docs_site_sidebar_exposes_the_migrated_governance_content():
    config = _read_text(SITE / "astro.config.mjs")

    assert "calculator-coverage" in config
    assert "governance" in config
    assert "Overview" in config
    assert "Coverage" in config


def test_docs_site_landing_and_migration_pages_expose_the_final_surface():
    index = _read_text(SITE / "src" / "content" / "docs" / "index.mdx")
    migration = _read_text(
        SITE / "src" / "content" / "docs" / "migration" / "legacy-docs.md"
    )
    release_policy = _read_text(
        SITE / "src" / "content" / "docs" / "governance" / "release-policy.md"
    )
    supply_chain = _read_text(
        SITE / "src" / "content" / "docs" / "governance" / "supply-chain-controls.md"
    )
    tech_stack = _read_text(
        SITE / "src" / "content" / "docs" / "governance" / "tech-stack.md"
    )
    public_readiness = _read_text(
        SITE / "src" / "content" / "docs" / "governance" / "public-readiness.md"
    )

    assert "Browse 2025 docs" in index
    assert "Pagefind" in index
    assert "Calculator coverage matrix" in index
    assert "Source archive" in index
    assert "Current contract" in index
    assert "Legacy docs entry points are no longer authoritative." in migration
    assert "governance and" in migration
    assert "provenance references" in migration
    assert "crate version" in release_policy
    assert "GitHub Actions must pass" in release_policy
    assert "cargo audit" in supply_chain
    assert "cargo deny" in supply_chain
    assert "Rust workspace scaffold" in tech_stack
    assert "Public readiness" in public_readiness
    assert "citation guidance" in public_readiness.lower()
