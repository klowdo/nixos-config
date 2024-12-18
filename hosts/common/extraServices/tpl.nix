{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.tpl;
in {
  options.extraServices.tpl.enable = mkEnableOption "enable tpl cpu management";

  config = mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 80;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
        # CPU_SCALING_MIN_FREQ_ON_AC = 400000;
        # CPU_SCALING_MAX_FREQ_ON_AC = 4500000;
        # CPU_SCALING_MAX_FREQ_ON_AC=5200000

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
        # always use battery mode
        # TLP_DEFAULT_MODE = "BAT";
        # TLP_PERSISTENT_DEFAULT = 1;
      };
    };
  };
}
