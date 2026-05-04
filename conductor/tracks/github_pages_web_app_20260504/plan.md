# Plan: GitHub Pages Web App Prototype

## Phase 1: Demo Architecture and Boundary

- [ ] Task: Write checks for static deployment assumptions
    - [ ] Verify build output can be served from GitHub Pages
    - [ ] Verify demo mode depends only on synthetic fixtures and public contract metadata
    - [ ] Verify no server-only calculation dependency is required for demo mode
- [ ] Task: Document web architecture
    - [ ] Define contract-driven UI capabilities
    - [ ] Define privacy-safe demo data workflow
    - [ ] Define the secure service boundary for any future real-data workflow outside GitHub Pages
- [ ] Task: Conductor - User Manual Verification 'Demo Architecture and Boundary' (Protocol in workflow.md)

## Phase 2: Prototype Shell

- [ ] Task: Write UI smoke tests
    - [ ] Verify calculator/year selection from metadata
    - [ ] Verify synthetic fixture execution or display
    - [ ] Verify real-data entry points are absent from the Pages demo
- [ ] Task: Build prototype shell
    - [ ] Add GitHub Pages build/deploy path
    - [ ] Add fixture-backed demonstration workflow
    - [ ] Consume public contract metadata for supported calculators and fields
- [ ] Task: Conductor - User Manual Verification 'Prototype Shell' (Protocol in workflow.md)

## Phase 3: Secure Real-Data Boundary

- [ ] Task: Write boundary checks for real-data workflows
    - [ ] Verify real-data requests are routed to a secured service boundary
    - [ ] Verify the Pages demo does not expose upload or persistence paths for patient data
- [ ] Task: Document real-data service boundary
    - [ ] Define how the secure service boundary validates contracts and fixture parity
    - [ ] Define how the boundary integrates with the public API contract and golden fixtures
- [ ] Task: Conductor - User Manual Verification 'Secure Real-Data Boundary' (Protocol in workflow.md)
