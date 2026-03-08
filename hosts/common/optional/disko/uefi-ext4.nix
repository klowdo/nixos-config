# Disko configuration for UEFI systems with ext4 (simpler setup)
# Usage: Import this and set disko-ext4.enable = true; disko-ext4.device = "/dev/nvme0n1";
{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.disko-ext4;
in {
  imports = [inputs.disko.nixosModules.disko];

  options.disko-ext4 = {
    enable = lib.mkEnableOption "UEFI ext4 disk configuration";

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/nvme0n1";
      description = "The disk device to use (e.g., /dev/nvme0n1, /dev/sda)";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "8G";
      description = "Size of swap partition (set to '0' to disable)";
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
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableTpm2 -> cfg.enableEncryption;
        message = "disko-ext4.enableTpm2 requires disko-ext4.enableEncryption to be true";
      }
      {
        assertion = cfg.enableFido2 -> cfg.enableEncryption;
        message = "disko-ext4.enableFido2 requires disko-ext4.enableEncryption to be true";
      }
      {
        assertion = cfg.enableHibernation -> cfg.swapSize != "0";
        message = "disko-ext4.enableHibernation requires swap to be enabled (swapSize != '0')";
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
      resumeDevice = lib.mkIf cfg.enableHibernation "/dev/disk/by-partlabel/disk-main-swap";
    };

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions =
              {
                ESP = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                  };
                };
              }
              // lib.optionalAttrs (cfg.swapSize != "0") {
                swap = {
                  size = cfg.swapSize;
                  content = {
                    type = "swap";
                    discardPolicy = "both";
                  };
                };
              }
              // {
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
                          type = "filesystem";
                          format = "ext4";
                          mountpoint = "/";
                        };
                      };
                    }
                    else {
                      content = {
                        type = "filesystem";
                        format = "ext4";
                        mountpoint = "/";
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
