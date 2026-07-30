local wezterm = require("wezterm")
local globals = require("utils.globals")
local act = wezterm.action

local M = {}

-- Absolute paths: a GUI-launched WezTerm inherits macOS's minimal PATH
-- (/usr/bin:/bin:/usr/sbin:/sbin), so Homebrew binaries must be named in full.
-- Declared here so the switcher closures below capture them as upvalues.
local HERDR = "/opt/homebrew/bin/herdr"
local FC_LIST = "/opt/homebrew/bin/fc-list"

-- Theme Switcher. Uses WezTerm's native InputSelector (fuzzy=true) rather than
-- an fzf subprocess: a GUI-launched WezTerm inherits macOS's minimal PATH, so
-- /opt/homebrew/bin/fzf is not resolvable and the split pane died instantly.
function M.themes()
  return wezterm.action_callback(function(window, pane)
    local schemes = wezterm.color.get_builtin_schemes()
    local choices = {}
    for name, _ in pairs(schemes) do
      table.insert(choices, { label = name })
    end
    table.sort(choices, function(a, b)
      return a.label < b.label
    end)

    window:perform_action(
      act.InputSelector({
        title = "Select Color Scheme",
        description = "Type to fuzzy-search, Enter to apply, Esc to cancel",
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(_, _, _, label)
          if not label then
            return -- cancelled
          end
          globals.setGlobals(function(g)
            g.colorscheme = label
          end)
        end),
      }),
      pane
    )
  end)
end

-- Font Switcher. Lists monospaced families via fc-list, presented in WezTerm's
-- native fuzzy selector. fc-list needs its absolute path for the same
-- GUI-launch PATH reason as herdr/tmux below.
function M.fonts()
  return wezterm.action_callback(function(window, pane)
    local seen, choices = {}, {}
    local pipe = io.popen(FC_LIST .. " :spacing=100 family 2>/dev/null")
    if pipe then
      for line in pipe:lines() do
        -- fc-list emits comma-separated aliases; the first is the family name
        local family = line:match("^([^,]+)")
        if family and family ~= "" and not family:match("^%.") and not seen[family] then
          seen[family] = true
          table.insert(choices, { label = family })
        end
      end
      pipe:close()
    end
    table.sort(choices, function(a, b)
      return a.label < b.label
    end)

    if #choices == 0 then
      window:toast_notification("WezTerm", "No monospaced fonts found", nil, 4000)
      return
    end

    window:perform_action(
      act.InputSelector({
        title = "Select Font",
        description = "Type to fuzzy-search, Enter to apply, Esc to cancel",
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(_, _, _, label)
          if not label then
            return -- cancelled
          end
          globals.setGlobals(function(g)
            g.font_family = label
          end)
        end),
      }),
      pane
    )
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

-- Toggle Solid Background (no image) vs background-image mode.
-- Remembers the opacity tuned in solid mode (saved_solid_opacity) instead of
-- clobbering it, so toggling back restores your transparent look.
function M.toggleSolidBackground(window, pane)
  globals.setGlobals(function(g)
    g.solid_background = not (g.solid_background or false)
    if g.solid_background then
      -- Back to solid mode: restore the remembered opacity
      g.opacity = g.saved_solid_opacity or 0.95
      g.bg_overlay_opacity = 1.0
      g.bg_image_opacity = 0.0
    else
      -- Into image mode: remember current opacity first
      -- Overlay at 1.0 = solid Nord tint, photo fully hidden. Drop toward 0.85
      -- if you ever want the image to read through as faint texture.
      g.saved_solid_opacity = g.opacity
      g.opacity = 0.92
      g.bg_overlay_opacity = 1.0
      g.bg_image_opacity = 0.15
    end
  end)
end

-- Project Switcher. Enumerates git repos via /usr/bin/find (always on PATH),
-- then presents them in WezTerm's native fuzzy selector instead of fzf.
function M.projects()
  return wezterm.action_callback(function(window, pane)
    local home = os.getenv("HOME")

    local search_paths = {
      home,
      home .. "/Projects",
      home .. "/projects",
      home .. "/code",
      home .. "/work",
      home .. "/dev",
      home .. "/dotfiles",
    }

    -- Locate git repos rather than every directory: a bare -type d sweep of
    -- $HOME at depth 3 returns thousands of entries and is slow to boot.
    local find_commands = {}
    for _, path in ipairs(search_paths) do
      table.insert(
        find_commands,
        -- -not -path filter: skip repos inside hidden dirs (~/.config/AstroNvim,
        -- ~/.nvm, ...) — config-manager clones, not projects
        string.format("/usr/bin/find '%s' -maxdepth 3 -type d -name .git -not -path '*/.*/.git' 2>/dev/null", path)
      )
    end

    local seen, choices = {}, {}
    local pipe = io.popen(table.concat(find_commands, "; "))
    if pipe then
      for line in pipe:lines() do
        local dir = line:gsub("/%.git$", "")
        if dir ~= "" and not seen[dir] then
          seen[dir] = true
          table.insert(choices, { label = dir:gsub("^" .. home, "~"), id = dir })
        end
      end
      pipe:close()
    end
    table.sort(choices, function(a, b)
      return a.label < b.label
    end)

    if #choices == 0 then
      window:toast_notification("WezTerm", "No git projects found", nil, 4000)
      return
    end

    window:perform_action(
      act.InputSelector({
        title = "Select Project",
        description = "Type to fuzzy-search, Enter to open, Esc to cancel",
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(win, _, id, _)
          if not id then
            return -- cancelled
          end
          local label = id:match("([^/]+)$") or id

          -- Dedupe: focus an existing workspace with this label instead of
          -- creating a twin. Label = folder basename is the best key the API
          -- offers (workspace cwd is not exposed), so same-named repos in
          -- different parents map to one workspace.
          local pipe = io.popen(HERDR .. " workspace list 2>/dev/null")
          if pipe then
            local out = pipe:read("*all")
            pipe:close()
            local ok_parse, data = pcall(wezterm.json_parse, out)
            if ok_parse and data and data.result then
              for _, w in ipairs(data.result.workspaces or {}) do
                if w.label == label then
                  os.execute(
                    string.format("%s workspace focus %q >/dev/null 2>&1", HERDR, w.workspace_id)
                  )
                  return
                end
              end
            end
          end

          -- herdr only. No tmux fallback by choice: nesting herdr inside tmux
          -- swallowed keys (see .zshrc auto-attach note), so a failure here
          -- should surface rather than silently open a different multiplexer.
          local ok = os.execute(
            string.format(
              "%s workspace create --cwd %q --label %q --focus >/dev/null 2>&1",
              HERDR, id, label
            )
          )
          if not ok then
            win:toast_notification(
              "WezTerm",
              "herdr could not open " .. label .. " — is the herdr server running?",
              nil,
              5000
            )
          end
        end),
      }),
      pane
    )
  end)
end

return M
