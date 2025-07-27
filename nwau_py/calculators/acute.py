from dataclasses import dataclass
from pathlib import Path
import pandas as pd
import numpy as np

from nwau_py.utils import sas_ref_dir


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


def _load_price_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    df = pd.read_sas(ref_dir / f'nep{suffix}_aa_price_weights.sas7bdat')
    if df['DRG'].dtype == object:
        df['DRG'] = df['DRG'].str.decode('ascii')
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
    weights = _load_price_weights(ref_dir, year)
    merged = df.merge(weights, on='DRG', how='left')

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
    merged['NWAU25'] = nwau25
    return merged
