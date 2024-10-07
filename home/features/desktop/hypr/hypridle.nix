{...}: let
  minutes = m: m * 60;
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "swaylock";
      };

      listener = [
        {
          timeout = minutes 5;
          on-timeout = "swaylock";
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
