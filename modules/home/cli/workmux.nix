{inputs, ...}: {
  flake.modules.homeManager.workmux = {pkgs, ...}: let
    yaml = pkgs.formats.yaml {};
  in {
    home.packages = [
      (inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
        doCheck = false;
      })
    ];

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
