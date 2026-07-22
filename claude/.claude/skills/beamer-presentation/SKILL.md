---
name: beamer-presentation
description: Create academic presentations in Beamer (jambro theme, lualatex)
---

# Beamer Presentation

Build conference/seminar/job-market slides. Infer the paper's content from the repo when converting a paper to slides; ask only for talk length and venue if not stated.

## Setup (matches this machine's LaTeX workflow)

- Compile with **lualatex** via latexmk (`\ll` in Neovim/VimTeX); verified working with this theme
- Default theme: **jambro** ([JambroBeamerTheme](https://github.com/ambropo/JambroBeamerTheme), Cesa-Bianchi), preferred over metropolis for academic and policy talks
- Citations: biblatex/biber, `\citet`/`\citep` (see the academic-paper-writer skill); the theme also provides `\citej{ref}` for a citation in the theme's main color

The theme ships with the dotfiles as the `texmf` stow package, symlinked into `TEXMFHOME` at `~/Library/texmf/tex/latex/jambro/`, so `\usetheme{jambro}` resolves from any directory and no per-deck copy is needed. Do not add `beamerthemejambro.sty` to a project unless the deck must build on a machine without the dotfiles, in which case say so. It loads its own dependencies (Fira Sans, TikZ, tcolorbox, tabularx, the Augie handwriting font) and needs TeX Live 2022 or newer. Slides that draw arrows to named nodes need **two compiler passes**, which latexmk handles.

On a new machine `./scripts/stow-all.sh` puts it in place. If `\usetheme{jambro}` ever fails, check `kpsewhich beamerthemejambro.sty` returns a path under `~/Library/texmf` before doing anything else. Vendoring details and the update procedure are in `texmf/README.md`.

```latex
\documentclass{beamer}   % 16:9 is the theme default; do not pass aspectratio
\usetheme{jambro}
\usepackage{graphicx, booktabs}
```

Theme options go as class options, not to `\usetheme`: `\documentclass[red,light,itemsep]{beamer}`. The ones worth knowing:

| Option | Effect |
|--------|--------|
| `red` / `night` | Red or dark-mode palette (default is blue; `night` overrides `red`) |
| `light` / `cabin` / `roboto` | Fira Sans Light, or switch font family |
| `3to2` | 3:2 aspect ratio instead of the 16:9 default |
| `itemsep` | More generous itemize spacing |
| `onesec` | Show only the current section in the footline |
| `centertitle` | Center frame titles |
| `shownotes` / `handout2x1` | Speaker notes alongside slides; 2x1 print handout |
| `hidememo` | Suppress every `\memo{...}` for a clean final build |

Annotation tools the theme adds, useful for talks where you mark up a result live: `\lapis{text}` (hand-drawn underline), `\stabilo{text}` (highlighter), `\lapisbox[label=id]{text}` (pencil box, names a TikZ node), `\jarrowu`/`\jarrowd`/`\jarrowl`/`\jarrowr` (sketched arrows), `\lapisnote[...]{node}{text}` (handwritten note attached to a named node by an arrow), `\NB{text}` (call-out), `\memo{text}` (draft annotation, hidden by `hidememo`). Tables get auto-width `Y`/`S` columns plus `\tablesize`, and `\sym{***}` keeps significance stars machine-readable. Use these where they carry meaning, not as decoration.

`Demo.tex` / `Demo.pdf` in the theme repo is the full feature showcase; read it before reaching for an unfamiliar macro.

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
