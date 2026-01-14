{
  pkgs,
  lib,
  config,
  ...
}: let
  # Script to check if laptop lid is CLOSED (returns 0 if closed, 1 if open)
  check-lid-closed = pkgs.writeShellScriptBin "check-lid-closed" ''
    # Check if laptop lid is CLOSED
    # Returns 0 (success) if lid is CLOSED, 1 (failure) if lid is OPEN
    # Used with pam_succeed_if to skip fingerprint when lid is closed

    LID_STATE_FILES=(
      "/proc/acpi/button/lid/LID0/state"
      "/proc/acpi/button/lid/LID/state"
    )

    # Check lid state from /proc/acpi
    for lid_file in "''${LID_STATE_FILES[@]}"; do
      if [[ -f "$lid_file" ]]; then
        state=$(cat "$lid_file" | awk '{print $2}')
        if [[ "$state" == "closed" ]]; then
          exit 0  # Lid is CLOSED - success (will skip fingerprint)
        elif [[ "$state" == "open" ]]; then
          exit 1  # Lid is OPEN - failure (will use fingerprint)
        fi
      fi
    done

    # If we can't determine lid state, assume open (allow fingerprint)
    exit 1
  '';
in {
  environment.systemPackages = [
    pkgs.fprintd
    check-lid-closed
  ];

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  # Used to allow a password login on first login as an alternative to just a fingerprint
  security.pam.services.login.fprintAuth = false;

  # Custom sudo PAM config - only use fingerprint when lid is open
  security.pam.services.sudo = {
    text = lib.mkDefault ''
      # Account management
      account required pam_unix.so

      # Authentication - check if lid is CLOSED, then skip fingerprint
      # If lid is CLOSED (exit 0/success), skip 1 line (skip fingerprint)
      # If lid is OPEN (exit 1/fail), continue to fingerprint
      auth [success=1 default=ignore] pam_exec.so quiet ${check-lid-closed}/bin/check-lid-closed
      auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
      auth sufficient pam_unix.so try_first_pass nullok
      auth required pam_deny.so

      # Password management
      password sufficient pam_unix.so nullok sha512

      # Session management
      session required pam_unix.so
    '';
  };
  # similarly to how other distributions handle the fingerprinting login
  security.pam.services.gdm-fingerprint = lib.mkIf (config.services.fprintd.enable) {
    text = ''
      auth       required                    pam_shells.so
      auth       requisite                   pam_nologin.so
      auth       requisite                   pam_faillock.so      preauth
      auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
      auth       optional                    pam_permit.so
      auth       required                    pam_env.so
      auth       [success=ok default=1]      ${pkgs.gdm}/lib/security/pam_gdm.so
      auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so

      account    include                     login

      password   required                    pam_deny.so

      session    include                     login
      session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    '';
  };
}
