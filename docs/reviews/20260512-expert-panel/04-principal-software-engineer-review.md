# Simulated Principal Software Engineer Review

## Role

Senior implementation reviewer focused on execution order, maintainability,
CI/CD, packaging, and practical delivery.

## Findings

1. The immediate technical choke point is contract shape.
   Until Arrow schemas, error models, provenance models, and validation records
   are stable, every binding will churn.

2. Rust core should not replace Python all at once.
   The current canary approach is right. Promote stream by stream.

3. CI is strong for current Python/Rust surfaces but not yet for future
   languages.
   Add conformance-test scaffolding before adding language-specific release
   automation.

4. Release state must be queryable.
   A human should be able to run one command or read one generated page showing
   PyPI, conda-forge, GitHub Release, Pages, docs, and future registry status.

5. Track sprawl is now a real maintenance burden.
   The roadmap governance backfill should happen before the next large feature
   implementation.

## Implementation Recommendations

- Build `nwau validate-year`.
- Build `nwau diff-year`.
- Build `nwau sources scan` in dry-run mode.
- Add schema validation tests.
- Add restricted-artifact denylist tests.
- Add one conformance fixture runner that bindings can reuse.

## Priority Recommendation

Implement shared tooling and conformance tests first. Then promote one Rust
calculator stream through Python, CLI, and docs before adding extra bindings.
