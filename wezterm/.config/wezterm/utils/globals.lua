local wezterm = require("wezterm")
local M = {}

-- Path to the globals file (using JSON for better compatibility)
M.globals_file = wezterm.config_dir .. "/globals.json"

-- Read globals from JSON file
function M.readGlobals()
  local file = io.open(M.globals_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local success, globals = pcall(function()
      return wezterm.json_parse(content)
    end)
    if success and globals then
      return globals
    end
  end

  -- Return defaults if file doesn't exist or can't be read
  return {
    colorscheme = "Dracula",
    opacity = 0.95,
    font_family = "JetBrains Mono",
    font_size = 15.0,
    bg_overlay_opacity = 0.9,
    bg_image_opacity = 0.5,
    solid_background = false,
  }
end

-- Write globals to JSON file
function M.setGlobals(callback)
  local globals = M.readGlobals()

  -- Call the callback to modify globals
  callback(globals)

  -- Encode and write to file
  local content = wezterm.json_encode(globals)
  local file = io.open(M.globals_file, "w")
  if file then
    file:write(content)
    file:close()

    -- Reload configuration
    wezterm.reload_configuration()
  end
end

return M
