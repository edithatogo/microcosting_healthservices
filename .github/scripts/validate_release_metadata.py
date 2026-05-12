#!/usr/bin/env python
"""Validate release metadata consistency across project version sources."""

from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Final
import tomllib


REF_NAME_ENV: Final[str] = "GITHUB_REF_NAME"
REF_TYPE_ENV: Final[str] = "GITHUB_REF_TYPE"


def parse_pyproject_version(pyproject_path: Path = Path("pyproject.toml")) -> str:
    pyproject = tomllib.loads(pyproject_path.read_text(encoding="utf-8"))
    return pyproject["project"]["version"]


def parse_conda_version(recipe_path: Path = Path("conda/recipe/meta.yaml")) -> str:
    match = re.search(
        r'{%\s*set\s+version\s*=\s*"([^"]+)"\s*%}', recipe_path.read_text(encoding="utf-8")
    )
    if not match:
        raise RuntimeError("Could not parse conda version from conda/recipe/meta.yaml")
    return match.group(1)


def parse_tag_version() -> str:
    ref_name = os.environ[REF_NAME_ENV]
    ref_type = os.environ.get(REF_TYPE_ENV, "")
    if ref_type != "tag":
        raise RuntimeError("Version validation only applies to tag-based release events")
    if not ref_name.startswith("v"):
        raise RuntimeError(f"Invalid release ref '{ref_name}' (expected vMAJOR.MINOR.PATCH)")
    return ref_name.removeprefix("v")


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
