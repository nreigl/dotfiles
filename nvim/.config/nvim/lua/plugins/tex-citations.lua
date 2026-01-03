return {
  -- Add VimTeX-specific completion source to nvim-cmp
  {
    "micangl/cmp-vimtex",
    ft = { "tex", "plaintex", "bib" },
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-omni",
    },
    config = function()
      require("cmp_vimtex").setup({
        additional_information = {
          info_in_menu = false,
          info_in_window = false,
          info_max_length = 20,
          match_against_info = false,
          symbols_in_menu = false,
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

      -- Setup filetype-specific cmp sources for TeX files only
      local cmp = require("cmp")
      cmp.setup.filetype({ "tex", "plaintex", "bib" }, {
        sources = cmp.config.sources({
          { name = "vimtex", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "omni", priority = 500 },
          { name = "buffer", priority = 250 },
          { name = "path", priority = 100 },
        }),
      })
    end,
  },
}
