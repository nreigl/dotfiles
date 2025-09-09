#!/usr/bin/env zsh
# Modern, fast ZSH configuration

# === XDG Base Directory Specification ===
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# === Core Environment ===
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# === Path Configuration ===
# Clean PATH - no duplicates, ordered by priority
typeset -U path
path=(
  $HOME/.local/bin           # User binaries (UV, etc.)
  /opt/homebrew/bin          # Homebrew (Apple Silicon)
  /usr/local/bin             # Local binaries
  /usr/bin                   # System binaries
  /bin                       # Core binaries
  /usr/sbin                  # System admin
  /sbin                      # Core admin
  $path                      # Existing paths
)

# === History Configuration ===
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write timestamp
setopt INC_APPEND_HISTORY        # Write immediately
setopt SHARE_HISTORY             # Share between sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Remove duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate
setopt HIST_FIND_NO_DUPS         # Don't display duplicates
setopt HIST_IGNORE_SPACE         # Don't record space-prefixed
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates
setopt HIST_REDUCE_BLANKS        # Remove extra blanks
setopt HIST_VERIFY               # Show command before executing

# === Zinit Plugin Manager ===
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# === Fast Plugin Loading ===
# Load essential plugins first (without wait to avoid widget issues)
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search

# Load syntax highlighting after other plugins
zinit light zdharma-continuum/fast-syntax-highlighting

# Set key bindings for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Additional useful plugins (loaded async)
zinit wait lucid for \
  OMZL::git.zsh \
  OMZP::git \
  OMZP::sudo \
  OMZP::command-not-found

# === Modern Tool Initialization ===
# UV (Python)
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Mise (Universal version manager)
eval "$(mise activate zsh 2>/dev/null || true)"

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# FZF
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# === FZF Configuration ===
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796
  --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6
  --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
'

# === LaTeX Configuration ===
export PATH="$PATH:/usr/local/texlive/2023/bin/universal-darwin"

# === Completion System ===
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

# === Shell Options ===
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push directories to stack
setopt PUSHD_IGNORE_DUPS    # No duplicate directories
setopt PUSHD_SILENT         # No directory stack after pushd/popd
setopt CORRECT              # Spell correction
setopt CDABLE_VARS          # cd to variable
setopt EXTENDED_GLOB        # Extended globbing
setopt NO_CASE_GLOB         # Case insensitive globbing
setopt NUMERIC_GLOB_SORT    # Sort globs numerically
setopt NO_BEEP              # No beeping
setopt NOTIFY               # Report status of background jobs immediately

# === Key Bindings ===
bindkey -e  # Emacs key bindings
# These bindings are set after the plugin loads (see below)
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# === Aliases ===
# Modern replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --style=plain'
alias grep='rg'
alias find='fd'
alias du='dust'
alias df='duf'
alias top='btop'
alias htop='btop'
alias vim='nvim'
alias vi='nvim'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

# Python
alias py='python3'
alias pip='uv pip'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# === Functions ===
# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick backup
backup() {
  cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}

# === Load Additional Configs ===
# Load local machine-specific config if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# === Docker Completions ===
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=($HOME/.docker/completions $fpath)
fi

# === GitHub Copilot CLI ===
command -v gh &>/dev/null && eval "$(gh copilot alias -- zsh)"

# === Tmux Autostart (Optional) ===
# Uncomment to auto-start tmux
# [[ $- != *i* ]] && return
# [[ -z "$TMUX" ]] && exec tmux

# === Additional Aliases ===
# Source custom aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# === Final Setup ===
# Ensure XDG directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME/zsh"

# Welcome message (optional - comment out for faster startup)
# echo "🚀 ZSH loaded with modern tooling (UV, Mise, Starship, Zoxide)"
# echo "📦 Python: $(python3 --version 2>&1 | cut -d' ' -f2) | Julia: $(julia --version 2>&1 | cut -d' ' -f3)"