# Roadmap for Historical NEP/NWAU Support

This project currently ships a single set of weights and the formula for the NEP25
calculator under `excel_calculator/data`. To compute funding for previous years
we will maintain year specific copies of these files.

## Data layout
- Create a subdirectory per year in `excel_calculator/data/` e.g.
  `excel_calculator/data/2024/weights.csv` and `excel_calculator/data/2024/formula.json`.
- The default `excel_calculator/data/weights.csv` and `formula.json` will continue
  to hold the current year data (NEP25) for backwards compatibility.
- Archive copies of the official calculators (xlsb workbooks) will live under
  `excel_calculator/archive/<year>/` to allow regeneration of CSV files via the
  `extract_weights.py` script.

## CLI selection of year
The Python CLI in `nwau_py.cli.main` will gain a `--year` option which selects
the correct data directory. For example:

```bash
nwau_py.cli.main acute patient.csv --year 2022 --output out.csv
```

internally translates to:

```bash
--params excel_calculator/data/2022
```

If `--year` is omitted, the tool will use the default data directory as it does
today.

## Future steps
1. Add folders for each historical year (e.g. `2023`, `2022`, `2021`).
2. Store the corresponding workbook under `excel_calculator/archive/<year>/` and
   regenerate `weights.csv` using `extract_weights.py`.
3. Convert the workbook formula into `formula.json` using the same structure as
   the current year.
4. Extend unit tests to parametrise over years ensuring the CLI can calculate
   NWAU correctly for all supported years.
5. Update documentation and examples to demonstrate selecting historical data.

This roadmap will allow researchers to easily compute funding using past
NEP/NWAU definitions without altering the code base for each release.

