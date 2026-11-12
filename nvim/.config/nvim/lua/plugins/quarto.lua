-- Quarto preview and code-chunk LSP (through otter.nvim) for .qmd files.
--
-- Keys use <leader>Q, not the <leader>q from the quarto-nvim README:
--   * LazyVim owns <leader>q (quit and session); <leader>qq is "Quit All".
--   * R.nvim (lang.r extra) owns <localleader>q in quarto buffers:
--     \qr, \qp, \qs render, preview, and stop through a running R session.
-- QuartoPreview runs the quarto CLI in a terminal and needs no R session.
--
-- Heading outline: gO, ]] and [[ do what they do in markdown buffers.
-- The quarto ftplugin only sources rmd.vim, so Neovim does not map them here.
-- vim.treesitter._headings is private and can change in a Neovim release.
local function map_headings(buf)
  local headings = require("vim.treesitter._headings")
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, silent = true, desc = desc })
  end
  map("gO", function() headings.show_toc() end, "Show heading outline")
  map("]]", function() headings.jump({ count = 1 }) end, "Next section")
  map("[[", function() headings.jump({ count = -1 }) end, "Previous section")
end

-- LazyVim maps ]] and [[ to Snacks.words.jump on LspAttach, which would
-- replace the section maps (otter and r_language_server have documentHighlight).
-- These specs replace LazyVim's (same lhs) and disable them in quarto buffers.
-- <a-n> and <a-p> still jump between references there.
local function words_enabled(buf)
  return vim.bo[buf or 0].filetype ~= "quarto" and Snacks.words.is_enabled()
end

return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = { "quarto" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("quarto_headings", { clear = true }),
        pattern = "quarto",
        callback = function(ev) map_headings(ev.buf) end,
      })
    end,
    opts = {},
    keys = {
      { "<leader>Q", "", desc = "+quarto", ft = "quarto" },
      { "<leader>Qp", "<cmd>QuartoPreview<cr>", desc = "Quarto preview", ft = "quarto" },
      { "<leader>Qc", "<cmd>QuartoClosePreview<cr>", desc = "Quarto close preview", ft = "quarto" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
              desc = "Next Reference", enabled = words_enabled },
            { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
              desc = "Prev Reference", enabled = words_enabled },
          },
        },
      },
    },
  },
}
