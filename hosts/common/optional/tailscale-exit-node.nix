{
  imports = [../core/tailscale.nix];
  services.tailscale = {
    useRoutingFeatures = "both";
    extraUpFlags = ["--advertise-exit-node"];
  };
}
