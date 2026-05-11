from __future__ import annotations

from pathlib import Path

WEB_ROOT = Path(__file__).resolve().parents[1] / "web"


def _read(name: str) -> str:
    return (WEB_ROOT / name).read_text(encoding="utf-8")


def test_web_demo_shell_is_static_and_demo_only():
    html = _read("index.html")
    js = _read("app.js")

    assert "Demo only" in html
    assert "No real patient data is accepted here" in html
    assert '<script type="module" src="./app.js"></script>' in html
    assert "fetch(demoUrl)" in js
    assert "./demo/acute_2025.json" in js
    assert "contract.schema_version" in js
    assert 'input type="file"' not in html


def test_web_demo_fixture_is_traceable_to_the_public_contract():
    data = _read("demo/acute_2025.json")

    assert '"schema_version": "1.0"' in data
    assert '"calculator": "acute"' in data
    assert '"pricing_year": "2025"' in data
