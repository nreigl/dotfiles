return {
  {
    "lervag/vimtex",
    lazy = false, -- CRITICAL: Never lazy load VimTeX!
    init = function()
      -- Note: maplocalleader is set in init.lua

      -- Use Skim on macOS (you have it installed)
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      
      -- Compiler settings (respects project .latexmkrc)
      vim.g.vimtex_compiler_latexmk = {
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-shell-escape",
        },
      }

      -- Compiler method (use latexmk for continuous compilation)
      vim.g.vimtex_compiler_method = "latexmk"
      
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

      -- Enable VimTeX completion (cmp-vimtex uses VimTeX's parser)
      -- The popup issue was from texlab LSP, which is stopped on attach
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_complete_close_braces = 1

      -- Use simple ref completion to avoid large preview windows
      vim.g.vimtex_complete_ref = { simple = 1 }

      -- Parser for bibliography files (bibparser works with both bibtex and biber)
      vim.g.vimtex_parser_bib_backend = 'bibparser'
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

      -- Disable LSP for TeX files (texlab can cause large preview popups)
      -- Use LspAttach event to catch clients when they actually attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("disable_tex_lsp", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            local ft = vim.bo[args.buf].filetype
            if ft == "tex" or ft == "plaintex" or ft == "bib" then
              -- Stop LSP clients that interfere with VimTeX
              -- Note: copilot.lua is disabled for tex via filetypes config, not LSP
              if client.name == "texlab" or client.name == "ltex" or client.name == "textlsp" then
                vim.lsp.stop_client(client.id)
              end
            end
          end
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
