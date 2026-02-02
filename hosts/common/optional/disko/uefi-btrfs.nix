# Disko configuration for UEFI systems with btrfs and optional encryption
# Usage: Import this and set disko.devices.disk.main.device = "/dev/nvme0n1";
{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.disko-btrfs;
in {
  imports = [inputs.disko.nixosModules.disko];

  options.disko-btrfs = {
    enable = lib.mkEnableOption "UEFI btrfs disk configuration";

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/nvme0n1";
      description = "The disk device to use (e.g., /dev/nvme0n1, /dev/sda)";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "8G";
      description = "Size of swap partition";
    };

    enableEncryption = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable LUKS encryption for the root partition";
    };

    enableTpm2 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable TPM2 auto-unlock with password fallback (requires enableEncryption)";
    };

    enableFido2 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable FIDO2/YubiKey unlock with password fallback (requires enableEncryption)";
    };

    enableHibernation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable hibernation support. When true, set swapSize >= RAM size (e.g., '64G' for 64GB RAM)";
    };

    hibernationResumeOffset = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Resume offset for btrfs swapfile hibernation. Required for hibernation to work.
        After first boot, run: btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
        Then set this to the returned offset value.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableTpm2 -> cfg.enableEncryption;
        message = "disko-btrfs.enableTpm2 requires disko-btrfs.enableEncryption to be true";
      }
      {
        assertion = cfg.enableFido2 -> cfg.enableEncryption;
        message = "disko-btrfs.enableFido2 requires disko-btrfs.enableEncryption to be true";
      }
      {
        assertion = cfg.enableHibernation -> cfg.hibernationResumeOffset != null;
        message = ''
          disko-btrfs.enableHibernation requires hibernationResumeOffset to be set.
          After first boot, run: btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
          Then set disko-btrfs.hibernationResumeOffset to the returned value.
        '';
      }
    ];

    boot = {
      initrd = lib.mkIf cfg.enableEncryption {
        systemd.enable = cfg.enableTpm2 || cfg.enableFido2;
        luks.devices."cryptroot" = lib.mkIf (cfg.enableTpm2 || cfg.enableFido2) {
          device = "/dev/disk/by-partlabel/disk-main-root";
          crypttabExtraOpts =
            lib.optional cfg.enableTpm2 "tpm2-device=auto"
            ++ lib.optional cfg.enableFido2 "fido2-device=auto";
        };
      };
      resumeDevice = lib.mkIf cfg.enableHibernation (
        if cfg.enableEncryption
        then "/dev/mapper/cryptroot"
        else "/dev/disk/by-partlabel/disk-main-root"
      );
      kernelParams = lib.mkIf (cfg.enableHibernation && cfg.hibernationResumeOffset != null) [
        "resume_offset=${cfg.hibernationResumeOffset}"
      ];
    };

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                type = "EF0a0";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              root =
                {
                  size = "100%";
                }
                // (
                  if cfg.enableEncryption
                  then {
                    content = {
                      type = "luks";
                      name = "cryptroot";
                      settings =
                        {
                          allowDiscards = true;
                        }
                        // lib.optionalAttrs (cfg.enableTpm2 || cfg.enableFido2) {
                          crypttabExtraOpts =
                            lib.optional cfg.enableTpm2 "tpm2-device=auto"
                            ++ lib.optional cfg.enableFido2 "fido2-device=auto";
                        };
                      content = {
                        type = "btrfs";
                        extraArgs = ["-f"];
                        subvolumes = {
                          "/root" = {
                            mountpoint = "/";
                            mountOptions = ["compress=zstd" "noatime"];
                          };
                          "/home" = {
                            mountpoint = "/home";
                            mountOptions = ["compress=zstd" "noatime"];
                          };
                          "/nix" = {
                            mountpoint = "/nix";
                            mountOptions = ["compress=zstd" "noatime"];
                          };
                          "/swap" = {
                            mountpoint = "/.swapvol";
                            swap.swapfile.size = cfg.swapSize;
                          };
                        };
                      };
                    };
                  }
                  else {
                    content = {
                      type = "btrfs";
                      extraArgs = ["-f"];
                      subvolumes = {
                        "/root" = {
                          mountpoint = "/";
                          mountOptions = ["compress=zstd" "noatime"];
                        };
                        "/home" = {
                          mountpoint = "/home";
                          mountOptions = ["compress=zstd" "noatime"];
                        };
                        "/nix" = {
                          mountpoint = "/nix";
                          mountOptions = ["compress=zstd" "noatime"];
                        };
                        "/swap" = {
                          mountpoint = "/.swapvol";
                          swap.swapfile.size = cfg.swapSize;
                        };
                      };
                    };
                  }
                );
            };
          };
        };
      };
    };
  };
}
