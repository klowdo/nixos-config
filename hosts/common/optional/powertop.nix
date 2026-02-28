{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.powertop;
in {
  options.extraServices.powertop.enable = mkEnableOption "enable powertop management";

  config = mkIf cfg.enable {
    powerManagement.powertop.enable = true;
  };
}
