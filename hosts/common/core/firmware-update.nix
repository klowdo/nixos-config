{pkgs, ...}: {
  # hardware firmware update
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    firmware-manager
  ];
}
