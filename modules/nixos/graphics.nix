{
  flake.modules.nixos.graphics = {
    hardware.intelgpu = {
      driver = "i915";
      vaapiDriver = "intel-media-driver";
    };

    hardware.graphics.enable = true;
  };
}
