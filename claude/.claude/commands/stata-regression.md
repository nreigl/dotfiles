---
description: Run regression analyses in Stata with publication-ready esttab output
---

# Stata Regression

Generate reproducible Stata regression workflows. Infer the specification, fixed effects, and clustering from context; ask only when a choice would materially change the estimates.

## Conventions

- `regress` for simple OLS, `reghdfe` for high-dimensional FE, `xtreg` for classic panels
- Always specify `vce(cluster ...)` or `vce(robust)` to match the design
- `eststo` + `esttab` for tables (LaTeX by default), with variable labels and SE notes
- Requires: `ssc install estout reghdfe`

## Core pattern

```stata
use "data.dta", clear
summarize y x1 x2 x3

regress y x1 x2 x3, vce(cluster firm_id)
eststo model1

reghdfe y x1 x2 x3, absorb(firm_id year) vce(cluster firm_id)
eststo model2

esttab model1 model2 using "results/regression_table.tex", replace se label
```

## Pitfalls

- Clustering at the wrong level (cluster where treatment varies)
- Omitting fixed effects the design requires
- Exporting tables without labels or SE/star notes
