return {
  -- Add VimTeX-specific completion source to nvim-cmp
  {
    "micangl/cmp-vimtex",
    ft = { "tex", "plaintex", "bib" },
    dependencies = {
      "hrsh7th/nvim-cmp",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")

      -- cmp-vimtex ships after/plugin/cmp_vimtex.lua, which calls setup() with
      -- default options. lazy.nvim sources after/plugin before it runs this
      -- config, so the plugin's own "only if unset" guard never fires and our
      -- setup() call registers a second "vimtex" source. cmp then queries both
      -- and every citation candidate appears twice. Record the sources that
      -- exist before our call, and drop them after it.
      -- cmp.core.sources is keyed by source id, not a dense array, so iterate
      -- with pairs. ipairs stops at the first missing id and silently misses
      -- sources beyond it.
      local stale = {}
      for id, src in pairs(cmp.core.sources) do
        if src.name == "vimtex" then
          table.insert(stale, id)
        end
      end

      require("cmp_vimtex").setup({
        additional_information = {
          info_in_menu = true,
          info_in_window = false,
          info_max_length = 60,
          match_against_info = true,
          symbols_in_menu = false,
        },
        bibtex_parser = {
          enabled = true,
        },
        search = {
          browser = "open",
          default = "google_scholar",
          search_engines = {
            google_scholar = {
              name = "Google Scholar",
              get_url = require("cmp_vimtex").url_default_format("https://scholar.google.com/scholar?q=%s"),
            },
          },
        },
      })

      for _, id in ipairs(stale) do
        cmp.unregister_source(id)
      end

      -- Setup filetype-specific cmp sources for TeX files only
      cmp.setup.filetype({ "tex", "plaintex", "bib" }, {
        sources = cmp.config.sources({
          { name = "vimtex", priority = 1000 },
          { name = "nvim_lsp", priority = 900 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 250 },
          { name = "path", priority = 100 },
        }),
      })
    end,
  },
}
