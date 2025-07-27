from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd

from nwau_py.utils import sas_ref_dir

_DEFAULT_YEAR = "2025"

@dataclass
class SubacuteParams:
    radiotherapy_option: int = 1
    dialysis_option: int = 1
    est_remoteness_option: int = 1
    debug_mode: bool = False
    clear_data: bool = False


def _load_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    df = pd.read_sas(ref_dir / f"nep{suffix}_sa_snap_price_weights.sas7bdat")
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.decode("ascii")
    if "ansnap" in df.columns:
        df = df.rename(columns={"ansnap": "ANSNAP"})
    elif "snap" in df.columns:
        df = df.rename(columns={"snap": "ANSNAP"})
    return df


def calculate_subacute(
    df: pd.DataFrame,
    params: SubacuteParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Partial translation of ``NWAU25_CALCULATOR_SUBACUTE.sas``.

    Only a subset of the SAS logic is implemented.  ``df`` should contain at
    least the columns ``ANSNAP``, ``ADM_DATE``, ``SEP_DATE``, ``LEAVE_DAYS`` and
    ``BIRTH_DATE``.  Private/public flags are expected in ``PAT_PRIVATE_FLAG``
    and ``PAT_PUBLIC_FLAG``.
    """
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    weights = _load_weights(ref_dir, year)
    merged = df.merge(weights, on="ANSNAP", how="left")

    adm = pd.to_datetime(merged["ADM_DATE"])
    sep = pd.to_datetime(merged["SEP_DATE"])
    leave = merged.get("LEAVE_DAYS", 0).fillna(0)
    los = (sep - adm).dt.days - leave
    los = los.clip(lower=1)
    los = np.where(adm.isna() | sep.isna() | (adm > sep), np.nan, los)
    merged["pat_los"] = los
    merged["_pat_sameday_flag"] = (adm == sep).astype(int)

    birth = pd.to_datetime(merged["BIRTH_DATE"])
    age = np.floor(((adm - birth).dt.days) / 365.25)
    merged["_pat_age_years"] = age

    ind_col = merged.get("INDSTAT", pd.Series(0, index=merged.index))
    merged["_pat_ind_flag"] = ind_col.isin([1, 2, 3]).astype(int)
    merged["_pat_private_flag"] = merged.get("PAT_PRIVATE_FLAG", 0)
    merged["_pat_public_flag"] = merged.get("PAT_PUBLIC_FLAG", 0)

    error_code = np.select(
        [
            (age >= 0) & (age <= 17) & ~merged["ANSNAP"].isin([
                "5F01",
                "5F02",
                "5F03",
                "5F04",
                "5F05",
                "5O01",
                "5G01",
                "5G02",
                "5G03",
                "5G04",
                "5P01",
                "5ES4",
                "5EL1",
            ]),
            merged["ANSNAP"].isna()
            | adm.isna()
            | sep.isna()
            | merged.get("STATE").isna(),
            adm > sep,
            (merged["_pat_public_flag"] + merged["_pat_private_flag"]) == 0,
            merged["ANSNAP"].isin(
                ["5J01", "5O01", "5K01", "5P01", "5L01", "5M01"]
            )
            & (
                (los > 1)
                | (merged["ansnap_samedaylist_flag"] != 1)
            ),
        ],
        [1, 3, 1, 2, 4],
        default=0,
    )
    merged["Error_Code"] = error_code.astype(int)

    merged["_pat_separation_category"] = np.select(
        [
            merged["ansnap_samedaylist_flag"] == 1,
            los < merged["ansnap_inlier_lb"],
            los <= merged["ansnap_inlier_ub"],
            los > merged["ansnap_inlier_ub"],
        ],
        [1, 2, 3, 4],
        default=np.nan,
    )

    w01 = np.select(
        [merged["_pat_separation_category"] == 1,
         merged["_pat_separation_category"] == 2,
         merged["_pat_separation_category"] == 3,
         merged["_pat_separation_category"] == 4],
        [
            merged["ansnap_pw_sd"],
            los * merged["ansnap_pw_sso_perdiem"].fillna(0),
            merged["ansnap_pw_inlier"],
            merged["ansnap_pw_inlier"]
            + (los - merged["ansnap_inlier_ub"])
            * merged["ansnap_pw_lso_perdiem"].fillna(0),
        ],
        default=0,
    )
    merged["_w01"] = w01.round(4)

    gwau = merged["_w01"] * (
        1
        + merged.get("adj_indigenous", 0)
        + merged.get("adj_remoteness", 0)
        + merged.get("adj_radiotherapy", 0)
        + merged.get("adj_dialysis", 0)
    ) * (1 + merged.get("adj_treat_remoteness", 0))

    adj_priv_serv = merged["_pat_private_flag"] * merged.get(
        "caretype_adj_privpat_serv_nat", 0
    ) * merged["_w01"]
    adj_priv_accomm = merged["_pat_private_flag"] * (
        merged["_pat_sameday_flag"] * merged.get("state_adj_privpat_accomm_sd", 0)
        + (1 - merged["_pat_sameday_flag"])
        * los
        * merged.get("state_adj_privpat_accomm_on", 0)
    )

    nwau = np.where(
        merged["Error_Code"] > 0,
        0,
        np.maximum(0, gwau - adj_priv_serv - adj_priv_accomm),
    )
    merged["NWAU25"] = nwau

    result = merged
    if not params.debug_mode:
        result = result.drop(columns=[c for c in result.columns if c.startswith("_")])
    if params.clear_data:
        import shutil
        shutil.rmtree(".cache", ignore_errors=True)

    return result
