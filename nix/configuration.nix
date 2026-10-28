{ config, pkgs, pkgs-unstable, lib, ... }:

let
  brightnessctl-rs = pkgs.callPackage ./tools/brightnessctl-rs.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = with pkgs; [ 
    linux-firmware 
  ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    };
  };

  programs.steam = {
      enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  virtualisation.docker.enable = true;

  # Enable NVIDIA Container Toolkit so Docker can expose GPUs to containers
  hardware.nvidia-container-toolkit.enable = true;

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

    ACTION=="add", SUBSYSTEM=="net", DRIVERS=="ax88179_178a", RUN+="${pkgs.coreutils}/bin/sleep 3"
  '';

  # Timezone and locale
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;  # see the note above

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  networking.firewall.allowedTCPPorts = [
    22
    1400
    8123
  ];

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

  programs.nix-ld = {
    enable = true;
  };

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

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

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
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "video" "dialout" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # NixOS-only packages; shared ones are in common.nix
  environment.systemPackages = with pkgs; [
    curl
    fastfetch
    ghostty

    # Wayland tools
    waybar
    wofi
    dunst

    # Utilities
    vim
    difftastic

    libinput

    hyprpaper

    uwsm

    # apps
    microsoft-edge
    jetbrains.rider
    obsidian
    pyright
    omnisharp-roslyn
    dotnetCorePackages.dotnet_10.sdk
    llvmPackages_21.libcxxClang
    brightnessctl
    brightnessctl-rs
    playerctl
    gtk3
    vscodium
    opencode

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
    pkgs-unstable.claude-code
    lmstudio
    spotify

    pavucontrol


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

  # Enable automatic login (optional, for VM convenience)
  # services.getty.autologinUser = "yourusername";
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release compatibility
  system.stateVersion = "25.05";

  fileSystems."/mnt/secondary" = {
    device = "/dev/disk/by-label/secondary";
    fsType = "ext4";
    options = [ "defaults" "user" "exec" ];  # Allow user access and execution
  };

  fileSystems."/mnt/ternary" = {
    device = "/dev/disk/by-label/ternary";
    fsType = "ext4";
    options = [ "defaults" "user" "exec" ];  # Allow user access and execution
  };

  systemd.tmpfiles.rules = [
    "d /mnt/secondary 0755 randuck-dev users -"
    "d /mnt/secondary/SteamLibrary 0755 randuck-dev users -"
    "d /mnt/ternary 0755 randuck-dev users -"
    "d /mnt/ternary/SteamLibrary 0755 randuck-dev users -"
  ];


  nix.settings.trusted-users = [ "root" "randuck-dev" ];
}
