from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RELEASE_POLICY = ROOT / "conductor" / "release-policy.md"
SUPPLY_CHAIN = ROOT / "conductor" / "supply-chain-controls.md"
INDEX = ROOT / "conductor" / "index.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_release_policy_documents_required_release_metadata():
    text = _read(RELEASE_POLICY)
    assert "Package version" in text
    assert "Calculator data bundle version" in text
    assert "Validation status" in text
    assert "Source checksum set" in text
    assert "Lockfile revision used for the build" in text


def test_supply_chain_controls_record_verification_expectations():
    text = _read(SUPPLY_CHAIN)
    assert "Verify source checksums before extraction" in text
    assert "Use locked installs for build and validation jobs" in text
    assert "Publish SBOMs and signed artifacts" in text
    assert "Review Renovate updates" in text


def test_project_index_links_the_release_governance_docs():
    text = _read(INDEX)
    assert "[Release Policy](./release-policy.md)" in text
    assert "[Supply-Chain Controls](./supply-chain-controls.md)" in text
