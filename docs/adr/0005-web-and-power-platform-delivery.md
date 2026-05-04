# ADR 0005: Web and Power Platform Delivery

## Status

Proposed

## Context

The project should eventually support a GitHub Pages-hosted web app and a Power Platform app with a C# calculation engine.

## Decision

Keep the GitHub Pages app static-first and safe for synthetic/demo data. Keep the Power Platform app as an orchestration surface over an explicit C# calculation engine. Use shared golden fixtures to enforce parity between Python and C#.

## Consequences

Delivery surfaces can evolve independently while sharing calculator contracts and validation evidence.

