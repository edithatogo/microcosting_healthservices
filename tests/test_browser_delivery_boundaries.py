from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB_ARCH = ROOT / "conductor" / "web-architecture.md"
ADR_0005 = ROOT / "docs" / "adr" / "0005-web-and-power-platform-delivery.md"
DOCS_SITE_WEB = (
    ROOT
    / "docs-site"
    / "src"
    / "content"
    / "docs"
    / "governance"
    / "web-and-power-platform-delivery.md"
)
DOCS_SITE_INDEX = (
    ROOT / "docs-site" / "src" / "content" / "docs" / "governance" / "index.mdx"
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_browser_delivery_documents_exist():
    for path in [WEB_ARCH, ADR_0005, DOCS_SITE_WEB, DOCS_SITE_INDEX]:
        assert path.exists(), path


def test_browser_delivery_boundary_language_is_explicit():
    web_arch = _read(WEB_ARCH)
    adr_0005 = _read(ADR_0005)
    docs_site = _read(DOCS_SITE_WEB)

    for phrase in [
        "TypeScript/WASM Delivery",
        "`wasm-bindgen` or `wasm-pack`",
        "synthetic or committed fixture data",
        "browser parity check",
        "presentation layer, not a calculator engine",
    ]:
        assert phrase in web_arch

    for phrase in [
        "TypeScript/WebAssembly demo shells",
        "Streamlit surface",
        "synthetic/demo data",
        "never for real-data",
    ]:
        assert phrase in adr_0005

    for phrase in [
        "GitHub Pages stays static-first and synthetic/demo-only",
        "TypeScript/WASM can support browser demos",
        "Streamlit is a Python-hosted analyst surface",
        "Power Platform remains orchestration-only",
        "Real-data workflows stay outside browser-hosted demo shells",
    ]:
        assert phrase in docs_site


def test_docs_site_governance_index_links_web_delivery_guidance():
    text = _read(DOCS_SITE_INDEX)
    assert "Web and Power Platform delivery" in text
