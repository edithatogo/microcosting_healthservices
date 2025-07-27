from dataclasses import dataclass
from pathlib import Path
import pandas as pd

from nwau_py.utils import sas_ref_dir


_DEFAULT_YEAR = "2025"

@dataclass
class SubacuteParams:
    radiotherapy_option: int = 1
    dialysis_option: int = 1
    est_remoteness_option: int = 1


def _load_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    df = pd.read_sas(ref_dir / f'nep{suffix}_sa_snap_price_weights.sas7bdat')
    if df['snap'].dtype == object:
        df['snap'] = df['snap'].str.decode('ascii')
    return df


def calculate_subacute(
    df: pd.DataFrame,
    params: SubacuteParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Simplified translation of ``NWAU25_CALCULATOR_SUBACUTE.sas``."""
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    weights = _load_weights(ref_dir, year)
    merged = df.merge(weights, on='SNAP', how='left')

    w01 = merged['snap_pw']
    nwau = w01 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0))
    merged['NWAU25'] = nwau
    return merged
