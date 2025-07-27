import pandas as pd
from typing import Sequence

def calculate_adjusted_nwau(
    df: pd.DataFrame,
    *,
    base_nwau_col: str = "nwau25",
    weight_col: str = "_w01",
    ahr_weight_col: str | None = None,
    hac_flag_cols: Sequence[str] | None = None,
    hac_adj_cols: Sequence[str] | None = None,
    ahr_flag_cols: Sequence[str] | None = None,
    ahr_adj_cols: Sequence[str] | None = None,
    drop_intermediate: bool = False,
) -> pd.DataFrame:
    """Combine base NWAU with HAC/AHR risk adjustments.

    Parameters
    ----------
    df : pd.DataFrame
        Input data containing base NWAU and adjustment columns.
    base_nwau_col : str, default ``"nwau25"``
        Column with the unadjusted NWAU amount.
    weight_col : str, default ``"_w01"``
        Column representing the underlying weight used for HAC adjustment.
    ahr_weight_col : str, optional
        If provided, the weight used for AHR adjustment. Defaults to
        ``weight_col`` when not supplied.
    hac_flag_cols, hac_adj_cols : sequence of str, optional
        Pairs of flag and adjustment columns for HAC categories. Each flag
        should be 1 when the category applies and 0 otherwise.
    ahr_flag_cols, ahr_adj_cols : sequence of str, optional
        Pairs of flag and adjustment columns for AHR categories.
    drop_intermediate : bool, default ``False``
        When ``True`` intermediate adjustment columns are removed from the
        returned dataframe (mimicking the SAS ``DEBUG_MODE`` option).

    Returns
    -------
    pd.DataFrame
        ``df`` with a new ``nwau25_adjusted`` column containing the final NWAU
        value per record.
    """

    result = df.copy()

    # ------------------------------------------------------------------
    # AHR risk adjustment
    # ------------------------------------------------------------------
    if ahr_flag_cols and ahr_adj_cols:
        if len(ahr_flag_cols) != len(ahr_adj_cols):
            raise ValueError("AHR flag and adjustment column counts differ")
        ahr_values = [
            result[adj].fillna(0) * result[flag].fillna(0)
            for flag, adj in zip(ahr_flag_cols, ahr_adj_cols)
        ]
        ahr_adj = pd.concat(ahr_values, axis=1).max(axis=1).fillna(0)
    else:
        ahr_adj = pd.Series(0, index=result.index)

    weight_ahr = result[ahr_weight_col] if ahr_weight_col else result[weight_col]
    result["riskAdjustment_AHR"] = weight_ahr.fillna(0) * ahr_adj

    # ------------------------------------------------------------------
    # HAC risk adjustment
    # ------------------------------------------------------------------
    if hac_flag_cols and hac_adj_cols:
        if len(hac_flag_cols) != len(hac_adj_cols):
            raise ValueError("HAC flag and adjustment column counts differ")
        hac_values = [
            result[adj].fillna(0) * result[flag].fillna(0)
            for flag, adj in zip(hac_flag_cols, hac_adj_cols)
        ]
        hac_adj = pd.concat(hac_values, axis=1).max(axis=1).fillna(0)
    else:
        hac_adj = pd.Series(0, index=result.index)

    result["riskAdjustment_HAC"] = result[weight_col].fillna(0) * hac_adj

    # ------------------------------------------------------------------
    # Final NWAU calculation
    # ------------------------------------------------------------------
    adjusted = (
        result[base_nwau_col].fillna(0)
        - result["riskAdjustment_HAC"]
        - result["riskAdjustment_AHR"]
    ).clip(lower=0)
    result["nwau25_adjusted"] = adjusted

    if drop_intermediate:
        cols_to_drop = list(hac_flag_cols or []) + list(hac_adj_cols or [])
        cols_to_drop += list(ahr_flag_cols or []) + list(ahr_adj_cols or [])
        cols_to_drop += [weight_col]
        if ahr_weight_col:
            cols_to_drop.append(ahr_weight_col)
        cols_to_drop += ["riskAdjustment_HAC", "riskAdjustment_AHR"]
        cols_to_drop = [c for c in cols_to_drop if c in result.columns]
        result = result.drop(columns=cols_to_drop)

    return result
