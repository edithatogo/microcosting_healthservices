# Plan: Ecosystem Standards and Language Readiness

## Phase 1: Repository Surface and Standards Audit

- [ ] Task: Write tests for the ecosystem readiness documentation contract
    - [ ] Verify the standards matrix file exists
    - [ ] Verify the matrix covers Python, R, Julia, C#, Power Platform, docs-site, and health interoperability
    - [ ] Verify the track registry includes the new roadmap
- [ ] Task: Document current repository language and packaging surfaces
    - [ ] Record implemented Python and docs-site package surfaces
    - [ ] Record missing R, Julia, C#, and Power Platform artifacts
    - [ ] Distinguish architecture documentation from executable implementations
- [ ] Task: Document ecosystem standards and source references
    - [ ] Record Python pyOpenSci and PyPA readiness expectations
    - [ ] Record R rOpenSci, CRAN-style, and statistical software expectations
    - [ ] Record Julia package, docs, registry, and CI expectations
    - [ ] Record .NET, NuGet, Source Link, and Power Platform ALM expectations
- [ ] Task: Conductor - Automated Review and Checkpoint 'Repository Surface and Standards Audit' (Protocol in workflow.md)

## Phase 2: Language and Platform Decision Matrix

- [ ] Task: Write tests for the decision matrix
    - [ ] Verify every surface has a recommended action
    - [ ] Verify non-Python surfaces require shared contract and golden fixture parity
    - [ ] Verify unsupported or deferred surfaces are not described as implemented
- [ ] Task: Create the language and platform decision matrix
    - [ ] Classify Python as the current authoritative implementation surface
    - [ ] Decide whether R should be a wrapper, full port, or deferred
    - [ ] Decide whether Julia should be a wrapper, kernel prototype, full port, or deferred
    - [ ] Decide what C# must implement before Power Platform can claim calculation logic
    - [ ] Tighten docs-site package maturity recommendations
- [ ] Task: Add prioritized implementation recommendations
    - [ ] Define near-term packaging and publication improvements
    - [ ] Define medium-term C# and Power Platform implementation gates
    - [ ] Define deferred R, Julia, and additional platform criteria
- [ ] Task: Conductor - Automated Review and Checkpoint 'Language and Platform Decision Matrix' (Protocol in workflow.md)

## Phase 3: Health Standards and Community Contribution Roadmap

- [ ] Task: Write tests for health standards and community contribution guidance
    - [ ] Verify near-term health standards include ICD-10-AM, ACHI, ACS, AR-DRG, HL7 v2, FHIR R4, and IHE patient administration profiles
    - [ ] Verify ICD-11, FHIR R5, openEHR, CDA, and document sharing are classified as watch-list or conditional scope
    - [ ] Verify contribution targets include scientific software and health funding communities
- [ ] Task: Document health-funding and PAS interoperability considerations
    - [ ] Prioritize Australian coding and funding classification standards
    - [ ] Document PAS integration standards and API baselines
    - [ ] Separate near-term integration targets from watch-list standards
- [ ] Task: Document contribution and publication pathways
    - [ ] Identify pyOpenSci, rOpenSci, Julia community, JOSS, health economics, health informatics, and govtech contribution paths
    - [ ] Define prerequisites before submitting to each community
    - [ ] Record governance and validation risks for external contribution
- [ ] Task: Conductor - Automated Review and Checkpoint 'Health Standards and Community Contribution Roadmap' (Protocol in workflow.md)

