from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "archive" / "power_bi_cli_tooling_20260511"
TRACKS = ROOT / "conductor" / "tracks.md"
SCRIPT = ROOT / "scripts" / "bootstrap-power-platform-powerbi-cli.sh"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_power_bi_cli_tooling_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
        TRACK / "verification-handoff.md",
    ]:
        assert path.exists(), path


def test_power_bi_cli_tooling_track_scope_and_contracts():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    track_index = _read_text(TRACK / "index.md")
    registry = _read_text(TRACKS)

    assert metadata["track_id"] == "power_bi_cli_tooling_20260511"
    assert metadata["status"] in {"complete", "completed"}
    assert "Power BI and Power Platform CLI" in metadata["description"]

    for phrase in [
        "Power Platform CLI",
        "SOTA Command-Surface Baseline",
        "Tooling Decision Record: `pacx`",
        "powerbi",
        "pacx",
        "solution pack/unpack",
        "bootstrap",
        "Path",
        "Command matrix",
    ]:
        assert phrase in spec

    for phrase in [
        "CLI and SOTA Requirements Baseline",
        "[x] Task: Write tests for CLI/tooling contract",
        "[x] Task: Record current and SOTA command surfaces",
        "Bootstrap and Environment Hardening",
        "[x] Task: Write tests for end-to-end CLI bootstrap and checks",
        "[x] Task: Complete command documentation",
        "Power Platform Surface and Power BI Delivery Readiness",
        "Conductor - Automated Review and Checkpoint",
        "via conductor-review, auto-fix, and auto-progress",
    ]:
        assert phrase in plan

    assert "power_bi_cli_tooling_20260511" in track_index
    assert "Verification and Handoff Notes" in track_index
    assert "Bootstrap Script" in track_index
    assert "Power BI and Power Platform CLI Tooling" in registry
    assert "Depends on: Power Platform ALM App Setup and Delivery." in registry
    assert "Power BI and Power Platform CLI Tooling" in track_index


def test_power_bi_cli_tooling_bootstrap_contract_exists_and_is_focused():
    script = _read_text(SCRIPT)

    assert SCRIPT.exists()
    assert "bootstrap command must validate all required command groups" in _read_text(
        TRACK / "spec.md"
    )
    assert "pac solution checker --help" in script
    assert "powerbi workspace --help" in script
    assert "AZURE_HELP_CHECKS" in script
    assert "MIN_PAC_VERSION" in script
    assert "MIN_POWERBI_VERSION" in script
    assert "MIN_AZURE_CLI_VERSION" in script
    assert "DOTNET_TOOLS_PATH" in script
    assert "If pac remains unavailable after bootstrap" in script
    assert 'check_command_present "pac"' in script
    assert "run_help_smoke_check" in script


def test_power_bi_cli_tooling_track_install_expectations_are_documented():
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")

    assert "Power Platform (`pac`) Command Contract" in spec
    assert "Command Matrix and Version Contract" in spec
    assert ">= 1.35.0" in spec
    assert ">= 2.70.0" in spec
    assert "MIN_PAC_VERSION" in plan or "MIN_PAC_VERSION" in _read_text(SCRIPT)


def test_power_bi_cli_tooling_phase1_command_contracts_and_discovery_contract():
    spec = _read_text(TRACK / "spec.md")

    for term in [
        "`pac auth create`",
        "`pac org list`",
        "`pac solution pack`",
        "`pac solution unpack`",
        "`pac solution import`",
        "`pac solution checker run`",
        "`pac pipeline list`",
        "`powerbi login`",
        "`powerbi workspace list`",
        "`powerbi dataset list`",
        "`powerbi report list`",
        "`az version`",
        "`az account show`",
        "`az account set`",
        "`command -v pac`",
        "`command -v az`",
        "`command -v powerbi`",
        "`pac --version`",
        "`az --version`",
        "`powerbi --version`",
        "~/.dotnet/tools",
    ]:
        assert term in spec


def test_power_bi_cli_tooling_pacx_decision_rationale_is_explicit():
    spec = _read_text(TRACK / "spec.md").lower()
    assert "decision: do not use `pacx` for this track." in spec
    assert (
        "not currently discoverable in this environment's supported package sources"
        in spec
    )
    assert "supported, current microsoft toolchain" in spec
