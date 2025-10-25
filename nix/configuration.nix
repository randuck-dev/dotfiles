{ config, pkgs, ... }:

let
  brightnessctl-rs = pkgs.callPackage ./tools/brightnessctl-rs.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  virtualisation.docker.enable = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # In order for brightness control to work, this has to be setup like this.
  # The alternative would be to use setuid on the brightnessctl-rs would be used,
  # but that would provide to much access to the system
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chgrp input /sys/class/leds/%k/brightness"
    ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
  '';

  # Timezone and locale
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Danish keyboard layout
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };
  console.keyMap = "dk-latin1";

  # Enable OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  # Open SSH port
  networking.firewall.allowedTCPPorts = [ 22 ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      hyprland = {
        binPath = "/run/current-system/sw/bin/Hyprland";
        comment = "Hyprland session managed by uwsm";
        prettyName = "Hyprland";
      };
    };
  };

  programs.hyprlock.enable = true;
  programs.zsh.enable = true;

  # Required for Hyprland
  security.polkit.enable = true;

  # XDG portal for screen sharing etc
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.nix-ld.enable = true;

  programs.dconf.profiles.user = {
    databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
      };
    }];
  };

  # Sound
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.randuck-dev = {
    isNormalUser = true;
    description = "Raphael Neumann";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "video" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

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
    dotnetCorePackages.dotnet_9.sdk
    nodejs_24
    llvmPackages_21.libcxxClang
    python314
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

  fonts = {
    packages = with pkgs; [
      nerd-fonts.caskaydia-mono
      font-awesome
    ];
    fontconfig = {
      localConf = ''
        <!-- use a less horrible font substition for pdfs such as https://www.bkent.net/Doc/mdarchiv.pdf -->
        <match target="pattern">
          <test name="family" qual="any">
            <string>monospace</string>
          </test>
          <edit name="family" mode="assign" binding="strong">
            <string>CaskaydiaMono Nerd Font</string>
          </edit>
        </match>
      '';
    };
  };

  # Enable automatic login (optional, for VM convenience)
  # services.getty.autologinUser = "yourusername";
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release compatibility
  system.stateVersion = "25.05";
}
