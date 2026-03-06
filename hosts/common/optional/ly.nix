{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.ly;
in {
  options.extraServices.ly.enable = mkEnableOption "Ly display manager";

  config = mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "hyprland-uwsm";
      ly.enable = true;
    };
  };
}
