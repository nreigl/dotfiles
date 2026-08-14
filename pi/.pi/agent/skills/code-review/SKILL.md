---
name: code-review
description: Review code changes for correctness, regressions, security, and missing tests. Use when the user asks to review a diff, pull request, patch, or implementation without requesting edits.
---

# Code Review

1. Read repository instructions and inspect `git status`.
2. Review the relevant diff and enough surrounding code to understand behavior.
3. Trace changed inputs, outputs, error paths, and state transitions.
4. Run focused checks when they are safe and useful; do not modify files.
5. Report only actionable findings, ordered by severity, with exact file and line references.
6. Explain the failure scenario and a concrete remedy for each finding.
7. If no findings remain, say so explicitly and list anything not verified.

Do not praise, restate the diff, or flag style preferences unless they create a concrete maintenance or correctness risk.
