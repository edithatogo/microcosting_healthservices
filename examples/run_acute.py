#!/usr/bin/env python
"""Example script running the acute funding calculator."""

from pathlib import Path

import pandas as pd

from nwau_py.calculators import AcuteParams, calculate_acute


def main():
    df = pd.read_csv(Path("tests/data/acute_input.csv"))
    result = calculate_acute(df, AcuteParams())
    print(f"Calculated NWAU: {result['NWAU25'].iloc[0]:.4f}")


if __name__ == "__main__":
    main()
