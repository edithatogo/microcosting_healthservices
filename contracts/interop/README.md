# CLI and file interop contracts

This directory holds the minimal machine-readable scaffold for language-neutral
file interop with `funding-calculator`.

## Files

- `cli-file-interop.schema.json`: JSON Schema for the interop contract bundle.
- `cli-file-interop.contract.json`: Example contract document for the CLI/file
  interoperability surface.
- `examples/acute-batch.job.json`: Example batch-job manifest.
- `examples/acute-batch.result.json`: Example result manifest for the same job.

## CLI

Print the contract bundle from the command line:

```bash
funding-calculator interop contract
```

The scaffold is intentionally additive. Existing calculator commands remain
unchanged.

## Privacy

The committed examples are synthetic scaffolds only. Do not add PHI,
patient-level records, secrets, private study data, or operational extracts to
this directory. Round-trip fixtures must remain safe to publish.
