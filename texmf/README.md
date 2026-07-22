# Jambro Beamer theme (vendored)

Third-party LaTeX theme, not authored here. Stowed into `TEXMFHOME`
(`~/Library/texmf`) so `\usetheme{jambro}` resolves from any directory without
copying the `.sty` into each presentation.

- Upstream: https://github.com/ambropo/JambroBeamerTheme
- Author: Ambrogio Cesa-Bianchi
- License: GPL-3.0
- Vendored version: `v1.3-dev` (`\ProvidesPackage` date 2026/03/26)
- Vendored from commit: `bc52600d9f9096a3b6f4e7afb55b114c087c7b9b`
- Vendored on: 2026-07-22

Only `beamerthemejambro.sty` is vendored. The upstream repo also ships
`Demo.tex` / `Demo.pdf`, which are worth reading for the annotation macros but
are not needed at build time.

## Updating

Fetch the current upstream file, then record the new commit and version above:

```bash
cd ~/dotfiles
gh api "repos/ambropo/JambroBeamerTheme/contents/beamerthemejambro.sty" --jq '.content' \
  | base64 -d > texmf/Library/texmf/tex/latex/jambro/beamerthemejambro.sty
gh api "repos/ambropo/JambroBeamerTheme/commits/HEAD" --jq '.sha'
```

No `texhash` is needed: `TEXMFHOME` is scanned directly rather than through an
`ls-R` index. Confirm the result with `kpsewhich beamerthemejambro.sty`, which
should print a path under `~/Library/texmf`.

Usage notes for writing slides live in the `beamer-presentation` skill
(`claude/.claude/skills/beamer-presentation/SKILL.md`).
