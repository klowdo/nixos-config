{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.kando;
in {
  options.features.desktop.kando.enable =
    mkEnableOption "Kando pie menu with Hyprland integration";

  config = mkIf cfg.enable {
    home.packages = [pkgs.kando];

    xdg.configFile."kando/config.json".text = builtins.toJSON {
      trayIconFlavor = "none";
      ignoreWriteProtectedConfigFiles = true;
      menuTheme = "default";
      darkMenuTheme = "default";
      menuThemeColors = {};
      darkMenuThemeColors = {};
      enableDarkModeForMenuThemes = false;
      soundTheme = "none";
      soundVolume = 0.5;
      settingsWindowColorScheme = "system";
      settingsWindowFlavor = "transparent-system";
      lazyInitialization = false;
      enableVersionCheck = false;
      zoomFactor = 1;
      centerDeadZone = 50;
      minParentDistance = 150;
      dragThreshold = 15;
      fadeInDuration = 150;
      fadeOutDuration = 200;
      enableMarkingMode = true;
      enableTurboMode = true;
      warpMouse = true;
      enableGamepad = false;
      sameShortcutBehavior = "nothing";
      hideSettingsButton = false;
      settingsButtonPosition = "bottom-right";
    };

    features.desktop.solaar = {
      enable = true;
      rules = [
        [
          {Key = ["Mouse Gesture Button" "pressed"];}
          {KeyPress = ["Control_L" "space"];}
        ]
      ];
    };

    wayland.windowManager.hyprland.settings = {
      exec-once = ["kando --in-process-gpu"];

      windowrulev2 = [
        "noblur,class:(kando)"
        "opaque,class:(kando)"
        "size 100% 100%,class:(kando)"
        "noborder,class:(kando)"
        "noanim,class:(kando)"
        "float,class:(kando)"
        "pin,class:(kando)"
      ];

      bind = [
        "CTRL, Space, global, org.chromium.Chromium:example-menu"
      ];
    };
  };
}
