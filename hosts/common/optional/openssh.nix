{
  programs.ssh.knownHosts = {
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

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
