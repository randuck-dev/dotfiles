#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
NVIM_DIR="$HOME/.config/nvim"
TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
SSH_DIR="$HOME/.ssh"

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

if ! [ -d $NVIM_DIR ]; then
    echo "nvim dir does not exist linking it"
    ln -sf $DOTFILES_DIR/nvim $HOME/.config/
else
    echo "not linking nvim dir, since it already exists"
fi


echo "Applying OS specific scripts"
for file in $DOTFILES_DIR/os.d/*.sh; do
    echo "> $file"
    source $file
done


echo "Applying shared scripts"
for sharedFile in $DOTFILES_DIR/shared.d/*.sh; do
    echo "> $sharedFile"
    source $sharedFile
done

echo "Applying ansible playbook"
ansible-playbook "$DOTFILES_DIR/main.yml" --ask-become-pass

