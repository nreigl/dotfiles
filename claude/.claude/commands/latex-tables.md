---
description: Generate publication-ready regression and summary tables in LaTeX
---

# LaTeX Tables

Produce clean academic tables. Prefer generating tables **from code** (`modelsummary`/`etable` in R, `esttab` in Stata) and pulling them into the manuscript with `\input{}` — hand-typed numeric tables are an integrity risk (see /audit-research-code).

## Conventions

- `booktabs` rules only (`\toprule`/`\midrule`/`\bottomrule`); never vertical lines
- `threeparttable` for notes; notes must state SE type, clustering, significance stars, and sample
- Numeric columns aligned (use `siunitx` `S` columns for decimal alignment when precision varies)
- Every table gets `\caption{}` + `\label{tab:...}`; reference as `Table~\ref{tab:...}`
- Consistent star convention across the paper: `* p<0.10, ** p<0.05, *** p<0.01`

## Skeleton

```latex
\begin{table}[htbp]\centering
\caption{Effect of Treatment on Outcome}
\label{tab:main_results}
\begin{threeparttable}
\begin{tabular}{lccc}
\toprule
 & (1) & (2) & (3) \\
\midrule
Treatment & 0.125*** & 0.118*** & 0.102** \\
 & (0.041) & (0.039) & (0.046) \\
Controls & No & Yes & Yes \\
Fixed effects & No & Yes & Yes \\
\midrule
Observations & 2,145 & 2,145 & 2,145 \\
R$^2$ & 0.18 & 0.24 & 0.31 \\
\bottomrule
\end{tabular}
\begin{tablenotes}\small
\item Notes: Standard errors clustered by firm in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01.
\end{tablenotes}
\end{threeparttable}
\end{table}
```

## Pitfalls

- Tables wider than the text block (use `\resizebox` sparingly; prefer fewer columns)
- Notes missing SE type or star definitions
- Inconsistent decimal places or star thresholds across tables
