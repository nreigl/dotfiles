#!/usr/bin/env zsh
# FZF Custom Functions and Keybindings

# === Git Integration ===
# Ctrl-G: Search git files
fzf-git-files() {
  local files
  files=$(git ls-files --others --exclude-standard --cached 2>/dev/null | \
    fzf --multi --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range :500 {} || sed -n "1,200p" {}')
  [[ -n "$files" ]] && ${EDITOR:-nvim} ${(f)files}
  zle && zle reset-prompt
}

# Alt-G: Checkout git branch
fzf-git-branch() {
  local branches branch
  branches=$(git branch --all | command grep -v HEAD) &&
  branch=$(echo "$branches" | fzf +m \
    --preview 'git log --oneline --graph --decorate --color=always -n 30 {-1}' \
    --preview-window 'right:60%') &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  zle && zle reset-prompt
}

# Ctrl-H: Search git commit history
fzf-git-history() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs -I % git show --color=always --stat %' \
    --preview-window 'right:60%' \
    --header 'Enter: full diff in less, Ctrl-S: toggle sort' \
    --bind "ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF"
}

# === File Search with Preview ===
# Ctrl-O: Find file with preview, open in the editor
fzf-file-preview() {
  local file
  file=$( (command -v fd >/dev/null 2>&1 && fd --type f --hidden --follow --exclude .git || \
    rg --files --hidden --follow -g '!*.git/*') |
    fzf --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range :500 {} || sed -n "1,200p" {}')
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
  zle && zle reset-prompt
}

# === Directory Navigation ===
# Alt-C: Enhanced directory navigation.
# Named fzf-my-cd-widget so it does not shadow fzf's own fzf-cd-widget.
fzf-my-cd-widget() {
  local dir
  dir=$( (command -v fd >/dev/null 2>&1 && fd --type d --hidden --follow --exclude .git || \
    command find . -type d -not -path '*/.git/*' 2>/dev/null) | \
    fzf --preview 'command -v eza >/dev/null 2>&1 && eza --tree --level=2 --icons {} || ls -lah {}')
  [[ -n "$dir" ]] && cd "$dir"
  zle && zle reset-prompt
}

# === Process Management ===
# Ctrl-P: Kill process
fzf-kill-process() {
  local pid
  pid=$(ps -ef | sed 1d | \
    fzf -m \
        --preview 'ps -p {2} -o pid,ppid,user,%cpu,%mem,etime,command' \
        --preview-window 'up:6:wrap' \
        --header "Select processes, Enter sends SIG${1:-KILL}" | \
    awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# === Docker Integration ===
# List and manage Docker containers
fzf-docker() {
  local container
  container=$(docker ps -a | sed 1d | \
    fzf --multi \
        --preview 'docker inspect {1} | head -80' \
        --preview-window 'right:60%' \
        --header 'WARNING: Enter removes the selected containers' | \
    awk '{print $1}')
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
  zle -N fzf-my-cd-widget

  # Then bind keys.
  # ctrl-f and ctrl-b stay on forward-char / backward-char.
  bindkey '^g' fzf-git-files
  bindkey '\eg' fzf-git-branch    # Alt-G
  bindkey '^o' fzf-file-preview   # Ctrl-O
  bindkey '\ec' fzf-my-cd-widget  # Alt-C
fi

# === Aliases ===
alias fgh='fzf-git-history'  # Changed from fh to avoid conflict
alias fkill='fzf-kill-process'
alias fdocker='fzf-docker'
alias fbrew='fzf-brew-install'

# === Enhanced ripgrep integration ===
# Search content in files with live preview
# ripgrep re-runs on every keystroke, so fzf never has to hold the whole tree.
# ripgrep re-runs on every keystroke, so fzf never holds the whole tree.
# Select one hit to open it. Select several with Tab to open them as a
# Neovim quickfix list. Follows the upstream ripgrep-integration recipe.
frg() (
  local editor=${EDITOR:-nvim}
  local RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  local OPENER="if [[ \$FZF_SELECT_COUNT -eq 0 ]]; then
                  $editor {1} +{2}
                else
                  $editor +cw -q {+f}
                fi"
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" \
      --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --delimiter : \
      --preview 'command -v bat >/dev/null 2>&1 && bat --style=full --color=always --highlight-line {2} {1} || sed -n "1,200p" {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --header 'Tab: multi-select -> quickfix, Ctrl-O: open without leaving' \
      --query "$*"
)

# Search and edit files
fe() {
  local files
  files=$( ( (command -v fd >/dev/null 2>&1 && fd "${1:-.}" --type f --hidden --follow --exclude .git) || \
    rg --files --hidden --follow -g '!*.git/*') | fzf --multi --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always {} || sed -n "1,200p" {}')
  [[ -n "$files" ]] && ${EDITOR:-nvim} $files
}

# === Enhanced History Search ===
# Removed: fh. Atuin owns Ctrl-R and gives a better history UI.
# Use Ctrl-R, or `atuin search <query>` for a non-interactive list.

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
    script=$(jq -r '.scripts | keys[]' package.json 2>/dev/null | \
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
  # `command` bypasses the grep=rg alias. rg rejects "*" as a regex.
  host=$(command grep "^Host " ~/.ssh/config 2>/dev/null | \
    cut -d" " -f2- | \
    tr ' ' '\n' | \
    command grep -v '[*?]' | \
    sort -u | \
    fzf --preview 'grep -A 5 "^Host {}" ~/.ssh/config' \
        --preview-window=up:10:wrap)
  [[ -n "$host" ]] && ssh "$host"
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

# === Open in Default Application ===
# Find file with fzf and open in default macOS application
fo() {
  local file
  file=$( (command -v fd >/dev/null 2>&1 && fd --type f --hidden --follow --exclude .git || \
    rg --files --hidden --follow -g '!*.git/*') | \
    fzf --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range :500 {} || file {}')
  [[ -n "$file" ]] && open "$file"
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
