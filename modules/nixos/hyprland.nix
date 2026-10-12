{
  flake.modules.nixos.hyprland = {
    pkgs,
    lib,
    ...
  }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    # Workaround: nixpkgs passes the raw Hyprland binary to UWSM instead of start-hyprland
    # https://github.com/hyprwm/Hyprland/discussions/12661
    programs.uwsm.waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      binPath = lib.mkForce "/run/current-system/sw/bin/start-hyprland";
    };

    security.pam.services.hyprlock = {
      fprintAuth = true;
    };

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };
  };
}
