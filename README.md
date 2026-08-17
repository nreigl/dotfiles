# Modern Dotfiles

My personal dotfiles for macOS with state-of-the-art tooling and performance optimizations.

![Terminal Setup](https://user-images.githubusercontent.com/15176096/71632895-ff0d0980-2bde-11ea-966f-65e5d564361f.png)

## 🚀 Stack

### Core Tools
- **Terminal**: [Ghostty](https://ghostty.org/)
- **Shell**: ZSH with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- **Prompt**: [Starship](https://starship.rs/) - blazing fast, customizable prompt
- **Editor**: [Neovim](https://neovim.io/) with [LazyVim](https://www.lazyvim.org/) distribution
- **Multiplexer**: [herdr](https://github.com/herdr-dev/herdr) for coding agents; tmux via the `tm` alias
- **File manager**: [yazi](https://yazi-rs.github.io/) (`y`); [superfile](https://superfile.dev/) on trial (`sf`)
- **Launcher**: [Raycast](https://raycast.com/) (not stowed - settings live in an encrypted database)
- **Screenshots**: [Shottr](https://shottr.cc/)

### Modern CLI Replacements
- `eza` - Better `ls` (with icons and git status)
- `bat` - Better `cat` (with syntax highlighting)
- `fd` - Better `find` (faster and user-friendly)
- `rg` (ripgrep) - Better `grep` (blazingly fast)
- `zoxide` - Smart `cd` (learns your habits)
- `delta` - Better `git diff` (side-by-side diffs)

### XDG Layout
- Most configs live under `~/.config/...` (fzf, ripgrep, starship, ghostty, nvim, etc.).
- FZF custom config: `~/.config/fzf/fzf.zsh`
- FZF/ZLE functions: `~/.config/zsh/fzf-functions.zsh`

### Development
- **Python**: [UV](https://docs.astral.sh/uv/) - Ultra-fast Python package manager (replaces pip, pipx, poetry, pyenv)
- **Julia**: [Juliaup](https://github.com/JuliaLang/juliaup) - Official Julia version manager
- **Version Management**: [mise](https://mise.jdx.dev/) - For Node.js, Ruby, Go, etc.
- **Formatting**: [Ruff](https://docs.astral.sh/ruff/) - Lightning-fast Python linter/formatter
- **LaTeX**: Full TeXLive distribution with VimTeX integration

### Window Management
None. yabai and skhd were both removed on 2026-08-14. Neither was running, and
`skhdrc` held almost nothing but yabai commands.

## 📦 Installation

### Prerequisites

1. **macOS** (tested on Apple Silicon)
2. **Homebrew** installed
3. **Full Disk Access** for Terminal.app (System Settings → Privacy & Security → Full Disk Access)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/nreigl/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run installation script
./scripts/install.sh
```

### Manual Installation

```bash
# Install GNU Stow
brew install stow

# Link all configurations
./scripts/stow-all.sh

# Or link individual packages
stow nvim
stow zsh
stow tmux
# ... etc
```

## 🗂 Structure

```
dotfiles/
├── scripts/          # Installation and management scripts
│   ├── install.sh    # Main installation script
│   ├── doctor.sh     # Health check for the whole repo
│   ├── stow-all.sh   # Link all dotfiles
│   ├── stow-remove.sh # Remove all symlinks
│   └── update.sh     # Update all tools
├── atuin/            # Shell history sync
├── aws/              # AWS CLI configuration
├── claude/           # Claude Code settings, agents, and skills
├── cursor/           # Cursor IDE settings
├── docker/           # Docker CLI config
├── fzf/              # Fuzzy finder configuration
├── gh/               # GitHub CLI config
├── ghostty/          # Terminal emulator config and shaders
├── git/              # Git configuration (XDG: ~/.config/git)
├── herdr/            # Agent multiplexer config
├── julia/            # Julia startup.jl
├── latex/            # LaTeX/latexmk configuration
├── macos/            # macOS defaults script
├── mise/             # Version manager config
├── nvim/             # Neovim/LazyVim configuration
├── pi/               # Pi agent settings, extensions, and prompts
├── python/           # Python/UV/Ruff configuration
├── raycast/          # Raycast scripts (NOT stowed)
├── ripgrep/          # Ripgrep configuration
├── ssh/              # SSH configuration
├── starship/         # Shell prompt
├── superfile/        # Second file manager (on trial)
├── television/       # Television channels and UI configuration
├── texmf/            # LaTeX beamer theme
├── tmux/             # Terminal multiplexer
├── vscode/           # VS Code settings
├── yazi/             # Terminal file manager
└── zsh/              # ZSH shell configuration
```

`scripts/stow-all.sh` holds the authoritative package list. `scripts/doctor.sh`
fails if that list drifts from what is on disk.

## 🛠 Usage

### Update Everything
```bash
./scripts/update.sh
```

### Check the Setup
```bash
./scripts/doctor.sh          # full report
./scripts/doctor.sh --quiet  # problems only
SKIP_CHECKS=brewfile ./scripts/doctor.sh
```
`doctor.sh` is read-only. It reports problems and never repairs them. It exits
1 if any check fails.

### Python Development
```bash
# Create new project with UV
uv init myproject --python 3.12
cd myproject
uv add pandas numpy
uv add --dev pytest ruff mypy
```

### Julia Development
```bash
# Check Julia versions
juliaup status

# Create new project
julia -e 'using Pkg; Pkg.generate("MyProject")'
```

### Version Management (mise)
```bash
# Install Node.js
mise use node@20

# Install Ruby
mise use ruby@3.2

# List all tools
mise list
```

## ⚙️ Configuration

### Environment Variables
Create `~/.zsh_secrets` for private environment variables:
```bash
export GITHUB_TOKEN="your-token"
export OPENAI_API_KEY="your-key"
```

### Ripgrep
- Uses XDG config at `~/.config/ripgrep/config` (set via `RIPGREP_CONFIG_PATH`).
- The config includes smart-case, hidden file handling with safe VCS exclusions, and useful type aliases.

### Television
- `tv pdfs` browses PDFs in the current project; press `Ctrl-S` for both research roots.
- `tv research-artifacts` browses papers, figures, tables, reports, slides, and logs while excluding data, dependency, and cache trees.
- `Enter` opens the selected file, `F12` reveals it in Finder, and `Ctrl-Y` uses Television's default copy action.
- Television shell integration is intentionally disabled so fzf/fzf-tab keep `Ctrl-T` and Atuin keeps `Ctrl-R`.

### Git (XDG)
- Global config at `~/.config/git/config`. A minimal `~/.gitconfig` includes this file for compatibility with tools expecting it.
- Global ignore file at `~/.config/git/ignore`.

### Node and Python
- Node is managed by `mise` (see `mise/.config/mise/config.toml`), so `brew install node` is not required.
- Python is managed by `UV` (ultra-fast), so separate Homebrew Python or Conda are optional.

### Aliases
Aliases live in `~/.config/zsh/aliases.zsh` and only activate when the underlying tool is installed. Shell functions live in `~/.config/zsh/functions.zsh` and `~/.config/zsh/fzf-functions.zsh`. `.zshrc` sources these three files. Add your own aliases and functions to them.

The legacy `~/.aliases` file was removed on 2026-08-14. Nothing sourced it, and an `ENABLE_LEGACY_GNU_ALIASES` guard disabled most of it anyway. Run `git show 9694c2508fb8^:zsh/.aliases` to read the old contents.

### Secrets
Copy `~/.zsh_secrets.template` to `~/.zsh_secrets` and fill in your API keys. `.zshrc` sources that file if it exists. Never commit the filled-in file.

### Neovim
- Leader key: `<Space>`
- Config: `~/.config/nvim/`
- LaTeX compile: `\ll` (with VimTeX)
- Package manager: Lazy.nvim

## 🔧 Troubleshooting

### Stow Conflicts
```bash
# Check what would be stowed (dry run)
stow -n -v nvim

# Force restow if conflicts
stow --adopt nvim
```

### UV/Python Issues
```bash
# Ensure UV is in PATH
source $HOME/.local/bin/env

# Check UV installation
uv --version
```

### Zinit/ZSH Plugin Issues
```bash
# Update Zinit
zinit self-update

# Update all plugins
zinit update --all

# Reinstall plugins
rm -rf ~/.local/share/zinit
exec zsh
```

### Mise Not Available
```bash
# Activate mise
eval "$(mise activate zsh)"

# Check installation
mise doctor
```

## 🔐 Security

- Never commit `.zsh_secrets` or `.env` files
- SSH keys use strong Ed25519 algorithm
- AWS credentials stored securely in `~/.aws/`
- GitHub tokens managed via `gh auth`
- Use 1Password CLI or similar for secret management
- Keep sensitive configs in separate, non-tracked files
- Review git history before pushing (`git log --oneline`)

## 📈 Performance

- ZSH plugins load lazily with Zinit's `wait` ice
- UV caches packages globally for fast installs (10-100x faster than pip)
- Mise uses shims for instant version switching
- LazyVim loads plugins on-demand
- Starship prompt is async and minimal
- Ripgrep for blazing fast code search
- FZF with optimized preview settings

## 🧹 Brewfile Notes
- Replaced `youtube-dl` with `yt-dlp`.
- Switched AdoptOpenJDK casks to `temurin8`.
- Prefer `zoxide` over `autojump` (autojump commented out).
- Prefer `eza` over `lsd` (lsd commented out).
- Prefer `tmux` over `screen` (screen commented out).
- Python managed by UV; `python@3.9` commented out to reduce conflicts.

## 📝 License

MIT

## 🙏 Acknowledgments

Inspired by many amazing dotfile repositories in the community.

---

**Last Updated**: August 2026
**macOS Compatibility**: Sequoia 15.2+
**Architecture**: Apple Silicon (M1/M2/M3) optimized
