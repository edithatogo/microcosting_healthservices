from __future__ import annotations

import importlib.util
import io
import json
import sys
from pathlib import Path

import pytest


SCRIPT_PATH = (
    Path(__file__).resolve().parents[1] / "scripts" / "archive_ihacpa_sources.py"
)
SPEC = importlib.util.spec_from_file_location("archive_ihacpa_sources", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
archive = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = archive
SPEC.loader.exec_module(archive)


class FakeResponse:
    def __init__(self, final_url: str, body: bytes, content_type: str) -> None:
        self._final_url = final_url
        self._body = io.BytesIO(body)
        self.headers = {"content-type": content_type}

    def __enter__(self) -> "FakeResponse":
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        return False

    def geturl(self) -> str:
        return self._final_url

    def read(self, size: int = -1) -> bytes:
        return self._body.read(size)

    def close(self) -> None:
        return None


def _metadata(
    final_url: str,
    content_type: str,
    *,
    requested_url: str = "https://www.ihacpa.gov.au/fake",
) -> object:
    return archive.FetchMetadata(
        requested_url=requested_url,
        final_url=final_url,
        status_code=200,
        content_type=content_type,
        headers={"content-type": content_type},
        redirect_chain=[],
        fetched_at="2026-05-05T00:00:00+00:00",
    )


def _artifact(
    label: str,
    url: str,
    *,
    artifact_type: str = "excel",
    year_label: str = "2025-26",
    year_start: int = 2025,
) -> object:
    artifact_kind = archive.ArtifactKind(artifact_type)
    return archive.SourceArtifact(
        artifact_id=archive.stable_artifact_id(
            year_label,
            label,
            url,
            artifact_kind=artifact_kind,
        ),
        year_label=year_label,
        year_start=year_start,
        artifact_type=artifact_kind.value,
        artifact_kind=artifact_kind,
        service_stream=(
            "SAS-based calculators" if artifact_kind is archive.ArtifactKind.SAS else label
        ),
        label=label,
        source_page_url=archive.PAGE_URL,
        artifact_url=url,
        source_host=(
            archive.SourceHost.BOX if "box.com" in url else archive.SourceHost.IHACPA
        ),
    )


def test_list_only_writes_provenance_manifest_outside_raw_storage(
    tmp_path, monkeypatch
):
    artifacts = [
        _artifact(
            "2025-26 acute weights workbook",
            "https://www.ihacpa.gov.au/files/nep25_aa_price_weights.xlsb",
        )
    ]
    snapshot = archive.SourcePageSnapshot(
        path="snapshot.html",
        sha256="snapshot",
        byte_count=1,
        captured_at="2026-05-05T00:00:00+00:00",
    )
    monkeypatch.setattr(
        archive,
        "parse_artifacts",
        lambda *_args, **_kwargs: (artifacts, snapshot, {"path": "snapshot.html"}),
    )

    def _fail_download(*_args, **_kwargs):
        pytest.fail("download_artifact should not run in list-only mode")

    monkeypatch.setattr(archive, "download_artifact", _fail_download)

    raw_dir = tmp_path / "archive" / "ihacpa" / "raw"
    provenance_dir = tmp_path / "data" / "provenance" / "ihacpa"
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "archive_ihacpa_sources.py",
            "--list-only",
            "--output-dir",
            str(raw_dir),
            "--provenance-dir",
            str(provenance_dir),
        ],
    )

    archive.main()

    assert not any(raw_dir.glob("2025/*/*"))
    manifest_json = provenance_dir / "sources.json"
    manifest_csv = provenance_dir / "sources.csv"
    assert manifest_json.exists()
    assert manifest_csv.exists()

    manifest = json.loads(manifest_json.read_text())
    assert manifest["schema_version"] == "1"
    assert manifest["artifacts"][0]["status"] == "listed"
    assert manifest["artifacts"][0]["lifecycle"]["acquisition"] == "listed"
    assert manifest["artifacts"][0]["lifecycle"]["implementation"] == "not-started"


def test_download_writes_raw_artifact_and_tracked_provenance_manifest(
    tmp_path, monkeypatch
):
    artifact = _artifact(
        "2025-26 acute weights workbook",
        "https://www.ihacpa.gov.au/files/nep25_aa_price_weights.xlsb",
    )
    snapshot = archive.SourcePageSnapshot(
        path="snapshot.html",
        sha256="snapshot",
        byte_count=1,
        captured_at="2026-05-05T00:00:00+00:00",
    )
    monkeypatch.setattr(
        archive,
        "parse_artifacts",
        lambda *_args, **_kwargs: ([artifact], snapshot, {"path": "snapshot.html"}),
    )
    monkeypatch.setattr(
        archive,
        "fetch",
        lambda *_args, **_kwargs: (
            FakeResponse(
                "https://www.ihacpa.gov.au/files/nep25_aa_price_weights.xlsb",
                b"binary-xlsb-bytes",
                "application/vnd.ms-excel.sheet.binary.macroEnabled.12",
            ),
            _metadata(
                "https://www.ihacpa.gov.au/files/nep25_aa_price_weights.xlsb",
                "application/vnd.ms-excel.sheet.binary.macroEnabled.12",
            ),
        ),
    )

    raw_dir = tmp_path / "archive" / "ihacpa" / "raw"
    provenance_dir = tmp_path / "data" / "provenance" / "ihacpa"
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "archive_ihacpa_sources.py",
            "--output-dir",
            str(raw_dir),
            "--provenance-dir",
            str(provenance_dir),
        ],
    )

    archive.main()

    raw_file = raw_dir / "2025" / "excel" / "nep25_aa_price_weights.xlsb"
    assert raw_file.exists()
    assert raw_file.read_bytes() == b"binary-xlsb-bytes"

    manifest_json = provenance_dir / "sources.json"
    assert manifest_json.exists()

    manifest = json.loads(manifest_json.read_text())
    assert manifest["schema_version"] == "1"
    assert manifest["artifacts"][0]["status"] == "downloaded"
    assert manifest["artifacts"][0]["path"] == str(raw_file)


def test_box_hosted_html_share_is_recorded_without_direct_download(tmp_path, monkeypatch):
    artifact = _artifact(
        "2021-22 SAS calculator share page",
        "https://www.box.com/s/example-share",
        artifact_type="sas",
    )

    monkeypatch.setattr(
        archive,
        "fetch",
        lambda *_args, **_kwargs: (
            FakeResponse(
                "https://public.box.com/s/example-share",
                b"<html><body>Box share page</body></html>",
                "text/html; charset=utf-8",
            ),
            _metadata(
                "https://public.box.com/s/example-share",
                "text/html; charset=utf-8",
                requested_url="https://www.box.com/s/example-share",
            ),
        ),
    )

    archive.download_artifact(artifact, tmp_path, timeout=5)

    assert artifact.status == "external-html-only"
    assert artifact.path.endswith(".html")
    assert artifact.downloaded_at == ""
    assert artifact.bytes == 0
