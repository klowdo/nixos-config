{
  flake.modules.nixos.swaylock = {
    security.pam.services = {
      swaylock = {};
    };
  };
}
