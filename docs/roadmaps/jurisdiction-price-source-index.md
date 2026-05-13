# Jurisdiction Price Source Index Plan

> Parallel-agent notice: this is a source-index plan, not extracted price data.
> Do not hard-code public or local prices without provenance, licence status,
> checksum, and support status.

## Required source fields

- `jurisdiction`
- `financial_year`
- `source_title`
- `source_url_or_path`
- `retrieved_on`
- `checksum`
- `licence_status`
- `redistribution_status`
- `source_unit`
- `mapped_unit`
- `price_term`
- `stream_applicability`
- `adjustment_notes`
- `support_status`
- `extraction_notes`

## Jurisdictions

- NSW
- VIC
- QLD
- WA
- SA
- TAS
- ACT
- NT

## Initial source classes

- NEP and national pricing determinations.
- State price or efficient price documents.
- LHD, LHN, HHS, hospital network, or territory service agreements.
- Activity schedules using NWAU, WAU, QWAU, WIES, or local terms.
- Block funding and supplementary funding schedules.
- Local discount, local price, cap/floor, or override documents.

## Extraction rule

Extract only values with source provenance and licence status. If a source is
not public or redistribution is uncertain, record metadata and mark values
`blocked` or `local_only` rather than committing restricted data.
