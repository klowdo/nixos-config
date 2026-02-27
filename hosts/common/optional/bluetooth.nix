{
  # Bluetooth Support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = "true";
        # Auto-trust devices on first connection
        AutoEnable = "true";
        # Keep devices trusted after pairing
        RememberPowered = "true";
      };
      Policy = {
        # Auto-connect to trusted devices
        AutoEnable = "true";
      };
    };
  };
  services.blueman.enable = false;
}
