# Provenance

This skill is a verbatim copy of `skills/productivity/teach/` from
https://github.com/mattpocock/skills (MIT license).

- Commit: ad5400b930b297b0c0cb231ff1ffe42a7da666aa
- Commit date: 2026-10-07
- Installed: 2026-11-07

Do NOT edit the files in this directory. Keep this copy clean, so that an
upstream update is a plain copy.

## Tracked deviations

- `agents/openai.yaml` is not copied. It is Codex metadata, and Claude Code
  does not read it.

Nothing else deviates.

To update:

    git clone --depth 1 https://github.com/mattpocock/skills /tmp/mps
    cp /tmp/mps/skills/productivity/teach/*.md ~/dotfiles/claude/.claude/skills/teach/
    cd ~/dotfiles && ./scripts/stow-all.sh
