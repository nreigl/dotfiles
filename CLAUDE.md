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

#### LaTeX in Neovim
- `\ll` - Start continuous compilation
- `\lv` - View PDF in Skim
- `\lk` - Stop compilation

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