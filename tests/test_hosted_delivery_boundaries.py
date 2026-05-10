from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA_GOVERNANCE = ROOT / "conductor" / "data-governance.md"
STREAMLIT = ROOT / "conductor" / "streamlit-delivery.md"
POWER_PLATFORM = ROOT / "conductor" / "power-platform-boundary.md"
DOCS_SITE_STREAMLIT = (
    ROOT
    / "docs-site"
    / "src"
    / "content"
    / "docs"
    / "governance"
    / "streamlit-delivery.md"
)
DOCS_SITE_INDEX = (
    ROOT / "docs-site" / "src" / "content" / "docs" / "governance" / "index.md"
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_hosted_delivery_documents_exist():
    for path in [DATA_GOVERNANCE, STREAMLIT, POWER_PLATFORM, DOCS_SITE_STREAMLIT]:
        assert path.exists(), path


def test_streamlit_and_service_boundaries_are_explicit():
    data_governance = _read(DATA_GOVERNANCE)
    streamlit = _read(STREAMLIT)
    power_platform = _read(POWER_PLATFORM)
    docs_site = _read(DOCS_SITE_STREAMLIT)

    for phrase in [
        "Streamlit is a Python-hosted analyst surface",
        "Do not expose unrestricted file upload paths",
        "Log operational metadata, not patient-level fields",
        "secured service boundary",
    ]:
        assert phrase in data_governance

    for phrase in [
        "Python-hosted analyst surface",
        "secured service boundary",
        "Do not log patient-level fields",
        "not a separate calculation engine",
    ]:
        assert phrase in streamlit

    for phrase in [
        "Power Platform should orchestrate calculator workflows",
        "secured service boundary",
        "Power Platform should not duplicate formula logic",
    ]:
        assert phrase in power_platform

    for phrase in [
        "Streamlit is a Python-hosted analyst surface",
        "fixture-backed or synthetic by default",
        "secured service boundary",
        "convenience surface, not a source of calculator truth",
    ]:
        assert phrase in docs_site


def test_docs_site_governance_index_links_streamlit_delivery():
    text = _read(DOCS_SITE_INDEX)
    assert "[Streamlit delivery](./streamlit-delivery/)" in text
