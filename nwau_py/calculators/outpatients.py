from dataclasses import dataclass
from pathlib import Path
import pandas as pd
import numpy as np

_DEFAULT_REF_DIR = Path('archive/sas/NEP25_SAS_NWAU_calculator/calculators')

@dataclass
class OutpatientParams:
    paed_option: int = 1
    est_remoteness_option: int = 1


def _load_weights(ref_dir: Path) -> pd.DataFrame:
    df = pd.read_sas(ref_dir / 'nep25_op_price_weights.sas7bdat')
    if df['clinic_code'].dtype == object:
        df['clinic_code'] = df['clinic_code'].str.decode('ascii')
    return df


def calculate_outpatients(df: pd.DataFrame, params: OutpatientParams, ref_dir: Path = _DEFAULT_REF_DIR) -> pd.DataFrame:
    """Simplified translation of ``NWAU25_CALCULATOR_OUTPATIENTS.sas``."""
    weights = _load_weights(ref_dir)
    merged = df.merge(weights, on='CLINIC_CODE', how='left')

    w01 = merged['op_pw']
    nwau = w01 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0))
    merged['NWAU25'] = nwau
    return merged
