{
  description = "Configuration for randuck-dev machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nixpkgs, disko } @inputs:
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

      mkDarwin = { system, user, name, email, extraCasks? [], config? {} }:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            ./configuration.nix
            config
            {
              username = user;
            }
            ./modules/darwin
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
        };
      };
    };
}
