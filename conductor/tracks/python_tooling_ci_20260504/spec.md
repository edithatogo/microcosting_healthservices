# Specification: Python Tooling and CI Modernization

## Goal

Move the Python project toward the approved toolchain: uv, Python 3.10-3.14, Codecov, ty, Hypothesis, mutmut, Scalene, Renovate, Vale, and staged CI.

## Requirements

- CI must test Python 3.10 through 3.14.
- Coverage must report to Codecov.
- `ty` replaces `mypy` as the forward type-checking direction.
- Hypothesis, mutmut, and Scalene must be available without slowing every normal PR run.
- Renovate must propose dependency and GitHub Actions updates.
- Vale must lint documentation prose and validation claims.

## Acceptance Criteria

- Fast PR CI includes formatting, linting, type checks, tests, and coverage.
- Slower mutation/property/profiling workflows are separate or scheduled.
- Documentation explains local commands.
