return {
  -- Explicitly install nvim-cmp dependencies for TeX
  { "hrsh7th/cmp-buffer", lazy = true },
  { "hrsh7th/cmp-path", lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },
  { "micangl/cmp-vimtex", lazy = true },

  -- Configure nvim-cmp for TeX files to get bibliography completion
  {
    "hrsh7th/nvim-cmp",
    ft = { "tex", "plaintex" },
    event = "InsertEnter", -- Also load on InsertEnter for better responsiveness
    dependencies = {
      "micangl/cmp-vimtex", -- VimTeX-aware completion (labels, cites, etc.)
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", -- Ensure LuaSnip is available
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup.filetype({ "tex", "plaintex" }, {
        completion = {
          autocomplete = { cmp.TriggerEvent.TextChanged, cmp.TriggerEvent.InsertEnter },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "vimtex", priority = 10 },
          { name = "luasnip", priority = 8 },
          { name = "buffer", priority = 5 },
          { name = "path", priority = 3 },
        }),
      })
    end,
  },

  -- Disable blink.cmp in TeX buffers to avoid two completion UIs
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      local orig_enabled = opts and opts.enabled
      opts = opts or {}
      opts.enabled = function(ctx)
        if vim.bo.filetype == "tex" or vim.bo.filetype == "plaintex" then
          return false
        end
        if type(orig_enabled) == "function" then return orig_enabled(ctx) end
        if type(orig_enabled) == "boolean" then return orig_enabled end
        return true
      end
      return opts
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
