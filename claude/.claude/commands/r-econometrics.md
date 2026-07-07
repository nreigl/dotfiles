---
description: Run IV, DiD, RDD, and panel analyses in R with fixest and proper diagnostics
---

# R Econometrics

Generate rigorous causal-inference code in R. Infer the research design, unit of observation, fixed effects, and clustering level from the project context and data; ask only when a choice is genuinely ambiguous and would change the estimates (e.g., clustering level with no obvious treatment-assignment level).

## Conventions

- **`fixest` for estimation** (`feols`, `feglm`), never `lm` for panels
- **`modelsummary` or `etable`** for tables; export LaTeX with `coef_map` labels if the project has one
- **Cluster SEs at the level of treatment assignment**; for macro panels prefer Driscoll-Kraay (`vcov = "DK"` / `vcov = dk(lags)`)
- **Diagnostics by design**:
  - IV: first-stage F (KP), weak-instrument caveats
  - DiD: event-study plot (`i(rel_time, treated, ref = -1)` + `iplot`), pre-trend check; use `sunab()` or the `did` package for staggered timing — never plain TWFE
  - RDD: bandwidth selection, density test
- **Script structure**: setup → data prep → descriptives → main spec → robustness → visualization → export
- Comment *why* each specification choice was made, not what the line does

## Core pattern

```r
library(fixest)
library(modelsummary)

did <- feols(outcome ~ treat_post | unit + year, data = df, cluster = ~unit)

es <- feols(outcome ~ i(rel_time, treated, ref = -1) | unit + year,
            data = df, cluster = ~unit)
iplot(es)

modelsummary(list("Main" = did),
             stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
             output = "output/tables/did_table.tex")
```

## Pitfalls

- Clustering at the wrong level (cluster where treatment varies)
- Plain TWFE with staggered treatment timing
- Reporting IV results without first-stage strength
- Skipping pre-trend evidence in DiD
