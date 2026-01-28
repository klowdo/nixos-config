{pkgs, ...}: let
  configDir = "/home/user/nixos-config";
in {
  system.autoUpgrade = {
    enable = true;

    # Use the local flake after git pull
    flake = "${configDir}";

    # Print build logs
    flags = [
      "-L"
    ];

    # Run on boot
    dates = "boot";

    # Apply on next reboot
    operation = "boot";

    # Run garbage collection after upgrade
    runGarbageCollection = true;
  };

  # Pull latest config from GitHub before auto-upgrade runs
  systemd.services.nixos-upgrade = {
    serviceConfig = {
      ExecStartPre = "${pkgs.git}/bin/git -C ${configDir} pull --ff-only origin main";
    };
  };
}
