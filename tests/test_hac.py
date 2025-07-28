import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

import pytest

from nwau_py.groupers.hac import flag_hacs
from nwau_py.utils import RA_VERSION

YEARS = sorted(RA_VERSION.keys())


@pytest.mark.parametrize("year", YEARS)
def test_hac_a020_maps_to_c03(year):
    try:
        flags = flag_hacs(["A020"], edition="07", year=year)
    except FileNotFoundError:
        pytest.skip(f"No data for {year}")
    assert flags.get("hac032c03_flag") == 1
    assert flags.get("hac032_flag") == 1


@pytest.mark.parametrize("year", YEARS)
def test_hac_t810_maps_to_c04(year):
    try:
        flags = flag_hacs(["T810"], edition="07", year=year)
    except FileNotFoundError:
        pytest.skip(f"No data for {year}")
    assert flags.get("hac032c04_flag") == 1


@pytest.mark.parametrize("year", YEARS)
def test_hac_multiple_codes(year):
    try:
        flags = flag_hacs(["A020", "T810"], edition="07", year=year)
    except FileNotFoundError:
        pytest.skip(f"No data for {year}")
    assert flags.get("hac032c03_flag") == 1
    assert flags.get("hac032c04_flag") == 1
    assert flags.get("hac032_flag") == 1
