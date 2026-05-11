import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from nwau_py.utils import ra_suffix


def test_ra_suffix():
    assert ra_suffix("2025") == "ra2021"
    assert ra_suffix("2024") == "ra2021"
    assert ra_suffix("2023") == "ra2016"
    assert ra_suffix("2019") == "ra2011"
