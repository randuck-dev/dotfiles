{
  description = "Machine configs: NixOS desktop and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, nixpkgs-unstable, nix-darwin, ... }@inputs:
    let
      unstableFor = system: import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; pkgs-unstable = unstableFor "x86_64-linux"; };
        modules = [
          ./nix/common.nix
          ./nix/configuration.nix
        ];
      };

      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; pkgs-unstable = unstableFor "aarch64-darwin"; };
        modules = [
          ./nix/common.nix
          ./nix/darwin.nix
        ];
      };

      # Used by dev.sh for the first switch, before darwin-rebuild is installed.
      packages.aarch64-darwin.darwin-rebuild = nix-darwin.packages.aarch64-darwin.darwin-rebuild;
    };
}
