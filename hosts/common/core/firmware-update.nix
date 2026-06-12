{pkgs, ...}: {
  # hardware firmware update
  services.fwupd.enable = true;

  # Ensure polkit is enabled for firmware-manager authorization
  # (usually already enabled by desktop environments)
  security.polkit.enable = true;

  # fwupd 2.x `fwupdmgr refresh` loads metadata via the daemon, needing the
  # refresh-remote polkit action. The fwupd-refresh.service user has no active
  # session, so allow it explicitly or the timer fails with "Failed to obtain auth".
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.fwupd.refresh-remote" &&
          subject.user == "fwupd-refresh") {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = with pkgs; [
    firmware-manager
  ];
}
