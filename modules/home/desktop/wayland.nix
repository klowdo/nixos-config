{...}: {
  flake.modules.homeManager.wayland = {pkgs, ...}: {
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    xdg.portal = {
      enable = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = ["gtk" "hyprland"];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
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
      awww
      grim
      brightnessctl
      pavucontrol
    ];
  };
}
