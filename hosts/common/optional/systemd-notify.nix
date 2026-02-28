{
  config,
  pkgs,
  ...
}: let
  cfg = config.hostConfig;
  notifyScript = pkgs.writeShellScript "systemd-notify" ''
    UNIT="$1"
    STATUS="$2"
    URGENCY="''${3:-normal}"

    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${cfg.mainUser})/bus"
    ${pkgs.sudo}/bin/sudo -u ${cfg.mainUser} \
      DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
      ${pkgs.libnotify}/bin/notify-send \
        -u "$URGENCY" \
        -a "systemd" \
        -i "system-software-update" \
        "Systemd: $STATUS" \
        "$UNIT"
  '';
in {
  systemd.services."notify-failure@" = {
    description = "Send failure notification for %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${notifyScript} %i 'Failed' critical";
    };
  };

  systemd.services."notify-status@" = {
    description = "Send status notification for %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${notifyScript} %i 'Started' normal";
    };
  };

  systemd.services.systemd-failure-monitor = {
    description = "Monitor all systemd service failures";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = pkgs.writeShellScript "failure-monitor" ''
        ${pkgs.systemd}/bin/journalctl -f -o json -p err | \
        ${pkgs.jq}/bin/jq --unbuffered -r '
          select(.UNIT != null and ._SYSTEMD_UNIT != null) |
          select(.MESSAGE | test("Failed|failed|error|Error")) |
          "\(.UNIT // ._SYSTEMD_UNIT): \(.MESSAGE | .[0:100])"
        ' | while read -r msg; do
          ${notifyScript} "$msg" "Error" critical
        done
      '';
    };
  };
}
