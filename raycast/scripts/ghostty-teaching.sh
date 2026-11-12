#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Ghostty Teaching Mode
# @raycast.mode silent
# @raycast.packageName Ghostty

# @raycast.icon 🎓

# @raycast.description Switch every open Ghostty window between the daily theme and the light teaching overlay.
# @raycast.author Nicolas Reigl

set -euo pipefail

# ~/.config/ghostty/config includes "?teaching-active". This script creates
# or removes that symlink, then asks Ghostty to reload its config.
# Opacity does not reload on macOS. Press Cmd+Shift+O for an opaque window.
dir="$HOME/.config/ghostty"
link="$dir/teaching-active"

if [[ -L "$link" || -e "$link" ]]; then
  command rm -f -- "$link"
  state="off"
else
  if [[ ! -f "$dir/teaching" ]]; then
    echo "Missing $dir/teaching. Run: stow ghostty"
    exit 1
  fi
  ln -s teaching "$link"
  state="on"
fi

# "is running" keeps the script from starting Ghostty. Without a window
# there is no terminal to target, and the next launch reads the file anyway.
reloaded="$(osascript <<'EOF'
if application id "com.mitchellh.ghostty" is running then
  tell application id "com.mitchellh.ghostty"
    if (count of windows) is 0 then return "no-window"
    perform action "reload_config" on focused terminal of selected tab of front window
    return "yes"
  end tell
end if
return "not-running"
EOF
)"

case "$reloaded" in
  yes) echo "Ghostty teaching mode: $state" ;;
  *)   echo "Ghostty teaching mode: $state (applies at the next start)" ;;
esac
