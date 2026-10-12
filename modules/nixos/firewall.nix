{
  flake.modules.nixos.firewall = {
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [];
      # WebRTC voice in Electron apps (Vesktop) needs incoming UDP replies
      # on high ports during DTLS handshake. Conntrack alone is insufficient
      # because Chromium's WebRTC stack binds ports differently than native
      # Discord. See nixpkgs#238961.
      allowedUDPPortRanges = [
        {
          from = 50000;
          to = 65535;
        }
      ];
      allowedTCPPorts = [
        22
      ];
      logRefusedConnections = true;
      logRefusedPackets = false;
      allowPing = false;
      logReversePathDrops = true;
    };
  };
}
