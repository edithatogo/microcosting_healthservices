# IHACPA NWAU Calculators

This repository provides Python translations of the National Weighted Activity Unit (NWAU) calculators released by the Independent Health and Aged Care Pricing Authority (IHACPA). The calculators reproduce the logic from the official Excel and SAS tools so that funding estimates can be generated programmatically.

## Installation

Python 3.8 or later is required. Clone the repository and install the package with its dependencies:

```bash
pip install -r requirements.txt
pip install .
```

For development, optional linting tools can be installed with:

```bash
pip install ruff pre-commit
```

The weights and pricing formula used by the calculators are stored under `excel_calculator/data`. To regenerate the weights file from the original IHACPA workbook, run:

```bash
python excel_calculator/scripts/extract_weights.py
```

## Usage

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

