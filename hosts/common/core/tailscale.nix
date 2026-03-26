{
  lib,
  config,
  ...
}: {
  sops.secrets."applications/tailscale/authkey" = {};

  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
    authKeyFile = config.sops.secrets."applications/tailscale/authkey".path;
    extraUpFlags = [
      "--accept-routes"
      "--accept-dns"
      "--ssh"
      "--exit-node-allow-lan-access"
    ];
  };
  networking.firewall.allowedUDPPorts = [41641]; # Facilitate firewall punching
}
