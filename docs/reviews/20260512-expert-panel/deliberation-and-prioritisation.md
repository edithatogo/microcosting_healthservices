# Simulated Deliberative Prioritisation

## Chair

Meeting chaired by a simulated CEO of IHACPA. This is a planning exercise only
and does not represent an official IHACPA position.

## Participants

- Red team reviewer
- Devil's advocate reviewer
- Professor of software engineering
- Principal software engineer
- Professor of computer science
- Principal coder
- Professor of mathematics
- Professor of finance
- Professor of econometrics
- Professor of health economics
- Professor of policy

## Chair's Opening Direction

The chair frames the decision as follows:

> The project must not become a catalogue of aspirations. It must demonstrate
> trustworthy calculation, explicit evidence, careful use of official sources,
> and responsible public communication. Prioritise work that prevents harm,
> prevents overclaiming, and proves the implementation pattern.

## Deliberation Summary

### Security and public trust

The red team and policy reviewers argue that unsupported validation claims,
restricted source leakage, and premature publication are the highest-risk
failures. The chair accepts this as a gating concern.

Decision: evidence gates and restricted artifact controls must precede broad
publication or binding expansion.

### Scientific and mathematical validity

The mathematics, software engineering, and computer science reviewers argue
that formula bundles, versioned schemas, and SAS/Excel parity are the core of
credibility. The chair accepts that no pricing year should be called validated
without this evidence or a recorded exception.

Decision: source and formula parity become mandatory validation gates.

### Delivery feasibility

The devil's advocate and principal engineer argue that the roadmap is too broad
to implement all at once. The principal coder recommends a narrow executable
contract layer first.

Decision: prove one full stream/year lifecycle before attempting all bindings.

### Costing and policy usefulness

The health economics, finance, and econometrics reviewers argue that costing
studies are a legitimate high-value use case, but only with caveats, data
quality checks, and synthetic examples.

Decision: costing tutorials proceed after core validation gates and should use
synthetic or public aggregate data only.

## Prioritised Implementation Order

### Priority 0: Governance and claim control

1. Complete `Roadmap Portfolio Governance Backfill`.
2. Apply the governance checklist to every active track.
3. Reclassify roadmap-only, scaffold-only, complete-with-gaps, and complete
   states accurately.
4. Fix stale workflow paths, stale repo names, and inaccurate publication
   claims.

Rationale: Prevents the project from misrepresenting its state.

### Priority 1: Executable contracts and schemas

1. Implement `Reference Data Manifest Schema`.
2. Implement `Formula and Parameter Bundle Pipeline`.
3. Implement `Coding-Set Version Registry`.
4. Export JSON Schema or equivalent contract artifacts.

Rationale: Every later calculator, binding, classifier, and tutorial depends
on stable contracts.

### Priority 2: Validation gates and parity evidence

1. Implement `Pricing-Year Validation Gates`.
2. Add SAS parity and Excel formula parity as required evidence.
3. Implement fixture evidence records and source-gap exceptions.
4. Implement `nwau validate-year`.

Rationale: No public support claim is credible without validation evidence.

### Priority 3: Source discovery and restricted asset controls

1. Implement `IHACPA Source Scanner`.
2. Implement `ICD-10-AM/ACHI/ACS Licensed Product Workflow`.
3. Add restricted artifact denylist and local-only manifest conventions.
4. Record source hashes, retrieval dates, and gap records.

Rationale: Protects source provenance and licensing integrity.

### Priority 4: One complete stream/year canary

1. Select one calculator stream and one pricing year.
2. Archive and extract SAS/Excel sources.
3. Create formula bundle and reference-data manifest.
4. Validate source parity and output parity.
5. Run Python baseline and Rust canary.
6. Expose CLI/Arrow output.
7. Publish Starlight docs for the canary.

Rationale: Proves the whole lifecycle before scaling.

### Priority 5: Rust core promotion

1. Complete `Polyglot Rust Core Roadmap` phase sequencing.
2. Stabilize `Python Rust Binding`.
3. Add shared cross-binding conformance tests.
4. Promote Rust stream by stream from canary to opt-in to default.

Rationale: Rust should become the shared core only through evidence.

### Priority 6: Classification and grouper capabilities

1. Implement AR-DRG ICD/ACHI/ACS registry and grouper interfaces.
2. Implement emergency UDG/AECC transition registry and mapping pipeline.
3. Add parity fixtures and licensed local-tool workflows.

Rationale: Derived classifications are essential but legally and technically
complex.

### Priority 7: Public documentation and appropriate-use material

1. Add validation-status and appropriate-use docs.
2. Add pricing-year and classification compatibility matrices.
3. Add source and licensing caveats.
4. Add release evidence pages.

Rationale: Users need to know what is validated, experimental, future-only, or
locally supplied.

### Priority 8: Costing-study support

1. Implement cost bucket registry.
2. Ingest public NHCDC aggregate tables where permitted.
3. Add AHPCS concept models.
4. Publish synthetic costing-study tutorials.

Rationale: High user value, but should not precede calculator credibility.

### Priority 9: Polyglot bindings and apps

1. CLI/file interop.
2. C ABI.
3. R and Julia.
4. C#/.NET and Go.
5. TypeScript/WASM and web demos.
6. Java/JVM and SQL/DuckDB.
7. SAS interoperability.
8. Power Platform managed solution.

Rationale: Bindings should follow, not lead, the shared contract and validation
work.

### Priority 10: Publication expansion

1. PyPI remains primary.
2. Submit conda-forge staged-recipes.
3. Publish Rust crates only when Rust core is stable.
4. Publish npm/WASM, NuGet, Go, JVM, R, and Julia artifacts only after
   conformance gates pass.
5. Publish Power Platform only when managed solution and service boundary are
   real, tested, and imported.

Rationale: Registry publication should reflect real support, not intent.

## Chair's Final Decision

The chair selects a credibility-first roadmap:

1. Governance.
2. Contracts.
3. Validation.
4. Source and licensing controls.
5. One full canary.
6. Rust promotion.
7. Classifier/grouper support.
8. Documentation.
9. Costing tutorials.
10. Bindings and apps.
11. Publication expansion.

The chair explicitly rejects broad binding implementation or public milestone
claims until evidence gates are in place.
