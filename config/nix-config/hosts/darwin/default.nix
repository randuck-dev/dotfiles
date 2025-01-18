{ config, pkgs, lib, ... }:

let
  combinedDotnet = with pkgs; with dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
    ];
in
{
  imports = [
    ../../modules/darwin/home-manager.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
  };

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${config.username}" ];
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

  home-manager.users.${config.username}.programs.zsh.initExtra = ''
      export ASPNETCORE_ENVIRONMENT="Development"
      export DOTNET_ROOT="${combinedDotnet}/share/dotnet"
      export DOTNET_HOST_PATH="${combinedDotnet}/dotnet"
  '';

  system.checks.verifyNixPath = false;

  environment.systemPackages = with pkgs; [
    combinedDotnet
  ] ++ (import ../../modules/darwin/packages.nix { inherit pkgs; });

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
