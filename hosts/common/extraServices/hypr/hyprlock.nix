{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.hyprlock;
in {
  options.extraServices.hyprlock.enable = mkEnableOption "enable hyprlock security";

  config = mkIf cfg.enable {
    security.pam.services.hyprlock = {};
  };
}
