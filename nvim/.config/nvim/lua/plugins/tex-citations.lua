return {
  -- Use nvim-cmp only for TeX to get bibliography completion
  {
    "hrsh7th/nvim-cmp",
    ft = { "tex", "plaintex" },
    dependencies = {
      "micangl/cmp-vimtex", -- VimTeX-aware completion (labels, cites, etc.)
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = { autocomplete = { cmp.TriggerEvent.TextChanged } },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "vimtex" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      }
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
