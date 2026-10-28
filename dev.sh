#!/usr/bin/env bash
# Sets up a machine from this repo. Safe to run again.
set -e

DOTFILES_DIR="$HOME/.dotfiles"
cd "$(dirname "$0")"

source ./config.sh
source ./git-identity.sh
./oh-my-zsh.sh

if [ ! -f "$HOME/.ideavimrc" ]; then
  echo "Linking .ideavimrc"
  ln -sf "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  echo "Linking .zshrc"
  ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
fi

if [ "$(uname)" = "Darwin" ]; then
  if ! command -v brew >/dev/null; then
    echo "Homebrew is needed for desktop apps. Install it from https://brew.sh, then run this again."
    exit 1
  fi
  if ! command -v nix >/dev/null; then
    echo "Nix is needed. Install it (e.g. https://lix.systems/install), then run this again."
    exit 1
  fi

  echo "Applying the macOS config (asks for your password)"
  if command -v darwin-rebuild >/dev/null; then
    sudo darwin-rebuild switch --flake "$DOTFILES_DIR#mac"
  else
    # First run: darwin-rebuild isn't installed yet, so run it from the flake.
    sudo nix --extra-experimental-features "nix-command flakes" \
      run "$DOTFILES_DIR#darwin-rebuild" -- switch --flake "$DOTFILES_DIR#mac"
  fi
else
  echo "On NixOS, apply the system config with: athena-update"
fi
