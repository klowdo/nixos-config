# Host-specific configuration options
# Centralizes paths and settings that vary per host/user
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hostConfig;
in {
  options.hostConfig = {
    mainUser = mkOption {
      type = types.str;
      default = "klowdo";
      description = "Primary user account name";
    };

    home = mkOption {
      type = types.str;
      description = "The home directory of the main user";
      default =
        if pkgs.stdenv.isLinux
        then "/home/${cfg.mainUser}"
        else "/Users/${cfg.mainUser}";
    };

    dotfilesPath = mkOption {
      type = types.str;
      description = "Path to the dotfiles/nix-config directory";
      default = "${cfg.home}/.dotfiles";
    };
  };

  config = {
    # Use the dotfiles path for nh if it's set
    programs.nh.flake = mkIf (cfg.dotfilesPath != "") cfg.dotfilesPath;
  };
}
