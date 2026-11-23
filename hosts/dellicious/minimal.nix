{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # ========== Hardware ==========
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.dell-xps-15-9530

    # ========== Required Configs (includes SOPS, firewall, yubikey, tailscale) ==========
    ../common

    # ========== Minimal Optional Configs ==========
    ../common/optional/tpm.nix
    ../common/optional/resolved.nix
    ../common/optional/zsh.nix
    ../common/optional/networking.nix
    ./wifi.nix
    ../common/optional/openssh.nix
    ../common/optional/graphics.nix
  ];

  networking.hostName = "dellicious-minimal";

  # Kernel & Bootloader (same hardware as dellicious)
  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelModules = ["kvm-intel"];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["i915.force_probe=a7a0"];
  };
}
