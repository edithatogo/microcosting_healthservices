# Tech Stack

## Current Repository State

The repository still contains a transitional Python package and CLI surface for IHACPA NWAU calculator parity. This section records the current evidence that the modernization track is replacing or normalizing.

Current repository evidence shows:

- Python package metadata in `pyproject.toml`.
- Python runtime requirement currently declared as `>=3.10,<3.15`.
- `setuptools` build backend.
- Runtime dependencies currently include `click`, `lightgbm`, `numpy`, `pandas`, `polars`, `pyarrow`, `pydantic`, `pyreadstat`, and `pyxlsb`.
- `pyarrow` is present in the current tooling surface as an optional cache/storage dependency.
- Dependency groups separate `dev`, `test`, `coverage`, `typing`, `property`, `mutation`, `profiling`, and `docs`, which provision Ruff, pytest, pytest-cov, ty, Hypothesis, mutmut, Scalene, and Vale.
- Tests use `pytest`.
- Linting uses `ruff`.
- Type checking uses `ty` for the active quality gate.
- `mypy` remains a transitional comparator until the migration is complete.
- The implementation currently uses pandas broadly across calculator modules, groupers, scoring, CLI, tests, and extraction scripts.
- The CLI is exposed through the `funding-calculator` entry point.

## Target Platform

The project should standardize on Python 3.10 through Python 3.14.

Supported Python versions should be covered in CI and Codecov reporting. Compatibility should be tested across the full declared support range before releases or major calculator validation claims.

## Package and Environment Management

Use `uv` for dependency management, lockfile generation, local development workflows, and CI installation.

Use `pyproject.toml` plus a committed `uv.lock` as the source of truth for environment resolution. Keep `requirements.txt` and `requirements-dev.txt` only as transitional compatibility artifacts or generated views during the migration to `uv`.

The project should maintain clear dependency groups for:

- Runtime dependencies.
- Development tooling.
- Testing and validation.
- Documentation tooling.
- Performance and profiling tools.

Use Renovate for automated dependency update proposals, including Python tooling, GitHub Actions, documentation tooling, and any package manager files managed by `uv`.

The supported Python matrix is 3.10 through 3.14. Repository metadata should be brought into alignment with that support window as the tooling track lands.

## DataFrame and Compute Stack

The target DataFrame engine should be Polars rather than pandas.

Arrow should be the canonical interchange and storage format for tabular reference data, extracted calculator tables, intermediate reusable datasets, and cross-library compatibility. DataFrame boundaries should prefer Arrow-compatible schemas so data can move between Polars, Python libraries, and future compute backends without lossy conversion.

JAX/XLA should be considered for calculation paths where vectorized numerical behavior, compilation, batching, or accelerator portability provides a measurable benefit. JAX should not obscure calculator traceability; calculation behavior must remain explainable against IHACPA source logic.

Existing pandas code should be treated as legacy implementation detail until replaced or wrapped behind stable abstractions.

## Validation and Modeling

Use Pydantic where structured validation is needed for calculator parameters, configuration, input schemas, output schemas, pricing-year metadata, and extracted reference data manifests.

Validation should be explicit at module boundaries:

- Calculator parameters should have strict schemas.
- Pricing year selection should validate against available and supported data.
- Input data requirements should be declared, checked, and documented.
- Output columns and types should be predictable and testable.
- Reference data provenance should be represented in structured metadata.

## Calculator Architecture

The project should enforce strict abstraction between:

- Calculator orchestration.
- Calculator formulas and deterministic logic.
- Parameter models.
- Input/output schemas.
- Reference data loading.
- Source provenance and validation metadata.
- CLI and user-facing workflow code.

Calculator functions should avoid hidden global state. Calculation behavior should be deterministic for a given input dataset, pricing year, parameter model, and reference data bundle.

The architecture should make it possible to compare implementations against SAS, Excel, compiled/Python reference files, and extracted Arrow-backed datasets.

## Testing and Quality

Use `pytest` as the base test runner.

Use Codecov for coverage reporting. CI coverage should include Python 3.10, 3.11, 3.12, 3.13, and 3.14.

Use Hypothesis for property-based tests around calculator invariants, input validation, boundary conditions, and source-parity assumptions where exhaustive examples are impractical.

Use mutmut for mutation testing of core calculation logic, especially arithmetic, branching, adjustment, and validation paths.

Use Scalene for profiling performance and memory behavior during calculator execution, extraction workflows, and DataFrame conversion paths.

Use `ty` instead of `mypy` for Python type checking. Treat `mypy` as transitional only until the migration is complete.

Codecov is the coverage reporting gate for CI. Local coverage runs should
produce the same XML artifact that the workflow uploads so the report remains
stable across the active Python matrix.

Use Ruff for linting and formatting unless a future decision explicitly replaces it.

## Logging and Observability

Use Python logging consistently across CLI, data loading, extraction, validation, and calculator orchestration code.

Logging should support maintainers without changing calculation outputs. It should make data source selection, pricing-year resolution, validation warnings, cache use, and comparison workflows easier to diagnose.

Avoid print-based diagnostics in library code.

## Version Management

The project should use explicit version management for the package, calculator data bundles, validation status, and supported pricing years.

Versioning should make clear distinctions between:

- Package release version.
- IHACPA pricing year.
- Reference data version.
- Extracted dataset version.
- Calculator validation status.

Release notes should identify calculator behavior changes, source-data changes, validation changes, and compatibility changes.

## Documentation Stack

Documentation should use a state-of-the-art documentation approach that supports API reference material, conceptual guides, validation guides, source provenance, and contributor workflows.

The documentation system should support:

- Generated API reference from typed Python code.
- Narrative guides for calculator parity and pricing-year validation.
- Source mapping from IHACPA SAS, Excel, compiled/Python, and support files to Python modules.
- Versioned documentation for supported releases or pricing years where practical.
- Executable examples or checked snippets where useful.
- Clear contributor guides for adding or validating a pricing year.

Use Vale for prose linting so documentation remains precise, conservative, and consistent with project terminology.

## Dependency and Maintenance Automation

Use Renovate to keep dependencies and GitHub Actions current through reviewable pull requests.

Renovate should be configured to avoid unsafe automatic upgrades for tools or libraries that may affect calculator outputs without validation.

## Migration Guidance

Treat the transitional tools and files as compatibility scaffolding, not as the long-term contract:

- `requirements.txt` and `requirements-dev.txt` are compatibility views during the `uv` migration.
- `mypy` remains a comparator until the `ty` migration is complete.
- `pandas` remains the current implementation substrate until the Polars and Arrow migration is verified.

The current pandas implementation should not be replaced casually. Migration to Polars, Arrow-backed storage, Pydantic validation, JAX/XLA calculation paths, and stricter abstraction should be planned in phases with parity tests protecting behavior.

Each migration phase should preserve or improve calculator fidelity against IHACPA reference sources and should be documented in this file as either transitional or intended-state tooling.
