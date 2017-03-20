# Path to your oh-my-zsh configuration.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="powerlevel9k/powerlevel9k" # agnoster or #fino-time # or cobalt2
# configure powerline for powerlevel9k
POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status virtualenv docker_machine)
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"

# POWERLEVEL9K_VCS_GIT_ICON=''
POWERLEVEL9K_VCS_STAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_UNTRACKED_ICON='\u25CF'
POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'

# Ensure languages are set
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
extract
web-search
python
gitignore
git-flow
brew
osx
sublime
atom
matlab
autoenv
vi-mode
zsh-pandoc-completion
virtualenv
# virtualenvwrapper
)

# Uncomment this to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

source "$ZSH/oh-my-zsh.sh"

## User configuration
# sourcing external files
# Settings
source ~/.zsh/settings.zsh

# Bootstrap
source ~/.zsh/bootstrap.zsh

# Aliases
source ~/.zsh/aliases.zsh

# Syntax highlighting
source ~/.zsh/syntax.zsh

# external plugins
source ~/.zsh/plugins/z/z.sh

# Don't resolve symbolic links in z
_Z_NO_RESOLVE_SYMLINKS="true"

# Julia path
export PATH="/Users/nicolasreigl/github/repos/julia/usr/bin:$PATH"

# Python path
export PYTHONNOUSERSITE="$HOME/.local"

# zathura path
export PATH="/usr/local/Cellar/zathura/0.3.6/bin:$PATH"

# added by Anaconda3 4.2.0 installer
export PATH="/Users/nicolasreigl/anaconda3/bin:$PATH"

# added by Anaconda2 4.2.0 installer
export PATH="/Users/nicolasreigl/anaconda2/bin:$PATH"

# added by Miniconda3 4.2.12 installer
export PATH="/Users/nicolasreigl/miniconda3/bin:$PATH"
