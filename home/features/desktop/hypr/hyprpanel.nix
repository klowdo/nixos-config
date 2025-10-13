{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    hyprpanel.enable = lib.mkEnableOption "Enable hyprpanel module";
  };
  config = lib.mkIf config.hyprpanel.enable {
    home.packages = [
      pkgs.upower
      pkgs.libgtop
      # pkgs.python313Packages.gpustat
      # pkgs.python313Packages.nvidia-ml-py
    ];
    programs.hyprpanel = {
      package = inputs.hyprpanel.packages.${pkgs.system}.default;
      enable = true;
      # hyprland.enable = true;
      # theme = "catppuccin_mocha";
      systemd.enable = true;
      dontAssertNotificationDaemons = true;

      settings = {
        bar.layouts = {
          "*" = {
            left = [
              "dashboard"
              "clock"
              "workspaces"
              "windowtitle"
            ];
            middle = ["media" "cava"];
            right = [
              "systray"
              "volume"
              "bluetooth"
              "battery"
              "network"
              "hypridle"
              "custom/darkman"
              "notifications"
              "kbinput"
            ];
          };
        };
        bar = {
          launcher.autoDetectIcon = true;
          # launcher.icon = " ";
          workspaces.show_icons = true;
          clock.format = "%a %b %d  %H:%M";
        };
        menus = {
          clock = {
            time = {
              military = true;
              hideSeconds = true;
            };

            weather = {
              unit = "metric";
              location = "Gothenburg";
              key = "${config.sops.secrets."weather-api-key".path}";
            };
          };
          dashboard = {
            powermenu.avatar.image = "~/.face.icon";
            directories.enabled = false;
            # stats.enable_gpu = true;
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

    xdg.configFile."hyprpanel/modules.json".text = builtins.toJSON {
      "custom/darkman" = {
        icon = {
          dark = "󰖙";
          light = "󰖔";
        };
        tooltip = "Current theme: {alt}%";
        execute = "darkman get | jq -R '{alt: .}'";
        interval = 1000;
        actions = {
          onLeftClick = "darkman toggle";
        };
      };
    };
  };
}
