{
  outputs,
  lib,
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    #
    # ========== Hardware ==========
    #
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.dell-xps-15-9530
    # disable nvidia in default config, enable in specialisation
    # inputs.hardware.nixosModules.common-gpu-nvidia-disable
    ./hardware/dual-gpu.nix
    ./hardware/default-disable-nvidia.nix
    ./hardware/keychron.nix
    ./hardware/fingerprint.nix

    # inputs.hardware.nixosModules.common-cpu-intel
    # inputs.hardware.nixosModules.common-pc-laptop
    # inputs.hardware.nixosModules.common-pc-laptop-ssd

    # ========== Required Configs ==========
    #
    # TODO: combine theses
    ../common

    #
    # ========== Optional Configs ==========
    #
    ../common/optional/thunderbolt.nix
    ../common/optional/resolved.nix
    ../common/optional/zsh.nix
    ../common/optional/audio.nix
    ../common/optional/printing.nix
    ../common/optional/keyboard.nix
    ../common/optional/ld.nix
    ../common/optional/nerworking.nix
    ../common/optional/thunar.nix
    ../common/optional/openssh.nix
    ../common/optional/graphics.nix
    ../common/optional/hyprland.nix
    ../common/optional/bluetooth.nix
    ../common/optional/avahi.nix
    ../common/optional/default.nix
    ../common/optional/default.nix
    ../common/optional/tailscale-exit-node.nix
    ../common/optional/udev.nix
    ../common/optional/icu.nix
    ../common/optional/dotnet-dev-certs.nix
    ../common/optional/steam.nix
  ];

  powerManagement.enable = true;

  extraServices = {
    docker.enable = true;
    # hyprlock.enable = true;
    swaylock.enable = true;
    # tlp.enable = true;
    # auto-cpufreq.enable = true;
    power-profiles-daemon.enable = true; # Already enables upower for hyprdynamicmonitors
    # strongSwan.enable = true;
    # strongSwan.
    strongSwan-swanctl.enable = true;
  };

  #TODO: fix this... use same names for modules
  modules = {
    resolved.enable = true;
  };

  # Kernel Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["i915.force_probe=a7a0"];
  };
}
