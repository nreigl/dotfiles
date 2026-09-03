# Voice and craft

Read this reference before a substantial rewrite, a front-matter rewrite, or
any task concerning voice, flow, paragraph structure, or exposition. The core
rules in `../SKILL.md` take precedence.

## Contents

1. Target voice
2. Introductions and non-technical summaries
3. Body-section openings
4. Paragraph architecture
5. Sentence craft
6. Reporting results
7. Exposing assumptions and limitations
8. Contribution and policy register
9. Literal register
10. Worked repairs

## 1. Target voice

The register is an experienced central-bank colleague explaining an empirical
result at a whiteboard. Put intuition and the plain-words reason before
notation. Gloss every technical term on first use. Use a concrete example before
the general case when the mechanism is not immediately visible. State material
limitations early and directly.

The tone is formal without being ornate. It is neither compressed seminar
shorthand nor a bureaucratic memo. The reader should understand why an estimate
answers the paper's question without having to reconstruct the design.

For a substantial rewrite, read one or two nearby examples from the reference
corpus, starting with Reigl (2026), Eesti Pank Working Paper 3/2026:

- Reigl (2026): first-person voice, intuition before formalism, explicit
  limitations, and contributions framed as clarification.
- Degryse, De Jonghe, Laeven and Zhao (2025): accessible exposition and
  mechanism-oriented implications.
- Caglio, Darst and Kalemli-Ozcan (2024): identification assumptions defended
  directly and a two-sided mechanism stated before estimates.
- Horan, Jarmulska and Ryan (2023): magnitude-first reporting and careful
  qualification.
- Anderson, Bahaj, Chavaz, Foulis and Pinter (2018): monetary benchmarks and
  falsification logic.
- Altavilla et al. (2019): economical descriptions of impulse-response shapes.

Imitate the explanatory moves, not signature phrases.

## 2. Introductions and non-technical summaries

Open the introduction with brief broad framing and reach a concrete fact or
contrast within a few sentences. Do not open with a generic statement that a
literature is large, important, or growing.

The introduction should make five things visible without requiring the reader
to infer them:

1. the practical or economic problem;
2. the precise question;
3. the paper's answer;
4. the design that supports that answer; and
5. the contribution relative to what was previously known.

The non-technical summary is genuine plain language. Explain what happens to a
firm, lender, household, price, or quantity. Do not merely replace econometric
terms with abstract nouns such as `margin`, `gradient`, or `channel`.

Keep the abstract short, normally below about 180 words. It has no citations,
no parenthetical test statistics, and only a few headline magnitudes in running
text.

## 3. Body-section openings

A major body section often benefits from three moves:

1. **Bridge:** restate the preceding result in a clause.
2. **Question:** say what the section now needs to establish.
3. **Plan:** give the order of the main evidence.

Use this architecture when the reader has crossed to a new empirical question.
Do not repeat it mechanically for every appendix subsection, short robustness
check, or data diagnostic.

Bad:

> One feature of this episode shapes everything in this section. The answer can
> be stated up front.

Better:

> The previous section showed that loans backed by real estate carry lower rates
> than loans backed by residual protection. This section asks whether the asset
> pledged also changes how higher policy rates reach firms. I first document the
> repricing of existing loans and then examine rates and quantities on new loans.

The better version is longer because it contains the bridge, question, and plan.
It does not announce that content is coming.

## 4. Paragraph architecture

The first sentence states the paragraph's primary empirical payload. Follow it
with the evidence, interpretation, and one material qualification. Split the
paragraph when another result begins doing independent work.

An overloaded paragraph often contains several of these at once:

- a new sample definition;
- a new estimator or fixed-effect menu;
- more than one headline coefficient;
- several robustness variants;
- an imagined objection and rebuttal;
- a replication filename or implementation date; and
- a conclusion about the mechanism.

Do not repair this by adding transitions. Decide which item is the paragraph's
claim, move the others to separate paragraphs or notes, and give robustness
material space in proportion to its importance.

Read first sentences in sequence. They should form a compressed version of the
section's argument. If they form a list of tables, the section is a catalogue.

## 5. Sentence craft

Use varied sentence length. A short sentence may state a headline finding. A
longer sentence may carry the reason or one qualification. Split on logical
load and nesting depth, not on an arbitrary word count.

A sentence is overloaded when it asks the reader to retain several of the
following before reaching the main verb: a sample restriction, estimator,
comparison group, time window, numerical result, inferential result, and caveat.
Reorder or divide it.

State logical joins. `Because`, `although`, `however`, `consequently`, `by
contrast`, and `therefore` are useful when they identify the relationship
between two claims. Adverbs that merely tell the reader that a result is
important are not useful.

Avoid runs of short declaratives with no connective. They read like bullets
with full stops:

> Collateral type explains little. Weighting changes nothing. Composition is
> not the story. The gradient survives.

Repair:

> Weighting each loan by its euro amount leaves the collateral coefficients
> close to their unweighted values, which indicates that a few large exposures
> do not account for the pricing differences.

The repair states the evidence and inference together. It does not preserve
each original sentence merely for rhythm.

## 6. Reporting results

State the prediction before the estimate when theory gives one. Then report the
economic magnitude, point to the relevant table or figure in an active sentence,
interpret the estimate, and state the material limitation.

Bad:

> Following estimation of equation (2), the results are presented in Table 4.

Better:

> If collateral values constrain lending, banks should reduce credit most where
> property secures the loan. Column 3 of Table 4 reports whether that relative
> contraction occurs.

Anchor a coefficient to a quantity the reader can scale:

> Within continuing relationships, the rate on weak-collateral loans rose about
> 60 basis points more, equivalent to roughly EUR 600 a year on a EUR 100,000
> loan.

Do not write a coefficient dump. The table carries the complete estimate,
standard error, p-value, sample size, and fixed effects. The prose explains the
economically important magnitude and what it establishes.

### Null and imprecise estimates

For a precise null, state the excluded magnitude and why it matters:

> The estimated markdown is close to zero, and the confidence interval excludes
> declines larger than about 3%. The design therefore rules out the fall in
> collateral values required by the proposed mechanism.

For an imprecise estimate, do not use a significance threshold as narrative:

> The point estimate is positive, but its standard error is of similar size. The
> interval leaves moderate positive and negative effects open, so I treat the
> direction as suggestive rather than the magnitude as established.

Never write `just short of the 5% level`, `marginally significant`, `almost
significant`, or `approaches conventional significance`.

## 7. Exposing assumptions and limitations

State an identification assumption in economic terms. Name what would violate
it and the evidence used to assess it.

- For event studies, explain why untreated trends should have been parallel and
  point to the plotted pre-period.
- For local projections, state the shock, horizon, outcome transformation,
  labels or exposures held fixed, and identifying comparison.
- For instrumental variables, discuss institutional exclusion and first-stage
  strength. Do not let a statistic stand in for the exclusion argument.
- With few clusters, state the cluster count and why the chosen small-sample or
  wild-bootstrap inference is appropriate.
- For subgroup analysis, state whether the split was determined before results
  were seen and how many related cuts were run.

Limitations should be early and proportionate. Put the decisive identification
limit near the claim it qualifies. Do not repeat every secondary caveat in the
main text; move implementation-specific qualifications to the relevant note or
appendix.

### Controls do not exhaust omitted information

Bad:

> Whatever the bank reacts to is not on the balance sheet.

Better:

> Adding the observed balance-sheet controls changes the estimate little. Those
> variables therefore do not account for the pricing difference, although the
> regression cannot rule out unobserved borrower information.

Also report whether the controls increase explanatory power. Coefficient
stability is weak evidence against omitted-variable bias when the added controls
explain little of the outcome.

## 8. Contribution and policy register

Frame the contribution as measuring, clarifying, organizing, or distinguishing
existing mechanisms. Avoid discovery rhetoric and claims of decisive closure.

Useful forms include:

- `This exercise clarifies ...`
- `The estimates distinguish ...`
- `The paper measures ...`
- `The evidence narrows ... but does not identify ...`

Policy discussion follows from the identified evidence. Separate what the paper
establishes, what it suggests, and what a policymaker might reasonably infer.
Do not attach a policy recommendation to a robustness corner or an
associational coefficient as though it were a causal estimate.

## 9. Literal register

Use literal economic verbs:

| Instead of | Write |
|---|---|
| the link fired | the step occurred |
| bites hardest | matters most |
| loans rode the benchmark | loans repriced with the benchmark |
| values ratchet upward | values adjust upward but rarely downward |
| the two ends part company | the estimates diverge |
| the classes fall silent | the class indicators are jointly insignificant |
| the table closes that door | the estimate rules out that magnitude |
| the first 10% does the damage | the first 10% accounts for most of the decline |
| at the cheap end | among the lowest-rate loans |
| the imprecise half | the imprecisely estimated specifications |

Do not replace one vivid metaphor with another. State the quantity or
relationship the phrase was standing in for.

## 10. Worked repairs

### Jargon used before it is defined

Bad:

> Loans backed only by residual protection are at the expensive end of the
> secured market.

Better:

> Some loans are backed only by residual protection, the register's catch-all
> class for protection that is not recorded under a more specific asset type.
> These loans carry higher rates than loans backed by real estate or machinery.

### Bias asserted rather than explained

Bad:

> Conditioning on the rate makes collateral type mechanically informative, so
> a vanishing coefficient is what a collider would produce.

Better:

> The bank chooses the rate and collateral requirement together rather than
> setting the rate first. Conditioning on that jointly determined rate can
> therefore create a relationship between collateral and the borrower risk the
> bank has already priced, even when no such relationship existed beforehand.

### Announcement instead of a claim

Bad:

> The anchor fact needs no causal design.

Better:

> The average rate on the existing corporate loan book rose by 421 basis points
> between 2021Q4 and 2023Q4. Establishing that repricing requires measurement,
> not a causal design.

### Private label

Bad:

> I call the two-year outcome test the arbiter.

Better:

> I use distress during the two years after origination to assess whether the
> higher rate on residual protection reflects realized credit risk.

### Dense mechanics

Bad:

> Firm-bank-time effects absorb selection. The discount is stable. Each bound
> that result.

Better:

> Firm-bank-time fixed effects compare loans that the same lender extends to the
> same borrower at the same time, removing borrower and lender characteristics
> that do not vary within that cell. The collateral discount changes little in
> this comparison. The bounds in the next subsection show how much selection on
> remaining unobservables could still alter it.

### Referee-response cadence

Bad:

> The harder objection is that borrower composition changed. That objection does
> not survive the frozen sample.

Better:

> Borrower composition may change over the cycle and could therefore generate
> the estimated difference. Restricting the sample to relationships observed
> before the cycle leaves the estimate close to its baseline value, although the
> smaller sample widens the interval.

### Audit trail in running prose

Bad:

> The result is reproduced in `CDKO_X7_model.csv`, which the monthly switch
> regenerated after the entry-guard correction.

Better:

> The result is unchanged when the entry guard is imposed.

Record the filename and implementation history in a source comment, table note,
or replication appendix.
