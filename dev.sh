#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

echo "Linking configuration files"
for dir in $DOTFILES_DIR/config/*; do
  target_dir="$CONFIG_DIR/$(basename $dir)"
  if [ ! -d $target_dir ]; then
    echo "> Creating symlink for $dir in $target_dir"
    ln -sf $dir $target_dir
  else
    echo "> $target_dir already exists"
  fi
done
echo "Finished linking configuration files"

if [ ! -f "$HOME/.ideavimrc" ]; then
  echo "Linking .ideavimrc"
  ln -sf "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
fi
