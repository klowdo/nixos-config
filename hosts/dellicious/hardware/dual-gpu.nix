{
  config,
  lib,
  ...
}: {
  specialisation = {
    nvidia.configuration = {
      # Nvidia Configuration
      services.xserver.videoDrivers = ["nvidia"];

      # Override base blacklist to allow nvidia modules
      boot.blacklistedKernelModules = lib.mkForce ["nouveau"];

      hardware = {
        graphics.enable = true;

        nvidia = {
          # Use open source kernel modules (recommended for RTX/GTX 16xx series)
          open = true;

          # Optionally, you may need to select the appropriate driver version for your specific GPU.
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
          modesetting.enable = true;

          prime = {
            sync.enable = true;

            # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
            nvidiaBusId = "PCI:01:00:0";

            # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
            intelBusId = "PCI:00:02:0";
          };
        };
      };
    };
  };
}
