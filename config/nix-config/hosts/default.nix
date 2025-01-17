{ config, pkgs, lib, inputs, home-manager, ... }:

let systems = {
    m1-darwin = "aarch64-darwin";
  };
in 
{
  machines = {
      zeus = import ./darwin/zeus.nix { inherit config pkgs lib systems inputs home-manager; };
      mft = import ./darwin/mft.nix { inherit config pkgs lib systems inputs home-manager; };
    };
}
