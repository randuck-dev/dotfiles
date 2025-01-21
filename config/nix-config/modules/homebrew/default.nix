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
        "ghostty"
        "rider"
        "visual-studio-code"
        "nikitabobko/tap/aerospace"
        "microsoft-edge"
      ] ++ config.extraCasks;
    };
  };
}
