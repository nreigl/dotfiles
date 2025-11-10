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
```

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

**Settings:**
- Compiler: latexmk with lualatex (modern Unicode support)
- PDF viewer: Skim (forward/backward sync enabled)
- Build directory: `build/` (keeps project root clean)
- Completion: nvim-cmp with cmp-vimtex for intelligent suggestions

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
- `alacritty/`, `wezterm/` - Terminal emulators (configs symlinked to `~/.config/`)
- `nvim/` - Neovim/LazyVim config (→ `~/.config/nvim/`)
- `zsh/` - Shell config with `.zshrc`, aliases, functions (→ `~/`)
- `git/` - Global git config and gitignore (→ `~/`)
- `mise/` - Version manager config (→ `~/`)
- `tmux/` - Terminal multiplexer config (→ `~/`)
- `ssh/`, `aws/` - Security configs (→ `~/.ssh/`, `~/.aws/`)

### Key Configuration Files
- `Brewfile` - Homebrew package manifest (480+ packages)
- `scripts/install.sh` - Main installer (lines 1-198)
- `scripts/update.sh` - Update all tools (lines 1-158)
- `scripts/stow-all.sh` - Links 22 stow packages (lines 22-43)
- `mise.toml` - Global Node.js version (currently v22)

### Tool Stack
- **Package Management**: Homebrew (system), UV (Python), Juliaup (Julia), mise (Node/Ruby/Go)
- **Shell**: ZSH + Zinit + Starship prompt
- **Editor**: Neovim with LazyVim distribution
- **Terminal**: WezTerm/Alacritty
- **Window Management**: yabai + skhd (optional)

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