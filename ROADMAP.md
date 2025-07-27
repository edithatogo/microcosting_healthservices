# Roadmap

The current pricing formula is based on the IHACPA 2025 workbook.
Earlier years use similar calculators with different weights and
parameters.  Future work will allow the project to load formulae from
multiple editions.

## Planned approach

1. For each year download the SAS calculator zip from
   <https://www.ihacpa.gov.au/health-care/pricing/nwau-calculators>.
   Keep the archive as `archive/sas/<YEAR>.zip` and extract it to
   `archive/sas/<YEAR>/` alongside the workbook extracts.
2. Add a `--year` option to the CLI to select which set of weights and
   formula to load.
3. Provide helper functions to read the appropriate tables based on the
   chosen year.
4. Update documentation and tests to cover at least one previous year
   once data is available.

The extracted SAS programs will be referenced when extending the
Python-based engine so NEP/NWAU calculations can be performed for
multiple years.

Contributions are welcome.

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
- Keep each year's SAS calculator under `archive/sas/<YEAR>.zip` and extract
  it to `archive/sas/<YEAR>/` for reference when extending the Python engine.

## CLI selection of year
The `funding-calculator` command line tool accepts a `--year` option to select
the appropriate data directory. For example:

```bash
funding-calculator --year 2022 patient.csv > out.csv
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