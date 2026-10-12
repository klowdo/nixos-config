{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.hypridle = {
    config,
    lib,
    ...
  }: let
    minutes = m: m * 60;
    inherit (config.features.desktop.hyprland) manageIdle;
  in {
    imports = [flake.modules.homeManager.hyprland];

    services.hypridle = {
      enable = manageIdle;
      settings = lib.mkIf manageIdle {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock & sleep 2 && hyprctl dispatch dpms off";
        };

        listener = [
          {
            timeout = minutes 5;
            on-timeout = "hyprlock";
          }
          {
            timeout = minutes 10;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
