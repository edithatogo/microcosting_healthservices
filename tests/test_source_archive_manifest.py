from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import nwau_py.provenance as provenance

PAGE_URL = "https://www.ihacpa.gov.au/health-care/pricing/nwau-calculators"


def _artifact(
    *,
    artifact_id: str,
    year_label: str,
    year_start: int,
    artifact_type: str,
    artifact_kind: provenance.ArtifactKind,
    service_stream: str,
    label: str,
    source_host: provenance.SourceHost,
    artifact_url: str,
    final_url: str,
    content_type: str,
    path: str,
    local_path: str,
    bytes_: int,
    checksum: str,
    downloaded_at: str,
    acquisition_status: provenance.AcquisitionStatus,
) -> provenance.SourceArtifact:
    return provenance.SourceArtifact(
        artifact_id=artifact_id,
        year_label=year_label,
        year_start=year_start,
        artifact_type=artifact_type,
        artifact_kind=artifact_kind,
        service_stream=service_stream,
        label=label,
        source_page_url=PAGE_URL,
        artifact_url=artifact_url,
        source_host=source_host,
        final_url=final_url,
        content_type=content_type,
        path=path,
        local_path=local_path,
        checksum_algorithm="sha256",
        checksum=checksum,
        bytes=bytes_,
        downloaded_at=downloaded_at,
        status=acquisition_status.value,
        lifecycle=provenance.LifecycleAxes(
            acquisition_status=acquisition_status,
            extraction_status=provenance.ExtractionStatus.NOT_STARTED,
            implementation_status=provenance.ImplementationStatus.NOT_STARTED,
            validation_status=provenance.ValidationStatus.NOT_STARTED,
        ),
    )


def test_manifest_helpers_record_nested_metadata_and_flatten_csv(tmp_path):
    snapshot_path = tmp_path / "source-page.html"
    snapshot = provenance.write_source_page_snapshot(
        "<html><body>IHACPA source page</body></html>",
        snapshot_path,
    )
    run_context = provenance.RunContext(
        script_name="archive_ihacpa_sources.py",
        script_version="0.2",
        git_commit="deadbeef",
        invocation_args=(
            "--page-url",
            PAGE_URL,
            "--output-dir",
            "archive/ihacpa/raw",
            "--provenance-dir",
            "data/provenance/ihacpa",
        ),
        source_page_url=PAGE_URL,
        source_page_snapshot=snapshot,
        started_at="2026-05-05T00:00:00+00:00",
        completed_at="2026-05-05T00:01:00+00:00",
    )
    manifest = provenance.SourceArchiveManifest(
        schema_version=provenance.MANIFEST_SCHEMA_VERSION,
        generated_at="2026-05-05T00:01:00+00:00",
        run_context=run_context,
        artifacts=(
            _artifact(
                artifact_id="2025-26-excel-nep25-aa-price-weights-acde1234",
                year_label="2025-26",
                year_start=2025,
                artifact_type="excel",
                artifact_kind=provenance.ArtifactKind.EXCEL,
                service_stream="2025 Acute calculator workbook",
                label="2025 Acute calculator workbook",
                source_host=provenance.SourceHost.IHACPA,
                artifact_url=(
                    "https://www.ihacpa.gov.au/files/nep25_aa_price_weights.xlsb"
                ),
                final_url=(
                    "https://www.ihacpa.gov.au/files/nep25_aa_price_weights.xlsb"
                ),
                content_type=("application/vnd.ms-excel.sheet.binary.macroEnabled.12"),
                path="archive/ihacpa/raw/2025/excel/nep25_aa_price_weights.xlsb",
                local_path="archive/ihacpa/raw/2025/excel/nep25_aa_price_weights.xlsb",
                bytes_=12345,
                checksum="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
                downloaded_at="2026-05-05T00:00:00+00:00",
                acquisition_status=provenance.AcquisitionStatus.DOWNLOADED,
            ),
            _artifact(
                artifact_id="2022-23-sas-2022-23-sas-calculator-share-page-acde1234",
                year_label="2022-23",
                year_start=2022,
                artifact_type="sas",
                artifact_kind=provenance.ArtifactKind.SAS,
                service_stream="SAS-based calculators",
                label="2022-23 SAS calculator share page",
                source_host=provenance.SourceHost.BOX,
                artifact_url="https://www.box.com/s/example-share",
                final_url="https://public.box.com/s/example-share",
                content_type="text/html; charset=utf-8",
                path="archive/ihacpa/raw/2022/sas/2022-23-share.html",
                local_path="archive/ihacpa/raw/2022/sas/2022-23-share.html",
                bytes_=0,
                checksum="fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210",
                downloaded_at="",
                acquisition_status=provenance.AcquisitionStatus.EXTERNAL_HTML_ONLY,
            ),
        ),
    )

    manifest_dict = manifest.to_dict()

    assert manifest_dict["schema_version"] == provenance.MANIFEST_SCHEMA_VERSION
    assert manifest_dict["run_context"]["git_commit"] == "deadbeef"
    assert manifest_dict["run_context"]["source_page_snapshot"]["path"] == str(
        snapshot_path
    )
    assert manifest_dict["run_context"]["source_page_snapshot"]["byte_count"] > 0
    assert manifest_dict["artifacts"][0]["checksum_algorithm"] == "sha256"
    assert manifest_dict["artifacts"][0]["bytes"] == 12345
    assert manifest_dict["artifacts"][0]["lifecycle"]["acquisition"] == "downloaded"
    assert manifest_dict["artifacts"][1]["source_host"] == "box"
    assert manifest_dict["artifacts"][1]["lifecycle"]["acquisition"] == (
        "external-html-only"
    )

    json_path = tmp_path / "manifest.json"
    csv_path = tmp_path / "manifest.csv"
    provenance.write_manifest_json(manifest, json_path)
    provenance.write_manifest_csv(manifest, csv_path)

    json_payload = json.loads(json_path.read_text(encoding="utf-8"))
    assert json_payload == manifest_dict

    rows = list(csv.DictReader(csv_path.read_text(encoding="utf-8").splitlines()))
    assert rows[0]["schema_version"] == provenance.MANIFEST_SCHEMA_VERSION
    assert rows[0]["acquisition_status"] == "downloaded"
    assert rows[1]["acquisition_status"] == "external-html-only"
    assert rows[1]["checksum_algorithm"] == "sha256"


def test_manifest_helpers_normalize_status_and_paths():
    paths = provenance.tracked_manifest_paths()
    assert paths.manifest_dir == Path("data/provenance/ihacpa")
    assert paths.json_path == Path("data/provenance/ihacpa/sources.json")
    assert paths.csv_path == Path("data/provenance/ihacpa/sources.csv")
    assert paths.source_page_snapshot_path == Path(
        "data/provenance/ihacpa/snapshots/source-page.html"
    )
    assert paths.manifest_dir != provenance.DEFAULT_RAW_ARCHIVE_DIR

    assert (
        provenance.normalize_acquisition_status(
            "https://www.ihacpa.gov.au/files/example.xlsb",
            final_url="https://www.ihacpa.gov.au/files/example.xlsb",
            content_type="application/vnd.ms-excel.sheet.binary.macroEnabled.12",
            downloaded=True,
        )
        == provenance.AcquisitionStatus.DOWNLOADED
    )
    assert (
        provenance.normalize_acquisition_status(
            "https://www.box.com/s/example-share",
            final_url="https://public.box.com/s/example-share",
            content_type="text/html; charset=utf-8",
            downloaded=True,
        )
        == provenance.AcquisitionStatus.EXTERNAL_HTML_ONLY
    )
