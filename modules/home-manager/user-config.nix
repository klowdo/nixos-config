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
      description = "The home directory of the user";
      default =
        if pkgs.stdenv.isLinux
        then "/home/${cfg.username}"
        else "/Users/${cfg.username}";
    };

    dotfilesPath = mkOption {
      type = types.str;
      default = "${cfg.homeDirectory}/.dotfiles";
      description = "Path to the dotfiles/nix-config directory";
    };

    projectsPath = mkOption {
      type = types.str;
      default = "${cfg.homeDirectory}/dev";
      description = "Path to the projects/development directory";
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

  config = {
    # Set home-manager's username and homeDirectory from userConfig
    home.username = mkDefault cfg.username;
    home.homeDirectory = mkDefault cfg.homeDirectory;

    # Export as environment variables for shell access
    home.sessionVariables = {
      NH_FLAKE = cfg.dotfilesPath;
      PROJECT_FOLDERS = cfg.projectsPath;
    };
  };
}
