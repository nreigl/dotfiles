return {
  {
    "lervag/vimtex",
    lazy = false, -- CRITICAL: Never lazy load VimTeX!
    init = function()
      -- Note: maplocalleader is set in init.lua

      -- Use Skim on macOS (you have it installed)
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      -- Keep activate off: with continuous = 1, a value of 1 pulls Skim to the
      -- foreground after every successful rebuild, which interrupts writing.
      vim.g.vimtex_view_skim_activate = 0
      vim.g.vimtex_view_skim_reading_bar = 1
      vim.g.vimtex_view_skim_no_select = 1

      -- Compiler settings.
      -- The engine and the output directory are NOT set here. latex/.latexmkrc
      -- carries $pdf_mode = 4 (lualatex) and $out_dir = 'build'. VimTeX reads
      -- that file and derives the engine flag, and texlab reads it too, so all
      -- three tools agree. Adding engine flags to `options` is documented as
      -- wrong (:h g:vimtex_compiler_latexmk).
      vim.g.vimtex_compiler_latexmk = {
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        -- -file-line-error is deliberately absent: pplatex reports 0 errors
        -- against a log in file:line: form. See latex/.latexmkrc, which drops
        -- the flag from the engine commands for the same reason.
        options = {
          "-verbose",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- Disable mappings that conflict with LazyVim.
      -- Keep this here, not in `config`: the `config` function below replaces
      -- LazyVim's tex-extra `config` (lazy.nvim overwrites functions instead of
      -- merging them), so the extra's own copy of this line never runs.
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }

      -- LuaSnip owns insert-mode expansion. VimTeX's own imaps overlap with a
      -- math snippet set and depend on keypress timing.
      vim.g.vimtex_imaps_enabled = 0

      -- Folding is off by default and long papers need it. The fold expression
      -- is slow on large files, so fold manually.
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_fold_manual = 1

      -- Matchparen is the first documented cause of VimTeX slowness, and it
      -- double-highlights under conceallevel = 2.
      vim.g.vimtex_matchparen_enabled = 0

      -- `csc` over an environment renames \begin and \end together.
      vim.g.vimtex_env_change_autofill = 1
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      
      -- Better syntax and concealing
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
      
      -- Quickfix filters for cleaner output
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Command terminated with space",
        "LaTeX Font Warning: Font shape",
        "Package caption Warning: The option",
        [[Underfull \\hbox (badness [0-9]*) in]],
        "Package enumitem Warning: Negative labelwidth",
        [[Package caption Warning: Unused \\captionsetup]],
        "Package typearea Warning: Bad type area settings!",
        [[Package fancyhdr Warning: \\headheight is too small]],
        [[Underfull \\hbox (badness [0-9]*) in paragraph at lines]],
        "Package hyperref Warning: Token not allowed in a PDF string",
      }

      -- Enable VimTeX completion (cmp-vimtex uses VimTeX's parser)
      -- texlab LSP provides go-to-definition and diagnostics for LaTeX
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_complete_close_braces = 1

      -- Use simple ref completion to avoid large preview windows
      vim.g.vimtex_complete_ref = { simple = 1 }

      -- Use VimTeX's native Neovim parser. It needs no external executable.
      vim.g.vimtex_parser_bib_backend = "lua"
    end,
    config = function()
      -- Auto-set conceallevel for LaTeX files
      vim.api.nvim_create_autocmd({ "FileType" }, {
        group = vim.api.nvim_create_augroup("lazyvim_vimtex_conceal", { clear = true }),
        pattern = { "bib", "tex" },
        callback = function()
          vim.wo.conceallevel = 2
        end,
      })
    end,
    keys = {
      { "<localleader>l", "", desc = "+vimtex", ft = "tex" },
      { "<localleader>ll", "<cmd>VimtexCompile<cr>", desc = "Compile", ft = "tex" },
      { "<localleader>lv", "<cmd>VimtexView<cr>", desc = "View PDF", ft = "tex" },
      { "<localleader>lk", "<cmd>VimtexStop<cr>", desc = "Stop compilation", ft = "tex" },
      { "<localleader>lc", "<cmd>VimtexClean<cr>", desc = "Clean aux files", ft = "tex" },
      { "<localleader>lt", "<cmd>VimtexTocToggle<cr>", desc = "Toggle TOC", ft = "tex" },
      { "<localleader>le", "<cmd>VimtexErrors<cr>", desc = "Show errors", ft = "tex" },
      { "<localleader>li", "<cmd>VimtexInfo<cr>", desc = "Info", ft = "tex" },
    },
  },

  {
    -- texlab sends an inlay hint at each \ref{...} that contains the resolved
    -- caption, for example " Figure: Macro context ". Neovim draws it as
    -- virtual text inside the line, so it looks like it overlays the source.
    -- LazyVim enables inlay hints for every filetype except vue, so exclude
    -- the LaTeX filetypes here. Keep "vue" in the list: LazyVim overwrites
    -- this list instead of merging it.
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "vue", "tex", "plaintex", "bib" },
      },
      servers = {
        -- texlab is the LSP half of the split: rename, go-to-definition,
        -- document symbols, hover, chktex. VimTeX keeps compilation, viewing,
        -- SyncTeX and completion. Leave build.onSave and forwardSearchAfter at
        -- their false defaults, or two latexmk processes race on the same
        -- aux files.
        texlab = {
          settings = {
            texlab = {
              -- Mirror of vimtex_quickfix_ignore_filters, so a warning does not
              -- appear once in the quickfix list and again as a diagnostic.
              -- The dialects differ: VimTeX uses Vim regex, texlab uses Rust
              -- regex.
              diagnostics = {
                ignoredPatterns = {
                  [[Underfull \\hbox]],
                  [[Overfull \\hbox]],
                  [[Command terminated with space]],
                  [[Font shape]],
                  [[Token not allowed in a PDF string]],
                },
              },
              -- chktex is off on both events by default, so it never runs.
              -- Run it on open and save, but not on every keystroke.
              chktex = { onOpenAndSave = true, onEdit = false },
            },
          },
        },
        -- textlsp is installed through Mason and attaches to every .tex buffer,
        -- where it runs LanguageTool. That duplicates the spellchecker and adds
        -- typography nags. Nothing in this repository asked for it, so disable
        -- it explicitly and keep the decision reproducible.
        textlsp = { enabled = false },
      },
    },
  },
}
