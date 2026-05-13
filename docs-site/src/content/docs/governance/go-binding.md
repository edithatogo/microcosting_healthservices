---
title: Go binding
---

# Go binding

This page defines the docs-site governance for the Go workstream. The Go
binding is treated as a downstream adapter, not as a new source of calculator
truth. The contract stays in the shared public calculator schema and the Go
layer only exists to expose that contract safely to Go users.

## Strategy

The Go strategy is deliberately conservative:

- Keep the Go surface aligned to the public calculator contract.
- Prefer thin wrappers over duplicated business logic.
- Treat implementation changes in the core calculator as upstream changes that
  the Go binding consumes, not redefines.
- Avoid promises about runtime support until the Go package is explicitly
  gated and documented.

This keeps the binding predictable for users and limits drift between the docs,
the contract, and any generated or hand-maintained Go code.

## Service boundary

The CLI and Arrow-file boundary is the first Go package entrypoint that callers
should rely on while the binding matures.

- Public functions on that package define the supported file and batch surface.
- Helper functions, internal types, and transport-specific details stay out of
  the public API.
- If the binding grows additional helpers, they must remain clearly marked as
  internal or experimental.

The intent is that users call a small, stable Go API that forwards to the
shared calculator contract rather than a broad package of implementation
details.

## File boundary

The file boundary is the on-disk separation between generated glue, hand-written
helpers, and test fixtures.

- Keep generated contract adapters in dedicated files so they can be refreshed
  without touching surrounding logic.
- Keep manual compatibility code separate from generated code.
- Do not mix transport concerns, conversion helpers, and public package docs in
  the same file unless that file is explicitly the package entrypoint.

This makes it easier to review changes, regenerate code, and keep provenance
clear.

## Contract boundary

The contract boundary is the line between calculator semantics and language
binding mechanics.

- The contract defines inputs, outputs, and validation rules.
- The Go binding may translate types, errors, and zero values to match Go
  conventions.
- The binding must not introduce new business rules or silently relax contract
  validation.

When the contract changes, the binding should be updated to match the new
schema. When the binding needs a convenience API, that API must still map back
to the contract without changing meaning.

## Cross-compilation caveats

Go cross-compilation is useful, but the docs should not overstate what it
guarantees.

- Pure Go code can usually cross-compile cleanly, but any native dependency
  changes that assumption.
- CGO, platform-specific files, and build tags can create target-specific
  differences that must be documented.
- Generated code should be checked against the target operating systems and
  architectures that the project claims to support.

The binding should only advertise cross-compilation support after the build
matrix, dependency set, and release packaging have been validated for the
claimed targets.

## Future module gating

Future Go publishing should use explicit module gating instead of open-ended
claims.

Planned gates include:

- Package versioning that matches the documented contract version.
- A release checklist that confirms the module still matches the public schema.
- Build and cross-compile checks for the supported `GOOS` and `GOARCH`
  combinations.
- A clear distinction between preview, supported, and archived module states.

Until those gates are in place, the docs should treat the Go binding as a
governed workstream with a stable direction, not as a universally supported
distribution promise.
