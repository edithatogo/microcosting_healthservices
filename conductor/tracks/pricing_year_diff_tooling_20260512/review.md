# Review: Pricing-Year Diff Tooling

Status: integration review complete

## Findings

1. High: The diff command is not implemented on the actual CLI surface.
   - Evidence: `nwau_py/cli/main.py:148-323` defines `interop`, `sources`, `validate-year`, `acute`, `ed`, and `non-admitted`, but there is no `diff-year` command or helper path.
   - Impact: the track acceptance criteria require a working diff command and tests, but the installed `funding-calculator` CLI cannot execute the contract surface yet.

2. High: The committed diff examples are for the wrong year pair relative to the current reference manifests and the track plan.
   - Evidence: `contracts/pricing-year-diff/examples/diff-year.json:2-4` and `contracts/pricing-year-diff/examples/diff-year.markdown.md:1` are keyed to `2024 -> 2025`.
   - Evidence: the manifest-backed examples in `reference-data/2025/manifest.yaml:1-12` and `reference-data/2026/manifest.yaml:1-12` are the current year pair available for comparison, and `conductor/tracks/pricing_year_diff_tooling_20260512/plan.md:15-18` explicitly asks for `2025-26 to 2026-27` release examples.
   - Impact: release-note examples and contract fixtures will be misleading unless they are retargeted to the same manifest-backed years the repo actually carries.

3. Medium: Track registry metadata points at evidence files that do not exist.
   - Evidence: `conductor/tracks.md:206-209` says this track’s evidence surfaces include `conductor/tracks/pricing_year_diff_tooling_20260512/strategy.md` and `conductor/tracks/pricing_year_diff_tooling_20260512/ci_notes.md`.
   - Evidence: `find conductor/tracks/pricing_year_diff_tooling_20260512 -maxdepth 2 -type f` only returns `index.md`, `metadata.json`, `plan.md`, and `spec.md`.
   - Impact: the audit trail is inconsistent, and reviewers cannot find the documented guidance that the registry says should exist.

4. Medium: Release documentation does not yet consume diff output.
   - Evidence: `README.md:28-40` covers release tags, drafts, CI, and validation gates, but it does not describe year-diff summaries or how diff output feeds release notes.
   - Impact: the acceptance criterion that release docs can consume diff output is not satisfied by the current documentation set.

## Blockers

- Resolved in integration: `funding-calculator diff-year <from-year> <to-year>`
  now emits markdown by default and JSON with `--json`.
- Resolved in integration: contract examples and docs now target the
  manifest-backed `2025` and `2026` years.
- Resolved in integration: track `strategy.md` and `ci_notes.md` are present.
- Resolved in integration: Starlight governance docs describe year-diff release
  note consumption.

## Recommended validation commands

- `uv run pytest tests/test_pricing_year_diff_tooling.py`
- `uv run pytest tests/test_pricing_year_validation_gates.py`
- `uv run python -m nwau_py.cli.main diff-year 2025 2026 --json`
- `uv run python -m nwau_py.cli.main diff-year 2025 2026 --help`
- `uv run pytest --cov=nwau_py --cov-report=term-missing --cov-report=xml --cov-fail-under=80`
- `uv run ruff check .`
- `uv run ty check`
