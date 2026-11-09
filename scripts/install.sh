#!/usr/bin/env bash
# Modern dotfiles installation script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Modern Dotfiles Installation${NC}"
echo -e "${BLUE}========================================${NC}"

# === Install Homebrew ===
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}📦 Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo -e "${GREEN}✓ Homebrew already installed${NC}"
  fi
}

# === Install Core Tools ===
install_core_tools() {
  echo -e "${YELLOW}📦 Installing core tools...${NC}"
  
  # Install from Brewfile if it exists
  if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo -e "${YELLOW}Installing from Brewfile...${NC}"
    # One failed entry makes `brew bundle` exit 1. The usual cause is a `mas`
    # entry when the App Store is not signed in. Under `set -e` that stopped
    # the install before uv, mise, and stow ran. Warn and continue instead.
    if brew bundle --file="$DOTFILES_DIR/Brewfile"; then
      echo -e "${GREEN}✓ Core tools installed${NC}"
    else
      echo -e "${YELLOW}⚠️  brew bundle did not install every Brewfile entry.${NC}"
      echo -e "${YELLOW}   If the failed entries are mas apps, sign in to the App Store.${NC}"
      echo -e "${YELLOW}   Then run: brew bundle install --file=$DOTFILES_DIR/Brewfile${NC}"
    fi
  else
    # Manual installation of essentials
    brew install stow mise starship zoxide fzf fd ripgrep bat eza dust btop
    echo -e "${GREEN}✓ Core tools installed${NC}"
  fi
}

# === Install UV (Python) ===
install_uv() {
  if ! command -v uv &>/dev/null; then
    echo -e "${YELLOW}🐍 Installing UV for Python...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.local/bin/env"
    
    # Install Python 3.12
    uv python install 3.12
    uv tool install ruff
    echo -e "${GREEN}✓ UV and Python 3.12 installed${NC}"
  else
    echo -e "${GREEN}✓ UV already installed${NC}"
  fi
}

# === Setup Julia ===
setup_julia() {
  echo -e "${YELLOW}🔷 Setting up Julia...${NC}"
  
  if command -v juliaup &>/dev/null; then
    # The `release` channel tracks the current stable Julia. A pinned minor
    # version goes stale within a year and then installs an old Julia.
    juliaup add release
    juliaup default release
    echo -e "${GREEN}✓ Julia release channel set as default${NC}"
  else
    echo -e "${RED}✗ Juliaup not found, install it via brew${NC}"
  fi
}

# === Install mise tools ===
# Runs AFTER stow_dotfiles. The stowed mise/.config/mise/config.toml pins the
# tool versions (node = "22"). Do not add `mise use --global` here: before
# stow it creates a real ~/.config/mise/config.toml, and that file then
# blocks the mise package from linking.
install_mise_tools() {
  echo -e "${YELLOW}🔧 Installing mise tools...${NC}"

  if command -v mise &>/dev/null; then
    if mise install; then
      echo -e "${GREEN}✓ mise tools installed from the stowed config${NC}"
    else
      echo -e "${YELLOW}⚠️  mise install failed; run it again by hand${NC}"
    fi
  else
    echo -e "${RED}✗ Mise not found${NC}"
  fi
}

# === Install Pi Coding Agent ===
install_pi() {
  echo -e "${YELLOW}🤖 Installing Pi coding agent...${NC}"

  if command -v mise &>/dev/null; then
    mise exec node@22 -- npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    echo -e "${GREEN}✓ Pi coding agent installed${NC}"
  else
    echo -e "${RED}✗ Mise not found; unable to install Pi${NC}"
  fi
}

# === Install hunk (diff viewer) ===
# The `hd`/`hds`/`hs` aliases and the git `hdiff`/`hshow` aliases all call
# `hunk`. Without this, doctor.sh check_referenced_binaries fails on a fresh
# machine with three "alias points at a missing command" errors.
install_hunk() {
  echo -e "${YELLOW}🔍 Installing hunk...${NC}"

  if ! command -v mise &>/dev/null; then
    echo -e "${RED}✗ Mise not found; unable to install hunk${NC}"
    return 0
  fi

  if mise exec node@22 -- npm install -g hunkdiff@latest; then
    echo -e "${GREEN}✓ hunk installed${NC}"
  else
    echo -e "${YELLOW}⚠️  hunk install failed; run ./scripts/update.sh to retry${NC}"
  fi
}

# === Install Zinit (ZSH Plugin Manager) ===
install_zinit() {
  local ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
  
  if [ ! -d "$ZINIT_HOME" ]; then
    echo -e "${YELLOW}⚡ Installing Zinit...${NC}"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo -e "${GREEN}✓ Zinit installed${NC}"
  else
    echo -e "${GREEN}✓ Zinit already installed${NC}"
  fi
}

# === Stow Dotfiles ===
stow_dotfiles() {
  echo -e "${YELLOW}🔗 Stowing dotfiles...${NC}"
  
  cd "$DOTFILES_DIR"
  
  # Make scripts executable
  chmod +x scripts/*.sh
  
  # stow-all.sh exits 1 if any package fails. Warn and continue, so the
  # remaining steps still run, but do not claim success.
  if ./scripts/stow-all.sh; then
    echo -e "${GREEN}✓ Dotfiles stowed${NC}"
  else
    echo -e "${YELLOW}⚠️  Some packages did not stow. Fix the conflicts, then run ./scripts/stow-all.sh${NC}"
  fi
}

# === Create necessary directories ===
create_directories() {
  echo -e "${YELLOW}📁 Creating necessary directories...${NC}"
  
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  mkdir -p "$HOME/.local/state/zsh"
  mkdir -p "$HOME/.cache"
  # ssh/.ssh/config sets ControlPath under this directory. ssh does not create
  # it, and without it every connection warns and runs without multiplexing.
  mkdir -p "$HOME/.ssh/sockets"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets"
  # A real directory makes stow link only tuios/config.toml. If the directory
  # is missing, stow links the whole directory, and the themes/ that tuios
  # writes land in the repo.
  mkdir -p "$HOME/.config/tuios"

  echo -e "${GREEN}✓ Directories created${NC}"
}

# === macOS Specific Settings ===
configure_macos() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}🍎 Configuring macOS settings...${NC}"

    # macos/.macos is the single source of truth for `defaults write` lines.
    # It asks for sudo once and restarts Finder and Dock itself. It has no
    # `set -e`, so a failed line does not change its exit status. Treat the
    # run as best effort and never claim that every setting applied.
    if bash "$DOTFILES_DIR/macos/.macos"; then
      echo -e "${YELLOW}⚠️  macos/.macos ran. It does not stop on a failed setting,${NC}"
      echo -e "${YELLOW}   so read its output above for errors.${NC}"
    else
      echo -e "${YELLOW}⚠️  macos/.macos exited with an error; rerun it by hand${NC}"
    fi
  fi
}

# === Machine-local git identity ===
# ~/.gitconfig is an untracked real file that holds user.name and user.email.
# Git reads it after ~/.config/git/config (tracked), so its keys win, and
# `git config --global` writes into it instead of into the repo.
setup_git_identity() {
  echo -e "${YELLOW}👤 Checking the git identity file...${NC}"

  if [[ -L "$HOME/.gitconfig" ]]; then
    echo -e "${RED}✗ ~/.gitconfig is a symlink to $(readlink "$HOME/.gitconfig").${NC}"
    echo -e "${RED}  git config --global would write into that target. Replace the link${NC}"
    echo -e "${RED}  with a real file, then run install.sh again. Skipping this step.${NC}"
    return 0
  fi

  if [[ ! -e "$HOME/.gitconfig" ]]; then
    touch "$HOME/.gitconfig"
    echo -e "${GREEN}✓ Created an empty ~/.gitconfig${NC}"
  else
    echo -e "${GREEN}✓ ~/.gitconfig exists${NC}"
  fi

  if ! git config --file "$HOME/.gitconfig" user.name >/dev/null 2>&1; then
    echo -e "${YELLOW}   No identity is set. Run:${NC}"
    echo -e "   ${BLUE}git config --global user.name 'Your Name'${NC}"
    echo -e "   ${BLUE}git config --global user.email 'you@example.com'${NC}"
  fi
}

# === Main Installation ===
main() {
  echo -e "${YELLOW}Starting installation...${NC}"
  
  # Create directories first
  create_directories
  
  # Install tools
  install_homebrew
  install_core_tools
  install_uv
  setup_julia
  install_zinit

  # Stow dotfiles
  stow_dotfiles
  setup_git_identity

  # After stow: mise reads the tool pins from the stowed config, and pi and
  # hunk install under the Node that mise installs.
  install_mise_tools
  install_pi
  install_hunk
  
  # macOS specific
  configure_macos
  
  echo
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✨ Installation Complete!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo
  echo -e "${YELLOW}Next steps:${NC}"
  echo -e "1. Restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
  echo -e "2. Install LazyVim plugins: ${BLUE}nvim${NC} (will auto-install)"
  # ~/.config/git/config is a symlink into this repo. ~/.gitconfig is an
  # untracked real file, and `git config --global` writes into it.
  echo -e "3. Configure Git: ${BLUE}git config --global user.name 'Your Name'${NC}"
  echo -e "   (and user.email). The identity goes into ~/.gitconfig, which is untracked."
  echo -e "4. Test LaTeX: Create a .tex file and use ${BLUE}\\ll${NC} in Neovim"
  echo
  echo -e "${GREEN}Installed tools:${NC}"
  echo -e "  🐍 Python: UV with Python 3.12"
  echo -e "  🔷 Julia: release channel via Juliaup"
  echo -e "  📦 Node: LTS via mise"
  echo -e "  📝 Neovim: LazyVim with VimTeX"
  echo -e "  🚀 Shell: ZSH with Starship prompt"
}

# Run main installation
main "$@"
