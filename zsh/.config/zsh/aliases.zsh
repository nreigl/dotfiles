# Modern shell aliases

# === Core replacements with modern tools ===
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
  alias l='eza -l --icons --group-directories-first'
else
  alias ll='ls -la'
  alias la='ls -la'
  alias l='ls -l'
fi

command -v bat &>/dev/null && alias cat='bat --style=plain'
command -v rg &>/dev/null && alias grep='rg'
command -v fd &>/dev/null && alias find='fd'
command -v dust &>/dev/null && alias du='dust'
command -v duf &>/dev/null && alias df='duf'
command -v btop &>/dev/null && alias top='btop' && alias htop='btop'

# === Editor ===
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# === Git ===
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gm='git merge'
alias gr='git remote'
alias grs='git reset'
alias grh='git reset --hard'
alias gst='git stash'
alias gstp='git stash pop'
alias gf='git fetch'

# === Python ===
alias py='python3'
alias python='python3'
alias pip='uv pip'
alias venv='uv venv'
alias activate='source .venv/bin/activate'

# === Julia ===
alias jl='julia'
alias jlup='juliaup update'

# === Navigation ===
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'
# Zoxide interactive mode with automatic cd
unalias zz 2>/dev/null || true
zz() {
    local result=$(zoxide query -i "$@")
    [ -n "$result" ] && cd "$result"
}
# For zinit, use explicit name
alias zinit-update='zinit update --all'

# === Safety nets ===
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# === System ===
alias reload='source ~/.zshrc'
alias path='echo -e ${PATH//:/\\n}'
alias ports='netstat -tulanp'
alias myip='curl -s https://ipecho.net/plain; echo'
## Open current directory in Finder (Marta if installed)
# Keep this here (modern aliases) so it works even when ~/.aliases is
# disabled by the legacy guard. Accepts optional path arg, defaults to '.'
o() {
  local target
  target="${1:-.}"
  if [[ "$OSTYPE" == darwin* ]]; then
    if /usr/bin/open -Ra "Marta" >/dev/null 2>&1; then
      /usr/bin/open -a Marta "$target"
    else
      /usr/bin/open "$target"
    fi
  else
    command -v xdg-open >/dev/null 2>&1 && xdg-open "$target" || {
      echo "No system opener found for '$target'" >&2
      return 1
    }
  fi
}

# === Docker ===
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'

# === Kubernetes ===
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias klog='kubectl logs'

# === Misc ===
alias speedtest='speedtest-cli'
alias week='date +%V'
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# === Taskwarrior ===
alias twsync='tw_gtasks_sync -l "Taskwarrior" --all'

# === File managers ===
# yazi, with cd-on-quit.
y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# superfile, with cd-on-quit. Requires cd_on_quit = true in
# superfile/.config/superfile/config.toml.
#
# The upstream wrapper hardcodes the macOS path as
# "$HOME/Library/Application Support/superfile/lastdir". A Homebrew install
# writes to $XDG_STATE_HOME instead, so the upstream wrapper silently does
# nothing (superfile issue #1274). Ask the binary for the path instead.
sf() {
    local lastdir_file
    lastdir_file="$(command spf path-list --lastdir-file)" || return
    export SPF_LAST_DIR="$lastdir_file"
    command spf "$@"
    if [[ -f "$SPF_LAST_DIR" ]]; then
        source "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR"
    fi
    unset SPF_LAST_DIR
}

# === Terminal ===
# The Homebrew cask does not link a ghostty binary onto PATH, so the CLI is
# only reachable inside the app bundle. Useful subcommands:
#   ghostty +list-themes / +list-fonts / +list-actions / +list-keybinds
#   ghostty +validate-config                 check a config before reloading
#   ghostty +show-config --default --docs    every setting with its default
alias ghostty="/Applications/Ghostty.app/Contents/MacOS/ghostty"
