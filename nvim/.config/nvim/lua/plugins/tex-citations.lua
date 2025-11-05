return {
  -- Configure nvim-cmp to use VimTeX's omnifunc for citations
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-omni", -- Omnifunc completion source
    },
    opts = function(_, opts)
      -- Ensure sources table exists
      opts.sources = opts.sources or {}

      -- Add omni source for all file types
      table.insert(opts.sources, {
        name = "omni",
        option = {
          disable_omnifuncs = {} -- Don't disable any omnifuncs
        }
      })

      return opts
    end,
  },

  -- Setup omni completion specifically for TeX files using VimTeX's omnifunc
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex" },
    config = function()
      -- Set up omnifunc for TeX files to use VimTeX's completion
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          vim.bo.omnifunc = "vimtex#complete#omnifunc"

          -- Ensure nvim-cmp uses the omnifunc for this buffer
          local cmp = require("cmp")
          cmp.setup.buffer({
            sources = cmp.config.sources({
              { name = "omni" },
              { name = "luasnip" },
              { name = "buffer" },
              { name = "path" },
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
