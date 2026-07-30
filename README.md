# Modern Dotfiles

My personal dotfiles for macOS with state-of-the-art tooling and performance optimizations.

![Terminal Setup](https://user-images.githubusercontent.com/15176096/71632895-ff0d0980-2bde-11ea-966f-65e5d564361f.png)

## 🚀 Stack

### Core Tools
- **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/) / [Alacritty](https://alacritty.org/)
- **Shell**: ZSH with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- **Prompt**: [Starship](https://starship.rs/) - blazing fast, customizable prompt
- **Editor**: [Neovim](https://neovim.io/) with [LazyVim](https://www.lazyvim.org/) distribution

### Modern CLI Replacements
- `eza` - Better `ls` (with icons and git status)
- `bat` - Better `cat` (with syntax highlighting)
- `fd` - Better `find` (faster and user-friendly)
- `rg` (ripgrep) - Better `grep` (blazingly fast)
- `zoxide` - Smart `cd` (learns your habits)
- `delta` - Better `git diff` (side-by-side diffs)

### XDG Layout
- Most configs live under `~/.config/...` (fzf, ripgrep, starship, wezterm, nvim, etc.).
- FZF custom config: `~/.config/fzf/fzf.zsh`
- FZF/ZLE functions: `~/.config/zsh/fzf-functions.zsh`

### Development
- **Python**: [UV](https://docs.astral.sh/uv/) - Ultra-fast Python package manager (replaces pip, pipx, poetry, pyenv)
- **Julia**: [Juliaup](https://github.com/JuliaLang/juliaup) - Official Julia version manager
- **Version Management**: [mise](https://mise.jdx.dev/) - For Node.js, Ruby, Go, etc.
- **Formatting**: [Ruff](https://docs.astral.sh/ruff/) - Lightning-fast Python linter/formatter
- **LaTeX**: Full TeXLive distribution with VimTeX integration

### Window Management (Optional)
- **WM**: [yabai](https://github.com/koekeishiya/yabai) - Tiling window manager
- **Hotkeys**: [skhd](https://github.com/koekeishiya/skhd) - Simple hotkey daemon

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
├── scripts/           # Installation and management scripts
│   ├── install.sh    # Main installation script
│   ├── stow-all.sh   # Link all dotfiles
│   ├── stow-remove.sh # Remove all symlinks
│   └── update.sh     # Update all tools
├── alacritty/        # Terminal emulator config
├── aws/              # AWS CLI configuration
├── cursor/           # Cursor IDE settings
├── fzf/              # Fuzzy finder configuration
├── gh/               # GitHub CLI config
├── git/              # Git configuration (XDG: ~/.config/git)
├── julia/            # Julia startup.jl
├── latex/            # LaTeX/latexmk configuration
├── lazygit/          # LazyGit configuration
├── mise/             # Version manager config
├── nvim/             # Neovim/LazyVim configuration
├── python/           # Python/UV/Ruff configuration
├── ripgrep/          # Ripgrep configuration
├── ssh/              # SSH configuration
├── starship/         # Shell prompt
├── television/       # Television channels and UI configuration
├── tmux/             # Terminal multiplexer
├── vscode/           # VS Code settings
├── wezterm/          # WezTerm terminal config
├── vim/              # Vim fallback config
├── yabai/            # Tiling window manager config
├── skhd/             # Hotkey daemon config
└── zsh/              # ZSH shell configuration
```

## 🛠 Usage

### Update Everything
```bash
./scripts/update.sh
```

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
- Node is managed by `mise` (see `mise.toml`), so `brew install node` is not required.
- Python is managed by `UV` (ultra-fast), so separate Homebrew Python or Conda are optional.

### Aliases
- Primary aliases live in `~/.config/zsh/aliases.zsh` and only activate when the underlying tools are installed.
- Legacy aggressive GNU/coreutils overrides in `~/.aliases` are disabled by default to avoid breaking scripts and muscle memory. To enable them explicitly:

```bash
export ENABLE_LEGACY_GNU_ALIASES=1
```

### Custom Aliases
Edit `~/.config/zsh/aliases.zsh` to add your own aliases.

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

**Last Updated**: January 2025
**macOS Compatibility**: Sequoia 15.2+
**Architecture**: Apple Silicon (M1/M2/M3) optimized
