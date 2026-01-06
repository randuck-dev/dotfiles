{
  description = "Config for machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin.url = "github:LNL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin,... }@inputs: {
    nixosConfigurations."zeus" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nix/machines/zeus.nix
          ./nix/pkgs/dotnet.nix
          ./nix/pkgs/base.nix
          {
              config.dotnet.enable = true;
          }
        ];

    };

    darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
          ./nix/pkgs/dotnet.nix
          {
              config.dotnet.enable = true;
              system.stateVersion = 6;
          }
      ];
    };
  };
}
