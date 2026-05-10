# Current Calculator Boundary Audit

## Scope

Audit the current calculator boundary against the Rust-core target architecture:
formulae, parameters, schemas, reference loading, provenance, and adapter
responsibilities.

## Current Boundary Map

- Formula logic currently lives in the Python calculator modules under
  `nwau_py/calculators/`.
- Shared adjustments and grouping logic still depend on pandas dataframes and series.
- The concrete pandas-coupled modules include
  `nwau_py/calculators/adjust.py`, `nwau_py/groupers/`, and `nwau_py/utils.py`.
- Acute contract validation is already explicit in
  `nwau_py/calculators/acute.py` via `AcuteParams`, `AcuteInputContract`,
  `AcuteReferenceBundle`, and `AcuteCalculationContract`.
- Reference-data resolution is separated from calculation logic in
  `nwau_py/reference_data.py`.
- Data-bundle reading is separated from calculator math in
  `nwau_py/bundles.py`.
- The CLI and cache/loading helpers remain adapters around pandas-backed
  execution paths in `nwau_py/cli/main.py` and `nwau_py/data/loader.py`.

## Remaining Pandas-Coupled Paths

- `nwau_py/calculators/acute.py`
- `nwau_py/calculators/adjust.py`
- `nwau_py/calculators/ed.py`
- `nwau_py/calculators/mh.py`
- `nwau_py/calculators/outpatients.py`
- `nwau_py/calculators/subacute.py`
- `nwau_py/calculators/funding_formula.py`
- `nwau_py/data/loader.py`
- `nwau_py/groupers/ahr.py`
- `nwau_py/groupers/hac.py`
- `nwau_py/fixtures.py`
- `nwau_py/utils.py`

These modules are the main Python execution surface that a Rust core would
eventually replace or wrap.

## Existing Contract Scaffolding Already in Place

- `nwau_py/bundles.py` defines a dataframe-neutral manifest contract and reads
  Arrow/Parquet payloads.
- `nwau_py/fixtures.py` defines runner-neutral fixture packs with explicit
  schema versioning, payload formats, provenance, and cross-language readiness
  flags.
- `nwau_py/reference_data.py` validates bundle selection and manifest identity
  without binding the result to a specific dataframe engine.
- `docs/adr/0002-arrow-polars-data-bundle.md` and
  `conductor/tech-stack.md` already establish Arrow/Parquet as the target
  interchange layer for reference data and future kernels.
- Shared golden fixture packs already provide the parity harness needed for a
  calculator-by-calculator migration.

## Audit Conclusion

The repository already has the right contract scaffolding for a Rust-first future core,
but the active calculator engine is still pandas-centered. The next migration step is
to preserve the existing manifest and fixture contracts while moving formula execution
out of the Python modules listed above.
