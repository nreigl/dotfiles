# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Modern dotfiles repository with state-of-the-art tooling for macOS development environment using GNU Stow for symlink management.

## Commands

### Essential Scripts
```bash
./scripts/install.sh      # Initial setup - installs Homebrew, tools, and stows dotfiles
./scripts/update.sh       # Update all tools (Homebrew, UV, Julia, mise, Neovim plugins, ZSH plugins)
./scripts/stow-all.sh     # Link all dotfile configurations
./scripts/stow-remove.sh  # Remove all symlinks
./scripts/doctor.sh       # Health check: stow drift, broken links, dead references
```

Run `./scripts/doctor.sh` after any structural change to the repo. It is
read-only and exits 1 if any check fails. `--quiet` prints problems only.
`SKIP_CHECKS=name1,name2` mutes named checks. `scripts/update.sh` runs it at
the end and never fails the update because of it.

Eleven checks: package-list parity, stow dry run, broken symlinks, git
tracking of linked files, required binaries and alias targets, referenced
repo paths and applications, references to removed tools, duplicate shell
functions and aliases, PATH accretion in `.zshrc`, Brewfile installation
state, and working-tree cleanliness.

**Writing scripts in this repo: use `command rm`, `command cp`, `command mv`.**
`aliases.zsh` maps all three to their `-i` form. In a non-interactive shell the
prompt gets no answer, so the write is skipped and the command still exits 0.
The failure is silent, and it will not appear in the exit status.

### Development Commands

#### Python (UV)
```bash
uv init myproject --python 3.12      # Create new project
uv add pandas numpy matplotlib        # Add dependencies
uv add --dev pytest ruff mypy        # Add dev dependencies
uv run python script.py              # Run Python with project dependencies
uv tool install <package>            # Install Python CLI tools globally
uv tool upgrade --all                # Update all UV tools
```

#### Julia
```bash
juliaup status                                          # Show installed Julia versions
julia -e 'using Pkg; Pkg.generate("MyProject")'        # Create new project
julia --project=. -e 'using Pkg; Pkg.add("DataFrames")'  # Add package to project
```

#### Version Management (mise)
```bash
mise list                  # List all installed tools
mise use node@20          # Install and set Node.js version
mise use ruby@3.2         # Install and set Ruby version
```

#### LaTeX in Neovim (VimTeX)

**Compilation & Viewing:**
- `\ll` - Start continuous compilation (latexmk with lualatex)
- `\lv` - View PDF in Skim (with sync)
- `\lk` - Stop compilation
- `\lc` - Clean auxiliary files
- `\lt` - Toggle table of contents
- `\le` - Show compilation errors

**Citation & Reference Completion:**
- Type `\cite{` and start typing → automatic bibliography completion
- Type `\ref{` → automatic label completion
- `<C-Space>` (insert mode) - Trigger VimTeX omni-completion manually
- Completion shows: `2025 Stefani, "Long-term debt and short-term rates"`

**Math snippets (autotriggered, math zone only):**
- `mk` opens inline math, `dm` opens display math. Both work in prose only
- Inside math: `ff`→`\frac{}{}`, `sq`→`\sqrt{}`, `x1`→`x_{1}`, `sr`/`cb`/`td` for powers, `xbar`→`\bar{x}` (also `hat`, `til`, `dot`, `vec`), `;a`→`\alpha` and the rest of the Greek alphabet, `==`/`<=`/`->`/`**` for relations, `sum`/`prod`/`int`/`lim`
- Every math trigger is guarded by `vimtex#syntax#in_mathzone()`, so two-letter triggers cannot fire in prose
- `vimtex_imaps_enabled = 0`, so VimTeX's own insert-mode maps do not compete with LuaSnip

**Settings:**
- Compiler: latexmk with lualatex (modern Unicode support)
- PDF viewer: Skim (forward/backward sync enabled)
- Build directory: `build/` (keeps project root clean)
- Completion: nvim-cmp with cmp-vimtex for intelligent suggestions

**Where the compiler settings live.** The engine and the build directory are set
in `latex/.latexmkrc` (`$pdf_mode = 4`, `$out_dir = 'build'`), **not** in
`nvim/.config/nvim/lua/plugins/vimtex.lua`. VimTeX reads that file and derives
the `-lualatex` flag from it, latexmk obeys it directly, and texlab resolves the
log and the PDF through it. If the engine or the output path is set in the
Neovim config instead, texlab keeps looking in the project root and loses its
log diagnostics and its forward search. Adding engine flags to
`vimtex_compiler_latexmk.options` is documented as wrong
(`:h g:vimtex_compiler_latexmk`).

**Do not add `-file-line-error`.** It is absent from `latex/.latexmkrc` and from
`vimtex_compiler_latexmk.options` on purpose. The quickfix parser is `pplatex`,
which reads the classic `! Undefined control sequence.` form. Against a log in
`file:line:` form it reports zero errors and prints no warning, so the quickfix
list goes silent on every compile error while appearing to work. VimTeX strips
the flag from its own latexmk options, but it cannot strip it from the engine
commands in `.latexmkrc`. `pplatex` itself is built from source into
`~/.local/bin` (not in Homebrew, needs cmake and the deprecated `pcre`), so it is
absent on a new machine. `vimtex.lua` falls back to `latexlog` when it is
missing.

**Division of labour.** VimTeX owns compilation, viewing, SyncTeX, the table of
contents, motions, and citation/label completion. texlab is LSP-only: rename,
go-to-definition, symbols, hover, chktex. Leave `texlab.build.onSave` and
`forwardSearchAfter` at `false`, or two latexmk processes race on the same aux
files. Warning filters are duplicated on purpose in `vimtex_quickfix_ignore_filters`
and `texlab.diagnostics.ignoredPatterns` — VimTeX uses Vim regex, texlab uses
Rust regex, so the two lists cannot be shared.

### Testing/Verification
```bash
# Verify key tools
uv --version
julia --version
mise --version
nvim --version
ruff --version
```

## Code Architecture

### Stow Package Structure
Each directory at the root level is a "stow package" containing configs:
- `ghostty/` - Terminal emulator (config symlinked to `~/.config/ghostty/`)
- `herdr/` - Terminal multiplexer for coding agents (→ `~/.config/herdr/`)
- `yazi/` - Terminal file manager (→ `~/.config/yazi/`). Keep `yazi.toml` minimal: yazi merges it over built-in presets, and copying the full default config breaks on every release
- `superfile/` - Second terminal file manager, on trial (→ `~/.config/superfile/`). Only `config.toml` is stowed. Keep it minimal and keep `ignore_missing_fields = true`, which silences the warning about absent fields. `hotkeys.toml` and `theme/` stay unstowed because superfile rewrites them on upgrade
- `nvim/` - Neovim/LazyVim config (→ `~/.config/nvim/`)
- `latex/` - Global latexmk config (→ `~/.latexmkrc`). Load-bearing for the LaTeX setup: it selects the engine (`$pdf_mode = 4`, lualatex) and the build directory (`$out_dir = 'build'`) for VimTeX, latexmk, and texlab at once. Do not move these two settings into `vimtex.lua` — texlab reads only this file. Also holds the biber setting and the glossaries dependency
- `zsh/` - Shell config (→ `~/`). `.zshrc` sources three files from `.config/zsh/`: `aliases.zsh`, `functions.zsh`, `fzf-functions.zsh`. New aliases and shell functions go in one of those three. Nothing else in this package is sourced
- `git/` - Global git config and gitignore (→ `~/`)
- `mise/` - Version manager config (→ `~/`)
- `tmux/` - Terminal multiplexer config (→ `~/`)
- `ssh/`, `aws/` - Security configs (→ `~/.ssh/`, `~/.aws/`)
- `raycast/` - **Not stowed.** Raycast keeps its settings in an encrypted SQLite database, so hotkeys and extension settings cannot live in this repository. The package holds only `scripts/` (script commands) and `install-extensions.sh`. Point Raycast at the scripts through Settings → Extensions → + → Add Script Directory. See `raycast/README.md`

### Key Configuration Files
- `Brewfile` - Homebrew package manifest (480+ packages)
- `scripts/install.sh` - Main installer (lines 1-198)
- `scripts/update.sh` - Update all tools (lines 1-158)
- `scripts/stow-all.sh` - Links 27 stow packages (the `PACKAGES` array). `scripts/stow-remove.sh` holds an identical list — update both together. `scripts/doctor.sh` fails if the two lists drift apart or if a listed package is missing
- `mise/.config/mise/config.toml` - Language versions (Node v22, Ruby, Go, Rust, Bun). This is the only mise config; the former root `mise.toml` duplicated the Node pin and was removed on 2026-08-18

### Tool Stack
- **Package Management**: Homebrew (system), UV (Python), Juliaup (Julia), mise (Node/Ruby/Go)
- **Shell**: ZSH + Zinit + Starship prompt
- **Editor**: Neovim with LazyVim distribution
- **Terminal**: Ghostty (WezTerm removed 2026-08-14 — it drops Caps Lock→Escape key events on macOS)
- **Multiplexer**: herdr (agent multiplexer, tmux-parity keys); tmux still available via the `tm` alias
- **File manager**: yazi (`y` wrapper); superfile on trial (`sf` wrapper). Both cd the shell to the last directory on exit
- **Launcher**: Raycast (Alfred removed 2026-08-14 — the Powerpack came from a patched build, and a Homebrew update replaced it with the official one). Raycast free covers clipboard history, snippets, quicklinks, and script commands. It does not sync settings between machines
- **Screenshots**: Shottr (free for personal use, includes OCR and scrolling capture)
- **Window Management**: none. yabai and skhd both removed 2026-08-14 — neither was running, and `skhdrc` was almost entirely yabai commands

## Important Notes

### Stow Behavior
- GNU Stow creates symlinks from home directory to this repo
- Running `stow <package>` links all files in `<package>/` to `~/`
- Subdirectories like `.config/` are preserved in the symlink structure
- Use `stow -n -v <package>` to preview what will be linked
- Conflicts occur when target files already exist - remove them first

### Tool Precedence
- **Python**: Always use UV, never pip/conda/pyenv
- **Node/Ruby/Go**: Use mise, not nvm/rbenv/gvm
- **Julia**: Use juliaup for version management
- **Shell**: ZSH with Zinit (not oh-my-zsh/prezto)

### Common Fixes
```bash
# UV not in PATH
source $HOME/.local/bin/env

# Mise tools not available
eval "$(mise activate zsh)"

# Neovim plugins issues
nvim --headless "+Lazy! sync" +qa

# ZSH plugin issues
zinit self-update && zinit update --all

# Stow conflicts (preview first)
stow -n -v <package>
stow --adopt <package>  # Careful: moves existing files into repo

# Fix z function in Claude Code (if getting "bad pattern" error)
unfunction z; source ~/dotfiles/zsh/.zshrc.local
# Note: Claude Code resets working directory after each command
# The z function works but directory changes don't persist in Claude Code
# Use absolute paths or cd commands within scripts instead
```

## LaTeX & BibTeX Workflow

### Bibliography Management with Zotero

**Setup:**
1. Install Better BibTeX for Zotero (https://github.com/retorquere/zotero-better-bibtex)
2. Configure citation key format: `[auth:lower][year]` (e.g., `stefani2025`)
3. Set up auto-export: Collection → Export → "Better BibLaTeX" → Keep updated

**Standard structure for research projects:**
```
project/
├── bib/
│   ├── master.bib        # Auto-exported from Zotero (all papers)
│   ├── core_papers.bib   # Hand-curated frequently cited papers
│   └── README.md         # Setup documentation
├── paper/
│   └── manuscript.tex
└── presentation/
    └── slides.tex
```

**LaTeX preamble (biblatex):**
```latex
\usepackage[
    backend=biber,
    style=authoryear-comp,
    sorting=nyt,
    maxbibnames=99,
    maxcitenames=2,
    giveninits=true,
    uniquename=false,
    uniquelist=false,
]{biblatex}

\addbibresource{../bib/master.bib}
\addbibresource{../bib/core_papers.bib}
```

**Citation commands:**
```latex
\textcite{stefani2025}      % Stefani and Mano (2025)
\parencite{stefani2025}     % (Stefani and Mano 2025)
\cite{stefani2025}          % Stefani and Mano 2025
```

**Compilation:**
```bash
latexmk -pdf manuscript.tex  # Automatically runs biber
# Or manually:
pdflatex manuscript.tex && biber manuscript && pdflatex manuscript.tex
```

### VimTeX Citation Completion

**In Neovim:**
1. Open .tex file with `\addbibresource{../bib/master.bib}`
2. Type `\cite{` and start typing author name
3. Completion automatically shows: `2025 Stefani, "Long-term debt..."`
4. Select with `<Tab>` or `<CR>`

**Completion sources (in order):**
1. `cmp-vimtex` - Bibliography citations, labels, commands
2. `luasnip` - LaTeX snippets
3. `buffer` - Words from current buffer
4. `path` - File paths

**Configuration:**
- Files: `nvim/.config/nvim/lua/plugins/vimtex.lua` and `tex-citations.lua`
- nvim-cmp enabled for .tex files only (not blink.cmp)
- Omni-completion fallback: `<C-Space>` in insert mode

### Troubleshooting LaTeX

**Citation not found:**
```bash
# Delete auxiliary files and recompile
rm build/*.{aux,bbl,bcf,blg,run.xml}
latexmk -pdf manuscript.tex
```

**Vimtex completion not working:**
```bash
# Restart LSP in Neovim
:LspRestart
# Or reload file
:edit
```

**Skim not syncing:**
- Check `\synctex=1` in vimtex compiler options (already configured)
- Ensure Skim is set as default PDF viewer
- Forward sync: `\lv` in vim
- Backward sync: Cmd+Shift+Click in Skim PDF

**Build directory issues:**
```bash
# VimTeX uses build/ by default (configured in vimtex.lua)
# Clean: \lc in vim or manually:
rm -rf build/
```