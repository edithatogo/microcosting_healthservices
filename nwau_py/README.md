# nwau_py

This package provides utilities for working with IHACPA funding weights.

## Installation

The project is standardizing on `uv` for local development and validation.
Install and sync the environment with:

```bash
uv sync
```

The SAS calculators for each pricing year should be extracted under
`archive/sas/<YEAR>/` so the modules can read the reference tables.

Development targets Python 3.10 through 3.14. The runtime stack is being
updated around `uv`, `ty`, `Ruff`, `pytest`, `Codecov`, `Hypothesis`,
`mutmut`, and `Scalene` alongside the calculator libraries.

## Data preparation

The Python calculators load tables directly from the SAS releases archived under
`archive/sas/<YEAR>/`. If you need the original Excel workbook outputs, the
helper script `excel_calculator/scripts/extract_all.py` can recreate
`weights.csv` and `formula.json` from the workbooks stored in
`excel_calculator/archive/<year>`.

## CLI usage

Once installed you can calculate funding from the command line using the
`nwau_py` CLI:

```bash
python -m nwau_py.cli.main acute patient_data.csv --output funding.csv --year 2025
```

`patient_data.csv` should contain the variables expected by the SAS programs.
The output CSV will include an `NWAU25` column with the calculated weights.

## Validation Workflow

The package is validated through manifest-driven fixture packs and explicit
parity checks rather than broad claims of complete coverage. Use the shared
fixture helpers in `nwau_py.fixtures` to load packs, read payloads, and run
runner-neutral checks that can later be consumed by Python, C#, and web
tooling.

## Formula JSON

The file `excel_calculator/data/formula.json` is a structured representation of
the workbook formula used by IHACPA and is kept for archival purposes. It lists
each symbol (for example `PW`, `APaed`, `AInd`) and the corresponding column
heading in `excel_calculator/data/weights.csv`. A full mapping is provided in
[`FORMULA_MAPPING.md`](../excel_calculator/data/FORMULA_MAPPING.md).

The `steps` array enumerates the intermediate calculations that build up the
final `NWAU25` value. Starting from the base price weight, paediatric and other
adjustments are applied, ICU hours are added, private patient adjustments and
readmission penalties are subtracted and the result is multiplied by the
National Efficient Price (`NEP`). The last step yields the overall `NWAU25`
figure used for funding.

## Documentation

Detailed notes on each calculator module are available in [docs/calculators.md](docs/calculators.md).

## Golden Fixture Packs

The project uses manifest-driven fixture packs for cross-language parity checks.
The current pilot pack lives under `tests/fixtures/golden/acute_2025/` and includes
a JSON manifest plus `input.csv` and `expected.csv` payloads.

Use `nwau_py.fixtures` to work with these packs:

- `load_fixture_pack()` validates the manifest and resolves payload paths.
- `discover_fixture_packs()` finds packs under a fixture root.
- `read_payload_frame()` loads the manifest-declared input or expected output tables.
- `iter_fixture_cases()` maps manifests to calculator cases.
- `fixture_case_params()` turns cases into pytest parameters with stable ids.
- `run_fixture_case()` executes a calculator against one manifest case.
- `run_fixture_suite()` executes and validates a set of cases.
- `run_fixture_suite_from_root()` discovers packs and runs every valid case in order.
- `assert_fixture_case_output()` checks the result against the declared tolerance and rounding policy.

Pytest coverage is generated from the same manifests by parameterizing over the
discovered fixture cases. That keeps the test matrix and the helper runner in
sync without hard-coding runner-specific logic.
