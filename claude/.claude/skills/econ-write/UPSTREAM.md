# Provenance

This skill is a verbatim copy of `skills/econ-write/` from
https://github.com/hanlulong/econ-writing-skill

- Commit: f2bf7a22c5e3b37921a5e6c73bd1fb380a5e00e8
- Commit date: 2026-07-19
- Installed: 2026-08-20

Do NOT edit the files in this directory. House deviations live in the
`econ-write-house` skill, which overrides named lines here. Keeping this copy
clean is what makes a future `git pull` from upstream a clean update.

## Tracked deviations

One exception, kept deliberately:

- `SKILL.md` frontmatter `description:` is rewritten. The upstream text reads
  "USE THIS SKILL whenever the user writes, edits, reviews..." and claims
  LaTeX, presentations and audits as well. Routing tests showed it firing on a
  git commit message and claiming the jobs of the LaTeX, slide, and
  referee-report skills alongside its own. The
  replacement narrows the trigger to paper sections and adds explicit skip
  conditions. The body is untouched.

  After an upstream update, re-apply this one edit. Nothing else in this
  directory deviates.

To update:

    git clone --depth 1 https://github.com/hanlulong/econ-writing-skill /tmp/ews
    cp /tmp/ews/skills/econ-write/*.md ~/.claude/skills/econ-write/

Then re-read `econ-write-house` and confirm its line-number citations still
point at the text they claim to override.
