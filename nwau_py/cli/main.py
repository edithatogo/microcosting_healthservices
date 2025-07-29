import sys
from collections.abc import Callable
from pathlib import Path
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

cli = click.Group()


def _write_output(df: pd.DataFrame, outfh: IO[str]) -> None:
    df.to_csv(outfh, index=False)


def _run(
    calculator: Callable[..., pd.DataFrame],
    params: Any,
    input_csv: str,
    outfh: IO[str],
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
    _write_output(result, outfh)


def run_cli(
    calculator: Callable[..., pd.DataFrame],
    params: Any,
    input_csv: str,
    output: str,
    year: str | None,
    ref_dir: str | None,
) -> None:
    outfh = sys.stdout if output == "-" else open(output, "w", newline="")
    try:
        _run(calculator, params, input_csv, outfh, year, ref_dir)
    finally:
        if outfh is not sys.stdout:
            outfh.close()

def _common_options(func):
    func = click.argument("input_csv", type=click.Path(exists=True))(func)
    func = click.option("--output", default="-", show_default=True)(func)
    func = click.option("--year", default="2025", show_default=True)(func)
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
@common_options
def acute(
    input_csv: str,
    params: str | None,
    output: str,
    icu: bool,
    covid: bool,
    year: str | None,
) -> None:
    """Calculate NWAU for acute care."""
    ac_params = AcuteParams(
        icu_paed_option=1 if icu else 2,
        covid_option=1 if covid else 2,
        covid_adj_option=1 if covid else 2,
    )
    run_cli(calculate_acute, ac_params, input_csv, output, year, params)


@cli.command()
@common_options
def ed(
    input_csv: str,
    params: str | None,
    output: str,
    icu: bool,
    covid: bool,
    year: str | None,
) -> None:
    """Calculate NWAU for emergency department care."""
    run_cli(calculate_ed, EDParams(), input_csv, output, year, params)


@cli.command(name="non-admitted")
@common_options
def non_admitted(
    input_csv: str,
    params: str | None,
    output: str,
    icu: bool,
    covid: bool,
    year: str | None,
) -> None:
    """Calculate NWAU for non-admitted care."""
    run_cli(calculate_outpatients, OutpatientParams(), input_csv, output, year, params)


if __name__ == "__main__":
    cli()

