from dataclasses import dataclass
from pathlib import Path
import pandas as pd
import numpy as np

from nwau_py.utils import sas_ref_dir


_DEFAULT_YEAR = "2025"

@dataclass
class MHParams:
    ppsa_option: int = 1
    adm_sstream: int = 1
    cmty_sstream: int = 1


def _load_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    path = ref_dir / f'nep{suffix}_mh_adm_price_weights.sas7bdat'
    df = pd.read_sas(path)
    if df['amhcc'].dtype == object:
        df['amhcc'] = df['amhcc'].str.decode('ascii')
    return df


def calculate_mh(
    df: pd.DataFrame,
    params: MHParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Simplified translation of ``NWAU25_CALCULATOR_MH.sas``."""
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    weights = _load_weights(ref_dir, year)
    merged = df.merge(weights, on='AMHCC', how='left')

    w01 = merged['amhcc_pw_inlier']
    gwau = w01 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0)) * (
        1 + merged.get('adj_treat_remoteness', 0))

    if params.ppsa_option == 1:
        adj_priv_serv = merged['PAT_PRIVATE_FLAG'] * merged.get('amhcc_adj_privpat_servnat', 0) * w01
    else:
        adj_priv_serv = merged['PAT_PRIVATE_FLAG'] * merged.get('amhcc_adj_privpat_serv', 0) * w01

    adj_priv_accomm = merged['PAT_PRIVATE_FLAG'] * (
        merged['PAT_SAMEDAY_FLAG'] * merged.get('state_adj_privpat_accomm_sd', 0) +
        (1 - merged['PAT_SAMEDAY_FLAG']) * merged['LOS'] * merged.get('state_adj_privpat_accomm_on', 0)
    )

    nwau = np.maximum(0, gwau - adj_priv_serv - adj_priv_accomm)
    merged['NWAU25'] = nwau
    return merged
