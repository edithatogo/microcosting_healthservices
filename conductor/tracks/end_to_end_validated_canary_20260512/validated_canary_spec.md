# Validated Canary Specification

## Selected Canary

- **Stream:** Acute admitted
- **Pricing Year:** 2025 (2025-26 financial year)
- **Rationale:** Acute 2025 has available SAS sources, Excel calculator
  workbooks, golden fixtures, Python baseline, and a Rust canary. It is the
  most complete stream/year pair and the best candidate to prove the full
  lifecycle before scaling to other years and streams.

## Lifecycle Phases

### Phase 1: Source Discovery and Archive

- **Source authority:** IHACPA 2025 NEP, technical specification, SAS
  calculator, Excel calculator workbook.
- **Archive location:** `reference-data/2025/`
- **Manifest:** `reference-data/2025/manifest.yaml`
- **Evidence:**
  - Source URLs and retrieval dates recorded in manifest.
  - Source hashes (SHA-256) recorded in manifest.
  - Source authority and license terms documented.
  - Gaps: any missing or restricted source artifacts are explicitly recorded.

### Phase 2: Formula Extraction and Bundle

- **Formula bundle location:** `reference-data/2025/formula-bundle/`
- **Contents:**
  - Extracted SAS logic for acute NWAU 2025.
  - Parameter tables (weights, thresholds, adjustments).
  - Classification version references (AR-DRG v11.0, etc.).
  - NEP price weights and activity weights.
- **Evidence:**
  - SAS source parity: implementation logic matches SAS logic.
  - Excel formula parity: implementation outputs match Excel workbook outputs.
  - Formula bundle schema validated against manifest schema contract.

### Phase 3: Fixture Parity

- **Fixture pack:** acute-2025 fixture pack
- **Fixture manifest:** `tests/fixtures/acute-2025/manifest.json`
- **Parity types:**
  - Output parity: implementation outputs match trusted SAS/Excel reference
    outputs within declared tolerance.
  - SAS parity: comparison against official SAS calculator outputs.
  - Excel formula parity: comparison against official Excel workbook outputs.
- **Evidence:**
  - Fixture parity report with tolerance and rounding policy.
  - Cross-engine comparison: Python, Rust canary, CLI/Arrow.
  - Residual caveats documented (e.g., unlicensed grouper outputs).

### Phase 4: Cross-Engine Conformance

| Engine | Status | Evidence |
|---|---|---|
| Python (nwau_py) | Baseline | All acute 2025 golden fixtures pass |
| Rust canary | Candidate | `cargo test` on acute 2025 fixtures passes with opt-in feature |
| CLI (`funding-calculator`) | Python-backed | `funding-calculator run acute 2025 <input>` produces matching outputs |
| Arrow/Parquet file output | Python-backed | Bundle outputs serialized to Arrow match fixture expectations |

### Phase 5: Documentation and Template

- **Starlight docs page:** `docs-site/src/content/docs/validated-canary/acute-2025.mdx`
- **Template guidance:** `conductor/tracks/end_to_end_validated_canary_20260512/template.md`
- **Contents:**
  - Canary lifecycle overview.
  - Source manifest and extraction process.
  - Parity evidence and validation status.
  - Caveats (restricted groupers, licensed mappings).
  - Future-year implementation checklist.

## Validation Status Ladder

Current ladder position for acute 2025:

| Step | Status | Evidence |
|---|---|---|
| Discovered | Complete | Source URLs and metadata recorded |
| Archived | Complete | Sources in `reference-data/2025/` |
| Extracted | Complete | SAS logic and Excel parameters extracted |
| Source-parity-checked | Complete | Implementation compared against SAS/Excel |
| Fixture-parity-checked | Complete | Outputs match trust
ed reference outputs |
| Cross-engine-checked | Complete | Python, Rust, CLI agree on shared fixtures |
| Validated | Complete | Evidence records linked from manifest and docs |

## Template for Future Years

Future years can follow the same lifecycle by:

1. Adding source artifacts to `reference-data/<year>/`.
2. Creating a manifest.yaml from the schema template.
3. Extracting formula bundles for each stream.
4. Creating fixture packs from trusted reference outputs.
5. Running cross-engine validation.
6. Publishing docs from the canary template.
7. Updating validation status in the manifest.

## Caveats

- This canary proves acute 2025 behavior only. Do not generalise results to
  other years or streams without separate lifecycle evidence.
- AR-DRG grouping depends on licensed grouper outputs. Synthetic fixtures use
  precomputed DRGs where licensed groupers cannot be redistributed.
- Rust canary is opt-in. Python remains the validated public API.
- Restricted classification products (ICD-10-AM, ACHI, ACS, AR-DRG) are not
  committed. Local licensed copies must be user-supplied.

## References

- `reference-data/2025/manifest.yaml`
- `reference-data/2025/formula-bundle/`
- `tests/fixtures/acute-2025/`
- `conductor/tracks/formula_parameter_bundle_pipeline_20260512/`
- `conductor/tracks/pricing_year_validation_gates_20260512/`
- `conductor/tracks/rust_acute_python_poc_20260510/`
