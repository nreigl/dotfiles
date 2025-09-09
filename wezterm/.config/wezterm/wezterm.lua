local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font = wezterm.font("JetBrains Mono")
config.font_size = 15.0

config.color_scheme = "Dracula"
config.colors = {
  cursor_fg = "#282a36",
  cursor_bg = "#ff79c6",
  selection_bg = "#44475a",
  selection_fg = "#f8f8f2",
}
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.send_composed_key_when_left_alt_is_pressed = true -- Need to use use alt

config.window_background_opacity = 1 -- Default opacity when not fullscreen
config.macos_window_background_blur = 10

config.background = {
	{
		source = {
			File = wezterm.config_dir .. "/images/pexels-eberhardgross-572897.jpg",
		},
		opacity = 0.5, -- Adjust the image opacity
	},
	{
		source = {
			Color = "#000000",
		},
		opacity = 0.9, -- Adjust the overlay opacity
	},
}

config.window_background_gradient = {
	orientation = "Vertical",

	colors = {
		"#223343",
		"#000000",
	},

	interpolation = "Linear",

	blend = "Rgb",
}

config.keys = {
	-- Move between windows
	{
		key = "f",
		mods = "CTRL|CMD",
		action = wezterm.action.ToggleFullScreen,
	},
}
config.scrollback_lines = 10000
config.hide_mouse_cursor_when_typing = true
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"
return config
