#!/usr/bin/env python
"""Validate release metadata consistency across project version sources."""

from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Final
import tomllib


REF_NAME_ENV: Final[str] = "GITHUB_REF_NAME"
REF_NAME_OVERRIDE: Final[str] = "RELEASE_REF_NAME"
REF_TYPE_ENV: Final[str] = "GITHUB_REF_TYPE"
REF_TYPE_OVERRIDE: Final[str] = "RELEASE_REF_TYPE"


def parse_pyproject_version(pyproject_path: Path = Path("pyproject.toml")) -> str:
    pyproject = tomllib.loads(pyproject_path.read_text(encoding="utf-8"))
    version = pyproject["project"]["version"]
    if not re.fullmatch(r"\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?", version):
        raise RuntimeError(f"Pyproject version '{version}' must be SemVer-compatible")
    return version


def parse_conda_version(recipe_path: Path = Path("conda/recipe/meta.yaml")) -> str:
    match = re.search(
        r'{%\s*set\s+version\s*=\s*"([^"]+)"\s*%}', recipe_path.read_text(encoding="utf-8")
    )
    if not match:
        raise RuntimeError("Could not parse conda version from conda/recipe/meta.yaml")
    version = match.group(1)
    if not re.fullmatch(r"\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?", version):
        raise RuntimeError(f"Conda recipe version '{version}' must be SemVer-compatible")
    return version


def parse_tag_version() -> str:
    ref_name = os.environ.get(REF_NAME_OVERRIDE) or os.environ.get(REF_NAME_ENV, "")
    ref_type = os.environ.get(REF_TYPE_OVERRIDE) or os.environ.get(REF_TYPE_ENV, "")
    if not ref_name:
        raise RuntimeError("Could not resolve release ref name from workflow environment")
    if ref_type != "tag":
        raise RuntimeError("Version validation only applies to tag-based release events")
    match = re.fullmatch(r"v(?P<version>\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)", ref_name)
    if not match:
        raise RuntimeError(
            f"Invalid release ref '{ref_name}' (expected SemVer-compatible tag vMAJOR.MINOR.PATCH)"
        )
    return match.group("version")


def main() -> int:
    project_version = parse_pyproject_version()
    conda_version = parse_conda_version()
    tag_version = parse_tag_version()

    if tag_version != project_version:
        raise RuntimeError(
            f"Tag version {tag_version} does not match pyproject version {project_version}"
        )
    if conda_version != project_version:
        raise RuntimeError(
            f"Conda recipe version {conda_version} does not match pyproject version {project_version}"
        )

    print(f"Release metadata validated for v{project_version}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
