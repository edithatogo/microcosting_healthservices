# Solution Manifest Skeleton

## Solution Identity

- Solution display name: `Microcosting Health Services ALM`
- Solution unique name: `mchs_alm_orchestration`
- Solution type: solution-based app orchestration package
- Versioning strategy: semantic versioning tracked in source control

## Packaging Contract

- Authoring format: unpacked source tree.
- Build format: packed solution artifact for import into target environments.
- Promotion format: managed solution for downstream environments.

## Included Asset Placeholders

- Canvas or model-driven app surface.
- Environment variables.
- Connection references.
- Custom connector or service-boundary binding.
- Optional Dataverse tables for orchestration metadata only.

## Exclusions

- Calculator formulas.
- Embedded business logic that duplicates the core engine.
- Direct production data handling outside the secure service boundary.
