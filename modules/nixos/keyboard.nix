{
  flake.modules.nixos.keyboard = {
    services.xserver = {
      xkb = {
        layout = "us,se";
      };
    };
  };
}
