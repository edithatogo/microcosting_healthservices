from __future__ import annotations

import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_FILE = ROOT / "pyproject.toml"
LOCK_FILE = ROOT / "uv.lock"
PR_CI_WORKFLOW_FILE = ROOT / ".github" / "workflows" / "pr-ci.yml"
SLOW_VALIDATION_WORKFLOW_FILE = (
    ROOT / ".github" / "workflows" / "slow-validation.yml"
)
CONDUCTOR_WORKFLOW_FILE = ROOT / "conductor" / "workflow.md"

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


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


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


def test_pr_ci_workflow_runs_the_expected_quality_and_test_sequence():
    workflow = _read_text(PR_CI_WORKFLOW_FILE)

    assert 'python-version: "3.11"' in workflow
    assert '  - "3.10"' in workflow
    assert '  - "3.14"' in workflow
    assert "run: uv sync --locked" in workflow
    assert "Phase 1 quality checks (Python 3.11)" in workflow
    assert "Phase 2 tests (Python ${{ matrix.python-version }})" in workflow
    assert "Phase 3 coverage and Codecov (Python 3.11)" in workflow
    assert "run: uv run ruff format --check ." in workflow
    assert "run: uv run ruff check ." in workflow
    assert "run: uv run ty check" in workflow
    assert "run: uv run pytest" in workflow
    assert (
        "run: uv run --with pytest --with pytest-cov pytest --cov=nwau_py"
        not in workflow
    )
    assert "run: uv run pytest --cov=nwau_py --cov-report=term-missing" in workflow

    assert workflow.index("Sync environment") < workflow.index("Check formatting")
    assert workflow.index("Check formatting") < workflow.index("Run lint")
    assert workflow.index("Run lint") < workflow.index("Run type check")
    assert workflow.index("Run type check") < workflow.index("Run tests")
    assert workflow.index("Run tests") < workflow.index("Run coverage")


def test_slow_validation_workflow_uses_the_expected_uv_group_commands():
    workflow = _read_text(SLOW_VALIDATION_WORKFLOW_FILE)
    scalene_command = (
        "run: uv run scalene --cli --outfile scalene.out --html python -m pytest"
    )

    assert "run: uv sync --locked --group test --group property" in workflow
    assert "run: uv sync --locked --group test --group mutation" in workflow
    assert "run: uv sync --locked --group test --group profiling" in workflow
    assert "run: uv run pytest" in workflow
    assert "run: uv run mutmut run" in workflow
    assert scalene_command in workflow

    assert (
        workflow.index("Property checks")
        < workflow.index("Run property-focused tests")
    )
    assert workflow.index("Mutation checks") < workflow.index("Run mutmut")
    assert workflow.index("Profiling checks") < workflow.index("Run Scalene profiling")


def test_conductor_workflow_documents_the_target_uv_command_sequence():
    workflow = _read_text(CONDUCTOR_WORKFLOW_FILE)
    coverage_command = (
        "uv run pytest --cov=nwau_py --cov-report=term-missing --cov-report=xml"
    )

    assert (
        "uv sync --locked --group dev --group test --group coverage --group typing "
        "--group property --group mutation --group profiling --group docs"
        in workflow
    )
    assert "uv run ruff format --check ." in workflow
    assert "uv run ruff check ." in workflow
    assert "uv run ty check" in workflow
    assert "uv run pytest" in workflow
    assert coverage_command in workflow
    assert "uv run vale conductor README.md docs" in workflow
