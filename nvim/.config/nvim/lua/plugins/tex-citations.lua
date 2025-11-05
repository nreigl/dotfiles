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

      -- Trigger bibliography parsing when opening TeX files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          -- Give VimTeX time to initialize and find bibliography files
          vim.defer_fn(function()
            local cmp_vimtex = require("cmp_vimtex")
            if cmp_vimtex.search then
              -- Force refresh of bibliography database
              cmp_vimtex.search()
            end
          end, 500) -- Wait 500ms for VimTeX to parse \addbibresource
        end,
      })
    end,
  },

  -- Add LuaSnip adapter for nvim-cmp
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = { "L3MON4D3/LuaSnip" },
  },

  -- Configure nvim-cmp - add vimtex/luasnip sources and fix buffer completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "micangl/cmp-vimtex",
      "saadparwaiz1/cmp_luasnip",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- Add our TeX-specific sources
      table.insert(opts.sources, { name = "vimtex" })
      table.insert(opts.sources, { name = "luasnip" })

      -- Fix buffer completion: move from group 2 (fallback) to group 1 (primary)
      -- LazyVim defaults buffer to fallback, which hides it when other sources have results
      for _, source in ipairs(opts.sources) do
        if source.name == "buffer" then
          source.group_index = 1
          break
        end
      end

      return opts
    end,
    config = function()
      local cmp = require("cmp")

      -- Setup filetype-specific config for TeX files to ensure citation completion triggers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          cmp.setup.buffer({
            sources = cmp.config.sources({
              { name = "vimtex", priority = 1000 },
              { name = "luasnip" },
              { name = "buffer" },
              { name = "path" },
            }),
          })
        end,
      })
    end,
  },

  -- Disable blink.cmp in TeX files to avoid conflicts
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.vimtex = {
        name = "vimtex",
        module = "blink.compat.source",
        score_offset = 10,
      }
      return opts
    end,
  },

  -- Fallback: VimTeX omnifunc with Ctrl-Space
  {
    "lervag/vimtex",
    keys = {
      { "<C-Space>", "<C-x><C-o>", mode = "i", ft = "tex", desc = "VimTeX Omni complete" },
    },
  },
}
