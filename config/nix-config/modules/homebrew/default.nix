{ lib, config, options, ...}:
with lib;

{
  options.extraCasks = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Extra casks to install";
  };

  config = {
    homebrew = {
      enable = true;
      casks = [
      ] ++ config.extraCasks;
    };
  };
}
