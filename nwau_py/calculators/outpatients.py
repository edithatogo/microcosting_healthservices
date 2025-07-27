from dataclasses import dataclass
from pathlib import Path
import pandas as pd

from nwau_py.utils import sas_ref_dir


_DEFAULT_YEAR = "2025"

@dataclass
class OutpatientParams:
    paed_option: int = 1
    est_remoteness_option: int = 1


def _load_weights(ref_dir: Path, year: str = _DEFAULT_YEAR) -> pd.DataFrame:
    suffix = str(year)[-2:]
    df = pd.read_sas(ref_dir / f'nep{suffix}_op_price_weights.sas7bdat')
    if df['clinic_code'].dtype == object:
        df['clinic_code'] = df['clinic_code'].str.decode('ascii')
    return df


def calculate_outpatients(
    df: pd.DataFrame,
    params: OutpatientParams,
    *,
    year: str = _DEFAULT_YEAR,
    ref_dir: Path | None = None,
) -> pd.DataFrame:
    """Simplified translation of ``NWAU25_CALCULATOR_OUTPATIENTS.sas``."""
    if ref_dir is None:
        ref_dir = sas_ref_dir(year)
    weights = _load_weights(ref_dir, year)
    merged = df.merge(weights, on='CLINIC_CODE', how='left')

    w01 = merged['op_pw']
    nwau = w01 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0))
    merged['NWAU25'] = nwau
    return merged
