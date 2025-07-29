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
    calculate_funding,
    load_formula,
    load_weights,
)


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
