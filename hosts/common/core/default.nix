{
  imports = [
    ./nh.nix
    ./firmware-update.nix
    ./tailscale.nix
    ./yubikey.nix
    ./sops.nix
    ./locale.nix
  ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
