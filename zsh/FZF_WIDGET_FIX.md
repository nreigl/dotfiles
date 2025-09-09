# ZSH FZF Widget Declaration Fix

## Problem
When loading zsh-syntax-highlighting plugin, the following errors appeared:
```
zsh-syntax-highlighting: unhandled ZLE widget 'fzf-git-branch'
zsh-syntax-highlighting: unhandled ZLE widget 'fzf-git-files'
zsh-syntax-highlighting: unhandled ZLE widget 'fzf-file-preview'
```

## Root Cause
The zsh-syntax-highlighting plugin needs to know about all ZLE (Zsh Line Editor) widgets when it loads. Our custom FZF functions were being sourced at line 241 of `.zshrc`, but the syntax highlighting plugin was loaded much earlier at line 68. This timing issue caused the plugin to complain about "unhandled" widgets.

## Solution
Pre-declare the custom widgets immediately before loading the syntax highlighting plugin. The widgets are declared as empty shells at line 58-60, then fully implemented when `.fzf-functions` is sourced later.

### Changes Made
In `.zshrc` at lines 55-60, added:
```zsh
# Pre-declare FZF custom widgets to prevent zsh-syntax-highlighting errors
# These widgets are fully defined in ~/.fzf-functions (loaded at line 241)
# but must be declared here before syntax highlighting plugin loads
zle -N fzf-git-files
zle -N fzf-git-branch
zle -N fzf-file-preview
```

## How It Works
1. Widget declarations (`zle -N widget-name`) create empty widget registrations
2. zsh-syntax-highlighting loads and recognizes these widgets
3. Later, when `.fzf-functions` is sourced, the widgets are re-registered with their actual implementations
4. ZSH allows re-declaring widgets, so this two-step process works perfectly

## Files Involved
- `/Users/nicolasreigl/dotfiles/zsh/.zshrc` - Widget pre-declarations added
- `/Users/nicolasreigl/dotfiles/zsh/.fzf-functions` - Contains actual widget implementations

## Testing
Run `source ~/.zshrc` - should load without any "unhandled ZLE widget" errors.