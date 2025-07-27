# Calculator Modules

This page outlines the Python implementations of the IHACPA NWAU calculators. Each module loosely mirrors a SAS program from the official calculator package.

| Module | SAS source | Notes |
|-------|-----------|-------|
|`acute`|`NWAU25_CALCULATOR_ACUTE.sas`|Calculates NWAU25 for acute admitted episodes. Implements ICU hour logic, length of stay categories and private patient adjustments using pandas operations.|
|`ed`|`NWAU25_CALCULATOR_ED.sas`|Handles Emergency Department/Service activity. Supports UDG and AECC classifications with remoteness and indigenous adjustments.|
|`mh`|`NWAU25_CALCULATOR_MH.sas`|Implements the mental health consumer model. Applies private patient services and accommodation adjustments.|
|`subacute`|`NWAU25_CALCULATOR_SUBACUTE.sas`|Calculates NWAU25 for subacute admitted activity based on SNAP.|
|`outpatients`|`NWAU25_CALCULATOR_OUTPATIENTS.sas`|For non‑admitted clinic activity. Applies remoteness and indigenous adjustments.|
|`adjust`|`Calculate Adjusted NWAU.sas`|Combines base NWAU with Hospital Acquired Complication (HAC) and Avoidable Hospital Readmission (AHR) adjustments.|

The SAS programs are stored under `archive/sas/NEP25_SAS_NWAU_calculator/calculators`. The Python functions focus on the core weighting formulae and use pandas for data manipulation. See the source code of each module for details of the translation.

## Usage examples

Below are minimal examples for each calculator. Dataframes should provide the columns referenced in the IHACPA documentation.

### Acute
```python
from nwau_py.calculators import AcuteParams, calculate_acute
result = calculate_acute(acute_df, AcuteParams())
```

### Emergency department
```python
from nwau_py.calculators import EDParams, calculate_ed
result = calculate_ed(ed_df, EDParams())
```

### Mental health
```python
from nwau_py.calculators import MHParams, calculate_mh
result = calculate_mh(mh_df, MHParams())
```

### Subacute
```python
from nwau_py.calculators import SubacuteParams, calculate_subacute
result = calculate_subacute(sa_df, SubacuteParams())
```

### Outpatients
```python
from nwau_py.calculators import OutpatientParams, calculate_outpatients
result = calculate_outpatients(op_df, OutpatientParams())
```

### Adjustment
```python
from nwau_py.calculators import calculate_adjusted_nwau
result = calculate_adjusted_nwau(weight_df)
```

## Debugging and cleanup

Each parameter dataclass includes two optional flags:

* `debug_mode` – when ``True`` intermediate columns (those beginning with
  underscores) are retained in the returned dataframe. The default ``False``
  mimics the SAS calculators by dropping these helper fields.
* `clear_data` – when ``True`` any cached reference tables under ``.cache`` are
  removed after calculation completes.

Example usage:

```python
params = AcuteParams(debug_mode=True)
df = calculate_acute(data, params)
```
