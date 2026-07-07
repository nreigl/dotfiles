---
description: Audit this research codebase for integrity risks (hardcoded results, stale outputs, spec drift, orphans, placeholder data, paper-code inconsistencies)
argument-hint: [optional: specific phase or directory to focus on]
---

Launch the `research-code-auditor` agent on the current repository. That agent owns the full 6-phase audit protocol (project discovery, hardcoded results, stale outputs, spec governance, orphans, placeholder data, paper-code consistency) and the report format.

If `$ARGUMENTS` names a specific concern (e.g. "stale outputs", "phase 3", a subdirectory), pass it to the agent as the audit focus; otherwise request the full sweep.

When the agent returns, relay the report verbatim, leading with the critical-finding count and the top remediation priorities.
