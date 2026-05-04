from __future__ import annotations

from pathlib import Path

HYPOTHESIS_MAX_EXAMPLES = 5
HYPOTHESIS_DEADLINE_MS = None

MUTATION_TARGETS = (
    "nwau_py/calculators/adjust.py",
    "nwau_py/calculators/funding_formula.py",
    "nwau_py/utils.py",
)

MUTATION_EXCLUSIONS = (
    "archive/",
    "scripts/",
    "tests/",
    "nwau_py/data/loader.py",
    "nwau_py/scoring/score.py",
)

SCALENE_OUTPUT_DIR = Path(".cache/validation/scalene")


def hypothesis_settings_kwargs() -> dict[str, object]:
    """Return a small, PR-friendly Hypothesis profile."""

    return {
        "max_examples": HYPOTHESIS_MAX_EXAMPLES,
        "deadline": HYPOTHESIS_DEADLINE_MS,
    }


def scalene_report_path(name: str) -> Path:
    """Return a cache-backed path for a Scalene profile report."""

    safe = "".join(ch if ch.isalnum() or ch in "-_" else "_" for ch in name).strip("_")
    filename = f"{safe or 'profile'}.txt"
    return SCALENE_OUTPUT_DIR / filename
