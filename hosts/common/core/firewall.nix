{...}: {
  networking.firewall = {
    # Explicitly enable firewall (enabled by default, but being explicit is better)
    enable = true;

    # Default policy: deny all incoming, allow all outgoing
    # This is the secure default behavior

    # Allow specific UDP ports
    allowedUDPPorts = [
      # Note: Individual services add their own ports via allowedUDPPorts
      # Tailscale: 41641 (added by tailscale.nix)
      # mDNS: 5353 (added by avahi.nix if enabled)
    ];

    # Allow specific TCP ports
    allowedTCPPorts = [
      22 # SSH - hardened with key-only authentication (see openssh.nix)
      # Individual services should add their ports here if needed
    ];

    # Log refused connections for security monitoring
    # Check logs with: journalctl -k -g "refused"
    logRefusedConnections = true;

    # Log refused packets (useful for debugging but can be noisy)
    logRefusedPackets = false;

    # Refuse ping requests from external networks
    # Makes the laptop less discoverable on public networks
    allowPing = false;

    # Log reverse path filter drops
    logReversePathDrops = true;

    # Note: Docker sets checkReversePath to "loose" when enabled
    # This is required for Docker networking to work properly

    # Gaming notes:
    # - Client gaming works without special firewall rules (outgoing connections allowed by default)
    # - To host game servers, add specific ports to allowedTCPPorts/allowedUDPPorts above
    # - UPnP is not needed on laptop firewall (only on router for port forwarding)
  };
}
