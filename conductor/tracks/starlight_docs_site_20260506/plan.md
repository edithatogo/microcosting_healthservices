# Plan: Starlight Documentation Site and Versioning

## Phase 1: Roadmap, Versioning, and Site Contract [checkpoint: 44e493d]

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

## Phase 2: Scaffold and Content Migration [checkpoint: 4c43ed3]

- [x] Task: Write tests for the site scaffold and content layout
    - [x] Check that the docs source tree resolves as expected
    - [x] Check that versioned content directories and sidebar groups are present
    - [x] Check that chosen plugins are wired into the scaffold
- [x] Task: Implement the Starlight scaffold
    - [x] Create the Astro/Starlight project structure
    - [x] Add the baseline config, theme, and sidebar layout
    - [x] Wire in the chosen validation and docs-quality plugins
- [x] Task: Migrate the existing docs content
    - [x] Move or mirror the current markdown documentation into the site content tree
    - [x] Preserve provenance and cross-links
    - [x] Add the initial versioned documentation structure
- [x] Task: Conductor - Automated Review and Checkpoint 'Scaffold and Content Migration' (Protocol in workflow.md)

## Phase 3: De-implementation and Deployment [checkpoint: f82cd6f]

- [x] Task: Write tests for the deployment and de-implementation path
    - [x] Check that the legacy docs entry points are no longer authoritative
    - [x] Check that the GitHub Actions build/deploy workflow is defined
    - [x] Check that the site can be built for GitHub Pages
- [x] Task: Remove or redirect the legacy docs entry points
    - [x] Retire temporary docs bootstrap files
    - [x] Replace duplicate entry points with the Starlight site
    - [x] Keep redirects or migration notes where they are needed
- [x] Task: Add and stabilize GitHub Actions deployment
    - [x] Add build, link-check, and deployment jobs
    - [x] Review failing checks until they pass
    - [x] Verify the GitHub Pages publish path
- [x] Task: Conductor - Automated Review and Checkpoint 'De-implementation and Deployment' (Protocol in workflow.md)

## Phase 4: Refinement and Feature Completion [checkpoint: f82cd6f]

- [x] Task: Write tests for the docs-site features that must be exercised
    - [x] Verify version switcher or version navigation behavior
    - [x] Verify search behavior
    - [x] Verify any generated API-doc pages if adopted
- [x] Task: Refine the website until the planned features are actually used
    - [x] Tighten navigation, landing pages, and cross-links
    - [x] Exercise the chosen plugins in the published site
    - [x] Improve accessibility and mobile behavior
- [x] Task: Finalize docs-site governance and handoff
    - [x] Record the versioning and plugin decisions in conductor docs
    - [x] Document how the site is deployed and maintained
    - [x] Confirm the site is ready for continued content growth
- [x] Task: Conductor - Automated Review and Checkpoint 'Refinement and Feature Completion' (Protocol in workflow.md)
