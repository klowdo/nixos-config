# GNOME Desktop Environment configuration
{pkgs, ...}: {
  # Enable GNOME Desktop Environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # GNOME Keyring for credential management
  services.gnome.gnome-keyring.enable = true;

  # Exclude some default GNOME packages
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany # web browser
    geary # email client
    gnome-music
  ];

  # Additional GNOME packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    dconf-editor
    gnome-extension-manager
  ];

  # XDG portal for GNOME
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
  };
}
