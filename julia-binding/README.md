# NWAUJulia

`NWAUJulia` is a minimal Julia wrapper around the authoritative Python
`nwau_py` CLI. It does not reimplement any funding formulas in Julia.
Instead, it moves CSV files across a stable process boundary and lets the
existing Python calculator perform the work.

This keeps the Julia surface conservative and low risk while preserving a
single source of truth for calculator logic.

## What this prototype provides

- `calculate(...)` for generic CLI/file execution
- `calculate_acute(...)`, `calculate_ed(...)`, and `calculate_non_admitted(...)`
  convenience helpers

## Contract

The wrapper shells out to:

```text
python -m nwau_py.cli.main <subcommand> <input_csv> --output <output_csv>
```

Optional arguments are forwarded when supplied:

- `--year`
- `--params`

The Julia code only coordinates file paths and process execution. Validation,
classification checks, and all formula logic remain in Python.

## Requirements

- Julia 1.10 or newer
- Python 3 with the `nwau_py` package available on the selected interpreter
- The archived calculator data under `archive/sas/<YEAR>/`

The wrapper defaults to `python3` and `nwau_py.cli.main`, but both can be
overridden through environment variables:

```julia
ENV["NWAU_PYTHON"] = "/path/to/python"
ENV["NWAU_MODULE"] = "nwau_py.cli.main"
```

## Example

```julia
using NWAUJulia

output_csv = calculate_acute(
    "tests/fixtures/golden/acute_2025/input.csv";
    year = 2025,
    params_dir = "archive/sas/2025",
)

println(output_csv)
```

The returned value is the path to the Python-produced output CSV. If you want
the data as a Julia table, load it separately with your preferred CSV package.

Arrow is the target interchange format for larger cross-language batches after
the shared CLI/file contract supports it. The current executable prototype is
CSV-only because that is the active shared CLI contract.

## Boundary

This package is intentionally wrapper-only.

- Formula logic stays in Python
- Input validation stays in Python
- Julia only handles file handoff and process invocation
