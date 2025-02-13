{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.hyprpanel.homeManagerModules.hyprpanel];
  options = {
    hyprpanel.enable = lib.mkEnableOption "Enable hyprpanel module";
  };
  config = lib.mkIf config.hyprpanel.enable {
    home.packages = [
      pkgs.upower
      pkgs.libgtop
    ];
    programs.hyprpanel = {
      enable = true;
      hyprland.enable = true;
      theme = "catppuccin_mocha";
      overlay.enable = true;
      overwrite.enable = true;

      layout = {
        "bar.layouts" = {
          "*" = {
            "left" = [
              "dashboard"
              "clock"
              "workspaces"
              "windowtitle"
            ];
            "middle" = ["media" "cava"];
            "right" = [
              "systray"
              "volume"
              "bluetooth"
              "battery"
              "network"
              "hypridle"
              "notifications"
              "kbinput"
            ];
          };
        };
      };

      override = {
      };
      settings = {
        bar = {
          launcher.autoDetectIcon = true;
          # launcher.icon = " ";
          workspaces.show_icons = true;
        };
        menus = {
          clock = {
            time = {
              military = true;
              hideSeconds = true;
            };
            weather.unit = "metric";
            weather.location = "Gothenburg";
          };
          dashboard = {
            directories.enabled = false;
            stats.enable_gpu = true;
          };
        };

        theme = {
          bar = {
            transparent = true;
          };
          font = {
            name = "CaskaydiaCove NF";
            size = "12px";
          };
        };
      };
    };
  };
}
