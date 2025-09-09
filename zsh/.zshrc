# === [ Basic Setup ] ===
export PATH="$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/.tmuxifier/bin:$PATH:/Users/nicolasreigl/.local/bin:/Users/nicolasreigl/Library/Python/3.9/bin"
export EDITOR="nvim"
typeset -U path

# === [ History ] ===
HISTSIZE=50000
SAVEHIST=10000

fpath+=("/opt/homebrew/share/zsh/site-functions")

typeset -A ZINIT
ZINIT[ALIASES]=no

# ---[ Zinit init (must come before zinit commands) ]---
if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
else
  echo "⚠️  Zinit not found — did the install fail?"
fi
unalias zi 2>/dev/null
# === [ zoxide (directory jumping) ] ===
zinit ice wait"0"
zinit light ajeetdsouza/zoxide

eval "$(zoxide init zsh)"
#
# === [ Zinit Init ] ===
# source ~/.local/share/zinit/zinit.zsh

# === [ Plugin Management ] ===
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light djui/alias-tips
zinit light zsh-users/zsh-history-substring-search
zinit light rupa/z  # Optional: if you prefer original 'z' over zoxide

# === [ Optional: lazy-load heavy plugins ] ===
# zinit ice wait"1" atload"alias g=git"
# zinit light ohmyzsh/plugins/git

# === [ Starship Prompt ] ===
zinit ice wait"0"  # load ASAP after init
zinit light starship/starship
eval "$(starship init zsh)"

# === [ FZF ] ===
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# === [ iTerm2 integration ] ===
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# === [ CD quality-of-life ] ===
setopt autocd

# === [ Neovim launcher ] ===
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"

function nvims() {
  local items config
  items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=50% --layout=reverse --border --exit-0)
  [[ -z $config ]] && { echo "Nothing selected"; return 0; }
  [[ $config == "default" ]] && config=""
  NVIM_APPNAME="$config" nvim "$@"
}

# Optional: fzf-cd-widget binding (use Alt-C or remap to ç)
bindkey "ç" fzf-cd-widget

# === [ Dotfiles and Secrets ] ===
[ -f "$HOME/dotfiles/zsh/.exports" ] && source "$HOME/dotfiles/zsh/.exports"
[ -f "$HOME/dotfiles/zsh/.aliases" ] && source "$HOME/dotfiles/zsh/.aliases"
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"


# === [ fzf cheat helper function ] ===
fzf-help() {
  local choice
  choice=$(cat <<EOF | fzf --prompt="FZF Help ❯ " --height=~50% --layout=reverse --border
🔍  Search command history              | history | fzf | cut -c 8-
📝  Open file with preview in editor   | fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}' | xargs nvim
📂  Fuzzy cd into directory            | fd -t d | fzf | xargs cd
📁  Zoxide fuzzy dir jump              | zi
🔎  Search file contents via ripgrep   | rg "search-term" | fzf
📜  Show recent git branches           | git branch --sort=-committerdate | fzf | xargs git checkout
🔄  Search and re-run shell history    | Ctrl+R
EOF
  )
  [[ -n "$choice" ]] && echo "$choice" | cut -d'|' -f2- | xargs -0 printf "\n%s\n"
}



# === [ Node Version Manager ] ===
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# === [ Tmux Autostart ] ===
[[ $- != *i* ]] && return
[[ -z "$TMUX" ]] && exec tmux
## End of Zinit's installer chunk
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/nicolasreigl/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
eval "$(gh copilot alias -- zsh)"
