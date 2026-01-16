{
  imports = [
    ./nh.nix
    ./firmware-update.nix
    ./firewall.nix
    ./tailscale.nix
    ./yubikey.nix
    ./sops.nix
    ./locale.nix
  ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
