{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.steam-link = {pkgs, ...}: let
    notify = msg: "${pkgs.libnotify}/bin/notify-send -u low -t 2000 'Game Mode' '${msg}'";
  in {
    imports = [flake.modules.homeManager.nix-flatpak];
    services.flatpak.packages = [
      {
        appId = "com.valvesoftware.SteamLink";
        origin = "flathub";
      }
    ];

    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "match:class ^(steamlink)$, fullscreen on"
        "match:class ^(steamlink)$, immediate on"
        "match:class ^(steamlink)$, idle_inhibit fullscreen"
      ];

      bind = [
        "SUPER, F12, exec, ${notify "Enabled - keys pass through"}"
        "SUPER, F12, submap, gamemode"
      ];
    };

    wayland.windowManager.hyprland.submaps.gamemode = {
      settings = {
        bind = [
          "SUPER, F12, exec, ${notify "Disabled"}"
          "SUPER, F12, submap, reset"
          "SUPER SHIFT, F12, exec, ${notify "Disabled"}"
          "SUPER SHIFT, F12, submap, reset"
          ", escape, exec, ${notify "Disabled"}"
          ", escape, submap, reset"
        ];
      };
    };
  };
}
