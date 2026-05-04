# nwau_py

This package provides utilities for working with IHACPA funding weights.

## Installation

Install from source using `pip`:

```bash
pip install .
```

The SAS calculators for each pricing year should be extracted under
`archive/sas/<YEAR>/` so the modules can read the reference tables.

This requires Python 3.8+ and depends on `pandas`, `pyxlsb`, `pyreadstat` and `lightgbm`.

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

The project now includes manifest-driven synthetic fixture packs for cross-language parity checks.
Use the shared helpers in `nwau_py.fixtures` to load a pack, validate the manifest, and execute
manifest-declared cases against calculator inputs. The current pilot pack lives under
`tests/fixtures/golden/acute_2025/`.
