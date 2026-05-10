from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBLIC_API = ROOT / "conductor" / "public-api-contract.md"
TECH_STACK = ROOT / "conductor" / "tech-stack.md"
CSHARP_ARCH = ROOT / "conductor" / "csharp-architecture.md"
POWER_PLATFORM = ROOT / "conductor" / "power-platform-boundary.md"
WEB_ARCH = ROOT / "conductor" / "web-architecture.md"
ADR_0006 = ROOT / "docs" / "adr" / "0006-calculator-core-boundary.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_boundary_docs_separate_core_concepts_from_delivery_adapters():
    public_api = _read(PUBLIC_API)
    tech_stack = _read(TECH_STACK)
    adr_0006 = _read(ADR_0006)

    assert "runtime-neutral and batch-first" in public_api
    assert "Formula logic belongs in the" in public_api
    assert "calculator core, not in adapters" in public_api
    assert "must not embed calculator math" in public_api

    assert "Calculator formulas and deterministic logic." in tech_stack
    assert "Parameter models." in tech_stack
    assert "Input/output schemas." in tech_stack
    assert "Reference data loading." in tech_stack
    assert "Source provenance and validation metadata." in tech_stack
    assert (
        "Reference data provenance should be represented in structured metadata"
        in tech_stack
    )
    assert (
        "Rust-core migration should be calculator-by-calculator and fixture-gated"
        in tech_stack
    )

    assert "parameter models" in adr_0006
    assert "reference data manifests" in adr_0006
    assert "formula/provenance metadata" in adr_0006
    assert "Arrow-compatible batch input/output" in adr_0006


def test_boundary_docs_prohibit_duplicate_formula_logic_in_adapters():
    public_api = _read(PUBLIC_API)
    csharp_arch = _read(CSHARP_ARCH)
    power_platform = _read(POWER_PLATFORM)
    web_arch = _read(WEB_ARCH)

    assert (
        "must not embed calculator math or source-bundle lookup behavior" in public_api
    )
    assert "formula logic should" in csharp_arch
    assert "live in the Rust core rather than in C#" in csharp_arch
    assert "Power Platform should not duplicate formula logic" in power_platform
    assert "browser surface should stay contract-consuming" in web_arch
