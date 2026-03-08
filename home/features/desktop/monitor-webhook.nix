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
          script = pkgs.writeShellScript "monitor-webhook" ''
            ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
              event="''${line%%>>*}"
              if [ "$event" = "monitoradded" ]; then
                is_hp=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '[.[] | select(.description | contains("HP Z40c G3"))] | length')
                if [ "$is_hp" -gt 0 ] && ${pkgs.tailscale}/bin/tailscale status &>/dev/null; then
                  ${pkgs.curl}/bin/curl -s -X POST https://assistant.home.flixen.se/api/webhook/enable_skarmgej
                fi
              elif [ "$event" = "monitorremoved" ]; then
                if ${pkgs.tailscale}/bin/tailscale status &>/dev/null; then
                  ${pkgs.curl}/bin/curl -s -X POST https://assistant.home.flixen.se/api/webhook/disable_skarmgej
                fi
              fi
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
