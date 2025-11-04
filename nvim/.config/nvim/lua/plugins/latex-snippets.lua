return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local fmt = require("luasnip.extras.fmt").fmt
      local rep = require("luasnip.extras").rep

      -- Load community snippets (includes many LaTeX snippets)
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Custom LaTeX snippets focused on your requested triggers
      ls.add_snippets("tex", {
        -- Citations
        -- Common triggers
        s("cite", fmt("\\cite{{{}}}", { i(1) })),
        s("citet", fmt("\\citet{{{}}}", { i(1) })),
        s("citep", fmt("\\citep{{{}}}", { i(1) })),
        -- Short aliases
        s("cit", fmt("\\cite{{{}}}", { i(1) })),
        s("citt", fmt("\\citet{{{}}}", { i(1) })),
        s("citp", fmt("\\citep{{{}}}", { i(1) })),
        s("cref", fmt("\\cref{{{}}}", { i(1) })),
        s("aref", fmt("\\autoref{{{}}}", { i(1) })),
        s("ref", fmt("\\ref{{{}}}", { i(1) })),

        -- Environments (using <> delimiters to avoid conflicts with LaTeX braces)
        s(
          "beg",
          fmt(
            "\\begin{<>}\n\t<>\n\\end{<>}",
            { i(1, "environment"), i(2), rep(1) },
            { delimiters = "<>" }
          )
        ),
        s(
          "itemi",
          fmt(
            "\\begin{itemize}\n\t\\item <>\n\\end{itemize}",
            { i(1) },
            { delimiters = "<>" }
          )
        ),
        s(
          "enum",
          fmt(
            "\\begin{enumerate}\n\t\\item <>\n\\end{enumerate}",
            { i(1) },
            { delimiters = "<>" }
          )
        ),
        s("it", t("\\item ")),

        -- Common structures
        s(
          "eq",
          fmt(
            "\\begin{equation}\n\t<>\n\\end{equation}",
            { i(1) },
            { delimiters = "<>" }
          )
        ),
        s(
          "fig",
          fmt(
            "\\begin{figure}[<>]\n\t\\centering\n\t\\includegraphics[width=<>\\textwidth]{<>}\n\t\\caption{<>}\n\t\\label{<>}\n\\end{figure}",
            { i(1, "htbp"), i(2, "0.8"), i(3, "path/to/image"), i(4, "caption"), i(5, "fig:label") },
            { delimiters = "<>" }
          )
        ),
      })

      -- Keymaps: expand/jump with Ctrl-j, jump back with Ctrl-k
      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end, { silent = true, desc = "LuaSnip expand/jump" })

      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true, desc = "LuaSnip jump back" })
    end,
  },
}
