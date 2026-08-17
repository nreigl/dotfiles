-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim's wrap_spell autocmd covers plaintex but not tex, which is what
-- VimTeX actually sets — so .tex files get no spellcheck by default.
-- No extra syntax config is needed: vimtex_syntax_enabled marks math, command
-- names and cite keys as @NoSpell regions itself.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "bib" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.wrap = true
  end,
  desc = "Spellcheck and wrap for LaTeX",
})
