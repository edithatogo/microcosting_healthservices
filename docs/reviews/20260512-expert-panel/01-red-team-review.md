# Simulated Red Team Review

## Role

Adversarial reviewer focused on security, misuse, integrity, provenance,
licensing, and public credibility risk.

## Findings

1. Validation claims are the main attack surface.
   If the repository claims a year, package, app, or binding is "validated" or
   "published" without durable evidence, users may rely on incorrect funding or
   costing outputs.

2. Restricted IHACPA classification products are a licensing trap.
   AR-DRG, ICD-10-AM, ACHI, ACS, groupers, and mapping tables may include
   restricted material. The repo must guard against accidental commits and
   redistribution.

3. Polyglot expansion increases drift risk.
   Every new binding is another place where formula logic can be copied,
   mutated, or silently diverge.

4. Power Platform and web demos are high-risk surfaces.
   They can accidentally store formula logic, PHI-like input examples, service
   credentials, environment IDs, or tenant-specific configuration.

5. Public package trust depends on repeatable release evidence.
   PyPI release exists, but conda-forge, Power Platform publishing, crates,
   npm/WASM, NuGet, and other future package claims must be explicit about
   current versus future status.

6. Source downloads and scanner automation create supply-chain exposure.
   Downloaded IHACPA files need hashes, retrieval dates, source URLs, and
   tamper-evident manifests.

## Required Controls

- Add CI guards for restricted classification artifacts.
- Make validation status machine-readable and deny broad support claims without
  SAS parity, Excel formula parity, fixture parity, and source provenance.
- Require every binding to run shared fixture conformance tests.
- Keep formula logic out of Power Platform apps, flows, docs demos, notebooks,
  R, Julia, C#, Go, TypeScript, JVM, and SQL.
- Require release evidence tables for PyPI, conda-forge, GitHub Releases,
  Pages, and every future registry.
- Add an audit log for source acquisition and extraction.

## Priority Recommendation

Do not implement more surfaces first. Implement evidence gates, restricted
artifact guards, source manifests, and contract tests before additional
bindings or apps.
