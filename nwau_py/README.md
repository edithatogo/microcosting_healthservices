# nwau_py

This package provides utilities for working with IHACPA funding weights.

## Installation

Install from source using `pip`:

```bash
pip install .
```

This requires Python 3.8+ and depends on `pandas`, `pyxlsb`, `pyreadstat` and `lightgbm`.

## Data preparation

Weights are stored under `excel_calculator/data/<year>/weights.csv`. To
recreate these files from the official IHACPA workbooks run:

```bash
python excel_calculator/scripts/extract_all.py
```

The script reads each workbook under `excel_calculator/archive/<year>` and writes
`excel_calculator/data/<year>/weights.csv` as well as a matching
`formula.json`.

## CLI usage

Once installed you can calculate funding using the `funding-calculator`
script. Select a pricing year with `--year`:

```bash
funding-calculator --year 2025 patient_data.csv > funding.csv
```

`patient_data.csv` should contain the columns referenced in the formula JSON
file. The output is a CSV column named `NWAU25` with the calculated weights.

## Formula JSON

The file `excel_calculator/data/formula.json` is a structured representation of
the workbook formula used by IHACPA. It lists each symbol (for example `PW`,
`APaed`, `AInd`) and the corresponding column heading in
`excel_calculator/data/weights.csv`. A full mapping is provided in
[`FORMULA_MAPPING.md`](../excel_calculator/data/FORMULA_MAPPING.md).

The `steps` array enumerates the intermediate calculations that build up the
final `NWAU25` value. Starting from the base price weight, paediatric and other
adjustments are applied, ICU hours are added, private patient adjustments and
readmission penalties are subtracted and the result is multiplied by the
National Efficient Price (`NEP`). The last step yields the overall `NWAU25`
figure used for funding.

## Documentation

Detailed notes on each calculator module are available in [docs/calculators.md](docs/calculators.md).
