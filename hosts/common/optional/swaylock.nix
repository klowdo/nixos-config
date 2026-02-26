{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.swaylock;
in {
  options.extraServices.swaylock.enable = mkEnableOption "enable hyprlock security";

  config = mkIf cfg.enable {
    security.pam.services = {
      swaylock = {};
    };
  };
}
