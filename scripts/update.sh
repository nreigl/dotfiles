#!/usr/bin/env bash
# Update all tools and dotfiles

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Updating Development Environment${NC}"
echo -e "${BLUE}========================================${NC}"

# === Update Homebrew ===
update_homebrew() {
  echo -e "${YELLOW}🍺 Updating Homebrew...${NC}"
  brew update
  brew upgrade
  brew cleanup
  echo -e "${GREEN}✓ Homebrew updated${NC}"
}

# === Update UV and Python tools ===
update_python() {
  echo -e "${YELLOW}🐍 Updating Python tools...${NC}"
  
  if command -v uv &>/dev/null; then
    # Update UV itself
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Update tools installed with UV
    uv tool upgrade --all
    
    echo -e "${GREEN}✓ Python tools updated${NC}"
  else
    echo -e "${RED}✗ UV not found${NC}"
  fi
}

# === Update Julia ===
update_julia() {
  echo -e "${YELLOW}🔷 Updating Julia...${NC}"
  
  if command -v juliaup &>/dev/null; then
    juliaup update
    echo -e "${GREEN}✓ Julia updated${NC}"
  else
    echo -e "${RED}✗ Juliaup not found${NC}"
  fi
}

# === Update mise tools ===
update_mise() {
  echo -e "${YELLOW}🔧 Updating mise tools...${NC}"
  
  if command -v mise &>/dev/null; then
    mise upgrade
    echo -e "${GREEN}✓ Mise tools updated${NC}"
  else
    echo -e "${RED}✗ Mise not found${NC}"
  fi
}

# === Update Neovim plugins ===
update_neovim() {
  echo -e "${YELLOW}📝 Updating Neovim plugins...${NC}"
  
  if command -v nvim &>/dev/null; then
    nvim --headless "+Lazy! sync" +qa
    echo -e "${GREEN}✓ Neovim plugins updated${NC}"
  else
    echo -e "${RED}✗ Neovim not found${NC}"
  fi
}

# === Update Zinit and ZSH plugins ===
update_zsh() {
  echo -e "${YELLOW}⚡ Updating ZSH plugins...${NC}"
  
  # Update Zinit (run in an interactive zsh so zinit is available)
  if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git" ]; then
    zsh -i -c 'zinit self-update && zinit update --all' || {
      echo -e "${YELLOW}⚠️  Unable to update via interactive zsh; sourcing directly...${NC}"
      zsh -c "source '${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.zsh'; zinit self-update; zinit update --all" || true
    }
    echo -e "${GREEN}✓ ZSH plugins updated${NC}"
  else
    echo -e "${RED}✗ Zinit not found${NC}"
  fi
}

# === Update dotfiles repository ===
update_dotfiles() {
  echo -e "${YELLOW}📁 Updating dotfiles...${NC}"
  
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
  
  cd "$DOTFILES_DIR"
  
  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes in dotfiles${NC}"
    echo -e "${YELLOW}   Skipping git pull${NC}"
  else
    git pull origin main
    echo -e "${GREEN}✓ Dotfiles updated${NC}"
  fi
  
  # Restow all packages
  echo -e "${YELLOW}🔗 Restowing dotfiles...${NC}"
  ./scripts/stow-all.sh
}

# === Update LaTeX packages ===
update_latex() {
  echo -e "${YELLOW}📚 Updating LaTeX packages...${NC}"
  
  if command -v tlmgr &>/dev/null; then
    sudo tlmgr update --self
    sudo tlmgr update --all
    echo -e "${GREEN}✓ LaTeX packages updated${NC}"
  else
    echo -e "${YELLOW}⚠️  tlmgr not found, skipping LaTeX updates${NC}"
  fi
}

# === Main update function ===
main() {
  echo -e "${YELLOW}Starting updates...${NC}"
  echo
  
  update_homebrew
  update_python
  update_julia
  update_mise
  update_neovim
  update_zsh
  update_dotfiles
  update_latex
  
  echo
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✨ All updates complete!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo
  echo -e "${YELLOW}Versions:${NC}"
  echo -e "  Python: $(python3 --version 2>&1 | cut -d' ' -f2)"
  echo -e "  Julia: $(julia --version 2>&1 | cut -d' ' -f3)"
  echo -e "  Node: $(node --version 2>&1)"
  echo -e "  Neovim: $(nvim --version 2>&1 | head -1 | cut -d' ' -f2)"
  echo
  echo -e "${YELLOW}Restart your terminal for all changes to take effect${NC}"
}

# Run main update
main "$@"
