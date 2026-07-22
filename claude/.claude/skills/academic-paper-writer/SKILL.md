---
name: academic-paper-writer
description: Use when drafting, revising, or restructuring sections of an empirical economics research paper in LaTeX
---

# Academic Paper Writer

## Overview

Write empirical economics prose that reads as expert human writing. The core principle: **read the existing paper first, then match its voice, precision level, and terminology exactly.**

## Before Writing Anything

1. **Read at least 2 existing sections** of the paper to absorb the author's voice, citation style, caveat patterns, and terminology
2. **Check the bibliography** for correct citation keys before writing any citation. Find it via the preamble's `\addbibresource{...}` rather than assuming a location: some projects use a shared `bib/master.bib`, others a per-paper `references.bib`. Never guess a key
3. **Check existing cross-reference labels** (`\label{...}`) in the paper before writing `\ref{}`
4. **Identify the paper's pronoun** ("I" vs "we") from existing text

## Anti-Patterns to Avoid

These patterns mark text as AI-generated. Never use them:

| Pattern | Example | Fix |
|---------|---------|-----|
| Em-dashes for asides | "households---those with ARMs---face" | Use commas, parentheses, or restructure |
| Typographic emphasis | `\emph{should}`, `\textit{only}`, `\textbf{Result:}` as a paragraph lead-in | Never use `\emph{}`, `\textit{}`, or `\textbf{}` — not in prose, not in captions, not in table notes, not as bold paragraph starters. Carry emphasis through word choice and sentence construction; a contrast becomes "the owned parcel" vs. "the pledged parcel", not `\emph{owned}`. Structure comes from plain topic sentences. The only exception is a genuine title or foreign term conventionally italicised in running prose (`\emph{ex ante}`) |
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
\citet{fagereng2021a} provide micro-level evidence that
consumption responses to income shocks are driven primarily
by liquidity constraints rather than total wealth.

% BAD: Generic consistency claim
This is consistent with the broader literature on household
consumption responses \citep{fagereng2021a}.
```

## LaTeX Conventions

- **Bibliography engine: always biblatex + biber.** Never the `natbib` package, never plain BibTeX. Standing preamble: `\usepackage[backend=biber, style=authoryear, natbib=true, maxbibnames=99]{biblatex}` plus `\addbibresource{...}` after `hyperref`. The reference list is `\printbibliography`; never `\bibliographystyle`/`\bibliography`. Build is `pdflatex -> biber -> pdflatex -> pdflatex`. If a paper you inherit uses the BibTeX toolchain, say so rather than silently writing to it
- **Citation commands: `\citet`/`\citep` by default, one pair per paper.** `\citet{key}` gives "Author (year)", `\citep{key}` gives "(Author, year)"; these come from biblatex's `natbib=true` compatibility option in the standing preamble above, which is not the natbib package. The native biblatex pair `\textcite`/`\parencite` is equally valid and does the same job — use it where a paper already does. What matters is that a paper picks one pair and stays with it: both compile under `natbib=true`, so mixing renders inconsistently rather than erroring. Grep an existing section before writing your first citation, and follow it. Inside existing parentheses use the textual form (`\citet`/`\textcite`); the parenthetical form there double-parenthesises
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

## Lint Before Declaring a Draft Done

Run these against the file you edited. They govern **prose**, so a hit on a `%`
comment line or inside a preamble macro definition is a false positive: read
each hit before acting, and never edit a comment just to satisfy a lint.

```
rg -n -- '---' <file>.tex
rg -n ' -- ' <file>.tex
rg -n -i 'taken together|at the heart of|it is worth noting|in other words|the resolution lies in|it is important to note|notably,|importantly,' <file>.tex
rg -n '\\emph\{|\\textit\{|\\textbf\{' <file>.tex
```

The first catches em-dashes used as separators; numeric ranges like `2022--23`
have only two hyphens and will not match. The second catches a spaced en-dash
used as a pause, while leaving `pp.~14--16` and `Chaney--Sraer--Thesmar` alone.

Then confirm every number in the draft traces to an actual estimation output,
not to memory.

## Common Mistakes

- Using terminology not established earlier in the paper (e.g., "conventional interest rate channel" when the paper uses "cash-flow channel")
- Guessing citation keys instead of checking the bib file named in `\addbibresource`
- Guessing `\ref{}` labels instead of checking the `.tex` file
- Writing welfare conclusions from reduced-form estimates
- Omitting ecological inference caveats for country-level analysis
- Over-interpreting coefficient magnitudes from weak-instrument specifications
