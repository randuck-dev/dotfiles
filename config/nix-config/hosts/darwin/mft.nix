{ config, pkgs, lib, home-manager, systems, ... }:

let 
  coreConfig = import ./core.nix {
    inherit config pkgs lib home-manager systems;
    user = "rne";
    name = "Raphael Neumann";
    email = "rne@mft-energy.com";
  };
in
{
  imports = [ coreConfig ];
}
