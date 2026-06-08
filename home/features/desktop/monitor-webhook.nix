{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.monitor-webhook;
in {
  options.features.desktop.monitor-webhook.enable = mkEnableOption "enable monitor webhook";

  config = mkIf cfg.enable {
    systemd.user.services.monitor-webhook = {
      Unit = {
        Description = "Trigger Home Assistant webhook on HP Z40c G3 monitor connect/disconnect";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = let
          notify = pkgs.writeShellScript "monitor-notify" ''
            for i in 1 2 3; do
              ${pkgs.libnotify}/bin/notify-send "$@" 2>/dev/null && exit 0
              sleep 2
            done
          '';
          script = pkgs.writeShellScript "monitor-webhook" ''
            hp_connected() {
              [ "$(timeout 5 ${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '[.[] | select(.description | contains("HP Z40c G3"))] | length')" -gt 0 ]
            }

            fire() {
              action="$1"
              timeout 5 ${pkgs.tailscale}/bin/tailscale status &>/dev/null || return
              if ${pkgs.curl}/bin/curl -sf --max-time 5 -X POST "https://assistant.home.flixen.se/api/webhook/''${action}_skarmgej"; then
                echo "Webhook fired: $action"
                ${notify} "Monitor webhook: $action"
              else
                echo "Webhook failed: $action"
                ${notify} "Monitor webhook: failed to $action"
              fi
            }

            hp_connected && fire enable

            ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
              event="''${line%%>>*}"
              case "$event" in
                monitoradded) hp_connected && fire enable ;;
                monitorremoved) hp_connected || fire disable ;;
              esac
            done
          '';
        in "${script}";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
