{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.battery-charge-threshold;
  applyScript = pkgs.writeShellScript "apply-battery-charge-threshold" ''
    set -eu
    for bat in /sys/class/power_supply/BAT*; do
      end="$bat/charge_control_end_threshold"
      start="$bat/charge_control_start_threshold"
      [ -w "$end" ] || continue
      ${optionalString (cfg.startThreshold != null) ''
      [ -w "$start" ] && echo ${toString cfg.startThreshold} > "$start" || true
    ''}
      echo ${toString cfg.endThreshold} > "$end"
    done
  '';
in {
  options.extraServices.battery-charge-threshold = {
    enable = mkEnableOption "cap battery charge to preserve long term health";
    endThreshold = mkOption {
      type = types.ints.between 1 100;
      default = 80;
      description = "Stop charging once the battery reaches this percentage.";
    };
    startThreshold = mkOption {
      type = types.nullOr (types.ints.between 1 100);
      default = null;
      description = "Resume charging once the battery drops below this percentage. Null leaves firmware default.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.battery-charge-threshold = {
      description = "Apply battery charge threshold";
      wantedBy = ["multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target"];
      after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = applyScript;
      };
    };
  };
}
