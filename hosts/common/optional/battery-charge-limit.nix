{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.battery-charge-limit;
in {
  options.extraServices.battery-charge-limit = {
    enable = mkEnableOption "limit battery charging to extend battery lifespan";
    start = mkOption {
      type = types.ints.between 0 99;
      default = 75;
    };
    end = mkOption {
      type = types.ints.between 1 100;
      default = 80;
    };
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", KERNEL=="BAT0", ACTION=="add", ATTR{charge_control_end_threshold}="${toString cfg.end}", ATTR{charge_control_start_threshold}="${toString cfg.start}"
    '';
  };
}
