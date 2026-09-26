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

# Function to stow a package
stow_package() {
  local package="$1"
  local -a FLAGS=("--restow")
  if [[ "${STOW_ADOPT:-0}" == "1" ]]; then
    FLAGS=("--adopt" "--restow")
  fi
  if [[ "${STOW_DRY_RUN:-0}" == "1" ]]; then
    FLAGS=("-n" "-v" "${FLAGS[@]}")
  else
    FLAGS=("-v" "${FLAGS[@]}")
  fi
  
  if [ -d "$package" ]; then
    echo -e "${YELLOW}Stowing $package...${NC}"
    # The grep only removes a noise line. Read stow's own exit status from
    # PIPESTATUS[0]: grep exits 1 when it prints nothing, and `|| true` on the
    # whole pipeline would also hide a stow failure. `set +e` keeps a failed
    # pipeline from ending the script before the status is read.
    local rc
    set +e
    stow "${FLAGS[@]}" "$package" 2>&1 | grep -v "BUG in find_stowed_path"
    rc=${PIPESTATUS[0]}
    set -e
    if [[ $rc -eq 0 ]]; then
      echo -e "${GREEN}✓ $package stowed${NC}"
    else
      echo -e "${RED}✗ $package: stow exited with status $rc${NC}"
      FAILED+=("$package")
    fi
  else
    echo -e "${RED}✗ $package directory not found${NC}"
    FAILED+=("$package")
  fi
}

# Stow each package
FAILED=()
for package in "${PACKAGES[@]}"; do
  stow_package "$package"
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo -e "${RED}✗ ${#FAILED[@]} of ${#PACKAGES[@]} packages failed: ${FAILED[*]}${NC}"
  echo -e "${YELLOW}Read the stow output above. A conflict means a real file exists at the target.${NC}"
  exit 1
fi

echo -e "${GREEN}✨ All ${#PACKAGES[@]} packages stowed successfully!${NC}"
echo -e "${YELLOW}Note: You may need to reload your shell for changes to take effect${NC}"
echo -e "${YELLOW}Run: source ~/.zshrc${NC}"
