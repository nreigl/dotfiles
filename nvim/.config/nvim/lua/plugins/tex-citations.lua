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
          browser = "open", -- macOS default browser
          default = "search_engines",
          search_engines = {
            google_scholar = {
              name = "Google Scholar",
              get_url = require("cmp_vimtex").url_default_format("https://scholar.google.com/scholar?q=%s"),
            },
          },
        },
      })

      -- Ensure parser starts when opening TeX files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          local cmp_vimtex = require("cmp_vimtex")
          if cmp_vimtex.source and cmp_vimtex.source.start_parser then
            cmp_vimtex.source:start_parser()
            vim.notify("cmp-vimtex parser started", vim.log.levels.DEBUG)
          end
        end,
      })
    end,
  },

  -- Configure nvim-cmp for TeX files (nvim-cmp is installed via LazyVim extra)
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      "micangl/cmp-vimtex", -- VimTeX citations/labels
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Ensure vimtex source is available globally
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "vimtex", priority = 1000 })

      -- Setup filetype-specific config for TeX
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          -- Ensure VimTeX is loaded before setting up completion
          vim.schedule(function()
            cmp.setup.buffer({
              sources = cmp.config.sources({
                { name = "vimtex" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
              }),
              completion = {
                autocomplete = { cmp.TriggerEvent.TextChanged, cmp.TriggerEvent.InsertEnter },
              },
            })
            -- Debug: Print when setup runs
            vim.notify("nvim-cmp configured for TeX with vimtex source", vim.log.levels.INFO)
          end)
        end,
      })

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
