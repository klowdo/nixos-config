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
        "CTRL, Space, global, kando://menu/Kando"
      ];
    };
  };
}
