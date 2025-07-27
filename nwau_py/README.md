# nwau_py

This package provides utilities for working with IHACPA funding weights.

## Installation

Install from source using `pip`:

```bash
pip install .
```

This requires Python 3.8+ and depends on `pandas` and `pyxlsb` for Excel parsing.

## Data preparation

Weights are stored in `data/weights.csv`. To recreate this file from the
original IHACPA workbook run:

```bash
python excel_calculator/scripts/extract_weights.py
```

The script reads `excel_calculator/archive/nwau25_calculator_for_acute_activity.xlsb` and writes
`excel_calculator/data/weights.csv`.

## CLI usage

Once installed you can calculate funding using the `funding-calculator`
script:

```bash
funding-calculator --weights excel_calculator/data/weights.csv \
    --formula excel_calculator/data/formula.json patient_data.csv > funding.csv

`patient_data.csv` should contain the columns referenced in the formula JSON
file. The output is a CSV column named `NWAU25` with the calculated weights.

## Documentation

Detailed notes on each calculator module are available in [docs/calculators.md](docs/calculators.md).

