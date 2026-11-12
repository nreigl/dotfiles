---
name: r-econometrics
description: "Use when writing or reviewing causal-inference code in R: IV, difference-in-differences with common or staggered timing, RDD, and panel fixed effects with fixest. Skip for debugging an R error message, for data wrangling with no estimation in it, and for interpreting results already estimated (the user can run `/principled-economics` for that)."
---

# R Econometrics

Generate rigorous causal-inference code in R. Infer the research design, unit of observation, fixed effects, and clustering level from the project context and data; ask only when a choice is genuinely ambiguous and would change the estimates (e.g., clustering level with no obvious treatment-assignment level).

## Conventions

- **`fixest` for estimation** (`feols`, `feglm`), never `lm` for panels
- **`modelsummary` or `etable`** for tables; export LaTeX with `coef_map` labels if the project has one
- **Cluster SEs at the level of treatment assignment**, not at the unit of observation. A municipal programme in a firm-year panel clusters on municipality
- **Long-T macro panels only**: prefer Driscoll-Kraay (`vcov = "DK"` / `vcov = dk(lags)`) for cross-sectional dependence. Not for a short-T firm or household panel
- **Diagnostics by design**:
  - IV: first-stage F (KP), weak-instrument caveats
  - DiD, common timing (every unit treated in the same period): `i(rel_time, treated, ref = -1)` + `iplot`
  - DiD, staggered timing (units treated in different periods): `sunab()` or the `did` package. Never `i(rel_time, treated)` under two-way FE — that **is** the plain-TWFE event study, and it carries the negative-weighting problem `sunab()` exists to fix
  - RDD: bandwidth selection, density test
- **Script structure**: setup → data prep → descriptives → main spec → robustness → visualization → export
- Comment *why* each specification choice was made, not what the line does

## Staggered DiD: three traps

**Never-treated units need a sentinel, and the two packages want different ones.**
`sunab()` wants a large finite cohort; `did::att_gt()` wants `0`. `NA` silently
drops every control unit in both, and the run still returns a plausible estimate
off the treated sample alone.

```r
df$cohort_sa <- ifelse(is.na(df$first_treat), 10000L, df$first_treat)  # sunab()
df$cohort_cs <- ifelse(is.na(df$first_treat),     0L, df$first_treat)  # att_gt()
```

**A table of insignificant leads is not a pre-trend test.** Low power makes
failure-to-reject cheap. Report a joint Wald test on all leads, and report
`HonestDiD` (Rambachan-Roth) sensitivity: how large a trend violation the result
survives.

**Name the estimand.** `aggte()` returns four of them. Report `dynamic` as the
event study and `simple` or `group` as the headline, and say which you chose.
`group` is the one that exposes a cohort-selection story.

Print the cohort-by-year rollout table before estimating. If one cohort holds
most of the treated mass, the aggregate ATT is that cohort.

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
- Plain TWFE with staggered treatment timing, including the `i(rel_time, treated)` event study
- Never-treated units coded `NA`, which drops the control group without an error
- Reporting IV results without first-stage strength
- Skipping pre-trend evidence in DiD
