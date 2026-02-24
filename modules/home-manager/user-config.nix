# User-specific configuration options
# Centralizes paths and settings that vary per user/setup
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.userConfig;
in {
  options.userConfig = {
    username = mkOption {
      type = types.str;
      default = "user";
      description = "The username for this home-manager configuration";
    };

    homeDirectory = mkOption {
      type = types.str;
      default = "";
      description = "The home directory of the user (auto-detected if empty)";
    };

    dotfilesPath = mkOption {
      type = types.str;
      default = "";
      description = "Path to the dotfiles/nix-config directory (defaults to ~/.dotfiles)";
    };

    projectsPath = mkOption {
      type = types.str;
      default = "";
      description = "Path to the projects/development directory (defaults to ~/dev)";
    };

    fullName = mkOption {
      type = types.str;
      default = "User";
      description = "User's full name for git, email, etc.";
    };

    email = mkOption {
      type = types.str;
      default = "";
      description = "User's primary email address";
    };
  };

  config = let
    # Compute effective values with smart defaults
    effectiveHome =
      if cfg.homeDirectory != ""
      then cfg.homeDirectory
      else if pkgs.stdenv.isLinux
      then "/home/${cfg.username}"
      else "/Users/${cfg.username}";

    effectiveDotfiles =
      if cfg.dotfilesPath != ""
      then cfg.dotfilesPath
      else "${effectiveHome}/.dotfiles";

    effectiveProjects =
      if cfg.projectsPath != ""
      then cfg.projectsPath
      else "${effectiveHome}/dev";
  in {
    # Set home-manager's username and homeDirectory from userConfig
    home.username = mkDefault cfg.username;
    home.homeDirectory = mkDefault effectiveHome;

    # Export as environment variables for shell access
    home.sessionVariables = {
      NH_FLAKE = effectiveDotfiles;
      PROJECT_FOLDERS = effectiveProjects;
    };
  };
}
