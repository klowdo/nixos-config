{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.git-repo-manager = {config, ...}: {
    imports = [flake.modules.homeManager.sops];

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
