#!/usr/bin/env bash

# Ensure we have the full PATH including Homebrew
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

BOOKMARKS_FILE="${HOME}/.tmux/bookmarks"
FZF="/opt/homebrew/bin/fzf"

# Collect selection using fzf; each non-empty, non-comment line is a path
if [[ ! -f "$BOOKMARKS_FILE" ]]; then
  echo "No bookmarks file at $BOOKMARKS_FILE"
  echo "Create it with one absolute path per line."
  read -r -p "Press enter to close..."
  exit 1
fi

_clean() {
  sed '/^\s*#/d;/^\s*$/d' "$BOOKMARKS_FILE"
}

# Check if we have any bookmarks
bookmark_count=$(_clean | wc -l | tr -d ' ')
if [[ "$bookmark_count" -eq 0 ]]; then
  echo "No bookmarks found in $BOOKMARKS_FILE"
  read -r -p "Press enter to close..."
  exit 1
fi

# Make sure fzf is available
if [[ ! -x "$FZF" ]]; then
  echo "Error: fzf not found at $FZF"
  echo "PATH: $PATH"
  read -r -p "Press enter to close..."
  exit 1
fi

# Run fzf to select a bookmark
selection=$(_clean | "$FZF" --prompt="Project > " --height=100% --layout=reverse --border --no-info) || exit 0

# Exit if user cancelled (Esc)
[[ -z "${selection:-}" ]] && exit 0

path="$selection"
if [[ ! -d "$path" ]]; then
  printf "Directory not found: %s\n" "$path"
  read -r -p "Press enter to close..."
  exit 1
fi

# Create session name from directory basename
name=$(basename "$path" | tr -cs '[:alnum:]_-' '-' | tr '[:upper:]' '[:lower:]')

# If session exists, switch; otherwise create it rooted at the path
if tmux has-session -t "=${name}" 2>/dev/null; then
  tmux switch-client -t "=${name}"
else
  tmux new-session -ds "$name" -c "$path"
  tmux switch-client -t "=${name}"
fi

