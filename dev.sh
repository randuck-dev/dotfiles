#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
dry_run="0"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

log() {
  if [[ $dry_run == "1" ]]; then
    echo "[DRY_RUN]: $1"
  else
    echo "$1"
  fi
}

if ! [ -x "$(command -v brew)" ]; then
  echo "brew not found. Installing it..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH after installation
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "brew found"
fi
echo "Linking configuration files"
mkdir -p "$CONFIG_DIR"

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

if [ ! -f "$HOME/.zshrc" ]; then
  echo "Linking .zshrc"
  ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
fi

echo $script_dir
runs_dir=$(find $script_dir/pkgs -mindepth 1 -maxdepth 1)

for s in $runs_dir; do
  if basename $s | grep -vq "$grep"; then
    log "grep \"$grep\" filtered out $s"
    continue
  fi

  log "running script: $s"

  if [[ $dry_run == "0" ]]; then
    $s
  fi
done

if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
  echo "Restoring original .zshrc from oh-my-zsh backup"
  rm -f "$HOME/.zshrc"
  mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
fi

if [ -n "$ZSH_VERSION" ]; then
  echo "Reloading zsh configuration..."
  source "$HOME/.zshrc"
fi
