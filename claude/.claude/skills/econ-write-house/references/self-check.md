# Manuscript self-check

Complete this check before declaring a substantial rewrite ready to circulate.
For a local edit, apply the relevant items to the changed passage and its joins.

## 1. Argument and evidence hierarchy

Write down, in one sentence each:

1. the central question;
2. the paper's answer;
3. the mechanism;
4. the empirical strategy; and
5. the contribution.

Then classify every main-text exhibit as headline evidence, supporting evidence,
qualification, diagnostic, or robustness. Confirm that narrative space follows
that order. Move or cut material that cannot be tied to the five sentences.

## 2. Section sequence

Read every section and subsection opener in sequence, without the body. They
should form a coherent account of the argument. A major section should tell the
reader why the preceding result creates the next question. Do not require a
formal bridge-question-plan opening for every short appendix subsection.

## 3. Paragraph payload

Read only the first sentence of every paragraph. Each should state the
paragraph's primary payload rather than announce that a result is coming.

Then flag any paragraph that contains more than one of the following:

- a new sample or estimator;
- two or more independent results;
- several robustness variants;
- an objection and rebuttal;
- replication metadata; and
- a mechanism conclusion.

Split or relocate overloaded material. Do not treat a transition as a repair.

## 4. Referee-response voice

Search for imagined-adversary language and read every hit in context:

```text
rg -in "obvious (worry|objection)|harder (worry|objection)|what survives|closes the remaining distance|answers the objection|rules out the objection" <paper>.tex
```

Replace the rhetorical frame with the empirical threat, its possible bias, the
test, and the remaining limitation.

## 5. Audit-trail leakage

Locate artifact and implementation references in running prose:

```text
rg -n "output/|scripts/|\.csv|cleared table|regenerated|producer" <paper>.tex
```

Keep substantive references to replication material in comments, concise notes,
or a reproducibility appendix. Remove filenames and implementation history from
the economic argument unless the artifact identity is itself necessary.

## 6. Claims and precision

For every headline result, ask:

- Is the verb causal or associational at the level the design supports?
- Is the economic magnitude benchmarked?
- Is the uncertainty described without threshold chasing?
- Does a null state the economically meaningful bound?
- Does a control exercise say only what the included controls establish?
- Is a material limitation adjacent to the claim it qualifies?

Search explicitly for near-significance language:

```text
rg -in "just short|marginally significant|nearly significant|almost significant|approaches conventional significance|close to the 5%" <paper>.tex
```

Replace each hit with magnitude, uncertainty, and an economically meaningful
bound or a direct statement of imprecision.

## 7. Front matter

Restate every headline sentence in the abstract, non-technical summary,
introduction, and conclusion without using the paper's private vocabulary. If
that is difficult, replace the label with what happens to the economic object.

Confirm that the abstract is short, the non-technical summary is intelligible
without econometrics, and the conclusion introduces no new result.

## 8. Logical joins

Read consecutive paragraphs in pairs and name the join: `because`, `however`,
`therefore`, `by contrast`, or `to test this`. If no relation is apparent,
reorder, supply missing reasoning, or cut. Do not hide a gap with a generic
transition.

## 9. Register

Search for private labels, vivid verbs, and conversational shorthand:

```text
rg -in "\b(arbiter|horse race|estimator bridge|anchor fact|fired|bites?|rides?|rode|ratchets?|concede|part(s)? company|dormant|speaks?|reveals?|arbitrates?|judges?)\b" <paper>.tex
```

Read every hit. Terms of art such as pass-through and channel are legitimate;
private labels and personified data are not.

Check for pointer sentences and compressed definite labels. A sentence should
state content that a reader can restate, not promise or point at content located
elsewhere.

## 10. Hard-rule scan

Run these locators and read every hit:

```text
rg -n -- "---" <paper>.tex
rg -n " -- " <paper>.tex
rg -n "\\emph\{|\\textit\{|\\textbf\{" <paper>.tex tables/*.tex
rg -n "\(\$?[tp]\s*=|\(s\.e\." <paper>.tex
rg -in "informative null|seen from another angle|almost by construction|best read as|it is worth noting|in other words|at the heart of|taken together, these" <paper>.tex
```

Ranges and compound names may legitimately contain `--`. Genuine titles may
require italics. Fix generated-table violations in the renderer.

Read separately for colon-joined independent clauses and unnecessary
semicolons; those require judgment rather than a reliable pattern.

## 11. Numbers and citations

Trace every new or changed number to a current cleared artifact or rendered
table. If a producer changed, reconcile its regenerated output with the public
file before trusting the manuscript.

Run the paper's numerical assertions, but do not treat their passing as proof
that every quoted number or committed output is current.

Check that every external factual claim has an active citation, every key exists
in the paper-local bibliography, and the final build contains no undefined
references or citations.

## 12. Withdrawn claims and final read

Before restoring a missing claim, inspect its git history. No automated guard
now prevents a deliberately withdrawn claim from returning.

Read the revised manuscript in rendered form. Check page turns, orphaned
sentences, table placement, note density, and whether the headline evidence is
visually and narratively easier to find than its robustness checks.

## 13. Mechanical lint

Run these against the file you edited, as the last step before you declare a
draft done. They govern **prose**. A hit inside a `%` comment line or a preamble
macro definition is a false positive: read every hit before you act, and never
edit a comment to satisfy a lint.

```
rg -n -- '---' <file>.tex
rg -n ' -- ' <file>.tex
rg -n -i 'taken together|at the heart of|it is worth noting|in other words|the resolution lies in|it is important to note|notably,|importantly,' <file>.tex
rg -n '\\emph\{|\\textit\{|\\textbf\{' <file>.tex
```

The first catches an em dash used as a separator. A numeric range such as
`2022--23` has only two hyphens and does not match. The second catches a spaced
en dash used as a pause, and leaves `pp.~14--16` and `Chaney--Sraer--Thesmar`
alone.

Then confirm that every number in the draft traces to an estimation output, not
to memory.
