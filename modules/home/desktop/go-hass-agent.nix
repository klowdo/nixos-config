{...}: {
  flake.modules.homeManager.go-hass-agent = {pkgs, ...}: {
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
