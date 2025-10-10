#!/usr/bin/env bash
sudo disko --mode disko ./disko.nix
sudo nixos-generate-config --root /mnt
