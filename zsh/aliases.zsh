## Alias ##
## Use colors in coreutils utilities output
alias ls='ls --color=auto'
alias grep='grep --color'

# ls aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls'
alias lh="ls -a | egrep "^\."" # alias dotfiles
# List only directories
 alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# show only hidden files (dot files)
# alias hidden='ls -a | grep "^\."'
# show only hidden files with additional arguments
# hidden() { ls -a "$@" | grep '^\.'; }

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade --all; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# git related aliases
alias gag='git exec ag'
# Remove git from a project
alias ungit="find . -name '.git' -exec rm -rf {} \;"


# alias Dropbox
alias db="cd ~/Dropbox/"
# quick source
alias zs="source ~/.zshrc"

alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

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

ester() {
    search=""
    echo "Googling: $@"
    for term in $@; do
        search="$search%20$term"
    done
    opens "https://www.ester.ee/search?q=$search"
}


google() {
    search=""
    echo "Googling: $@"
    for term in $@; do
        search="$search%20$term"
    done
    xdg-open "http://www.google.com/search?q=$search"
}


## Export path directions ##
# path to anaconda3
export PATH="/Users/nicolasreigl/anaconda3/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/TeX/texbin"
# open matlab from the terminal
export PATH=/Applications/MATLAB_R2016a.app/bin:$PATH
