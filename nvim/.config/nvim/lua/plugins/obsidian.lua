return {
  -- Obsidian.nvim for better note-taking
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- NOTE: Using blink.cmp in this setup; avoid forcing nvim-cmp.
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/notes",
        },
        {
          name = "research",
          path = "~/Documents/researchnotes",
        },
      },

      -- Optional, set to true if you use the ObsidianToday, ObsidianYesterday, etc.
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        template = nil,
      },

      -- Optional, completion of wiki links, local markdown links, and tags
      completion = {
        -- Disable nvim-cmp integration since this setup uses blink.cmp
        nvim_cmp = false,
        min_chars = 2,
      },

      -- Optional, configure key mappings
      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes
        ["<leader>ch"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
      },

      -- Optional, for templates (similar to Obsidian Templates plugin)
      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {},
      },

      -- Optional, customize how note file names are generated
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and suffix
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,

      -- Optional, customize the backlinks view
      backlinks = {
        height = 10,
        wrap = true,
      },

      -- Optional, customize the tags view
      tags = {
        height = 10,
        wrap = true,
      },

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,

      -- Optional, set to true to use native Obsidian-style [[Wiki Links]]
      wiki_link_func = "use_alias_only",

      -- Optional, configure additional syntax highlighting
      markdown_link_func = function(opts)
        return require("obsidian.util").markdown_link(opts)
      end,

      -- Specify how to handle attachments
      attachments = {
        img_folder = "assets/imgs",
        img_text_func = function(client, path)
          local link_path
          local vault_relative_path = client:vault_relative_path(path)
          if vault_relative_path ~= nil then
            link_path = vault_relative_path
          else
            link_path = tostring(path)
          end
          local display_name = vim.fs.basename(link_path)
          return string.format("![%s](%s)", display_name, link_path)
        end,
      },
    },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note" },
      { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian app" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian vault" },
      { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
      { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Show tags" },
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Daily note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's note" },
      { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard" },
      { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename note" },
    },
  },
}
