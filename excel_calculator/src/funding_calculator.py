import json
import sys
import argparse
import pandas as pd
from pandas import DataFrame


def load_weights(csv_path: str) -> DataFrame:
    """Load the weight table from ``csv_path``.

    Column names are normalised by replacing newline characters with spaces
    and stripping surrounding whitespace so that names match the variables
    defined in ``formula.json``.
    """
    df = pd.read_csv(csv_path, engine="python")
    df.columns = [c.replace("\n", " ").strip() if isinstance(c, str) else c for c in df.columns]
    return df


def load_formula(json_path: str):
    """Load and return the formula description from ``json_path``."""
    with open(json_path, "r") as fh:
        return json.load(fh)


def calculate_funding(weights_df: DataFrame, formula) -> pd.Series:
    """Calculate funding amounts using ``weights_df`` and ``formula``.

    ``formula`` must define ``variables`` (mapping symbols to column names)
    and ``steps`` (a list of assignment expressions). Each step is executed
    with :func:`pandas.eval` and the resulting Series for ``NWAU25`` is
    returned.
    """
    env = {sym: weights_df[col] for sym, col in formula["variables"].items()}
    for step in formula["steps"]:
        lhs, expr = step.split("=")
        lhs = lhs.strip()
        expr = expr.strip()
        env[lhs] = pd.eval(expr, local_dict=env, engine="python")
    return env["NWAU25"]


def main(argv=None):
    """Command line entry point for funding calculation."""
    parser = argparse.ArgumentParser(description="Calculate IHACPA NWAU values")
    parser.add_argument("--weights", required=True, help="CSV containing weights")
    parser.add_argument("--formula", required=True, help="Formula JSON file")
    parser.add_argument("input_csv", help="Patient level CSV data")
    args = parser.parse_args(argv)

    weights = load_weights(args.weights)
    formula = load_formula(args.formula)
    patient_df = pd.read_csv(args.input_csv)
    df = pd.concat([weights, patient_df], axis=1)
    result = calculate_funding(df, formula)
    result.to_csv(sys.stdout, index=False, header=True)


if __name__ == "__main__":
    main()
