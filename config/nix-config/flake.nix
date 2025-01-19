{
  description = "Configuration for Mac OS Machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nikitabobko-homebrew-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko, nikitabobko-homebrew-tap } @inputs:
    let 
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "rollback" = mkApp "rollback" system;
      };

      mkDarwin = { system, user, name, email, extraCasks? [] }:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            ./configuration.nix
            {
              username = user;
              gitEmail = email;
              gitName = name;
              extraCasks = extraCasks;
            }
            # We are importing the home-manager module
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "nikitabobko/homebrew-tap" = nikitabobko-homebrew-tap;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
            {
              users.users.${user} = {
                name = "${user}";
                home = "/Users/${user}";
                isHidden = false;
                shell = nixpkgs.legacyPackages.${system}.zsh;
              };
            }
          ]; 
        };
    in
    {
      apps = nixpkgs.lib.genAttrs ["aarch64-darwin"] mkDarwinApps;
      darwinConfigurations = {
        zeus = mkDarwin {
          system = "aarch64-darwin";
          user = "randuck-dev";
          name = "Raphael Neumann";
          email = "2768009+randuck-dev@users.noreply.github.com";
          extraCasks = [
            "notion"
            "spotify"
          ];
        };
      };
    };
}
