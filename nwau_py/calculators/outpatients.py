from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd

from nwau_py.utils import sas_ref_dir

_DEFAULT_YEAR = "2025"

@dataclass
class OutpatientParams:
    paed_option: int = 1
    est_remoteness_option: int = 1


def _load_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    df = pd.read_sas(ref_dir / f"nep{suffix}_op_price_weights.sas7bdat")
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.decode("ascii")
    if "tier2_clinic" in df.columns:
        df = df.rename(columns={"tier2_clinic": "TIER2_CLINIC"})
    elif "clinic_code" in df.columns:
        df = df.rename(columns={"clinic_code": "TIER2_CLINIC"})
    return df


def calculate_outpatients(
    df: pd.DataFrame,
    params: OutpatientParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Partial translation of ``NWAU25_CALCULATOR_OUTPATIENTS.sas``."""
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    weights = _load_weights(ref_dir, year)
    merged = df.merge(weights, on="TIER2_CLINIC", how="left")

    service = pd.to_datetime(merged.get("SERVICE_DATE"))
    birth = pd.to_datetime(merged.get("BIRTH_DATE"))
    age = np.floor(((service - birth).dt.days) / 365.25)
    merged["_pat_age_years"] = age

    est_flag = merged.get("EST_ELIGIBLE_PAED_FLAG", 0)
    merged["_pat_eligible_paed_flag"] = (
        (age >= 0) & (age <= 17) & (est_flag == 1)
    ).astype(int)

    merged["_pat_remoteness"] = merged.get(
        "PAT_REMOTENESS", merged.get("EST_REMOTENESS", 0)
    )
    ind_col = merged.get("INDSTAT", pd.Series(0, index=merged.index))
    merged["_pat_ind_flag"] = ind_col.isin([1, 2, 3]).astype(int)

    error_code = np.select(
        [
            merged["clinic_pw"].isna(),
            merged.get("INSCOPE_FLAG", 1) == 0,
            merged["clinic_pw"] == 0,
        ],
        [3, 2, 1],
        default=0,
    )
    merged["Error_Code"] = error_code.astype(int)

    multiprov_flag = merged.get("PAT_MULTIPROV_FLAG", 0)
    adj_multi = merged.get("adj_multiprov", 0)

    cond1 = (
        (merged["_pat_eligible_paed_flag"] == 1)
        & (multiprov_flag == 1)
        & ~merged["TIER2_CLINIC"].isin([20.48, 20.56, 40.62])
    )
    cond2 = (
        (merged["_pat_eligible_paed_flag"] == 1)
        & (multiprov_flag == 1)
        & merged["TIER2_CLINIC"].isin([20.48, 20.56, 40.62])
    )
    cond3 = (
        (merged["_pat_eligible_paed_flag"] != 1)
        & (multiprov_flag == 1)
        & ~merged["TIER2_CLINIC"].isin([20.48, 20.56, 40.62])
    )
    cond4 = (
        (merged["_pat_eligible_paed_flag"] == 1) & (multiprov_flag != 1)
    )

    w01 = merged["clinic_pw"]
    base = 1 + merged.get("adj_indigenous", 0) + merged.get("adj_remoteness", 0)
    treat = 1 + merged.get("adj_treat_remoteness", 0)

    gwau = np.select(
        [cond1, cond2, cond3, cond4],
        [
            w01 * merged["tier2_adj_paed"] * (base + adj_multi) * treat,
            w01 * merged["tier2_adj_paed"] * base * treat,
            w01 * (base + adj_multi) * treat,
            w01 * merged["tier2_adj_paed"] * base * treat,
        ],
        default=w01 * base * treat,
    )

    nwau = np.where(merged["Error_Code"] > 0, 0, gwau)
    merged["NWAU25"] = nwau
    return merged
