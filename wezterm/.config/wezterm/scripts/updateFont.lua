#!/usr/bin/env lua

-- Read globals.json
local home = os.getenv("HOME")
local globals_path = home .. "/dotfiles/wezterm/.config/wezterm/globals.json"

local function read_json(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()

  -- Simple JSON parser for our use case
  local globals = {}
  for key, value in content:gmatch('"([^"]+)":([^,}]+)') do
    -- Remove quotes and whitespace
    value = value:gsub('^%s*"?', ''):gsub('"?%s*$', '')
    -- Try to convert to number
    local num = tonumber(value)
    if num then
      globals[key] = num
    elseif value == "true" then
      globals[key] = true
    elseif value == "false" then
      globals[key] = false
    else
      globals[key] = value
    end
  end
  return globals
end

local function write_json(path, data)
  local file = io.open(path, "w")
  if not file then return false end

  local json_str = "{"
  local first = true
  for k, v in pairs(data) do
    if not first then json_str = json_str .. "," end
    first = false

    json_str = json_str .. '"' .. k .. '":'
    if type(v) == "string" then
      json_str = json_str .. '"' .. v .. '"'
    elseif type(v) == "boolean" then
      json_str = json_str .. tostring(v)
    else
      json_str = json_str .. tostring(v)
    end
  end
  json_str = json_str .. "}"

  file:write(json_str)
  file:close()
  return true
end

-- Get font from command line argument
local font = arg[1]
if not font then
  print("Usage: updateFont.lua <font-name>")
  os.exit(1)
end

-- Read current globals
local globals = read_json(globals_path)
if not globals then
  globals = {
    colorscheme = "Dracula",
    opacity = 0.95,
    font_family = "JetBrains Mono",
    font_size = 15.0,
    bg_overlay_opacity = 0.9,
    bg_image_opacity = 0.5,
    solid_background = false
  }
end

-- Update font
globals.font_family = font

-- Write back
write_json(globals_path, globals)

-- Print for preview
print("Font: " .. font)
