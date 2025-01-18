{ lib, config, options, ...}:

with lib;

{
  options.username = mkOption {
      type = types.str;
      description = "The username of the user";
  };
}
