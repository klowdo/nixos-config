{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.auto-cpufreq;
in {
  options.extraServices.auto-cpufreq.enable = mkEnableOption "enable auto-cpufreq management";

  config = mkIf cfg.enable {
    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "powersave";
        turbo = "never";
      };
    };
  };
}
