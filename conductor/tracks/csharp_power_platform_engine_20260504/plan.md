# Plan: C# Calculation Engine and Power Platform Adapter

## Phase 1: Engine Architecture

- [ ] Task: Write architecture checks for shared contracts
    - [ ] Verify contracts can map to C# models
    - [ ] Verify golden fixtures do not depend on Python-specific types
    - [ ] Verify the C# engine can consume the same public contract metadata as the web demo
- [ ] Task: Document C# engine architecture
    - [ ] Define project layout, secure service boundary, and model generation path
    - [ ] Define logging and privacy rules
    - [ ] Define how fixture packs are loaded for parity and regression testing
- [ ] Task: Conductor - User Manual Verification 'Engine Architecture' (Protocol in workflow.md)

## Phase 2: Power Platform Boundary

- [ ] Task: Write integration design checks
    - [ ] Verify Power Platform inputs map to public contracts
    - [ ] Verify outputs and errors are structured for app workflows
    - [ ] Verify Power Platform remains orchestration-only while the C# service performs calculation
- [ ] Task: Document Power Platform adapter
    - [ ] Define Custom Connector or Azure Function approach
    - [ ] Define Dataverse responsibilities and non-responsibilities
    - [ ] Define how the adapter consumes contract and fixture identifiers
- [ ] Task: Conductor - User Manual Verification 'Power Platform Boundary' (Protocol in workflow.md)

## Phase 3: Contract and Fixture Alignment

- [ ] Task: Write parity checks against shared fixtures
    - [ ] Verify C# payloads round-trip against the public contract
    - [ ] Verify fixture outputs match the declared tolerance and parity type
- [ ] Task: Document release and rollout rules
    - [ ] Define how contract updates, fixture updates, and engine updates stay synchronized
    - [ ] Define the gate for enabling real-data workflows through the service boundary
- [ ] Task: Conductor - User Manual Verification 'Contract and Fixture Alignment' (Protocol in workflow.md)
