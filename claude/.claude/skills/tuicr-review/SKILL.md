---
name: tuicr-review
description: "Use when the user wants review comments written or answered, and when the user has tuicr open. tuicr is the review TUI that exports: it persists inline comments and copies the whole review out. hunk can annotate a live session but has no export path, so its comments cannot leave it. Prefer tuicr whenever a comment must survive the session or be copied out. tuicr works on any file, so this covers LaTeX manuscripts as well as code. If the user says only \"the review TUI\", ask which one before running any command."
---

# tuicr Review

tuicr is an interactive code review TUI. The TUI belongs to the user. Never run
`tuicr`, `tuicr tui`, `tuicr -w`, or `tuicr --file` yourself. Those block on a
terminal you do not have. Use the `tuicr review` subcommands instead. They read
and write the same persisted session the user has open.

If `tuicr review list` returns `[]`, no session exists. Ask the user to open one.

## The two directions

This skill exists because tuicr carries review comments both ways.

- **User to you.** The user comments on lines, then asks you to act on them.
  Read them with `tuicr review comments`.
- **You to user.** You leave inline comments the user reads in the TUI next to
  the text. Write them with `tuicr review add`.

Always pass `--username`. Without it your comments are stamped `user` and the
user cannot tell them from their own.

```bash
--username "Claude Opus 5"
```

## Find the session

```bash
tuicr review list --repo .    # sessions for this checkout
tuicr review list --all       # every persisted session
```

Each entry carries a `slug` and a `path`. Both work as `--session`. Prefer the
`path`, because a slug needs `--repo` to resolve and a path does not.

A slug looks like `myrepo@abc1234/worktree` for a diff review, or
`myrepo@~file/worktree/file` for a plain-file review opened with `--file`.

## Read the user's comments

```bash
tuicr review comments --session "<path-or-slug>"
```

Returns JSON. Each comment carries `location` (`paper.tex:42`), `path`,
`start_line`, `end_line`, `side`, `comment_type`, `lifecycle_state`, and
`content`.

Work the list in file and line order. Read the surrounding text before you act
on any single comment. A comment on line 42 often refers to a claim made on
line 30.

## Write a comment

```bash
# One line
tuicr review add --session "<path>" \
  --target-file paper.tex --line 42 \
  --type question --username "Claude Opus 5" \
  "Which standard errors support this significance claim?"

# A range
tuicr review add --session "<path>" \
  --target-file R/04_estimate.R --line 120 --end-line 134 \
  --type bug --username "Claude Opus 5" "..."

# The whole file: omit --line
tuicr review add --session "<path>" --target-file paper.tex --type todo ...

# The whole review: omit --target-file too
tuicr review add --session "<path>" --type praise ...
```

`--side old` comments the pre-change side of a diff. The default is `new`.

For many comments at once, pass `--input -` and pipe one JSON payload rather
than calling the command in a loop.

## Comment types

These come from `comment_types` in `~/.config/tuicr/config.toml`. Use them.
An untyped comment carries no prefix and the user cannot triage it.

| Type | Use it for |
|---|---|
| `bug` | Wrong behaviour, or a wrong claim in a paper. Blocks. |
| `nit` | Style, naming, or wording. Optional. |
| `question` | You need the user to explain a choice or supply evidence. |
| `todo` | Follow-up work. Not a blocker for this change. |
| `praise` | Keep this. Do not undo it in a later pass. |

## Reviewing a research paper

tuicr needs no VCS in `--file` mode, so the user can open a `.tex` manuscript
directly. Nothing changes on your side: the file path is the `--target-file`
and the line is the line in the `.tex` source.

Read the compiled argument, not the markup. Useful comment targets:

- A claim with no citation and no table reference.
- A number in the prose that disagrees with the table it points at.
- A hedge that hides a result, or a causal verb the identification cannot carry.
- A symbol used before it is defined, or defined twice.

Do not comment on LaTeX style, spacing, or macro choice unless the user asks.

## Related

`hunk-review` is the other half. hunk shows a changeset and cannot export.
tuicr comments on it and can. If the user wants to read a diff, point them at
hunk. If they want to leave or receive comments, use this skill.
