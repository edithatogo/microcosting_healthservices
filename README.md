# IHACPA NWAU Calculators

This repository contains Python translations of the National Weighted Activity Unit (NWAU) calculators published by the Independent Health and Aged Care Pricing Authority (IHACPA). The calculators reproduce the logic from the official Excel and SAS tools so that NWAU values can be generated programmatically.

## Installation

The project requires Python 3.8 or later. Clone the repository and install the package with its dependencies:

```bash
pip install -r requirements.txt
pip install .
```

The weights and pricing formula used by the calculators are stored under `excel_calculator/data`. If you need to recreate the `weights.csv` file from the original workbook run:

```bash
python excel_calculator/scripts/extract_weights.py
```

## Usage

The main functionality is provided by the `nwau_py` package. It includes a command line interface and Python functions for programmatic use.

### Command line

After installation the `funding-calculator` entry point becomes available:

```bash
funding-calculator --params excel_calculator/data patient_data.csv > funding.csv
```

`patient_data.csv` should contain the columns referenced in `excel_calculator/data/formula.json`. The output CSV will include a `NWAU25` column with the calculated values.

### Python modules

You can also import the calculator functions directly:

```python
from funding_calculator import load_weights, load_formula, calculate_funding

weights = load_weights('excel_calculator/data/weights.csv')
formula = load_formula('excel_calculator/data/formula.json')

patient_df = ...  # pandas DataFrame containing your episode level data
patient_df['NWAU25'] = calculate_funding(patient_df, formula)
```

Additional modules under `nwau_py.calculators` provide helpers for acute, emergency, mental health and other activity types. The `nwau_py.scoring` module includes `score_readmission` for applying the readmission risk model.

Refer to `examples/run_acute.py` for a minimal demonstration.
