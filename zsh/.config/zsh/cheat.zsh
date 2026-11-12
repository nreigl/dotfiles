#!/usr/bin/env zsh
# Shortcut reminder popup. Press ? on an empty line, or Ctrl+/ anywhere.
#
# The list comes from tag comments in the files that .zshrc sources, and in
# the Ghostty and herdr configs, so terminal keys can sit next to their
# bindings. A tag is
# a comment line: the word "cheat" and a colon, then the key or command, then
# two or more spaces, then a short description. See .zshrc for examples.
# This file is not scanned, so the popup code never shows up in the list.

# True if the entry is a key combo, not a command to type.
_cheat_is_key() {
  emulate -L zsh
  setopt extended_glob
  [[ $1 == (Ctrl|Alt|Cmd|Shift|Esc|Tab|Up|Down|F<->)* || $1 == '?' ]]
}

# Print one aligned line per tag: key or command, then the description.
# Key combos come first, then commands, each group in file order.
_cheat_entries() {
  emulate -L zsh
  setopt extended_glob
  local -a files keys cmds
  files=(
    ~/.zshrc(N)
    ~/.zshrc.local(N)
    ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/*.zsh(N)
    ${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config(N)
    ${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml(N)
  )
  files=(${files:#*/cheat.zsh})

  local f line key desc entry
  for f in $files; do
    while IFS= read -r line; do
      [[ $line == [[:space:]]#\#\ cheat:\ * ]] || continue
      line=${line#*\# cheat: }
      key=${line%%  *}
      desc=${${line#*  }##[[:space:]]#}
      printf -v entry '%-12s  %s' "$key" "$desc"
      if _cheat_is_key "$key"; then
        keys+=("$entry")
      else
        cmds+=("$entry")
      fi
    done < $f
  done
  print -rl -- $keys $cmds
}

# Print the zle widget that a tag key such as Ctrl+O or Alt+C runs in the
# emacs keymap. Fail for keys that zsh never sees (Cmd+..., herdr chords),
# for unbound keys, and for the popup keys themselves.
_cheat_key_widget() {
  emulate -L zsh
  local part seq='' out widget
  for part in ${(s: :)1}; do
    case $part in
      Ctrl+/)       seq+='^_' ;;
      Ctrl+[A-Za-z]) seq+="^${(U)part#Ctrl+}" ;;
      Alt+[A-Za-z])  seq+="^[${(L)part#Alt+}" ;;
      Esc)          seq+='^[' ;;
      *)            return 1 ;;
    esac
  done
  out=$(bindkey -M emacs "$seq") || return 1
  widget=${out##* }
  [[ $out == \"$seq\"\ * ]] || return 1
  [[ $widget == (undefined-key|self-insert|cheat-popup|cheat-question-mark) ]] && return 1
  print -r -- $widget
}

# Open the list in fzf.
#   Enter      a command goes onto the command line and does not run.
#              A key combo only closes the list.
#   Alt+Enter  a command runs. A zsh key combo runs its widget, for example
#              Ctrl+O opens the file picker. Ghostty and herdr keys only
#              close the list, because zsh never sees those keys.
cheat-popup() {
  emulate -L zsh
  if (( ! $+commands[fzf] )); then
    zle -M "cheat: fzf is not installed"
    return 1
  fi

  local out pressed sel key widget
  out=$(_cheat_entries | fzf --height 40% --layout reverse --border \
    --prompt 'shortcuts> ' --no-multi --no-preview \
    --header 'Enter: insert   Alt+Enter: run   Esc: close' \
    --expect alt-enter)
  pressed=${out%%$'\n'*}
  sel=${out#*$'\n'}
  [[ $out == *$'\n'* ]] || sel=''
  key=${sel%%  *}

  if [[ -z $sel ]]; then
    zle reset-prompt
  elif [[ $pressed != alt-enter ]]; then
    _cheat_is_key "$key" || LBUFFER+="$key "
    zle reset-prompt
  elif ! _cheat_is_key "$key"; then
    # Keep any text on the line. push-line returns it at the next prompt.
    [[ -n $BUFFER ]] && zle push-line
    BUFFER=$key
    zle accept-line
  elif widget=$(_cheat_key_widget "$key"); then
    zle reset-prompt
    zle $widget
  else
    zle reset-prompt
  fi
}

# ? opens the list on an empty line only. Anywhere else it types a literal ?,
# so globs such as file?.txt keep working. For a ? at the start of a line,
# press Ctrl+V, then ?.
cheat-question-mark() {
  if [[ -z $BUFFER ]]; then
    zle cheat-popup
  else
    zle self-insert
  fi
}

# Atuin AI moved from ? to Alt+A. The Atuin widget types the pressed key on a
# non-empty line, which for Alt+A is an "a", so call it on an empty line only.
cheat-atuin-ai() {
  [[ -z $BUFFER ]] || return 0
  if (( $+widgets[self-atuin-ai-question-mark] )); then
    zle self-atuin-ai-question-mark
  else
    zle -M "cheat: Atuin AI is not loaded"
  fi
}

if [[ $- == *i* ]]; then
  zle -N cheat-popup
  zle -N cheat-question-mark
  zle -N cheat-atuin-ai

  # Source this file after `atuin init`, which binds ? to Atuin AI.
  bindkey -M emacs '?' cheat-question-mark
  bindkey -M emacs '^_' cheat-popup       # Ctrl+/ (undo stays on Ctrl+X U)
  bindkey -M emacs '^[a' cheat-atuin-ai   # Alt+A (was accept-and-hold)
fi
