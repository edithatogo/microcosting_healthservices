# Formula Mapping

The workbook `nwau25_calculator_for_acute_activity.xlsb` contains the core formula on the
sheet **Formula breakdown** cell `B49`:

```
= {[PW x APaed x (1 + AInd + ARes + ART + ADia) x (1 + ATreat) x (1 + AC19) + (AICU x ICU hours)] - [(PW + AICU x ICU hours) x APPS + LOS x AAcc] - PW x AHAC - PWAHR x RAHR} x NEP
```

`excel_calculator/data/formula.json` captures this expression in a structured way. The `variables`
object lists each symbol used in the formula and the corresponding column name
in `excel_calculator/data/weights.csv`. The `steps` array lists the operations in order so that
the formula can be recomputed programmatically.

For example `PW` references the **Inlier** column in the weights table and the
final `NWAU25` value is obtained after all intermediate terms are combined as
shown in the `steps` list.
