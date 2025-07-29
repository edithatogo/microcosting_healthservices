"""Command line interface for the NWAU calculators."""
from __future__ import annotations

import sys
from pathlib import Path
from typing import IO

import click
import pandas as pd

from nwau_py.calculators import (
    AcuteParams,
    EDParams,
    OutpatientParams,
    calculate_acute,
    calculate_ed,
    calculate_outpatients,
)


@click.group()
def cli() -> None:
    """Entry point for calculator commands."""
    pass


def _write_output(df: pd.DataFrame, outfh: IO[str]) -> None:
    df.to_csv(outfh, index=False)


def _run(
    calculator,
    params,
    input_csv: str,
    output: str,
    year: str | None,
    ref_dir: str | None,
) -> None:
    df = pd.read_csv(input_csv)
    result = calculator(
        df,
        params,
        year=year or "2025",
        ref_dir=Path(ref_dir) if ref_dir else None,
    )
    outfh = sys.stdout if output == "-" else open(output, "w", newline="")
    try:
        _write_output(result, outfh)
    finally:
        if outfh is not sys.stdout:
            outfh.close()


def _common_options(func):
    func = click.argument("input_csv", type=click.Path(exists=True))(func)
    func = click.option(
        "--params",
        default=None,
        type=click.Path(file_okay=False, dir_okay=True),
        help="Directory containing SAS tables",
    )(func)
    func = click.option("--year", default=None, help="NEP/NWAU edition year")(func)
    func = click.option(
        "--output",
        default="-",
        show_default=True,
        help="Output CSV path ('-' for stdout)",
    )(func)
    return func


@cli.command()
@_common_options
def acute(input_csv: str, params: str | None, output: str, year: str | None) -> None:
    """Calculate NWAU for acute care."""
    _run(calculate_acute, AcuteParams(), input_csv, output, year, params)


@cli.command()
@_common_options
def ed(input_csv: str, params: str | None, output: str, year: str | None) -> None:
    """Calculate NWAU for emergency department care."""
    _run(calculate_ed, EDParams(), input_csv, output, year, params)


@cli.command(name="non-admitted")
@_common_options
def non_admitted(
    input_csv: str, params: str | None, output: str, year: str | None
) -> None:
    """Calculate NWAU for non-admitted care."""
    _run(calculate_outpatients, OutpatientParams(), input_csv, output, year, params)


if __name__ == "__main__":  # pragma: no cover
    cli()
