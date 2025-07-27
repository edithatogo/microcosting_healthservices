# Roadmap

The current pricing formula is based on the IHACPA 2025 workbook.
Earlier years use similar calculators with different weights and
parameters.  Future work will allow the project to load formulae from
multiple editions.

## Planned approach

1. Store each year's SAS tables and workbook extracts under
   `archive/` using a `YYYY` directory name.
2. Add a `--year` option to the CLI to select which set of weights and
   formula to load.
3. Provide helper functions to read the appropriate tables based on the
   chosen year.
4. Update documentation and tests to cover at least one previous year
   once data is available.

Contributions are welcome.
