#!/usr/bin/env python
"""Run the acute NWAU calculator using SAS reference tables."""

from pathlib import Path

import pandas as pd

import nwau_py.calculators.acute as acute_mod
from nwau_py.calculators import AcuteParams, calculate_acute
from nwau_py.data.loader import load_sas_table
from nwau_py.utils import sas_ref_dir


def main() -> None:
    """Calculate NWAU for a minimal patient example."""
    df = pd.DataFrame(
        {
            "DRG": ["801A"],
            "LOS": [5],
            "ICU_HOURS": [0],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [0],
        }
    )

    ref_dir = sas_ref_dir("2025")

    def load_weights(ref: Path, year: str = "2025") -> pd.DataFrame:
        suffix = str(year)[-2:]
        path = ref / f"nep{suffix}_aa_price_weights.sas7bdat"
        return load_sas_table(path)

    acute_mod._load_price_weights = load_weights

    result = calculate_acute(df, AcuteParams(), year="2025", ref_dir=ref_dir)
    print(result[["DRG", "NWAU25"]])


if __name__ == "__main__":
    main()
