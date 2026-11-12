#!/usr/bin/env bash
# Update all tools and dotfiles

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defined here, not inside update_dotfiles(). Under `set -u` any function that
# runs before update_dotfiles() would abort on an unset DOTFILES_DIR.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Every tool step runs under `set -e`. One failed tool must not stop the other
# updates, so each step ends in `|| warn "..."` and reports the failure instead.
warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Updating Development Environment${NC}"
echo -e "${BLUE}========================================${NC}"

# === Update Homebrew ===
update_homebrew() {
  echo -e "${YELLOW}🍺 Updating Homebrew...${NC}"
  local brew_failed=0
  brew update || { warn "brew update failed"; brew_failed=1; }
  brew upgrade --formula || { warn "brew upgrade --formula failed"; brew_failed=1; }
  # Upgrade casks but never google-chrome (it manages its own updates).
  # `|| true` keeps grep's "no match" exit status from tripping `set -euo pipefail`
  # when the only outdated cask is chrome (or nothing is outdated).
  local outdated_casks
  outdated_casks=$(brew outdated --cask --quiet | grep -v '^google-chrome$' || true)
  if [ -n "$outdated_casks" ]; then
    echo "$outdated_casks" | xargs brew upgrade --cask ||
      { warn "brew upgrade --cask failed"; brew_failed=1; }
  fi
  brew cleanup || warn "brew cleanup failed"
  if [[ $brew_failed -eq 0 ]]; then
    echo -e "${GREEN}✓ Homebrew updated${NC}"
  else
    warn "Homebrew only partly updated"
  fi
}

# === Update UV and Python tools ===
update_python() {
  echo -e "${YELLOW}🐍 Updating Python tools...${NC}"
  
  if command -v uv &>/dev/null; then
    # Update UV itself. `uv self update` replaces the curl | sh installer.
    uv self update || warn "uv self update failed; uv left as-is"

    # Update tools installed with UV
    if uv tool upgrade --all; then
      echo -e "${GREEN}✓ Python tools updated${NC}"
    else
      warn "uv tool upgrade --all failed"
    fi
  else
    echo -e "${RED}✗ UV not found${NC}"
  fi
}

# === Update Julia ===
update_julia() {
  echo -e "${YELLOW}🔷 Updating Julia...${NC}"
  
  if command -v juliaup &>/dev/null; then
    if juliaup update; then
      echo -e "${GREEN}✓ Julia updated${NC}"
    else
      warn "juliaup update failed"
    fi
  else
    echo -e "${RED}✗ Juliaup not found${NC}"
  fi
}

# === Update mise tools ===
update_mise() {
  echo -e "${YELLOW}🔧 Updating mise tools...${NC}"
  
  if command -v mise &>/dev/null; then
    if mise upgrade; then
      echo -e "${GREEN}✓ Mise tools updated${NC}"
    else
      warn "mise upgrade failed"
    fi
  else
    echo -e "${RED}✗ Mise not found${NC}"
  fi
}

# === Update npm global tools (hunk) ===
# hunk installs with `npm i -g hunkdiff`, so it lands under the mise Node
# version that is active AT INSTALL TIME. A Node major upgrade leaves the old
# install behind and `hunk` falls off PATH. `mise exec node@22 --` resolves the
# Node through mise instead of through the versioned bin directory already
# baked into this shell's PATH. Keep the pin in step with install.sh and with
# mise/.config/mise/config.toml (node = "22").
update_npm_globals() {
  echo -e "${YELLOW}📦 Updating npm global tools...${NC}"

  if ! command -v mise &>/dev/null; then
    echo -e "${RED}✗ mise not found; skipping npm globals${NC}"
    return 0
  fi

  # `|| return 0` on the install: a registry outage or a permission error must
  # warn, never kill the update run.
  if ! mise exec node@22 -- npm install -g hunkdiff@latest; then
    echo -e "${YELLOW}⚠️  npm install -g hunkdiff@latest failed; hunk left as-is${NC}"
    return 0
  fi
  echo -e "${GREEN}✓ hunk $(hunk --version 2>&1) installed${NC}"
}

# === Update Pi Coding Agent ===
update_pi() {
  echo -e "${YELLOW}🤖 Updating Pi coding agent...${NC}"

  if command -v pi &>/dev/null; then
    if pi update --self; then
      echo -e "${GREEN}✓ Pi coding agent updated${NC}"
    else
      warn "pi update --self failed"
    fi
  else
    echo -e "${RED}✗ Pi not found${NC}"
  fi
}

# === Report Brewfile drift ===
# --no-upgrade is required. Without it, brew reports installed-but-outdated
# packages as unmet, and self-updating casks (1Password, Slack, Spotify, VS
# Code, WhatsApp, Signal) then show as unmet permanently. That noise hides the
# packages that are genuinely absent.
check_brewfile_drift() {
  echo -e "${YELLOW}📋 Checking Brewfile drift...${NC}"

  local brewfile="$DOTFILES_DIR/Brewfile"
  if [ ! -f "$brewfile" ]; then
    echo -e "${RED}✗ Brewfile not found at $brewfile${NC}"
    return
  fi

  local missing
  missing="$(brew bundle check --verbose --no-upgrade --file="$brewfile" 2>&1 | grep '^→' || true)"

  if [ -z "$missing" ]; then
    echo -e "${GREEN}✓ Brewfile matches what is installed${NC}"
  else
    echo -e "${YELLOW}Listed in the Brewfile but not installed:${NC}"
    echo "$missing"
    echo -e "${YELLOW}Install them with 'brew bundle install', or delete the lines.${NC}"
  fi
}

# === Update Neovim plugins ===
update_neovim() {
  echo -e "${YELLOW}📝 Updating Neovim plugins...${NC}"
  
  if command -v nvim &>/dev/null; then
    if nvim --headless "+Lazy! sync" +qa; then
      echo -e "${GREEN}✓ Neovim plugins updated${NC}"
    else
      warn "Lazy sync failed"
    fi
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
  
  cd "$DOTFILES_DIR"
  
  # Fetch first, so a dirty tree still learns how far behind it is. A pull
  # into a dirty tree is skipped on purpose: a rebase with autostash can stop
  # on a conflict in the middle of an update run.
  git fetch --quiet origin main || echo -e "${YELLOW}⚠️  git fetch failed; is the network up?${NC}"
  local behind
  behind="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"

  if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes in dotfiles; skipping git pull${NC}"
    if [[ "$behind" -gt 0 ]]; then
      echo -e "${YELLOW}   origin/main is $behind commit(s) ahead. Commit, then run: git pull${NC}"
    fi
  elif [[ "$behind" -gt 0 ]]; then
    if git pull origin main; then
      echo -e "${GREEN}✓ Dotfiles updated ($behind commit(s))${NC}"
    else
      warn "git pull failed; the dotfiles repo is not updated"
    fi
  else
    echo -e "${GREEN}✓ Dotfiles already up to date${NC}"
  fi
  
  # Restow all packages
  echo -e "${YELLOW}🔗 Restowing dotfiles...${NC}"
  ./scripts/stow-all.sh || warn "stow-all.sh reported failures; run it again and read the ✗ lines"
}

# === Update LaTeX packages ===
update_latex() {
  echo -e "${YELLOW}📚 Updating LaTeX packages...${NC}"

  if ! command -v tlmgr &>/dev/null; then
    echo -e "${YELLOW}⚠️  tlmgr not found, skipping LaTeX updates${NC}"
    return 0
  fi

  # Once a TeX Live release is superseded its repository is frozen, and every
  # tlmgr update exits 1. Under `set -euo pipefail` that aborted this whole
  # script before the summary ran. Detect the condition first, without sudo,
  # and report it instead of failing.
  local status
  status="$(tlmgr update --list 2>&1 || true)"

  if echo "$status" | grep -q "older than remote repository"; then
    local local_ver remote_ver
    local_ver="$(echo "$status" | sed -n 's/.*Local TeX Live (\([0-9]*\)).*/\1/p' | head -1)"
    remote_ver="$(echo "$status" | sed -n 's/.*remote repository (\([0-9]*\)).*/\1/p' | head -1)"
    echo -e "${YELLOW}⚠️  TeX Live ${local_ver:-?} is superseded by ${remote_ver:-a newer release}.${NC}"
    echo -e "${YELLOW}   The ${local_ver:-current} repository is frozen, so no package updates remain.${NC}"
    echo -e "${YELLOW}   tlmgr cannot cross a release boundary. To upgrade, either:${NC}"
    echo -e "${YELLOW}     - install MacTeX ${remote_ver:-latest} (keeps ${local_ver:-the old tree} for rollback), or${NC}"
    echo -e "${YELLOW}     - run update-tlmgr-latest.sh --update (rewrites the tree in place)${NC}"
    echo -e "${YELLOW}   See https://tug.org/texlive/upgrade.html${NC}"
    return 0
  fi

  # The `||` branches: a tlmgr failure must warn, never kill the update run.
  # `tl_failed` gates the success line, so a warning cannot be followed by a
  # success claim about the same operation.
  local tl_failed=0
  sudo tlmgr update --self || { echo -e "${YELLOW}⚠️  tlmgr update --self failed${NC}"; tl_failed=1; }
  sudo tlmgr update --all || { echo -e "${YELLOW}⚠️  tlmgr update --all failed${NC}"; tl_failed=1; }
  if [[ $tl_failed -eq 0 ]]; then
    echo -e "${GREEN}✓ LaTeX packages updated${NC}"
  else
    echo -e "${YELLOW}⚠️  LaTeX packages only partly updated${NC}"
  fi
}

# === Main update function ===
main() {
  echo -e "${YELLOW}Starting updates...${NC}"
  echo
  
  update_homebrew
  # update_dotfiles runs second. The steps after it write tracked files
  # (lazy-lock.json and pi settings.json), and a dirty tree makes
  # update_dotfiles skip `git pull`. Homebrew runs first so that stow and git
  # are current before the pull and the restow.
  update_dotfiles
  # After the pull, so the drift report reads the newest Brewfile.
  check_brewfile_drift
  update_python
  update_julia
  update_mise
  update_pi
  update_neovim
  update_zsh
  update_npm_globals
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

  # Updates are where drift appears: a cask disappears, a tool rewrites .zshrc,
  # a plugin leaves a dangling symlink. Report it, but never fail the update
  # over it, so a health problem cannot mask a successful set of upgrades.
  echo
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}🩺 Health check${NC}"
  echo -e "${GREEN}========================================${NC}"
  "$DOTFILES_DIR/scripts/doctor.sh" --quiet || true
}

# Run main update
main "$@"
