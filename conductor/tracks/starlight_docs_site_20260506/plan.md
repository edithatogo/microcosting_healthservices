# Plan: Starlight Documentation Site and Versioning

## Phase 1: Roadmap, Versioning, and Site Contract

- [x] Task: Write tests or checks for the docs-site contract
    - [x] Pin the Starlight version baseline
    - [x] Assert the required plugin and integration list
    - [x] Define the versioned-docs policy for pricing years and releases
- [x] Task: Draft the site architecture and migration roadmap
    - [x] Document the source content inventory
    - [x] Document the versioning and navigation model
    - [x] Document the migration and de-implementation strategy
- [x] Task: Update conductor setup for the Starlight stack
    - [x] Reflect the Starlight roadmap in `tech-stack.md`
    - [x] Add the new track to the registry and context index
- [x] Task: Conductor - Automated Review and Checkpoint 'Roadmap, Versioning, and Site Contract' (Protocol in workflow.md)

## Phase 2: Scaffold and Content Migration

- [ ] Task: Write tests for the site scaffold and content layout
    - [ ] Check that the docs source tree resolves as expected
    - [ ] Check that versioned content directories and sidebar groups are present
    - [ ] Check that chosen plugins are wired into the scaffold
- [ ] Task: Implement the Starlight scaffold
    - [ ] Create the Astro/Starlight project structure
    - [ ] Add the baseline config, theme, and sidebar layout
    - [ ] Wire in the chosen validation and docs-quality plugins
- [ ] Task: Migrate the existing docs content
    - [ ] Move or mirror the current markdown documentation into the site content tree
    - [ ] Preserve provenance and cross-links
    - [ ] Add the initial versioned documentation structure
- [ ] Task: Conductor - Automated Review and Checkpoint 'Scaffold and Content Migration' (Protocol in workflow.md)

## Phase 3: De-implementation and Deployment

- [ ] Task: Write tests for the deployment and de-implementation path
    - [ ] Check that the legacy docs entry points are no longer authoritative
    - [ ] Check that the GitHub Actions build/deploy workflow is defined
    - [ ] Check that the site can be built for GitHub Pages
- [ ] Task: Remove or redirect the legacy docs entry points
    - [ ] Retire temporary docs bootstrap files
    - [ ] Replace duplicate entry points with the Starlight site
    - [ ] Keep redirects or migration notes where they are needed
- [ ] Task: Add and stabilize GitHub Actions deployment
    - [ ] Add build, link-check, and deployment jobs
    - [ ] Review failing checks until they pass
    - [ ] Verify the GitHub Pages publish path
- [ ] Task: Conductor - Automated Review and Checkpoint 'De-implementation and Deployment' (Protocol in workflow.md)

## Phase 4: Refinement and Feature Completion

- [ ] Task: Write tests for the docs-site features that must be exercised
    - [ ] Verify version switcher or version navigation behavior
    - [ ] Verify search behavior
    - [ ] Verify any generated API-doc pages if adopted
- [ ] Task: Refine the website until the planned features are actually used
    - [ ] Tighten navigation, landing pages, and cross-links
    - [ ] Exercise the chosen plugins in the published site
    - [ ] Improve accessibility and mobile behavior
- [ ] Task: Finalize docs-site governance and handoff
    - [ ] Record the versioning and plugin decisions in conductor docs
    - [ ] Document how the site is deployed and maintained
    - [ ] Confirm the site is ready for continued content growth
- [ ] Task: Conductor - Automated Review and Checkpoint 'Refinement and Feature Completion' (Protocol in workflow.md)
