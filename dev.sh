#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
NVIM_DIR="$HOME/.config/nvim"
TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
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

if ! [ -x "$(command -v ansible)" ]; then
    echo "ansible not found. installing it..."
    brew install ansible
else
    echo "ansible found"
fi

if ! [ -d "$TMUX_PLUGIN_DIR/tpm" ]; then
    echo "TPM not installed"
    mkdir -p "$TMUX_PLUGIN_DIR/tpm"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM found"
fi

ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"


# Run install of rest of the deps in the end
ansible-playbook "$DOTFILES_DIR/main.yml"
