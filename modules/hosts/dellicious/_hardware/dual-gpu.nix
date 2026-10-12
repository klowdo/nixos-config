inputs: {
  config,
  lib,
  ...
}: {
  specialisation = {
    nvidia.configuration = {
      imports = [inputs.hardware.nixosModules.dell-xps-15-9530-nvidia];
      services.xserver.videoDrivers = ["nvidia"];

      # Override base blacklist to allow nvidia modules
      boot.blacklistedKernelModules = lib.mkForce ["nouveau"];

      hardware = {
        graphics.enable = true;

        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
          modesetting.enable = true;
        };
      };

      services.nvidia-greenboost.enable = false;
    };
  };
}
