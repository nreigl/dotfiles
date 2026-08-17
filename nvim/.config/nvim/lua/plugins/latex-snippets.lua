-- LaTeX snippets.
--
-- Two groups:
--   1. Tab-triggered snippets for structure (environments, tables, figures,
--      citations). You type the trigger and press <Tab>.
--   2. Autosnippets for mathematics. They expand as soon as you type the
--      trigger, with no <Tab>. Every one of them is guarded by a math-zone
--      condition, so two-letter triggers cannot fire inside prose. VimTeX
--      supplies the zone test through vimtex#syntax#in_mathzone().
--
-- vimtex_imaps_enabled is set to 0 in plugins/vimtex.lua, so VimTeX's own
-- insert-mode maps do not compete with this set.
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    opts = { enable_autosnippets = true },
    config = function(_, opts)
      local ls = require("luasnip")
      ls.config.setup(opts or {})

      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local fmt = require("luasnip.extras.fmt").fmt
      local rep = require("luasnip.extras").rep

      -- Context tests -------------------------------------------------------
      -- vimtex#syntax#in_mathzone() reads the syntax stack under the cursor, so
      -- it is correct for $...$, \[...\], and every amsmath environment without
      -- a hand-written list.
      local function in_mathzone()
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      end

      local function in_text()
        return not in_mathzone()
      end

      -- Shorthands ----------------------------------------------------------
      -- auto() marks a snippet as an autosnippet and attaches a condition.
      -- wordTrig stays on for word-like triggers, so that "stuff" does not turn
      -- into "stu\frac{}{}".
      local function auto(trig, nodes, cond)
        return s({ trig = trig, snippetType = "autosnippet", condition = cond }, nodes)
      end

      -- post() is for triggers that attach to the symbol in front of them:
      -- "x" then "sr" gives x^{2}, and "x" then "==" gives x &= . wordTrig must
      -- be off, or the preceding letter blocks the expansion.
      local function post(trig, nodes, cond)
        return s({
          trig = trig,
          wordTrig = false,
          snippetType = "autosnippet",
          condition = cond,
        }, nodes)
      end

      -- re() is the same, for pattern triggers. wordTrig must be false:
      -- word-boundary detection conflicts with pattern triggers.
      local function re(trig, nodes, cond)
        return s({
          trig = trig,
          regTrig = true,
          wordTrig = false,
          snippetType = "autosnippet",
          condition = cond,
        }, nodes)
      end

      -- cap() returns capture group n from a pattern trigger.
      local function cap(n)
        return f(function(_, snip)
          return snip.captures[n]
        end)
      end

      local d = { delimiters = "<>" }

      ls.add_snippets("tex", {
        -- Citations ---------------------------------------------------------
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

        -- Environments ------------------------------------------------------
        s("beg", fmt("\\begin{<>}\n\t<>\n\\end{<>}", { i(1, "environment"), i(2), rep(1) }, d)),
        s("itemi", fmt("\\begin{itemize}\n\t\\item <>\n\\end{itemize}", { i(1) }, d)),
        s("enum", fmt("\\begin{enumerate}\n\t\\item <>\n\\end{enumerate}", { i(1) }, d)),
        s("it", t("\\item ")),

        -- Common structures -------------------------------------------------
        s("eq", fmt("\\begin{equation}\n\t<>\n\\end{equation}", { i(1) }, d)),
        s("eq*", fmt("\\begin{equation*}\n\t<>\n\\end{equation*}", { i(1) }, d)),
        s("align", fmt("\\begin{align}\n\t<> &= <> \\\\\n\\end{align}", { i(1), i(2) }, d)),
        s("align*", fmt("\\begin{align*}\n\t<> &= <> \\\\\n\\end{align*}", { i(1), i(2) }, d)),
        s(
          "tab",
          fmt(
            "\\begin{table}[<>]\n\t\\centering\n\t\\begin{tabular}{<>}\n\t\t\\toprule\n\t\t<> \\\\\n\t\t\\midrule\n\t\t<> \\\\\n\t\t\\bottomrule\n\t\\end{tabular}\n\t\\caption{<>}\n\t\\label{<>}\n\\end{table}",
            { i(1, "htbp"), i(2, "lcc"), i(3, "Header"), i(4, "Data"), i(5, "caption"), i(6, "tab:label") },
            d
          )
        ),
        s("tabular", fmt("\\begin{tabular}{<>}\n\t<>\n\\end{tabular}", { i(1, "lcc"), i(2) }, d)),
        s(
          "fig",
          fmt(
            "\\begin{figure}[<>]\n\t\\centering\n\t\\includegraphics[width=<>\\textwidth]{<>}\n\t\\caption{<>}\n\t\\label{<>}\n\\end{figure}",
            { i(1, "htbp"), i(2, "0.8"), i(3, "path/to/image"), i(4, "caption"), i(5, "fig:label") },
            d
          )
        ),

        -- Autosnippets: entering math ---------------------------------------
        -- These fire in prose, so both triggers are two characters that do not
        -- occur inside an English word.
        auto("mk", fmt("$<>$<>", { i(1), i(0) }, d), in_text),
        auto("dm", fmt("\\[\n\t<>\n\\]\n<>", { i(1), i(0) }, d), in_text),

        -- Autosnippets: fractions, roots, powers -----------------------------
        auto("ff", fmt("\\frac{<>}{<>}<>", { i(1), i(2), i(0) }, d), in_mathzone),
        auto("sq", fmt("\\sqrt{<>}<>", { i(1), i(0) }, d), in_mathzone),
        post("sr", t("^{2}"), in_mathzone),
        post("cb", t("^{3}"), in_mathzone),
        post("td", fmt("^{<>}<>", { i(1), i(0) }, d), in_mathzone),
        auto("ee", fmt("e^{<>}<>", { i(1), i(0) }, d), in_mathzone),
        -- No "inv" trigger: with wordTrig off it fires inside "inverse".
        -- Use td and type -1.

        -- Subscript a digit that follows a letter or a closing bracket:
        -- x1 becomes x_{1}, \beta2 becomes \beta_{2}.
        re("([%a%)%]%}])(%d)", fmt("<>_{<>}", { cap(1), cap(2) }, d), in_mathzone),

        -- Postfix accents: xbar becomes \bar{x}.
        -- Group 1 is the character in front of the name and is re-emitted
        -- unchanged. It exists only to reject a leading backslash: without it
        -- the "dot" pattern rewrites \cdot into \dot{c}, and \ldots into
        -- \dot{l}s, while you type them.
        re("([^%a\\])([%a][%w]*)bar", fmt("<>\\bar{<>}", { cap(1), cap(2) }, d), in_mathzone),
        re("([^%a\\])([%a][%w]*)hat", fmt("<>\\hat{<>}", { cap(1), cap(2) }, d), in_mathzone),
        re("([^%a\\])([%a][%w]*)til", fmt("<>\\tilde{<>}", { cap(1), cap(2) }, d), in_mathzone),
        re("([^%a\\])([%a][%w]*)dot", fmt("<>\\dot{<>}", { cap(1), cap(2) }, d), in_mathzone),
        re("([^%a\\])([%a][%w]*)vec", fmt("<>\\mathbf{<>}", { cap(1), cap(2) }, d), in_mathzone),

        -- Autosnippets: operators and relations ------------------------------
        post("==", t(" &= "), in_mathzone),
        post("!=", t(" \\neq "), in_mathzone),
        post("<=", t(" \\leq "), in_mathzone),
        post(">=", t(" \\geq "), in_mathzone),
        post("~~", t(" \\sim "), in_mathzone),
        post("->", t(" \\to "), in_mathzone),
        post("=>", t(" \\implies "), in_mathzone),
        post("**", t(" \\cdot "), in_mathzone),
        auto("iff", t(" \\iff "), in_mathzone),
        auto("xx", t(" \\times "), in_mathzone),
        auto("EE", t("\\mathbb{E}"), in_mathzone),
        auto("VV", t("\\mathrm{Var}"), in_mathzone),
        auto("CV", t("\\mathrm{Cov}"), in_mathzone),
        auto("sum", fmt("\\sum_{<>}^{<>}<>", { i(1, "i=1"), i(2, "N"), i(0) }, d), in_mathzone),
        auto("prod", fmt("\\prod_{<>}^{<>}<>", { i(1, "i=1"), i(2, "N"), i(0) }, d), in_mathzone),
        auto("int", fmt("\\int_{<>}^{<>}<>", { i(1), i(2), i(0) }, d), in_mathzone),
        auto("lim", fmt("\\lim_{<> \\to <>}<>", { i(1, "n"), i(2, "\\infty"), i(0) }, d), in_mathzone),

        -- Autosnippets: Greek letters ----------------------------------------
        -- The semicolon leader keeps these out of the way of ordinary text and
        -- never collides with a variable name.
        post(";a", t("\\alpha"), in_mathzone),
        post(";b", t("\\beta"), in_mathzone),
        post(";g", t("\\gamma"), in_mathzone),
        post(";d", t("\\delta"), in_mathzone),
        post(";e", t("\\varepsilon"), in_mathzone),
        post(";t", t("\\theta"), in_mathzone),
        post(";k", t("\\kappa"), in_mathzone),
        post(";l", t("\\lambda"), in_mathzone),
        post(";m", t("\\mu"), in_mathzone),
        post(";p", t("\\pi"), in_mathzone),
        post(";r", t("\\rho"), in_mathzone),
        post(";s", t("\\sigma"), in_mathzone),
        post(";f", t("\\phi"), in_mathzone),
        post(";o", t("\\omega"), in_mathzone),
        post(";G", t("\\Gamma"), in_mathzone),
        post(";D", t("\\Delta"), in_mathzone),
        post(";S", t("\\Sigma"), in_mathzone),
        post(";O", t("\\Omega"), in_mathzone),
      })
    end,
  },
}
