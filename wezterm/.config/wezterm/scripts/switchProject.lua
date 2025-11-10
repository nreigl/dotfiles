#!/usr/bin/env lua

-- WezTerm project switcher script
-- Shows preview information about a project directory

-- Get the project path from command line argument
local project_path = arg[1]

if not project_path or project_path == "" then
  os.exit(0)
end

-- Trim whitespace
project_path = project_path:match("^%s*(.-)%s*$")

-- Print project name
local project_name = project_path:match("([^/]+)$") or project_path
print("📁 Project: " .. project_name)
print("📂 Path: " .. project_path)
print()

-- Check if directory exists
local dir_check = io.popen("test -d '" .. project_path .. "' && echo 'exists'")
local exists = dir_check:read("*a"):match("exists")
dir_check:close()

if not exists then
  print("⚠️  Directory does not exist")
  os.exit(0)
end

-- Check if it's a git repository
local git_check = io.popen("cd '" .. project_path .. "' 2>/dev/null && git rev-parse --git-dir 2>/dev/null")
local is_git = git_check:read("*a") ~= ""
git_check:close()

if is_git then
  print("🌿 Git repository")

  -- Get current branch
  local branch_cmd = io.popen("cd '" .. project_path .. "' && git branch --show-current 2>/dev/null")
  local branch = branch_cmd:read("*a"):gsub("\n", "")
  branch_cmd:close()

  if branch ~= "" then
    print("   Branch: " .. branch)
  end

  -- Get git status summary
  local status_cmd = io.popen("cd '" .. project_path .. "' && git status --short 2>/dev/null | wc -l")
  local changes = tonumber(status_cmd:read("*a"))
  status_cmd:close()

  if changes and changes > 0 then
    print("   Changes: " .. changes .. " files modified")
  else
    print("   Status: Clean")
  end
else
  print("📄 Not a git repository")
end

-- Count files in directory (excluding hidden and git files)
local count_cmd = io.popen("find '" .. project_path .. "' -maxdepth 3 -type f 2>/dev/null | grep -v '/\\.' | wc -l")
local file_count = count_cmd:read("*a"):gsub("\n", "")
count_cmd:close()

print()
print("📊 Files: ~" .. file_count)

-- Show recent files (modified in last 7 days)
print()
print("🕐 Recently modified:")
local recent_cmd = io.popen("find '" .. project_path .. "' -maxdepth 2 -type f -mtime -7 2>/dev/null | grep -v '/\\.' | head -5 | xargs -I {} basename {}")
for line in recent_cmd:lines() do
  if line ~= "" then
    print("   • " .. line)
  end
end
recent_cmd:close()
