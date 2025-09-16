#!/usr/bin/env zsh
# FZF Custom Functions and Keybindings

# === Git Integration ===
# Ctrl-G: Search git files
fzf-git-files() {
  local files
  files=$(git ls-files --others --exclude-standard --cached 2>/dev/null | \
    fzf --multi --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range :500 {} || sed -n "1,200p" {}')
  [[ -n "$files" ]] && ${EDITOR:-nvim} $files
}

# Ctrl-B: Checkout git branch
fzf-git-branch() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Ctrl-H: Search git commit history
fzf-git-history() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF"
}

# === File Search with Preview ===
# Ctrl-F: Find file with preview
fzf-file-preview() {
  (command -v fd >/dev/null 2>&1 && fd --type f --hidden --follow --exclude .git || \
    rg --files --hidden --follow -g '!*.git/*') |
    fzf --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range :500 {} || sed -n "1,200p" {}' \
        --bind 'ctrl-/:change-preview-window(down|hidden|)'
}

# === Directory Navigation ===
# Alt-C: Enhanced directory navigation
fzf-cd-widget() {
  local dir
  dir=$( (command -v fd >/dev/null 2>&1 && fd --type d --hidden --follow --exclude .git || \
    find . -type d -not -path '*/.git/*' 2>/dev/null) | \
    fzf --preview 'command -v eza >/dev/null 2>&1 && eza --tree --level=2 --icons {} || ls -lah {}')
  [[ -n "$dir" ]] && cd "$dir"
}

# === Process Management ===
# Ctrl-P: Kill process
fzf-kill-process() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# === Docker Integration ===
# List and manage Docker containers
fzf-docker() {
  local container
  container=$(docker ps -a | sed 1d | fzf --multi | awk '{print $1}')
  [[ -n "$container" ]] && docker rm $container
}

# === Homebrew Integration ===
# Search and install Homebrew packages
fzf-brew-install() {
  local inst=$(brew formulae | fzf --multi --preview 'brew info {}')
  [[ -n "$inst" ]] && brew install $inst
}

# === Keybindings ===
# Register ZLE widgets and set keybindings
if [[ $- == *i* ]]; then
  # Register widgets first
  zle -N fzf-git-files
  zle -N fzf-git-branch
  zle -N fzf-file-preview
  zle -N fzf-cd-widget
  
  # Then bind keys
  bindkey '^g' fzf-git-files
  bindkey '^b' fzf-git-branch
  bindkey '^f' fzf-file-preview
  bindkey '\\ec' fzf-cd-widget  # Alt-C
fi

# === Aliases ===
alias fgh='fzf-git-history'  # Changed from fh to avoid conflict
alias fkill='fzf-kill-process'
alias fdocker='fzf-docker'
alias fbrew='fzf-brew-install'

# === Enhanced ripgrep integration ===
# Search content in files with live preview
frg() {
  local result
  result=$(
    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
      fzf --ansi \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'command -v bat >/dev/null 2>&1 && bat --color=always {1} --highlight-line {2} || sed -n "1,200p" {1}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
  )
  [[ -n "$result" ]] && ${EDITOR:-nvim} $(echo "$result" | cut -d: -f1) +$(echo "$result" | cut -d: -f2)
}

# Search and edit files
fe() {
  local files
  files=$( ( (command -v fd >/dev/null 2>&1 && fd "${1:-.}" --type f --hidden --follow --exclude .git) || \
    rg --files --hidden --follow -g '!*.git/*') | fzf --multi --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always {} || sed -n "1,200p" {}')
  [[ -n "$files" ]] && ${EDITOR:-nvim} $files
}

# === Enhanced History Search ===
# Search command history with preview showing when command was run
fh() {
  local cmd
  cmd=$(history -n 1 | fzf --tac --no-sort --query="$1" \
    --preview 'echo {} | sed "s/^[ ]*[0-9]*[ ]*//" | (bat --language=sh --style=plain --color=always 2>/dev/null || cat)' \
    --preview-window='up:3:wrap' \
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)+abort' \
    --header='Press CTRL-Y to copy command')
  [[ -n "$cmd" ]] && print -z "$cmd"
}

# === Environment Variables ===
# Search and edit environment variables
fenv() {
  local var
  var=$(printenv | fzf --preview 'echo {1} | cut -d= -f2' --preview-window=up:3:wrap)
  [[ -n "$var" ]] && echo "$var" | cut -d= -f1
}

# === NPM/Yarn Scripts ===
# Run npm/yarn scripts with FZF
fnpm() {
  if [[ -f package.json ]]; then
    local script
    script=$(cat package.json | jq -r '.scripts | keys[]' 2>/dev/null | \
      fzf --preview "cat package.json | jq -r '.scripts.\\"{}\\"'" \
          --preview-window=up:3:wrap \
          --header='Select npm script to run')
    [[ -n "$script" ]] && npm run "$script"
  else
    echo "No package.json found"
  fi
}

# === SSH Host Selector ===
# Quick SSH into hosts from ~/.ssh/config
fssh() {
  local host
  host=$(grep "^Host " ~/.ssh/config 2>/dev/null | \
    grep -v "*" | \
    cut -d" " -f2- | \
    fzf --preview 'grep -A 5 "^Host {}" ~/.ssh/config' \
        --preview-window=up:10:wrap)
  [[ -n "$host" ]] && ssh "$host"
}

# === Tmux Session Manager ===
# Switch or create tmux sessions
ftmux() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
    fzf --preview 'tmux list-windows -t {} -F "#{window_index}: #{window_name} (#{window_panes} panes)"' \
        --preview-window=up:10:wrap \
        --header='Select tmux session (or type new name to create)')
  
  if [[ -n "$session" ]]; then
    if tmux has-session -t "$session" 2>/dev/null; then
      if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$session"
      else
        tmux attach-session -t "$session"
      fi
    else
      tmux new-session -s "$session"
    fi
  fi
}

# === Git Stash Manager ===
# Browse and apply git stashes
fstash() {
  local stash
  stash=$(git stash list | \
    fzf --preview 'echo {} | cut -d: -f1 | xargs git stash show -p --color=always' \
        --preview-window=up:60% \
        --bind='ctrl-d:execute(echo {} | cut -d: -f1 | xargs git stash drop)+reload(git stash list)' \
        --header='Enter: apply, Ctrl-D: drop')
  
  [[ -n "$stash" ]] && git stash apply $(echo "$stash" | cut -d: -f1)
}

# === Git Diff Explorer ===
# Browse changed files with diff preview
fgd() {
  local file
  file=$(git diff --name-only | \
    fzf --preview 'git diff --color=always {}' \
        --preview-window=up:60% \
        --bind='ctrl-s:execute(git add {})+reload(git diff --name-only)' \
        --header='Enter: edit, Ctrl-S: stage')
  
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# === Port Process Finder ===
# Find what's running on a port
fport() {
  local port="${1:-}"
  if [[ -z "$port" ]]; then
    lsof -iTCP -sTCP:LISTEN -n -P | \
      fzf --header-lines=1 \
          --preview 'echo {} | awk "{print \$2}" | xargs ps -p' \
          --preview-window=up:10:wrap
  else
    lsof -iTCP:$port -sTCP:LISTEN -n -P
  fi
}

# === Zoxide Integration ===
# Enhanced directory jumping with fzf
# Unlike 'zi' (zoxide interactive), this enables fuzzy matching and customization
# Usage: zz [query] - fuzzy search through frecent directories
# Example: zz dot -> search for directories containing "dot"
zz() {
  local dir
  dir=$(zoxide query --list --score | \
    sed 's/^ *//' | \
    fzf --height 40% \
        --layout reverse \
        --info inline \
        --nth 2.. \
        --tac \
        --no-sort \
        --query "$*" \
        --preview 'command -v eza >/dev/null 2>&1 && eza --tree --level=2 --icons {2..} || ls -lah {2..}' \
        --preview-window 'right:40%' \
        --bind 'enter:become:echo {2..}')
  [[ -n "$dir" ]] && cd "$dir"
}
