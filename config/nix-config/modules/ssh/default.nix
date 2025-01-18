{ config, pkgs, lib, ...}:
let user = config.username;
in
{
  home-manager.users.${user}.programs.ssh = {
    enable = true;
    includes = [ "/Users/${user}/.ssh/config_external" ];
    matchBlocks = {
      "github.com" = {
        identitiesOnly = true;
        identityFile = [ "/Users/${user}/.ssh/id_github" ];
      };
    };
  };
}

