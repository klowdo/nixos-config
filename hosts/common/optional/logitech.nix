{pkgs, ...}: {
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  systemd.user.services.solaar = {
    description = "Solaar - Logitech device manager";
    wantedBy = ["graphical-session.target"];
    after = ["dbus.service"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.solaar}/bin/solaar --window hide";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
