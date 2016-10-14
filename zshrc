# Path to your oh-my-zsh installation.
export ZSH=/Users/nicolasreigl/.oh-my-zsh

# Set name of the theme to load.
ZSH_THEME="cobalt2" # agnoster or #fino-time

# Uncomment the following line to enable command auto-correction.
 ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
 COMPLETION_WAITING_DOTS="true"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(compleat extract git brew osx sublime z matlab autoenv zsh-syntax-highlighting)

# User configuration
# Settings
source ~/.zsh/settings.zsh

# Bootstrap
source ~/.zsh/bootstrap.zsh

# Aliases
source ~/.zsh/aliases.zsh

# Syntax highlighting
source ~/.zsh/syntax.zsh

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# include Z, yo: does not work for me via oh-my-zsh plugins
source /Users/nicolasreigl/dotfiles/zsh/plugins/z/z.sh

# Syntax highlighting
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zshit
source /Users/nicolasreigl/dotfiles/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
