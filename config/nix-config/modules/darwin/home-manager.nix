{ config, pkgs, lib, ... }:

let 
    user = config.username;
in
{
  imports = [
   ./dock
   ../homebrew
   ../ssh
   ../zsh
   ../tmux
   ../git
   ../azure
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        stateVersion = "24.11";
      };
      manual.manpages.enable = false;
    };
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "/Applications/Ghostty.app/"; }
    { path = "/Applications/Rider.app/"; }
    { path = "/Applications/Microsoft Edge.app/"; }
    { path = "/Applications/Visual Studio Code.app/"; }
    { path = "/Applications/Notion.app/"; }
  ];
}
