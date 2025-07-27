import pandas as pd
import sys
import pathlib

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from nwau_py.calculators.adjust import calculate_adjusted_nwau


def test_adjustment_basic_drop():
    df = pd.DataFrame({
        "nwau25": [10.0],
        "_w01": [10.0],
        "w01_ahr": [10.0],
        "hac_adj01": [0.1],
        "hac_flag01": [1],
        "ahr_adj01": [0.2],
        "ahr_flag01": [1],
    })

    result = calculate_adjusted_nwau(
        df,
        hac_flag_cols=["hac_flag01"],
        hac_adj_cols=["hac_adj01"],
        ahr_flag_cols=["ahr_flag01"],
        ahr_adj_cols=["ahr_adj01"],
        ahr_weight_col="w01_ahr",
        drop_intermediate=True,
    )

    assert "hac_flag01" not in result.columns
    assert "ahr_adj01" not in result.columns
    assert result["nwau25_adjusted"].iloc[0] == 7.0
