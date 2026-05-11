"""Helpers for loading the optional Rust-backed acute 2025 extension."""

from __future__ import annotations

import importlib.machinery
import importlib.util
from pathlib import Path
from types import ModuleType


def _candidate_extension_paths() -> list[Path]:
    root = Path(__file__).resolve().parents[1]
    candidates: list[Path] = []
    for rel in (
        "rust/target/debug/deps",
        "rust/target/release/deps",
        "rust/target/debug",
        "rust/target/release",
    ):
        base = root / rel
        if not base.exists():
            continue
        candidates.extend(sorted(base.glob("libnwau_py_rust.*")))
        candidates.extend(sorted(base.glob("nwau_py_rust.*")))
    return [path for path in candidates if path.suffix in {".so", ".dylib", ".pyd"}]


def _load_from_path(path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(
        "nwau_py._rust",
        path,
        loader=importlib.machinery.ExtensionFileLoader("nwau_py._rust", str(path)),
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"unable to load Rust extension from {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _load_module_if_available(path: Path) -> ModuleType | None:
    try:
        return _load_from_path(path)
    except Exception:
        return None


def load_rust_extension() -> ModuleType:
    """Load the optional Rust extension, preferring an installed build."""

    try:
        from . import _rust as module  # type: ignore[attr-defined]

        return module
    except Exception:
        for candidate in _candidate_extension_paths():
            module = _load_module_if_available(candidate)
            if module is not None:
                return module
    raise ImportError("Rust extension nwau_py._rust is not available")


def kernel_label() -> str:
    return load_rust_extension().kernel_label()


def calculate_acute_2025_row(*args, **kwargs):
    if kwargs:
        raise TypeError("calculate_acute_2025_row accepts positional arguments only")
    if len(args) != 3:
        raise TypeError(
            "calculate_acute_2025_row expects row, reference, and adjustments"
        )

    row, reference, adjustments = args
    ext = load_rust_extension()
    return ext.calculate_acute_2025_row(
        str(row["DRG"]),
        float(row["LOS"]),
        float(row.get("ICU_HOURS", 0.0)),
        float(row.get("ICU_OTHER", 0.0)),
        bool(int(row.get("PAT_SAMEDAY_FLAG", 0))),
        bool(int(row.get("PAT_PRIVATE_FLAG", 0))),
        bool(int(row.get("PAT_COVID_FLAG", 0))),
        bool(int(row.get("EST_ELIGIBLE_PAED_FLAG", row.get("eligible_paed_flag", 0)))),
        float(reference.get("inlier_lower_bound", 0.0)),
        float(reference.get("inlier_upper_bound", 0.0)),
        float(reference.get("paediatric_multiplier", 1.0)),
        bool(int(reference.get("same_day_list_flag", 0))),
        bool(int(reference.get("bundled_icu_flag", 0))),
        float(reference.get("same_day_base_weight", 0.0)),
        float(reference.get("same_day_per_diem", 0.0)),
        float(reference.get("inlier_weight", 0.0)),
        float(reference.get("long_stay_per_diem", 0.0)),
        float(reference.get("private_service_adjustment", 0.0)),
        float(adjustments.get("icu_rate", 0.0)),
        float(adjustments.get("covid_adjustment", 0.0)),
        float(adjustments.get("indigenous_adjustment", 0.0)),
        float(adjustments.get("remoteness_adjustment", 0.0)),
        float(adjustments.get("treatment_remoteness_adjustment", 0.0)),
        float(adjustments.get("radiotherapy_adjustment", 0.0)),
        float(adjustments.get("dialysis_adjustment", 0.0)),
        float(adjustments.get("private_accommodation_same_day", 0.0)),
        float(adjustments.get("private_accommodation_overnight", 0.0)),
    )
