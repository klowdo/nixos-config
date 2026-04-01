{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.workmux;
  yaml = pkgs.formats.yaml {};
in {
  options.features.cli.workmux.enable = mkEnableOption "workmux parallel development with git worktrees";

  config = mkIf cfg.enable {
    home.packages = [inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default];

    xdg.configFile."workmux/config.yaml".source = yaml.generate "config.yaml" {
      worktree_dir = ".worktrees";
      agent = "claude";
      mode = "session";
      merge_strategy = "rebase";
      status_icons = {
        working = "🤖";
        waiting = "💬";
        done = "✅";
      };
      panes = [
        {
          command = "nvim";
          focus = true;
        }
        {
          command = "<agent>";
          split = "horizontal";
          percentage = 40;
        }
      ];
    };
  };
}
