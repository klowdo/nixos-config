{
  lib,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  hardware.nvidia = {
    open = true;
    prime = {
      # Bus ID of the Intel GPU.
      intelBusId = lib.mkDefault "PCI:0:2:0";

      # Bus ID of the NVIDIA GPU.
      nvidiaBusId = lib.mkDefault "PCI:1:0:0";
    };
  };
}
