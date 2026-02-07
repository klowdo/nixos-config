# Filesystem layout for impermanence on dellicious
#
# Transforms the standard ext4 root into:
#   /         -> tmpfs (ephemeral, wiped on reboot)
#   /persist  -> ext4 partition (persistent storage, former root)
#   /nix      -> bind mount from /persist/nix
#   /boot     -> EFI vfat partition (unchanged)
#
# ┌──────────────────────────────────────────────────────────────┐
# │  MIGRATION REQUIRED before enabling this configuration!      │
# │                                                              │
# │  Boot from a NixOS live USB and run:                         │
# │                                                              │
# │  1. Mount the ext4 partition:                                │
# │     mount /dev/disk/by-uuid/b8e67ffd-... /mnt               │
# │                                                              │
# │  2. Move all contents into a 'persist' subdirectory:         │
# │     mkdir -p /mnt/persist                                    │
# │     # Move everything except persist itself                  │
# │     for item in /mnt/*; do                                   │
# │       [ "$(basename "$item")" = "persist" ] && continue      │
# │       mv "$item" /mnt/persist/                               │
# │     done                                                     │
# │     for item in /mnt/.*; do                                  │
# │       case "$(basename "$item")" in                          │
# │         .|..|persist) continue ;;                            │
# │       esac                                                   │
# │       mv "$item" /mnt/persist/                               │
# │     done                                                     │
# │                                                              │
# │  3. Verify critical paths exist:                             │
# │     ls /mnt/persist/nix                                      │
# │     ls /mnt/persist/etc/ssh/ssh_host_ed25519_key             │
# │     ls /mnt/persist/var/lib/nixos                            │
# │     ls /mnt/persist/var/lib/sops-nix/age/key.txt             │
# │                                                              │
# │  4. Ensure /persist/home/klowdo exists with correct state:   │
# │     ls /mnt/persist/home/klowdo/.ssh                         │
# │     ls /mnt/persist/home/klowdo/.gnupg                       │
# │                                                              │
# │  5. Unmount and reboot into the new configuration:           │
# │     umount /mnt                                              │
# │     reboot                                                   │
# └──────────────────────────────────────────────────────────────┘
{lib, ...}: {
  # Override root to use tmpfs
  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  # Mount the ext4 partition as persistent storage
  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/b8e67ffd-5876-4c08-9000-77ac86957e54";
    fsType = "ext4";
    neededForBoot = true;
  };

  # Bind-mount /nix from persistent storage (required for NixOS to function)
  fileSystems."/nix" = {
    device = "/persist/nix";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
  };

  # Boot partition stays unchanged (defined in hardware-configuration.nix)
  # fileSystems."/boot" is already defined there

  # Separate tmpfs for /home/klowdo so impermanence fuse mounts work
  # (fuse mountpoint must not be on the same tmpfs as root)
  fileSystems."/home/klowdo" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=512M" "mode=700" "uid=1000" "gid=100"];
  };
}
