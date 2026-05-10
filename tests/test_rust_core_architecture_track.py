from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADR = (
    ROOT / "docs" / "adr" / "0007-rust-core-architecture-and-calculator-abstraction.md"
)
TECH_STACK = ROOT / "conductor" / "tech-stack.md"
PUBLIC_API = ROOT / "conductor" / "public-api-contract.md"
CSHARP_ARCH = ROOT / "conductor" / "csharp-architecture.md"
POWER_PLATFORM = ROOT / "conductor" / "power-platform-boundary.md"
WEB_ARCH = ROOT / "conductor" / "web-architecture.md"
ADR_0005 = ROOT / "docs" / "adr" / "0005-web-and-power-platform-delivery.md"
ADR_0006 = ROOT / "docs" / "adr" / "0006-calculator-core-boundary.md"
INDEX = ROOT / "conductor" / "index.md"
TRACKS = ROOT / "conductor" / "tracks.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rust_core_roadmap_files_and_registry_are_present():
    assert ADR.exists()
    assert TECH_STACK.exists()
    assert PUBLIC_API.exists()
    assert CSHARP_ARCH.exists()
    assert POWER_PLATFORM.exists()
    assert WEB_ARCH.exists()
    assert ADR_0005.exists()
    assert ADR_0006.exists()
    assert INDEX.exists()

    tracks = _read(TRACKS)
    assert "Rust Core Architecture and Calculator Abstraction" in tracks
    assert "Rust Acute 2025 Proof of Concept with Python Bindings" in tracks
    assert "Multi-Surface Binding and Delivery Roadmap" in tracks
    assert "Rust CI, Pre-Commit, and Supply-Chain Hardening" in tracks
    assert "Documentation, Release, and Public Readiness" in tracks


def test_rust_core_adr_records_the_target_architecture():
    text = _read(ADR)

    assert "Rust Core Architecture and Calculator Abstraction" in text
    assert "intended future source of truth" in text
    assert "Arrow-compatible batch input and output" in text
    assert "Python remaining" in text
    assert "validation baseline" in text
    assert "must not duplicate formula logic" in text
    assert "Promotion from Python-default to Rust-backed behavior" in text


def test_governance_docs_shift_the_core_boundary_to_rust():
    tech_stack = _read(TECH_STACK)
    public_api = _read(PUBLIC_API)
    csharp_arch = _read(CSHARP_ARCH)
    power_platform = _read(POWER_PLATFORM)
    web_arch = _read(WEB_ARCH)
    adr_0005 = _read(ADR_0005)
    adr_0006 = _read(ADR_0006)
    index = _read(INDEX)

    assert "Rust is the intended future calculator core" in tech_stack
    assert "Python remains the current validated runtime path" in tech_stack
    assert "Arrow-compatible batch input and output" in tech_stack
    assert (
        "Rust-core migration should be calculator-by-calculator and fixture-gated"
        in tech_stack
    )

    assert "runtime-neutral and batch-first" in public_api
    assert "Formula logic belongs in the" in public_api
    assert "calculator core, not in adapters" in public_api
    assert "Rust, Python, C#, web, Power" in public_api
    assert "Platform, R, Julia, Go, and TypeScript" in public_api

    assert "downstream adapter or service integration target" in csharp_arch
    assert "formula logic should" in csharp_arch
    assert "Rust core" in csharp_arch
    assert "future Rust" in csharp_arch
    assert "other language surfaces" in csharp_arch

    assert "secured service boundary or Rust-backed core" in power_platform
    assert "Power Platform should not duplicate formula logic" in power_platform

    assert "browser surface should stay contract-consuming" in web_arch
    assert "Rust-backed core through a secure boundary" in web_arch

    assert "long-term calculation core" in adr_0005
    assert "direction is Rust" in adr_0005
    assert "future Rust-backed delivery surface" in adr_0005

    assert "long-term core shifts toward Rust" in adr_0006
    assert "Arrow-compatible batch input/output" in adr_0006
    assert "Rust can become the future source of truth" in adr_0006

    assert "Rust Core Architecture ADR" in index


def test_rust_core_adr_metadata_is_disciplined():
    text = _read(ADR)
    assert text.startswith(
        "# ADR 0007: Rust Core Architecture and Calculator Abstraction"
    )
    assert "\n## Status\n\nProposed\n" in text
