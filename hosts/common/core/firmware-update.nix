{pkgs, ...}: {
  # hardware firmware update
  services.fwupd.enable = true;

  # Ensure polkit is enabled for firmware-manager authorization
  # (usually already enabled by desktop environments)
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    firmware-manager
  ];
}
