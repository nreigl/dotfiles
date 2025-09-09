return {
  "vimwiki/vimwiki",
  event = "BufEnter *.md",
  keys = { "<leader>ww", "<leader>wt" },
  init = function()
    vim.g.vimwiki_folding = ""
    vim.g.vimwiki_list = {
      {
        path = "~/Documents/notes/",
        syntax = "markdown",
        ext = ".md",
      },
      {
        path = "~/Documents/researchnotes/",
        syntax = "markdown",
        ext = ".md",
      },
    }
    vim.g.vimwiki_ext2syntax = {
      [".md"] = "markdown",
      [".markdown"] = "markdown",
      [".mdown"] = "markdown",
    }
  end,
}
