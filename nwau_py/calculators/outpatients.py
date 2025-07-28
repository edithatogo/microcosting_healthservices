from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd

from nwau_py.utils import ra_suffix, sas_ref_dir

_DEFAULT_YEAR = "2025"


@dataclass
class OutpatientParams:
    paed_option: int = 1
    est_remoteness_option: int = 1
    debug_mode: bool = False
    clear_data: bool = False
    data_type: int = 1
    inscope_funding_sources: tuple[int, ...] = (1, 2, 8)
      

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


def _load_hospital_ra(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    ra = ra_suffix(year)
    df = pd.read_sas(ref_dir / f"nep{suffix}_hospital_{ra}.sas7bdat")
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.decode("ascii")
    apc_col = [c for c in df.columns if c.startswith("APCID")][0]
    return df.rename(columns={apc_col: "APCID"})[
        ["APCID", f"_hosp_{ra.replace('ra', 'ra_')}"]
    ]


def _load_postcode_ra(ref_dir: Path, ra: str) -> pd.DataFrame:
    df = pd.read_sas(ref_dir / f"postcode_to_{ra}.sas7bdat")
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.decode("ascii")
    ra_col = next((c for c in df.columns if ra.lower() in c.lower()), ra)
    return df.rename(columns={"POSTCODE": "POSTCODE", ra_col: ra})


def _load_sa2_ra(ref_dir: Path, ra: str) -> pd.DataFrame:
    try:
        df = pd.read_sas(ref_dir / f"sa2_to_{ra}.sas7bdat")
    except FileNotFoundError:
        if ra == "ra2011":
            df = pd.read_sas(ref_dir / "asgs_to_ra2011.sas7bdat")
        elif ra == "ra2006":
            df = pd.read_sas(ref_dir / "sla_to_ra2006.sas7bdat")
        else:
            raise
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.decode("ascii")
    key = next(
        (
            c
            for c in df.columns
            if c.lower().startswith("asgs")
            or c.lower().startswith("sa2")
            or c.lower().startswith("sla")
        ),
        "SA2",
    )
    ra_col = next((c for c in df.columns if ra.lower() in c.lower()), ra)
    return df.rename(columns={key: "SA2", ra_col: ra})


def _load_icu_list(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    df = pd.read_sas(ref_dir / f"nep{suffix}_icu_paed_eligibility_list.sas7bdat")
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.decode("ascii")
    apc_col = [c for c in df.columns if c.startswith("APCID")][0]
    return df.rename(columns={apc_col: "APCID"})[["APCID", "_est_eligible_paed_flag"]]


def calculate_outpatients(
    df: pd.DataFrame,
    params: OutpatientParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Calculate NWAU25 for outpatient activity.

    Mirrors ``NWAU25_CALCULATOR_OUTPATIENTS.sas``.
    """
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    ra = ra_suffix(year)
    weights = _load_weights(ref_dir, year)
    merged = df.merge(weights, on="TIER2_CLINIC", how="left")

    # --------------------------------------------------------------
    # Establishment remoteness lookups
    # --------------------------------------------------------------
    if params.est_remoteness_option == 1:
        hosp_col = f"_hosp_{ra.replace('ra', 'ra_')}"
        if "APCID" in merged.columns:
            try:
                hosp_df = _load_hospital_ra(ref_dir, year)
                merged = merged.merge(hosp_df, on="APCID", how="left")
            except (FileNotFoundError, KeyError, ValueError):
                merged[hosp_col] = np.nan
        else:
            merged[hosp_col] = np.nan

        pat_pc = next(
            (c for c in ["PAT_POSTCODE", "POSTCODE"] if c in merged.columns),
            None,
        )
        pat_sa2 = next(
            (c for c in ["PAT_SA2", "SA2"] if c in merged.columns),
            None,
        )

        if pat_pc:
            try:
                pc_df = _load_postcode_ra(ref_dir, ra)
                pc_df = pc_df.rename(
                    columns={"POSTCODE": pat_pc, ra: f"PAT_{ra}"}
                )
                merged = merged.merge(
                    pc_df[[pat_pc, f"PAT_{ra}"]],
                    on=pat_pc,
                    how="left",
                )
            except Exception:
                merged[f"PAT_{ra}"] = np.nan
        else:
            merged[f"PAT_{ra}"] = np.nan

        if pat_sa2:
            try:
                sa2_df = _load_sa2_ra(ref_dir, ra)
                sa2_df = sa2_df.rename(
                    columns={"SA2": pat_sa2, ra: f"SA2_{ra}"}
                )
                merged = merged.merge(
                    sa2_df[[pat_sa2, f"SA2_{ra}"]],
                    on=pat_sa2,
                    how="left",
                )
            except Exception:
                merged[f"SA2_{ra}"] = np.nan
        else:
            merged[f"SA2_{ra}"] = np.nan

        merged["_pat_remoteness"] = (
            merged.get(f"SA2_{ra}")
            .combine_first(merged.get(f"PAT_{ra}"))
            .combine_first(merged.get(hosp_col))
        )
        merged["_treat_remoteness"] = merged.get(hosp_col, 0).fillna(0)
    else:
        merged["_pat_remoteness"] = merged.get(
            "PAT_REMOTENESS",
            merged.get("EST_REMOTENESS", np.nan),
        )
        merged["_treat_remoteness"] = merged.get("EST_REMOTENESS", 0)

    if params.data_type == 1:
        service = pd.to_datetime(merged.get("SERVICE_DATE"))
        birth = pd.to_datetime(merged.get("BIRTH_DATE"))
        age = np.floor(((service - birth).dt.days) / 365.25)
        merged["_pat_age_years"] = age

        if params.paed_option == 1 and "APCID" in merged.columns:
            try:
                paed_df = _load_icu_list(ref_dir, year)
                merged = merged.merge(paed_df, on="APCID", how="left")
            except Exception:
                merged["_est_eligible_paed_flag"] = 0
        else:
            merged["_est_eligible_paed_flag"] = merged.get("EST_ELIGIBLE_PAED_FLAG", 0)

        est_flag = merged.get("_est_eligible_paed_flag", 0)
        merged["_pat_eligible_paed_flag"] = (
            (age >= 0) & (age <= 17) & (est_flag == 1)
        ).astype(int)
    else:
        merged["_pat_age_years"] = np.nan
        merged["_pat_eligible_paed_flag"] = 0

    merged["_pat_remoteness"] = merged.get(
        "PAT_REMOTENESS", merged.get("EST_REMOTENESS", 0)
    )
    ind_col = merged.get("INDSTAT", pd.Series(0, index=merged.index))
    merged["_pat_ind_flag"] = ind_col.isin([1, 2, 3]).astype(int)

    if "FUNDSC" in merged.columns:
        out_scope = ~merged["FUNDSC"].isin(params.inscope_funding_sources)
    else:
        out_scope = merged.get("INSCOPE_FLAG", 1) == 0

    error_code = np.select(
        [merged["clinic_pw"].isna(), out_scope, merged["clinic_pw"] == 0],
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

    if params.data_type == 1:
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
    else:
        treat = 1 + merged.get("adj_treat_remoteness", 0)
        counts = (
            merged.get("GROUP_EVENT_COUNT", 0).fillna(0)
            + merged.get("INDIV_EVENT_COUNT", 0).fillna(0)
        )
        counts_multi = counts + merged.get("MULTI_DISP_CONF_COUNT", 0).fillna(0)

        gwau = np.select(
            [
                (multiprov_flag == 1)
                & ~merged["TIER2_CLINIC"].isin([20.48, 20.56, 40.62]),
                (multiprov_flag == 1)
                & merged["TIER2_CLINIC"].isin([20.48, 20.56, 40.62]),
            ],
            [w01 * (1 + adj_multi) * treat * counts_multi, w01 * treat * counts_multi],
            default=w01 * treat * counts,
        )

    nwau = np.where(merged["Error_Code"] > 0, 0, gwau)
    merged["NWAU25"] = nwau

    result = merged
    if not params.debug_mode:
        result = result.drop(columns=[c for c in result.columns if c.startswith("_")])
    if params.clear_data:
        import shutil
        shutil.rmtree(".cache", ignore_errors=True)

    return result
