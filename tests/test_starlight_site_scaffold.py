from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "docs-site"
WORKFLOW = ROOT / ".github" / "workflows" / "docs-site.yml"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_starlight_scaffold_files_exist():
    expected_paths = [
        SITE / "package.json",
        SITE / "package-lock.json",
        SITE / "astro.config.mjs",
        SITE / "src" / "content" / "versions" / "2025.json",
        SITE / "src" / "content" / "docs" / "index.md",
        SITE / "src" / "content" / "docs" / "versions" / "2025.md",
        SITE / "src" / "content" / "docs" / "migration" / "legacy-docs.md",
        WORKFLOW,
    ]

    for path in expected_paths:
        assert path.exists(), path


def test_starlight_package_declares_required_plugins_and_scripts():
    package_json = json.loads(_read_text(SITE / "package.json"))

    assert package_json["private"] is True
    assert package_json["name"] == "docs-site"
    assert package_json["scripts"] == {
        "dev": "astro dev",
        "build": "astro build",
        "preview": "astro preview",
        "linkcheck": "astro build",
    }

    dependencies = package_json["dependencies"]
    assert dependencies["@astrojs/starlight"] == "0.38.5"
    assert "starlight-links-validator" in dependencies
    assert "starlight-versions" in dependencies
    assert package_json["dependencies"]["starlight-versions"] == "0.8.2"


def test_starlight_config_documents_the_static_docs_site_contract():
    config = _read_text(SITE / "astro.config.mjs")

    assert "@astrojs/starlight" in config
    assert "starlightLinksValidator" in config
    assert "starlightVersions" in config
    assert "github.io/microcosting_healthservices" in config
    assert "editLink" in config


def test_docs_site_workflow_builds_and_deploys_the_site():
    workflow = _read_text(WORKFLOW)

    assert "docs-site" in workflow
    assert "npm ci" in workflow
    assert "npm run build" in workflow
    assert "linkcheck" in workflow
    assert "pages" in workflow
