from dataclasses import dataclass
from pathlib import Path
import pandas as pd

_DEFAULT_REF_DIR = Path('archive/sas/NEP25_SAS_NWAU_calculator/calculators')

@dataclass
class SubacuteParams:
    radiotherapy_option: int = 1
    dialysis_option: int = 1
    est_remoteness_option: int = 1


def _load_weights(ref_dir: Path) -> pd.DataFrame:
    df = pd.read_sas(ref_dir / 'nep25_sa_snap_price_weights.sas7bdat')
    if df['snap'].dtype == object:
        df['snap'] = df['snap'].str.decode('ascii')
    return df


def calculate_subacute(df: pd.DataFrame, params: SubacuteParams, ref_dir: Path = _DEFAULT_REF_DIR) -> pd.DataFrame:
    """Simplified translation of ``NWAU25_CALCULATOR_SUBACUTE.sas``."""
    weights = _load_weights(ref_dir)
    merged = df.merge(weights, on='SNAP', how='left')

    w01 = merged['snap_pw']
    nwau = w01 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0))
    merged['NWAU25'] = nwau
    return merged
