# NixOS system-level impermanence configuration
#
# This module configures the system to use tmpfs as root (/) with
# explicit persistence of stateful directories and files to /persist.
#
# Prerequisites:
# 1. A persistent partition/subvolume mounted at /persist
# 2. Root (/) mounted as tmpfs or with btrfs blank snapshot rollback
# 3. /boot and /nix on persistent storage
#
# After enabling, run from a live USB or before first reboot:
#   mkdir -p /persist
#   cp -a /etc/machine-id /persist/etc/machine-id
#   cp -a /etc/ssh /persist/etc/ssh
#   cp -a /var/lib/nixos /persist/var/lib/nixos
#   cp -a /var/lib/systemd /persist/var/lib/systemd
#   cp -a /var/lib/sops-nix /persist/var/lib/sops-nix
{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.impermanence;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];

  options.extraServices.impermanence = {
    enable = mkEnableOption "NixOS impermanence (tmpfs root with explicit persistence)";

    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Path to the persistent storage mount point";
    };
  };

  config = mkIf cfg.enable {
    # Persistent directories and files that survive reboots
    environment.persistence.${cfg.persistPath} = {
      hideMounts = true;

      directories = [
        # ── Core system state ──
        "/var/lib/nixos" # NixOS uid/gid maps - CRITICAL
        "/var/lib/systemd" # Systemd machine-id, journal cursors, timers

        # ── Logging ──
        "/var/log" # System logs (journald, etc.)

        # ── Networking ──
        "/var/lib/NetworkManager" # NetworkManager state (lease files, etc.)
        "/etc/NetworkManager/system-connections" # Saved WiFi/VPN connection profiles

        # ── Security & secrets ──
        "/var/lib/sops-nix" # SOPS age decryption key derived from SSH host key
        "/etc/ssh" # SSH host keys - CRITICAL for SOPS key derivation

        # ── VPN ──
        "/var/lib/tailscale" # Tailscale node identity and state

        # ── Bluetooth ──
        "/var/lib/bluetooth" # Paired device keys and configuration

        # ── Audio ──
        "/var/lib/alsa" # ALSA sound card state (volume levels, etc.)

        # ── Printing ──
        "/var/lib/cups" # CUPS printer configurations and queues
        "/etc/cups" # CUPS server configuration

        # ── Flatpak ──
        "/var/lib/flatpak" # Installed Flatpak apps and runtime data

        # ── Firmware ──
        "/var/lib/fwupd" # Firmware update daemon state

        # ── Power management ──
        "/var/lib/power-profiles-daemon" # Power profile state

        # ── TPM ──
        "/var/lib/tpm" # TPM sealed data
      ];

      files = [
        "/etc/machine-id" # Unique machine identifier - CRITICAL
      ];
    };

    # Ensure the persistent storage directory exists
    # The actual mount must be defined in hardware-configuration.nix
    fileSystems.${cfg.persistPath}.neededForBoot = mkDefault true;

    # Allow the impermanence module to create fuse bind mounts for home-manager
    programs.fuse.userAllowOther = true;

    # SOPS paths (/etc/ssh, /var/lib/sops-nix) are transparently handled
    # by impermanence bind mounts - no path overrides needed.
    # The original paths in hosts/common/core/sops.nix continue to work
    # because /etc/ssh -> /persist/etc/ssh via bind mount, etc.
  };
}
