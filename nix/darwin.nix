# macOS (nix-darwin). One config for every Mac; machine-specific values stay
# outside the repo (see git-identity.sh).
{ pkgs, ... }:

let
  dotnet = with pkgs.dotnetCorePackages; combinePackages [
    sdk_10_0
    sdk_9_0
    sdk_8_0
  ];
in
{
  # Nix itself is installed and updated by its own installer (Lix), not nix-darwin.
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "randuck-dev";
  system.stateVersion = 6;

  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Carried over from the earlier nix-darwin setup.
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
    };
    dock = {
      autohide = true;
      show-recents = false;
      orientation = "bottom";
      tilesize = 24;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  environment.systemPackages = with pkgs; [
    dotnet
    bun
    tree
    zip
    openssh
    bash-completion
    pre-commit
    git-filter-repo
    fd
    zoxide

    go
    golangci-lint
    cobra-cli
    air

    poetry

    docker-client
    docker-compose
    fluxcd
    azure-cli
    azure-functions-core-tools
  ];

  environment.variables.DOTNET_ROOT = "${dotnet}/share/dotnet";

  # Desktop apps come from Homebrew casks; many are missing or work poorly in nixpkgs on macOS.
  # Activation only installs what's listed and never removes other Homebrew packages.
  homebrew = {
    enable = true;
    taps = [ "nikitabobko/tap" ];
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
      "microsoft-edge"
      "rider"
      "visual-studio-code"
      "rancher"
      "spotify"
    ];
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
