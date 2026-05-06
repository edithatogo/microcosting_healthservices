# Specification: Starlight Documentation Site and Versioning

## Goal

Replace the current documentation front door with a Starlight-based static site that supports versioned documentation, GitHub Pages deployment, and a clean migration path away from any temporary or legacy docs entry points.

## Requirements

- Use Astro and Starlight as the canonical docs-site framework.
- Pin `@astrojs/starlight` to the current stable `0.38.5` baseline initially, with Renovate responsible for future upgrades through reviewable pull requests.
- Support versioned documentation for calculator releases and pricing years.
- Keep the site static-host compatible for GitHub Pages.
- Use the default Pagefind search unless the roadmap later justifies a stronger external search provider.
- Include `starlight-links-validator` in the CI pipeline to catch broken links.
- Evaluate `starlight-openapi` for generated API documentation if the public calculator contract becomes machine-readable.
- Keep the docs navigation, sidebar, and content structure aligned with the existing conductor documentation and public calculator contracts.
- Migrate existing markdown documentation into the Starlight site without losing provenance, cross-links, or validation language.
- De-implement temporary or legacy docs entry points once the Starlight site is the canonical docs surface.
- Keep data-governance and privacy warnings visible in documentation workflows and examples.

## Non-Functional Requirements

- The site must build reproducibly in CI.
- The site must remain readable and usable on desktop and mobile browsers.
- Documentation structure must be maintainable as more pricing years and calculator pages are added.
- Plugin usage should be minimal and justified by docs quality, versioning, navigation, or generated reference content.

## Acceptance Criteria

- A Starlight scaffold exists in the repository or implementation branch.
- Versioned docs are implemented for at least one real calculator or release surface.
- GitHub Actions can build, validate links, and prepare deployment without manual intervention once configured.
- Legacy docs entry points are either removed or redirected with a documented migration path.
- The docs site uses only the plugins and integrations that are justified by this track.
- Documentation for the site explains the versioning model, plugin choices, and deployment path.

## Out of Scope

- Calculator algorithm changes.
- C# or Python engine rewrites unrelated to the docs site.
- Non-documentation web applications.
- Unnecessary Starlight plugins or integrations that do not support the docs-site goals.
