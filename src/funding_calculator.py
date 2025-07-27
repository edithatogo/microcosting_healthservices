import json
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
