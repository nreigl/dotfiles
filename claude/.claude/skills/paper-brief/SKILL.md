---
name: paper-brief
description: Produces a one-page PDF brief of an academic economics paper from a PDF URL or a filepath. Six fixed sections, written so an economics PhD outside the subfield can follow the strategy and the result. Use when the user asks for a brief, a summary, or a read of one economics paper, and when the user prepares for a seminar, a department visit, or a meeting with a visiting author. The output is always a one-page PDF file, so say so before you start if the user only asked for a summary.
argument-hint: "[PDF URL or filepath]"
---

# Paper Brief

Turn one economics paper into a one-page PDF brief. The reader is an economics
PhD who does not work in the paper's subfield. That reader must finish the
brief able to state what the paper does, why the result is credible, and what
to ask the author.

The translation is the product. A summary that repeats the paper's own
vocabulary has failed, even when every sentence is true.

## Workflow

```text
1. Resolve the input      URL or filepath -> a local PDF
2. Extract the text       pdftotext
3. Read the paper         abstract, intro, spec, main table, conclusion
4. Write the six sections to the contract below
5. Build brief-<slug>.tex
6. Compile, move the PDF out, clean the aux files
7. Check the page count. Trim if it is above 1
```

## Resolve the input

If the user gave no argument, ask for one. Do not guess a paper.

Work in the session scratchpad directory. Set `TMP` to it.

For a URL:

```bash
curl -fSL --max-time 90 -o "$TMP/source.pdf" "$URL"
```

For a filepath, confirm the file exists.

Confirm the file is a real PDF before you read it:

```bash
pdfinfo "$TMP/source.pdf"
```

If `pdfinfo` fails, the server returned a landing page or a paywall, not the
paper. Stop. Tell the user which URL failed. Never write a brief from an
abstract page, and never fill the gaps from memory of the literature.

## Extract the text

```bash
pdftotext -layout "$TMP/source.pdf" "$TMP/source.txt"
```

Read `$TMP/source.txt`.

Read these parts: the abstract, the introduction, the section that states the
specification, the main results table, and the conclusion. Read a robustness
table only when section 5 needs it. Skip the appendix and the proofs.

Read the theory section too when the empirics test it. A reference-point model
or a bargaining model that generates the heterogeneity prediction is part of
the strategy, not decoration. Skip a theory section the results never touch.

Do not trust the section boundaries in the extracted text. `-layout` drops
figure axis labels and table cells into the middle of body paragraphs on
figure-heavy pages. Locate each section with `grep -n` before you read it.

Headline numbers are not always in a table. Check the prose around the main
table for the event-study contrast and for any aggregate cross-check against
an external data source.

Do not reach for `pdfplumber` or `pypdf`. Neither imports on this machine.
`pdftotext` and `pdfinfo` come from poppler, which the Brewfile installs.

## The six sections

Each section has a word budget and a required shape. Fill the shape.

| Section | Budget | Shape |
|---|---|---|
| 1. Summary | 1 sentence | What the paper finds, and what makes it credible. No method names. |
| 2. Setup | ~80 words | The question, the country or market, the sample period, the unit of observation, the data source. |
| 3. Empirical strategy | ~140 words | Four parts, in the order below. |
| 4. Key result | ~120 words | The headline number with units, the direction in words, the magnitude against a benchmark. |
| 5. Limitations | 3 bullets, ~30 words each | What the design cannot rule out. Name the threat. |
| 6. Follow-ups | 3 bullets, ~25 words each | Questions to put to the author. |

The six budgets sum to about 495 words. Treat 560 words as the hard ceiling:
one A4 page at 10pt holds about 620 words of body text, and the title block
takes the rest. A fourth bullet in section 5 or 6 is the first thing to cut,
not the first thing to add.

### Section 3 has four parts, in this order

1. **The variation, in plain words.** Name what is compared with what. The
   comparison may be across firms, across places, or across time windows.
   Shape: "compares firms whose loans happened to reprice in 2022 with
   otherwise similar firms whose loans did not."
   Shape: "compares Michigan households with households in four neighbouring
   states over the same clock hours."
2. **The identifying assumption, as a sentence the reader can judge.**
   Shape: "this works only if the repricing date is unrelated to the firm's
   own outlook."
3. **The method name, once, and only now.** Write "difference in differences"
   on first use, then the short form.
4. **What would break it**, in one clause.

Parts 1 and 2 come before part 3. A reader who meets the estimator name first
stops reading for meaning and starts reading for vocabulary.

### The translation rule

Define every subfield term in the same sentence that first uses it.

Write: "a diffusion index, which reports the share of banks tightening minus
the share easing".

Not: "the BLS diffusion index".

The rule covers instruments, data products, institutional terms, and survey
constructs, not only estimators. If a term needs its own sentence to explain,
the paper's mechanism probably needs that sentence more.

### Section 4 needs a benchmark

A coefficient on its own is not intuition. Put the magnitude against something
the reader already holds: a standard deviation, the sample mean, an annual
growth rate, or one policy step.

Shape: "0.4 percentage points, about one third of the average annual increase
over the sample."

State the direction in words as well as in sign.

### Sections 5 and 6 are a pair

Each limitation names a specific threat to this design. "The sample is small"
is not a limitation. "The first stage is weak for firms below 50 employees,
where most of the variation sits" is.

Each follow-up question ties back to a limitation or to a choice the paper
makes without explaining it. Write questions you can ask out loud in a
seminar.

### Prose rules

Write under ASD-STE100 Simplified Technical English. Short sentences. Active
voice. One word for one concept across the whole brief. No hedging stack
("appears to somewhat suggest"). State what the paper claims, and mark your
own judgement as yours.

## Build the LaTeX file

Write `brief-<slug>.tex` in the current working directory. The slug is the
first author surname in lower case plus the year printed on the version you
have, not the repository stamp: `stefani2025`. A preprint dated January 2025
and posted in 2026 is `2025`. This matches
the Better BibTeX citation key format.

`latexmk` reads the global `~/.latexmkrc`, which sets `$pdf_mode = 4`. The
compile runs **lualatex**. Two consequences:

- Do not load `inputenc`. It is wrong under lualatex.
- Load `fontspec` only when the paper forces a non-Latin glyph.

Preamble:

```latex
\documentclass[10pt,a4paper]{article}
\usepackage[margin=2.2cm]{geometry}
\usepackage{parskip}
\usepackage{microtype}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage[hidelinks]{hyperref}

\setlist[itemize]{noitemsep,topsep=2pt,leftmargin=*}
\titlespacing*{\section}{0pt}{6pt}{2pt}
\titleformat{\section}{\normalsize\bfseries}{\thesection.}{0.5em}{}
\pagestyle{empty}
```

At 10pt with 2.2cm margins, one A4 page holds about 620 words of body text.
That is the reason for 10pt. The same brief at 11pt runs to two pages and the
budget above stops meaning anything.

The title block carries the paper title, the authors, the year, and the venue
or working-paper series. A preprint has no venue: write the repository and the
identifier instead, for example `Working paper, arXiv:2607.27584 [econ.GN]`.
Put the source URL or filename below it in `\small`.

Number the six sections 1 to 6 and keep the section names from the table.

## Compile and clean

```bash
latexmk "brief-$SLUG.tex"
latexmk -c "brief-$SLUG.tex"
command mv "build/brief-$SLUG.pdf" .
command rm -rf build
```

Clean before you move. `latexmk -c` removes the auxiliary files but keeps the
PDF, so the PDF is still there to move afterwards. Do not use `rmdir`: it fails
on a directory that still holds `.fls` or `.synctex.gz`, and `2>/dev/null` hides
that failure.

Four failures happen silently. Avoid all four:

- **Pass no `-pdf` flag.** `-pdf` downgrades the run to pdflatex.
- **The PDF lands in `build/`**, not next to the source, because `.latexmkrc`
  sets `$out_dir = 'build'`. Move it out.
- **Use `command mv` and `command rm`.** `aliases.zsh` maps both to the `-i`
  form. A non-interactive shell never answers the prompt, so the write is
  skipped and the exit status stays 0.
- **Use `command ls`** when you pipe the listing into `grep`. `ls` is an alias
  for `eza --icons`, and the icon glyphs stop the filename matching.

On a failed compile, read `build/brief-<slug>.log`. Errors appear in the
classic `! Undefined control sequence.` form, not in `file:line:` form.

## Enforce one page

```bash
pdfinfo "brief-$SLUG.pdf" | grep Pages
```

If the count is above 1, trim and recompile. Trim in this order:

1. Section 6, down to two questions.
2. Section 5, down to two bullets.
3. Section 2, down to the question, the sample period, and the data source.
4. Section 4, down to the headline number and its one benchmark.

Never trim section 3. The strategy is the reason the brief exists.

If the brief is still above one page after step 4, the sections are over
budget. Count the words against the table above and cut back to the budget.
Do not change the margin, the font size, or the preamble.

Report the final path to the user.

## Common errors

**`pdfinfo: Couldn't open file`** — the download returned HTML. The paper is
behind a paywall or the URL points at a landing page. Ask the user for a
direct PDF link or a local file.

**The brief runs to two pages** — trim in the order above. Do not reach for the
preamble first. The margin must stay at or above 2cm and the font at or above
10pt, so there is no room there anyway.

**`latexmk` exits 0 but no PDF appears** — you passed `-pdf` and pdflatex
choked on a lualatex-only construct. Drop the flag.

## Related

If the task is to attack the identification, not to summarise it, tell the user
that `/principled-economics` does that. Use `review-paper` for a full referee report.
