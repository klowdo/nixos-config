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
  };

  config = lib.mkIf cfg.enable {
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
                type = "EF00";
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
                      settings = {
                        allowDiscards = true;
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
