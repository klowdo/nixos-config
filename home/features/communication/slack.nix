{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.communication.slack;
in {
  options.features.communication.slack.enable = mkEnableOption "enable slack";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
    ];

    systemd.user.services.slack-floating-killer = {
      Unit = {
        Description = "Kill Slack floating windows on open";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = let
          script = pkgs.writeShellScript "slack-floating-killer" ''
            ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
              event="''${line%%>>*}"
              if [ "$event" = "openwindow" ]; then
                addr="0x''${line#*>>}"
                addr="''${addr%%,*}"
                window=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.address == \"$addr\")")
                class=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.class // empty')
                floating=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.floating // false')
                if [ "$class" = "Slack" ] && [ "$floating" = "true" ]; then
                  ${pkgs.hyprland}/bin/hyprctl dispatch closewindow address:"$addr"
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
