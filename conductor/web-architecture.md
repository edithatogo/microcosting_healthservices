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

## Demo Shell

- A static HTML shell can be served directly from GitHub Pages.
- The shell should read calculator/year metadata from committed fixture data or
  contract metadata.
- The shell should display a synthetic fixture result table rather than perform
  server-side calculation.

## Privacy Rules

- The demo must not encourage users to paste patient-level data.
- The interface should make the demo-only nature obvious.
- Sample data should be synthetic and traceable to the shared fixture contract.
