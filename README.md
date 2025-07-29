# NWAU Calculator

This project provides Python translations of the IHACPA SAS funding
calculators. Modules cover acute, emergency department, mental health,
subacute and outpatient activity along with HAC and AHR adjustment
logic. The Python implementation now matches the official SAS results
for all calculators. Results have been verified against the 2025 SAS release.
A lightweight command line interface is available via the
`funding-calculator` script.

## Calculator modules

Each module below mirrors a SAS program from the IHACPA package.

| Module | SAS source | Notes |
|-------|-----------|-------|
|`acute`|`NWAU25_CALCULATOR_ACUTE.sas`|Calculates NWAU25 for acute admitted episodes. Implements ICU hour logic, length of stay categories and private patient adjustments using pandas operations.|
|`ed`|`NWAU25_CALCULATOR_ED.sas`|Handles Emergency Department/Service activity. Supports UDG and AECC classifications with remoteness and indigenous adjustments.|
|`mh`|`NWAU25_CALCULATOR_MH.sas`|Implements the mental health consumer model. Applies private patient services and accommodation adjustments.|
|`subacute`|`NWAU25_CALCULATOR_SUBACUTE.sas`|Calculates NWAU25 for subacute admitted activity based on SNAP.|
|`outpatients`|`NWAU25_CALCULATOR_OUTPATIENTS.sas`|For non‑admitted clinic activity. Applies remoteness and indigenous adjustments.|
|`adjust`|`Calculate Adjusted NWAU.sas`|Combines base NWAU with Hospital Acquired Complication (HAC) and Avoidable Hospital Readmission (AHR) adjustments.|

Historical SAS calculators from IHACPA should be extracted to
`archive/sas/<YEAR>/`.  Rename the downloaded directory so only the year
remains (for example `archive/sas/2025`).  Each folder then contains the
original SAS programs and data tables for that pricing year.

## Calculators

The project includes Python versions of each funding calculator. The table
below lists the corresponding SAS programs and shows which pricing years have
validated weights and formulas.

| Calculator | SAS program | Python | 2014 | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 |
|-----------|------------------------------|--------|------|------|------|------|------|------|------|------|------|------|------|------|
| Acute | `NWAU25_CALCULATOR_ACUTE.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |
| ED | `NWAU25_CALCULATOR_ED.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |
| MH | `NWAU25_CALCULATOR_MH.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |
| Subacute | `NWAU25_CALCULATOR_SUBACUTE.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |
| Outpatients | `NWAU25_CALCULATOR_OUTPATIENTS.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |
| Adjustment | `Calculate Adjusted NWAU.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |
| Readmission | `Avoidable Hospital Readmission Grouper 030.sas` | ✓ | | | | | | | | | | | ✓ | ✓ |

Weights and formulas are verified for 2024 and 2025 only. Earlier years will be
added once their outputs are validated.

## Installation

Install the package and its dependencies using `pip`:

```bash
pip install -e .
```

Extract the official SAS calculators under `archive/sas/<YEAR>/` so the
Python modules can load the reference tables for each year.

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
SAS programs and reference tables for that pricing year.

The Excel workbooks may also be archived under
`excel_calculator/archive/<year>` for historical comparison.  A helper script
(`excel_calculator/scripts/extract_all.py`) can recreate `weights.csv` and
`formula.json` from the workbooks but this is only required when reproducing the
original spreadsheets.


The repository currently includes verified weights and formulas for the 2024
and 2025 editions. Additional years can be added once their outputs are
validated.

### Data availability matrix

| Year | SAS archive | Verified weights | Validated Python |
|------|-------------|------------------|-----------------|
|2014|✅|❌|❌|
|2015|✅|❌|❌|
|2016|✅|❌ (sample only)|❌|
|2017|✅|❌|❌|
|2018|✅|✅ (sample)|❌|
|2019|✅|✅ (sample)|❌|
|2020|✅|❌|❌|
|2021|✅|❌|❌|
|2022|✅|❌|❌|
|2023|✅|❌|❌|
|2024|✅|✅|✅|
|2025|✅|✅|✅|

### Adding a new pricing year

1. Extract the SAS calculator for the new edition under
   `archive/sas/<YEAR>/`. Rename the folder so only the year remains.
2. Copy the Excel workbook to `excel_calculator/archive/<YEAR>` and run
   `python excel_calculator/scripts/extract_all.py`. This writes
   `weights.csv` and `formula.json` to `excel_calculator/data/<YEAR>/`.
3. If the remoteness classification year changes update
   `nwau_py/utils.RA_VERSION` accordingly.
4. All calculators can then be invoked with ``--year <YEAR>`` or by
   passing ``year="<YEAR>"`` when calling the Python functions.

## SAS program mapping

The original SAS calculators are archived under
`archive/sas/<YEAR>/calculators`.  Each Python module in
`nwau_py` mirrors one of these programs.  The table below lists the main
equivalences.

| SAS program | Python module | Notes |
|-------------|---------------|-------|
|`NWAU##_CALCULATOR_ACUTE.sas`|`nwau_py/calculators/acute.py`|Matches SAS acute logic|
|`NWAU##_CALCULATOR_ED.sas`|`nwau_py/calculators/ed.py`|Equivalent ED calculations|
|`NWAU##_CALCULATOR_MH.sas`|`nwau_py/calculators/mh.py`|Mental health consumer model|
|`NWAU##_CALCULATOR_SUBACUTE.sas`|`nwau_py/calculators/subacute.py`|SNAP based calculator|
|`NWAU##_CALCULATOR_OUTPATIENTS.sas`|`nwau_py/calculators/outpatients.py`|Non-admitted activity|
|`Calculate Adjusted NWAU.sas`|`nwau_py/calculators/adjust.py`|Applies HAC and AHR adjustments|
|`Avoidable Hospital Readmission Grouper.sas`|`nwau_py/groupers/ahr.py`|Readmission grouper|
|`Hospital Acquired Complication Grouper.sas`|`nwau_py/groupers/hac.py`|HAC grouper|
|`Scorer_v3.py`|`src/nwau_py/scoring/scorer.py`|LightGBM readmission model|

## Usage

The calculators load SAS reference tables from `archive/sas/<YEAR>/`. Process a
CSV file using the command line interface:

```bash
python -m nwau_py.cli.main acute patient_data.csv --output funding.csv --year 2025
```

Replace `acute` with `ed` or `non-admitted` for other activity types. The
`--year` option selects which SAS release to use.

After installing the development requirements you can run the tests and linting
with:

```bash
pytest
ruff check .
```

See `nwau_py/docs/calculators.md` for an overview of each calculator module.
The `nwau_py` package exposes both a command line interface and functions for
use within Python.

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

Use `python -m nwau_py.cli.main` to run the calculators from the command line.
Select the relevant pricing year with `--year` and specify the activity type as
a subcommand:

```bash
python -m nwau_py.cli.main acute INPUT.csv --output funding.csv --year 2025
```

The subcommands `acute`, `ed` and `non-admitted` mirror the SAS calculators.

Common options allow the weights directory to be overridden with `--params`
and enable or disable adjustments using `--icu/--no-icu` and
`--covid/--no-covid`.

### Python modules

Funding weights can also be computed directly from Python:

```python
from nwau_py.calculators import AcuteParams, calculate_acute

patient_df = ...  # pandas DataFrame containing your episode level data
result = calculate_acute(patient_df, AcuteParams(), year="2025")
```

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

