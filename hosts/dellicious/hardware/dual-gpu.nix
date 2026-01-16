{
  config,
  lib,
  inputs,
  ...
}: {
  specialisation = {
    nvidia.configuration = {
      imports = [
        inputs.hardware.nixosModules.dell-xps-15-9530-nvidia
      ];
      # Nvidia Configuration
      services.xserver.videoDrivers = ["nvidia"];

      # Override base blacklist to allow nvidia modules
      boot.blacklistedKernelModules = lib.mkForce ["nouveau"];

      hardware = {
        graphics.enable = true;

        nvidia = {
          # Optionally, you may need to select the appropriate driver version for your specific GPU.
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
          modesetting.enable = true;
        };
      };
    };
  };
}
