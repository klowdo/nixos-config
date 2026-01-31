{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.gaming.steam-link;
in {
  options.features.gaming.steam-link.enable = mkEnableOption "Steam Link client for game streaming";

  config = mkIf cfg.enable {
    services.flatpak.packages = [
      {
        appId = "com.valvesoftware.SteamLink";
        origin = "flathub";
      }
    ];

    wayland.windowManager.hyprland.settings = {
      windowrulev2 = [
        "fullscreen, class:^(steamlink)$"
        "immediate, class:^(steamlink)$"
        "idleinhibit fullscreen, class:^(steamlink)$"
      ];

      bind = [
        "SUPER, F12, submap, gamemode"
      ];
    };

    wayland.windowManager.hyprland.extraConfig = ''
      submap = gamemode
      bind = SUPER, F12, submap, reset
      bind = SUPER SHIFT, F12, submap, reset
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
