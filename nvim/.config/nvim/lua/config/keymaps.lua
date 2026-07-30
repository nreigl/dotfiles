-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim-herdr-navigation: seamless Ctrl+h/j/k/l across nvim splits and herdr
-- panes. Loaded here (not a plugin spec) because user keymaps.lua runs AFTER
-- LazyVim's default <C-hjkl> wincmd maps and must override them — otherwise
-- nvim can't hand off focus to the neighboring herdr pane at a split edge.
local herdr_nav = vim.fn.glob(
  "~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua"
)
if herdr_nav ~= "" then
  dofile(vim.split(herdr_nav, "\n")[1])
end
