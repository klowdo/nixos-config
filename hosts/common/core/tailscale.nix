{lib, ...}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
    extraUpFlags = [
      "--accept-routes"
      "--accept-dns"
      "--ssh"
      "--reset"
    ];
    extraSetFlags = [
      "--exit-node-allow-lan-access"
    ];
  };
  networking.firewall.allowedUDPPorts = [41641]; # Facilitate firewall punching
}
