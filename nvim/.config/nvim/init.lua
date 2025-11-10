vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Fix buffer completion after plugins load
require("config.cmp_fix")
