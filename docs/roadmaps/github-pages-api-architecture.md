# GitHub Pages and API Architecture

> Parallel-agent notice: GitHub Pages cannot host a server-side API. Do not
> implement API-backed demos as if GitHub Pages can run a backend.

## Recommended architecture

- GitHub Pages hosts Starlight documentation.
- GitHub Pages may host a static TypeScript/WASM demo.
- API-backed examples call an external hosted API or run in documented local
  mode.
- Docs should include mock/static examples where no hosted backend exists.

## Valid modes

| Mode | Description | Status |
| --- | --- | --- |
| Docs only | Static Starlight docs and examples. | Preferred baseline |
| Static WASM demo | Browser-only demo using bundled WASM and synthetic fixtures. | Optional |
| External API demo | GitHub Pages frontend calls separately hosted API. | Requires deployment |
| Local API demo | User runs local API and docs point to localhost examples. | Developer mode |

## Invalid claim

Do not claim that GitHub Pages runs the production API backend.
