{
  inputs,
  config,
  ...
}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.hyprpanel = {
    config,
    pkgs,
    ...
  }: {
    imports = [flake.modules.homeManager.bar];

    programs.hyprlock.enable = true;

    home.packages = [
      pkgs.upower
      pkgs.libgtop
      pkgs.swaynotificationcenter
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
      systemd.enable = true;

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
