{
  config,
  pkgs,
  ...
}: let
  cfg = config.hostConfig;
  effectiveHome =
    if cfg.home != ""
    then cfg.home
    else if pkgs.stdenv.isLinux
    then "/home/${cfg.mainUser}"
    else "/Users/${cfg.mainUser}";
  configDir =
    if cfg.dotfilesPath != ""
    then cfg.dotfilesPath
    else "${effectiveHome}/.dotfiles";
  notifyScript = pkgs.writeShellScript "notify-upgrade" ''
    STATUS="$1"
    MESSAGE="$2"
    URGENCY="''${3:-normal}"

    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${cfg.mainUser})/bus"
    ${pkgs.sudo}/bin/sudo -u ${cfg.mainUser} \
      DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
      ${pkgs.libnotify}/bin/notify-send \
        -u "$URGENCY" \
        -a "NixOS Upgrade" \
        -i "system-software-update" \
        "NixOS Auto-Upgrade: $STATUS" \
        "$MESSAGE"
  '';
in {
  system.autoUpgrade = {
    enable = true;

    # Use the local flake after git pull
    flake = "${configDir}";

    # Print build logs
    flags = [
      "-L"
    ];

    dates = "06:00";

    # Apply on next reboot
    operation = "boot";

    # Run garbage collection after upgrade
    runGarbageCollection = true;
  };

  # Pull latest config from GitHub before auto-upgrade runs
  systemd.services.nixos-upgrade = {
    unitConfig = {
      OnFailure = ["notify-upgrade-failure.service"];
    };
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.git}/bin/git -C ${configDir} pull --ff-only origin main"
        "${notifyScript} Started 'Pulling latest config and upgrading system...'"
      ];
      ExecStartPost = "${notifyScript} Completed 'System upgrade finished successfully'";
    };
  };

  systemd.services.notify-upgrade-failure = {
    description = "Notify on NixOS upgrade failure";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${notifyScript} Failed 'System upgrade failed! Check journalctl -u nixos-upgrade' critical";
    };
  };
}
