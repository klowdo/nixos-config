{
  # Enable the OpenSSH daemon with security hardening
  services.openssh = {
    enable = true;
    settings = {
      # Disable root login
      PermitRootLogin = "no";

      # Require public key authentication only (no passwords)
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;

      # Disable challenge-response authentication
      ChallengeResponseAuthentication = false;

      # Disable X11 forwarding (enable if you need it)
      X11Forwarding = false;

      # Only allow specific users (optional - remove if you want all users to have SSH access)
      # AllowUsers = [ "klowdo" ];
    };

    # Enable SFTP subsystem
    allowSFTP = true;

    # Additional hardening: disable forwarding by default (uncomment if needed)
    # settings.AllowTcpForwarding = "no";
    # settings.AllowAgentForwarding = "no";
  };
}
