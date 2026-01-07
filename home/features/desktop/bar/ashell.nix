{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.bar.ashell;
  defaultLauncher = config.features.defaults.launcher.command or "wofi --show drun";
in {
  options.features.desktop.bar.ashell = {
    enable = mkEnableOption "Ashell status bar for Hyprland";

    package = mkOption {
      type = types.package;
      inherit (inputs.ashell.packages.${pkgs.stdenv.hostPlatform.system}) default;
      description = "The ashell package to use";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Ashell configuration settings (TOML format)";
    };
  };

  config = mkIf cfg.enable {
    programs.ashell = {
      enable = true;
      inherit (cfg) package;
      systemd.enable = true;

      settings = mkMerge [
        {
          log_level = "warn";
          outputs.Targets = ["eDP-1"];
          position = "Top";
          app_launcher_cmd = defaultLauncher;

          modules = {
            left = [["appLauncher" "Updates" "Workspaces"]];
            center = ["WindowTitle"];
            right = ["SystemInfo" ["Tray" "Clock" "Privacy" "Settings"]];
          };

          # updates = {
          #   check_cmd = "checkupdates; paru -Qua";
          #   update_cmd = ''kitty -e bash -c "paru; echo Done - Press enter to exit; read" &'';
          # };

          workspaces = {
            enable_workspace_filling = true;
            show_special = false;
            show_empty = true;
          };

          CustomModule = [{
            name = "appLauncher";
            icon = "󱗼";
            command = defaultLauncher;
          }];

          window_title = {
            truncate_title_after_length = 100;
          };

          settings = {
            lock_cmd = "hyprlock &";
            audio_sinks_more_cmd = "pavucontrol -t 3";
            audio_sources_more_cmd = "pavucontrol -t 4";
            wifi_more_cmd = "nm-connection-editor";
            vpn_more_cmd = "nm-connection-editor";
            bluetooth_more_cmd = "blueberry";
          };

          # appearance = {
          #   style = "Islands";
          #   primary_color = "#7aa2f7";
          #   success_color = "#9ece6a";
          #   text_color = "#a9b1d6";
          #   workspace_colors = ["#7aa2f7" "#9ece6a"];
          #   special_workspace_colors = ["#7aa2f7" "#9ece6a"];
          #
          #   danger_color = {
          #     base = "#f7768e";
          #     weak = "#e0af68";
          #   };
          #
          #   background_color = {
          #     base = "#1a1b26";
          #     weak = "#24273a";
          #     strong = "#414868";
          #   };
          #
          #   secondary_color = {
          #     base = "#0c0d14";
          #   };
          # };
        }
        cfg.settings
      ];
    };
  };
}
