#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
dry_run="0"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
DOTFILES_DIR="$HOME/.dotfiles"

log() {
  if [[ $dry_run == "1" ]]; then
    echo "[DRY_RUN]: $1"
  else
    echo "$1"
  fi
}

source ./config.sh

if [ ! -f "$HOME/.ideavimrc" ]; then
  echo "Linking .ideavimrc"
  ln -sf "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  echo "Linking .zshrc"
  ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
fi

if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
  echo "Restoring original .zshrc from oh-my-zsh backup"
  rm -f "$HOME/.zshrc"
  mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
fi

if [ -n "$ZSH_VERSION" ]; then
  echo "Reloading zsh configuration..."
  source "$HOME/.zshrc"
fi
