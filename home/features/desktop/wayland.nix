{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland.enable = mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    xdg.portal = {
      enable = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = ["gtk" "hyprland"];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    home.packages = with pkgs; [
      qt6.qtwayland
      waypipe
      wf-recorder
      wtype
      ydotool
      wlr-randr
      gsettings-desktop-schemas
      swww
      grim
      brightnessctl
      pavucontrol
    ];
  };
}
