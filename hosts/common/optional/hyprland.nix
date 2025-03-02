{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  ## to login with hyprlock
  security.pam.services.hyprlock = {};

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
  ];
}
