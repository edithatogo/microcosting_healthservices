# Binding Matrix

## Purpose

This matrix defines the recommended language bindings and delivery surfaces for
the Rust core. It is a roadmap artifact, not a promise that every surface is
already implemented.

## Sequencing Rule

- Rust/Python parity is the prerequisite for any non-Python adapter that would
  ship calculator logic.
- Language bindings are thin wrappers over the Rust core, not independent
  calculation engines.
- Stable ABI, Arrow exchange, WebAssembly, or a service boundary may be used as
  appropriate for the target surface.
- GitHub Pages remains synthetic/demo-only.
- Power Platform remains orchestration-only through a service or custom
  connector boundary.

## Language Binding Matrix

| Surface | Status | Recommended toolchain | Boundary shape | Primary risk | Sequencing |
| --- | --- | --- | --- | --- | --- |
| Python | implemented | PyO3 / maturin for the Rust bridge, with the current Python package as the first adapter | Arrow-compatible table exchange and native package import | Adapter drift from the Rust core if parity tests weaken | Keep as the validated production path until Rust parity is fixture-backed |
| Rust | implemented | Native Rust core crate and workspace consumers | Direct crate calls over Arrow-compatible structs/tables | None beyond ordinary crate API stability | Core source of truth for all later adapters |
| TypeScript | planned | wasm-bindgen or wasm-pack over a Rust/WASM build | WebAssembly for synthetic browser demos only | Browser bundle size, serialization friction, and accidental real-data assumptions | Start after Rust/Python parity is stable and only for demo/fixture usage |
| R | planned | extendr, with FFI reviewed against the data contract | Native extension or ABI wrapper around Rust core | Packaging complexity and host-runtime compatibility | Start after Rust/Python parity and after the matrix has stable contract tests |
| Julia | planned | jlrs or a Julia `ccall` wrapper depending on the packaging target | ABI wrapper or native package bridge | Tooling maturity and call-convention maintenance | Start after Rust/Python parity and after adapter contract tests exist |
| C# | planned | Stable ABI wrapper or service boundary, not formula duplication | Native wrapper or secured service call | Long-term maintenance of interop shims | Start after core parity; prefer service boundary if ABI overhead is high |
| Go | deferred | C ABI or service boundary | Thin wrapper around the Rust core or service contract | Cross-language memory management and build portability | Defer until core contracts and a lower-risk adapter path are stable |

## Delivery Surface Matrix

| Surface | Status | Recommended toolchain | Boundary shape | Primary risk | Sequencing |
| --- | --- | --- | --- | --- | --- |
| GitHub Pages | implemented | Static Astro/Starlight site with fixture-backed content | Synthetic demo shell only | User confusion if real data workflows appear in the browser | Keep demo-only forever; never own calculator math |
| Streamlit | planned | Python-hosted Streamlit app over the existing package | Local/demo analyst surface | Overexposing sensitive data or duplicating service logic | Ship only after Python adapter parity is stable |
| Power Platform | advisory | Custom Connector or secured service boundary | Workflow orchestration only | Formula duplication inside flows, Dataverse, or canvas apps | Consume contracts only; never compute calculator logic |

## Notes

- Implemented surfaces are the ones already available in the repository and
  validated by the current track state.
- Planned surfaces should be treated as sequencing targets, not commitments to
  ship in a single track.
- Deferred means the surface is intentionally not the next implementation step.
- Advisory means the surface is useful for orchestration or governance but
  should not own calculator computation.
