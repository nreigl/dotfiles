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

    -- Opacity Controls
    {
      key = "z",
      mods = "OPT",
      action = wezterm.action_callback(features.moreOpacity),
    },
    {
      key = "x",
      mods = "OPT",
      action = wezterm.action_callback(features.resetOpacity),
    },
    {
      key = "c",
      mods = "OPT",
      action = wezterm.action_callback(features.lessOpacity),
    },

    -- Background Overlay Controls
    {
      key = "=",
      mods = "OPT|SHIFT",
      action = wezterm.action_callback(features.lightenBgOverlay),
    },
    {
      key = "-",
      mods = "OPT|SHIFT",
      action = wezterm.action_callback(features.darkenBgOverlay),
    },
    {
      key = "0",
      mods = "OPT|SHIFT",
      action = wezterm.action_callback(features.resetBgOverlay),
    },

    -- Background Image Controls
    {
      key = "=",
      mods = "OPT",
      action = wezterm.action_callback(features.lightenBgImage),
    },
    {
      key = "-",
      mods = "OPT",
      action = wezterm.action_callback(features.darkenBgImage),
    },
    {
      key = "0",
      mods = "OPT",
      action = wezterm.action_callback(features.resetBgImage),
    },

    -- Toggle Solid Background (no transparency, no image)
    {
      key = "b",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(features.toggleSolidBackground),
    },
  }
end

return M
