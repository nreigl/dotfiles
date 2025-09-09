# Useful shell functions

# === Directory Operations ===
# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
  local d=""
  local limit="${1:-1}"
  for ((i=1; i<=limit; i++)); do
    d="../$d"
  done
  cd "$d" || return
}

# === Archive Operations ===
# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.tar.xz)    tar xf "$1"      ;;
      *.tar.zst)   tar xf "$1"      ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Create archive
archive() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: archive <archive_name.tar.gz> <directory>"
    return 1
  fi
  tar czf "$1" "$2"
  echo "Created archive: $1"
}

# === File Operations ===
# Quick backup with timestamp
backup() {
  if [ -z "$1" ]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
  echo "Backed up to: $1.bak.$(date +%Y%m%d_%H%M%S)"
}

# Find and replace in files
replace() {
  if [ "$#" -ne 3 ]; then
    echo "Usage: replace <find> <replace> <file_pattern>"
    echo "Example: replace 'old text' 'new text' '*.txt'"
    return 1
  fi
  rg -l "$1" -g "$3" | xargs -I {} sed -i '' "s/$1/$2/g" {}
}

# === Git Operations ===
# Git commit with message
gcmsg() {
  git commit -m "$*"
}

# Git push to current branch
gpush() {
  git push origin $(git branch --show-current)
}

# Git pull from current branch
gpull() {
  git pull origin $(git branch --show-current)
}

# === Development ===
# Create Python project with UV
pyproject() {
  if [ -z "$1" ]; then
    echo "Usage: pyproject <project_name>"
    return 1
  fi
  uv init "$1" --python 3.12
  cd "$1"
  uv add pytest ruff mypy --dev
  echo "Created Python project: $1"
}

# Create Julia project
jlproject() {
  if [ -z "$1" ]; then
    echo "Usage: jlproject <project_name>"
    return 1
  fi
  mkdir -p "$1"
  cd "$1"
  julia -e 'using Pkg; Pkg.generate(".")'
  echo "Created Julia project: $1"
}

# === System Info ===
# System information
sysinfo() {
  echo "System Information:"
  echo "==================="
  echo "Hostname: $(hostname)"
  echo "OS: $(uname -s) $(uname -r)"
  echo "Kernel: $(uname -v)"
  echo "Architecture: $(uname -m)"
  echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || grep -m1 'model name' /proc/cpuinfo | cut -d: -f2)"
  echo "Memory: $(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024 " GB"}' || free -h | awk '/^Mem:/ {print $2}')"
  echo "Disk: $(df -h / | awk 'NR==2 {print $2 " total, " $3 " used, " $4 " free"}')"
}

# === Network ===
# Get local IP
localip() {
  ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
}

# Test port
testport() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: testport <host> <port>"
    return 1
  fi
  nc -zv "$1" "$2"
}

# === FZF Enhanced Functions ===
# cd to selected directory
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf +m) && cd "$dir"
}

# Open file in editor
fe() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}') && ${EDITOR:-nvim} "$file"
}

# Kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo "$pid" | xargs kill -9
  fi
}

# Git branch selection
fbr() {
  local branch
  branch=$(git branch --all | grep -v HEAD | fzf +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# === Docker Functions ===
# Docker container shell
dsh() {
  docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

# Docker cleanup
dclean() {
  docker system prune -af --volumes
  echo "Docker cleanup complete"
}

# === Utility ===
# Weather for a city
weather() {
  curl "wttr.in/${1:-}"
}

# Cheat sheet
cheat() {
  curl "cheat.sh/$1"
}

# Calculator
calc() {
  echo "$*" | bc -l
}