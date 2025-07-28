import pathlib
import sys

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from nwau_py.data.loader import load_sas_table
from nwau_py.utils import RA_VERSION, sas_ref_dir

YEARS = sorted(RA_VERSION.keys())

BASE_DIR = pathlib.Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / sas_ref_dir("2025")


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


@pytest.mark.parametrize("year", YEARS)
def test_sas_ref_dir_legacy(year):
    """Ensure legacy directory structures are located for all years."""
    legacy_dir = BASE_DIR / sas_ref_dir(year)
    assert legacy_dir.exists()
