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
  };

  config = lib.mkIf cfg.enable {
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
                        settings = {
                          allowDiscards = true;
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
