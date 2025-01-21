{ lib, config, options, pkgs, ...}:
with lib;

let cfg = config.azure;
in
{
  options.azure = {
    enable = mkEnableOption "azure";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      azure-cli
      terraform
    ];
  };
}

