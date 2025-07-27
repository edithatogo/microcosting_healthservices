# Calculator Modules

This page outlines the Python implementations of the IHACPA NWAU calculators. Each module loosely mirrors a SAS program from the official calculator package.

| Module | SAS source | Notes |
|-------|-----------|-------|
|`acute`|`NWAU25_CALCULATOR_ACUTE.sas`|Calculates NWAU25 for acute admitted episodes. Implements ICU hour logic, length of stay categories and private patient adjustments using pandas operations.|
|`ed`|`NWAU25_CALCULATOR_ED.sas`|Handles Emergency Department/Service activity. Supports UDG and AECC classifications with remoteness and indigenous adjustments.|
|`mh`|`NWAU25_CALCULATOR_MH.sas`|Implements the mental health consumer model. Applies private patient services and accommodation adjustments.|
|`subacute`|`NWAU25_CALCULATOR_SUBACUTE.sas`|Simplified translation for subacute admitted activity based on SNAP.|
|`outpatients`|`NWAU25_CALCULATOR_OUTPATIENTS.sas`|For non‑admitted clinic activity. Applies remoteness and indigenous adjustments.|
|`adjust`|`Calculate Adjusted NWAU.sas`|Combines base NWAU with Hospital Acquired Complication (HAC) and Avoidable Hospital Readmission (AHR) adjustments.|

The SAS programs are stored under `archive/sas/NEP25_SAS_NWAU_calculator/calculators`. The Python functions focus on the core weighting formulae and use pandas for data manipulation. See the source code of each module for details of the translation.
