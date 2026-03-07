{
  hardware.intelgpu = {
    # Raptor lake :Intel® VPL
    driver = "i915"; # xe
    vaapiDriver = "intel-media-driver";
  };

  hardware.graphics.enable = true;
}
