{
  flake.modules.nixos.ly = {
    services.displayManager = {
      defaultSession = "hyprland-uwsm";
      ly.enable = true;
    };
  };
}
