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
        -- Basic
        s("cite", fmt("\\cite{{{}}}", { i(1) })),
        s("ref", fmt("\\ref{{{}}}", { i(1) })),

        -- Biblatex commands (modern)
        s("parencite", fmt("\\parencite{{{}}}", { i(1) })),
        s("textcite", fmt("\\textcite{{{}}}", { i(1) })),
        s("footcite", fmt("\\footcite{{{}}}", { i(1) })),
        s("autocite", fmt("\\autocite{{{}}}", { i(1) })),

        -- Natbib commands (legacy)
        s("citet", fmt("\\citet{{{}}}", { i(1) })),
        s("citep", fmt("\\citep{{{}}}", { i(1) })),

        -- Short aliases for biblatex
        s("pc", fmt("\\parencite{{{}}}", { i(1) })),
        s("tc", fmt("\\textcite{{{}}}", { i(1) })),
        s("ac", fmt("\\autocite{{{}}}", { i(1) })),

        -- Cross-references
        s("cref", fmt("\\cref{{{}}}", { i(1) })),
        s("aref", fmt("\\autoref{{{}}}", { i(1) })),

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
          "eq*",
          fmt(
            "\\begin{equation*}\n\t<>\n\\end{equation*}",
            { i(1) },
            { delimiters = "<>" }
          )
        ),
        s(
          "align",
          fmt(
            "\\begin{align}\n\t<> &= <> \\\\\n\\end{align}",
            { i(1), i(2) },
            { delimiters = "<>" }
          )
        ),
        s(
          "align*",
          fmt(
            "\\begin{align*}\n\t<> &= <> \\\\\n\\end{align*}",
            { i(1), i(2) },
            { delimiters = "<>" }
          )
        ),
        s(
          "tab",
          fmt(
            "\\begin{table}[<>]\n\t\\centering\n\t\\begin{tabular}{<>}\n\t\t\\toprule\n\t\t<> \\\\\n\t\t\\midrule\n\t\t<> \\\\\n\t\t\\bottomrule\n\t\\end{tabular}\n\t\\caption{<>}\n\t\\label{<>}\n\\end{table}",
            { i(1, "htbp"), i(2, "lcc"), i(3, "Header"), i(4, "Data"), i(5, "caption"), i(6, "tab:label") },
            { delimiters = "<>" }
          )
        ),
        s(
          "tabular",
          fmt(
            "\\begin{tabular}{<>}\n\t<>\n\\end{tabular}",
            { i(1, "lcc"), i(2) },
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
