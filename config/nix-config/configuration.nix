{ lib, config, options, ...}:

with lib;

{
  options.username = mkOption {
      type = types.str;
      description = "The username of the user";
  };
  
  options.gitEmail = mkOption {
      type = types.str;
      description = "The git email to use for the .gitconfig";
  };

  options.gitName = mkOption {
      type = types.str;
      description = "The name to use for the .gitconfig";
  };
}
