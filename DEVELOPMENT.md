# Development

The preferred development workflow is `uv`-based and keeps the local
environment aligned with the repo's approved stack.

```bash
uv sync --group dev --group test --group coverage --group typing --group property --group mutation --group profiling --group docs
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

Codecov consumes the generated coverage report in CI. Keep local coverage runs
focused on the packages that own calculator behavior so the uploaded report
remains meaningful.

## Tooling Notes

- **Ruff** handles linting and formatting.
- **ty** is the preferred type checker.
- **pytest** runs the test suite.
- **pytest-cov** records coverage for Codecov.
- **Hypothesis** is used for property-based tests around calculator contracts.
- **mutmut** is reserved for targeted mutation testing on pure calculation
  code.
- **Scalene** is used for profiling and memory analysis when a change affects
  compute-heavy paths.
- **Vale** lints prose and validation language and is run on demand with
  `uv run --with vale vale`.

## Dependency Notes

The current calculator implementation depends on several core libraries:

- **NumPy** and **Pandas** for existing data handling paths
- **LightGBM** for readmission risk scoring
- **PyArrow** (optional) for Arrow/Parquet interoperability and cached tables

The repository is standardizing on `uv` for dependency management and on the
Python 3.10 to 3.14 support window described in the project docs. The longer-
term stack is moving toward stricter validation, Arrow-backed interchange, and
Polars-based data handling where parity work allows it.
