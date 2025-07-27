from dataclasses import dataclass
from pathlib import Path
import pandas as pd
import numpy as np

from nwau_py.utils import sas_ref_dir
from nwau_py.data.loader import load_sas_table


_DEFAULT_YEAR = "2025"


@dataclass
class AcuteParams:
    """Configuration options for the acute calculator."""
    icu_paed_option: int = 1
    covid_option: int = 1
    covid_adj_option: int = 1
    radiotherapy_option: int = 1
    dialysis_option: int = 1
    ppservadj: int = 1
    est_remoteness_option: int = 1
    debug_mode: bool = False
    clear_data: bool = False


def _load_price_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    path = ref_dir / f"nep{suffix}_aa_price_weights.sas7bdat"
    df = load_sas_table(path, cache=True)
    if df["DRG"].dtype == object:
        df["DRG"] = df["DRG"].str.decode("ascii")
    return df


def calculate_acute(
    df: pd.DataFrame,
    params: AcuteParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Calculate NWAU25 for acute admitted episodes.

    This is a partial translation of ``NWAU25_CALCULATOR_ACUTE.sas`` using
    pandas operations.
    ``df`` is expected to contain columns ``DRG``, ``LOS``, ``ICU_HOURS``,
    ``ICU_OTHER``, ``PAT_SAMEDAY_FLAG`` and ``PAT_PRIVATE_FLAG``.
    """
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    suffix = str(year)[-2:]

    weights = _load_price_weights(ref_dir, year)
    merged = df.merge(weights, on="DRG", how="left")
    merged["_drg_inscope_flag"] = np.where(merged["drg_pw_inlier"].isna(), 0, 1)

    # ------------------------------------------------------------------
    # Radiotherapy and dialysis procedure flags
    # ------------------------------------------------------------------
    proc_cols = [c for c in merged.columns if "srg" in c.lower() or c.lower().startswith("proc")]

    def _flag_procs(codes: set[str]) -> pd.Series:
        if not proc_cols:
            return pd.Series(0, index=merged.index)
        proc_df = merged[proc_cols].fillna("").astype(str)
        proc_df = proc_df.replace({"/": "", "-": "", " ": ""}, regex=True)
        return proc_df.isin(codes).any(axis=1).astype(int)

    try:
        radio_codes = load_sas_table(ref_dir / f"nep{suffix}_radio_codes.sas7bdat")
        radio_set = set(radio_codes["code_ID"].astype(int).astype(str))
    except Exception:
        radio_set = set()
    try:
        dialysis_codes = load_sas_table(ref_dir / f"nep{suffix}_dialysis_codes.sas7bdat")
        dialysis_set = set(dialysis_codes["code_ID"].astype(int).astype(str))
    except Exception:
        dialysis_set = set()

    if params.radiotherapy_option == 2:
        merged["_pat_radiotherapy_flag"] = merged.get("PAT_RADIOTHERAPY_FLAG", 0).fillna(0)
    else:
        merged["_pat_radiotherapy_flag"] = _flag_procs(radio_set)

    if params.dialysis_option == 2:
        merged["_pat_dialysis_flag"] = merged.get("PAT_DIALYSIS_FLAG", 0).fillna(0)
    else:
        merged["_pat_dialysis_flag"] = _flag_procs(dialysis_set)

    # ------------------------------------------------------------------
    # ICU/paediatric eligibility
    # ------------------------------------------------------------------
    if params.icu_paed_option == 1 and "APCID" in merged.columns:
        try:
            icu_df = load_sas_table(ref_dir / f"nep{suffix}_icu_paed_eligibility_list.sas7bdat")
            apc_col = [c for c in icu_df.columns if c.startswith("APCID")][0]
            icu_df = icu_df.rename(columns={apc_col: "APCID"})
            icu_df = icu_df[["APCID", "_est_eligible_icu_flag", "_est_eligible_paed_flag"]]
            merged = merged.merge(icu_df, on="APCID", how="left")
        except Exception:
            merged["_est_eligible_icu_flag"] = 0
            merged["_est_eligible_paed_flag"] = 0
    else:
        merged["_est_eligible_icu_flag"] = merged.get("EST_ELIGIBLE_ICU_FLAG", 0)
        merged["_est_eligible_paed_flag"] = merged.get("EST_ELIGIBLE_PAED_FLAG", 0)

    merged["_est_eligible_icu_flag"] = merged["_est_eligible_icu_flag"].fillna(0)
    merged["_est_eligible_paed_flag"] = merged["_est_eligible_paed_flag"].fillna(0)

    # ------------------------------------------------------------------
    # Remoteness lookups
    # ------------------------------------------------------------------
    if params.est_remoteness_option == 1:
        pat_pc = next((c for c in ["PAT_POSTCODE", "POSTCODE"] if c in merged.columns), None)
        pat_sa2 = next((c for c in ["PAT_SA2", "SA2"] if c in merged.columns), None)
        if pat_pc:
            try:
                pc_df = load_sas_table(ref_dir / "postcode_to_ra2021.sas7bdat")
                merged = merged.merge(
                    pc_df.rename(columns={"POSTCODE": pat_pc, "ra2021": "PAT_ra2021"})[[pat_pc, "PAT_ra2021"]],
                    on=pat_pc,
                    how="left",
                )
            except Exception:
                merged["PAT_ra2021"] = np.nan
        else:
            merged["PAT_ra2021"] = np.nan
        if pat_sa2:
            try:
                sa2_df = load_sas_table(ref_dir / "sa2_to_ra2021.sas7bdat")
                merged = merged.merge(
                    sa2_df.rename(columns={"ASGS": pat_sa2, "ra2021": "SA2_ra2021"})[[pat_sa2, "SA2_ra2021"]],
                    on=pat_sa2,
                    how="left",
                )
            except Exception:
                merged["SA2_ra2021"] = np.nan
        else:
            merged["SA2_ra2021"] = np.nan
        if "APCID" in merged.columns:
            try:
                hosp_df = load_sas_table(ref_dir / f"nep{suffix}_hospital_ra2021.sas7bdat")
                apc_col = [c for c in hosp_df.columns if c.startswith("APCID")][0]
                hosp_df = hosp_df.rename(columns={apc_col: "APCID"})
                merged = merged.merge(hosp_df[["APCID", "_hosp_ra_2021"]], on="APCID", how="left")
            except Exception:
                merged["_hosp_ra_2021"] = np.nan
        else:
            merged["_hosp_ra_2021"] = np.nan

        merged["_pat_remoteness"] = (
            merged["SA2_ra2021"].combine_first(merged["PAT_ra2021"]).combine_first(merged["_hosp_ra_2021"])
        )
        merged["_treat_remoteness"] = merged["_hosp_ra_2021"].fillna(0)
    else:
        merged["_pat_remoteness"] = merged.get("EST_REMOTENESS", np.nan)
        merged["_treat_remoteness"] = merged.get("EST_REMOTENESS", 0)

    # ------------------------------------------------------------------
    # Basic patient variables
    # ------------------------------------------------------------------
    merged["_pat_los"] = merged.get("LOS")
    if "PAT_SAMEDAY_FLAG" in merged.columns:
        merged["_pat_sameday_flag"] = merged["PAT_SAMEDAY_FLAG"]
    else:
        merged["_pat_sameday_flag"] = 0
    merged["_pat_private_flag"] = merged.get("PAT_PRIVATE_FLAG", 0)
    merged["_pat_public_flag"] = 1 - merged["_pat_private_flag"]
    merged["_pat_acute_flag"] = 1

    # ------------------------------------------------------------------
    # Error code calculation
    # ------------------------------------------------------------------
    merged["Error_Code"] = np.select(
        [
            merged["_pat_los"].isna() | merged["DRG"].isna(),
            (merged["_pat_public_flag"] + merged["_pat_private_flag"]) == 0,
            (merged["_pat_acute_flag"] == 0) | (merged["_drg_inscope_flag"] == 0),
        ],
        [3, 2, 1],
        default=0,
    )


    icu_hours = merged.get('ICU_HOURS', 0)
    icu_other = merged.get('ICU_OTHER', 0)
    bundled = merged['drg_bundled_icu_flag'].fillna(0)
    covid_flag = merged.get('PAT_COVID_FLAG', 0)

    eligible_icu = np.where(
        covid_flag == 1,
        (1 - bundled) * (icu_hours + icu_other),
        (1 - bundled) * icu_hours,
    )
    merged['_pat_eligible_icu_hours'] = eligible_icu

    merged['_pat_los_icu_removed'] = (merged['LOS'] - (eligible_icu / 24).astype(int)).clip(lower=1)

    conds = [
        (merged['PAT_SAMEDAY_FLAG'] == 1) & (merged['drg_samedaylist_flag'] == 1),
        merged['_pat_los_icu_removed'] < merged['drg_inlier_lb'],
        merged['_pat_los_icu_removed'] <= merged['drg_inlier_ub'],
        merged['_pat_los_icu_removed'] > merged['drg_inlier_ub'],
    ]
    merged['_pat_separation_category'] = np.select(conds, [1, 2, 3, 4], default=np.nan)

    w01 = np.select(
        [merged['_pat_separation_category'] == 1,
         merged['_pat_separation_category'] == 2,
         merged['_pat_separation_category'] == 3,
         merged['_pat_separation_category'] == 4],
        [merged['drg_pw_sd'],
         merged['drg_pw_sso_base'].fillna(0) + merged['_pat_los_icu_removed'] * merged['drg_pw_sso_perdiem'],
         merged['drg_pw_inlier'],
         merged['drg_pw_inlier'] + (merged['_pat_los_icu_removed'] - merged['drg_inlier_ub']) * merged['drg_pw_lso_perdiem'].fillna(0)],
        default=0,
    )
    w01 = w01.round(4)
    w02 = np.where(merged.get('_pat_eligible_paed_flag', 0) == 1,
                   merged['drg_adj_paed'] * w01,
                   w01)
    w03 = w02 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0) +
                 merged.get('adj_radiotherapy', 0) + merged.get('adj_dialysis', 0)) * (
                     1 + merged.get('adj_treat_remoteness', 0))
    w04 = w03 * (1 + merged.get('adj_covid', 0))

    adj_icu = merged.get('_pat_eligible_icu_hours', 0) * merged.get('icu_rate', 0)
    gwau25 = np.maximum(0, w04 + adj_icu)

    drg_adj_serv = merged.get('drg_adj_privpat_serv', 0)
    adj_priv_serv = merged['PAT_PRIVATE_FLAG'] * drg_adj_serv * (w01 + adj_icu)
    adj_priv_accomm = merged['PAT_PRIVATE_FLAG'] * (
        merged['PAT_SAMEDAY_FLAG'] * merged.get('state_adj_privpat_accomm_sd', 0) +
        (1 - merged['PAT_SAMEDAY_FLAG']) * merged['LOS'] * merged.get('state_adj_privpat_accomm_on', 0)
    )

    nwau25 = np.maximum(0, gwau25 - adj_priv_serv - adj_priv_accomm)
    merged['NWAU25'] = np.where(merged['Error_Code'] > 0, 0, nwau25)

    result = merged
    if not params.debug_mode:
        result = result.drop(columns=[c for c in result.columns if c.startswith("_")])
    if params.clear_data:
        import shutil
        shutil.rmtree(".cache", ignore_errors=True)

    return result
