from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
C_SHARP_ARCH = ROOT / "conductor" / "csharp-architecture.md"
POWER_PLATFORM = ROOT / "conductor" / "power-platform-boundary.md"
INDEX = ROOT / "conductor" / "index.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_csharp_architecture_records_service_boundary():
    text = _read(C_SHARP_ARCH)
    assert "downstream adapter or service integration target" in text
    assert "formula logic should" in text
    assert "Rust core" in text
    assert "Power Platform" in text
    assert "shared golden fixtures" in text


def test_power_platform_boundary_records_orchestration_only_rules():
    text = _read(POWER_PLATFORM)
    assert "orchestrate calculator workflows" in text
    assert "secured service boundary" in text
    assert "Rust-backed core" in text
    assert "Custom Connector or Azure Function" in text


def test_project_index_links_csharp_governance_docs():
    text = _read(INDEX)
    assert "[C# Calculation Engine Architecture](./csharp-architecture.md)" in text
    assert "[Power Platform Boundary](./power-platform-boundary.md)" in text
