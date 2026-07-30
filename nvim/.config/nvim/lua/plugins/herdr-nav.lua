-- Seamless Ctrl+h/j/k/l between herdr panes and nvim splits
-- (vim-tmux-navigator equivalent for herdr; the herdr side is bound in
-- ~/dotfiles/herdr/.config/herdr/config.toml via the vim-herdr-navigation
-- plugin). The editor script falls back to tmux / plain wincmd when not
-- inside a herdr pane, so it is safe to load unconditionally.
return {
  {
    "LazyVim/LazyVim",
    init = function()
      -- plugin dir carries a content hash that changes on update -> glob it
      local script = vim.fn.glob(
        "~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua"
      )
      if script ~= "" then
        vim.schedule(function()
          dofile(vim.split(script, "\n")[1])
        end)
      end
    end,
  },
}
