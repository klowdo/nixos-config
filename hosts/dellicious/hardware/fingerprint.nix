{
  pkgs,
  lib,
  config,
  ...
}: {
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

    # Custom sudo PAM config - only use fingerprint when lid is open
    sudo = {
      fprintAuth = false;
      #   text = lib.mkDefault ''
      #     # Account management
      #     account required pam_unix.so
      #
      #     # Authentication with lid detection (inline check)
      #     # Test returns: 0 (success) if OPEN, 1 (fail) if CLOSED
      #     # success=ok: if lid OPEN (exit 0), continue to fingerprint
      #     # default=1: if lid CLOSED (exit 1), skip fingerprint line
      #     auth [success=ok default=1] pam_exec.so /bin/sh -c '[ "$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk "{print \$2}")" = "open" ]'
      #     # Only reached if lid is OPEN - try fingerprint with timeout
      #     auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so timeout=5
      #     # Password authentication - always available as fallback
      #     auth sufficient pam_unix.so try_first_pass nullok
      #     auth required pam_deny.so
      #
      #     # Password management
      #     password sufficient pam_unix.so nullok sha512
      #
      #     # Session management
      #     session required pam_unix.so
      #   '';
    };
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
