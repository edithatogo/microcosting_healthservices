# Synthetic Costing-Study Data Fixtures

## Purpose

These CSV files provide synthetic activity, cost, and benchmark data for
costing-study tutorials in the IHACPA NWAU calculator documentation. They
illustrate how analysts can combine NWAU calculation outputs with observed
costs and benchmark averages to produce stream-level and classification-level
cost-versus-funding analyses.

## Data Origin and Caveats

- **All data is synthetic.** No real patient, hospital, or jurisdiction data
  is included. Episode identifiers, classification codes, costs, and
  benchmarks are fabricated for tutorial purposes only.

- **Costs are illustrative.** The observed costs in `observed_costs.csv` are
  drawn from a log-normal distribution centered around (NWAU × NEP × 1.1) to
  simulate real-world variation. They do not reflect any actual hospital's
  cost structure.

- **Columns map to real NHCDC/AHPCS concepts**, but the values are
  fabricated. The column names follow conventions from the National Hospital
  Cost Data Collection and the Australian Hospital Patient Costing Standards.

- **Do not use for policy or funding decisions.** These files are training
  aids and must not be treated as official IHACPA outputs or as substitutes
  for rigorous local costing studies.

## File Inventory

| File | Contents |
|------|----------|
| `nwau_calculation_inputs.csv` | 20 synthetic episodes (10 acute, 5 ED, 3 mental health, 2 subacute) across 2 hospitals with classification codes, LOS, age, private/same-day flags, and state. |
| `observed_costs.csv` | Synthetic patient-level costs (total, variable, fixed) matching the 20 episodes, log-normally distributed around efficient price. |
| `nhcdc_benchmarks.csv` | Aggregate stream-level average cost, average NWAU, and cost-per-NWAU benchmarks inspired by public NHCDC summary tables. |

## Usage in Tutorials

1. Calculate NWAU for each episode using the package calculators.
2. Join results with `observed_costs.csv` on `episode_id`.
3. Compare observed total cost against funded revenue (NWAU × NEP).
4. Aggregate by stream or classification code and compare against `nhcdc_benchmarks.csv`.

## Source Evidence

- [IHACPA Costing Overview](https://www.ihacpa.gov.au/health-care/costing/costing-overview)
- [NHCDC Public Sector Reports](https://www.ihacpa.gov.au/health-care/costing/national-hospital-cost-data-collection)
- [Australian Hospital Patient Costing Standards](https://www.ihacpa.gov.au/health-care/costing/australian-hospital-patient-costing-standards)
