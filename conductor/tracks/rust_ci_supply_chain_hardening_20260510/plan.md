# Plan: Rust CI, Pre-Commit, and Supply-Chain Hardening

## Phase 1: Existing CI and Pre-Commit Audit

- [ ] Task: Write tests for quality-gate alignment
    - [ ] Verify workflow branch triggers include the actual default branch
    - [ ] Verify pre-commit does not contradict the documented type-checking gate
    - [ ] Verify docs-site CI remains wired to Starlight content changes
- [ ] Task: Audit CI and local hooks
    - [ ] Record current Python, docs, and slow-validation gates
    - [ ] Identify branch, tool, and workflow drift
    - [ ] Record required pre-push checks for future implementation work
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Existing CI and Pre-Commit Audit' (Protocol in workflow.md)

## Phase 2: Python Gate Alignment

- [ ] Task: Write tests for Python quality command documentation
    - [ ] Verify workflow, tech-stack, and development docs agree on Ruff, ty, pytest, coverage, and Vale
    - [ ] Verify mypy is described only as transitional if retained
- [ ] Task: Align Python CI and pre-commit
    - [ ] Fix branch trigger drift
    - [ ] Replace stale pre-commit hooks or document them as transitional
    - [ ] Keep local and GitHub Actions commands consistent
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Python Gate Alignment' (Protocol in workflow.md)

## Phase 3: Rust Gate Addition

- [ ] Task: Write tests for Rust workflow expectations
    - [ ] Verify Rust checks are present once `Cargo.toml` exists
    - [ ] Verify Rust gates include formatting, clippy, and tests
- [ ] Task: Add Rust CI and local gate documentation
    - [ ] Add `cargo fmt --check`, `cargo clippy --all-targets --all-features -- -D warnings`, and `cargo test`
    - [ ] Evaluate `cargo nextest` without requiring it before it adds value
    - [ ] Wire Rust checks into pre-push guidance
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Rust Gate Addition' (Protocol in workflow.md)

## Phase 4: Security, Provenance, and Release Automation

- [ ] Task: Write tests for supply-chain governance coverage
    - [ ] Verify Python, Node/docs-site, and Rust ecosystems are covered
    - [ ] Verify release automation is gated on provenance and validation status
- [ ] Task: Add Rust supply-chain and release-hardening guidance
    - [ ] Evaluate `cargo audit`, `cargo deny`, SBOM generation, signing, attestations, and `cargo-dist`
    - [ ] Update Renovate and release policy docs for Rust dependencies
    - [ ] Document GitHub Actions passing requirements before push/merge claims
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Security, Provenance, and Release Automation' (Protocol in workflow.md)
