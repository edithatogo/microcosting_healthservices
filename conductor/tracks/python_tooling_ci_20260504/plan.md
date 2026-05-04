# Plan: Python Tooling and CI Modernization

## Phase 1: uv and Python Matrix

- [ ] Task: Write tests or checks for dependency resolution
    - [ ] Verify runtime, dev, docs, test, profiling, and mutation groups resolve
    - [ ] Verify Python 3.10-3.14 markers are represented
- [ ] Task: Configure uv and CI matrix
    - [ ] Add dependency groups
    - [ ] Add Python 3.10, 3.11, 3.12, 3.13, and 3.14 GitHub Actions jobs
- [ ] Task: Conductor - User Manual Verification 'uv and Python Matrix' (Protocol in workflow.md)

## Phase 2: Quality Gates

- [ ] Task: Write CI checks for quality tools
    - [ ] Verify ruff, ty, pytest, and coverage commands run locally
    - [ ] Verify Codecov upload is configured
- [ ] Task: Add quality tooling
    - [ ] Configure Codecov
    - [ ] Configure ty
    - [ ] Remove mypy as the documented forward path
- [ ] Task: Conductor - User Manual Verification 'Quality Gates' (Protocol in workflow.md)

## Phase 3: Advanced Validation Jobs

- [ ] Task: Add focused tests for Hypothesis strategies and mutmut configuration
    - [ ] Cover calculator invariants and boundary conditions
    - [ ] Define mutation target modules
- [ ] Task: Add scheduled or manual jobs for Hypothesis, mutmut, and Scalene
    - [ ] Keep normal PR feedback fast
    - [ ] Store profiling output outside source files
- [ ] Task: Conductor - User Manual Verification 'Advanced Validation Jobs' (Protocol in workflow.md)

## Phase 4: Maintenance Automation and Prose Quality

- [ ] Task: Validate Renovate and Vale configuration
    - [ ] Ensure calculator-impacting dependencies are not automerged unsafely
    - [ ] Ensure Vale flags unsupported validation claims
- [ ] Task: Add Renovate and Vale
    - [ ] Configure Renovate package rules
    - [ ] Configure Vale terminology and validation language rules
- [ ] Task: Conductor - User Manual Verification 'Maintenance Automation and Prose Quality' (Protocol in workflow.md)

