{ config, pkgs, lib, ... }:

let 
    name = "Raphael Neumann";
    email = config.gitEmail;
    user = config.username;
    # additionalFiles = import ./files.nix { inherit user config pkgs; };
    zshConfig = import ../zsh { inherit config pkgs lib; };
    sshConfig = import ../ssh { inherit config pkgs lib; };
    tmuxConfig = import ../tmux { inherit config pkgs lib; };
in
{
  imports = [
   ./dock
   tmuxConfig
   sshConfig
   zshConfig
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        stateVersion = "23.11";
      };
      programs = {
        git = {
          enable = true;
          ignores = [ "*.swp" ];
          userName = name;
          userEmail = email;
          lfs = {
            enable = true;
          };
          extraConfig = {
            init.defaultBranch = "main";
            core = {
            editor = "vim";
              autocrlf = "input";
            };
            pull.rebase = true;
            rebase.autoStash = true;
          };
        };
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
