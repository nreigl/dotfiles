local wezterm = require("wezterm")
local globals = require("utils.globals")
local keys = require("keys")

local config = wezterm.config_builder()

-- Read globals for dynamic configuration
local G = globals.readGlobals()

-- Note: tmux auto-attach is handled in .zshrc instead of here
-- (WezTerm's default_prog with tmux causes TTY issues)

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

-- Background configuration based on solid_background setting
if not G.solid_background then
	-- Background with dynamic opacity from globals
	config.background = {
		{
			source = {
				File = wezterm.config_dir .. "/images/pexels-eberhardgross-572897.jpg",
			},
			opacity = G.bg_image_opacity or 0.5,
			width = "100%",
			height = "100%",
		},
		{
			source = {
				Color = "#000000",
			},
			opacity = G.bg_overlay_opacity or 0.9,
			width = "100%",
			height = "100%",
		},
	}
end

-- Setup keybindings from keys module
keys.setup(config)

config.scrollback_lines = 10000
config.hide_mouse_cursor_when_typing = true
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"
return config
