"""Command line interface for the NWAU calculators."""

from __future__ import annotations

from collections.abc import Callable
from typing import IO, Any

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
from nwau_py.runtime import run_csv_calculation


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
    run_csv_calculation(
        input_csv=input_csv,
        output=output,
        calculator=calculator,
        params=params,
        year=year,
        ref_dir=ref_dir,
        read_csv=pd.read_csv,
        write_csv=_write_output,
    )


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


def common_options(func: Callable[..., Any]) -> Callable[..., Any]:
    options = [
        click.argument("input_csv", type=click.Path(exists=True)),
        click.option(
            "--params",
            default=None,
            type=click.Path(file_okay=False, dir_okay=True),
            help="Directory containing SAS tables",
        ),
        click.option(
            "--year",
            default=None,
            help="NEP/NWAU edition year",
        ),
        click.option(
            "--output",
            default="-",
            show_default=True,
            help="Output CSV path ('-' for stdout)",
        ),
        click.option(
            "--icu/--no-icu",
            default=True,
            show_default=True,
            help="Include ICU adjustments",
        ),
        click.option(
            "--covid/--no-covid",
            default=True,
            show_default=True,
            help="Include COVID adjustments",
        ),
    ]
    for opt in reversed(options):
        func = opt(func)
    return func


@click.group()
def cli() -> None:
    """NWAU calculation commands."""


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
