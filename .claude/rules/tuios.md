---
paths:
  - "tuios/**"
---

# tuios (on trial)

- Settings-page and `tuios set-config` writes go through the symlink into the repo file.
- The leader is Ctrl+A with `preset = "tmux"`, the same keys as tmux and herdr.
- Do not run tuios inside herdr or tmux, because the outer one takes Ctrl+A first.
- On the Austrian layout `|`, `\`, `[`, and `]` need Option.
- tuios 0.12.1 reads Ctrl+A then Option+7 as `alt+7` and drops the `|`, so
  `[keybindings.prefix_mode]` binds the `alt+N` chords too. Remove them when
  tuios is newer than 0.12.1 (upstream commit d6cd422).
- zsh completion comes with the Homebrew formula.
