---
name: econ-write-house
description: "House style for Nicolas Reigl's economics writing, layered over the econ-write skill. Use when drafting, revising, restructuring, or reviewing any economics prose - working papers, journal submissions, policy briefs, memos, abstracts, conclusions, captions, table notes, non-technical summaries, referee responses, slide text. econ-write supplies the section formulas and field conventions; this file supplies the register, the evidence hierarchy, the claims discipline, and the punctuation rules, and it wins on every conflict. Skip for prose that is not part of a research output: commit messages, chat replies, code comments, and documentation, which follow the `simple-english` rules instead."
---

# House layer over `econ-write`

Write empirical-economics prose in the voice of an experienced central-bank
economist. Make the economic argument easy to follow without making it
telegraphic, ornamental, or more certain than the evidence permits.

## Authority and loading

`econ-write` is the default skill for economics writing. It carries the section
formulas, the introduction and abstract structure, the identification and
results guidance, the paper-type templates, and the field conventions. Load it
first.

This file is the author's layer on top. It overrides `econ-write` where the two
conflict, and it adds the rules `econ-write` does not carry. **Where they
disagree, this file wins**, without exception and regardless of how well-sourced
the upstream advice is. It also overrides generic academic-writing guidance. The former
`academic-paper-writer` skill was removed on 2026-08-23: everything it carried
now lives here, and its mechanical lint block is section 13 of
[references/self-check.md](references/self-check.md).

Load the references selectively but completely:

- Read [references/voice-and-craft.md](references/voice-and-craft.md) before a
  substantial rewrite, a front-matter rewrite, or any task concerning voice,
  flow, paragraph structure, or exposition.
- Read [references/technical-conventions.md](references/technical-conventions.md)
  before editing citations, equations, table notes, captions, numerical claims,
  or LaTeX structure.
- Read [references/self-check.md](references/self-check.md) before completing a
  manuscript-wide pass or declaring prose ready to circulate.

The references elaborate this file. They do not relax its rules.

A project may add its own layer for disclosure rules, artifact paths, and
repository conventions. A project layer adds constraints; it does not relax
these.

Nothing here is machine-enforced. Every rule is checked by reading, so the layer
works only when it is loaded. Invoke it explicitly for any prose work.

## Overrides of `econ-write`

Each entry names the upstream text it displaces. Line numbers refer to the
installed copy recorded in `../econ-write/UPSTREAM.md`. If an upstream update
moves them, re-check each pointer.

### O1. Em dashes are banned. Upstream recommends them.

Upstream `SKILL.md:312` says "Include parenthetical asides and em-dashes --
real academics use these for qualifications and side notes". `SKILL.md:265`
repeats the licence, and `review-checklist.md:75` lists their absence as a
defect.

Reject all three. Recast with a comma, with parentheses, with a subordinate
clause, or as a new sentence. A paired appositive normally becomes commas, or
parentheses when the inserted text already contains a comma. A single trailing
dash normally becomes a new sentence.

Upstream's reasoning is that em dashes defeat AI-detection heuristics. Writing
to defeat a detector is not a reason to write worse, and the recast version is
almost always the clearer one.

### O2. Split on logical load, not on a word count.

Upstream `SKILL.md:310` prescribes "Mix short sentences (8-12 words) with longer
ones (15-25 words)".

No word-count range is a safe harbor, upstream's or any other. Split a sentence
when it carries several empirical jobs, even if its grammar is correct, and
retain a longer sentence when shortening it would force the reader to
reconstruct the logic. Upstream's range is too short for the content this prose
carries: a Manski bound, a fixed-effect absorption argument, or the difference
between a euro-weighted and an unweighted mean does not fit in eight to twelve
words, and forcing it there makes the reader re-read the paragraph to recover a
meaning the writer already had.

The rule that replaces the range is in the clarity floor below, under "Control
logical load, not word count".

### O3. No deliberate roughness.

Upstream `SKILL.md:313` says "Allow natural roughness ... Real papers have some
friction between sections", and `SKILL.md:315` says "Avoid perfect parallel
structure in every list ... Real writing is slightly irregular".

Both are anti-detection advice, and both lose to the clarity floor. Do not
introduce friction, irregularity, or a missing transition on purpose. The prose
must state its own logical joins.

Upstream's underlying point survives in a weaker form: do not sand every
sentence into the same shape. Vary rhythm. That is a different instruction from
leaving a gap in the argument.

### O4. Connectors that state a relation are permitted.

Upstream `SKILL.md:309` bans "notably", "crucial", "comprehensive",
"furthermore", "pivotal", "groundbreaking", "delve", "landscape",
"multifaceted", "shed light on", "pave the way", "leverage" as a verb, and
"robust" outside its statistical sense.

Keep that list, with one carve-out. The test is what the word does. A connector
that states a logical relation between two claims is doing necessary work and is
permitted: `however`, `by contrast`, `conversely`, `consequently`, `accordingly`,
`therefore`, `furthermore`, `moreover`, `nevertheless`, `although`, `because`,
`consistent with`, `for comparison`, `recall that`.

A word that only instructs the reader how to react stays banned, including
sentence-initial `notably`, `importantly`, `overall`, `strikingly`, and
`interestingly`.

### O5. Precision language is stricter than upstream.

Upstream's results guidance permits inline statistics and threshold language.
Neither is allowed here. See "Report precision without threshold chasing" below.

### O6. Slide theme and slide advice come from `beamer-presentation`.

Upstream `latex-tips.md:136` prescribes `\usetheme{metropolis}`, and
`specialized-tasks.md` carries its own presentations block. Both are displaced.
The house theme is `jambro`, vendored through the `texmf` stow package, and the
slide guidance lives in the `beamer-presentation` skill. Load that skill for any
talk. Ignore both upstream blocks.

## Before changing prose

1. Read at least two existing sections of the same paper to learn its terms,
   voice, caveat patterns, and established claims.
2. Write down the paper's central question, answer, mechanism, empirical
   strategy, and contribution. Use these five statements to decide what earns
   space in the manuscript.
3. Inspect the relevant generated outputs or rendered tables before touching a
   numerical claim. Never infer that a committed table is current merely because
   it renders or passes a schema check.
4. Check the paper-local bibliography for citation keys and the manuscript for
   existing labels before adding `\citet`, `\citep`, or `\ref`.
5. Read `git log` before restoring a claim missing from a mature draft. A
   withdrawn claim may have been removed deliberately even when no guard now
   records that decision.
6. Match authorship. Use `I` for authorial acts in sole-authored papers, passive
   voice for mechanical steps, and `we` only for a shared testable prediction.

## Revise from argument to sentence

Do not begin by polishing sentences. Work in this order:

1. Logical coherence and the red thread.
2. Visibility and accuracy of the main contribution.
3. Evidence hierarchy and allocation of narrative space.
4. Section and paragraph structure.
5. Economic interpretation and precision of claims.
6. Transitions and exposition.
7. Concision, meaning removal or relocation of material that is not earning its
   place.
8. Sentence-level style.

Repairing a higher level often discards work done below it. Diagnose first.

Concision is about what the draft covers, not about the length of its sentences.
Cutting words out of sentences that need them is not concision.

## Build an evidence hierarchy

Classify every empirical exercise before rewriting:

- **Headline evidence:** establishes the paper's main answer.
- **Supporting evidence:** explains the mechanism or an important margin.
- **Qualification:** limits the interpretation or measures an economically
  important uncertainty.
- **Diagnostic:** checks data construction, sample composition, or design
  behavior.
- **Robustness:** shows that a headline result is not specific to one reasonable
  implementation.

Give narrative space in that order. Diagnostics and robustness checks should not
crowd the result they support. Move secondary variants, implementation history,
and unused table panels to the appendix or replication record.

Report results as an argument, not a catalogue. Each exercise must answer a
question the preceding evidence raised. A table that does not advance the
argument should be cut, moved, or explicitly demoted.

## Control paragraph load

Each paragraph has one primary empirical payload. Its first sentence states that
payload. The remaining sentences normally provide the evidence or economic
magnitude, the interpretation, and at most one material qualification.

Do not make one paragraph carry the sample definition, estimator, headline
coefficient, three robustness variants, a hypothetical objection, and the
conclusion. Separate those jobs or relocate the secondary material. A paragraph
can be grammatically smooth and still be overloaded.

Use one idea per paragraph as a substantive rule, not a sentence-count rule.
Three to six sentences is common, but the number is not a target.

## Keep the manuscript out of referee-response mode

State identification threats and alternative explanations neutrally. Do not
organize the paper around an imagined adversary with phrases such as "the
obvious objection", "what survives", "the harder version of the objection", or
"this closes the remaining distance".

The house sequence is to name the empirical threat, explain why it could bias
the estimate, describe the design or evidence that addresses it, and state
exactly what uncertainty remains.

Do not turn every robustness result into a rebuttal. The manuscript should sound
like a researcher establishing an evidence hierarchy, not a response letter
anticipating every possible criticism.

## Separate research prose from the audit trail

The main text explains economics. Producer filenames, generated-artifact names,
implementation dates, reconciliation history, and secondary sample counts are
replication metadata. Put them in source comments, concise footnotes, table
notes, or a dedicated reproducibility appendix.

Keep a filename in running prose only when the identity of that artifact is
itself substantively necessary. A reader should not need to parse the pipeline
to understand the paper.

## Clarity floor

These rules outrank compression and elegance, here and upstream. Compression
without a clarity floor does not produce plain prose. It produces punchy prose:
sentences that sound decisive while the reader assembles the meaning.

### Say the claim in the sentence that mentions it

A sentence must be intelligible on one reading. Do not use an announcement or a
compressed pointer where the content should be:

- Bad: "One feature of this episode shapes everything in this section."
- Bad: "The action sits in the triple interaction."
- Bad: "Two terms carry the exercise."
- Better: state the feature, the quantities, or the identified coefficient in
  that sentence.

For each `this`, `that`, or definite label such as "the quantity margin", check
that the referent and its meaning have already been stated. If the reader can
only repeat the sentence rather than restate its content, the sentence is a
pointer, not a claim.

This also rules out the enumerative opener ("Two patterns tie the result to a
fixed-cost mechanism"). Name the items inside the sentence, or write a plain
roadmap.

### Use plain, public vocabulary

Do not make the reader learn private shorthand such as "the arbiter", "the
ladder", "the horse race", or "the estimator bridge". Name the exercise
literally each time. Circulating widely in applied work is not a defence:
"specification ladder" and "horse-race regression" are common and still banned,
because a reader outside that circle has to decode them. If a short form has to
be taught before it can be used, it is a coinage.

Standard technical terms are permitted in the body when they were glossed on
first use and add precision. "Rate discounts remain stable once firm-bank-time
fixed effects absorb borrower and lender selection" is legal in a results
section, because no plain paraphrase is as exact.

In the abstract, non-technical summary, introduction, and conclusion, plain
words carry the claim. Say what moves, for whom, and by how much before using a
term of art. An abstract relational verb is the tell: organises, carries,
drives, governs, operates on, works through. Each names a relation without
saying what moves, and the repair is to say what moves. The plain version is
usually longer, and the length is the rule working rather than failing.

### Use literal verbs

Rates rise or fall. Values adjust. Coefficients are large, small, or imprecisely
estimated. Data do not reveal, judge, arbitrate, settle, or speak. Tables report
estimates; the author interprets them. Dead metaphors that are standard terms of
art, including pass-through, tightening, channel, margin, buffer, and spillover,
remain available.

Rhetorical figures are chosen for sound and cost clarity. Antithesis ("the first
link fired and the second did not"), chiasmus, and three-beat cadence all make
the reader decode rather than read. Say both halves plainly and in full, even
when that costs words.

A vivid figure repeated across sections hardens into the paper's frame, and the
reader then has to carry it. Retire a motif at every occurrence, not just the
first.

### State logical joins

Use `because`, `however`, `consequently`, `although`, and similar connectors
when they express the relationship between claims. Do not leave the reader to
infer why one sentence follows another. Redundancy at a long-distance join is
useful: restate the earlier result in a clause rather than pointing back with a
bare label. Not "The accelerator of the introduction needs two links", but "The
financial accelerator described in the introduction needs two links to work."

A run of three or more consecutive short declaratives with no connective is a
defect to repair, not a style to preserve.

### Control logical load, not word count

Use complete expository sentences of varied length. A short sentence is useful
when it states a headline result. A longer sentence may attach one reason or
qualification. No word-count range is a safe harbor: split a sentence when it
contains several empirical jobs, even if its grammar is correct, and retain a
longer sentence when shortening it would force the reader to reconstruct the
logic.

A short sentence must carry a claim, never tease one. Test: if it were deleted,
would the reader lose a fact or only lose an announcement? If only an
announcement, cut it.

Split on nesting depth as well as load. A long sentence built from a main clause
and subordinate clauses in sequence is clear. A shorter one with a relative
clause inside a relative clause inside a parenthesis is not.

## Claims and inference

### Calibrate language to identification

Use causal verbs only for identified designs. Associational estimates `co-move`,
`are associated with`, or `predict`. State once, explicitly, what the design does
and does not identify, and repeat the limitation where a distant section depends
on it.

### Do not convert robustness to controls into identification

A coefficient that changes little after controls are added shows only that the
included controls do not absorb it. It does not show that omitted borrower risk,
balance-sheet information, or selection is absent. Report whether the controls
explain meaningful variation and describe the conclusion at that scope.

Prefer:

> The estimate changes little when the observed balance-sheet controls enter.

Do not write:

> Whatever the bank responds to is not on the balance sheet.

Order specifications from parsimonious to saturated, so the reader sees how the
estimate moves as controls enter.

### Report precision without threshold chasing

Do not write `just short of significance`, `marginally significant`, `nearly
significant`, or equivalent proximity-to-threshold language. Do not upgrade a
directional estimate because its p-value is near 0.05.

- For a precise estimate, give the magnitude, economic benchmark, and the
  relevant uncertainty statement.
- For a directional but imprecise estimate, give its direction, standard error
  or interval in the table, and an economically meaningful bound in the prose.
- For a precise zero, state what magnitudes the interval rules out, and whether
  the design could have detected an effect of the size the mechanism predicts.
- For an imprecise estimate, say that the design leaves economically relevant
  values open. Do not call it "no effect".

Full test statistics belong in tables or footnotes, not parenthetical strings in
running prose.

### Benchmark headline magnitudes

Translate every headline estimate into something the reader can scale: euros on
a stated loan, a share of the outcome mean, a change relative to an established
gap, or another quantity already on the page. A coefficient the reader cannot
scale is not yet a result.

### State the interpretation after the estimate

Use this order: prediction or mechanism in words; economic magnitude; table or
figure reference in an active sentence; interpretation; and the material
limitation. Do not lead with estimation mechanics unless the method is itself
the result.

## Section and paragraph flow

Major body sections usually open with a short bridge from the previous result,
the question now being answered, and a sentence explaining the order of the
evidence. Use this pattern when the reader has crossed to a new empirical
question. Do not apply it mechanically to every appendix subsection or short
diagnostic. Upstream's broad-to-concrete opening is for the introduction only.

Long sections need descriptive subsections. A flat section longer than roughly
150 lines is a warning that distinct questions have been combined.

Read consecutive paragraphs in pairs and name the logical join. If there is no
join, reorder, add the missing reasoning, or cut one paragraph. A smooth
transition cannot repair a gap in the argument.

## Hard rules

1. Do not use em dashes or a spaced ` -- ` as sentence separators. LaTeX `--`
   remains valid for ranges, page ranges, compound names, and intervals.
2. Do not use `\emph{}`, `\textit{}`, or `\textbf{}` for manuscript emphasis or
   run-in labels. Genuine titles and foreign terms are the exception.
3. Do not join two independent clauses with a colon. Use colons only for a
   genuine list, displayed equation, or label.
4. Avoid semicolons except when separating complex items in a genuine list.
5. Do not put bracketed test statistics in running prose.
6. Do not quote a number unless it traces to a current generated artifact or
   rendered table. A passing renderer, manifest, or assertion proves only what it
   checks; when a producer changed, reconcile its regenerated output before
   quoting it. Never invent, interpolate, or hand-adjust a result.
7. Do not use near-significance language.
8. Observe the project's disclosure rules. Where a project restricts what may
   enter prose or a prompt, that restriction binds absolutely.

## Banned habits

Remove these patterns rather than finding synonyms for them:

- `informative null` without a concrete bound;
- `seen from another angle`, `viewed through this lens`, `almost by
  construction`, `best read as`, and `is best understood as`;
- `the clean contribution`, `the sharpest statement`, `at the heart of`, and
  `the resolution lies in`;
- sentence-initial `Notably`, `Importantly`, `Overall`, `Strikingly`, or
  `Interestingly` when the word merely instructs the reader how to react;
- repeated `not X but Y` pivots, antithesis, chiasmus, and three-beat cadence;
- mechanical `First ... Second ... Third ...` scaffolding for findings, and
  `(i)...(ii)...(iii)` outside genuinely enumerable lists. Removing the
  scaffolding does not license a run of bare declaratives in its place; a list of
  findings still needs the logic that relates them;
- performative labels such as `I call this the X puzzle`;
- `It is important to note`, `It is worth noting`, and `In other words`;
- `just short of`, `marginally significant`, and other near-significance
  formulations;
- conversational shorthand standing in for a quantity, sample, or estimator;
- corporate jargon: `leverage` as a verb, `ecosystem`, `paradigm shift`;
- emojis.

## What a rewrite may change

A prose rewrite may change sentence structure, paragraph order within a section,
section openers, transition logic, emphasis, caveat placement, table notes,
citation positioning, and the location of secondary material.

It may not silently change quantitative results, identification assumptions, the
strength of claims, table or figure content, or disclosure statements. When a
review finding requires one of those changes, record it as a research change,
update the producing artifact first, and then reconcile the manuscript.

## Finish the task

For a local edit, read the changed passage with the paragraphs before and after
it. For a substantial or manuscript-wide edit, complete
[references/self-check.md](references/self-check.md).

Confirm that:

- the main claim is easier to find than its robustness checks;
- each paragraph has one primary payload;
- empirical threats are stated neutrally rather than as imagined objections;
- audit metadata is outside the running argument;
- all claims match identification and precision;
- all numbers trace to current generated outputs; and
- no withdrawn claim has silently returned.
