{ config, pkgs, lib, ... }:

{
  imports = [
    ./zeus-hardware-configuration.nix
  ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = with pkgs; [ 
    linux-firmware 
  ];

/*
  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    };
  };
  */

  programs.steam = {
      enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      insecure-registries = [ "rpi4:5000" ]; # Replace with your Pi's IP
    };
  };

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  services.blueman.enable = true;


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
      AllowUsers = [ "randuck-dev" ];
    };
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.deviceSection = ''
  Option "Coolbits" "4"
  '';

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

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
  
  services.k3s = {
    enable = true;
    role = "server";
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

  fileSystems."/mnt/vault" = {
    device = "//192.168.0.44/vault/media";
    fsType = "cifs";
    options = [
      "credentials=/root/.smbcredentials"
      "uid=1000"
      "gid=1000"
      "iocharset=utf8"
      "nofail"
      "x-systemd.automount"
    ];
  };

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

  # Set ownership after mount
  systemd.tmpfiles.rules = [
    "d /mnt/secondary 0755 randuck-dev users -"
    "d /mnt/secondary/SteamLibrary 0755 randuck-dev users -"

    "d /mnt/ternary 0755 randuck-dev users -"
    "d /mnt/ternary/SteamLibrary 0755 randuck-dev users -"
  ];

  # Enable automatic login (optional, for VM convenience)
  # services.getty.autologinUser = "yourusername";
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release compatibility
  system.stateVersion = "25.05";

  environment.variables.LD_LIBRARY_PATH = lib.makeLibraryPath [
    config.hardware.nvidia.package
  ];
}

