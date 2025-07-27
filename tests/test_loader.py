import sys
import pathlib

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from nwau_py.data.loader import load_sas_table

DATA_DIR = pathlib.Path(__file__).resolve().parents[1] / "archive/sas/NEP25_SAS_NWAU_calculator/calculators"


def test_load_sas_table_no_cache():
    path = DATA_DIR / "tablec.sas7bdat"
    df = load_sas_table(path, cache=False)
    assert not df.empty


def test_load_sas_table_csv_cache(tmp_path):
    path = DATA_DIR / "nep25_edaecc_price_weights.sas7bdat"
    df = load_sas_table(path, cache=True, cache_format="csv", cache_dir=tmp_path)
    cache_file = tmp_path / "nep25_edaecc_price_weights.csv"
    assert cache_file.exists()
    df_cached = load_sas_table(path, cache=True, cache_format="csv", cache_dir=tmp_path)
    assert df_cached.equals(df)


def test_load_multiple_tables(tmp_path):
    path = DATA_DIR / "ahr_map_10.sas7bdat"
    df = load_sas_table(path, cache=True, cache_format="csv", cache_dir=tmp_path)
    cache_file = tmp_path / "ahr_map_10.csv"
    assert cache_file.exists()
    assert len(df) > 0
