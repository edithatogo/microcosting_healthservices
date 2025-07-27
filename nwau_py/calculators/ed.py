from dataclasses import dataclass
from pathlib import Path
import pandas as pd
import numpy as np

_DEFAULT_REF_DIR = Path('archive/sas/NEP25_SAS_NWAU_calculator/calculators')

@dataclass
class EDParams:
    """Configuration for the ED calculator."""
    classification_option: int = 3


def _load_weights(ref_dir: Path, classification_option: int) -> pd.DataFrame:
    if classification_option < 3:
        path = ref_dir / 'nep25_edudg_price_weights.sas7bdat'
        df = pd.read_sas(path)
        if df['UDG'].dtype == object:
            df['UDG'] = df['UDG'].str.decode('ascii')
    else:
        path = ref_dir / 'nep25_edaecc_price_weights.sas7bdat'
        df = pd.read_sas(path)
        if df['AECC'].dtype == object:
            df['AECC'] = df['AECC'].str.decode('ascii')
    return df


def calculate_ed(df: pd.DataFrame, params: EDParams, ref_dir: Path = _DEFAULT_REF_DIR) -> pd.DataFrame:
    """Partial translation of ``NWAU25_CALCULATOR_ED.sas``."""
    weights = _load_weights(ref_dir, params.classification_option)
    key = 'UDG' if params.classification_option < 3 else 'AECC'
    merged = df.merge(weights, on=key, how='left')

    if params.classification_option < 3:
        w01 = merged['udg_pw']
        gwau = w01 * (1 + merged.get('adj_treat_remoteness', 0))
    else:
        w01 = merged['aecc_pw']
        gwau = w01 * (1 + merged.get('adj_indigenous', 0) + merged.get('adj_remoteness', 0)) * (
            1 + merged.get('adj_treat_remoteness', 0))

    nwau = gwau.round(8)
    merged['NWAU25'] = np.where(merged.get('Error_Code', 0) > 0, 0, nwau)
    return merged
