{ config, pkgs, lib, ... }:

let
  brightnessctl-rs = pkgs.callPackage ../tools/brightnessctl-rs.nix { };
in
{
  # System packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    htop
    neofetch
    ghostty

    # Wayland tools
    waybar
    wofi
    dunst

    tmux
    # Utilities
    git
    vim
    fzf
    neovim
    btop

    libinput

    hyprpaper
    jq
    htop
    bat
    sqlite
    watch
    ripgrep
    just
    terraform
    k9s

    uwsm

    # apps
    microsoft-edge
    jetbrains.rider
    obsidian
    lazygit
    gh
    pyright
    ruff
    omnisharp-roslyn
    unzip
    nodejs_24
    llvmPackages_21.libcxxClang
    helix
    python314
    uv
    brightnessctl
    brightnessctl-rs
    playerctl
    gtk3

    # rust-env
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy

    element-desktop
    protonvpn-gui
    roslyn-ls


    ansible
    sshpass

    lsb-release
    usbutils

    lshw
    lmstudio

    cifs-utils
    jetbrains.rider
    spotify
    fantomas
    fsautocomplete

    opencode
    jujutsu

    (makeDesktopItem {
      name = "youtube-music";
      desktopName = "YouTube Music";
      comment = "YouTube Music Web App";
      exec = "${pkgs.microsoft-edge}/bin/microsoft-edge --app=https://music.youtube.com";
      icon = "youtube-music";
      categories = [ "AudioVideo" "Audio" "Player" ];
      startupWMClass = "music.youtube.com";
    })
  ];
}
