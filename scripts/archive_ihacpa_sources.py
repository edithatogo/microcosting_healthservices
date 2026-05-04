"""Archive IHACPA NWAU calculator source artifacts.

The script reads the public IHACPA NWAU calculators page, downloads listed
calculator artifacts, and writes JSON/CSV manifests with provenance metadata.
Raw binaries are intentionally written under ``archive/ihacpa/raw/``, which is
ignored by Git until the project chooses Git LFS, release assets, or external
object storage.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import time
from dataclasses import asdict, dataclass
from datetime import UTC, datetime
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse
from urllib.request import Request, urlopen

PAGE_URL = "https://www.ihacpa.gov.au/health-care/pricing/nwau-calculators"
USER_AGENT = (
    "Mozilla/5.0 microcosting-healthservices-source-archiver/0.1 "
    "(+https://github.com/edithatogo/microcosting_healthservices)"
)


@dataclass
class SourceArtifact:
    year_label: str
    year_start: int
    artifact_type: str
    service_stream: str
    label: str
    source_page_url: str
    artifact_url: str
    final_url: str = ""
    content_type: str = ""
    status: str = "listed"
    path: str = ""
    bytes: int = 0
    sha256: str = ""
    downloaded_at: str = ""
    error: str = ""


class NwauCalculatorPageParser(HTMLParser):
    """Extract calculator artifact links grouped by year heading."""

    def __init__(self, page_url: str) -> None:
        super().__init__()
        self.page_url = page_url
        self.items: list[SourceArtifact] = []
        self.current_year_label = ""
        self.current_year_start = 0
        self._in_h2 = False
        self._h2_text = ""
        self._anchor: list[str] | None = None

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attr_map = dict(attrs)
        if tag == "h2":
            self._in_h2 = True
            self._h2_text = ""
        if tag == "a" and attr_map.get("href"):
            self._anchor = [urljoin(self.page_url, attr_map["href"] or ""), ""]

    def handle_data(self, data: str) -> None:
        if self._in_h2:
            self._h2_text += data
        if self._anchor is not None:
            self._anchor[1] += data

    def handle_endtag(self, tag: str) -> None:
        if tag == "h2":
            text = " ".join(self._h2_text.split())
            match = re.search(r"(20\d{2})[-–](\d{2})", text)
            if match:
                self.current_year_start = int(match.group(1))
                self.current_year_label = f"{match.group(1)}-{match.group(2)}"
            self._in_h2 = False

        if tag == "a" and self._anchor is not None:
            href, text = self._anchor
            self._anchor = None
            self._append_artifact(href, " ".join(text.split()))

    def _append_artifact(self, href: str, label: str) -> None:
        lower = href.lower()
        downloadable = lower.endswith((".xls", ".xlsm", ".xlsb", ".zip", ".7z"))
        box_share = "box.com/s/" in lower
        if not self.current_year_label or not (downloadable or box_share):
            return

        artifact_type = (
            "sas"
            if "sas" in label.lower()
            or lower.endswith((".zip", ".7z"))
            or box_share
            else "excel"
        )
        self.items.append(
            SourceArtifact(
                year_label=self.current_year_label,
                year_start=self.current_year_start,
                artifact_type=artifact_type,
                service_stream=(
                    "SAS-based calculators" if artifact_type == "sas" else label
                ),
                label=label,
                source_page_url=self.page_url,
                artifact_url=href,
            )
        )


def fetch(url: str, timeout: int) -> object:
    """Open ``url`` with retry support."""

    last_error: Exception | None = None
    for attempt in range(1, 4):
        try:
            request = Request(url, headers={"User-Agent": USER_AGENT})
            return urlopen(request, timeout=timeout)
        except Exception as exc:  # pragma: no cover - network variability
            last_error = exc
            time.sleep(attempt)
    if last_error is None:  # pragma: no cover
        raise RuntimeError("request failed without an exception")
    raise last_error


def safe_filename(item: SourceArtifact, final_url: str, content_type: str) -> str:
    name = Path(unquote(urlparse(final_url).path)).name
    if not name or "." not in name:
        suffix = ".html" if "html" in content_type else ".download"
        stem = re.sub(r"[^a-z0-9]+", "_", item.label.lower()).strip("_")
        name = f"{stem or item.artifact_type}{suffix}"
    return re.sub(r"[^A-Za-z0-9._%()+ -]+", "_", name)


def checksum(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def download_artifact(item: SourceArtifact, root: Path, timeout: int) -> None:
    target_dir = root / str(item.year_start) / item.artifact_type
    target_dir.mkdir(parents=True, exist_ok=True)

    with fetch(item.artifact_url, timeout) as response:
        final_url = response.geturl()
        content_type = response.headers.get("content-type", "")
        path = target_dir / safe_filename(item, final_url, content_type)

        item.final_url = final_url
        item.content_type = content_type
        item.path = str(path)

        if path.exists() and path.stat().st_size > 0:
            item.status = "downloaded"
            item.bytes = path.stat().st_size
            item.sha256 = checksum(path)
            return

        tmp_path = path.with_suffix(path.suffix + ".part")
        with tmp_path.open("wb") as file:
            while True:
                chunk = response.read(1024 * 1024)
                if not chunk:
                    break
                file.write(chunk)
        tmp_path.replace(path)

        item.status = "downloaded"
        item.bytes = path.stat().st_size
        item.sha256 = checksum(path)
        item.downloaded_at = datetime.now(UTC).isoformat()

        if "text/html" in content_type and "box.com" in item.artifact_url:
            item.status = "external-html-only"


def parse_artifacts(page_url: str, timeout: int) -> list[SourceArtifact]:
    with fetch(page_url, timeout) as response:
        html = response.read().decode("utf-8", errors="replace")
    parser = NwauCalculatorPageParser(page_url)
    parser.feed(html)
    return parser.items


def write_manifests(items: list[SourceArtifact], root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)
    manifest_json = root / "manifest.json"
    manifest_csv = root / "manifest.csv"

    rows = [asdict(item) for item in items]
    manifest_json.write_text(json.dumps(rows, indent=2) + "\n")

    if rows:
        with manifest_csv.open("w", newline="") as file:
            writer = csv.DictWriter(file, fieldnames=list(rows[0].keys()))
            writer.writeheader()
            writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--page-url", default=PAGE_URL)
    parser.add_argument("--output-dir", default="archive/ihacpa/raw")
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--list-only", action="store_true")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    items = parse_artifacts(args.page_url, args.timeout)

    if not args.list_only:
        for item in items:
            try:
                download_artifact(item, output_dir, args.timeout)
            except Exception as exc:  # pragma: no cover - network variability
                item.status = "failed"
                item.error = f"{type(exc).__name__}: {exc}"

    write_manifests(items, output_dir)

    counts: dict[str, int] = {}
    for item in items:
        counts[item.status] = counts.get(item.status, 0) + 1
    print(json.dumps({"items": len(items), "statuses": counts}, sort_keys=True))


if __name__ == "__main__":
    main()
