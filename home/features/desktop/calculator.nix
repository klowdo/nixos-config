{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.calculator;

in {
  options.features.desktop.calculator.enable =
    mkEnableOption "calculator application with Hyprland integration";

  config = mkIf cfg.enable {
    # Install qalculate-gtk calculator
    home.packages = with pkgs; [
      qalculate-gtk
    ];

    # Hyprland window rules and bindings for calculator
    wayland.windowManager.hyprland.settings = {
      # Window rules for floating calculator
      windowrulev2 = [
        "float,class:(qalculate-gtk)"
        "size 800 600,class:(qalculate-gtk)"
        "center,class:(qalculate-gtk)"
        "opacity 0.95,class:(qalculate-gtk)"
      ];

      # Simple keybind to launch floating calculator
      bind = [
        "$mainMod, C, exec, qalculate-gtk"
      ];
    };
  };
}