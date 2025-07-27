import sys
import pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from nwau_py.groupers.hac import flag_hacs


def test_hac_a020_maps_to_c03():
    flags = flag_hacs(["A020"], edition="07")
    assert flags.get("hac032c03_flag") == 1
    assert flags.get("hac032_flag") == 1


def test_hac_t810_maps_to_c04():
    flags = flag_hacs(["T810"], edition="07")
    assert flags.get("hac032c04_flag") == 1


def test_hac_multiple_codes():
    flags = flag_hacs(["A020", "T810"], edition="07")
    assert flags.get("hac032c03_flag") == 1
    assert flags.get("hac032c04_flag") == 1
    assert flags.get("hac032_flag") == 1
