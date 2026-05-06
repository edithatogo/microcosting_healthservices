# Development

The preferred development workflow is `uv`-based and keeps the local
environment aligned with the repo's approved stack.

```bash
uv sync --locked --group dev --group test --group coverage --group typing --group property --group mutation --group profiling --group docs
```

## Day-to-day Commands

```bash
uv run ruff format --check .
uv run ruff check .
uv run ty check
uv run pytest
uv run pytest --cov=nwau_py --cov-report=term-missing --cov-report=xml
uv run pytest -m hypothesis
uv run mutmut run
uv run scalene nwau_py/cli/main.py
uv run --with vale vale conductor README.md docs
```

Codecov consumes the XML coverage report produced in CI. Keep local coverage
runs focused on the packages that own calculator behavior so the uploaded
report stays representative of the calculator surface under validation.

Renovate manages dependency update pull requests for the repository. Review
those updates against the current `uv`-based workflow and the calculator
validation surface before merging, especially when they touch runtime
dependencies, tooling, or lockfile state.

The slow-validation workflow is split across a weekly `schedule` trigger and a
manual `workflow_dispatch` trigger in `.github/workflows/slow-validation.yml`.
Its profiling job writes cache-backed Scalene output under
`.cache/validation/scalene/` so the generated reports stay out of version
control.

## Tooling Notes

- **Ruff** handles linting and formatting.
- **ty** is the active type checker for the current phase.
- **mypy** is transitional only and remains in the repo as a comparator while
  the `ty` migration is being completed.
- **pytest** runs the test suite.
- **pytest-cov** records coverage for Codecov and keeps the CI gate aligned
  with the uploaded XML report.
- **Hypothesis** is used for property-based tests around calculator contracts.
- **mutmut** is reserved for targeted mutation testing on pure calculation
  code.
- **Scalene** is used for profiling and memory analysis when a change affects
  compute-heavy paths. Slow-validation profiling writes reports to
  `.cache/validation/scalene/`.
- **Vale** lints prose and validation language, including validation claims
  that need to stay conservative and evidence-based. It is run on demand with
  `uv run --with vale vale`.

## Dependency Notes

The current calculator implementation still uses pandas-based paths and depends
on several core libraries:

- **NumPy** for numerical helpers
- **Pandas** for legacy data handling paths that remain under parity validation
- **Polars** and **PyArrow** for Arrow/Parquet interoperability and the newer
  bundle layer
- **LightGBM** for readmission risk scoring

The repository is standardizing on `uv` for dependency management and on the
Python 3.10 to 3.14 support window described in the project docs. The longer-
term stack is moving toward stricter validation, Arrow-backed interchange, and
Polars-based data handling where parity work allows it.
