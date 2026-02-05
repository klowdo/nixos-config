{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  options.features.desktop.bar.hyprpanel = {
    enable = lib.mkEnableOption "Enable hyprpanel module";
  };

  config = lib.mkIf config.features.desktop.bar.hyprpanel.enable {
    home.packages = [
      pkgs.upower
      pkgs.libgtop
      # pkgs.python313Packages.gpustat
      # pkgs.python313Packages.nvidia-ml-py
    ];

    specialisation = {
      nvidia.configuration = {
        programs.hyprpanel = {
          settings = {
            menus = {
              dashboard = {
                stats.enable_gpu = true;
              };
            };
          };
        };
        home.packages = [
          pkgs.python313Packages.gpustat
          pkgs.python313Packages.nvidia-ml-py
        ];
      };
    };
    programs.hyprpanel = {
      package = inputs.hyprpanel.packages.${pkgs.stdenv.hostPlatform.system}.default;
      enable = true;
      # hyprland.enable = true;
      # theme = "catppuccin_mocha";
      systemd.enable = true;
      # dontAssertNotificationDaemons = true;

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
          # launcher.icon = " ";
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
            # stats.enable_gpu = truews-vpn-toggle;
            shortcuts = {
              left = {
                shortcut1 = {
                  icon = "󰖂";
                  command = "pkexec ws-vpn-toggle";
                  tooltip = "Toggle VPN";
                };
              };
              right = {
                shortcut1 = {
                  icon = "";
                  command = "systemctl --user restart hyprpanel.service";
                  tooltip = "Restart Panel";
                };
              };
            };
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

        notifications = {
          position = "top right";
          animation_style = "slide_from_right";
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
        execute = "darkman get | jq -Rc '{alt: .}'";
        interval = 1000;
        actions = {
          onLeftClick = "darkman toggle";
        };
      };
    };
  };
}
