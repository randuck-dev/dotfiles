# in configuration.nix
{ pkgs, lib, inputs }:
# inputs.self, inputs.nix-darwin, and inputs.nixpkgs can be accessed here

let x = 1;
in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  };
