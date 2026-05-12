# Contributing

Thank you for contributing to `nwau-py` and the broader polyglot IHACPA tooling roadmap.

## Development setup

1. Install dependencies with `uv sync --locked --group dev --group test --group coverage --group typing --group property --group mutation --group profiling --group docs`.
2. Use `pytest` and `uv run` workflows rather than ad-hoc Python environment changes.
3. Run formatting, linting, and type checks before opening a pull request.

## Branching and review

1. Open changes through `origin/master` with focused PRs per track or milestone.
2. Keep Conductor tracks and plan updates aligned with code changes.
3. Prefer one acceptance change per commit with clear completion evidence in the track metadata and tests.

## Quality gates

Before requesting review:

- `uv run ruff format --check .`
- `uv run ruff check .`
- `uv run ty check`
- `uv run pytest`
- Coverage and Codecov workflow parity when changing core behavior.
- Cargo checks for Rust-related changes.

## Conductor workflow

Track metadata must include governance fields in `metadata.json`:

- `track_class`
- `current_state`
- `primary_contract`
- `dependencies`
- `completion_evidence`
- `publication_status`

Tracks should only be marked complete when evidence is attached and verified.

## Reporting issues

Use issue templates to separate feature, bug, data-quality, and publication concerns. Provide:

- reproducible command
- input data path
- affected year(s) or tool(s)
- expected vs actual behavior
