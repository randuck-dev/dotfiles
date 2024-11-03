#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
NVIM_DIR="$HOME/.config/nvim"
TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
SSH_DIR="$HOME/.ssh"

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo "Applying OS specific scripts"
for file in $DOTFILES_DIR/os.d/*.sh; do
    echo "> $file"
    source $file
done


echo "Linking configuration files"
for dir in $DOTFILES_DIR/config/*; do
  target_dir="$CONFIG_DIR/$(basename $dir)"
  if [ ! -d $target_dir ]; then
    echo "> Creating symlink for $dir in $target_dir"
    ln -sf $dir $target_dir
  fi
done
echo "Finished linking configuration files"


echo "Applying shared scripts"
for sharedFile in $DOTFILES_DIR/shared.d/*.sh; do
    echo "> $sharedFile"
    source $sharedFile
done
echo "Finished applying shared scripts"

echo "Applying ansible playbook"
ansible-playbook "$DOTFILES_DIR/main.yml" --ask-become-pass

