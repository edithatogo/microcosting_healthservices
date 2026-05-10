# ADR 0005: Web and Power Platform Delivery

## Status

Proposed

## Context

The project should eventually support a GitHub Pages-hosted web app and a Power
Platform app over a secure calculation boundary. The long-term calculation core
direction is Rust, not a C#-owned engine.

## Decision

Keep the GitHub Pages app static-first and safe for synthetic/demo data. Keep
the Power Platform app as an orchestration surface over an explicit secure
service boundary. Use shared golden fixtures to enforce parity between Python
and any future Rust-backed delivery surface.

## Consequences

Delivery surfaces can evolve independently while sharing calculator contracts and validation evidence.
