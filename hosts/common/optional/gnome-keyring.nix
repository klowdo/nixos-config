{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.gnome.gnome-keyring-ssh;
in {
  options.services.gnome.gnome-keyring-ssh = {
    enable = mkEnableOption "GNOME Keyring with SSH agent support and PAM integration";
  };

  config = mkIf cfg.enable {
    # GNOME Keyring daemon service
    services.gnome.gnome-keyring.enable = true;

    # PAM configuration for GNOME Keyring integration
    security.pam.services = {
      login.enableGnomeKeyring = true;
      passwd.enableGnomeKeyring = true;
      sudo.enableGnomeKeyring = true;
    };

    # System packages for GNOME Keyring GUI management
    environment.systemPackages = with pkgs; [
      seahorse # GNOME Keyring GUI
      gcr # GNOME crypto services
      libsecret
    ];

    # Environment variables for SSH agent integration
    programs.ssh.startAgent = false; # Disable default SSH agent to use GNOME Keyring
    environment.variables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    };
  };
}

