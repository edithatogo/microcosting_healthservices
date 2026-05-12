# wasm-binding

This directory is a minimal TypeScript adapter shell for a future Rust/WASM
binding.

It is intentionally not a calculator implementation. The wrapper only:

- loads a future `wasm-pack`-style module
- validates the exported surface
- provides a safe boundary for downstream callers

Formula logic stays outside this package. When the Rust/WASM build becomes
ready, the generated output should be wired into the adapter here rather than
duplicating the calculator rules in TypeScript.

Browser demos that use this package must use synthetic data only. Do not place
PHI, patient-level records, secrets, tokens, or private study data in fixtures,
bundles, screenshots, logs, or example payloads.

## Current status

- No Rust build pipeline is defined here yet
- No funding formulas are implemented here
- The package is a scaffold for future `wasm-pack` output
- Not publication-ready and not published to npm

## Suggested shape

The adapter expects a module factory so callers can plug in future WASM output
without changing the wrapper contract:

```ts
import { createWasmAdapter } from './src/index.js';

const binding = await createWasmAdapter({
  moduleFactory: () => import('../pkg'),
  validateExports: (candidate): candidate is { calculate: (input: unknown) => unknown } =>
    typeof candidate === 'object' &&
    candidate !== null &&
    typeof (candidate as Record<string, unknown>).calculate === 'function',
});
```

That keeps the TypeScript side focused on loading, validation, and handoff.
