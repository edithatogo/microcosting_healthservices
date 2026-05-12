from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd

from nwau_py.classification_validation import (
    get_classification_version,
    validate_aecc_input,
    validate_udg_input,
)
from nwau_py.data.paths import sas_table
from nwau_py.utils import sas_ref_dir

_DEFAULT_YEAR = "2025"


@dataclass
class EDParams:
    """Configuration for the ED calculator."""

    classification_option: int = 3
    eligibility_option: int = 1
    inscope_funding_sources: tuple[int, ...] = (1, 2, 8)
    debug_mode: bool = False
    clear_data: bool = False


def _load_weights(
    ref_dir: Path, classification_option: int, year: str = _DEFAULT_YEAR
) -> pd.DataFrame:
    if classification_option < 3:
        path = sas_table(
            "nep{suffix}_edudg_price_weights.sas7bdat",
            year=year,
            base_dir=ref_dir,
        )
        df = pd.read_sas(path)
        if df["UDG"].dtype == object:
            df["UDG"] = df["UDG"].str.decode("ascii")
    else:
        path = sas_table(
            "nep{suffix}_edaecc_price_weights.sas7bdat",
            year=year,
            base_dir=ref_dir,
        )
        df = pd.read_sas(path)
        if df["AECC"].dtype == object:
            df["AECC"] = df["AECC"].str.decode("ascii")
    return df


def _load_udg_map(ref_dir: Path) -> pd.DataFrame:
    path = sas_table("ed_tov_tri_epi_to_udg.sas7bdat", base_dir=ref_dir)
    df = pd.read_sas(path)
    if df["UDG"].dtype == object:
        df["UDG"] = df["UDG"].str.decode("ascii")
    return df


def calculate_ed(
    df: pd.DataFrame,
    params: EDParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Implement ``NWAU25_CALCULATOR_ED.sas`` against loaded reference tables."""
    if params.classification_option < 3:
        validate_udg_input(
            tuple(df.columns),
            year=year,
            version=get_classification_version("udg", year),
        )
    else:
        validate_aecc_input(
            tuple(df.columns),
            year=year,
            version=get_classification_version("aecc", year),
        )
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    suffix = str(year)[-2:]
    nwau_col = f"NWAU{suffix}"
    gwau_col = f"GWAU{suffix}"
    df = df.copy()

    if params.classification_option == 1:
        udg_map = _load_udg_map(ref_dir)
        df = df.merge(
            udg_map,
            left_on=["type_of_visit", "triage_category", "episode_end_status"],
            right_on=["type_of_visit", "triage_category", "episode_end_status"],
            how="left",
        )

    weights = _load_weights(ref_dir, params.classification_option, year)
    key = "UDG" if params.classification_option < 3 else "AECC"
    merged = df.merge(weights, on=key, how="left")

    if params.classification_option < 3:
        w01 = merged["udg_pw"]
        gwau = (w01 * (1 + merged.get("adj_treat_remoteness", 0))).round(6)
    else:
        w01 = merged["AECC_pw"]
        gwau = (
            w01
            * (1 + merged.get("adj_indigenous", 0) + merged.get("adj_remoteness", 0))
            * (1 + merged.get("adj_treat_remoteness", 0))
        ).round(8)

    weight_missing = w01.isna()
    if params.eligibility_option == 1:
        comp = merged.get("COMPENSABLE_STATUS")
        dva = merged.get("DVA_STATUS")
        missing_elig = comp.isna() | dva.isna()
        not_in_scope = ~comp.isin([2, 9]) | ~dva.isin([2, 9])
        merged["Error_Code"] = np.select(
            [weight_missing, missing_elig, not_in_scope],
            [3, 3, 2],
            default=0,
        )
    else:
        fund = merged.get("FUNDSC")
        out_scope = ~fund.isin(params.inscope_funding_sources)
        merged["Error_Code"] = np.select(
            [weight_missing, out_scope],
            [3, 2],
            default=0,
        )

    merged["_w01"] = w01
    merged[gwau_col] = gwau
    merged[nwau_col] = np.where(merged["Error_Code"] > 0, 0, gwau.round(8))

    result = merged
    if not params.debug_mode:
        result = result.drop(columns=[c for c in result.columns if c.startswith("_")])
    if params.clear_data:
        import shutil

        shutil.rmtree(".cache", ignore_errors=True)

    return result
