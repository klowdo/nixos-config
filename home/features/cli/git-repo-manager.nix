{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.features.cli.git-repo-manager;
in {
  options.features.cli.git-repo-manager = {
    enable = mkEnableOption "vcstool/mr for declarative repo management";
  };

  config = mkIf cfg.enable {
    programs.vcstool = {
      enable = true;

      workspaces = [
        {
          root = "~";
          repos = {
            ".dotfiles" = {
              url = "git@github.com:klowdo/nixos-config.git";
              version = "main";
            };
          };
        }
        {
          root = "~/dev/github";
          repos = {
            "tailswan" = {
              url = "git@github.com:klowdo/tailswan.git";
            };
          };
        }
      ];

      service = {
        enable = true;
        onCalendar = "daily";
      };
    };

    programs.mr = {
      enable = true;

      settings = {
        ".dotfiles" = {
          checkout = "git clone 'git@github.com:klowdo/nixos-config.git' '.dotfiles'";
        };
        "dev/github/tailswan" = {
          checkout = "git clone 'git@github.com:klowdo/tailswan.git'";
        };
      };
    };
  };
}
