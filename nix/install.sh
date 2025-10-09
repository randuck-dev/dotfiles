#!/usr/bin/sh
sudo disko --mode disko ./disko.nix
sudo nixos-generate-config --root /mnt
