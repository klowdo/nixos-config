{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.nvidia-greenboost;
in {
  options.services.nvidia-greenboost = {
    enable = lib.mkEnableOption "NVIDIA GreenBoost GPU VRAM extension";

    vramSize = lib.mkOption {
      type = lib.types.str;
      default = "12G";
      description = "Tier 1 GPU VRAM size allocation";
    };

    ramSize = lib.mkOption {
      type = lib.types.str;
      default = "51G";
      description = "Tier 2 DDR RAM allocation";
    };

    nvmeSize = lib.mkOption {
      type = lib.types.str;
      default = "64G";
      description = "Tier 3 NVMe swap allocation";
    };

    nvmeDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/nvme0n1";
      description = "NVMe device path for Tier 3 storage";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (pkgs.callPackage ../../pkgs/nvidia-greenboost/module.nix {
        kernel = config.boot.kernelPackages.kernel;
      })
    ];

    boot.extraModprobeConfig = ''
      options greenboost vram_size=${cfg.vramSize} ram_size=${cfg.ramSize} nvme_size=${cfg.nvmeSize} nvme_dev=${cfg.nvmeDevice}
    '';

    services.udev.extraRules = ''
      KERNEL=="greenboost", SUBSYSTEM=="misc", MODE="0660", GROUP="video"
    '';

    boot.kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 5;
      "vm.dirty_background_ratio" = 2;
    };

    environment.systemPackages = [
      (pkgs.callPackage ../../pkgs/nvidia-greenboost {})
    ];
  };
}
