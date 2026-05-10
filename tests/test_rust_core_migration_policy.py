from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RELEASE_POLICY = ROOT / "conductor" / "release-policy.md"
TECH_STACK = ROOT / "conductor" / "tech-stack.md"
PRODUCT_GUIDELINES = ROOT / "conductor" / "product-guidelines.md"
ADR_0007 = (
    ROOT / "docs" / "adr" / "0007-rust-core-architecture-and-calculator-abstraction.md"
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rust_promotion_requires_fixture_parity_and_explicit_validation_status():
    release_policy = _read(RELEASE_POLICY)
    tech_stack = _read(TECH_STACK)
    adr_0007 = _read(ADR_0007)

    assert "Calculator Migration Policy" in release_policy
    assert "golden fixture parity" in release_policy
    assert "explicit validation status" in release_policy
    assert "calculator-specific" in release_policy
    assert "promotion record exists" in release_policy
    assert "Canary runs" in release_policy
    assert "rollback guidance" in release_policy
    assert "release-note requirements" in release_policy

    assert "Rust-core migration should be calculator-by-calculator" in tech_stack
    assert "fixture-gated" in tech_stack
    assert "Python remains the baseline for validation and promotion" in tech_stack
    assert "parity is recorded" in tech_stack
    assert "Promotion from Python-default to Rust-backed behavior" in adr_0007
    assert "explicit" in adr_0007
    assert "fixture parity and validation evidence" in adr_0007


def test_python_remains_default_until_a_promotion_record_exists():
    release_policy = _read(RELEASE_POLICY)
    product_guidelines = _read(PRODUCT_GUIDELINES)

    assert (
        "Python remains the default runtime path until a calculator-specific"
        in release_policy
    )
    assert "promotion record exists" in release_policy
    assert "validation claims must use precise language" in product_guidelines.lower()
    assert "fixture parity" in product_guidelines.lower()
