---
description: Review the current changes for actionable problems
argument-hint: "[focus]"
---
Review the current repository changes. Inspect `git status`, relevant diffs, and surrounding code.

Focus on correctness, regressions, security, edge cases, and missing tests. ${ARGUMENTS:-Prioritize issues that could cause incorrect behavior.}

Do not modify files. Report findings in severity order with exact file and line references. If there are no actionable findings, say so explicitly and mention any checks you could not run.
