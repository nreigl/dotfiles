local wezterm = require("wezterm")
local globals = require("utils.globals")
local act = wezterm.action

local M = {}

-- Helper: fzf switcher which opens in a right split and executes a command with live preview
M.fzfSwitcher = function(window, pane, script, command)
  -- Execute fzf with update script on every cursor move for live preview
  local fzfCommand = "fzf --color=gutter:-1,bg+:-1 --reverse --preview-window=down,1 --preview='" .. script .. " {}'"

  window:perform_action(
    act.SplitPane({
      direction = "Right",
      command = {
        args = {
          "zsh",
          "-c",
          command .. fzfCommand,
        },
      },
      size = { Percent = 25 },
    }),
    pane
  )
end

-- Theme Switcher with live preview
function M.themes()
  return wezterm.action_callback(function(window, pane)
    local scriptsPath = wezterm.config_dir .. "/scripts"

    -- Get all builtin color schemes and format them for fzf
    local schemes = wezterm.color.get_builtin_schemes()
    local scheme_list = {}
    for name, _ in pairs(schemes) do
      table.insert(scheme_list, name)
    end
    table.sort(scheme_list)

    -- Create temp file with themes
    local themes_file = os.tmpname()
    local f = io.open(themes_file, "w")
    for _, name in ipairs(scheme_list) do
      f:write(name .. "\n")
    end
    f:close()

    -- Build command: cat themes file and pipe to fzf with preview
    local themesCommand = "cat " .. themes_file .. " | "

    M.fzfSwitcher(window, pane, scriptsPath .. "/updateTheme.lua", themesCommand)

    -- Clean up temp file after a delay
    wezterm.time.call_after(1, function()
      os.remove(themes_file)
    end)
  end)
end

-- Font Switcher with live preview
function M.fonts()
  return wezterm.action_callback(function(window, pane)
    local scriptsPath = wezterm.config_dir .. "/scripts"

    -- Get system fonts by family name including only monospaced fonts, format and sort them
    local fontsCommand = "fc-list :spacing=100 family | grep -v '^\\.' | cut -d ',' -f1 | sort -u | "

    M.fzfSwitcher(window, pane, scriptsPath .. "/updateFont.lua", fontsCommand)
  end)
end

-- Font Size: Increase
function M.increaseFontSize(window, pane)
  globals.setGlobals(function(g)
    g.font_size = (g.font_size or 15.0) + 1.0
  end)
end

-- Font Size: Decrease
function M.decreaseFontSize(window, pane)
  globals.setGlobals(function(g)
    g.font_size = math.max((g.font_size or 15.0) - 1.0, 8.0)
  end)
end

-- Font Size: Reset
function M.resetFontSize(window, pane)
  globals.setGlobals(function(g)
    g.font_size = 15.0
  end)
end

-- Opacity: More Opaque
function M.moreOpacity(window, pane)
  globals.setGlobals(function(g)
    g.opacity = math.min((g.opacity or 0.95) + 0.05, 1.0)
  end)
end

-- Opacity: Reset
function M.resetOpacity(window, pane)
  globals.setGlobals(function(g)
    g.opacity = 0.95
  end)
end

-- Opacity: More Transparent
function M.lessOpacity(window, pane)
  globals.setGlobals(function(g)
    g.opacity = math.max((g.opacity or 0.95) - 0.05, 0.5)
  end)
end

-- Background Overlay: Lighten
function M.lightenBgOverlay(window, pane)
  globals.setGlobals(function(g)
    g.bg_overlay_opacity = math.max((g.bg_overlay_opacity or 0.9) - 0.05, 0.0)
  end)
end

-- Background Overlay: Darken
function M.darkenBgOverlay(window, pane)
  globals.setGlobals(function(g)
    g.bg_overlay_opacity = math.min((g.bg_overlay_opacity or 0.9) + 0.05, 1.0)
  end)
end

-- Background Overlay: Reset
function M.resetBgOverlay(window, pane)
  globals.setGlobals(function(g)
    g.bg_overlay_opacity = 0.9
  end)
end

-- Background Image: Lighten
function M.lightenBgImage(window, pane)
  globals.setGlobals(function(g)
    g.bg_image_opacity = math.min((g.bg_image_opacity or 0.5) + 0.05, 1.0)
  end)
end

-- Background Image: Darken
function M.darkenBgImage(window, pane)
  globals.setGlobals(function(g)
    g.bg_image_opacity = math.max((g.bg_image_opacity or 0.5) - 0.05, 0.0)
  end)
end

-- Background Image: Reset
function M.resetBgImage(window, pane)
  globals.setGlobals(function(g)
    g.bg_image_opacity = 0.5
  end)
end

-- Toggle Solid Background (no transparency, no image)
function M.toggleSolidBackground(window, pane)
  globals.setGlobals(function(g)
    g.solid_background = not (g.solid_background or false)
    if g.solid_background then
      -- Solid opaque background
      g.opacity = 1.0
      g.bg_overlay_opacity = 1.0
      g.bg_image_opacity = 0.0
    else
      -- Restore defaults
      g.opacity = 0.95
      g.bg_overlay_opacity = 0.9
      g.bg_image_opacity = 0.5
    end
  end)
end

-- Project Switcher with preview
function M.projects()
  return wezterm.action_callback(function(window, pane)
    local scriptsPath = wezterm.config_dir .. "/scripts"
    local home = os.getenv("HOME")

    -- Define common project locations to search
    local search_paths = {
      home,
      home .. "/Projects",
      home .. "/projects",
      home .. "/code",
      home .. "/work",
      home .. "/dev",
      home .. "/dotfiles",
    }

    -- Build find command to locate directories (max depth 3)
    local find_commands = {}
    for _, path in ipairs(search_paths) do
      table.insert(
        find_commands,
        string.format("find '%s' -maxdepth 3 -type d -not -path '*/.*' 2>/dev/null", path)
      )
    end

    -- Combine all find commands and pipe to fzf with preview
    local projectsCommand = table.concat(find_commands, "; ") .. " | "

    -- Custom action: on selection, switch to project in tmux
    local switchCommand = projectsCommand ..
      "fzf --color=gutter:-1,bg+:-1 --reverse " ..
      "--preview-window=down,60% " ..
      "--preview='lua " .. scriptsPath .. "/switchProject.lua {}' " ..
      "--bind='enter:execute(" ..
        "tmux new-session -A -s {/} -c {}" ..
      ")+abort'"

    window:perform_action(
      act.SplitPane({
        direction = "Right",
        command = {
          args = { "zsh", "-c", switchCommand },
        },
        size = { Percent = 30 },
      }),
      pane
    )
  end)
end

return M
