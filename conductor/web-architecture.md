# GitHub Pages Web Architecture

## Goal

Provide a static-hostable demo that showcases calculator selection and fixture
driven outputs without accepting real patient data.

## Boundary Rules

- GitHub Pages is demo-only.
- The demo uses synthetic fixtures and the public calculator contract.
- No upload, persistence, or authenticated real-data workflow belongs in the
  Pages-hosted shell.
- Any real-data path must go through a separate secured service boundary.
- The browser surface should stay contract-consuming and never own calculator
  math.

## Demo Shell

- A static HTML shell can be served directly from GitHub Pages.
- The shell should read calculator/year metadata from committed fixture data or
  contract metadata.
- The shell should display a synthetic fixture result table rather than perform
  server-side calculation.
- The demo may eventually consume a Rust-backed core through a secure boundary,
  but the Pages-hosted shell itself stays static and synthetic.

## TypeScript/WASM Delivery

- TypeScript and WebAssembly can power richer client-side demo experiences, but
  only for synthetic or committed fixture data.
- Prefer `wasm-bindgen` or `wasm-pack` for browser-facing Rust builds when the
  demo needs compiled calculator logic.
- The browser client should consume generated or shared contracts, not duplicate
  formulas, parameter rules, or validation logic.
- A browser parity check should compare the WASM demo against committed fixture
  packs and shared contract metadata.

## Fixture Parity Workflow

- Commit synthetic fixture packs alongside the demo contract metadata.
- Use the same calculator identifiers and pricing-year identifiers as the
  shared public contracts.
- Keep any real-data workflow behind a separate secured service boundary.
- Treat the browser shell as a presentation layer, not a calculator engine.

## Privacy Rules

- The demo must not encourage users to paste patient-level data.
- The interface should make the demo-only nature obvious.
- Sample data should be synthetic and traceable to the shared fixture contract.
