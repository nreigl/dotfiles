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
        rust = true,
        go = true,
        c = true,
        cpp = true,
        julia = true,
        r = true,
        yaml = true,
        toml = true,
        json = true,
        html = true,
        css = true,
        zsh = true,
        bash = true,
        vim = true,
        tex = false, -- Disabled to prevent popup issues with \ref{}
        plaintex = false,
        bib = false,
        ["*"] = false, -- disable by default
      },
    })
  end,
}
