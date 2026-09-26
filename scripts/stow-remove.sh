#!/usr/bin/env bash
# Remove all stowed dotfile packages

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}🔗 Removing stowed dotfiles from: $DOTFILES_DIR${NC}"

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Array of packages to unstow
PACKAGES=(
  "atuin"
  "aws"
  "claude"
  "cursor"
  "fzf"
  "gh"
  "ghostty"
  "git"
  "herdr"
  "hunk"
  "julia"
  "latex"
  "macos"
  "mise"
  "nvim"
  "pi"
  "python"
  "ripgrep"
  "ssh"
  "starship"
  "superfile"
  "television"
  "texmf"
  "tmux"
  "tuicr"
  "vscode"
  "yazi"
  "zsh"
)

# Function to unstow a package
unstow_package() {
  local package="$1"
  
  if [ -d "$package" ]; then
    echo -e "${YELLOW}Unstowing $package...${NC}"
    # Read stow's exit status from PIPESTATUS[0], not from the grep. See the
    # same block in stow-all.sh.
    local rc
    set +e
    stow -v --delete "$package" 2>&1 | grep -v "BUG in find_stowed_path"
    rc=${PIPESTATUS[0]}
    set -e
    if [[ $rc -eq 0 ]]; then
      echo -e "${GREEN}✓ $package unstowed${NC}"
    else
      echo -e "${RED}✗ $package: stow exited with status $rc${NC}"
      FAILED+=("$package")
    fi
  else
    echo -e "${RED}✗ $package directory not found${NC}"
    FAILED+=("$package")
  fi
}

# Confirm before removing
echo -e "${RED}Warning: This will remove all symlinks to your dotfiles!${NC}"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled"
  exit 1
fi

# Unstow each package
FAILED=()
for package in "${PACKAGES[@]}"; do
  unstow_package "$package"
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo -e "${RED}✗ ${#FAILED[@]} of ${#PACKAGES[@]} packages failed: ${FAILED[*]}${NC}"
  exit 1
fi

echo -e "${GREEN}✨ All ${#PACKAGES[@]} packages unstowed successfully!${NC}"
