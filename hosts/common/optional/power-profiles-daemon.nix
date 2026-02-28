{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.power-profiles-daemon;
in {
  options.extraServices.power-profiles-daemon.enable = mkEnableOption "enable power-profiles-daemon management";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(config.extraServices.tlp.enable or false);
        message = ''
          Only one power manager daemon is allowed at the time: tlp.enable and power-profiles-daemon.enable are mutually exclusive.
        '';
      }
    ];
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
  };
}
