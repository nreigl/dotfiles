return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true
    end,
    keys = {
      {
        "<leader>aa",
        function()
          require("opencode").ask()
        end,
        desc = "OpenCode: Ask",
      },
      {
        "<leader>as",
        function()
          require("opencode").select()
        end,
        desc = "OpenCode: Select action",
      },
      {
        "<leader>at",
        function()
          require("opencode").toggle()
        end,
        desc = "OpenCode: Toggle",
      },
      {
        "<leader>ac",
        function()
          require("opencode").add_context()
        end,
        desc = "OpenCode: Add context",
      },
      {
        "<leader>ap",
        function()
          require("opencode").prompt_with_selection()
        end,
        mode = "v",
        desc = "OpenCode: Prompt with selection",
      },
    },
  },

  -- Ensure snacks.nvim has the required features enabled
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.input = opts.input or {}
      opts.picker = opts.picker or {}
      opts.terminal = opts.terminal or {}
      return opts
    end,
  },
}

