---
paths:
  - "zsh/**"
  - "ghostty/**"
  - "herdr/**"
---

# Shortcut popup (`cheat.zsh`)

- The popup opens with `?` on an empty line, or with Ctrl+/.
- It lists every `# cheat: <key or command>  <description>` comment in the
  sourced zsh files, in `ghostty/.config/ghostty/config`, and in
  `herdr/.config/herdr/config.toml`.
- Use two or more spaces between the key and the description.
- In the popup, Enter inserts a command and Alt+Enter runs it. For a zsh key,
  Alt+Enter runs the widget that the key is bound to in the emacs keymap.
- `cheat.zsh` must load after `atuin init`, because it takes `?` from Atuin AI,
  which moved to Alt+A.
