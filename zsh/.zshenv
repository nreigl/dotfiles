#!/usr/bin/env zsh

# Minimal, early environment for all zsh invocations (login, interactive, non-interactive)

# ZDOTDIR and XDG base dirs
export ZDOTDIR="${ZDOTDIR:-$HOME}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# Editors and pager
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# Temp files for zsh
if [[ -n "$TMPDIR" && -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  [[ -d "$TMPPREFIX" ]] || mkdir -p "$TMPPREFIX"
fi

# Keep PATH and plugin initialization in .zshrc to avoid side effects in non-interactive shells.
