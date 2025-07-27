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
