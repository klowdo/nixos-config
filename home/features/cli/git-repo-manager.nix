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
          root = config.home.homeDirectory;
          repos = {
            ".dotfiles" = {
              url = "git@github.com:klowdo/nixos-config.git";
              version = "main";
            };
          };
        }
        {
          root = "${config.home.homeDirectory}/dev/github";
          repos = {
            "tailswan" = {
              url = "git@github.com:klowdo/tailswan.git";
            };
            "kixvim" = {
              url = "git@github.com:klowdo/kixvim.git";
            };
          };
        }
      ];

      extraImports = [
        {
          root = "${config.home.homeDirectory}/dev/work/worldstream";
          file = config.sops.secrets."vcstool-work".path;
        }
      ];

      service = {
        enable = true;
        onCalendar = "daily";
      };
    };

    sops.secrets."vcstool-work" = {};

    programs.mr = {
      enable = true;

      settings = {
        "${config.home.homeDirectory}/.dotfiles" = {
          checkout = "git clone 'git@github.com:klowdo/nixos-config.git' '.dotfiles'";
        };
        "${config.home.homeDirectory}/dev/github/tailswan" = {
          checkout = "git clone 'git@github.com:klowdo/tailswan.git'";
        };
        "${config.home.homeDirectory}/dev/github/kixvim" = {
          checkout = "git clone 'git@github.com:klowdo/kixvim.git'";
        };
      };
    };
  };
}
