{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.go-hass-agent;
in {
  options.features.desktop.go-hass-agent.enable = mkEnableOption "enable go-hass-agent";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.go-hass-agent];

    systemd.user.services.go-hass-agent = {
      Unit = {
        Description = "Go Hass Agent - Home Assistant native app for desktop";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.unstable.go-hass-agent}/bin/go-hass-agent";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
