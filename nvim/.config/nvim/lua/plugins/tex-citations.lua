return {
  -- Add VimTeX-specific completion source to nvim-cmp
  {
    "micangl/cmp-vimtex",
    ft = { "tex", "plaintex" },
  },

  -- Configure nvim-cmp for TeX files (nvim-cmp is installed via LazyVim extra)
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      "micangl/cmp-vimtex", -- VimTeX citations/labels
    },
    opts = function(_, opts)
      -- LazyVim's nvim-cmp extra provides the base config
      -- We just need to add vimtex source for TeX files
      local cmp = require("cmp")

      -- Add vimtex to sources for TeX files
      cmp.setup.filetype({ "tex", "plaintex" }, {
        sources = cmp.config.sources({
          { name = "vimtex", priority = 1000 }, -- Highest priority for citations
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
    end,
  },

  -- Convenience: fallback Omni completion key in TeX (works with VimTeX)
  {
    "lervag/vimtex",
    keys = {
      { "<C-Space>", "<C-x><C-o>", mode = "i", ft = "tex", desc = "VimTeX Omni complete" },
    },
  },
}
