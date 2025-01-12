{ pkgs }:

with pkgs; [
  # General packages for development and system management
  alacritty
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
  
  obsidian
  neovim

  sesh
  zoxide

  (with dotnetCorePackages; combinePackages [
      sdk_8_0
      sdk_9_0
    ])
]
