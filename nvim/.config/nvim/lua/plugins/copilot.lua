-- Copilot appears as inline ghost text only, accepted with <C-l>.
--
-- This spec uses `config` rather than `opts`, which replaces LazyVim's copilot
-- settings instead of merging with them. That is deliberate: the ai.copilot
-- extra sets suggestion.enabled = false so copilot only reaches you through the
-- completion menu, and we want the opposite. The two specs below keep that
-- choice consistent, because leaving both paths on makes copilot suggest twice.
return {
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<C-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
          lua = true,
          python = true,
          javascript = true,
          typescript = true,
          sh = true,
          rust = true,
          go = true,
          c = true,
          cpp = true,
          julia = true,
          r = true,
          yaml = true,
          toml = true,
          json = true,
          html = true,
          css = true,
          zsh = true,
          bash = true,
          vim = true,
          tex = false, -- Disabled to prevent popup issues with \ref{}
          plaintex = false,
          bib = false,
          ["*"] = false, -- disable by default
        },
      })
    end,
  },

  -- LazyVim's ai.copilot extra also wires copilot into the completion menu
  -- through copilot-cmp. With ghost text on, that shows every suggestion
  -- twice. Disable the plugin and drop the source LazyVim adds to nvim-cmp.
  { "zbirenbaum/copilot-cmp", enabled = false },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "copilot"
      end, opts.sources or {})
    end,
  },
}
