# CLAUDE.md

## Commands

Run `./scripts/doctor.sh` after any structural change to the repo. It is
read-only and exits 1 if any check fails. `--quiet` prints problems only.
`SKIP_CHECKS=name1,name2` mutes named checks. `scripts/update.sh` runs it at
the end and never fails the update because of it.

**Writing scripts in this repo: use `command rm`, `command cp`, `command mv`.**
`aliases.zsh` maps all three to their `-i` form. In a non-interactive shell the
prompt gets no answer, so the write is skipped and the command still exits 0.
The failure is silent, and it will not appear in the exit status.

### LaTeX
The VimTeX and texlab gotchas live in `nvim/.config/nvim/CLAUDE.md`. Read that
file before you edit `latex/.latexmkrc` or `nvim/.config/nvim/lua/plugins/vimtex.lua`.

**Do not add `-file-line-error`** to `latex/.latexmkrc` or to
`vimtex_compiler_latexmk.options`. The `pplatex` quickfix parser then reports
zero errors and prints no warning.

The Zotero and biblatex conventions for research projects are in the
`latex-bibliography` skill (`claude/.claude/skills/latex-bibliography/`).

## Code Architecture

### Stow Package Structure
Each directory at the root level is a "stow package" containing configs:
- `herdr/` - Terminal multiplexer for coding agents (→ `~/.config/herdr/`)
- `hunk/` - Diff viewer for agent-authored changesets (→ `~/.config/hunk/`). Read-only: hunk has no export path. `theme` is the only theme key it reads
- `tuicr/` - Code review TUI (→ `~/.config/tuicr/`). The write half that hunk lacks: comment on lines, then copy the review with `y` or `:clip`
- `tuios/` - Terminal multiplexer and window manager, on trial (→ `~/.config/tuios/`). Only `config.toml` is stowed. tuios writes `themes/` next to it, so `~/.config/tuios/` must be a real directory before stow runs. `install.sh` creates it. The key gotchas are in `.claude/rules/tuios.md`
- `yazi/` - Terminal file manager (→ `~/.config/yazi/`). Keep `yazi.toml` minimal: yazi merges it over built-in presets, and copying the full default config breaks on every release
- `superfile/` - Second terminal file manager, on trial (→ `~/.config/superfile/`). Only `config.toml` is stowed. Keep it minimal and keep `ignore_missing_fields = true`, which silences the warning about absent fields. `hotkeys.toml` and `theme/` stay unstowed because superfile rewrites them on upgrade
- `opencode/` - Opencode coding agent config (→ `~/.config/opencode/`). Only `opencode.json`, `tui.json`, and `AGENTS.md` are stowed. Opencode writes auth and service files next to them, and `--no-folding` keeps those out of the repo. `AGENTS.md` must exist: without it, opencode falls back to `~/.claude/CLAUDE.md`. The CLI is `brew "opencode"` and the Neovim side is `nvim/.config/nvim/lua/plugins/opencode.lua`
- `latex/` - Global latexmk config (→ `~/.latexmkrc`). Load-bearing for the LaTeX setup: it selects the engine (`$pdf_mode = 4`, lualatex) and the build directory (`$out_dir = 'build'`) for VimTeX, latexmk, and texlab at once. Do not move these two settings into `vimtex.lua` — texlab reads only this file. Also holds the biber setting and the glossaries dependency
- `zsh/` - Shell config (→ `~/`). `.zshrc` sources four files from `.config/zsh/`: `aliases.zsh`, `functions.zsh`, `fzf-functions.zsh`, `cheat.zsh`. New aliases and shell functions go in one of the first three. Nothing else in this package is sourced. `cheat.zsh` holds the shortcut popup only. Its `# cheat:` comment format is in `.claude/rules/cheat-popup.md`
- `git/` - Global git config and gitignore (→ `~/.config/git/`). The identity lives in `~/.gitconfig`, an untracked real file that is not a symlink. Git reads it after the XDG file, so its keys win, and `git config --global` writes into it. If `~/.gitconfig` is missing, `--global` writes land in the tracked file. `install.sh` creates it and refuses to continue that step if it is a symlink. `doctor.sh` warns if it is missing or a symlink
- `raycast/` - **Not stowed.** Raycast keeps its settings in an encrypted SQLite database, so hotkeys and extension settings cannot live in this repository. The package holds only `scripts/` (script commands) and `install-extensions.sh`. Point Raycast at the scripts through Settings → Extensions → + → Add Script Directory. See `raycast/README.md`

### Key Configuration Files
- `scripts/stow-all.sh` - Links the stow packages (the `PACKAGES` array). `scripts/stow-remove.sh` holds an identical list — update both together. `scripts/doctor.sh` fails if the two lists drift apart or if a listed package is missing
- `mise/.config/mise/config.toml` - This is the only mise config

### Tool Stack
- **Terminal**: Ghostty (WezTerm removed 2026-08-14 — it drops Caps Lock→Escape key events on macOS)
- **Multiplexer**: herdr (agent multiplexer, tmux-parity keys); tmux still available via the `tm` alias; tuios on trial (leader Ctrl+A, tmux preset)
- **File manager**: yazi (`y` wrapper); superfile on trial (`sf` wrapper). Both cd the shell to the last directory on exit
- **Launcher**: Raycast (Alfred removed 2026-08-14 — the Powerpack came from a patched build, and a Homebrew update replaced it with the official one). Raycast free covers clipboard history, snippets, quicklinks, and script commands. It does not sync settings between machines
- **Screenshots**: Shottr (free for personal use, includes OCR and scrolling capture)
- **Window Management**: AeroSpace (`cask "aerospace"` in the Brewfile). Its config, `~/.config/aerospace/aerospace.toml`, is not in this repo. yabai and skhd were removed 2026-08-14 — neither was running, and `skhdrc` was almost entirely yabai commands

## Important Notes

### Tool Precedence
- **Python**: Always use UV, never pip/conda/pyenv
- **Node/Ruby/Go**: Use mise, not nvm/rbenv/gvm
- **Julia**: Use juliaup for version management
- **Shell**: ZSH with Zinit (not oh-my-zsh/prezto)

### Common Fixes
```bash
# Fix z function in Claude Code (if getting "bad pattern" error)
# z is defined near the end of zsh/.zshrc. ~/.zshrc.local is an empty
# placeholder for machine-local overrides and defines nothing.
unfunction z; source ~/dotfiles/zsh/.zshrc
```
