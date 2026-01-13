{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  ## to login with hyprlock - enable fingerprint auth
  security.pam.services.hyprlock = {
    fprintAuth = true;
  };

  # Prevent systemd from handling lid switch (let Hyprland do it)
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
  ];
}
