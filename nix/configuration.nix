{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-hyprland";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  # Open SSH port
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Required for Hyprland
  security.polkit.enable = true;
  
  # XDG portal for screen sharing etc
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account
  users.users.ran= {
    isNormalUser = true;
    description = "Raphael Neumann";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Terminal
      kitty
      
      # Wayland tools
      waybar
      wofi
      dunst
      
      # Utilities
      firefox
      git
      vim
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    htop
    neofetch
  ];

  # Enable automatic login (optional, for VM convenience)
  # services.getty.autologinUser = "yourusername";

  # This value determines the NixOS release compatibility
  system.stateVersion = "25.05";
}
