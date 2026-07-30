local wezterm = require("wezterm")
local features = require("features")

local M = {}

function M.setup(config)
  config.keys = {
    -- Original keybinding: Toggle fullscreen
    {
      key = "f",
      mods = "CTRL|CMD",
      action = wezterm.action.ToggleFullScreen,
    },

    -- Theme Switcher
    {
      key = "t",
      mods = "CTRL|SHIFT",
      action = features.themes(),
    },

    -- Font Switcher
    {
      key = "f",
      mods = "CTRL|SHIFT",
      action = features.fonts(),
    },

    -- Project Switcher
    {
      key = "p",
      mods = "CTRL|SHIFT",
      action = features.projects(),
    },

    -- Font Size Controls
    {
      key = "=",
      mods = "CMD",
      action = wezterm.action_callback(features.increaseFontSize),
    },
    {
      key = "-",
      mods = "CMD",
      action = wezterm.action_callback(features.decreaseFontSize),
    },
    {
      key = "0",
      mods = "CMD",
      action = wezterm.action_callback(features.resetFontSize),
    },

    -- Opacity / overlay / image controls.
    --
    -- These were on OPT, which is dead: send_composed_key_when_*_alt_is_pressed
    -- makes macOS compose OPT chords into characters (OPT+Z -> "Ω",
    -- OPT+SHIFT+- -> "—"), so WezTerm never sees the bound key. Compose is
    -- wanted for typing accents/@/€, so the bindings moved off OPT instead.
    --
    -- Same +/-/0 triad as CMD font-size, one modifier set per target:
    --   CMD        = / - / 0  font size (above)
    --   CTRL|SHIFT = / - / 0  window opacity
    --   CMD|SHIFT  = / - / 0  background overlay
    --   CTRL|CMD   = / - / 0  background image
    --
    -- phys: codes bind the physical key position, so SHIFT cannot re-map
    -- "=" to "+" or "0" to ")" out from under the binding.

    -- Window Opacity
    {
      key = "phys:Equal",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(features.moreOpacity),
    },
    {
      key = "phys:Minus",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(features.lessOpacity),
    },
    {
      key = "phys:0",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(features.resetOpacity),
    },

    -- Background Overlay Controls
    {
      key = "phys:Equal",
      mods = "CMD|SHIFT",
      action = wezterm.action_callback(features.lightenBgOverlay),
    },
    {
      key = "phys:Minus",
      mods = "CMD|SHIFT",
      action = wezterm.action_callback(features.darkenBgOverlay),
    },
    {
      key = "phys:0",
      mods = "CMD|SHIFT",
      action = wezterm.action_callback(features.resetBgOverlay),
    },

    -- Background Image Controls
    {
      key = "phys:Equal",
      mods = "CTRL|CMD",
      action = wezterm.action_callback(features.lightenBgImage),
    },
    {
      key = "phys:Minus",
      mods = "CTRL|CMD",
      action = wezterm.action_callback(features.darkenBgImage),
    },
    {
      key = "phys:0",
      mods = "CTRL|CMD",
      action = wezterm.action_callback(features.resetBgImage),
    },

    -- Toggle solid vs background-image mode (opacity is remembered)
    {
      key = "b",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(features.toggleSolidBackground),
    },
  }
end

return M
