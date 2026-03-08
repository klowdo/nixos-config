{
  config,
  lib,
  ...
}: let
  minutes = m: m * 60;
  caelestiaEnabled = config.features.desktop.bar.caelestia.enable or false;
in {
  services.hypridle = {
    enable = !caelestiaEnabled; # Disabled when Caelestia handles idle
    settings = lib.mkIf (!caelestiaEnabled) {
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
}
