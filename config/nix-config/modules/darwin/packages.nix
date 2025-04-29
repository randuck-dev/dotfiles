{ pkgs }:

with pkgs;
[
  bash-completion
  bat
  btop
  openssh
  sqlite
  wget
  zip

  docker
  docker-compose

  ffmpeg
  fd
  font-awesome

  htop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  fzf
  unrar
  unzip
  zsh-autosuggestions

  oh-my-zsh

  # Python packages
  
  neovim

  sesh
  zoxide

  dockutil
  lazygit
  zsh-autosuggestions
  gh
  presenterm
  devenv
  direnv
  helix
  git
  nodejs
  just
  k6
  tokei
  go
  elixir
  git-filter-repo
  zig
  azure-functions-core-tools
]
