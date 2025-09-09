# Claude/AI Assistant Configuration Hints

## Project Overview
Modern dotfiles repository with state-of-the-art tooling for macOS development environment.

## Directory Structure
```
dotfiles/
├── scripts/           # Installation and management scripts
├── alacritty/        # Terminal emulator config
├── git/              # Git configuration
├── julia/            # Julia language config (startup.jl)
├── latex/            # LaTeX/latexmk configuration
├── mise/             # Universal version manager
├── nvim/             # Neovim/LazyVim configuration
├── python/           # Python/UV/Ruff configuration
├── starship/         # Modern shell prompt
├── tmux/             # Terminal multiplexer
├── vim/              # Vim fallback config
└── zsh/              # ZSH shell configuration
```

## Key Technologies

### Python Development
- **UV**: Ultra-fast Python package manager (replaces pip, pipx, poetry, pyenv)
- **Ruff**: Lightning-fast Python linter/formatter (Rust-based)
- **Python 3.12**: Latest stable Python via UV
- Command: `uv init project --python 3.12`

### Julia Development
- **Juliaup**: Official Julia version manager
- **Julia 1.11**: Latest stable version
- **Julia 1.10**: LTS version
- Command: `juliaup status` to see versions

### Version Management
- **mise**: Replaces nvm, rbenv, pyenv for non-Python tools
- Config: `~/.config/mise/config.toml`
- Command: `mise list` to see installed tools

### Editor
- **Neovim** with **LazyVim** distribution
- **VimTeX** for LaTeX editing with Skim PDF viewer
- LaTeX compile: `\ll` in Neovim
- Config: `~/.config/nvim/`

### Shell
- **ZSH** with **Zinit** plugin manager
- **Starship** prompt for beautiful, fast prompt
- **Zoxide** for smart directory jumping
- Modern aliases: `eza` (ls), `bat` (cat), `fd` (find), `rg` (grep)

## Common Tasks

### Update Everything
```bash
./scripts/update.sh
```

### Stow Management
```bash
./scripts/stow-all.sh     # Link all configs
./scripts/stow-remove.sh  # Remove all links
stow nvim                 # Link single package
```

### Python Project
```bash
uv init myproject --python 3.12
cd myproject
uv add pandas numpy matplotlib
uv add --dev pytest ruff mypy
```

### Julia Project
```bash
julia -e 'using Pkg; Pkg.generate("MyProject")'
cd MyProject
julia --project=. -e 'using Pkg; Pkg.add("DataFrames")'
```

### LaTeX Compilation
1. Open .tex file in Neovim
2. Press `\ll` to start continuous compilation
3. Press `\lv` to view PDF in Skim
4. Save file to auto-recompile

## Testing Commands

### Verify Installations
```bash
uv --version           # Should show UV version
julia --version        # Should show 1.11.x
mise --version         # Should show mise version
nvim --version         # Should show Neovim version
ruff --version         # Should show Ruff version
```

### Test Python
```bash
uv run python -c "import sys; print(sys.version)"
```

### Test Julia
```bash
julia -e 'println("Julia $(VERSION) working!")'
```

### Test LaTeX
```bash
latexmk --version
which lualatex
```

## Troubleshooting

### If Stow fails
- Check for existing files/links in home directory
- Use `stow -n -v package` to dry-run
- Remove conflicts manually then restow

### If UV not found
```bash
source $HOME/.local/bin/env
```

### If mise tools not available
```bash
eval "$(mise activate zsh)"
```

### If Neovim plugins not loading
```bash
nvim --headless "+Lazy! sync" +qa
```

### If ZSH plugins not working
```bash
zinit self-update
zinit update --all
```

## File Locations

- Python: `~/.local/share/uv/`
- Julia: `~/.julia/`
- Mise: `~/.local/share/mise/`
- Neovim: `~/.config/nvim/`
- ZSH History: `~/.local/state/zsh/history`
- Starship: `~/.config/starship.toml`

## Best Practices

1. **Always use UV for Python** - Don't use pip directly
2. **Use mise for Node/Ruby/Go** - Not for Python (UV handles that)
3. **Commit dotfile changes regularly** - Keep repo in sync
4. **Run update.sh weekly** - Keep tools current
5. **Use modern CLI replacements** - eza, bat, fd, rg, etc.

## Security Notes

- Never commit secrets to dotfiles
- Use 1Password CLI or similar for secrets
- Keep `.zsh_secrets` file local only
- Don't track `.env` files

## Performance Tips

- ZSH loads plugins lazily with `zinit wait`
- UV caches packages globally
- Mise uses shims for fast switching
- LazyVim lazy-loads plugins
- Starship is async and fast

## Additional Resources

- UV Docs: https://docs.astral.sh/uv/
- LazyVim: https://www.lazyvim.org/
- Mise: https://mise.jdx.dev/
- Juliaup: https://github.com/JuliaLang/juliaup
- VimTeX: https://github.com/lervag/vimtex