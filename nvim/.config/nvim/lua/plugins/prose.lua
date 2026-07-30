-- Low-noise diagnostics for prose filetypes (markdown, LaTeX).
-- See also: lua/config/autocmds.lua for the LaTeX spellcheck autocmd.

local prose_filetypes = {
  markdown = true,
  tex = true,
  plaintex = true,
  bib = true,
}

return {
  -- Point markdownlint-cli2 at our trimmed rule set. nvim-lint pipes the
  -- buffer over stdin, so config auto-discovery would key off Neovim's cwd
  -- instead of the edited file — pass --config to make it deterministic.
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Filename matters: markdownlint-cli2 rejects --config paths that are
      -- not one of its recognized names (or a prefix + recognized name).
      local config_file = vim.fn.stdpath("config") .. "/prose.markdownlint.yaml"
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = vim.tbl_deep_extend("force", opts.linters["markdownlint-cli2"] or {}, {
        args = { "--config", config_file, "-" },
      })
      return opts
    end,
  },

  -- Keep gutter signs but drop inline virtual text in prose buffers, so text
  -- never shifts mid-sentence. vim.diagnostic.config() has no buffer-local
  -- scope, but a format callback returning nil suppresses the diagnostic from
  -- the virtual-text handler alone — signs, underline and hover are untouched.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.diagnostics = opts.diagnostics or {}
      opts.diagnostics.virtual_text = vim.tbl_deep_extend("force", opts.diagnostics.virtual_text or {}, {
        format = function(diagnostic)
          -- getbufvar (not vim.bo[...]) so a diagnostic pointing at an
          -- already-wiped buffer returns "" instead of throwing, which would
          -- take down virtual text for every filetype.
          local ft = vim.fn.getbufvar(diagnostic.bufnr or 0, "&filetype")
          if prose_filetypes[ft] then
            return nil
          end
          -- Returned unchanged so the source suffix still applies: Neovim runs
          -- format() before prefix_source(), preserving LazyVim's "if_many".
          return diagnostic.message
        end,
      })
      return opts
    end,
  },
}
