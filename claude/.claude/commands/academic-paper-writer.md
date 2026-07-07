---
name: academic-paper-writer
description: Use when drafting, revising, or restructuring sections of an empirical economics research paper in LaTeX
---

# Academic Paper Writer

## Overview

Write empirical economics prose that reads as expert human writing. The core principle: **read the existing paper first, then match its voice, precision level, and terminology exactly.**

## Before Writing Anything

1. **Read at least 2 existing sections** of the paper to absorb the author's voice, citation style, caveat patterns, and terminology
2. **Check the bibliography** (`bib/master.bib`) for correct citation keys before using any `\textcite` or `\parencite`
3. **Check existing cross-reference labels** (`\label{...}`) in the paper before writing `\ref{}`
4. **Identify the paper's pronoun** ("I" vs "we") from existing text

## Anti-Patterns to Avoid

These patterns mark text as AI-generated. Never use them:

| Pattern | Example | Fix |
|---------|---------|-----|
| Em-dashes for asides | "households---those with ARMs---face" | Use commas, parentheses, or restructure |
| `\emph{}` anywhere | "\emph{should}", "\emph{only}", "\emph{precautionary saving}" | Never use `\emph{}`. Restructure the sentence so the emphasis is carried by word order or logic, not formatting. For concept labels, use plain text. The only acceptable use of `\emph{}` is for foreign-language terms (e.g., `\emph{ex ante}`) |
| Performative labeling | "I label this the 'X puzzle'" | Introduce the concept without naming ceremony |
| "Taken together" | "Taken together, these results..." | Cut entirely or use a specific connector |
| "at the heart of" | "the mechanism at the heart of this paper" | "the central mechanism" or just state it |
| "It is worth noting" | Filler | Delete; if worth noting, just note it |
| "In other words" | Restating what was just said | Say it right the first time |
| Tricolon flourishes | "X, Y, and Z all point to..." | Integrate evidence into the argument |
| Thesis-statement conclusions | "This finding carries implications for..." | Be specific about what implication |
| "The resolution lies in" | "The resolution lies in the distinction..." | State the distinction directly |

## Calibrating Confidence to Evidence

**Match assertion strength to estimation precision.** This is the most common AI writing failure in empirical papers.

- **Statistically significant + economically large**: "The ARM rate rises by 29bp by quarter 3, implying approximately 117% pass-through"
- **Directionally consistent but imprecise**: "GDP responses are directionally consistent but imprecisely estimated"
- **Surprising or puzzling**: "Savings expectations improve in high-ARM countries, contrary to the prediction of standard consumption-smoothing models"
- **Never**: "The results clearly demonstrate that..." or "This unambiguously shows..."

Always include caveats relevant to the identification strategy:
- Ecological inference concerns for country-level data
- Sample composition issues
- Instrument strength limitations (if KP F-stats are weak)

## Writing Results Sections

Lead with the estimate, not the method:

```latex
% GOOD: Estimate first
Panel (b) shows the response of ARM interest rates. Pass-through
builds steadily and slightly exceeds one-for-one by quarter 3,
peaking at roughly 29 basis points.% Source: estimates.csv, ARM rate, h=3 (0.293)

% BAD: Method first
Using the IV-LP framework described in Section X, I estimate
the response of ARM rates and find that...
```

**Source-comment convention**: After stating a specific number, add an inline LaTeX comment with the source file, variable, horizon, and raw value: `% Source: filename.csv, variable, h=N (value)`. If you do not know the actual source filename, use `% TODO: add source reference` rather than inventing a filename.

## Writing Literature Integration

Never write "is consistent with the broader X literature" — this is filler. Instead, cite the specific mechanism from the specific paper:

```latex
% GOOD: Specific mechanism from specific paper
\textcite{fagereng2021a} provide micro-level evidence that
consumption responses to income shocks are driven primarily
by liquidity constraints rather than total wealth.

% BAD: Generic consistency claim
This is consistent with the broader literature on household
consumption responses \parencite{fagereng2021a}.
```

## LaTeX Conventions

- **Citations**: `\textcite{key}` for "Author (year)", `\parencite{key}` for "(Author, year)". Never `\citet` or `\citep` (those are natbib, not biblatex). Inside existing parentheses use `\textcite` — `\parencite` there creates double parentheses
- **Cross-references**: Always use `~` before `\ref`: `Section~\ref{sec:results}`, `Table~\ref{tab:main}`, `Figure~\ref{fig:irf}`
- **Numbers in text**: Spell out one through nine; use numerals for 10+. Always use numerals with units: "25bp", "18 countries", "8 quarters"
- **Confidence intervals**: "Shaded: 68\% (dark) and 90\% (light) CI" in figure notes
- **Standard errors**: State the type: "DK(3) SE" or "Driscoll-Kraay standard errors with 3 lags"
- **Figure notes**: Use the `figurenotes` environment. Include: estimation equation reference, instrument, shock scaling, CI bands, FE, SE type, sample

## Paper Structure (IMRAD)

For empirical macro papers:

1. **Introduction**: Research question and main finding in paragraph 1. Methodology in paragraph 2. Contribution relative to closest paper in paragraph 3. Roadmap last.
2. **Literature Review**: Organize by intellectual strand, not chronologically. Each strand should connect to your identification or mechanism.
3. **Data**: Describe sources, sample, key variables. Figures showing cross-sectional variation before estimation.
4. **Methodology**: Estimation equation with numbered reference. Discuss identification assumptions and threats.
5. **Results**: Lead with first-stage diagnostics. Then outcome-by-outcome, most robust first. Caveats inline, not deferred.
6. **Robustness**: Brief, referencing appendix tables/figures. Don't re-argue the mechanism.
7. **Conclusion**: Restate finding. Policy implications. Limitations. No new results.

## Common Mistakes

- Using terminology not established earlier in the paper (e.g., "conventional interest rate channel" when the paper uses "cash-flow channel")
- Guessing citation keys instead of checking `bib/master.bib`
- Guessing `\ref{}` labels instead of checking the `.tex` file
- Writing welfare conclusions from reduced-form estimates
- Omitting ecological inference caveats for country-level analysis
- Over-interpreting coefficient magnitudes from weak-instrument specifications
