import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from scripts.archive_ihacpa_sources import NwauCalculatorPageParser

FIXTURE_DIR = Path(__file__).resolve().parent / "fixtures" / "ihacpa" / "page"
PAGE_URL = "https://www.ihacpa.gov.au/health-care/pricing/nwau-calculators"


def parse_fixture(name: str):
    parser = NwauCalculatorPageParser(PAGE_URL)
    parser.feed((FIXTURE_DIR / name).read_text(encoding="utf-8"))
    return parser.items


def test_parser_groups_years_and_classifies_excel_sas_and_box_share_links():
    items = parse_fixture("nwau_calculators_listing.html")

    assert [
        (
            item.year_label,
            item.year_start,
            item.artifact_type,
            item.service_stream,
            item.label,
            item.artifact_url,
        )
        for item in items
    ] == [
        (
            "2025-26",
            2025,
            "excel",
            "2025 Acute calculator workbook",
            "2025 Acute calculator workbook",
            "https://www.ihacpa.gov.au/files/nwau25_calculator_for_acute_activity.xlsb",
        ),
        (
            "2025-26",
            2025,
            "sas",
            "SAS-based calculators",
            "2025 SAS calculator package",
            "https://www.ihacpa.gov.au/files/NEP25_SAS_NWAU_calculator.zip",
        ),
        (
            "2025-26",
            2025,
            "excel",
            "2025 Acute calculator workbook on Box",
            "2025 Acute calculator workbook on Box",
            "https://www.box.com/s/abc123",
        ),
        (
            "2024-25",
            2024,
            "excel",
            "2024 Acute calculator workbook",
            "2024 Acute calculator workbook",
            "https://www.ihacpa.gov.au/files/nwau24_calculator_for_acute_activity.xlsb",
        ),
    ]
