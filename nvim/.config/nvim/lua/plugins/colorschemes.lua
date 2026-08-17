return {
  -- Dracula theme. LazyVim applies it via `opts.colorscheme` below, so this
  -- spec only configures the plugin. Do not call vim.cmd.colorscheme here.
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    priority = 1000,
    opts = {
      italic_comment = true,
      transparent_bg = true, -- to match the terminal background blur
    },
  },

  -- LazyVim core config
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
