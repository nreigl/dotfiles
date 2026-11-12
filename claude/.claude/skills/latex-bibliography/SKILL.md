---
name: latex-bibliography
description: Use when you set up or repair the bibliography of a LaTeX research project - the Zotero and Better BibTeX export, the bib/ folder layout, and the biblatex preamble. Skip for the prose of the paper (use econ-write-house).
---

# LaTeX bibliography with Zotero

## Bibliography Management with Zotero

**Setup:**
1. Install Better BibTeX for Zotero (https://github.com/retorquere/zotero-better-bibtex)
2. Configure citation key format: `[auth:lower][year]` (e.g., `stefani2025`)
3. Set up auto-export: Collection → Export → "Better BibLaTeX" → Keep updated

**Standard structure for research projects:**
```
project/
├── bib/
│   ├── master.bib        # Auto-exported from Zotero (all papers)
│   ├── core_papers.bib   # Hand-curated frequently cited papers
│   └── README.md         # Setup documentation
├── paper/
│   └── manuscript.tex
└── presentation/
    └── slides.tex
```

**LaTeX preamble (biblatex):**
```latex
\usepackage[
    backend=biber,
    style=authoryear-comp,
    natbib=true,
    sorting=nyt,
    maxbibnames=99,
    maxcitenames=2,
    giveninits=true,
    uniquename=false,
    uniquelist=false,
]{biblatex}

\addbibresource{../bib/master.bib}
\addbibresource{../bib/core_papers.bib}
```

## Compilation

Compile with `latexmk manuscript.tex`. Do not add `-pdf`. The flag forces
pdflatex, but the global `~/.latexmkrc` selects lualatex (`$pdf_mode = 4`) and
the `build/` output directory. latexmk runs biber when it is necessary.
