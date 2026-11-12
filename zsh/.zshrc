#!/usr/bin/env zsh
# Modern, fast ZSH configuration

# XDG base directories are defined in ~/.zshenv

# === Core Environment ===
# EDITOR and VISUAL are set in .zshenv (always sourced first)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# === Path Configuration ===
# Clean PATH - no duplicates, ordered by priority
typeset -U path
path=(
  $HOME/.local/bin           # User binaries (UV, etc.)
  /opt/homebrew/bin          # Homebrew (Apple Silicon)
  /opt/homebrew/sbin
  /usr/local/bin             # Local binaries
  /usr/bin                   # System binaries
  /bin                       # Core binaries
  /usr/sbin                  # System admin
  /sbin                      # Core admin
  $path                      # Existing paths
)
# Tool directories. Installers append `export PATH=...` lines to the end of
# this file; move them up here instead. Missing directories are dropped by
# the (N) glob qualifier, so the list can hold tools that are not installed.
path+=(
  $HOME/.antigravity/antigravity/bin(N)
  $HOME/.antigravity-ide/antigravity-ide/bin(N)
  $HOME/.kimi-code/bin(N)
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

# === Keymap ===
# Select the emacs keymap before any plugin or tool binds a key.
# EDITOR=nvim makes zsh start in viins, so a plain `bindkey` that runs before
# this line lands in viins and is lost (this broke the `?` binding of Atuin AI).
bindkey -e

# === Zinit Plugin Manager ===
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# === Fast Plugin Loading ===
# zsh-completions adds to fpath, so it loads before compinit.
# fzf-tab, autosuggestions and syntax highlighting load in turbo mode after
# compinit (see the Completion System section).
zinit light zsh-users/zsh-completions

# Additional useful plugins (loaded async)
# cheat: Esc Esc   put sudo in front of the current command
zinit wait lucid for \
  OMZP::sudo \
  OMZP::command-not-found

# === Modern Tool Initialization ===
# UV (Python)
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Mise (Universal version manager)
eval "$(mise activate zsh 2>/dev/null || true)"

# direnv (per-directory env)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Zoxide (smart cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
# zinit defines `alias zi=zinit`, which hides the zi function of zoxide.
unalias zi 2>/dev/null

# === FZF Configuration ===
# Set before key-bindings.zsh loads, so the widgets see it.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# FZF_ALT_C_* drive fzf's own fzf-cd-widget only. In the emacs keymap, Alt-C
# runs fzf-my-cd-widget (fzf-functions.zsh), which ignores them. The vi
# keymaps keep the fzf widget.
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
# Previews for fzf's own Ctrl-T and Alt-C widgets
export FZF_CTRL_T_OPTS="--preview '$XDG_CONFIG_HOME/fzf/preview-file {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=always {} 2>/dev/null || ls -lah {}'"
# Options live in the fzf stow package, not inline here.
export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/fzfrc"

# Use fzf key-bindings only; skip fzf's completion (fzf-tab handles completion)
# cheat: Ctrl+T   fzf: pick a file and insert its path at the cursor
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi
# Optional user FZF config
[[ -f "$XDG_CONFIG_HOME/fzf/fzf.zsh" ]] && source "$XDG_CONFIG_HOME/fzf/fzf.zsh"

# Atuin (smart, syncable shell history + Ctrl-R UI)
# Init after FZF so Atuin's Ctrl-R takes precedence.
# Atuin puts its own strategy in front of this list. Autosuggestions loads
# later (turbo mode), so set the history fallback here.
ZSH_AUTOSUGGEST_STRATEGY=(history)
# cheat: Ctrl+R   Atuin: search shell history
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# === LaTeX Configuration ===
# Add the latest TeXLive installation to PATH
if [[ -d "/usr/local/texlive" ]]; then
  # Find the latest year directory
  LATEST_TEXLIVE=$(ls -d /usr/local/texlive/20* 2>/dev/null | sort -r | head -1)
  if [[ -n "$LATEST_TEXLIVE" && -d "$LATEST_TEXLIVE/bin/universal-darwin" ]]; then
    path+=("$LATEST_TEXLIVE/bin/universal-darwin")
  fi
fi

# === Completion System ===
autoload -Uz compinit
# Ensure ZDOTDIR fallback and use a stable dump path
ZDOTDIR=${ZDOTDIR:-$HOME}
zcompdump="$ZDOTDIR/.zcompdump"
# Do the full check (compaudit and a new dump) once per day only. On other
# starts, -C reads the dump as it is. If you add a completion file to fpath,
# delete the dump to see it before the next full check.
() {
  setopt local_options extended_glob
  if [[ -n $zcompdump(#qN.mh+24) ]]; then
    compinit -d "$zcompdump"
    touch "$zcompdump"
  else
    compinit -C -d "$zcompdump"
  fi
}
# zoxide registers its completion for z only if compdef exists, and zoxide
# init runs before compinit. Register it here.
(( $+functions[__zoxide_z_complete] )) && compdef __zoxide_z_complete z

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

# Interactive plugins in turbo mode. They load in this order after the first
# prompt. fzf-tab needs compinit, and it must load before the plugins that
# wrap widgets. Syntax highlighting loads last, after all widgets exist.
# atload starts autosuggestions, because its precmd hook has already run.
# nocd keeps atload in $PWD. The plugin repo holds a .ruby-version (2.5.3),
# and a prompt redraw inside it makes mise and starship ask for that Ruby.
zinit wait lucid for \
    Aloxaf/fzf-tab \
  atload'_zsh_autosuggest_start' nocd \
    zsh-users/zsh-autosuggestions \
    zdharma-continuum/fast-syntax-highlighting
# Minimal but useful fzf-tab styles
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' extended-search yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' show-group auto
zstyle ':fzf-tab:*' fzf-flags --preview-window='right:60%:wrap,border'

# Generic file preview
zstyle ':fzf-tab:complete:*' fzf-preview 'bat --style=numbers --color=always --line-range=:500 -- {1} 2>/dev/null || sed -n "1,200p" -- {1}'

# Directory preview for cd/ls/eza
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -a --icons --group-directories-first -1 -- {1} 2>/dev/null || ls -la -- {1}'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -a --icons --group-directories-first -1 -- {1} 2>/dev/null || ls -la -- {1}'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -a --icons --group-directories-first -1 -- {1} 2>/dev/null || ls -la -- {1}'

# Useful previews for common tools
zstyle ':fzf-tab:complete:git-(add|restore):*' fzf-preview 'git diff --color=always -- {1} 2>/dev/null | sed -n "1,200p"'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always --oneline --graph --decorate {1} -n 30 2>/dev/null'
zstyle ':fzf-tab:complete:brew-(install|info|upgrade):*' fzf-preview 'brew info --color=always {1} 2>/dev/null | sed -n "1,200p"'
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man -P cat {1} 2>/dev/null | col -bx | sed -n "1,120p"'

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
# `bindkey -e` runs near the top of this file (see Keymap)
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# === Aliases ===
# Aliases are sourced from $XDG_CONFIG_HOME/zsh/aliases.zsh further down, after
# the interactive setup. See the "Additional Aliases" section.

# === Functions ===
# Load shared functions to avoid duplication
[[ -f "$XDG_CONFIG_HOME/zsh/functions.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/functions.zsh"

# === Load Additional Configs ===
# Load local machine-specific config if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Load API keys and tokens. Copy ~/.zsh_secrets.template to ~/.zsh_secrets and
# fill it in. Never commit the filled-in file.
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# === GitHub Copilot CLI ===
# New `gh copilot` is an agentic assistant; it no longer exposes `alias`.
# Wrap `-p` (one-shot prompt) to reproduce the old ghcs/ghce UX.
if command -v gh &>/dev/null; then
  ghcs() {
    gh copilot -p "Suggest a single shell command for: $*. Reply with the command in a code block, then a one-line explanation."
  }
  ghce() {
    gh copilot -p "Explain this shell command: $*"
  }
fi

# === Additional Aliases ===
# Source ZSH aliases from config directory
[[ -f "$XDG_CONFIG_HOME/zsh/aliases.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/aliases.zsh"

# Source FZF functions
[[ -f "$XDG_CONFIG_HOME/zsh/fzf-functions.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/fzf-functions.zsh"

# Shortcut reminder popup. It must load after `atuin init`, which binds ?.
# cheat: ?   show this list (on an empty line)
# cheat: Ctrl+/   show this list (anywhere)
# cheat: Alt+A   Atuin AI: describe a task, get a command (on an empty line)
[[ -f "$XDG_CONFIG_HOME/zsh/cheat.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/cheat.zsh"

# === Final Setup ===
# Ensure XDG directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME/zsh"

# Define z once (built on zoxide) for consistent navigation
# cheat: z   zoxide: jump to a frequent folder (no args: pick one in fzf)
unfunction z 2>/dev/null || true
z() {
  if [[ $# -eq 0 ]]; then
    local dir
    dir=$(zoxide query --list --score | \
      sed 's/^ *//' | \
      fzf --height 40% \
          --layout reverse \
          --info inline \
          --nth 2.. \
          --tac \
          --no-sort \
          --preview 'eza --tree --level=2 --icons=always {2..}' \
          --bind 'enter:become:echo {2..}')
    [[ -n "$dir" ]] && cd "$dir"
  elif [[ $# -eq 1 && ( "$1" == - || -d "$1" ) ]]; then
    # `z -`, `z ..` and `z /path` change directory without a zoxide query.
    cd -- "$1"
  else
    local dir
    dir=$(zoxide query -- "$@") || return
    [[ -n "$dir" ]] || return 1
    cd -- "$dir"
  fi
}

# === Multiplexers: explicit, never auto-attach ===
# Auto-attaching tmux in WezTerm nested herdr inside tmux (tmux swallowed the
# ctrl+a prefix). Shells now start plain; pick a multiplexer per window:
#   tm    -> tmux main session
#   herdr -> agent workspace manager
alias tm='/opt/homebrew/bin/tmux new-session -A -s main'

# This wrapper drops CLAUDE_CODE_CHILD_SESSION. Claude Code sets that
# marker on processes it spawns so nested sessions skip writing their own
# transcript. A `claude` launched by hand from a Claude-spawned terminal
# inherits it, silently loses its transcript, and cannot be --resume'd.
# Launching from an interactive shell always means a real top-level session.
#
# The wrapper no longer exports GITHUB_PERSONAL_ACCESS_TOKEN. Only the GitHub
# MCP plugin read it, and that plugin is disabled since 2026-11-07. If you
# enable the plugin again, add the `gh auth token` export back here.
claude() {
  env -u CLAUDE_CODE_CHILD_SESSION claude "$@"
}
