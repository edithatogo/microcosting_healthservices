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
