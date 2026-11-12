# Technical conventions

Read this reference before editing citations, equations, table notes, captions,
numerical claims, or LaTeX structure. The core rules in `../SKILL.md` take
precedence.

## Numbers and disclosure

- Every empirical number must trace to a current cleared file in
  the project's cleared-output directory or a rendered table.
- A manifest, renderer, or prose assertion proves only what it checks. When a
  producer changed, compare regenerated output with the committed cleared file
  before quoting it.
- Never invent, interpolate, or hand-adjust a result.
- Use two or three meaningful significant digits and consistent decimals within
  a table column.
- Spell out one through nine; use numerals for 10 and above and for quantities
  with units.
- Pick one of `percent`, `per cent`, or `%` for a paper and use it consistently.
- Illustrative numbers must be introduced as hypothetical.
- Confidential micro-data must not enter manuscript prose, a figure, or a
  prompt. Where a project defines a disclosure regime, its rules on entity-level
  content, identifiers, per-entity fitted values, and minimum cell sizes bind
  absolutely. Consult the project layer before quoting any aggregate.

## Citations

- Use the Zotero-managed bibliography files that the preamble loads with
  `\addbibresource{}`. Some projects keep them in a shared `bib/` folder
  (`master.bib`, `core_papers.bib`), others in a paper-local `references.bib`.
- Where the bibliography is generated from a reference manager, treat it as
  machine-owned. Do not hand-add entries. Record the import request wherever the
  project keeps its reading list, and park the citation behind a visible `% TODO`
  until the library is re-exported.
- Use biblatex with biber and the existing `natbib=true` compatibility layer.
  Use `\citet{key}` and `\citep{key}` rather than `\textcite` or `\parencite`.
- Inside existing parentheses, prefer `\citet` to avoid double parentheses.
- After a Zotero export, check for changed keys and undefined citations.
- Cite a source next to the claim it supports. Naming an institution in prose is
  not a substitute for a citation.

## Cross-references and equations

- Use a non-breaking space before references: `Section~\ref{...}`,
  `Table~\ref{...}`, and `Figure~\ref{...}`.
- Check existing labels before adding a reference or label.
- Explain the intuition and identifying comparison before displaying an
  equation.
- Define every variable and parameter at first use. Reintroduce notation after
  a long gap.
- Use Latin letters for variables and Greek letters for parameters and
  coefficients.
- Use `in which` for a model or equation; reserve `where` for place when a clean
  alternative exists.

## Tables and figures

- Discuss every substantive panel or column the paper prints. A panel that the
  text never uses should normally be cut or moved.
- Put fixed effects in indicator rows below the observation count, with `Yes`
  rather than check marks.
- Captions and notes state the sample, outcome units, controls, inference method,
  and material construction choices. Do not reproduce the entire pipeline.
- Keep producer filenames and clearing metadata in a concise final note only
  when the replication convention requires them.
- State the clustering level and, where relevant, the wild-bootstrap method,
  Driscoll-Kraay bandwidth, joint test, multiple-testing adjustment, or weak-
  instrument gate.
- Figures identify frequency, units, omitted category, sample window, and
  confidence-band level. Local-projection figures normally distinguish 68% and
  90% bands clearly.
- Table and figure references belong in active sentences, not isolated
  parentheticals.
- Generate every numeric table from code and pull it in with `\input{}`. A
  hand-typed number in the manuscript is an integrity risk: it cannot be traced
  to an estimation output and it goes stale without warning.
- Keep the palette and the axis scales consistent across every figure in one
  paper. A scale that changes between paired panels invites misreading.
- Box the headline result of a derivation: `\boxed{u'(c_1) = \beta R u'(c_2)}`.
  Box one result per model, not every intermediate step.

## LaTeX style

- Do not use `\emph{}`, `\textit{}`, or `\textbf{}` for emphasis or manual
  run-in labels. Use topic sentences and proper sectioning commands.
- Use `\paragraph{}` below subsection level. Promote a run-in block to a
  subsection when it extends beyond about a page or carries its own exhibits.
- Keep one manuscript file per paper. Tables may be input from generated files;
  prose should not be split across a `sections/` tree.
- Build with `latexmk` (the global `~/.latexmkrc` runs lualatex and biber). Do
  not pass `-pdf`, because it forces pdflatex. Then check undefined
  references, citations, overfull boxes, pagination, and table overflow.
- Fix generated-table text in the renderer, not in the rendered `.tex` file.

## Paper structure

The ordinary order is Introduction; Literature, which may be folded into the
introduction; Institutional background; Data; Empirical strategy; Results;
Robustness; Policy discussion when warranted; and Conclusion.

The conclusion restates the main finding, policy relevance, and material
limitations. It introduces no new empirical result.
