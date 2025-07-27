# NWAU Calculator

This project provides Python translations of the IHACPA SAS funding
calculators.  Modules cover acute, emergency department, mental health,
subacute and outpatient activity along with HAC and AHR adjustment
logic.  A lightweight command line interface is available via the
`funding-calculator` script.

## Installation

Install the package and its dependencies using `pip`:

```bash
pip install -e .
```

## Usage
Weights and the pricing formula are stored in `excel_calculator/data`.
To calculate funding for a CSV file of patient activity:

```bash
funding-calculator --weights excel_calculator/data/weights.csv \
    --formula excel_calculator/data/formula.json patient_data.csv > funding.csv
```

Unit tests can be run with `pytest` and linting is performed by
[Ruff](https://docs.astral.sh/ruff/):

```bash
pytest
ruff check .
```

See `nwau_py/docs/calculators.md` for an overview of each calculator
module.
The `nwau_py` package exposes both a command line interface and functions for use within Python.

### Command line

After installation the `funding-calculator` entry point is available:

```bash
funding-calculator --params excel_calculator/data patient_data.csv > funding.csv
```

`patient_data.csv` should contain the columns referenced in `excel_calculator/data/formula.json`. The output will include a `NWAU25` column with the calculated values.

### Python modules

Funding weights can also be computed directly from Python:

```python
from funding_calculator import load_weights, load_formula, calculate_funding

weights = load_weights('excel_calculator/data/weights.csv')
formula = load_formula('excel_calculator/data/formula.json')

patient_df = ...  # pandas DataFrame containing your episode level data
patient_df['NWAU25'] = calculate_funding(patient_df, formula)
```

Additional modules under `nwau_py.calculators` provide helpers for acute, emergency, mental health and other activity types. See `examples/run_acute.py` for a minimal demonstration.