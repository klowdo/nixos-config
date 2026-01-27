# User-specific configuration options
# Centralizes paths and settings that vary per user/setup
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.userConfig;
in {
  options.userConfig = {
    dotfilesPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.dotfiles";
      description = "Path to the dotfiles/nix-config directory";
    };

    projectsPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/dev";
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
    # Export as environment variables for shell access
    home.sessionVariables = {
      NH_FLAKE = cfg.dotfilesPath;
      PROJECT_FOLDERS = cfg.projectsPath;
    };
  };
}
