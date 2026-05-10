from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS_SITE = ROOT / "docs-site" / "src" / "content" / "docs"
GOVERNANCE = DOCS_SITE / "governance"
MIGRATION = DOCS_SITE / "migration"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_phase1_rust_core_architecture_and_migration_status_are_published():
    architecture = GOVERNANCE / "rust-core-architecture.md"
    legacy_docs = MIGRATION / "legacy-docs.md"
    governance_index = GOVERNANCE / "index.md"

    assert architecture.exists()
    assert legacy_docs.exists()
    assert governance_index.exists()

    architecture_text = _read(architecture)
    legacy_text = _read(legacy_docs)
    governance_index_text = _read(governance_index)

    assert "Rust is the intended future calculator core" in architecture_text
    assert "Python remains the current validated runtime path" in architecture_text
    assert "Arrow-compatible batch input and output" in architecture_text
    assert "Rust migration status" in legacy_text
    assert "opt-in" in legacy_text
    assert "not the default runtime" in legacy_text
    assert "Rust core architecture" in governance_index_text


def test_phase2_generated_reference_strategy_and_public_contract_surfaces_are_documented():
    architecture = _read(GOVERNANCE / "rust-core-architecture.md")
    governance_index = _read(GOVERNANCE / "index.md")
    docs_index = _read(DOCS_SITE / "index.md")

    assert "generated reference strategy" in architecture
    assert "public contract surfaces" in architecture
    assert "Starlight" in architecture
    assert "public calculator contract" in architecture
    assert "Rust API docs" in architecture
    assert "Python docs" in architecture
    assert "WASM docs" in architecture
    assert "[Rust core architecture](./rust-core-architecture/)" in governance_index
    assert "migration notes" in docs_index
