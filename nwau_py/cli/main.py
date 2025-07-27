import sys
from pathlib import Path

import click
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "excel_calculator" / "src"))  # noqa: E402

from funding_calculator import load_weights, load_formula, calculate_funding  # noqa: E402


def calculate(input_csv: str, params: str, outfh, icu: bool, covid: bool) -> None:
    """Load data, apply the formula and write the output CSV."""
    params_path = Path(params)
    load_weights(params_path / "weights.csv")
    formula = load_formula(params_path / "formula.json")

    df = pd.read_csv(input_csv)

    if not icu:
        for col in ["Bundled ICU", "ICU Hours"]:
            if col in df.columns:
                df[col] = 0
    if not covid:
        col = "COVID-19 Treatment Adjustment"
        if col in df.columns:
            df[col] = 0

    df["NWAU25"] = calculate_funding(df, formula)
    df.to_csv(outfh, index=False)


def run_cli(input_csv: str, params: str, output: str, icu: bool, covid: bool) -> None:
    outfh = sys.stdout if output == "-" else open(output, "w", newline="")
    try:
        calculate(input_csv, params, outfh, icu, covid)
    finally:
        if outfh is not sys.stdout:
            outfh.close()


def common_options(func):
    options = [
        click.argument("input_csv", type=click.Path(exists=True)),
        click.option(
            "--params",
            default="excel_calculator/data",
            show_default=True,
            type=click.Path(file_okay=False, dir_okay=True),
            help="Directory containing weights.csv and formula.json",
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
def cli():
    """NWAU calculation commands."""


@cli.command()
@common_options
def acute(**kwargs):
    """Calculate NWAU for acute care."""
    run_cli(**kwargs)


@cli.command()
@common_options
def ed(**kwargs):
    """Calculate NWAU for emergency department care."""
    run_cli(**kwargs)


@cli.command(name="non-admitted")
@common_options
def non_admitted(**kwargs):
    """Calculate NWAU for non-admitted care."""
    run_cli(**kwargs)


if __name__ == "__main__":
    cli()
