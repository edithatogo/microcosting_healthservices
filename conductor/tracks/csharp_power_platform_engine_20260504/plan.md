# Plan: C# Calculation Engine and Power Platform Adapter

## Phase 1: Engine Architecture

- [ ] Task: Write architecture checks for shared contracts
    - [ ] Verify contracts can map to C# models
    - [ ] Verify golden fixtures do not depend on Python-specific types
- [ ] Task: Document C# engine architecture
    - [ ] Define project layout, service boundary, and model generation path
    - [ ] Define logging and privacy rules
- [ ] Task: Conductor - User Manual Verification 'Engine Architecture' (Protocol in workflow.md)

## Phase 2: Power Platform Boundary

- [ ] Task: Write integration design checks
    - [ ] Verify Power Platform inputs map to public contracts
    - [ ] Verify outputs and errors are structured for app workflows
- [ ] Task: Document Power Platform adapter
    - [ ] Define Custom Connector or Azure Function approach
    - [ ] Define Dataverse responsibilities and non-responsibilities
- [ ] Task: Conductor - User Manual Verification 'Power Platform Boundary' (Protocol in workflow.md)

