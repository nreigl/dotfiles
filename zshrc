# Path to your oh-my-zsh configuration.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="cobalt2" # agnoster or #fino-time

# Ensure languages are set
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set name of the theme to load.
ZSH_THEME="cobalt2" # agnoster or #fino-time

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
virtualenvwrapper
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
