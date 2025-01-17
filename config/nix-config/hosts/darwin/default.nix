{ config, pkgs, lib, ... }:

let 
  user = "randuck-dev"; 
  name = "Raphael Neumann";
  email = "mail@raphaelneumann.dk";
in

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/darwin
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.checks.verifyNixPath = false;

  environment.systemPackages = with pkgs; [
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
    (with dotnetCorePackages; combinePackages [
        sdk_8_0
        sdk_9_0
      ])
  ];

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
