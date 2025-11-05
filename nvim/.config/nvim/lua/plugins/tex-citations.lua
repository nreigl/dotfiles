return {
  -- Add VimTeX-specific completion source to nvim-cmp
  {
    "micangl/cmp-vimtex",
    ft = { "tex", "plaintex" },
    config = function()
      require("cmp_vimtex").setup({
        additional_information = {
          info_in_menu = true,
          info_in_window = true,
          info_max_length = 60,
          match_against_info = true,
          symbols_in_menu = true,
        },
        bibtex_parser = {
          enabled = true,
        },
        search = {
          browser = "open",
          default = "search_engines",
          search_engines = {
            google_scholar = {
              name = "Google Scholar",
              get_url = require("cmp_vimtex").url_default_format("https://scholar.google.com/scholar?q=%s"),
            },
          },
        },
      })
    end,
  },

  -- Add LuaSnip and its adapter
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Configure nvim-cmp with all sources including vimtex and luasnip
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "micangl/cmp-vimtex",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-omni", -- Fallback omnifunc
    },
    opts = function(_, opts)
      -- Add vimtex and luasnip to global sources
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "vimtex", priority = 1000 })
      table.insert(opts.sources, { name = "luasnip" })
      table.insert(opts.sources, { name = "omni" })

      return opts
    end,
  },

  -- Setup TeX-specific completion
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          -- Set VimTeX omnifunc as fallback
          vim.bo.omnifunc = "vimtex#complete#omnifunc"

          -- Configure buffer-specific completion with proper priority
          local cmp = require("cmp")
          cmp.setup.buffer({
            sources = cmp.config.sources({
              { name = "vimtex", priority = 1000 },
              { name = "luasnip", priority = 900 },
              { name = "omni", priority = 800 },
              { name = "buffer", priority = 700 },
              { name = "path", priority = 600 },
            }),
          })
        end,
      })
    end,
    keys = {
      { "<C-Space>", "<C-x><C-o>", mode = "i", ft = "tex", desc = "VimTeX Omni complete" },
    },
  },
}
