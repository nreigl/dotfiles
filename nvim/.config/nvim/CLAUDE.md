# LaTeX in Neovim (VimTeX)

This file holds the LaTeX gotchas for the Neovim config. The root `CLAUDE.md`
points here. The engine and the build directory live in `latex/.latexmkrc`.

**Math snippets (autotriggered, math zone only):**
- Every math trigger is guarded by `vimtex#syntax#in_mathzone()`, so two-letter triggers cannot fire in prose
- `vimtex_imaps_enabled = 0`, so VimTeX's own insert-mode maps do not compete with LuaSnip

**Where the compiler settings live.** The engine and the build directory are set
in `latex/.latexmkrc` (`$pdf_mode = 4`, `$out_dir = 'build'`), **not** in
`nvim/.config/nvim/lua/plugins/vimtex.lua`. VimTeX reads that file and derives
the `-lualatex` flag from it, latexmk obeys it directly, and texlab resolves the
log and the PDF through it. If the engine or the output path is set in the
Neovim config instead, texlab keeps looking in the project root and loses its
log diagnostics and its forward search. Adding engine flags to
`vimtex_compiler_latexmk.options` is documented as wrong
(`:h g:vimtex_compiler_latexmk`).

**Do not add `-file-line-error`.** It is absent from `latex/.latexmkrc` and from
`vimtex_compiler_latexmk.options` on purpose. The quickfix parser is `pplatex`,
which reads the classic `! Undefined control sequence.` form. Against a log in
`file:line:` form it reports zero errors and prints no warning, so the quickfix
list goes silent on every compile error while appearing to work. VimTeX strips
the flag from its own latexmk options, but it cannot strip it from the engine
commands in `.latexmkrc`. `pplatex` itself is built from source into
`~/.local/bin` (not in Homebrew, needs cmake and the deprecated `pcre`), so it is
absent on a new machine. `vimtex.lua` falls back to `latexlog` when it is
missing.

**Division of labour.** VimTeX owns compilation, viewing, SyncTeX, the table of
contents, motions, and citation/label completion. texlab is LSP-only: rename,
go-to-definition, symbols, hover, chktex. Leave `texlab.build.onSave` and
`forwardSearchAfter` at `false`, or two latexmk processes race on the same aux
files. Warning filters are duplicated on purpose in `vimtex_quickfix_ignore_filters`
and `texlab.diagnostics.ignoredPatterns` — VimTeX uses Vim regex, texlab uses
Rust regex, so the two lists cannot be shared.

**Completion configuration:**
- The `coding.nvim-cmp` extra in `lazyvim.json` enables nvim-cmp for every filetype and disables blink.cmp
