return {
  "gruvw/strudel.nvim",
  build = "npm install",
  config = function()
    local strudel = require("strudel")

    strudel.setup({
      start_on_launch = true,
      update_on_save = false,
      sync_cursor = true,
      report_eval_errors = true,
      headless = false,
    })

    -- Use <leader>S (not <leader>s) so we don't shadow LazyVim's search group.
    vim.keymap.set("n", "<leader>Sl", strudel.launch, { desc = "Launch Strudel" })
    vim.keymap.set("n", "<leader>Sq", strudel.quit, { desc = "Quit Strudel" })
    vim.keymap.set("n", "<leader>St", strudel.toggle, { desc = "Strudel Toggle Play/Stop" })
    vim.keymap.set("n", "<leader>Su", strudel.update, { desc = "Strudel Update" })
    vim.keymap.set("n", "<leader>Ss", strudel.stop, { desc = "Strudel Stop Playback" })
    vim.keymap.set("n", "<leader>Sb", strudel.set_buffer, { desc = "Strudel set current buffer" })
    vim.keymap.set("n", "<leader>Sx", strudel.execute, { desc = "Strudel set buffer and update" })
  end,
}
