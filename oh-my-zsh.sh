#!/usr/bin/env bash
# Installs oh-my-zsh and the plugins zshrc uses. Safe to run again.
set -e

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

if [ ! -d "$ZSH" ]; then
  echo "Installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

clone_plugin() {
  local path="$ZSH_CUSTOM/plugins/$1"
  if [ ! -d "$path" ]; then
    echo "Installing zsh plugin $1"
    git clone "$2" "$path"
  fi
}

clone_plugin autoswitch_virtualenv https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git
clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
