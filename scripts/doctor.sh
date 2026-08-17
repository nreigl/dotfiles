#!/usr/bin/env bash
# Health check for the dotfiles repository.
#
# This script is read-only. It reports problems. It never repairs them.
#
# Usage:
#   ./scripts/doctor.sh                    Run every check
#   ./scripts/doctor.sh --quiet            Print problems only, no ok lines
#   SKIP_CHECKS=brewfile,paths ./scripts/doctor.sh
#
# Exit status: 0 if no check failed, 1 if any check reported an error.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

QUIET=0
if [[ "${1:-}" == "--quiet" ]]; then QUIET=1; fi

SKIP_CHECKS="${SKIP_CHECKS:-}"

ERRORS=0
WARNINGS=0

# Directories at the top level that are deliberately not stow packages.
UNSTOWED_ALLOWLIST=(scripts docs raycast tmp)

# Tools that must be on PATH. Add to this list when a config starts to
# depend on a new binary.
REQUIRED_BINS=(
  stow git nvim zsh tmux fzf rg fd eza bat zoxide starship mise
  direnv atuin uv jq gh delta yazi herdr
)

# Tools removed from this setup. Any surviving reference is dead config.
# Add a name here when a tool is removed, and doctor.sh polices it forever.
REMOVED_TOOLS='wezterm|alacritty|alfred|yabai|skhd|oh-my-zsh|pyenv|autojump'

# --- output helpers ---------------------------------------------------------

err() {
  printf "${RED}  ERROR${NC} %s\n" "$1"
  ERRORS=$((ERRORS + 1))
}

warn() {
  printf "${YELLOW}  WARN ${NC} %s\n" "$1"
  WARNINGS=$((WARNINGS + 1))
}

ok() {
  [[ $QUIET -eq 1 ]] && return 0
  printf "${GREEN}  ok   ${NC} %s\n" "$1"
}

section() {
  [[ $QUIET -eq 1 ]] && return 0
  printf "\n${BLUE}== %s${NC}\n" "$1"
}

skipped() {
  local name="$1"
  [[ ",$SKIP_CHECKS," == *",$name,"* ]]
}

# Read the PACKAGES array out of a stow script without sourcing it.
read_packages() {
  sed -n '/^PACKAGES=(/,/^)/p' "$1" | sed -n 's/^  *"\(.*\)"$/\1/p'
}

# --- checks -----------------------------------------------------------------

check_package_parity() {
  section "Package list"

  local all remove
  all="$(read_packages "$SCRIPT_DIR/stow-all.sh")"
  remove="$(read_packages "$SCRIPT_DIR/stow-remove.sh")"

  if [[ -z "$all" ]]; then
    err "cannot parse PACKAGES out of stow-all.sh"
    return
  fi

  if [[ "$all" != "$remove" ]]; then
    err "PACKAGES differs between stow-all.sh and stow-remove.sh"
    diff <(echo "$all") <(echo "$remove") | sed 's/^/         /' || true
  else
    ok "stow-all.sh and stow-remove.sh agree ($(echo "$all" | wc -l | tr -d ' ') packages)"
  fi

  local pkg
  for pkg in $all; do
    [[ -d "$DOTFILES_DIR/$pkg" ]] || err "package '$pkg' is listed but the directory is missing"
  done

  # Every top-level directory should be a package or on the allowlist.
  local dir base
  for dir in "$DOTFILES_DIR"/*/; do
    base="$(basename "$dir")"
    if ! echo "$all" | grep -qx "$base"; then
      local allowed=0 a
      for a in "${UNSTOWED_ALLOWLIST[@]}"; do
        if [[ "$base" == "$a" ]]; then allowed=1; fi
      done
      if [[ $allowed -eq 0 ]]; then
        warn "directory '$base' is not a stow package and not on the allowlist"
      fi
    fi
  done
  return 0
}

check_stow_conflicts() {
  skipped stow && return 0
  section "Stow (dry run)"

  local pkg out found=0
  cd "$DOTFILES_DIR"
  for pkg in $(read_packages "$SCRIPT_DIR/stow-all.sh"); do
    [[ -d "$pkg" ]] || continue
    # -n is a dry run. Never remove it: this check must not touch the disk.
    # Plain stow (no --restow) stays silent when a package is already linked,
    # so any remaining output means a genuine gap or conflict.
    out="$(stow -n -v "$pkg" 2>&1 |
      grep -v "BUG in find_stowed_path" |
      grep -v "^WARNING: in simulation mode" |
      grep -v "reverts previous action" || true)"
    if [[ -n "$out" ]]; then
      err "package '$pkg' is not fully linked:"
      echo "$out" | sed 's/^/         /'
      found=1
    fi
  done
  if [[ $found -eq 0 ]]; then ok "all packages are fully linked"; fi
}

check_broken_symlinks() {
  section "Broken symlinks"

  local found=0 link target
  while IFS= read -r link; do
    target="$(readlink "$link")"
    case "$target" in
      *dotfiles*) ;;
      *) continue ;;
    esac
    if [[ ! -e "$link" ]]; then
      err "broken link: $link -> $target"
      found=1
    fi
  done < <(find "$HOME" -maxdepth 1 -type l 2>/dev/null
           find "$HOME/.config" "$HOME/.claude" "$HOME/.pi" "$HOME/.ssh" \
                "$HOME/.aws" "$HOME/.docker" "$HOME/.julia" "$HOME/.tmux" \
                -type l 2>/dev/null || true)

  if [[ $found -eq 0 ]]; then ok "no broken symlinks into the repo"; fi
}

check_untracked_stowed() {
  section "Git tracking of linked files"

  # A file that is symlinked into $HOME but untracked in git breaks a fresh
  # clone: stow will not create the link because the file will not exist.
  local found=0 link target rel
  cd "$DOTFILES_DIR"
  while IFS= read -r link; do
    target="$(readlink "$link")"
    case "$target" in
      *dotfiles*) ;;
      *) continue ;;
    esac
    rel="${target#*dotfiles/}"
    [[ -f "$DOTFILES_DIR/$rel" ]] || continue
    # A deliberately gitignored file (machine-local config, secrets) is fine.
    git check-ignore -q "$rel" 2>/dev/null && continue
    if ! git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      err "linked but untracked (a fresh clone would miss it): $rel"
      found=1
    fi
  done < <(find "$HOME" -maxdepth 1 -type l 2>/dev/null
           find "$HOME/.config" "$HOME/.claude" "$HOME/.pi" -type l 2>/dev/null || true)

  if [[ $found -eq 0 ]]; then ok "every linked file is tracked"; fi
}

check_referenced_binaries() {
  skipped bins && return 0
  section "Referenced binaries"

  local bin found=0
  for bin in "${REQUIRED_BINS[@]}"; do
    command -v "$bin" >/dev/null 2>&1 || { err "required binary not on PATH: $bin"; found=1; }
  done

  # Every alias target in aliases.zsh must resolve to something.
  local aliases="$DOTFILES_DIR/zsh/.config/zsh/aliases.zsh"
  if [[ -f "$aliases" ]]; then
    local name target
    while IFS= read -r line; do
      name="$(echo "$line" | sed -n "s/^alias \([a-zA-Z0-9_-]*\)=.*/\1/p")"
      target="$(echo "$line" | sed -n "s/^alias [a-zA-Z0-9_-]*='\{0,1\}\([a-zA-Z0-9_.-]*\).*/\1/p")"
      [[ -z "$target" ]] && continue
      # Skip aliases that wrap a shell builtin, a shell function, or another
      # alias. These never resolve through command -v in bash.
      case "$target" in
        cd|echo|source|command|builtin|eza|zinit|y|sf|tm|"$name") continue ;;
      esac
      if ! command -v "$target" >/dev/null 2>&1; then
        err "alias '$name' points at a missing command: $target"
        found=1
      fi
    done < <(grep -E "^alias [a-zA-Z0-9_-]+=" "$aliases" || true)
  fi

  if [[ $found -eq 0 ]]; then ok "every required binary and alias target resolves"; fi
}

check_referenced_paths() {
  skipped paths && return 0
  section "Referenced paths"

  # A broad "does every referenced path exist" scan gives mostly false
  # positives, because most sources are guarded by [[ -f ]] and many
  # directories are created on demand. These three patterns are high signal.
  local found=0 path rel

  # 1. Config that points back into this repo. These must exist, or the
  #    config is referencing a file that was renamed or deleted.
  while IFS= read -r path; do
    rel="${path#*dotfiles/}"
    if [[ ! -e "$DOTFILES_DIR/$rel" ]]; then
      err "config references a repo path that does not exist: $path"
      found=1
    fi
  done < <(
    grep -rhoE '(~|\$HOME|\$\{HOME\})/dotfiles/[A-Za-z0-9._/@-]+' \
      "$DOTFILES_DIR" --exclude-dir=.git --exclude-dir=tmp \
      --exclude=doctor.sh --exclude=README.md --exclude=CLAUDE.md 2>/dev/null |
      sed 's/[",;)]*$//' | sort -u || true
  )

  # 2. macOS applications named in live config must be installed. The macos
  #    bootstrap script and the *.example.* templates are excluded: the first
  #    creates what it references, the second holds placeholders.
  while IFS= read -r path; do
    case "$path" in
      *XXXX*) continue ;;
    esac
    if [[ ! -e "$path" ]]; then
      err "config references an application that is not installed: $path"
      found=1
    fi
  done < <(
    grep -rhoE '/Applications/[A-Za-z0-9 ._-]+\.app' \
      "$DOTFILES_DIR" --exclude-dir=.git --exclude-dir=tmp --exclude-dir=macos \
      --exclude=doctor.sh --exclude=Brewfile --exclude=README.md \
      --exclude='*.example.*' --exclude='*.template' 2>/dev/null |
      sort -u || true
  )

  # 3. Version-pinned tool paths go stale on the next upgrade.
  if grep -rqE 'mise/installs/[a-z]+/[0-9]+\.[0-9]+' \
    "$DOTFILES_DIR/zsh" "$DOTFILES_DIR/tmux" 2>/dev/null; then
    err "a version-pinned mise install path is hardcoded; let 'mise activate' supply it"
    found=1
  fi

  if [[ $found -eq 0 ]]; then ok "repo paths, applications, and tool paths all resolve"; fi
}

check_removed_tools() {
  skipped removed && return 0
  section "References to removed tools"

  # install-extensions.sh is excluded because it lists third-party Raycast
  # extensions by their upstream names and descriptions. Those strings are not
  # this repo's config, so a tool name inside one is not dead config.
  local hits
  hits="$(grep -rniE "$REMOVED_TOOLS" "$DOTFILES_DIR" \
    --exclude-dir=.git --exclude-dir=tmp --exclude-dir=docs \
    --exclude=CLAUDE.md --exclude=README.md --exclude=doctor.sh \
    --exclude=Brewfile --exclude=lazy-lock.json \
    --exclude=install-extensions.sh 2>/dev/null |
    grep -vE '^[^:]+:[0-9]+: *(#|--|//)' || true)"

  if [[ -n "$hits" ]]; then
    warn "references to removed tools remain (comments explaining history are fine):"
    echo "$hits" | sed "s|$DOTFILES_DIR/||" | sed 's/^/         /'
  else
    ok "no live references to removed tools"
  fi
}

check_brewfile() {
  skipped brewfile && return 0
  section "Brewfile"

  if ! command -v brew >/dev/null 2>&1; then
    warn "brew not found, skipping"
    return
  fi

  # Fetch the installed list once. Calling `brew list <pkg>` per entry costs
  # about a second each, which makes the whole check take minutes.
  local installed
  installed="$(
    { brew list --formula 2>/dev/null; brew list --cask 2>/dev/null; } |
      sed 's|.*/||' | sort -u
  )"

  local missing=0 pkg
  while IFS= read -r pkg; do
    if ! echo "$installed" | grep -qxF "$pkg"; then
      warn "Brewfile lists a package that is not installed: $pkg"
      missing=$((missing + 1))
    fi
  done < <(
    grep -E '^(brew|cask) "' "$DOTFILES_DIR/Brewfile" |
      sed 's/^[a-z]* "\([^"]*\)".*/\1/' | sed 's|.*/||' | sort -u || true
  )

  if [[ $missing -eq 0 ]]; then ok "every Brewfile formula is installed"; fi
}

check_git_hygiene() {
  section "Git hygiene"

  cd "$DOTFILES_DIR"
  local dirty
  dirty="$(git status --porcelain 2>/dev/null || true)"
  if [[ -n "$dirty" ]]; then
    warn "the working tree has uncommitted changes:"
    echo "$dirty" | sed 's/^/         /'
  else
    ok "working tree is clean"
  fi
}

# --- main -------------------------------------------------------------------

main() {
  if [[ $QUIET -eq 0 ]]; then printf "${GREEN}🩺 Checking dotfiles: %s${NC}\n" "$DOTFILES_DIR"; fi

  check_package_parity
  check_stow_conflicts
  check_broken_symlinks
  check_untracked_stowed
  check_referenced_binaries
  check_referenced_paths
  check_removed_tools
  check_brewfile
  check_git_hygiene

  printf "\n"
  if [[ $ERRORS -gt 0 ]]; then
    printf "${RED}✗ %d error(s), %d warning(s)${NC}\n" "$ERRORS" "$WARNINGS"
    exit 1
  fi
  printf "${GREEN}✓ no errors, %d warning(s)${NC}\n" "$WARNINGS"
}

main
