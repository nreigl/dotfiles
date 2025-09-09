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
    brew bundle --file="$DOTFILES_DIR/Brewfile"
  else
    # Manual installation of essentials
    brew install stow mise starship zoxide fzf fd ripgrep bat eza dust btop
  fi
  
  echo -e "${GREEN}✓ Core tools installed${NC}"
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
    juliaup add 1.11
    juliaup add 1.10
    juliaup default 1.11
    echo -e "${GREEN}✓ Julia 1.11 set as default${NC}"
  else
    echo -e "${RED}✗ Juliaup not found, install it via brew${NC}"
  fi
}

# === Configure mise ===
configure_mise() {
  echo -e "${YELLOW}🔧 Configuring mise...${NC}"
  
  if command -v mise &>/dev/null; then
    mise install node@lts
    mise use node@lts --global
    echo -e "${GREEN}✓ Mise configured with Node.js LTS${NC}"
  else
    echo -e "${RED}✗ Mise not found${NC}"
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
  
  # Run stow-all script
  ./scripts/stow-all.sh
  
  echo -e "${GREEN}✓ Dotfiles stowed${NC}"
}

# === Create necessary directories ===
create_directories() {
  echo -e "${YELLOW}📁 Creating necessary directories...${NC}"
  
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  mkdir -p "$HOME/.local/state/zsh"
  mkdir -p "$HOME/.cache"
  
  echo -e "${GREEN}✓ Directories created${NC}"
}

# === macOS Specific Settings ===
configure_macos() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}🍎 Configuring macOS settings...${NC}"
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show path bar in Finder
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    killall Finder || true
    
    echo -e "${GREEN}✓ macOS configured${NC}"
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
  configure_mise
  install_zinit
  
  # Stow dotfiles
  stow_dotfiles
  
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
  echo -e "3. Configure Git: ${BLUE}git config --global user.name 'Your Name'${NC}"
  echo -e "4. Test LaTeX: Create a .tex file and use ${BLUE}\\ll${NC} in Neovim"
  echo
  echo -e "${GREEN}Installed tools:${NC}"
  echo -e "  🐍 Python: UV with Python 3.12"
  echo -e "  🔷 Julia: 1.11 (latest) via Juliaup"
  echo -e "  📦 Node: LTS via mise"
  echo -e "  📝 Neovim: LazyVim with VimTeX"
  echo -e "  🚀 Shell: ZSH with Starship prompt"
}

# Run main installation
main "$@"