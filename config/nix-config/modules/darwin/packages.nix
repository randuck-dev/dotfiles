{ pkgs }:

with pkgs;
[
  aspell
  aspellDicts.en
  bash-completion
  bat
  btop
  openssh
  sqlite
  wget
  zip

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf

  htop
  hunspell
  iftop
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
