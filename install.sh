#!/bin/bash

install_brew() {
    if ! command -v "brew" &> /dev/null; then
        printf "Homebrew not found, installing."
        # install homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # set path
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    sudo softwareupdate --install-rosetta

    printf "Installing homebrew packages..."
    brew bundle
}

create_dirs() {
    declare -a dirs=(
        "$HOME/Downloads/torrents"
        "$HOME/Desktop/screenshots"
        "$HOME/dev"
    )

    for i in "${dirs[@]}"; do
        mkdir "$i"
    done
}

build_xcode() {
    if ! xcode-select --print-path &> /dev/null; then
        xcode-select --install &> /dev/null

        until xcode-select --print-path &> /dev/null; do
            sleep 5
        done

        sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

        sudo xcodebuild -license
    fi
}

install_app_store_apps() {
    mas install 497799835 # Xcode
    mas install 1370791134 # DigiDoc4
    mas install 1317704208 # eduVPN
    mas install 1576665083 # Web eID
}

printf "🗄  Creating directories\n"
create_dirs

printf "🛠  Installing Xcode Command Line Tools\n"
build_xcode

printf "🍺  Installing Homebrew packages\n"
install_brew

printf "🛍️  Installing Mac App Store apps\n"
install_app_store_apps

printf "💻  Set macOS preferences\n"
./macos/.macos

printf "🔧  Configure development tools\n"
# Ruby, Node, Python, and other language versions are managed by mise
# See mise.toml for configuration
# UV handles Python package management
# Neovim uses LazyVim (lazy.nvim plugin manager)

printf "🐗  Stow dotfiles\n"
# Run the stow-all script which contains the up-to-date list of packages
./scripts/stow-all.sh

printf "✨  Done!\n"
