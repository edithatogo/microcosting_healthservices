# Specification: Go Binding

## Overview
Provide a Go integration path for services, command-line tools, and data-pipeline systems. Go should consume the shared Rust core through C ABI, service, or CLI/file contracts and must not reimplement formulas.

## Functional Requirements
- Evaluate cgo C ABI, gRPC/service, and CLI/Arrow-file interop.
- Define Go request/response structs aligned to the public contract.
- Reuse shared golden fixtures.
- Document module publication only after parity gates are stable.

## Acceptance Criteria
- Go roadmap identifies the initial supported integration strategy.
- Go examples validate against shared fixtures.
- No formula logic is implemented in Go.
