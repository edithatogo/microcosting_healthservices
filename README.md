# NWAU Calculator

This project provides Python translations of the IHACPA SAS funding
calculators. Modules cover acute, emergency department, mental health,
subacute and outpatient activity along with HAC and AHR adjustment
logic. The Python implementation now matches the official SAS results
for all calculators. A lightweight command line interface is available
via the `funding-calculator` script.
Historical SAS calculators from IHACPA should be extracted to
`archive/sas/<YEAR>/`.  Rename the downloaded directory so only the year
remains (for example `archive/sas/2025`).  Each folder then contains the
original SAS programs and data tables for that pricing year.

## Installation

Install the package and its dependencies using `pip`:

```bash
pip install -e .
```

To run the tests, install the additional development requirements and then run
`pytest`:

```bash
pip install -r requirements-dev.txt
```
These packages include `pytest`, `numpy`, `pandas`, `pyxlsb`, `pyreadstat` and
`lightgbm`.

## Historical data

Place each year's SAS calculator under `archive/sas/<YEAR>/` and ensure the
folder name is just the year.  After extraction the directory should contain the
SAS programs for that pricing year.  If you also download the Excel workbook,
copy it to `excel_calculator/archive/<year>` and run:

```bash
python excel_calculator/scripts/extract_weights.py
```

Move the resulting `weights.csv` into `excel_calculator/data/<year>` along with a matching `formula.json`.

The repository currently includes verified weights and formulas for the 2024
and 2025 editions. Additional years can be added once their outputs are
validated.

## Usage
Weights and the pricing formula are stored in `excel_calculator/data`.
Each pricing year has its own subdirectory, e.g. `excel_calculator/data/2025`.
The top-level files remain as the default for 2025 so existing scripts
continue to work.
To calculate funding for a CSV file of patient activity:

```bash
funding-calculator --weights excel_calculator/data/weights.csv \
    --formula excel_calculator/data/formula.json patient_data.csv > funding.csv
```

After installing the development requirements, unit tests can be run with
`pytest` and linting is performed by [Ruff](https://docs.astral.sh/ruff/):

```bash
pytest
ruff check .
```

See `nwau_py/docs/calculators.md` for an overview of each calculator
module.
The `nwau_py` package exposes both a command line interface and functions for use within Python.

### Command line

After installation the `funding-calculator` entry point is available. You can
select a specific pricing year with `--year`:

```bash
funding-calculator --year 2024 patient_data.csv > funding.csv
```

The `--year` option selects the data directory for that pricing year. The
example above uses the 2024 weights but you can also choose `--year 2025` once
verified data is available. `patient_data.csv` should contain the columns
referenced in `excel_calculator/data/2024/formula.json` and the output will
include a `NWAU24` column.

The `nwau_py` package also exposes a lightweight command line interface via
`python -m nwau_py.cli.main`. The `--year` flag works with any supported
edition (currently 2024 and 2025). The subcommands `acute`, `ed` and
`non-admitted` mirror the SAS calculators:

```bash
python -m nwau_py.cli.main acute INPUT.csv --output out.csv --year 2025
```

Common options allow the weights directory to be overridden with `--params`
and enable or disable adjustments using `--icu/--no-icu` and
`--covid/--no-covid`.

### Python modules

Funding weights can also be computed directly from Python:

```python
from funding_calculator import load_weights, load_formula, calculate_funding

weights = load_weights('excel_calculator/data/weights.csv')
formula = load_formula('excel_calculator/data/formula.json')

patient_df = ...  # pandas DataFrame containing your episode level data
patient_df['NWAU25'] = calculate_funding(patient_df, formula)
```

Replace `excel_calculator/data` with `excel_calculator/data/<year>` to use
weights and formulae from another pricing year.

Additional modules under `nwau_py.calculators` provide helpers for acute, emergency, mental health and other activity types. See `examples/run_acute.py` for a minimal demonstration.


#### Calculator examples

The individual calculators can be invoked directly when you need fine grained control. Each function expects a pandas DataFrame and returns the input with an additional `NWAU25` column.

```python
from nwau_py.calculators import AcuteParams, calculate_acute
result = calculate_acute(acute_df, AcuteParams())
```

```python
from nwau_py.calculators import EDParams, calculate_ed
result = calculate_ed(ed_df, EDParams())
```

```python
from nwau_py.calculators import MHParams, calculate_mh
result = calculate_mh(mh_df, MHParams())
```

```python
from nwau_py.calculators import SubacuteParams, calculate_subacute
result = calculate_subacute(sa_df, SubacuteParams())
```

```python
from nwau_py.calculators import OutpatientParams, calculate_outpatients
result = calculate_outpatients(op_df, OutpatientParams())
```

```python
from nwau_py.calculators import calculate_adjusted_nwau
result = calculate_adjusted_nwau(weight_df)
```

