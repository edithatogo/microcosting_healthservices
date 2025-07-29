# NWAU Calculator

This project provides Python translations of the IHACPA SAS funding
calculators. Modules cover acute, emergency department, mental health,
subacute and outpatient activity along with HAC and AHR adjustment
logic. The Python implementation now matches the official SAS results
for all calculators. A lightweight command line interface is available
via ``python -m nwau_py.cli.main``.
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
copy it to `excel_calculator/archive/<year>`.  Extract `weights.csv` and
`formula.json` for all available years with:

```bash
python excel_calculator/scripts/extract_all.py
```

The helper script writes the outputs to `excel_calculator/data/<year>/`.

The repository currently includes verified weights and formulas for the 2024
and 2025 editions. Additional years can be added once their outputs are
validated.

## Usage
Weights and the pricing formula are stored in `excel_calculator/data`.
Each pricing year has its own subdirectory, e.g. `excel_calculator/data/2025`.
The top-level files remain as the default for 2025 so existing scripts
continue to work.
Funding calculators can be executed directly via ``python -m nwau_py.cli.main``.
For example, to process acute activity:

```bash
python -m nwau_py.cli.main acute patient_data.csv --output funding.csv
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

## Remoteness classification

The calculators rely on the IHACPA remoteness area (RA) classification. The
edition used varies by pricing year. `nwau_py.utils.RA_VERSION` maps each year
to its RA edition and the helper function `ra_suffix(year)` returns the suffix
used in dataset column names.

```python
from nwau_py.utils import ra_suffix

assert ra_suffix("2025") == "ra2021"
```

### Handling missing demographics

When remoteness or Indigenous status is missing from the input data the
calculators can impute adjustment values using population distributions. Pass
a dictionary of proportions to the parameter dataclass:

```python
from nwau_py.calculators import AcuteParams, calculate_acute

rem_dist = {"RA1": 0.55, "RA2": 0.25, "RA3": 0.15, "RA4": 0.04, "RA5": 0.01}
ind_dist = {0: 0.8, 1: 0.2}
params = AcuteParams(
    remoteness_distribution=rem_dist,
    indigenous_distribution=ind_dist,
)
result = calculate_acute(df, params)
```

Missing adjustments are replaced by the weighted average of the relevant table
using the provided distribution.

### Command line

The calculators are accessible via ``python -m nwau_py.cli.main``. Select the
pricing year with ``--year``. The subcommands ``acute``, ``ed`` and
``non-admitted`` mirror the official SAS calculators:

```bash
python -m nwau_py.cli.main acute INPUT.csv --output out.csv --year 2025
```

Common options allow the weights directory to be overridden with `--params`
and enable or disable adjustments using `--icu/--no-icu` and
`--covid/--no-covid`.

### Python modules

The calculators can also be called directly from Python:

```python
from nwau_py.calculators import AcuteParams, calculate_acute

patient_df = ...  # pandas DataFrame containing your episode level data
result = calculate_acute(patient_df, AcuteParams())
```

Pass ``year="2024"`` (for example) to use a different pricing edition.

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

