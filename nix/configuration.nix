{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  virtualisation.docker.enable = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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

  # Open SSH port
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
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
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.randuck-dev = {
    isNormalUser = true;
    description = "Raphael Neumann";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
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

    # apps
    microsoft-edge
    jetbrains.rider
    obsidian
    lazygit
    gh
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

  # This value determines the NixOS release compatibility
  system.stateVersion = "25.05";
}
