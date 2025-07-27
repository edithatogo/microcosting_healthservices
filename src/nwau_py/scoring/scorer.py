from __future__ import annotations

from pathlib import Path
from typing import List

import lightgbm as lgb
import numpy as np
import pandas as pd


# Paths to model and parameter files relative to repository root
_BASE_DIR = Path(__file__).resolve().parents[3] / 'archive' / 'sas' / 'NEP25_SAS_NWAU_calculator' / 'calculators'
_MODELS_DIR = _BASE_DIR / 'models'
_PARAMS_DIR = _BASE_DIR / 'params'


def _model_vars(n: int, risk_factors_df: pd.DataFrame) -> List[str]:
    """Return list of risk factors for the ``n``th readmission category."""
    ret = [x for x in risk_factors_df[str(n)].dropna().tolist() if str(x) != 'nan']
    common = [
        'an110mdc_ra',
        'agegroup_rm',
        'flag_emergency',
        'pat_remoteness',
        'indstat_flag',
        'count_proc',
        'adm_past_year',
    ]
    for risk in common:
        if risk not in ret:
            ret.append(risk)
    return ret


def _rescale_to_points(x: pd.Series, data_min: float, data_max: float) -> pd.Series:
    """Scale ``x`` to the range 1..100 given ``data_min`` and ``data_max``."""
    return (((x - data_min) / (data_max - data_min)) * 99 + 1).clip(1, 100)


# Load model resources on import
_risk_factors = pd.read_csv(_MODELS_DIR / 'risk_factors.csv', index_col=0)
_models = {i: lgb.Booster(model_file=str(_MODELS_DIR / f'model_4year_sta_readm{i}_90_limited.txt')) for i in range(1, 13)}
_scaling_params = pd.read_csv(_PARAMS_DIR / 'scaling_params.csv', index_col=0)
_cutoffs = pd.read_csv(_PARAMS_DIR / 'cutoffs.csv', index_col=0)
_dampening = pd.read_csv(_PARAMS_DIR / 'dampening.csv', index_col=0)

# Union of all required variables
_model_vars_union = set().union(*(
    _risk_factors[str(i)].dropna().tolist() for i in range(1, 13)
))


def score_readmission(df: pd.DataFrame) -> pd.DataFrame:
    """Score readmission risk for ``df``.

    Parameters
    ----------
    df : :class:`pandas.DataFrame`
        Input dataframe containing the variables required for the models.

    Returns
    -------
    :class:`pandas.DataFrame`
        Dataframe containing ``risk_category1`` .. ``risk_category12`` and
        ``dampening1`` .. ``dampening12`` columns.
    """
    data = df.copy()
    data.columns = data.columns.str.lower()

    if 'drg11_type' in data.columns:
        data['drg11_type_m'] = (data['drg11_type'] == 'M').astype(np.int8)
    if 'an110mdc_ra' in data.columns:
        data['an110mdc_ra'] = data['an110mdc_ra'].replace('.', '99')

    for col in _model_vars_union:
        if col not in data.columns:
            data[col] = 0
        data[col] = data[col].astype(np.int64)

    for col in data.columns:
        if col not in {'count_proc', 'adm_past_year'}:
            data[col] = data[col].astype('category')
        else:
            data[col] = data[col].astype(np.int32)

    results = pd.DataFrame(index=data.index)

    for i in range(1, 13):
        vars_i = _model_vars(i, _risk_factors)
        probs = _models[i].predict(data[vars_i])
        log_probs = np.log(probs)
        points = _rescale_to_points(
            x=log_probs,
            data_min=_scaling_params.loc[i, 'mins'],
            data_max=_scaling_params.loc[i, 'maxs'],
        )
        conditions = [
            points < _cutoffs.iloc[0, i - 1],
            (points >= _cutoffs.iloc[0, i - 1]) & (points < _cutoffs.iloc[1, i - 1]),
            points >= _cutoffs.iloc[1, i - 1],
        ]
        choices = [
            _dampening.iloc[0, i - 1],
            _dampening.iloc[1, i - 1],
            _dampening.iloc[2, i - 1],
        ]
        choices_cat = [0, 1, 2]
        results[f'dampening{i}'] = np.select(conditions, choices, default=np.nan)
        results[f'risk_category{i}'] = np.select(conditions, choices_cat, default=np.nan)

    return results

__all__ = ['score_readmission']
