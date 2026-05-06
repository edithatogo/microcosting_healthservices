from __future__ import annotations

import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT_FILE = ROOT / "pyproject.toml"
LOCK_FILE = ROOT / "uv.lock"

EXPECTED_GROUP_PACKAGES = {
    "dev": {"ruff"},
    "test": {"pytest"},
    "coverage": {"pytest-cov"},
    "typing": {"ty"},
    "property": {"hypothesis"},
    "mutation": {"mutmut"},
    "profiling": {"scalene"},
    "docs": {"vale"},
}


def _load_toml(path: Path) -> dict[str, object]:
    return tomllib.loads(path.read_text(encoding="utf-8"))


def test_pyproject_declares_the_expected_dependency_groups():
    project = _load_toml(PROJECT_FILE)["dependency-groups"]
    assert isinstance(project, dict)

    for group_name, expected_packages in EXPECTED_GROUP_PACKAGES.items():
        group_packages = set(project[group_name])
        assert expected_packages.issubset(group_packages)


def test_pyproject_supports_python_310_through_314():
    project = _load_toml(PROJECT_FILE)["project"]
    assert isinstance(project, dict)
    assert project["requires-python"] == ">=3.10,<3.15"


def test_uv_lock_records_the_supported_python_window_and_tooling_packages():
    lock = _load_toml(LOCK_FILE)
    packages = {package["name"] for package in lock["package"]}
    resolution_markers = lock["resolution-markers"]

    assert lock["requires-python"] == ">=3.10, <3.15"
    assert EXPECTED_GROUP_PACKAGES["dev"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["test"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["coverage"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["typing"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["property"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["mutation"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["profiling"].issubset(packages)
    assert EXPECTED_GROUP_PACKAGES["docs"].issubset(packages)

    assert any(
        "python_full_version < '3.11'" in marker for marker in resolution_markers
    )
    assert any(
        "python_full_version >= '3.11' and python_full_version < '3.13'" in marker
        for marker in resolution_markers
    )
    assert any(
        "python_full_version == '3.13.*'" in marker for marker in resolution_markers
    )
    assert any(
        "python_full_version >= '3.14'" in marker for marker in resolution_markers
    )
