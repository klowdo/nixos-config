{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.fprintd
  ];

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
  security.pam.services = {
    # Used to allow a password login on first login as an alternative to just a fingerprint
    login.fprintAuth = false;

    sudo.fprintAuth = false;

    # Disable fingerprint for polkit GUI prompts (Tailscale, Nautilus, etc.)
    polkit-1.fprintAuth = false;
    # # similarly to how other distributions handle the fingerprinting login
    # gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
    #   text = ''
    #     auth       required                    pam_shells.so
    #     auth       requisite                   pam_nologin.so
    #     auth       requisite                   pam_faillock.so      preauth
    #     auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
    #     auth       optional                    pam_permit.so
    #     auth       required                    pam_env.so
    #     auth       [success=ok default=1]      ${pkgs.gdm}/lib/security/pam_gdm.so
    #     auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
    #
    #     account    include                     login
    #
    #     password   required                    pam_deny.so
    #
    #     session    include                     login
    #     session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    #   '';
    # };
  };
}
