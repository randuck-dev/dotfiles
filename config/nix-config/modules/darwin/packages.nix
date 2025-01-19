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
  zsh-powerlevel10k
  zsh-autosuggestions

  oh-my-zsh

  # Python packages
  python3
  virtualenv
  
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
]
