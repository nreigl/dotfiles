## Alias ##
## Use colors in coreutils utilities output
alias ls='ls -G'
alias grep='grep --color'

# ls aliases
alias ll='ls -lah'
alias la='ls -A'
alias lh="ls -ld ~/.[^.]*" # alias dotfiles
# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade --all; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Turn on/ off key repeat
alias keyon="defaults write -g ApplePressAndHoldEnabled -bool false"
alias keyoff="defaults write -g ApplePressAndHoldEnabled -bool true"
# Get week number
alias week='date +%V'

# Merge PDF files
# Usage: `mergepdf -o output.pdf input{1,2,3}.pdf`
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# Aliases to use Neovim instead of vim
alias vim="nvim"

# Hub: Add sugar to git completions
eval "$(hub alias -s)"

# git related aliases
alias gag='git exec ag'
# Remove git from a project
alias ungit="find . -name '.git' -exec rm -rf {} \;"

# alias Dropbox
alias db="cd ~/Dropbox/"

# alias nvim config
alias vimconfig="nvim ~/.config/nvim/init.vim"

# alias ranger config
alias rangerconfig="nvim ~/.config/ranger/rc.conf"

# alias tmux config
alias tmuxconfig="nvim ~/.tmux.conf"

# quick source
alias zs="source ~/.zshrc"
alias aliasconfig="nvim  ~/dotfiles/zsh/aliases.zsh"

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# cd to git root directory
alias cdgr='cd "$(git root)"'

# open html in chrome
alias chrome="open -a \"Google Chrome\""

#copy output of last command to clipboard
alias cl="fc -e -|pbcopy"

# copy the working directory path
alias cpwd='pwd|tr -d "\n"|pbcopy'

# Get your current public IP
alias ip="curl icanhazip.com"

# Rice
alias r="rice"

# Git pull over all subdirectories
alias uprepos="ls | xargs -P10 -I{} git -C {} pull"

# Git desperation
alias gcd=git commit -am $(apcom)

# update RStudio beta
alias uprstudio="~/.zsh/plugins/ac3934e08d2961285bef/install-rstudio-daily.sh"

## Functions ##
# Update dotfiles
function dfu() {
  (
  cd ~/.dotfiles && git pull --ff-only && ./install -q
  )
}

# Use pip without requiring virtualenv
function syspip() {
  PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

function syspip3() {
  PIP_REQUIRE_VIRTUALENV="" pip3 "$@@"
}


# Create a directory and cd into it
function mcd() {

  mkdir "${1}" && cd "${1}"
}

# Jump to directory containing file
function jump() {
  cd "$(dirname ${1})"
}

# Go up [n] directories
function up()
{
  local cdir="$(pwd)"
  if [[ "${1}" == "" ]]; then
    cdir="$(dirname "${cdir}")"
  elif ! [[ "${1}" =~ ^[0-9]+$ ]]; then
    echo "Error: argument must be a number"
  elif ! [[ "${1}" -gt "0" ]]; then
    echo "Error: argument must be positive"
  else
    for i in {1..${1}}; do
      local ncdir="$(dirname "${cdir}")"
      if [[ "${cdir}" == "${ncdir}" ]]; then
        break
      else
        cdir="${ncdir}"
      fi
    done
  fi
  cd "${cdir}"
}

# Execute a command in a specific directory
function in() {
  (
  cd ${1} && shift && ${@}
  )
}

# Check if a file contains non-ascii characters
function nonascii() {
  LC_ALL=C grep -n '[^[:print:][:space:]]' ${1}
}

# Fetch pull request
function fpr() {
  git fetch "git@github.com:${2}/${1}" "${3}:${2}/${3}"
}

# Change iterm2 profile. Usage it2prof ProfileName (case sensitive)
it2prof() { echo -e "\033]50;SetProfile=$1\a" }

# Open in PathFinder from the Terminal
pf () { open -a "Path Finder.app" $1; }

# Url to pdf api
function urldpf(){
  curl -o google.pdf https://url-to-pdf-api.herokuapp.com/api/render?url="$1"
}

# Most recent modified file
alias latest='\ls -t | head -n 1'
# nth most recent modified file
latestn(){
  \ls -t | head -n $1 | tail -n 1
}
# The names of the n most recently modified files in this directory and all
# subdirectories. See http://stackoverflow.com/a/4561987/2514228
latestr(){
  find . -type f -printf '%T@ %p\n' | sort -n | tail -n $1 | cut -f2 -d" "
}

## utilities

# open with system default application
alias o='open_command'
alias o.='o .'

# stdin to clipboard
alias xclip='xclip -selection c'

# enable advanced calculation in bc by default
alias bc='bc -l'

## youtube-dl
# standard
alias ydl="youtube-dl"
## youtube-dl available version
alias ydf="youtube-dl -F"
# default parameters for youtube-dl
alias ytdl='youtube-dl --prefer-ffmpeg -o "%(title)s.%(ext)s"'

# R
findinRfun() {

  if [ -z "$1" ]
  then
    echo "No argument supplied"
  else
    #search text is passed as argument $1
    find . -type f \( -name "*.R" -o -name "*.Rmd" -o -name "*.r" -o -name "*.rmd" \) -print0 | xargs --null grep --with-filename --line-number --no-messages --color --ignore-case "$1"
  fi
}
alias findinR=findinRfun

# Tmux {{{1
tm() {
    if (( $# )); then
        tmux has-session -t "$*" && tmux attach -t "$*" || tmux new-session -s "$*"
    else
        tmux attach || tmux new-session -s default
    fi
}


# fzf (https://github.com/junegunn/fzf)
# --------------------------------------------------------------------
# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  IFS=$'\n' out=($(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e))
  local out file key
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

# fuzzy grep open via ag
vg() {
  local file

  file="$(ag --nobreak --noheading $@ | fzf -0 -1 | awk -F: '{print $1 " +" $2}')"

  if [[ -n $file ]]
  then
    vim $file
  fi
}
# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
    -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
}



# fda - including hidden directories
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# cdf() {nto the directory of the selected file
cdf() {
  local file
  local dir
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}


# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# # `tm` will allow you to select your tmux session via fzf.
# # `tm irc` will attach to the irc session (if it exists), else it will create it.
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}


# fs [FUZZY PATTERN] - Select selected tmux session
# #   - Bypass fuzzy finder if there's only one match (--select-1)
# #   - Exit if there's no match (--exit-0)
fs() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --query="$1" --select-1 --exit-0) &&
    tmux switch-client -t "$session"
}


## Export path directions ##
# path to anaconda3
# export PATH="/Users/nicolasreigl/anaconda3/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/TeX/texbin"
# open matlab from the terminal
export PATH=/Applications/MATLAB_R2016a.app/bin:$PATH

# start terminal stata session
alias stata="/usr/bin/stata-mp"

# Julia environments
alias julia7="/Users/nicolasreigl/github/repos/julia/usr/bin/julia" #  Julia Dev (git)
alias julia6="/Applications/Julia-0.6.app/Contents/Resources/julia/bin/julia"

# git latex path:
export PATH=usr/local/Cellar/git/2.10.2/libexec/git-core:$PATH
