return {
  -- Existing Nord theme (you can keep it, or remove if switching to Dracula)
  { "shaunsingh/nord.nvim" },

  -- Dracula theme with config
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    priority = 1000,
    config = function()
      require("dracula").setup({
        italic_comment = true,
        transparent_bg = true, -- to match wezterm blur
      })
      vim.cmd.colorscheme("dracula")
    end,
  },

  -- LazyVim core config
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula", -- switch from "nord" to "dracula"
    },
  },
}

 
