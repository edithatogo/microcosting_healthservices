"""Public scoring API.

Compatibility wrapper for the readmission scoring implementation.

The actual scoring logic lives in :mod:`nwau_py.scoring.scorer`. This module
simply imports and re-exports :func:`score_readmission` from that file so that
``nwau_py.score_readmission`` works both when running from the repository and
when the package is installed without the source layout.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path

try:
    # Try the normal import first. This will succeed when ``scorer.py`` is
    # shipped with the package (e.g. in tests where ``src`` is on the path).
    from .scorer import score_readmission
except ImportError:  # pragma: no cover - fallback for source layout
    # When running from the repository, the real implementation lives under the
    # ``src`` directory which may not be on ``sys.path`` yet.  Locate the file
    # manually and load it with ``importlib``.
    _SRC_PATH = Path(__file__).resolve().parents[2] / "src"
    _SCORER = _SRC_PATH / "nwau_py" / "scoring" / "scorer.py"
    if not _SCORER.exists():
        raise

    spec = importlib.util.spec_from_file_location("nwau_py.scoring.scorer", _SCORER)
    assert spec is not None
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    score_readmission = module.score_readmission

__all__ = ["score_readmission"]
