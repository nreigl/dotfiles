return {
  {
    "lervag/vimtex",
    lazy = false, -- CRITICAL: Never lazy load VimTeX!
    init = function()
      -- Set local leader for VimTeX commands
      vim.g.maplocalleader = "\\"
      
      -- Use Skim on macOS (you have it installed)
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      
      -- Modern compiler settings with LuaLaTeX
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = ".build",
        out_dir = ".build",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-lualatex", -- Use LuaLaTeX for modern Unicode/font support
        },
      }
      
      -- Disable mappings that conflict with LazyVim
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      
      -- Better syntax and concealing
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
      
      -- Quickfix filters for cleaner output
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Overfull",
        "Command terminated with space",
        "LaTeX Font Warning: Font shape",
        "Package caption Warning: The option",
        [[Underfull \\hbox (badness [0-9]*) in]],
        "Package enumitem Warning: Negative labelwidth",
        [[Overfull \\hbox ([0-9]*.[0-9]*pt too wide) in]],
        [[Overfull \\vbox ([0-9]*.[0-9]*pt too high) at]],
        [[Package caption Warning: Unused \\captionsetup]],
        "Package typearea Warning: Bad type area settings!",
        [[Package fancyhdr Warning: \\headheight is too small]],
        [[Underfull \\hbox (badness [0-9]*) in paragraph at lines]],
        "Package hyperref Warning: Token not allowed in a PDF string",
        [[Overfull \\hbox ([0-9]*.[0-9]*pt too wide) in paragraph at lines]],
      }
    end,
    config = function()
      -- Auto-set conceallevel for LaTeX files
      vim.api.nvim_create_autocmd({ "FileType" }, {
        group = vim.api.nvim_create_augroup("lazyvim_vimtex_conceal", { clear = true }),
        pattern = { "bib", "tex" },
        callback = function()
          vim.wo.conceallevel = 2
        end,
      })
    end,
    keys = {
      { "<localleader>l", "", desc = "+vimtex", ft = "tex" },
      { "<localleader>ll", "<cmd>VimtexCompile<cr>", desc = "Compile", ft = "tex" },
      { "<localleader>lv", "<cmd>VimtexView<cr>", desc = "View PDF", ft = "tex" },
      { "<localleader>lk", "<cmd>VimtexStop<cr>", desc = "Stop compilation", ft = "tex" },
      { "<localleader>lc", "<cmd>VimtexClean<cr>", desc = "Clean aux files", ft = "tex" },
      { "<localleader>lt", "<cmd>VimtexTocToggle<cr>", desc = "Toggle TOC", ft = "tex" },
      { "<localleader>le", "<cmd>VimtexErrors<cr>", desc = "Show errors", ft = "tex" },
      { "<localleader>li", "<cmd>VimtexInfo<cr>", desc = "Info", ft = "tex" },
    },
  },
}
