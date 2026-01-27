# Host-specific configuration options
# Centralizes paths and settings that vary per host/user
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hostConfig;
in {
  options.hostConfig = {
    dotfilesPath = mkOption {
      type = types.str;
      description = "Path to the dotfiles/nix-config directory";
    };

    mainUser = mkOption {
      type = types.str;
      default = "klowdo";
      description = "Primary user account name";
    };
  };

  config = {
    # Use the dotfiles path for nh if it's set
    programs.nh.flake = mkIf (cfg.dotfilesPath != "") cfg.dotfilesPath;
  };
}
