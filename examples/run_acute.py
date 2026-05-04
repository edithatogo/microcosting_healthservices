#!/usr/bin/env python
"""Run the acute NWAU calculator using SAS reference tables."""

from pathlib import Path

import pandas as pd

from nwau_py.calculators import AcuteParams, calculate_acute


def main() -> None:
    # Minimal demo using the provided test weights
    df = pd.read_csv(Path("tests/data/acute_input.csv"))
    result = calculate_acute(
        df,
        AcuteParams(),
        year="2025",
        ref_dir=Path("tests/data/2025"),
    )
    print(result)


if __name__ == "__main__":
    main()
