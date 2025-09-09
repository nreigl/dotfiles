return {
  "zbirenbaum/copilot.lua",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
        lua = true,
        python = true,
        javascript = true,
        typescript = true,
        sh = true,
        ["*"] = false, -- disable by default
      },
    })
  end,
}
