#!/usr/bin/env bash
# Stow all dotfile packages

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}🔗 Stowing dotfiles from: $DOTFILES_DIR${NC}"

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Array of packages to stow
PACKAGES=(
  "aws"
  "claude"
  "cursor"
  "docker"
  "fzf"
  "gh"
  "git"
  "julia"
  "latex"
  "macos"
  "mise"
  "nvim"
  "python"
  "ripgrep"
  "skhd"
  "ssh"
  "starship"
  "tmux"
  "vim"
  "vscode"
  "wezterm"
  "yabai"
  "zsh"
)

# Function to stow a package
stow_package() {
  local package="$1"
  
  if [ -d "$package" ]; then
    echo -e "${YELLOW}Stowing $package...${NC}"
    stow -v --restow "$package" 2>&1 | grep -v "BUG in find_stowed_path" || true
    echo -e "${GREEN}✓ $package stowed${NC}"
  else
    echo -e "${RED}✗ $package directory not found${NC}"
  fi
}

# Stow each package
for package in "${PACKAGES[@]}"; do
  stow_package "$package"
done

echo -e "${GREEN}✨ All packages stowed successfully!${NC}"
echo -e "${YELLOW}Note: You may need to reload your shell for changes to take effect${NC}"
echo -e "${YELLOW}Run: source ~/.zshrc${NC}"