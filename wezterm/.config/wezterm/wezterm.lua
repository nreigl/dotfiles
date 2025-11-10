local wezterm = require("wezterm")
local globals = require("utils.globals")
local keys = require("keys")

local config = wezterm.config_builder()

-- Read globals for dynamic configuration
local G = globals.readGlobals()

-- Launch tmux by default (attach or create a "main" session)
-- Use absolute Homebrew path if available (GUI apps may not inherit shell PATH)
local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local tmux_path = "tmux"
if wezterm.target_triple:match("darwin") then
	if file_exists("/opt/homebrew/bin/tmux") then
		tmux_path = "/opt/homebrew/bin/tmux"
	elseif file_exists("/usr/local/bin/tmux") then
		tmux_path = "/usr/local/bin/tmux"
	end
end

-- Every new WezTerm pane/window runs tmux and attaches to session "main"
config.default_prog = { tmux_path, "new-session", "-A", "-s", "main" }

-- Font configuration from globals
config.font = wezterm.font(G.font_family or "JetBrains Mono")
config.font_size = G.font_size or 15.0

-- Color scheme from globals
config.color_scheme = G.colorscheme or "Dracula"
config.colors = {
	cursor_fg = "#282a36",
	cursor_bg = "#ff79c6",
	selection_bg = "#44475a",
	selection_fg = "#f8f8f2",
}
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
-- Make Left Option send ESC-prefix (Meta) for Alt keybindings in shells.
-- Keep Right Option composing characters for accents/symbols.
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- Opacity from globals
config.window_background_opacity = G.opacity or 0.95
config.macos_window_background_blur = 10

-- Background with dynamic opacity from globals
config.background = {
	{
		source = {
			File = wezterm.config_dir .. "/images/pexels-eberhardgross-572897.jpg",
		},
		opacity = G.bg_image_opacity or 0.5, -- Adjust the image opacity
	},
	{
		source = {
			Color = "#000000",
		},
		opacity = G.bg_overlay_opacity or 0.9, -- Adjust the overlay opacity
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

-- Setup keybindings from keys module
keys.setup(config)

config.scrollback_lines = 10000
config.hide_mouse_cursor_when_typing = true
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"
return config
