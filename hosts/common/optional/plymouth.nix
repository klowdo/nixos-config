{lib, ...}:
with lib; {
  boot.plymouth = {
    enable = true;
    theme = lib.mkDefault "bgrt";
  };

  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
}
