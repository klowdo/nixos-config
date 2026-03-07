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

  # Compute effective values with smart defaults
  effectiveHome =
    if cfg.home != ""
    then cfg.home
    else if pkgs.stdenv.isLinux
    then "/home/${cfg.mainUser}"
    else "/Users/${cfg.mainUser}";

  effectiveDotfiles =
    if cfg.dotfilesPath != ""
    then cfg.dotfilesPath
    else "${effectiveHome}/.dotfiles";
in {
  options.hostConfig = {
    mainUser = mkOption {
      type = types.str;
      default = "klowdo";
      description = "Primary user account name";
    };

    home = mkOption {
      type = types.str;
      default = "";
      description = "The home directory of the main user (auto-detected if empty)";
    };

    dotfilesPath = mkOption {
      type = types.str;
      default = "";
      description = "Path to the dotfiles/nix-config directory (defaults to ~/.dotfiles)";
    };
  };

  config = {
    # Use the dotfiles path for nh
    programs.nh.flake = effectiveDotfiles;
  };
}
