import sys

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
    """NWAU calculation commands."""


def _write_output(df: pd.DataFrame, output: str) -> None:
    outfh = sys.stdout if output == "-" else open(output, "w", newline="")
    try:
        df.to_csv(outfh, index=False)
    finally:
        if outfh is not sys.stdout:
            outfh.close()


def _common_options(func):
    func = click.argument("input_csv", type=click.Path(exists=True))(func)
    func = click.option("--output", default="-", show_default=True)(func)
    func = click.option("--year", default="2025", show_default=True)(func)
    return func


@cli.command()
@_common_options
@click.option("--icu/--no-icu", default=True, show_default=True)
@click.option("--covid/--no-covid", default=True, show_default=True)
def acute(input_csv: str, output: str, year: str, icu: bool, covid: bool) -> None:
    """Calculate NWAU for acute care."""
    df = pd.read_csv(input_csv)
    params = AcuteParams()
    if not icu:
        params.icu_paed_option = 2
    if not covid:
        params.covid_option = 2
        params.covid_adj_option = 2
    result = calculate_acute(df, params, year=year)
    _write_output(result, output)


@cli.command()
@_common_options
def ed(input_csv: str, output: str, year: str) -> None:
    """Calculate NWAU for emergency department care."""
    df = pd.read_csv(input_csv)
    params = EDParams()
    result = calculate_ed(df, params, year=year)
    _write_output(result, output)


@cli.command(name="non-admitted")
@_common_options
def non_admitted(input_csv: str, output: str, year: str) -> None:
    """Calculate NWAU for non-admitted care."""
    df = pd.read_csv(input_csv)
    params = OutpatientParams()
    result = calculate_outpatients(df, params, year=year)
    _write_output(result, output)


if __name__ == "__main__":
    cli()
