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
    # Don't use fprintAuth - it doesn't work correctly with the default stack
    # Instead, use custom PAM text to ensure "sufficient" control for both methods
    #   text = ''
    #     # Account management
    #     account required pam_unix.so
    #
    #     # Authentication - both are "sufficient" meaning first success wins
    #     auth sufficient pam_unix.so try_first_pass likeauth nullok
    #     auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
    #     auth required pam_deny.so
    #
    #     # Password management
    #     password sufficient pam_unix.so nullok sha512
    #
    #     # Session management
    #     session required pam_unix.so
    #     session required pam_env.so conffile=/etc/pam/environment readenv=0
    #   '';
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
