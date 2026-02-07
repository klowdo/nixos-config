{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    #
    # ========== Hardware ==========
    #
    ./hardware-configuration.nix

    # Disko configuration (only needed for fresh installations)
    # Uncomment during installation, then comment out after first boot
    ./disko.nix
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
    ../common
    ./sops.nix

    #
    # ========== Optional Configs ==========
    #
    ../common/optional/secure-boot.nix
    ../common/optional/tpm.nix
    ../common/optional/thunderbolt.nix
    ../common/optional/resolved.nix
    ../common/optional/zsh.nix
    ../common/optional/audio.nix
    ../common/optional/printing.nix
    ../common/optional/keyboard.nix
    ../common/optional/ld.nix
    ../common/optional/networking.nix
    ./wifi.nix
    ../common/optional/thunar.nix
    ../common/optional/openssh.nix
    ../common/optional/graphics.nix
    ../common/optional/hyprland.nix
    ../common/optional/plymouth.nix
    ../common/optional/bluetooth.nix
    ../common/optional/avahi.nix
    ../common/optional/default.nix
    ../common/optional/tailscale-exit-node.nix
    ../common/optional/udev.nix
    ../common/optional/icu.nix
    ../common/optional/dotnet-dev-certs.nix
    ../common/optional/steam.nix
    ../common/optional/flatpak.nix
    ../common/optional/nss-docker-ng.nix
    ../common/optional/swaylock.nix
    ../common/optional/power-profiles-daemon.nix
    ../common/optional/auto-upgrade.nix
    ../common/optional/systemd-notify.nix
  ];

  networking.hostName = "dellicious";

  powerManagement.enable = true;

  extraServices = {
    docker.enable = true;
    resolved.enable = true;
    # hyprlock.enable = true;
    swaylock.enable = true;
    # tlp.enable = true;
    # auto-cpufreq.enable = true;
    power-profiles-daemon.enable = true; # Already enables upower for hyprdynamicmonitors
    # strongSwan.enable = true;
    strongSwan-swanctl.enable = true;
    # nss-docker-ng = {
    #   enable = true;
    #   dockerHost = "unix:///run/user/1000/docker.sock";
    # };
  };

  # Kernel Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelModules = ["kvm-intel"];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["i915.force_probe=a7a0"];
  };
}
