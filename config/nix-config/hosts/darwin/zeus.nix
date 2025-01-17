{ config, pkgs, lib, home-manager, ... }:

let 
  coreConfig = import ./core.nix {
    inherit config pkgs lib home-manager;
    user = "randuck-dev";
    name = "Raphael Neumann";
    email = "mail@raphaelneumann.dk";
  };
in
{
  imports = [ coreConfig ];
}
