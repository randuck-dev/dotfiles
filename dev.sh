#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
NVIM_DIR="$HOME/.config/nvim"
TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
ALACRITTY_DIR="$HOME/.config/alacritty"
ALACRITTY_THEMES_DIR="$ALACRITTY_DIR/themes"
SSH_DIR="$HOME/.ssh"


if ! [ -d $NVIM_DIR ]; then
    echo "nvim dir does not exist linking it"
    ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
else
    echo "not linking nvim dir, since it already exists"
fi

if ! [ -x "$(command -v brew)" ]; then
    echo "brew not found. Installing it..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "brew found"
fi

if ! [ -d $ALACRITTY_THEMES_DIR ]; then
    echo "alacritty themes not found"
    mkdir -p ~/.config/alacritty/themes
    git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
else
    echo "alacritty themes found"
fi

if ! [ -x "$(command -v ansible)" ]; then
    echo "ansible not found. installing it..."
    brew install ansible
else
    echo "ansible found"
fi

ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/alacritty.yml" "$ALACRITTY_DIR/alacritty.yml"


# Run install of rest of the deps in the end
ansible-playbook "$DOTFILES_DIR/main.yml"


