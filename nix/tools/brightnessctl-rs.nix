{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage
  (pkgs.fetchFromGitHub {
    owner = "randuck-dev";
    repo = "brightnessctl-rs";
    rev = "main";
    sha256 = "VdNe9BO03tdXD5RKB68P8VILnpNgJyejEHtHYeZnGe0=";
  })
{ }
