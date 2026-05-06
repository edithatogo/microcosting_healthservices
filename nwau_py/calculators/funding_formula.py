"""Helpers for evaluating formula contracts against tabular weight inputs."""

from __future__ import annotations

import json
import os
from typing import Any

import pandas as pd
from pandas import DataFrame


def load_weights(csv_path: str | bytes | os.PathLike[str]) -> DataFrame:
    """Load a weight table from ``csv_path`` and normalize header text."""
    df = pd.read_csv(csv_path, engine="python")
    df.columns = [
        c.replace("\n", " ").strip() if isinstance(c, str) else c for c in df.columns
    ]
    return df


def load_formula(json_path: str | bytes | os.PathLike[str]) -> dict[str, Any]:
    """Return the JSON formula contract from ``json_path``."""
    with open(json_path) as fh:
        return json.load(fh)


def calculate_funding(weights_df: DataFrame, formula: dict[str, Any]) -> pd.Series:
    """Evaluate ``formula`` against ``weights_df`` using the declared symbols."""
    env = {sym: weights_df[col] for sym, col in formula["variables"].items()}
    for step in formula["steps"]:
        lhs, expr = step.split("=")
        lhs = lhs.strip()
        expr = expr.strip()
        env[lhs] = pd.eval(expr, local_dict=env, engine="python")
    return env["NWAU25"]
