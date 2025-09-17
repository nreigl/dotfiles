#!/usr/bin/env bash
set -euo pipefail

BOOKMARKS_FILE="${HOME}/.tmux/bookmarks"

# Collect selection using fzf; each non-empty, non-comment line is a path
if [[ ! -f "$BOOKMARKS_FILE" ]]; then
  echo "No bookmarks file at $BOOKMARKS_FILE"
  echo "Create it with one absolute path per line."
  read -r
  exit 1
fi

_clean() {
  sed '/^\s*#/d;/^\s*$/d' "$BOOKMARKS_FILE"
}

if command -v fzf >/dev/null 2>&1; then
  selection=$(_clean | fzf --prompt="Bookmarks > " --height=100% --layout=reverse --border)
else
  # Fallback: pick first entry if fzf is unavailable
  selection=$(_clean | head -n 1)
fi

[[ -z "${selection:-}" ]] && exit 0

path="$selection"
if [[ ! -d "$path" ]]; then
  printf "Directory not found: %s\n" "$path"
  read -r
  exit 1
fi

name=$(basename "$path" | tr -cs '[:alnum:]_-' '-' | tr '[:upper:]' '[:lower:]')

# If session exists, switch; otherwise create it rooted at the path
if tmux has-session -t "=${name}" 2>/dev/null; then
  tmux switch-client -t "=${name}"
else
  tmux new-session -ds "$name" -c "$path"
  tmux switch-client -t "=${name}"
fi

