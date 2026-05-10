from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUST_ROOT = ROOT / "rust"
WORKSPACE_CARGO = RUST_ROOT / "Cargo.toml"
CORE_CARGO = RUST_ROOT / "crates" / "nwau-core" / "Cargo.toml"
PY_BINDING_CARGO = RUST_ROOT / "crates" / "nwau-py" / "Cargo.toml"
PY_BINDING_PYPROJECT = RUST_ROOT / "crates" / "nwau-py" / "pyproject.toml"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rust_workspace_files_exist():
    assert WORKSPACE_CARGO.exists(), WORKSPACE_CARGO
    assert CORE_CARGO.exists(), CORE_CARGO
    assert PY_BINDING_CARGO.exists(), PY_BINDING_CARGO


def test_rust_workspace_metadata_names_the_acute_2025_poc():
    core_cargo = _read(CORE_CARGO)
    py_binding_cargo = _read(PY_BINDING_CARGO)

    assert 'name = "nwau-core"' in core_cargo
    assert "acute 2025" in core_cargo.lower()
    assert 'name = "nwau-py"' in py_binding_cargo
    assert "acute 2025" in py_binding_cargo.lower()


def test_python_packaging_can_locate_the_binding_scaffold():
    pyproject = _read(PY_BINDING_PYPROJECT)
    cargo = _read(PY_BINDING_CARGO)

    assert "maturin" in pyproject.lower()
    assert "rust" in pyproject.lower()
    assert "pyo3" in cargo.lower()
