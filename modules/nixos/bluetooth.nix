{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = "true";
          AutoEnable = "true";
          RememberPowered = "true";
        };
        Policy = {
          AutoEnable = "true";
        };
      };
    };
    services.blueman.enable = false;
  };
}
