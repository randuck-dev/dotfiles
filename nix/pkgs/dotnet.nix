{ config, pkgs, options, lib, ... }:

{
  options.dotnet = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable .NET SDK and Runtime installation.";
    };
  };

  config = lib.mkIf config.dotnet.enable {
    environment.systemPackages = with pkgs; [
      dotnet-sdk_9
      dotnet-runtime_9
    ];

    environment.sessionVariables = lib.mkIf pkgs.stdenv.isLinux {
        DOTNET_ROOT = "${pkgs.dotnet-sdk_9}";
    };

    environment.variables = lib.mkIf pkgs.stdenv.isDarwin {
        DOTNET_ROOT = "${pkgs.dotnet-sdk_9}";
    };
  };
}
