local wezterm = require("wezterm")
local M = {}

-- Generic picker using WezTerm's InputSelector
function M.pick(opts)
  opts.window:perform_action(
    wezterm.action.InputSelector({
      fuzzy_description = opts.title,
      choices = opts.choices,
      fuzzy = true,
      action = opts.action,
    }),
    opts.pane
  )
end

return M
