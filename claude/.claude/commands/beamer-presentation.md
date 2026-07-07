---
description: Create academic presentations in Beamer (metropolis theme, lualatex)
---

# Beamer Presentation

Build conference/seminar/job-market slides. Infer the paper's content from the repo when converting a paper to slides; ask only for talk length and venue if not stated.

## Setup (matches this machine's LaTeX workflow)

- Compile with **lualatex** via latexmk (`\ll` in Neovim/VimTeX)
- Default theme: **metropolis**, `aspectratio=169`, no navigation symbols, frame numbers on
- Citations: biblatex/biber, `\textcite`/`\parencite`

```latex
\documentclass[aspectratio=169, 11pt]{beamer}
\usetheme{metropolis}
\setbeamertemplate{navigation symbols}{}
\setbeamertemplate{footline}[frame number]
\usepackage{graphicx, booktabs, tikz}
```

## Structure by talk length

| Duration | Slides |
|----------|--------|
| 15-20 min | Motivation (2) → Question (1) → Method (2) → Results (3-4) → Takeaways (1) |
| 45-60 min | + literature positioning, more results, robustness |
| 90 min | Full seminar: framework, extensive empirics, appendix bank |

Canonical slide sequence: title → motivation → "This paper" (question + preview of findings) → identification (challenge/solution/key assumption + equation) → main results → takeaways → appendix (`\appendix`, `[noframenumbering]`).

## Slide discipline

- One idea per slide; 1-2 minutes per slide
- Minimal text — short bullet fragments, not sentences; figures over tables
- Reveal incrementally (`\pause`, `<+->`) only where the buildup aids comprehension
- Results tables: at most 3-4 columns; highlight the key coefficient
- Always state economic magnitude next to the estimate ("1 SD in X → Y%")
- End on takeaways, not "Questions?"; keep backup slides for anticipated questions

## Pitfalls

- Slides that read as paper paragraphs
- Skipping the results preview in "This paper" (audiences want the answer early)
- Unreadable tables copied straight from the paper
