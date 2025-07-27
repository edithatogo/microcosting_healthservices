# IHACPA NWAU Calculators

This repository contains Python translations of the National Weighted Activity Unit (NWAU) calculators published by the Independent Health and Aged Care Pricing Authority (IHACPA). The calculators reproduce the logic from the official Excel and SAS tools so that NWAU values can be generated programmatically.

## Installation

The project requires Python 3.8 or later. Clone the repository and install the package with its dependencies:

```bash
pip install -r requirements.txt
pip install .
```

The weights and pricing formula used by the calculators are stored under `excel_calculator/data`. If you need to recreate the `weights.csv` file from the original workbook run:
For development, install the linting tools as well:

```bash
pip install ruff pre-commit
```


Example project pages built using this template are:
- https://horwitz.ai/probex
- https://vision.huji.ac.il/probegen
- https://horwitz.ai/mother
- https://horwitz.ai/spectral_detuning
- https://vision.huji.ac.il/ladeda
- https://vision.huji.ac.il/dsire
- https://horwitz.ai/podd
- https://dreamix-video-editing.github.io
- https://horwitz.ai/conffusion
- https://horwitz.ai/3d_ads/
- https://vision.huji.ac.il/ssrl_ad
- https://vision.huji.ac.il/deepsim

## Data extraction and funding calculator

### Regenerating `excel_calculator/data/weights.csv`
Run the following command from the repository root to rebuild the weights table:

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
