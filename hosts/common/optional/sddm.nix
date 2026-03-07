{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.sddm;
in {
  options.extraServices.sddm.enable = mkEnableOption "SDDM display manager";

  config = mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "hyprland-uwsm";
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "catppuccin-macchiato";
        package = pkgs.kdePackages.sddm;
      };
    };

    environment.systemPackages = [
      pkgs.catppuccin-sddm
    ];
  };
}
