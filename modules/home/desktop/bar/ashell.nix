{
  inputs,
  config,
  ...
}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.ashell = {
    lib,
    config,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.desktop.bar.ashell;
      defaultLauncher = config.features.defaults.launcher.command;
    in {
      imports = with flake.modules.homeManager; [bar defaults];

      options.features.desktop.bar.ashell = {
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

      config = {
        programs.hyprlock.enable = true;

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
                center = ["WindowTitle" "MediaPlayer"];
                right = ["SystemInfo" ["Tray" "Clock" "darkman" "Privacy" "Settings"]];
              };

              workspaces = {
                enable_workspace_filling = true;
                show_special = false;
                show_empty = true;
              };

              CustomModule = [
                {
                  name = "appLauncher";
                  icon = "󱗼";
                  command = defaultLauncher;
                }
                {
                  name = "darkman";
                  icon = "󰖔";
                  tooltip = "Current theme: {alt}";
                  listen_cmd = "${pkgs.darkman}/bin/darkman get | ${pkgs.jq}/bin/jq -Rc '{alt: .}'";
                  interval = 1000;
                  command = "${pkgs.darkman}/bin/darkman toggle";
                  icons."dark.*" = "󰖙";
                  icons."light.*" = "󰖔";
                }
              ];

              window_title = {
                truncate_title_after_length = 100;
              };

              settings = {
                lock_cmd = "${config.programs.hyprlock.package}/bin/hyprlock &";
                audio_sinks_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
                audio_sources_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 4";
                wifi_more_cmd = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
                vpn_more_cmd = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
                bluetooth_more_cmd = "${pkgs.blueberry}/bin/blueberry";
              };
            }
            cfg.settings
          ];
        };
      };
    };
}
